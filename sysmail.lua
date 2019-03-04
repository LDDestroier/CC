local mainPath = ".sysmail"
local yourID = os.getComputerID()
local onlyUseWiredModems = false

local config = {
	channel = 1024,
	keyPath = fs.combine(mainPath, "keys"),
	mailPath = fs.combine(mainPath, "mail"),
	apiPath = fs.combine(mainPath, "api"),
	nameFile = fs.combine(mainPath, "names")
}

local keys = {}
local names = {}

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
keys[yourID] = ""
if fs.exists(fs.combine(config.keyPath, tostring(yourID))) then
	keys[yourID] = readFile(fs.combine(config.keyPath, tostring(yourID)))
else
	for i = 1, 64 do
		keys[yourID] = keys[yourID] .. string.char(math.random(11, 255))
	end
	writeFile(fs.combine(config.keyPath, tostring(yourID)), keys[yourID])
end

local getAllKeys = function()
	local list = fs.list(config.keyPath)
	local output = {}
	for i = 1, #list do
		if tonumber(list[i]) then
			output[tonumber(list[i])] = getKey(list[i])
		end
	end
	return output
end

keys = getAllKeys()

--print(textutils.serialize(keys))
--error()

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
local serverID = argData[1]

if ccemux and (not peripheral.find("modem")) then
	ccemux.attach("top", "wireless_modem")
end

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

local transmit = function(msg, msgID)
	modem = getModem(onlyUseWiredModems)
	modem.transmit(config.channel, config.channel, {
		msg = msg,
		encrypted = false,
		msgID = msgID
	})
end

local encTransmit = function(msg, msgID, recipient)
	modem = getModem(onlyUseWiredModems)
	if not keys[recipient] then
		error("the fuck, no keys[recipient]")
	elseif not msg then
		error("the fuck, no msg")
	else
		modem.transmit(config.channel, config.channel, {
			msg = aes.encrypt(keys[recipient], msg),
			encrypted = true,
			msgID = msgID,
			recipient = recipient
		})
	end
end

local receive = function(msgID, specifyCommand, timer)
	local evt, msg, tID
	if timer then
		tID = os.startTimer(timer)
	end
	modem = getModem()
	while true do
		evt = {os.pullEvent()}
		if evt[1] == "modem_message" then
			if type(evt[5]) == "table" then
				if evt[5].encrypted then
					msg = aes.decrypt(keys[yourID], evt[5].msg)
				else
					msg = evt[5].msg
				end
				if (not msgID) or (evt[5].msgID == msgID) then
					if (not specifyCommand) or (msg.command == specifyCommand) then
						return msg, evt[5].encrypted, evt[5].msgID
					end
				end
			end
		elseif evt[1] == "timer" and evt[2] == tID then
			return nil, nil, nil
		end
	end
end

local client = {}	-- all client-specific commands
local server = {}	-- all server-specific commands

----                       ----
----    CLIENT COMMANDS    ----
----                       ----

-- if you want a super duper secure network, manually enter the server ID into this
client.findServer = function(recipient)
	local msgID = math.random(1, 2^30)
	transmit({
		id = yourID,
		command = "find_server"
	}, msgID)
	local reply, isEncrypted = receive(msgID, "find_server_respond", 2)
	if type(reply) == "table" then
		if reply.server then
			return reply.server
		end
	end
end

client.register = function(srv, username)
	local msgID = math.random(1, 2^30)
	encTransmit({
		id = yourID,
		name = username
	}, msgID, srv)
end

client.sendMail = function(srv, recipient, subject, message, attachments)
	local msgID = math.random(1, 2^30)
	encTransmit({
		command = "send_mail",
		id = yourID,
		recipient = recipient,
		subject = subject,
		message = message,
		attachments = attachments
	}, msgID, srv)
	local reply, isEncrypted = receive(msgID, "send_mail_respond", 2)
	return (reply ~= nil and isEncrypted ~= nil)
end

client.getMail = function(srv)
	local msgID = math.random(1, 2^30)
	encTransmit({
		command = "get_mail",
		id = yourID,
	}, msgID, srv)
	local reply, isEncrypted = receive(msgID, "get_mail_respond", 2)
	return (isEncrypted and type(reply) == "table") and reply
end

----                       ----
----    SERVER COMMANDS    ----
----                       ----

server.checkValidName = function(name)
	if type(name) ~= "string" then
		return false
	else
		return #name >= 3 or #name <= 64
	end
end

server.checkRegister = function(id)
	-- I make the code this stupid looking in case I add other stipulations
	if names[tostring(id)] then
		return true
	else
		return false
	end
end

server.registerID = function(id, name)
	local path = fs.combine(config.mailPath, id)
	if not server.checkRegister(id) then
		fs.makeDir(path)
		names[id] = tostring(name)
		return true, names[id]
	else
		return false, "name already exists"
	end
end

-- records a full email to file
server.recordMail = function(sender, _recipient, subject, message, attachments)
	local time = os.epoch("utc")
	local recipient

	if _recipient == "*" then
		recipient = fs.list(config.mailPath)
	elseif type(_recipient) ~= "table" then
		recipient = {tostring(_recipient)}
	end

	local msg = textutils.serialize({
		sender = id,
		time = time,
		read = false,
		subject = subject,
		message = message,
		attachments = attachments
	})

	local requiredSpace = #msg + 2
	if fs.getFreeSpace(config.mailPath) < requiredSpace then
		return false, "Cannot write mail, not enough space!"
	end

	local path, file
	for i = 1, #recipient do
		server.registerID(recipient[i])
		path = fs.combine(config.mailPath, recipient[i])
		file = fs.open(fs.combine(path, tostring(time)), "w")
		file.write(msg)
		file.close()
	end
	return true
end

-- returns every email in an ID's inbox
server.getMail = function(id)
	local output, list = {}, {}
	local mails = fs.list(fs.combine(config.mailPath, tostring(id)))
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
server.networking = function(verbose)
	local msg, isEncrypted, msgID

	local say = function(text, id)
		if verbose then
			return print(text .. (id and ("(" .. id .. ")") or ""))
		end
	end

	while true do

		msg, isEncrypted, msgID = receive()

		if not isEncrypted then
			if msg.command == "find_server" then
				transmit({
					command = msg.command .. "_respond",
					server = yourID,
				}, msgID, msg.id)
				say("find_server found")
			end
		elseif msg.id then
			if not server.checkRegister(msg.id) then
				encTransmit({
					command = msg.command .. "_respond",
					result = false,
					errorMsg = "not registered"
				}, msgID, msg.id)
				say("unregistered users can burn in hell")
			else

				if msg.command == "register" then
					if (
						type(msg.id) == "number" and
						type(msg.name) == "string"
					) then
						local reply
						local result, name = server.registerID(msg.id, msg.name)
						if result then
							reply = {
								command = msg.command .. "_respond",
								result = result,
								name = name,
							}
						else
							reply = {
								command = msg.command .. "_respond",
								result = result,
							}
						end
						encTransmit(reply, msgID, msg.id)
						say("user " .. tostring(msg.id) .. " registered as " .. name)
					end
				elseif msg.command == "find_server" then
					encTransmit({
						command = msg.command .. "_respond",
						server = yourID,
						result = true
					}, msgID, msg.id)
					say("find_server found (aes)")
				elseif msg.command == "send_mail" then
					if (
						msg.recipient and
						type(msg.subject) == "string" and
						type(msg.message) == "string"
					) then
						local reply = {
							command = msg.command .. "_respond",
							result = server.recordMail(msg.id, msg.recipient, msg.subject, msg.message, msg.attachments)
						}
						encTransmit(reply, msgID, msg.id)
						say("mail sent", msg.id)
					end
				elseif msg.command == "get_mail" then
					if (
						msg.id
					) then
						local mail = server.getMail(msg.id)
						local reply = {
							command = msg.command .. "_respond",
							result = true,
							mail = mail,
						}
						encTransmit(reply, msgID, msg.id)
					end
				end

			end
		end

	end
end

if isServer then
	server.networking(true)
else
	-- make a whole client interface and shit
	local srv = client.findServer()
	print(srv)
	client.register(srv, "buttman")
end
--[[
server.recordMail(1, 1, "Testing the sysmail.", "Forgive me, but I'm just testing SysMail as it's being made.")
local messages = server.getMail(1)
print(textutils.serialize(messages))
--]]

return {client = client, server = server}
