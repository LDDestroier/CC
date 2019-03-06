local mainPath = ".sysmail"
local yourID = os.getComputerID()
local onlyUseWiredModems = false
local defaultTimer = 3

local config = {
	channel = 1024,
	keyPath = fs.combine(mainPath, "keys"),
	mailPath = fs.combine(mainPath, "mail"),
	apiPath = fs.combine(mainPath, "api"),
	nameFile = fs.combine(mainPath, "names"),
	attachmentPath = "attachments"
}

local getTableLength = function(tbl)
	local output = 0
	for k,v in pairs(tbl) do
		output = output + 1
	end
	return output
end

-- used for picking attachments

local lddfm = {scroll = 0, ypaths = {}}

lddfm.scr_x, lddfm.scr_y = term.getSize()

lddfm.setPalate = function(_p)
	if type(_p) ~= "table" then _p = {} end
	lddfm.p = { --the DEFAULT color palate
		bg =        _p.bg or colors.gray,			-- whole background color
		d_txt =     _p.d_txt or colors.yellow,		-- directory text color
		d_bg =      _p.d_bg or colors.gray,			-- directory bg color
		f_txt =     _p.f_txt or colors.white,		-- file text color
		f_bg =      _p.f_bg or colors.gray,			-- file bg color
		p_txt =     _p.p_txt or colors.black,		-- path text color
		p_bg =      _p.p_bg or colors.lightGray,	-- path bg color
		close_txt = _p.close_txt or colors.gray,	-- close button text color
		close_bg =  _p.close_bg or colors.lightGray,-- close button bg color
		scr =       _p.scr or colors.lightGray,		-- scrollbar color
		scrbar =    _p.scrbar or colors.gray,		-- scroll tab color
	}
end

lddfm.setPalate()

lddfm.foldersOnTop = function(floop,path)
	local output = {}
	for a = 1, #floop do
		if fs.isDir(fs.combine(path,floop[a])) then
			table.insert(output,1,floop[a])
		else
			table.insert(output,floop[a])
		end
	end
	return output
end

lddfm.filterFileFolders = function(list,path,_noFiles,_noFolders,_noCD,_doHidden)
	local output = {}
	for a = 1, #list do
		local entry = fs.combine(path,list[a])
		if fs.isDir(entry) then
			if entry == ".." then
				if not (_noCD or _noFolders) then table.insert(output,list[a]) end
			else
				if not ((not _doHidden) and list[a]:sub(1,1) == ".") then
					if not _noFolders then table.insert(output,list[a]) end
				end
			end
		else
			if not ((not _doHidden) and list[a]:sub(1,1) == ".") then
				if not _noFiles then table.insert(output,list[a]) end
			end
		end
	end
	return output
end

lddfm.isColor = function(col)
	for k,v in pairs(colors) do
		if v == col then
			return true, k
		end
	end
	return false
end

lddfm.clearLine = function(x1,x2,_y,_bg,_char)
	local cbg, bg = term.getBackgroundColor()
	local x,y = term.getCursorPos()
	local sx,sy = term.getSize()
	if type(_char) == "string" then char = _char else char = " " end
	if type(_bg) == "number" then
		if lddfm.isColor(_bg) then bg = _bg
		else bg = cbg end
	else bg = cbg end
	term.setCursorPos(x1 or 1, _y or y)
	term.setBackgroundColor(bg)
	if x2 then --it pains me to add an if statement to something as simple as this
		term.write((char or " "):rep(x2-x1))
	else
		term.write((char or " "):rep(sx-(x1 or 0)))
	end
	term.setBackgroundColor(cbg)
	term.setCursorPos(x,y)
end

lddfm.render = function(_x1,_y1,_x2,_y2,_rlist,_path,_rscroll,_canClose,_scrbarY)
	local px,py = term.getCursorPos()
	local x1, x2, y1, y2 = _x1 or 1, _x2 or lddfm.scr_x, _y1 or 1, _y2 or lddfm.scr_y
	local rlist = _rlist or {"Invalid directory."}
	local path = _path or "And that's terrible."
	ypaths = {}
	local rscroll = _rscroll or 0
	for a = y1, y2 do
		lddfm.clearLine(x1,x2,a,lddfm.p.bg)
	end
	term.setCursorPos(x1,y1)
	term.setTextColor(lddfm.p.p_txt)
	lddfm.clearLine(x1,x2+1,y1,lddfm.p.p_bg)
	term.setBackgroundColor(lddfm.p.p_bg)
	term.write(("/"..path):sub(1,x2-x1))
	for a = 1,(y2-y1) do
		if rlist[a+rscroll] then
			term.setCursorPos(x1,a+(y1))
			if fs.isDir(fs.combine(path,rlist[a+rscroll])) then
				lddfm.clearLine(x1,x2,a+(y1),lddfm.p.d_bg)
				term.setTextColor(lddfm.p.d_txt)
				term.setBackgroundColor(lddfm.p.d_bg)
			else
				lddfm.clearLine(x1,x2,a+(y1),lddfm.p.f_bg)
				term.setTextColor(lddfm.p.f_txt)
				term.setBackgroundColor(lddfm.p.f_bg)
			end
			term.write(rlist[a+rscroll]:sub(1,x2-x1))
			ypaths[a+(y1)] = rlist[a+rscroll]
		else
			lddfm.clearLine(x1,x2,a+(y1),lddfm.p.bg)
		end
	end
	local scrbarY = _scrbarY or math.ceil( (y1+1)+( (_rscroll/(#_rlist-(y2-(y1+1))))*(y2-(y1+1)) ) )
	for a = y1+1, y2 do
		term.setCursorPos(x2,a)
		if a == scrbarY then
			term.setBackgroundColor(lddfm.p.scrbar)
		else
			term.setBackgroundColor(lddfm.p.scr)
		end
		term.write(" ")
	end
	if _canClose then
		term.setCursorPos(x2-4,y1)
		term.setTextColor(lddfm.p.close_txt)
		term.setBackgroundColor(lddfm.p.close_bg)
		term.write("close")
	end
	term.setCursorPos(px,py)
	return scrbarY
end

lddfm.coolOutro = function(x1,y1,x2,y2,_bg,_txt,char)
	local cx, cy = term.getCursorPos()
	local bg, txt = term.getBackgroundColor(), term.getTextColor()
	term.setTextColor(_txt or colors.white)
	term.setBackgroundColor(_bg or colors.black)
	local _uwah = 0
	for y = y1, y2 do
		for x = x1, x2 do
			_uwah = _uwah + 1
			term.setCursorPos(x,y)
			term.write(char or " ")
			if _uwah >= math.ceil((x2-x1)*1.63) then sleep(0) _uwah = 0 end
		end
	end
	term.setTextColor(txt)
	term.setBackgroundColor(bg)
	term.setCursorPos(cx,cy)
end

lddfm.scrollMenu = function(amount,list,y1,y2)
	if #list >= y2-y1 then
		lddfm.scroll = lddfm.scroll + amount
		if lddfm.scroll < 0 then
			lddfm.scroll = 0
		end
		if lddfm.scroll > #list-(y2-y1) then
			lddfm.scroll = #list-(y2-y1)
		end
	end
end

lddfm.makeMenu = function(_x1,_y1,_x2,_y2,_path,_noFiles,_noFolders,_noCD,_noSelectFolders,_doHidden,_p,_canClose)
	if _noFiles and _noFolders then
		return false, "C'mon, man..."
	end
	if _x1 == true then
		return false, "arguments: x1, y1, x2, y2, path, noFiles, noFolders, noCD, noSelectFolders, doHidden, palate, canClose" -- a little help
	end
	lddfm.setPalate(_p)
	local path, list = _path or ""
	lddfm.scroll = 0
	local _pbg, _ptxt = term.getBackgroundColor(), term.getTextColor()
	local x1, x2, y1, y2 = _x1 or 1, _x2 or lddfm.scr_x, _y1 or 1, _y2 or lddfm.scr_y
	local keysDown = {}
	local _barrY
	while true do
		list = lddfm.foldersOnTop(lddfm.filterFileFolders(fs.list(path),path,_noFiles,_noFolders,_noCD,_doHidden),path)
		if (fs.getDir(path) ~= "..") and not (_noCD or _noFolders) then
			table.insert(list,1,"..")
		end
		_res, _barrY = pcall( function() return lddfm.render(x1,y1,x2,y2,list,path,lddfm.scroll,_canClose) end)
		if not _res then
			error(_barrY)
		end
		local evt = {os.pullEvent()}
		if evt[1] == "mouse_scroll" then
			lddfm.scrollMenu(evt[2],list,y1,y2)
		elseif evt[1] == "mouse_click" then
			local butt,mx,my = evt[2],evt[3],evt[4]
			if (butt == 1 and my == y1 and mx <= x2 and mx >= x2-4) and _canClose then
				--lddfm.coolOutro(x1,y1,x2,y2)
				term.setTextColor(_ptxt) term.setBackgroundColor(_pbg)
				return false
			elseif ypaths[my] and (mx >= x1 and mx < x2) then --x2 is reserved for the scrollbar, breh
				if fs.isDir(fs.combine(path,ypaths[my])) then
					if _noCD or butt == 3 then
						if not _noSelectFolders or _noFolders then
							--lddfm.coolOutro(x1,y1,x2,y2)
							term.setTextColor(_ptxt) term.setBackgroundColor(_pbg)
							return fs.combine(path,ypaths[my])
						end
					else
						path = fs.combine(path,ypaths[my])
						lddfm.scroll = 0
					end
				else
					term.setTextColor(_ptxt) term.setBackgroundColor(_pbg)
					return fs.combine(path,ypaths[my])
				end
			end
		elseif evt[1] == "key" then
			keysDown[evt[2]] = true
			if evt[2] == keys.enter and not (_noFolders or _noCD or _noSelectFolders) then --the logic for _noCD being you'd normally need to go back a directory to select the current directory.
				--lddfm.coolOutro(x1,y1,x2,y2)
				term.setTextColor(_ptxt) term.setBackgroundColor(_pbg)
				return path
			end
			if evt[2] == keys.up then
				lddfm.scrollMenu(-1,list,y1,y2)
			elseif evt[2] == keys.down then
				lddfm.scrollMenu(1,list,y1,y2)
			end
			if evt[2] == keys.pageUp then
				lddfm.scrollMenu(y1-y2,list,y1,y2)
			elseif evt[2] == keys.pageDown then
				lddfm.scrollMenu(y2-y1,list,y1,y2)
			end
			if evt[2] == keys.home then
				lddfm.scroll = 0
			elseif evt[2] == keys["end"] then
				if #list > (y2-y1) then
					lddfm.scroll = #list-(y2-y1)
				end
			end
			if evt[2] == keys.h then
				if keysDown[keys.leftCtrl] or keysDown[keys.rightCtrl] then
					_doHidden = not _doHidden
				end
			elseif _canClose and (evt[2] == keys.x or evt[2] == keys.q or evt[2] == keys.leftCtrl) then
				--lddfm.coolOutro(x1,y1,x2,y2)
				term.setTextColor(_ptxt) term.setBackgroundColor(_pbg)
				return false
			end
		elseif evt[1] == "key_up" then
			keysDown[evt[2]] = false
		end
	end
end

local alphasort = function(tbl)
	table.sort(tbl, function(a,b)
		if type(a) == "table" then
			return string.lower(a.time) > string.lower(b.time)
		else
			return string.lower(a) > string.lower(b)
		end
	end)
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
	local reply, isEncrypted = receive(msgID, "find_server_respond", srv, defaultTimer)
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
	local reply, isEncrypted = receive(msgID, "register_respond", yourID, defaultTimer)
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
	local reply, isEncrypted = receive(msgID, "get_names_respond", yourID, defaultTimer)
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
	local reply, isEncrypted = receive(msgID, "send_mail_respond", yourID, defaultTimer)
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
	local reply, isEncrypted = receive(msgID, "get_mail_respond", yourID, defaultTimer)
	if (isEncrypted and type(reply) == "table") then
		if reply.mail then
			return alphasort(reply.mail)
		end
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
	local reply, isEncrypted = receive(msgID, "delete_mail_respond", yourID, defaultTimer)
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
	local mails = alphasort( fs.list(fs.combine(config.mailPath, tostring(id))) )
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

	if verbose then
		term.clear()
		term.setCursorPos(1,1)
		print("Make sure client keys are copied to key folder!")
	end

	say("SysMail server started.")

	while true do

		msg, isEncrypted, msgID = receive(nil, nil, nil, 5)

		if not msg then
			keyList = getAllKeys()
		else
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
		term.setCursorPos(scr_x / 2 - (#text - 1) / 2, y or cy)
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
	local dialogueBox = function(msg, timeout)
		local height = 7
		local baseY = scr_y / 2 - height / 2
		term.setBackgroundColor(colors.gray)
		for y = 1, height do
			term.setCursorPos(1, (scr_y / 2) - (baseY / 2) + (y - 1))
			term.clearLine()
		end
		cwrite(("="):rep(scr_x), baseY)
		cwrite(msg, baseY + height / 2)
		cwrite(("="):rep(scr_x), baseY + height - 1)
		local evt
		local tID = os.startTimer(timeout or 2)
		repeat
			evt = {os.pullEvent()}
		until (evt[1] == "key") or (evt[1] == "timer" and evt[2] == tID)
		term.setBackgroundColor(colors.black)
	end
	srv = srv or tonumber( client.findServer(argData[1]) )
	if not srv then
		error("No server was found!")
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
				break
			else
				term.clear()
				cwrite("Bad name! Enter your name:", 3)
			end
		end
	end
	client.register(srv, names[yourID])

	for k,v in pairs(client.getNames(srv) or {}) do
		names[k] = v
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

	local writeHeader = function(left, right, y)
		if y then
			term.setCursorPos(1, y)
		end
		term.setTextColor(colors.lightGray)
		term.write(left)
		term.setTextColor(colors.white)
		term.write(" " .. right)
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
					term.write(inbox[i].subject:sub(1, 18))

					term.setCursorPos(30, y)
					term.setTextColor(colors.gray)
					term.write(inbox[i].message:sub(1, scr_x - 30))
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
			term.setCursorPos(scr_x - #names[yourID], scr_y)
			term.setTextColor(colors.lightGray)
			term.write(names[yourID])
		end

		-- logic(k)
		local barCommands = {
			[keys.q] = {1, scr_y, 4},
			[keys.n] = {6, scr_y, 3},
			[keys.r] = {10, scr_y, 7},
		}
		local evt, key, mx, my
		local adjY	-- mouse Y adjusted for scroll
		while true do
			render(scroll)
			inbox = alphasort(inbox)
			evt, key, mx, my = os.pullEvent()
			if evt == "mouse_click" then
				adjY = my + scroll
				if inbox[adjY] then
					return "view_mail", {adjY}
				else
					for key, data in pairs(barCommands) do
						if my == data[2] and mx >= data[1] and mx <= data[1] + data[3] - 1 then
							os.queueEvent("key", key)
							break
						end
					end
				end
			elseif evt == "mouse_scroll" then
				scroll = math.max(0, scroll + key)
			elseif evt == "key" then
				if key == keys.n then
					return "new_mail"
				elseif key == keys.r then
					return "refresh"
				elseif key == keys.q then
					return "exit"
				end
			end
		end
	end

	local niftyRead = function(prebuffer, startX, startY, startCursorMX, startCursorMY, allowEnter, maxLines, maxLength, history)
		local cx, cy = term.getCursorPos()
		local histPos = 0
		startX, startY = startX or cx, startY or cy
		local buffer = {{}}
		local unassemble = function(pBuffer)
			local output = {{""}}
			local y = 1
			local x = 1
			for i = 1, #pBuffer do
				if pBuffer:sub(i,i) == "\n" then
					x = 1
					y = y + 1
					output[y] = {""}
				else
					output[y][x] = pBuffer:sub(i,i)
					x = x + 1
				end
			end
			return output
		end
		if prebuffer then
			buffer = unassemble(prebuffer)
		end
		local curY = startCursorMY and math.max(1, math.min(startCursorMY - (startY - 1), #buffer)) or 1
		local curX = startCursorMX and math.max(1, math.min(startCursorMX - (startX - 1), #buffer[curY])) or 1
		local biggestHeight = math.max(1, #buffer)
		local getLength = function()
			local output = 0
			for ln = 1, #buffer do
				output = output + #buffer[ln]
				if ln ~= #buffer then	-- account for newline chars
					output = output + 1
				end
			end
			return output
		end
		local render = function()
			for y = startY, startY + (biggestHeight - 1) do
				term.setCursorPos(startX, y)
				term.write((" "):rep(maxLength))
			end
			term.setCursorPos(startX, startY)
			local words
			local x = startX
			local y = startY
			for ln = 1, #buffer do
				words = explode(" ", table.concat(buffer[ln]), nil, true)
				for i = 1, #words do
					if x + #words[i] > scr_x and y < maxLines then
						x = startX
						y = y + 1
					end
					term.setCursorPos(x, y)
					term.write(words[i])
					x = x + #words[i]
				end
				term.write(" ")
				if ln ~= #buffer then
					y = y + 1
					x = startX
				end
			end
			term.setCursorPos(curX + startX - 1, curY + startY - 1)
			biggestHeight = math.max(#buffer, biggestHeight)
		end

		local assemble = function(buffer)
			local output = ""
			for ln = 1, #buffer do
				output = output .. table.concat(buffer[ln])
				if ln ~= #buffer then
					output = output .. "\n"
				end
			end
			return output
		end

		if history then
			history[0] = assemble(buffer)
		end

		local evt, key, mx, my
		local keysDown = {}
		term.setCursorBlink(true)
		while true do
			render()
			evt, key, mx, my = os.pullEvent()
			if evt == "char" then
				if getLength() < maxLength then
					table.insert(buffer[curY], curX, key)
					curX = curX + 1
					if histPos == 0 and history then
						history[histPos] = assemble(buffer)
					end
				end
			elseif evt == "key_up" then
				keysDown[key] = nil
			elseif evt == "mouse_click" then
				if key == 1 then
					if my - (startY - 1) > maxLines or my < startY then
						term.setCursorBlink(false)
						return assemble(buffer), "mouse_click", mx, my
					else
						curY = math.max(1, math.min(my - (startY - 1), #buffer))
						curX = math.max(1, math.min(mx - (startX - 1), #buffer[curY]))
					end
				end
			elseif evt == "key" then
				keysDown[key] = true
				if key == keys.left then
					if curX == 1 then
						if curY > 1 then
							curY = curY - 1
							curX = #buffer[curY] + 1
						end
					elseif curX > 1 then
						curX = curX - 1
					end
				elseif key == keys.right then
					if curX == #buffer[curY] + 1 then
						if curY < #buffer then
							curY = curY + 1
							curX = 1
						end
					elseif curX < #buffer[curY] then
						curX = curX + 1
					end
				elseif key == keys.up then
					if history then
						if histPos < #history then
							histPos = histPos + 1
							buffer = unassemble(history[histPos])
							curY = #buffer
							curX = #buffer[curY] + 1
						end
					else
						if curY > 1 then
							curY = curY - 1
							curX = math.min(curX, #buffer[curY] + 1)
						else
							curX = 1
						end
					end
				elseif key == keys.down then
					if history then
						if histPos > 0 then
							histPos = histPos - 1
							buffer = unassemble(history[histPos])
							curY = #buffer
							curX = #buffer[curY] + 1
						end
					else
						if curY < #buffer then
							curY = curY + 1
							curX = math.min(curX, #buffer[curY] + 1)
						else
							curX = #buffer[curY] + 1
						end
					end
				elseif key == keys.enter then
					if allowEnter and not (keysDown[keys.leftAlt] or keysDown[keys.rightAlt]) and #buffer < maxLines then
						curY = curY + 1
						table.insert(buffer, curY, {})
						for i = curX, #buffer[curY - 1] do
							buffer[curY][#buffer[curY] + 1] = buffer[curY - 1][i]
							buffer[curY - 1][i] = nil
						end
						curX = 1
					else
						term.setCursorBlink(false)
						return assemble(buffer), "key", keys.enter
					end
				elseif key == keys.tab or (key == keys.q and (keysDown[keys.leftAlt] or keysDown[keys.rightAlt])) then
					term.setCursorBlink(false)
					return assemble(buffer), "key", key
				elseif key == keys.backspace then
					if curX > 1 then
						table.remove(buffer[curY], curX - 1)
						curX = curX - 1
					elseif curY > 1 then
						curX = #buffer[curY - 1] + 1
						for i = 1, #buffer[curY] do
							buffer[curY - 1][#buffer[curY - 1] + 1] = buffer[curY][i]
						end
						table.remove(buffer, curY)
						curY = curY - 1
					end
				elseif key == keys.delete then
					if buffer[curY][curX] then
						table.remove(buffer[curY], curX)
					end
				end
			end
		end
	end

	local area_new_mail = function(recipient, subject, message)
		recipient = recipient or ""
		subject = subject or ""
		message = message or ""
		local attachments = {}
		sleep(0.05)
		local mode = "recipient"
		render = function()
			term.setTextColor(colors.white)
			term.setBackgroundColor(colors.black)
			term.clear()
			writeHeader("To:", recipient, 1)
			writeHeader("Subject:", subject, 2)
			writeHeader("Attachments:", "", 3)
			for name, contents in pairs(attachments) do
				term.write(name .. " ")
			end
			term.setCursorPos(1, 4)
			term.setBackgroundColor(colors.gray)
			term.setTextColor(colors.lightGray)
			term.clearLine()
			cwrite("(Alt+Enter = SEND, Alt+Q = QUIT)")
			term.setTextColor(colors.white)
			term.setBackgroundColor(colors.black)
			if mode ~= "message" then
				term.setCursorPos(1, 5)
				write(message)
			end
		end
		local mx, my, evt = 1, 1
		local _mx, _my, userList
		while true do
			render()
			if mode == "message" then
				message, evt, _mx, _my = niftyRead(message, 1, 5, mx, my, true, 16, 512)
			elseif mode == "subject" then
				subject, evt, _mx, _my = niftyRead(subject, 10, 2, mx, 1, false, 1, 64)
			elseif mode == "recipient" then
				names = client.getNames(srv) or names
				userList = {}
				for k,v in pairs(names) do
					userList[#userList + 1] = v
				end
				recipient, evt, _mx, _my = niftyRead(recipient, 5, 1, mx, 1, false, 1, 24, userList)
			end
			if evt == "mouse_click" then
				mx, my = _mx, _my
				if my == 1 then
					mode = "recipient"
				elseif my == 2 then
					mode = "subject"
				elseif my == 3 then
					local newAttachment = lddfm.makeMenu(1, 4, scr_x, scr_y, "", false, false, false, true, false, nil, true)
					if newAttachment then
						local name = fs.getName(newAttachment)
						if attachments[name] then
							attachments[name] = nil
						else
							attachments[name] = readFile(newAttachment)
						end
					end
				elseif my >= 5 then
					mode = "message"
				end
			elseif evt == "key" then
				if _mx == keys.enter or _mx == keys.tab then
					if mode == "recipient" then
						mode = "subject"
					elseif mode == "subject" then
						mode = "message"
					elseif mode == "message" and _mx == keys.enter then
						local recip
						names = client.getNames(srv) or names
						if tonumber(recipient) then
							recip = tonumber(recipient)
							if not names[recip] then
								recip = nil
							end
						else
							recip = getNameID(recipient)
						end
						if recip then
							client.sendMail(srv, recip, subject, message, attachments)
							dialogueBox("Message sent!")
							refresh()
							return
						else
							dialogueBox("There's no such recipient.")
						end
					end
				elseif _mx == keys.q then
					return
				end
			end
		end
		niftyRead(nil, 1, 1, nil, true)
	end

	local area_view_mail = function(mailEntry)
		local scroll = 0
		local mail = inbox[mailEntry]
		local render = function(scroll)
			term.setBackgroundColor(colors.black)
			term.setTextColor(colors.lightGray)
			term.clear()
			local y
			writeHeader("From:", names[mail.sender], 1)
			writeHeader("Subject:", mail.subject, 2)
			if getTableLength(mail.attachments) > 0 then
				writeHeader("Attachments:","",3)
				for name, contents in pairs(mail.attachments) do
					term.write(name .. " ")
				end
				y = 5
			else
				y = 4
			end
			term.setTextColor(colors.gray)
			term.setCursorPos(1, y - 1)
			term.write(("="):rep(scr_x))
			term.setTextColor(colors.white)
			local words = {}
			local lines = explode("\n", mail.message, nil, true)
			for i = 1, #lines do
				local inWords = explode(" ", lines[i], nil, true)
				for ii = 1, #inWords do
					words[#words+1] = inWords[ii]
				end
				if i ~= #lines then
					words[#words+1] = "\n"
				end
			end
			local buffer = {""}
			for i = 1, #words do
				if words[i] == "\n" then
					buffer[#buffer+1] = ""
				elseif #buffer[#buffer] + #words[i] > scr_x then
					buffer[#buffer+1] = words[i]
				else
					buffer[#buffer] = buffer[#buffer] .. words[i]
				end
			end
			for i = scroll + 1, scroll + scr_y - y do
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
			if getTableLength(mail.attachments) > 0 then
				keyWrite("DL.Attachments ", 4)
			end
			keyWrite("Delete ", 1)
		end

		local downloadAttachments = function()
			local path = fs.combine(config.attachmentPath, names[mail.sender])
			for name, contents in pairs(mail.attachments) do
				writeFile(fs.combine(path, name), contents)
			end
			return path
		end

		local barCommands = {
			[keys.q] = {1, scr_y, 4},
			[keys.r] = {6, scr_y, 5},
		}
		if getTableLength(mail.attachments) > 0 then
			barCommands[keys.a] = {12, scr_y, 14}
			barCommands[keys.d] = {27, scr_y, 6}
		else
			barCommands[keys.d] = {12, scr_y, 6}
		end
		local evt, key, mx, my
		while true do
			render(scroll)
			evt, key, mx, my = os.pullEvent()
			if evt == "key" then
				if key == keys.r then
					area_new_mail(names[mail.sender], "Re: " .. mail.subject, "\n\n~~~\nAt UTC epoch " .. mail.time .. ", " .. names[mail.sender] .. " wrote:\n\n" .. mail.message)
				elseif key == keys.d then
					client.deleteMail(srv, mailEntry)
					refresh()
					return
				elseif key == keys.a then
					local path = downloadAttachments()
					dialogueBox("DL'd to '" .. path .. "/'")
				elseif key == keys.q then
					return "exit"
				end
			elseif evt == "mouse_click" then
				if my == 3 and getTableLength(mail.attachments) > 0 then
					local path = downloadAttachments()
					dialogueBox("DL'd to '" .. path .. "/'")
				else
					for key, data in pairs(barCommands) do
						if my == data[2] and mx >= data[1] and mx <= data[1] + data[3] - 1 then
							os.queueEvent("key", key)
							break
						end
					end
				end
			elseif evt == "mouse_scroll" then
				scroll = math.max(0, scroll + key)
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
		elseif res == "refresh" then
			refresh()
		elseif res == "view_mail" then
			area_view_mail(table.unpack(output or {}))
		elseif res == "new_mail" then
			area_new_mail(table.unpack(output or {}))
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
