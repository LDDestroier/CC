local mainPath = ".sysmail"
local yourID = os.getComputerID()
local onlyUseWiredModems = false

local config = {
	channel = 1024,
	keyPath = fs.combine(mainPath, "keys"),
	mailPath = fs.combine(mainPath, "mail"),
	apiPath = fs.combine(mainPath, "api")
}

local keys = {}

local readFile = function(path)
	local file = fs.open(path, "r")
	local contents = file.readAll()
	file.close()
	return contents
end

local writeFile = function(path, contents)
	if fs.isReadOnly(path) then
		return false
	else
		local file = fs.open(path, "w")
		file.write(contents)
		file.close()
		return true
	end
end

local makeKey = function(ID, key)
	return writeFile(fs.combine(config.keyPath, ID), key)
end

local getKey = function(ID)
	return readFile(fs.combine(config.keyPath, ID))
end

-- get personal key file
local key = ""
if fs.exists(fs.combine(config.keyPath, tostring(yourID))) then
	key = readFile(fs.combine(config.keyPath, tostring(yourID)))
else
	for i = 1, 64 do
		key = key .. string.char(math.random(11, 255))
	end
	writeFile(fs.combine(config.keyPath, tostring(yourID)), key)
end

local apiData = {
	["aes"] = {
		path = "aes.lua",
		url = "http://pastebin.com/raw/9E5UHiqv",
	}
}

for name, data in pairs(apiData) do
	data.path = fs.combine(config.apiPath, data.path)
	if not fs.exists(data.path) then
		local net = http.get(data.url)
		if net then
			local file = fs.open(data.path, "w")
			file.write(net.readAll())
			file.close()
			net.close()
		else
			error("Could not download " .. name)
		end
	end
	_ENV[name] = dofile(data.path)
end


local function interpretArgs(tInput, tArgs)
	local output = {}
	local errors = {}
	local usedEntries = {}
	for aName, aType in pairs(tArgs) do
		output[aName] = false
		for i = 1, #tInput do
			if not usedEntries[i] then
				if tInput[i] == aName and not output[aName] then
					if aType then
						usedEntries[i] = true
						if type(tInput[i+1]) == aType or type(tonumber(tInput[i+1])) == aType then
							usedEntries[i+1] = true
							if aType == "number" then
								output[aName] = tonumber(tInput[i+1])
							else
								output[aName] = tInput[i+1]
							end
						else
							output[aName] = nil
							errors[1] = errors[1] and (errors[1] + 1) or 1
							errors[aName] = "expected " .. aType .. ", got " .. type(tInput[i+1])
						end
					else
						usedEntries[i] = true
						output[aName] = true
					end
				end
			end
		end
	end
	for i = 1, #tInput do
		if not usedEntries[i] then
			output[#output+1] = tInput[i]
		end
	end
	return output, errors
end

local argList = {
	["--server"] = false
}

local argData, argErrors = interpretArgs({...}, argList)
local isServer = argData["--server"]

local modem
local getModem = function(doNotPickWireless)
	local output, periphList
	for try = 1, 40 do
		periphList = peripheral.getNames()
		for i = 1, #periphList do
			if peripheral.getType(periphList[i]) == "modem" then
				output = peripheral.wrap(periphList[i])
				if not (doNotPickWireless and output.isWireless()) then
					output.open(config.channel)
					return output
				end
			end
		end
		sleep(0.15)
	end
	error("No modems were found after 40 tries. That's as many as four tens. And that's terrible.")
end

-- allowed IDs
local userIDs = {}

-- all data recorded
local DATA = {}

local transmit = function(msg)
	modem = getModem(onlyUseWiredModems)
	modem.transmit(config.channel, config.channel, {
		msg = msg,
		encrypted = false
	})
end

local encTransmit = function(msg, recipient)
	modem = getModem(onlyUseWiredModems)
	modem.transmit(config.channel, config.channel, {
		msg = aes.encrypt(key, msg),
		encrypted = true
	})
end

local handle = {
	client = {},
	server = {}
}

handle.client.findServer = function(recipient)
	local msgID = math.random(1, 2^30)
	transmit({
		id = yourID,
		command = "find_server",
		msgID = msgID,
	})
	local evt, msg
	local timerID = os.startTimer(2)
	while true do
		evt = {os.pullEvent()}
		if evt[1] == "modem_message" then
			if evt[5].encrypted then
				msg = evt[5].msg
			else
				msg = evt[5].msg
			end
		elseif evt[1] == "timer" and evt[2] == timerID then
			return false
		end
	end
end

handle.server.registerID = function(id)
	local path = fs.combine(config.mailPath, id)
	if not fs.exists(path) then
		fs.makeDir(path)
	end
end

-- records a full email to file
handle.server.recordMail = function(sender, recipient, message, subject, attachment)
	-- sender: The person who sends the message
	-- recipient: The message will be put in their folder
	-- subject: The header of a message
	-- message: the fuck you think it is
	-- attachment: Contents of a SINGLE file that will be attached to an email
	local path = fs.combine(config.mailPath, recipient)
	handle.server.registerID(recipient)
	local time = os.epoch("utc")
	local file = fs.open(fs.combine(path, time), "w")
	file.write(textutils.serialize({
		sender = id,
		time = time,
		recipient = recipient,
		read = false,
		subject = subject,
		message = message,
		attachment = attachment
	}))
end

-- returns every email in an inbox
handle.server.getMail = function(id)
	local output, list = {}, {}
	local mails = fs.list(fs.combine(config.mailPath, id))
	local file
	for k,v in pairs(mails) do
		list[v] = k
	end
	for k,v in pairs(list) do
		file = fs.open(fs.combine(config.mailPath, "/" .. id .. "/" .. k), "r")
		if file then
			output[#output + 1] = textutils.unserialize(file.readAll())
			file.close()
		end
	end
	return output
end

-- receives messages and sends the appropriate response
handle.server.networking = function()
	local evt, _msg, msg
	while true do
		evt = {os.pullEvent()}
		if evt[1] == "modem_message" then
			_msg = evt[5]
			if type(_msg) == "table" then
				if _msg.msg and type(_msg.encrypted) == "boolean" then
					if _msg.encrypted then
						msg = _msg.msg
					else
						msg = aes.decrypt(key, _msg.msg)
					end
					if msg then
						
						-- add more commands
						if msg.command == "find_server" then
							-- send the server ID
						end
						
					end
				end
			end
		end
	end
end

if isServer then
	handle.server.networking()
else
	-- make a whole client interface and shit
end
