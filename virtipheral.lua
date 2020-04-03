local virtipheral = {
	-- path where virtual peripherals are stored
	peripheralPath = ".virtipheral/peripherals",

	-- default path to store the list of currently loaded peripherals
	configPath = ".virtipheral/p.lson",
}

-- list of currently loaded virtual peripherals
-- K = side, V = methods
local virtualPeripherals = {}

local function tableCopy(tbl)
	local output = {}
	for k,v in pairs(tbl) do
		if type(v) == "table" then
			output[k] = tableCopy(v)
		else
			output[k] = v
		end
	end
	return output
end

local loadPeripheral = function(name)
	local path = fs.combine(virtipheral.peripheralPath, name)
	local output
	if not fs.exists(path) then	-- counteract edit.lua's fixation with ending every goddamn file with ".lua"
		path = path .. ".lua"
	end
	if fs.exists(path) then
		output = dofile(path)
		return output
	else
		return false
	end
end

local makeNewPeripheralAPI = function(old)
	local p = {}

	p.attach = function(side, name)
		assert(type(side) == "string", "bad argument #1 to 'attach' (expected string, got " .. type(side) .. ")")
		assert(type(name) == "string", "bad argument #2 to 'attach' (expected string, got " .. type(name) .. ")")
		local methods = loadPeripheral(name)
		if methods then
			virtualPeripherals[side] = {
				name = name,
				side = side,
				methods = methods,
			}
			return true
		else
			return false
		end
	end

	p.detach = function(side)
		assert(type(side) == "string", "bad argument #1 to 'detach' (expected string, got " .. type(side) .. ")")
		virtualPeripherals[side] = nil
	end

	p.saveAttach = function(configPath)
		configPath = configPath or virtipheral.configPath

		local save = {}
		for k,v in pairs(virtualPeripherals) do
			save[k] = {
				name = v.name,
				side = v.side,
			}
		end
		local file = fs.open(configPath, "w")
		file.write(textutils.serialize(save))
		file.close()
	end

	p.loadAttach = function(configPath, additive)
		configPath = configPath or virtipheral.configPath
		local file = fs.open(configPath, "r")
		local contents = textutils.unserialize(file.readAll() or "")
		file.close()
		if not additive then
			virtualPeripherals = {}
		end
		if contents then
			for k,v in pairs(contents) do
				p.attach(v.side or k, v.name)
			end
		end
	end

	p.wrap = function(side)
		assert(type(side) == "string", "bad argument #1 to 'wrap' (expected string, got " .. type(side) .. ")")
		if virtualPeripherals[side] then
			return virtualPeripherals[side].methods
		else
			return old.wrap(side)
		end
	end

	p.call = function(side, method, ...)
		assert(type(side)   == "string", "bad argument #1 to 'call' (expected string, got " .. type(side) .. ")")
		assert(type(method) == "string", "bad argument #2 to 'call' (expected string, got " .. type(method) .. ")")
		if virtualPeripherals[side] then
			if virtualPeripherals[side].methods[method] then
				virtualPeripherals[side].methods[method](...)
			else
				error("no such method", 0)
			end
		else
			return old.call(side, method, ...)
		end
	end

	p.find = function(pType)
		assert(type(pType) == "string", "bad argument #1 to 'find' (expected string, got " .. type(pType) .. ")")
		for k,v in pairs(virtualPeripherals) do
			if v.name == pType then
				return v.methods
			end
		end
		return old.find(pType)
	end

	p.getNames = function()
		local output = {}
		for k, v in pairs(virtualPeripherals) do
			output[#output + 1] = k
		end
		for k, v in pairs(old.getNames()) do
			output[#output + 1] = v
		end
		return output
	end

	p.getMethods = function(side)
		local output = {}
		local list = (virtualPeripherals[side] or {}).methods or old.wrap(side)
		if list then
			for k,v in pairs(list) do
				output[#output + 1] = k
			end
		else
			return nil
		end
		return output
	end

	p.getType = function(side)
		if virtualPeripherals[side] then
			return virtualPeripherals[side].name
		else
			return old.getType(side)
		end
	end

	p.isPresent = function(side)
		if virtualPeripherals[side] then
			return true
		elseif old.isPresent(side) then
			return true
		else
			return false
		end
		return true
	end

	return p
end

virtipheral.activate = function()
	if _G.virtipheralActive then
		error("Virtipheral is already running", 0)
	else
		fs.makeDir(virtipheral.peripheralPath)
		local old = tableCopy(_G.peripheral)
		for k,v in pairs(old) do
			local env = getfenv(old[k])
			env.peripheral = old
		end
		_G.__old_peripheral = old
		_G.peripheral = makeNewPeripheralAPI(old)
		_G.virtipheralActive = true
		return true
	end
end

virtipheral.deactivate = function()
	if not _G.virtipheralActive then
		error("Virtipheral is not running", 0)
	else
		_G.peripheral = tableCopy(_G.__old_peripheral)
		for k,v in pairs(_G.peripheral) do
			local env = getfenv(_G.peripheral[k])
			env.peripheral = _G.peripheral
		end
		_G.__old_peripheral = nil
		_G.virtipheralActive = false
		return true
	end
end

return virtipheral
