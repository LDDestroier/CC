local function interpretArgs(tInput, tArgs)
	local output = {}
	local errors = {}
	local usedEntries = {}
	for aName, aType in pairs(tArgs) do
		output[aName] = false
		for i = 1, #tInput do
			if not usedEntries[i] then
				if tInput[i] == aName and not output[aName] then
					if aType then
						usedEntries[i] = true
						if type(tInput[i+1]) == aType or type(tonumber(tInput[i+1])) == aType then
							usedEntries[i+1] = true
							if aType == "number" then
								output[aName] = tonumber(tInput[i+1])
							else
								output[aName] = tInput[i+1]
							end
						else
							output[aName] = nil
							errors[1] = errors[1] and (errors[1] + 1) or 1
							errors[aName] = "expected " .. aType .. ", got " .. type(tInput[i+1])
						end
					else
						usedEntries[i] = true
						output[aName] = true
					end
				end
			end
		end
	end
	for i = 1, #tInput do
		if not usedEntries[i] then
			output[#output+1] = tInput[i]
		end
	end
	return output, errors
end

--[[

--example from progdor2

local argData = {
	["-pb"] = "string",	-- pastebin get
	["-dd"] = "string",	-- direct URL download
	["-m"] = "string",	-- specify main file
	["-PB"] = false,	-- pastebin upload
	["-e"] = false,		-- automatic self-extractor
	["-s"] = false,		-- silent
	["-a"] = false,		-- use as API with require, also makes silent
	["-c"] = false,		-- use CCA compression
	["-h"] = false,		-- show help
	["-i"] = false,		-- inspect mode
}

local argList, argErrors = interpretArgs({...}, argData)

if #argErrors > 0 then
	local errList = ""
	for k,v in pairs(argErrors) do
		if k ~= 1 then
			errList = errList .. "\"" .. k .. "\": " .. v .. "; "
		end
		error(errList:sub(1, -2))
	end
end

local pastebinGet    = argList["-pb"]	-- string, pastebin code
local directDownload = argList["-dd"]	-- string, download URL
local mainFile		 = argList["-m"]	-- string, main executable file
local pastebinUpload = argList["-PB"]	-- boolean
local selfExtractor	 = argList["-e"]	-- boolean
local silent		 = argList["-s"]	-- boolean
local useCompression = argList["-c"]	-- boolean
local justOverwrite  = argList["-o"] 	-- boolean

--]]
