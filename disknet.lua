local disknet = {}

local tArg = {...}

disknet.mainPath = tArg[1] or "disk/DISKNET"
local limitChannelsToModem = false
local maximumBufferSize = 64

local openChannels = {}
local yourID = os.getComputerID()
local uniqueID = math.random(1, 2^31 - 1) -- prevents receiving your own messages
local msgCheckList = {} -- makes sure duplicate messages aren't received
local ageToToss = 0.002	-- amount of time before a message is removed

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

disknet.send = function(channel, message, recipient)
	local valid, grr = checkValidChannel(channel)
	if valid then
		if not fs.exists(fs.combine(disknet.mainPath, tostring(channel))) then
			fs.open(fs.combine(disknet.mainPath, tostring(channel)), "w").close()
		end
		local contents = textutils.unserialize(readFile(fs.combine(disknet.mainPath, tostring(channel))))
		local cTime = getTime()
		if disknet.isOpen(channel) then
			local file = fs.open(fs.combine(disknet.mainPath, tostring(channel)), "w")
			if contents then
				contents[#contents + 1] = {
					time = cTime,
					id = yourID,
					uniqueID = uniqueID,
					messageID = math.random(1, 2^31 - 1),
					channel = channel,
					recipient = recipient,
					message = message,
				}
				for i = #contents, 1, -1 do
					if cTime - (contents[i].time or 0) > ageToToss then
						table.remove(contents, i)
					end
				end
				if #contents > maximumBufferSize then
					table.remove(contents, 1)
				end
				file.write(textutils.serialize(contents))
			else
				file.write(textutils.serialize({{
					time = cTime,
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

local fList, pList, sList = {}, {}, {}

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

disknet.receive = function(channel, senderFilter)
	local valid, grr = checkValidChannel(channel)
	if valid or not channel then

		local output, contents
		local doRewrite = false

		local good, goddamnit = pcall(function()
			local cTime = getTime()
			while true do
				loadFList()
				for i = 1, #fList do
					contents = fList[i].readAll()
					if contents ~= "" then
						contents = textutils.unserialize(contents)
						if type(contents) == "table" then
							if contents[1] then
								if not output then
									for look = 1, #contents do
										if (contents[look].uniqueID ~= uniqueID) and (not msgCheckList[contents[look].messageID]) then	-- make sure you're not receiving messages that you sent
											if (not contents[look].recipient) or contents[look].recipient == yourID then				-- make sure that messages intended for others aren't picked up
												if (not channel) or channel == contents[look].channel then								-- make sure that messages are the same channel as the filter, if any
													if (not senderFilter) or senderFilter == contents[look].id then						-- make sure that the sender is the same as the id filter, if any
														if cTime - (contents[look].time or 0) <= ageToToss then						-- make sure the message isn't too old
															msgCheckList[contents[look].messageID] = true
															output = {}
															for k,v in pairs(contents[look]) do
																output[k] = v
															end
															break
														end
													end
												end
											end
										end
									end
								end

								-- delete old msesages
								doRewrite = false
								for t = #contents, 1, -1 do
									if cTime - (contents[t].time or 0) > ageToToss then
										msgCheckList[contents[t].messageID] = nil
										table.remove(contents, t)
										doRewrite = true
									end
								end
								if doRewrite then
									writeFile(pList[i], textutils.serialize(contents))
								end
								if output then
									break
								end
							end
						end
					end
				end
				if output then
					break
				else
					os.queueEvent("")
					os.pullEvent("")
				end
				for i = 1, #fList do
					fList[i].close()
				end
				fList, pList = {}, {}
			end
		end)

		if good then
			if contents then
				return output.message, output.channel, output.id, output.time
			else
				return nil
			end
		else
			for i = 1, #fList do
				fList[i].close()
			end
			error(goddamnit, 0)
		end
	else
		error(grr)
	end
end

return disknet
