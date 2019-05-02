local disknet = {}

local tArg = {...}

disknet.mainPath = tArg[1] or "disk/DISKNET"
local limitChannelsToModem = false
local maximumBufferSize = 32

local openChannels = {}
local yourID = os.getComputerID()
local uniqueID = math.random(1, 2^31 - 1) -- prevents receiving your own messages
local msgCheckList = {} -- makes sure duplicate messages aren't received

-- do not think for one second that os.epoch("utc") would be a proper substitute
local getTime = function()
	return os.time() + (-1 + os.day()) * 24
end

local readFile = function(path)
	local file = fs.open(path, "r")
	local contents = file.readAll()
	file.close()
	return contents
end

local writeFile = function(path, contents)
	local file = fs.open(path, "w")
	file.write(contents)
	file.close()
end

-- if 'limitChannelsToModem', then will make sure that channel is a number between 0 and 65535
local checkValidChannel = function(channel)
	if limitChannelsToModem then
		if type(channel) == "number" then
			if channel < 0 or channel > 65535 then
				return false, "channel must be between 0 and 65535"
			else
				return true
			end
		else
			return false, "channel must be number"
		end
	else
		if type(channel) == "string" or type(channel) == "number" then
			return true
		else
			return false, "channel must be castable to string"
		end
	end
end

disknet.isOpen = function(channel)
	local valid, grr = checkValidChannel(channel)
	if valid then
		for i = 1, #openChannels do
			if openChannels[i] == channel then
				return true
			end
		end
		return false
	else
		error(grr)
	end
end

disknet.open = function(channel)
	local valid, grr = checkValidChannel(channel)
	if valid then
		openChannels[#openChannels + 1] = channel
		return true
	else
		error(grr)
	end
end

disknet.close = function(channel)
	local valid, grr = checkValidChannel(channel)
	if valid then
		for i = 1, #openChannels do
			if openChannels[i] == channel then
				table.remove(openChannels, i)
				return true
			end
		end
		return false
	else
		error(grr)
	end
end

disknet.closeAll = function()
	openChannels = {}
end

disknet.send = function(channel, message)
	local valid, grr = checkValidChannel(channel)
	if valid then
		local contents = textutils.unserialize(readFile(fs.combine(disknet.mainPath, tostring(channel))))
		if disknet.isOpen(channel) then
			local file = fs.open(fs.combine(disknet.mainPath, tostring(channel)), "w")
			if contents then
				contents[#contents + 1] = {
					time = getTime(),
					id = yourID,
					uniqueID = uniqueID,
					messageID = math.random(1, 2^31 - 1),
					channel = channel,
					message = message,
				}
				if #contents > maximumBufferSize then
					table.remove(contents, 1)
				end
				file.write(textutils.serialize(contents))
			else
				file.write(textutils.serialize({{
					time = getTime(),
					id = yourID,
					uniqueID = uniqueID,
					messageID = math.random(1, 2^31 - 1),
					channel = channel,
					message = message,
				}}))
			end
			file.close()
			return true
		else
			return false
		end
	else
		error(grr)
	end
end

local fList, pList = {}, {}

local loadFList = function()
	fList, pList = {}, {}
	if channel then
		fList = {fs.open(fs.combine(disknet.mainPath, tostring(channel)), "r")}
		pList = {fs.combine(disknet.mainPath, tostring(channel))}
	else
		for i = 1, #openChannels do
			fList[i] = fs.open(fs.combine(disknet.mainPath, tostring(openChannels[i])), "r")
			pList[i] = fs.combine(disknet.mainPath, tostring(openChannels[i]))
		end
	end
end

disknet.receive = function(channel)
	local valid, grr = checkValidChannel(channel)
	if valid or not channel then
	
		local output, contents
		local doRewrite = false
		
		while true do
			loadFList()
			for i = 1, #fList do
				contents = fList[i].readAll()
				if contents ~= "" then
					contents = textutils.unserialize(contents)
					if type(contents) == "table" then
						if contents[1] then
							if (not output) and (contents[1].uniqueID ~= uniqueID) and (not msgCheckList[contents[1].messageID]) then
								if getTime() - (contents[1].time or 0) <= 0.01 then
									msgCheckList[contents[1].messageID] = true
									output = {}
									for k,v in pairs(contents[1]) do
										output[k] = v
									end
								end
							end
							doRewrite = false
							for t = #contents, 1, -1 do
								if getTime() - (contents[t].time or 0) > 0.01 then
									table.remove(contents, t)
									doRewrite = true
								end
							end
							if doRewrite then
								writeFile(pList[i], textutils.serialize(contents))
							end
							if output then
								for i = 1, #fList do
									fList[i].close()
								end
								break
							end
						end
					end
				end
			end
			if output then
				break
			else
				for i = 1, #fList do
					fList[i].close()
				end
				os.queueEvent("")
				os.pullEvent("")
			end
		end
		
		if contents then
			return output.message, output.channel, output.id, output.time
		else
			return nil
		end
	else
		error(grr)
	end
end

return disknet
