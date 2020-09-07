--[[
 disknet2
 Work in progress (nonfunctional)
--]]

local disknet = {
	config = {
		limitChannelsToModem = false,
		updateSpeed = 0.05,
		messageDeleteAge = 5,
		path = "disk/DISKNET",
		openChannels = {},
	},
}

-- checks if an inputted channel is valid to use
local checkValidChannel = function(channel)
	if disknet.config.limitChannelsToModem then
		if type(channel) == "number" then
			if channel >= 1 and <= 65535 then
				return true, "all good"
			else
				return false, "channel is out of modem range (1-65535)"
			end
		else
			return false, "channel is out of modem range (must be number)"
		end
		
	else
		if type(channel) == "number" or type(channel) == "string" then
			if #channel <= 32 then
				return true, "all nice"
			else
				return false, "channel is too large"
			end
		else
			return false, "channel must be string or number"
		end
	end
end

local makeRandomID = function()
	return math.random(1, 2^31-1)
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

-- minified version of textutils.serialize
-- will actually make later
local serialize = function(input)
	return textutils.serialize(input)
end

disknet.setPath = function(path)
	local p = fs.combine("", path)
	if fs.isReadOnly(p) then
		return false, "Cannot set to read-only path."
	elseif (fs.exists(path) and not fs.isDir(path)) then
		return false, "Cannot set path to that of a file."
	else
		disknet.config.path = p
		return true
	end
end

local channelInfo = {}

disknet.open = function(channel)
	assert(checkValidChannel(channel))
	disknet.config.openChannels[channel] = true
	channelInfo[channel] = {}
end

disknet.close = function(channel)
	disknet.config.openChannels[channel] = nil
	channelInfo[channel] = nil
end

disknet.closeAll = function()
	disknet.config.openChannels = {}
	channelInfo = {}
end

disknet.send = function(message, channel, recipientID)
	local sMessage = serialize(message)
	assert(sMessage, "invalid message")
	assert(checkValidChannel(channel))
	assert(disknet.config.openChannels[channel], "cannot send to unopened channel")

	local mID = makeRandomID()

	-- sanitize all inputs
	if type(recipientID) == "string" then
		recipientID = recipientID:gsub("\n", "\\n")
	end
	local output = table.concat({
		recipientID or "",
		"",
		"",
		"",
		serialize(message)
	}, "\n")
end

disknet.receive = function(filterChannel, filterID)
	
end
