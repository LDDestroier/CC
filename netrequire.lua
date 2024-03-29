local function netrequire(_name, alwaysDownload, ...)
	assert(type(_name) == "string", "API name must be a string")
	local DL_path = ".netrequire_storage"
	
	local name
	if _name:sub(-4, -1) == ".lua" then
		name = _name:sub(1, -5)
	else
		name = _name
	end
	
	if (not alwaysDownload) and fs.exists(fs.combine(DL_path .. "/require", name)) then
		return loadfile(fs.combine(DL_path .. "/require", name))(...)
		
	elseif (not alwaysDownload) and fs.exists(fs.combine(DL_path .. "/loadAPI", name)) then
		os.loadAPI(fs.combine(DL_path .. "/loadAPI", name))
		return _ENV[fs.getName(name)]
		
	else
		local url = "https://github.com/LDDestroier/CC/raw/master/netrequire/" .. name
		local net = http.get(url)
		local description, creator
		if net then
			url = net.readLine()
			local useLoadAPI = net.readLine():sub(1, 4) == "true"
			creator = net.readLine()
			description = net.readAll()
			net.close()
			net = http.get(url)
			if net then
				local contents = net.readAll()
				net.close()
				if useLoadAPI then
					local file = fs.open(fs.combine(DL_path .. "/loadAPI", name), "w")
					file.write(contents)
					file.close()
					os.loadAPI(fs.combine(DL_path .. "/loadAPI", name))
					return _ENV[fs.getName(name)]
				else
					local file = fs.open(fs.combine(DL_path .. "/require", name), "w")
					file.write(contents)
					file.close()
					return loadstring(contents)(...)
				end
			else
				error("Couldn't connect to '" .. url .. "'")
			end
		else
			error("Cannot find any such API '" .. name .. "'")
		end
	end
end

return netrequire
