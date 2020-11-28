local disknet = disknet or {}

local tArg = {...}

disknet.mainPath = "disk/DISKNET"	-- path of shared file
local limitChannelsToModem = false	-- if true, can only use number channels from 1 to 65535
local checkDelay = 0.2			-- amount of time (seconds) between checking the file -- if 0, checks super fast so don't do that
local maximumBufferSize = 64		-- largest amount of messages per channel buffered

local isUsingTweaked = false
if _HOST then
	if _HOST:find("CCEmuX") or _HOST:find("CC:Tweaked") or _HOST:find("[(]Minecraft") then
		isUsingTweaked = true
	end
end

local openChannels = {}
local yourID = os.getComputerID()
local uniqueID = math.random(1, 2^31 - 1) -- prevents receiving your own messages
disknet.msgCheckList = {}	-- makes sure duplicate messages aren't received
local ageToToss = 0.005		-- amount of time before a message is removed

-- used for synching times between different emulators
disknet._timeMod = 0

-- do not think for one second that os.epoch("utc") would be a proper substitute
local getTime = function()
	if os.day then
		return (os.time() + (-1 + os.day()) * 24) + disknet._timeMod
	else
		return os.time() + disknet._timeMod
	end
end

local function serialize(tbl)
	local output = "{"
	local noKlist = {}
	local cc = table.concat
	for i = 1, #tbl do
		if type(tbl[i]) == "table" then
			output = output .. serialize(tbl[i])
		elseif type(tbl[i]) == "string" then
			output = cc({output, "\"", tbl[i], "\""})
		else
			output = output .. tbl[i]
		end
		noKlist[i] = true
		output = output .. ","
	end
	for k,v in pairs(tbl) do
		if not noKlist[k] then
			if type(k) == "number" or type(k) == "table" then
				output = cc({output, "[", k, "]="})
			else
				output = cc({output, k, "="})
			end
			if type(v) == "table" then
				output = output .. serialize(v)
			elseif type(v) == "string" then
				output = cc({output, "\"", v, "\""})
			else
				output = output .. v
			end
			output = output .. ","
		end
	end
	return output:sub(1, -2):gsub("\n", "\\n") .. "}"
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
isOpen = disknet.isOpen

disknet.open = function(channel)
	local valid, grr = checkValidChannel(channel)
	if valid then
		openChannels[#openChannels + 1] = channel
		return true
	else
		error(grr)
	end
end
open = disknet.open

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
close = disknet.close

disknet.closeAll = function()
	openChannels = {}
end
closeAll = disknet.closeAll

disknet.send = function(channel, message, recipient)
	local valid, grr = checkValidChannel(channel)
	if valid then
		if not fs.exists(fs.combine(disknet.mainPath, tostring(channel))) then
			fs.makeDir(disknet.mainPath)
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
				file.write(serialize(contents))
			else
				file.write(serialize({{
					time = cTime,
					id = yourID,
					uniqueID = uniqueID,
					messageID = math.random(1, 2^31 - 1),
					channel = channel,
					message = message,
				}}):gsub("\n[ ]*", ""))
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
send = disknet.send

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

-- returns: string message, string/number channel, number senderID, number timeThatMessageWasSentAt
disknet.receive = function(channel, senderFilter)
	local valid, grr = checkValidChannel(channel)
	if valid or not channel then

		local output, contents
		local doRewrite = false

		local good, goddamnit = pcall(function()
			local cTime = getTime()
			local goWithIt = false
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
										if (contents[look].uniqueID ~= uniqueID) and (not disknet.msgCheckList[contents[look].messageID]) then	-- make sure you're not receiving messages that you sent
											if (not contents[look].recipient) or contents[look].recipient == yourID then				-- make sure that messages intended for others aren't picked up
												if (not channel) or channel == contents[look].channel then								-- make sure that messages are the same channel as the filter, if any
													if (not senderFilter) or senderFilter == contents[look].id then						-- make sure that the sender is the same as the id filter, if any
														if (not isUsingTweaked) and math.abs(contents[look].time - getTime()) >= ageToToss then		-- if using something besides CC:Tweaked/CCEmuX, adjust your time.
															disknet._timeMod = contents[look].time - getTime()
															cTime = getTime()
															goWithIt = true
														end
														if cTime - (contents[look].time or 0) <= ageToToss or goWithIt then						-- make sure the message isn't too old
															disknet.msgCheckList[contents[look].messageID] = true
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
									if cTime - (contents[t].time or 0) > ageToToss or cTime - (contents[t].time or 0) < -1 then
										disknet.msgCheckList[contents[t].messageID] = nil
										table.remove(contents, t)
										doRewrite = true
									end
								end
								if doRewrite then
									writeFile(pList[i], serialize(contents))
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
					if checkDelay > 0 then
						sleep(checkDelay)
					else
						os.queueEvent("")
						os.pullEvent("")
					end
				end
				for i = 1, #fList do
					fList[i].close()
				end
				fList, pList = {}, {}
			end
		end)

		if good then
			if contents then
				return output.message, output.channel, output.id, output.time + disknet._timeMod
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
receive = disknet.receive

-- not really needed if going between CCEmuX and another emulator, but may be needed between two separate CCEmuX daemons
disknet.receive_TS = function(...)
	local message, channel, id, time = disknet.receive(...)
	if time then
		disknet._timeMod = time - getTime()
	end
	return message, channel, id, time
end
receive_TS = disknet.receive_TS

return disknet
