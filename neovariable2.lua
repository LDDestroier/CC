local tArg = {...}
local isServer = tArg[1] == "server"

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

local nv = {
	dir = {									-- all DIRECTORIES will end with "/"
		main = "neovariable",				-- main directory where all neovariable stuff are
		privateID = "neovariable/private",	-- private computer ID, protect with your life
		publicID = "neovariable/public",	-- public computer ID, is shared all the time
		config = "neovariable/config",		-- config options
		api = "neovariable/api/"			-- where APIs are stored
	},
	envKey = 1,			-- determines which environment to use
	environment = {},	-- stores multiple environments
	privateID = nil,	-- every computer should have a secret, individual "ID"
	publicID = nil,		-- every computer should also have a public key
	channel = 1002,		-- modem channel
}

for k,v in pairs(nv.dir) do
	if (not fs.exists(v)) and v:sub(-1, -1) == "/" then
		fs.makeDir(v)
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

local makeNewID = function(path)
	local file = fs.open(path, "w")
	local id = ""
	for i = 1, 256 do
		id = id .. string.char(math.random(1, 127))
	end
	file.write(id)
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

local newEnvironment = function(server, envKey)
	return makeMT(
		function(t, k)
			local cID = math.random(1, 2^30)
			send(envKey, cID, "get", server, t, k)
			local response = receive(envKey, cID, 3)
			if response then
				return response.v
			else
				return false, "no response"
			end
		end,
		function(t, k, v)
			local cID = math.random(1, 2^30)
			send(envKey, cID, "set", server, t, k, v)
			-- that should be enough
		end
	)
end

-- runs a neovariable server, and sets envList to the list of environments used
runServer = function( envList, verbose )
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
			if (	-- check the types of all the input
				msg.envKey ~= nil and
				type(msg.publicID) == "string" and
				type(t) == "table" and
				msg.k ~= nil and
				msg.recipient == nv.publicID
			) then

				nv.environment[msg.publicID] = nv.environment[msg.publicID] or {}
				nv.environment[msg.publicID][envKey] = nv.environment[msg.publicID][envKey] or {}

				if msg.command == "set" then
					if msg.v ~= nil then
						if verbose then print("got 'set' request") end
						nv.environment[msg.publicID][msg.envKey][msg.k] = msg.v
					end
				elseif msg.command == "get" then
					if verbose then print("got 'get' request") end
					send(msg.envKey, msg.cID, "get_response", msg.publicID, nv.environment[msg.publicID][msg.envKey][msg.k])
				end
			end
		end
	end
end

findServers = function(timeout)
	timeout = timeout or 1
	local cID = math.random(1, 2^30)

	local servers = {}
	send(nil, cID, "find")
	parallel.waitForAny(
		function()
			while true do
				servers[#servers+1] = receive(nil, cID).t
			end
		end,
		function()
			sleep(timeout)
		end
	)
	return servers
end

newEnv = function(server, envKey)
	return newEnvironment()
end

if isServer then
	runServer(nil, true)
else
	local server = findServers(1)[1]
	local noo = newEnv(server, 1)
	noo.hi = "what"
end
