local function netrequire(_name, alwaysDownload, ...)
	assert(type(_name) == "string", "API name must be a string")
	local DL_path = ".netrequire_storage"
	
	local name
	if _name:sub(-4, -1) ~= ".lua" then
		name = _name .. ".lua"
	else
		name = _name
	end
	
	if (not fs.exists(fs.combine(DL_path, name))) or alwaysDownload then
		local url = "https://github.com/LDDestroier/CC/raw/master/netrequire/" .. name
		local net = http.get(url)
		if net then
			local contents = net.readAll()
			net.close()
			local file = fs.open(fs.combine(DL_path, name), "w")
			file.write(contents)
			file.close()
			return loadstring(contents)(...)
		else
			error("Cannot find any such API '" .. name .. "'")
		end
	else
		return loadfile(fs.combine(DL_path, name))(...)
	end
end

return netrequire
