--[[
	NewVariable 2 (WIP) by LDDestroier
	Get with:
	 wget https://raw.githubusercontent.com/LDDestroier/CC/master/neovariable2.lua

	To Do:
	 + asymmetrical encryption (actually forget that, functions wouldn't work out)
	 + work on stability
	 + steal underpants
--]]

local tArg = {...}
local mode = tArg[1] -- "server" or "demo", otherwise works as API

if not peripheral.find("modem") then
	ccemux.attach("top", "wireless_modem")
end

local makeMT = function(indexFunc, newindexFunc)
	local output = {}
	local _output = output
	output = {}
	local mt = {
		__index = function(t, k)
			if indexFunc then
				return indexFunc(_output, k)
			else
				return _output[k]
			end
		end,
		__newindex = function(t, k, v)
			if newindexFunc then
				_output[k] = newindexFunc(_output, k, v)
			else
				_output[k] = v
			end
		end
	}
	setmetatable(output, mt)
	return output
end

-- information about the API
local nv = {
	dir = {						-- all DIRECTORIES will end with "/"
		main = "neovariable",	-- main directory where all neovariable stuff are
		privateID = "private",	-- private computer ID, protect with your life
		publicID = "public",	-- public computer ID, is shared all the time
		config = "config",		-- config options
		api = "api/"			-- where APIs are stored
	},
	envKey = 1,			-- determines which environment to use
	environment = {},	-- stores multiple environments
	privateID = nil,	-- every computer should have a secret, individual "ID"
	publicID = nil,		-- every computer should also have a public key
	channel = 1002,		-- modem channel
}

-- functions that are put in the api for use
local API = {}

for k,v in pairs(nv.dir) do
	if k ~= "main" then
		nv.dir[k] = fs.combine(nv.dir.main, v)
	end
	if (not fs.exists(v)) and v:sub(-1, -1) == "/" then
		fs.makeDir(nv.dir[k])
	end
end

local getID = function(path)
	if fs.exists(path) then
		local file = fs.open(path, "r")
		local contents = file.readAll()
		file.close()
		return contents
	else
		return false
	end
end

local makeNewID = function(path, _id)
	local file = fs.open(path, "w")
	if _id then
		file.write(_id)
	else
		local id = ""
		for i = 1, 256 do
			id = id .. string.char(math.random(11, 127))
		end
		file.write(id)
	end
	file.close()
	return id
end

nv.privateID, nv.publicID = getID(nv.dir.privateID), getID(nv.dir.publicID)
if not nv.privateID then
	nv.privateID = makeNewID(nv.dir.privateID)
end
if not nv.publicID then
	nv.publicID = makeNewID(nv.dir.publicID)
end

local getModem = function()
	local m = peripheral.find("modem")
	if m then
		if not m.isOpen(nv.channel) then
			m.open(nv.channel)
		end
	end
	return m
end

local modem = getModem()

local send = function(envKey, cID, command, recipient, tbl, key, value)
	modem.transmit(nv.channel, nv.channel, {
		envKey = envKey,
		command = command,
		t = tbl,
		k = key,
		v = value,
		publicID = nv.publicID,
		cID = cID or math.random(1, 2^30),
		recipient = recipient
	})
end

-- easy way to view values
local debugErrorScreen = function(value)
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	term.clear()
	term.setCursorPos(1,1)
	print(textutils.serialize(value))
	term.setCursorPos(1, 18)
	error()
end

local rawReceive = function(valueType, timeout)
	local evt, tID
	if timeout then
		tID = os.startTimer(timeout)
	end
	repeat
		evt = {os.pullEvent()}
	until (
		evt[1] == "modem_message" and type(evt[5]) == valueType
	) or (
		evt[1] == "timer" and evt[2] == tID
	)
	return evt[5]
end

local receive = function(envKey, cID, timeout)
	local output
	repeat
		output = rawReceive("table", timeout)
	until (output or {}).cID == cID or output == nil
	return output
end

-- runs a neovariable server, and sets envList to the list of environments used
API.runServer = function( envList, verbose )
	local evt, msg
	while true do

		repeat
			repeat
				evt = {os.pullEvent("modem_message")}
			until type(evt[5]) == "table"
		until evt[5].cID ~= nil
		msg = evt[5]

		if msg.command == "find" then
			if verbose then print("got 'find' request") end
			send(nil, msg.cID, "find_response", msg.publicID, nv.publicID)
		elseif msg.command == "set" or msg.command == "get" then
			if ( -- check the types of all the input
				msg.envKey ~= nil and
				type(msg.publicID) == "string" and
				msg.k ~= nil and
				msg.recipient == nv.publicID
			) then
				nv.environment[msg.publicID] = nv.environment[msg.publicID] or {}
				nv.environment[msg.publicID][msg.envKey] = nv.environment[msg.publicID][msg.envKey] or {}

				if msg.command == "set" then
					if msg.v ~= nil then
						if verbose then print("[" .. tostring(msg.envKey) .. "] " .. tostring(msg.k) .. " = " .. tostring(msg.v)) end
						nv.environment[msg.publicID][msg.envKey][msg.k] = msg.v
					end
				elseif msg.command == "get" then
					if verbose then print("[" .. tostring(msg.envKey) .. "] " .. tostring(msg.k)) end
					send(msg.envKey, msg.cID, "get_response", msg.publicID, nv.environment[msg.publicID][msg.envKey][msg.k])
				end
			end
		end
		envList = nv.environment
		
	end
end

API.findServer = function(getList, timeout)
	timeout = tonumber(timeout) or 1
	local cID = math.random(1, 2^30)
	send(nil, cID, "find")
	if getList then
		local servers = {}
		parallel.waitForAny(
			function()
				while true do
					servers[#servers+1] = receive(nil, cID).publicID
				end
			end,
			function()
				sleep(timeout)
			end
		)
		return servers
	else
		return (receive(nil, cID, timeout) or {}).publicID
	end
end

API.newEnvironment = function(server, envKey)
	assert(type(server) == "string", "server ID must be a string")
	assert(envKey ~= nil, "envKey must not be nil")
	return makeMT(
		function(t, k)
			local cID = math.random(1, 2^30)
			send(envKey, cID, "get", server, t, k)
			local response = receive(envKey, cID, 3)
			if response then
				return response.t
			else
				return nil, "no response"
			end
		end,
		function(t, k, v)
			local cID = math.random(1, 2^30)
			send(envKey, cID, "set", server, t, k, v)
		end
	)
end

if mode == "server" then
	API.runServer(nil, true)
elseif mode == "demo" then
	local server = API.findServer(false, 1)
	if server then
		print("found server")
		local noo = API.newEnvironment(server, 1)
		local yoo = API.newEnvironment(server, 2)
		print("made envs")
		noo.hi = "what"
		yoo.he = "bumbo"
		print("set")
		local var = noo.hi
		local ver = yoo.he
		print("get")
		print("noo.hi = " .. tostring(noo.hi))
		print("yoo.he = " .. tostring(yoo.he))
	else
		print("no neovariable server")
	end
else
	return API
end
