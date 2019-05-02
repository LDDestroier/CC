local disknet = {}

local mainPath = "disk/DISKNET"
local limitChannelsToModem = false
local openChannels = {}
local yourID = os.getComputerID()

local getTime = function()
	return os.time() + (-1 + os.day()) * 24
end

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



disknet.transmit = function(channel, message)
	local valid, grr = checkValidChannel(channel)
	if valid then
		if disknet.isOpen(channel) then
			local file = fs.open(fs.combine(mainPath, tostring(channel)), "a")
			file.write(textutils.serialize({
				time = getTime(),
				id = yourID,
				channel = channel,
				message = message,
			}))
			file.close()
			return true
		else
			return false
		end
	else
		error(grr)
	end
end

disknet.receive = function(channel)
	local valid, grr = checkValidChannel(channel)
	if valid or not channel then
	
		local fList, contents = {}
		
		-- clear files
		if channel then
			if openChannels[channel] then
				file = fs.open(fs.combine(mainPath, tostring(channel)), "w")
				file.close()
				fList[1] = fs.open(fs.combine(mainPath, tostring(channel)), "r")
			end
		else
			for i = 1, #openChannels do
				file = fs.open(fs.combine(mainPath, tostring(openChannels[i])), "w")
				file.close()
				fList[i] = fs.open(fs.combine(mainPath, tostring(openChannels[i])), "r")
			end
		end
		
		-- constantly check channel files
		local returnChannel
		while true do
			for i = 1, #fList do
				contents = fList[i].readAll()
				if contents ~= "" then
					returnChannel = channel or openChannels[i]
					break
				end
			end
			if returnChannel then
				break
			else
				os.queueEvent("")
				os.pullEvent("")
			end
		end
		for i = 1, #fList do
			fList[i].close()
		end
		contents = textutils.unserialize(contents)
		if contents then
			return contents.message, returnChannel, contents.id, contents.time
		else
			return nil
		end
	else
		error(grr)
	end
end

return disknet
