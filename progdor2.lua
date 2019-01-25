local progdor = {
	version = "0.1b",
	numVersion = 1,
}

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

local yield = function()
	os.queueEvent("yield")
	os.pullEvent("yield")
end

-- CCA API START --

local bit = bit32
local function pack(bn1, bn2)
	return bit.band(bn1, 0xFF), bit.rshift(bn1, 8) + bit.lshift(bit.band(bn2, 0xF), 4), bit.rshift(bn2, 4)
end
local function upack(b1, b2, b3)
	return (b1 + bit.lshift(bit.band(b2, 0xF), 8)), (bit.lshift(b3,4) + bit.band(bit.rshift(b2, 4), 0xF))
end
local function createDict(bool)
	local ret = {}
	for i = 1, 255 do
		if bool then
			ret[string.char(i)] = i
		else
			ret[i] = string.char(i)
		end
	end
	if not bool then ret[256] = 256 end
	return ret
end
local function cp(sInput)
	local dic = createDict(true)
	local s = ""
	local ch
	local dlen = 256
	local result = {}
	local temp
	for i = 1, #sInput do
		if dlen == 4095 then
			result[#result + 1] = dic[s]
			result[#result + 1] = 256
			dic = createDict(true)
			dlen = 256
			s = ""
		end
		ch = sInput:sub(i, i)
		temp = s..ch
		if dic[temp] then
			s = temp
		else
			result[#result + 1] = dic[s]
			dlen = dlen	+1
			dic[temp] = dlen
			s = ch
		end
	end
	result[#result + 1] = dic[s]

	return result
end
local function dc(data)
	local dic = createDict(false)
	local entry
	local ch
	local currCode
	local result = {}
	result[#result + 1] = dic[data[1]]
	prefix = dic[data[1]]
	for i = 2, #data do
		currCode = data[i]
		if currCode == 256 then
			dic = createDict(false)
			prefix = ""
		else
			entry = dic[currCode]
			if entry then--exists in dictionary
				ch = entry:sub(1, 1)
				result[#result + 1] = entry
				if prefix ~= "" then
					dic[#dic+1] = prefix .. ch
				end
			else
				ch = prefix:sub(1, 1)
				result[#result + 1] = prefix..ch
				dic[#dic + 1] = prefix..ch
			end

			prefix = dic[currCode]
		end
	end

	return table.concat(result)
end
local function trim(inp)
	for i = 0,2 do
		if inp[#inp] == 0 then
			inp[#inp] = nil
		end
	end
end
local function decompress(input)
	local rec = {}
	for i = 1, #input, 3 do
		if i % 66 == 0 then
			yield()
		end
		rec[#rec+1], rec[#rec+2] = upack(input[i], input[i+1] or 0, input[i+2] or 0)
	end
	trim(rec)
	return dc(rec)
end
local function compress(input)
	local rec = {}
	local data = cp(input)
	for i=1, #data, 2 do
		yield()
		rec[#rec+1], rec[#rec+2], rec[#rec+3] = pack(data[i], data[i+1] or 0)
	end
	trim(rec)
	return rec
end

-- CCA API END --

-- pastebin uploads have a 512K limit
local pastebinFileSizeLimit = 1024 * 512

local argData = {
	["-pb"] = "string",	-- pastebin get
	["-dd"] = "string",	-- direct URL download
	["-m"] = "string",	-- specify main file
	["-PB"] = false,	-- pastebin upload
	["-e"] = false,		-- automatic extract
	["-s"] = false,		-- silent
	["-a"] = false,		-- use as API with require, also makes silent
	["-c"] = false,		-- use CCA compression
	["-h"] = false		-- show help
}

local argList, argErrors = interpretArgs({...}, argData)

if #argErrors > 0 then
	for k,v in pairs(argErrors) do
		if k ~= 1 then
			printError("\"" .. k .. "\": " .. v)
		end
	end
	return false
end

local function showHelp()
	local helpInfo = {
		"progdor v" .. progdor.version,
		"Usage: progdor [options] inputFolder (outputFile)",
		"       progdor [options] inputFile (outputFolder)",
		"",
		"Progdor is a file/folder packaging program.",
		"",
		"Options:",
		" -pb [pastebin ID] : Download from Pastebin.",
		" -PB : Upload to pastebin.",
		" -dd [download URL] : Download from URL.",
		" -e : Adds on auto-extract code to archives.",
		" -s : Silences all terminal writing",
		" -a : Allows programs to use require() on Progdor.",
		" -c : Enables CCA compression.",
		" -m : Specify main executable file in archive.",
		" -h : Show this help."
	}
	for y = 1, #helpInfo do
		print(helpInfo[y])
	end
end

local pastebinGet    = argList["-pb"]	-- string, pastebin code
local directDownload = argList["-dd"]	-- string, download URL
local mainFile		 = argList["-m"]	-- string, main executable file
local pastebinUpload = argList["-PB"]	-- boolean
local autoExtract    = argList["-e"]	-- boolean
local silent		 = argList["-s"]	-- boolean
local APImode		 = argList["-a"]	-- boolean
local useCompression = argList["-c"]	-- boolean

local inputPath = argList[1]
local outputPath = argList[2] or inputPath

if argList["-h"] or (not inputPath) then
	return showHelp()
end

local mode = fs.isDir(inputPath) and "pack" or "unpack"
local exists = fs.exists(inputPath) -- does not matter if downloading

if (pastebinGet or directDownload) and pastebinUpload then
	printError("Cannot upload and download at the same time!")
	return false
end


local function listAll(path, includePath)
	local output = {}
	local list = fs.list(path)
	local fc = fs.combine
	for i = 1, #list do
		if fs.isDir(fc(path, list[i])) then
			if #fs.list(fc(path, list[i])) == 0 then
				output[#output+1] = includePath and fc(path, fc(path, list[i])) or fc(path, list[i])
			else
				local la = listAll(fc(path, list[i]))
				for ii = 1, #la do
					output[#output+1] = includePath and fc(path, fc(list[i], la[ii])) or fc(list[i], la[ii])
				end
			end
		else
			output[#output+1] = includePath and fc(path, list[i]) or list[i]
		end
	end
	return output
end

local makeFileList = function(path, doCompress)
	local output = {}
	local list = listAll(path, false)
	local file
	if not silent then
		print("Packing files...")
	end
	for i = 1, #list do
		if not silent then
			term.setTextColor(colors.lightGray)
			write("'" .. list[i] .. "'...")
		end
		file = fs.open(fs.combine(path, list[i]), "r")
		output[list[i]] = --textutils.serialize(
			doCompress and compress(file.readAll()) or file.readAll()
		--)
		file.close()
		if not silent then
			term.setTextColor(colors.green)
			print("good")
		end
	end
	if not silent then
		term.setTextColor(colors.white)
	end
	return output
end

local buildArchive = function(path, mainFile, doCompress)
	local output = {
		compressed = doCompress, -- uses CCA compression
		main = mainFile, -- specifies the main program within the archive to run, should I implement something to use that
		data = makeFileList(path, doCompress) -- files and folders and whatnot
	}
	return textutils.serialize(output)
end

local choice = function(input,verbose)
	if not input then
		input = "yn"
	end
	if verbose then
		write("[")
		for a = 1, #input do
			write(input:sub(a,a):upper())
			if a < #input then
				write(",")
			end
		end
		write("]?")
	end
	local evt,char
	repeat
		evt,char = os.pullEvent("char")
	until string.find(input:lower(),char:lower())
	if verbose then
		print(char:upper())
	end
	local pos = string.find(input:lower(),char:lower())
	return pos, char:lower()
end

local archive

if mode == "pack" then
	if exists then
		if pastebinUpload then
			archive = buildArchive(inputPath, mainFile, useCompression)
			if not silent then
				write("Uploading to Pastebin...")
			end
			local key = "0ec2eb25b6166c0c27a394ae118ad829"
			local response = http.post(
				"https://pastebin.com/api/api_post.php",
				"api_option=paste&" ..
				"api_dev_key=" .. key .. "&" ..
				"api_paste_format=lua&" ..
				"api_paste_name=" .. textutils.urlEncode(sName) .. "&" ..
				"api_paste_code=" .. textutils.urlEncode(sText)
			)
			if response then
				print("success!")
				local sResponse = response.readAll()
				response.close()

				local sCode = string.match( sResponse, "[^/]+$" )
				print("Uploaded to '" .. sResponse .. "'.")
				print("Retrieve with \"progdor -pb " .. sCode .. " " .. fs.getName(path) .. "\".")
			else
				print("failed!")
			end
		else
			if outputPath == inputPath then
				fs.delete(outputPath)
			elseif fs.exists(outputPath) then
				write("Overwrite? ")
				if choice("yn", true) == 1 then
					fs.delete(outputPath)
				else
					print("Abort.")
					return
				end
			end
			archive = buildArchive(inputPath, mainFile, useCompression)
			local file = fs.open(outputPath, "w")
			file.write(archive)
			file.close()
			print("Written to '" .. outputPath .. "'.")
		end
	else
		printError("No such input path exists.")
		return false
	end
elseif mode == "unpack" then
	error("spoon")
end
