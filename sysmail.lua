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

local alphasort = function(tbl)
	table.sort(tbl, function(a,b) return string.lower(a) < string.lower(b) end)
	return tbl
end

local readFile = function(path)
	if fs.exists(path) then
		local file = fs.open(path, "r")
		local contents = file.readAll()
		file.close()
		return contents
	else
		return nil
	end
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

local keyList, names = {}, {}

local makeKey = function(ID, key)
	return writeFile(fs.combine(config.keyPath, ID), key)
end

local getKey = function(ID)
	return readFile(fs.combine(config.keyPath, ID))
end

local readNames = function()
	return textutils.unserialize(readFile(config.nameFile) or "{}") or {}
end

local writeNames = function(_names)
	return writeFile(config.nameFile, textutils.serialize(_names or names))
end

-- keyList[id] = key
-- names[id] = name

-- get personal key file
keyList[yourID] = ""
if fs.exists(fs.combine(config.keyPath, tostring(yourID))) then
	keyList[yourID] = readFile(fs.combine(config.keyPath, tostring(yourID)))
else
	for i = 1, 64 do
		keyList[yourID] = keyList[yourID] .. string.char(math.random(11, 255))
	end
	writeFile(fs.combine(config.keyPath, tostring(yourID)), keyList[yourID])
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

names = readNames()
keyList = getAllKeys()

local apiData = {
	["aeslua"] = {
		path = "aeslua.lua",
		url = "https://gist.githubusercontent.com/SquidDev/86925e07cbabd70773e53d781bd8b2fe/raw/aeslua.lua",
		useLoadAPI = true,
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
	if data.useLoadAPI then
		local res = os.loadAPI(data.path)
		--error(res)
	else
		_ENV[name] = dofile(data.path)
	end
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
local serverName = argData[1] or "server"

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

local encTransmit = function(msg, msgID, recipient, encID)
	modem = getModem(onlyUseWiredModems)
	local key = keyList[encID or recipient]
	if not key then
		error("You do not possess the key of the recipient.")
	else
		modem.transmit(config.channel, config.channel, {
			msg = aeslua.encrypt(key, textutils.serialize(msg)),
			encrypted = true,
			msgID = msgID,
			recipient = recipient
		})
	end
end

local receive = function(msgID, specifyCommand, encID, timer)
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
					if true then
						if encID then
							msg = aeslua.decrypt(keyList[encID], evt[5].msg)
						else
							for id, key in pairs(keyList) do
								if msg then break end
								if id ~= encID then
									msg = aeslua.decrypt(key, evt[5].msg)
								end
							end
						end
						if msg then
							msg = textutils.unserialize(msg)
						end
					end
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

local getNameID = function(name)
	for k,v in pairs(names) do
		if v == name then
			return k
		end
	end
end

local client = {}	-- all client-specific commands
local server = {}	-- all server-specific commands

----                       ----
----    CLIENT COMMANDS    ----
----                       ----

-- if you want a super duper secure network, manually enter the server ID into this
client.findServer = function(srv)
	local msgID = math.random(1, 2^30)
	srv = type(srv) == "number" and srv or getNameID(srv)
	assert(tonumber(srv) or (not srv), "invalid server")
	transmit({
		id = yourID,
		command = "find_server"
	}, msgID)
	local reply, isEncrypted = receive(msgID, "find_server_respond", srv)
	if type(reply) == "table" then
		if reply.server then
			return reply.server
		end
	end
end

-- Registers your ID to a name.
client.register = function(srv, username)
	local msgID = math.random(1, 2^30)
	assert(srv, "register( server, username )")
	srv = type(srv) == "number" and srv or getNameID(srv)
	assert(srv, "invalid server")
	encTransmit({
		id = yourID,
		command = "register",
		name = username
	}, msgID, srv, yourID)
	local reply, isEncrypted = receive(msgID, "register_respond", yourID)
	if reply then
		return reply.result
	else
		return false
	end
end

-- Gets a list of all registered ID names
client.getNames = function(srv)
	local msgID = math.random(1, 2^30)
	assert(srv, "getNames( server )")
	srv = type(srv) == "number" and srv or getNameID(srv)
	assert(srv, "invalid server")
	encTransmit({
		id = yourID,
		command = "get_names"
	}, msgID, srv, yourID)
	local reply, isEncrypted = receive(msgID, "get_names_respond", yourID)
	if type(reply) == "table" then
		return reply.names
	else
		return nil
	end
end

-- Sends an email to a recipient ID.
client.sendMail = function(srv, recipient, subject, message, attachments)
	assert(srv, "sendMail( server, recipient, subject, message, attachments )")
	srv = type(srv) == "number" and srv or getNameID(srv)
	assert(srv, "invalid server")
	assert(type(subject) == "string", "invalid subject")
	assert(type(message) == "string", "invalid message")
	local msgID = math.random(1, 2^30)
	if type(recipient) == "string" then
		recipient = getNameID(recipient)
	end
	assert(recipient, "invalid recipient")
	encTransmit({
		command = "send_mail",
		id = yourID,
		recipient = recipient,
		subject = subject,
		message = message,
		attachments = attachments
	}, msgID, srv, yourID)
	local reply, isEncrypted = receive(msgID, "send_mail_respond", yourID)
	if (isEncrypted and type(reply) == "table") then
		return reply.result
	else
		return false
	end
end

client.getMail = function(srv)
	local msgID = math.random(1, 2^30)
	assert(srv, "getMail( server )")
	srv = type(srv) == "number" and srv or getNameID(srv)
	assert(srv, "invalid server")
	encTransmit({
		command = "get_mail",
		id = yourID,
	}, msgID, srv, yourID)
	local reply, isEncrypted = receive(msgID, "get_mail_respond", yourID)
	if (isEncrypted and type(reply) == "table") then
		return reply.mail
	else
		return nil
	end
end

client.deleteMail = function(srv, mail)
	local msgID = math.random(1, 2^30)
	assert(srv, "deleteMail( server, mailEntryNumber )")
	srv = type(srv) == "number" and srv or getNameID(srv)
	assert(srv, "invalid server")
	assert(type(mail) == "number", "invalid mail entry")
	encTransmit({
		command = "delete_mail",
		id = yourID,
		mail = mail,
	}, msgID, srv, yourID)
	local reply, isEncrypted = receive(msgID, "delete_mail_respond", yourID)
	if (isEncrypted and type(reply) == "table") then
		return reply.result
	else
		return false
	end
end

----                       ----
----    SERVER COMMANDS    ----
----                       ----

-- check whether or not a name is valid to be used
server.checkValidName = function(name)
	if type(name) == "string" then
		if #name >= 3 or #name <= 24 then
			return true
		end
	end
	return false
end

-- check whether or not an ID is registered
server.checkRegister = function(id)
	-- I make the code this stupid looking in case I add other stipulations
	if names[id] or getNameID(names[id]) then
		return true
	else
		return false
	end
end

server.registerID = function(id, name)
	local path = fs.combine(config.mailPath, tostring(id))
	if ((not server.checkRegister(name)) or getNameID(name) == id) then
		fs.makeDir(path)
		names[id] = name
		writeNames()
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
		sender = sender,
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

server.deleteMail = function(id, del)
	local mails = alphasort(fs.list(fs.combine(config.mailPath, tostring(id))))
	if mails[del] then
		fs.delete(fs.combine(config.mailPath, tostring(id) .. "/" .. mails[del]))
		return true
	else
		return false
	end
end

server.setName = function(newName)
	if server.checkValidName(newName) then
		names[yourID] = newName
	end
end

-- receives messages and sends the appropriate response
server.makeServer = function(verbose)
	local msg, isEncrypted, msgID

	local say = function(text, id)
		if verbose then
			return print(text .. (id and (" (" .. id .. ")") or ""))
		end
	end

	while true do
	names = names

		msg, isEncrypted, msgID = receive()

		if msg then
			if not isEncrypted then
				if msg.command == "find_server" then
					transmit({
						command = msg.command .. "_respond",
						server = yourID,
					}, msgID, msg.id, yourID)
					say("find_server")
				end
			elseif type(msg.id) == "number" and type(msg.command) == "string" then
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
							say("user " .. tostring(msg.id) .. " registered as " .. name)
						else
							reply = {
								command = msg.command .. "_respond",
								result = result,
							}
							say("user " .. tostring(msg.id) .. " failed to register as " .. tostring(msg.name) .. ": " .. name)
						end
						encTransmit(reply, msgID, msg.id, msg.id)
					end
				elseif not server.checkRegister(msg.id) then
					encTransmit({
						command = msg.command .. "_respond",
						result = false,
						errorMsg = "not registered"
					}, msgID, msg.id, msg.id)
					say("unregistered user attempt to use")
				else

					-- all the real nice stuff

					if msg.command == "find_server" then
						encTransmit({
							command = msg.command .. "_respond",
							server = yourID,
							result = true
						}, msgID, msg.id, msg.id)
						say("find_server (aes)")
					elseif msg.command == "get_names" then
						encTransmit({
							command = msg.command .. "_respond",
							result = true,
						}, msgID, msg.id, msg.id)
						say("get_names", msg.id)
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
							encTransmit(reply, msgID, msg.id, msg.id)
							say("send_mail", msg.id)
						end
					elseif msg.command == "get_mail" then
						local mail = server.getMail(msg.id)
						local reply = {
							command = msg.command .. "_respond",
							result = true,
							mail = mail,
						}
						encTransmit(reply, msgID, msg.id, msg.id)
						say("get_mail", msg.id)
					elseif msg.command == "delete_mail" then
						local result = false
						if type(msg.mail) == "number" then
							result = server.deleteMail(msg.id, msg.mail, yourID)
						end
						encTransmit({
							command = msg.command .. "_respond",
							result = result,
						}, msgID, msg.id, msg.id)
						say("delete_mail", msg.id)
					end

				end
			end
		end

	end
end

local clientInterface = function(srv)
	local scr_x, scr_y = term.getSize()
	local inbox = {}
	local refresh = function()
		inbox = client.getMail(srv)
	end
	local cwrite = function(text, y)
		local cx, cy = term.getCursorPos()
		term.setCursorPos(scr_x / 2 - #text / 2, y or cy)
		term.write(text)
	end
	local explode = function(div, str, replstr, includeDiv)
		if (div == '') then
			return false
		end
		local pos, arr = 0, {}
		for st, sp in function() return string.find(str, div, pos, false) end do
			table.insert(arr, string.sub(replstr or str, pos, st - 1 + (includeDiv and #div or 0)))
			pos = sp + 1
		end
		table.insert(arr, string.sub(replstr or str, pos))
		return arr
	end
	srv = srv or tonumber( client.findServer(argData[1]) )
	if not srv then
		error("No server was found!")
	end
	for k,v in pairs(client.getNames(srv) or {}) do
		names[k] = v
	end

	if not names[yourID] then
		term.setBackgroundColor(colors.black)
		term.setTextColor(colors.white)
		term.clear()
		local attempt
		cwrite("Enter your name:", 3)
		while true do
			term.setCursorPos(2, 5)
			term.write(":")
			attempt = read()
			if server.checkValidName(attempt) then
				names[yourID] = attempt
				writeNames()
				client.register(srv, attempt)
				break
			else
				term.clear()
				cwrite("Bad name! Enter your name:", 3)
			end
		end
	end

	refresh()

	local keyWrite = function(text, pos)
		local txcol = term.getTextColor()
		term.write(text:sub(1, pos - 1))
		term.setTextColor(colors.yellow)
		term.write(text:sub(pos, pos))
		term.setTextColor(txcol)
		term.write(text:sub(pos + 1))
	end

	local area_inbox = function()
		local scroll = 0
		local render = function(scroll)
			local y = 1
			term.setBackgroundColor(colors.black)
			term.clear()
			for i = 1 + scroll, scroll + scr_y - 1 do
				if inbox[i] then
					term.setCursorPos(1, y)
					term.setTextColor(colors.white)
					term.write(names[inbox[i].sender]:sub(1, 10))

					term.setCursorPos(11, y)
					term.setTextColor(colors.white)
					term.write(inbox[i].subject:sub(1, 12))

					term.setCursorPos(24, y)
					term.setTextColor(colors.gray)
					term.write(inbox[i].message:sub(1, scr_x - 23))
				end
				y = y + 1
			end
			term.setCursorPos(1, scr_y)
			term.setBackgroundColor(colors.gray)
			term.clearLine()
			term.setTextColor(colors.white)
			--term.write(names[yourID] .. ": ")
			keyWrite("Quit ", 1)
			keyWrite("New ", 1)
			keyWrite("Refresh ", 1)
		end

		-- logic(k)
		local evt, key, mx, my
		local adjY	-- mouse Y adjusted for scroll
		while true do
			render(scroll)
			evt, key, mx, my = os.pullEvent()
			if evt == "mouse_click" then
				adjY = my + scroll
				if inbox[adjY] then
					return "view_mail", inbox[adjY]
				end
			elseif evt == "mouse_scroll" then
				scroll = scroll + key
			elseif evt == "key" then
				if key == keys.q then
					return "exit"
				end
			end
		end
	end

	local area_view_mail = function(mail)
		local scroll = 0
		local writeHeader = function(left, right, y)
			if y then
				term.setCursorPos(1, y)
			end
			term.setTextColor(colors.lightGray)
			term.write(left)
			term.setTextColor(colors.white)
			term.write(" " .. right)
		end
		local render = function(scroll)
			term.setBackgroundColor(colors.black)
			term.setTextColor(colors.lightGray)
			term.clear()
			writeHeader("From", names[mail.sender], 1)
			writeHeader("Subject", mail.subject, 2)
			local words = explode(" ", mail.message, nil, true)
			local buffer = {""}
			for i = 1, #words do
				words[i] = words[i]:gsub("\n", (" "):rep(scr_x))
				if #buffer[#buffer] + #words[i] > scr_x then
					buffer[#buffer+1] = words[i]
				else
					buffer[#buffer] = buffer[#buffer] .. words[i]
				end
			end
			local y = 3
			for i = scroll + 1, scroll + scr_y - 3 do
				if buffer[i] then
					term.setCursorPos(1, y)
					term.write(buffer[i])
				end
				y = y + 1
			end
			term.setCursorPos(1, scr_y)
			term.setBackgroundColor(colors.gray)
			term.setTextColor(colors.white)
			term.clearLine()
			keyWrite("Quit ", 1)
			keyWrite("Reply ", 1)
			keyWrite("Delete ", 1)
		end

		local evt, key, mx, my
		while true do
			render(scroll)
			evt, key, mx, my = os.pullEvent()
			if evt == "key" then
				if key == keys.q then
					return "exit"
				end
			elseif evt == "mouse_scroll" then
				scroll = scroll + key
			end
		end
	end

	local res, output
	while true do
		res, output = area_inbox()
		if res == "exit" then
			term.setCursorPos(1, scr_y)
			term.setBackgroundColor(colors.black)
			term.clearLine()
			sleep(0.05)
			return
		elseif res == "view_mail" then
			area_view_mail(output)
		end
	end
end

if isServer then
	names[yourID] = names[yourID] or serverName
	writeNames()
	server.makeServer(true)
elseif shell then
	clientInterface()
end

return {client = client, server = server}
