--[[
	Progdor 2.0 - File Packaging
	by LDDestroier
	Get with:
	 wget https://raw.githubusercontent.com/LDDestroier/CC/master/progdor2.lua

	Uses CCA compression API, made by minizbot2012.
--]]

local progdor = {
	version = "2.0",
	PBlogPath = ".progdor_PB_uploads",
	channel = 8366,
	skynetPath = "skynet.lua",
	skynetURL = "https://github.com/osmarks/skynet/raw/master/client.lua"
}

local scr_x, scr_y = term.getSize()
local modem = peripheral.find("modem")
local skynet, skynetBigReceive, skynetBigSend

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
			if entry then -- exists in dictionary
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
local function strCompress(input)
	local output = {}
	local tbl = compress(input)
	for i = 1, #tbl do
		output[i] = string.char(tbl[i])
	end
	return table.concat(output)
end
local function strDecompress(input)
	local output = {}
	for i = 1, #input do
		output[i] = string.byte(input:sub(i,i))
	end
	return decompress(output)
end
-- CCA API END --

-- colors that are always safe to set to
local safeColorList = {
	[colors.white] = true,
	[colors.lightGray] = true,
	[colors.gray] = true,
	[colors.black] = true
}

-- pastebin uploads have a 512K limit
local pastebinFileSizeLimit = 1024 * 512

local argData = {
	["-pb"] = "string",		-- pastebin get
	["-dd"] = "string",		-- direct URL download
	["-m"] = "string",		-- specify main file
	["-PB"] = false,		-- pastebin upload
	["-t"] = false,			-- transmit file
	["-r"] = false,			-- receive file
	["-R"] = false,			-- include read-only files
	["-P"] = false,			-- include Progdor2 file
	["-S"] = false,			-- use skynet
	["-e"] = false,			-- automatic self-extractor
	["-E"] = "string",		-- specify output folder in self-extractor code
	["-s"] = false,			-- silent
	["-a"] = false,			-- use as API with require, also makes silent
	["-c"] = false,			-- use CCA compression
	["-h"] = false,			-- show help
	["-i"] = false,			-- inspect mode
	["-o"] = false,			-- always overwrite
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

local pastebinGet    		= argList["-pb"] -- string, pastebin code
local directDownload 		= argList["-dd"] -- string, download URL
local mainFile		 		= argList["-m"]  -- string, main executable file
local pastebinUpload 		= argList["-PB"] -- boolean
local selfExtractor	 		= argList["-e"]  -- boolean
local selfExtractorFolder 	= argList["-E"]  -- string, folder output for self extractor code
local silent		 		= argList["-s"]  -- boolean
local useCompression 		= argList["-c"]  -- boolean
local justOverwrite	 		= argList["-o"]  -- boolean
local allowReadOnly  		= argList["-R"]  -- boolean
local allowPackPD	 		= argList["-P"]  -- boolean
local useSkynet		 		= argList["-S"]  -- boolean
local trMode		 		= argList["-t"] and "transmit" or (argList["-r"] and "receive" or "normal")

local skynet

if useCompression and selfExtract then
	error("Cannot use compression with self-extractor.")
end

local sWrite = function(text)
	if not silent then
		return write(text)
	end
end

local sPrint = function(text)
	if not silent then
		return print(text)
	end
end

local cWrite = function(text, color, ignoreSilent)
	local col = term.getTextColor()
	term.setTextColor(color or col)
	if ignoreSilent then
		write(text)
	else
		sWrite(text)
	end
	term.setTextColor(col)
end

local cPrint = function(text, color, ignoreSilent)
	local col = term.getTextColor()
	term.setTextColor(color or col)
	if ignoreSilent then
		print(text)
	else
		sPrint(text)
	end
	term.setTextColor(col)
end

local function showHelp(verboseHelp)
	local helpInfo
	if verboseHelp then
		helpInfo = {
			"Progdor v" .. progdor.version,
			" -pb [pastebin ID] : Download from Pastebin.",			-- added
			" -PB : Upload to pastebin.",							-- added
			" -dd [download URL] : Download from URL.",				-- added
			" -e : Adds on self-extractor code to archive.",		-- added
			" -E [folder] : Extractor extracts to folder",			-- added
			" -s : Silences all terminal writing",					-- added
			" -S : Use skynet when transmitting/receiving.",		-- added
			" -t : Transmit a folder/file.",						-- added
			" -r : Receive a file/packed folder.",					-- added
			" -R : Allow packing read-only files/folders.",			-- added
			" -P : Allow packing in Progdor2 itself.",				-- added
			" -a : Allows programs to use require() on Progdor.",	-- added
			" -c : Enables CCA compression.",						-- added
			" -m : Specify main executable file in archive.",		-- added
			" -i : Inspect archive without extracting.",			-- added
			" -o : Overwrite files without asking.",				-- added
		}
	else
		helpInfo = {
			"Progdor v" .. progdor.version,
			"Usage: progdor [options] inputFolder (outputFile)",
			"       progdor [options] inputFile (outputFolder)",
			"",
			"Progdor is a file/folder packaging program with support for CCA compression and self-extraction.",
			"  If tacking on auto-extractor, a third argument will be the default extraction path.",
			"",
			"Use -h for all options.",
			"",
			"   This Progdor has Super Cow Powers."					-- not actually added
		}
	end
	for y = 1, #helpInfo do
		sPrint(helpInfo[y])
	end
end

local setTextColor = function(color)
	if (not silent) and (term.isColor() or safeColorList[color]) then
		term.setTextColor(color)
	end
end

local setBackgroundColor = function(color)
	if (not silent) and (term.isColor() or safeColorList[color]) then
		term.setBackgroundColor(color)
	end
end

local inputPath = argList[1]
local outputPath = argList[2] or inputPath
local defaultAutoExtractPath = argList[3]
local exists, mode

if inputPath == "moo" and not fs.exists(inputPath) then
	print([[
                     \_/
   m00h  (__)       -(_)-
      \  ~Oo~___     / \
         (..)  |\
___________|_|_|_____________
..."Have you mooed today?"..."]])
	return
end

if argList["-h"] then
	return showHelp(true)
elseif argList["-a"] or (not shell) then
	mode = "api"
elseif inputPath then
	exists = fs.exists(inputPath)
	if argList["-i"] then
		mode = "inspect"
	elseif fs.isDir(inputPath) then
		mode = "pack"
	else
		mode = "unpack"
	end
elseif trMode ~= "receive" then
	return showHelp(false)
end

if mode == "api" then
	silent = true
elseif (pastebinGet or directDownload) and pastebinUpload then
	error("Cannot upload and download at the same time!")
end

local specialWrite = function(left, colored, right, color)
	local origTextColor = term.getTextColor()
	sWrite(left)
	setTextColor(color)
	sWrite(colored)
	setTextColor(origTextColor)
	sWrite(right)
end

local specialPrint = function(left, colored, right, color)
	return specialWrite(left, colored, right .. "\n", color)
end

local function listAll(path, includePath)
	local output = {}
	local list = fs.list(path)
	local fc = fs.combine
	for i = 1, #list do
		if allowReadOnly or (not fs.isReadOnly(fc(path, list[i]))) then
			if allowPackPD or fc(path, list[i]) ~= (shell and shell.getRunningProgram()) then
				if fs.isDir(fc(path, list[i])) then
					if #fs.list(fc(path, list[i])) == 0 then
						output[#output+1] = (includePath and fc(path, list[i]) or list[i]) .. "/"
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
		end
	end
	return output
end

local makeFileList = function(path, doCompress)
	local output = {}
	local list = listAll(path, false)
	local file
	if not allowPackPD then
		cPrint("Ignoring Progdor2.", colors.lightGray)
	end
	if not allowReadOnly then
		cPrint("Ignoring read-only files.", colors.lightGray)
	end
	sPrint("Packing files...")
	for i = 1, #list do
		setTextColor(colors.lightGray)
		sWrite("'" .. list[i] .. "'...")
		if list[i]:sub(-1,-1) == "/" then
			output[list[i]] = true -- indicates empty directory
		else
			file = fs.open(fs.combine(path, list[i]), "r")
			output[list[i]] = doCompress and strCompress(file.readAll()) or file.readAll()
			file.close()
			setTextColor(colors.green)
			sPrint("good")
		end
	end
	setTextColor(colors.white)
	return output
end

local buildArchive = function(path, mainFile, doCompress)
	local output = {
		compressed = doCompress, -- uses CCA compression
		mainFile = mainFile, -- specifies the main program within the archive to run, should I implement something to use that
		data = makeFileList(path, doCompress) -- files and folders and whatnot
	}
	return textutils.serialize(output)
end

local parseArchiveData = function(input, doNotDecompress)
	local archive = textutils.unserialize(input)
	if archive then
		if archive.compressed and (not doNotDecompress) then
			for name, contents in pairs(archive.data) do
				archive.data[name] = strDecompress(contents)
			end
			archive.compressed = false
		end
		return archive
	else
		return false
	end
end

local parseArchive = function(path, doNotDecompress)
	local file = fs.open(path, "r")
	local output = parseArchiveData(file.readAll(), doNotDecompress)
	file.close()
	return output
end

local round = function(number, places)
	return math.floor(number * (10^places)) / (10^places)
end

local choice = function(input,verbose)
	if not input then
		input = "yn"
	end
	if verbose then
		sWrite("[")
		for a = 1, #input do
			sWrite(input:sub(a,a):upper())
			if a < #input then
				sWrite(",")
			end
		end
		sWrite("]?")
	end
	local evt,char
	repeat
		evt,char = os.pullEvent("char")
	until string.find(input:lower(),char:lower())
	if verbose then
		sPrint(char:upper())
	end
	local pos = string.find(input:lower(), char:lower())
	return pos, char:lower()
end

local overwriteOutputPath = function(inputPath, outputPath, allowMerge, override)
	setTextColor(colors.white)
	local c
	if override then
		return true, true
	else
		if allowMerge then
			write("Overwrite [Y/N]? Or [M]erge? ")
			c = choice("ynm", false)
		else
			write("Overwrite [Y/N]?")
			c = choice("yn", false)
		end
		write("\n")
		if c == 1 then
			return true, true
		elseif c == 2 then
			sPrint("Abort.")
			return false, false
		elseif c == 3 then
			return true, false
		end
	end
end

local uploadToPastebin = function(archive, name)
	if #archive > pastebinFileSizeLimit then
		error("That archive is too large to be uploaded to Pastebin. (limit is 512 KB)")
		return false
	else
		local key = "0ec2eb25b6166c0c27a394ae118ad829"
		local response = http.post(
			"https://pastebin.com/api/api_post.php",
			"api_option=paste&" ..
			"api_dev_key=" .. key .. "&" ..
			"api_paste_format=lua&" ..
			"api_paste_name=" .. textutils.urlEncode(name) .. "&" ..
			"api_paste_code=" .. textutils.urlEncode(archive)
		)
		if response then
			local sResponse = response.readAll()
			response.close()

			local sCode = string.match( sResponse, "[^/]+$" )
			return sCode, sResponse
		else
			return false
		end
	end
end

local writeArchiveData = function(archive, outputPath)
	local file
	for name, contents in pairs(archive.data) do
		setTextColor(colors.lightGray)
		sWrite("'" .. name .. "'...")
		if contents == true then -- indicates empty directory
			fs.makeDir(fs.combine(outputPath, name))
		else
			file = fs.open(fs.combine(outputPath, name), "w")
			if file then
				file.write(contents)
				file.close()
			end
		end
		if file then
			setTextColor(colors.green)
			sPrint("good")
		else
			setTextColor(colors.red)
			sPrint("fail")
		end
	end
	setTextColor(colors.white)
	specialPrint("Unpacked to '", outputPath .. "/", "'.", colors.yellow)
end

local getSkynet = function()
	if http.websocket then
		-- Skynet only supports messages that are 65506 bytes or smaller
		-- I'm just going with 65200 bytes to play safe.
		local defineBigOnes = function(skynet)
			local div = 65200
			return function(channel, _message)	-- big send
				local message = textutils.serialize(_message)
				for i = 1, math.ceil(#message / div) do
					skynet.send(progdor.channel, {
						msg = message:sub( (i - 1) * div + 1, i * div ),
						complete = i == math.ceil(#message / div),
						part = i
					})
					sleep(0.1)
					cWrite(".", colors.lightGray)
				end
			end, function(channel)				-- big receive
				local ch, msg
				local output = {}
				local gotFile = false
				while true do
					ch, msg = skynet.receive(channel)
					if type(msg) == "table" then
						if type(msg.complete) == "boolean" and type(msg.msg) == "string" and type(msg.part) == "number" then
							output[msg.part] = msg.msg
							cWrite(".", colors.lightGray)
							if msg.complete then
								break
							end
						end
					end
				end
				return channel, textutils.unserialize(table.concat(output))
			end
		end
		if skynet then
			local bS, bR = defineBigOnes(skynet)
			skynet.open(progdor.channel)
			return skynet, "", bS, bR
		else
			if fs.exists(progdor.skynetPath) then
				local sn = dofile(progdor.skynetPath)
				sn.open(progdor.channel)
				local bS, bR = defineBigOnes(sn)
				return sn, "", bS, bR
			else
				local net, contents = http.get(progdor.skynetURL)
				if net then
					contents = net.readAll()
					local file = fs.open(progdor.skynetPath, "w")
					file.write(contents)
					file.close()
					local sn = dofile(progdor.skynetPath)
					local bS, bR = defineBigOnes(sn)
					sn.open(progdor.channel)
					return sn, "", bS, bR
				else
					return false, "Couldn't download Skynet."
				end
			end
		end
	else
		return false, "This version of CC does not support Skynet."
	end
end

local getModem = function()
	local mod = peripheral.find("modem")
	if mod then
		mod.open(progdor.channel)
		return mod
	else
		return false, "No modem was found."
	end
end

local archive
local doOverwrite, doContinue = false, true

--[[ JUST SUMMIN' UP THE ELSEIF CHAIN
	if mode == "api" then
	elseif trMode == "transmit" then
		if mode == "pack" then
		end
	elseif trMode == "receive" then
		if mode == "pack" then
		end
	elseif mode == "pack" then
	elseif mode == "unpack" then
	elseif mode == "inspect" then
	end
--]]

-- API mode takes top priority
if mode == "api" then

	return {
		parseArchive = parseArchive,
		parseArchiveData = parseArchiveData,
		buildArchive = buildArchive,
		uploadToPastebin = uploadToPastebin,
	}

-- after that, trans
elseif trMode == "transmit" then

	-- assemble something to send
	local output = {name = fs.getName(inputPath)}
	if mode == "pack" then
		output.contents = textutils.serialize(buildArchive(inputPath, mainFile, useCompression))
	else
		local file = fs.open(inputPath, "r")
		output.contents = file.readAll()
		file.close()
	end

	local grr
	if useSkynet then
		if not skynet then
			cWrite("Connecting to Skynet...", colors.lightGray)
			skynet, grr, skynetBigSend, skynetBigReceive = getSkynet()
			if not skynet then
				print(grr)
				print("Aborting.")
				return false
			else
				cPrint("good", colors.green)
			end
		end
		cWrite("Sending file...", colors.lightGray)
		skynetBigSend(progdor.channel, output)
		skynet.socket.close()
		cPrint("good", colors.green)
		sWrite("Sent '")
		cWrite(fs.getName(inputPath), colors.yellow)
		sPrint("' using Skynet.")
	else
		modem, grr = getModem()
		if not modem then
			print(grr)
			print("Abort.")
			return false
		end
		cWrite("Sending file...", colors.lightGray)
		modem.transmit(progdor.channel, progdor.channel, output)
		cPrint("good", colors.green)
		sWrite("Sent '")
		cWrite(fs.getName(inputPath), colors.yellow)
		sPrint("' using modem.")
	end

elseif trMode == "receive" then
	local grr
	local gotFile = false
	local input, channel
	local didAbort = false
	if useSkynet then
		if not skynet then
			cWrite("Connecting to Skynet...", colors.lightGray)
			skynet, grr, skynetBigSend, skynetBigReceive = getSkynet()
			if not skynet then
				print(grr)
				print("Aborting.")
				return false
			else
				cPrint("good", colors.green)
			end
		end
		cWrite("Waiting for file on Skynet...", colors.lightGray)
		local result, grr = pcall(function()
			sleep(0.05)
			while true do
				if parallel.waitForAny(function()
					channel, input = skynetBigReceive(progdor.channel)
				end, function()
					local evt
					while true do
						evt = {os.pullEvent()}
						if evt[1] == "key" then
							if evt[2] == keys.q then
								return
							end
						end
					end
				end) == 2 then
					print("\nAbort.")
					sleep(0.05)
					didAbort = true
					break
				end
				if channel == progdor.channel and type(input) == "table" then
					if type(input.contents) == "string" and type(input.name) == "string" then
						gotFile = true
						break
					end
				end
			end
		end)
		skynet.socket.close()
		if not result then
			error(grr, 0)
		end
	else
		modem, grr = getModem()
		if not modem then
			print(grr)
			print("Abort.")
			sleep(0.05)
			return false
		end
		modem.open(progdor.channel)
		local evt
		cWrite("Waiting for file...", colors.lightGray)
		sleep(0.05)
		while true do
			evt = {os.pullEvent()}
			if evt[1] == "modem_message" then
				if evt[3] == progdor.channel and type(evt[5]) == "table" then
					if type(evt[5].contents) == "string" and type(evt[5].name) == "string" then
						input = evt[5]
						gotFile = true
						break
					end
				end
			elseif evt[1] == "key" then
				if evt[2] == keys.q then
					print("\nAbort.")
					sleep(0.05)
					didAbort = true
					break
				end
			end
		end
	end

	if gotFile then
		cPrint("good", colors.green)
		if input.contents then
			local writePath, c = fs.combine(shell.dir(), outputPath or input.name)
			write("Received '")
			cWrite(input.name or outputPath, colors.yellow, true)
			print("'.")
			if (not justOverwrite and fs.exists(writePath)) or fs.isReadOnly(writePath) then
				write("\nBut, '")
				cWrite(fs.getName(writePath), colors.yellow, true)
				print("' is already there.")
				local roCount = 0
				local showROmessage = function(roCount)
					if roCount == 1 then
						write("\nThat file/folder is ")
						cWrite("read-only", colors.yellow, true)
						print("!")
					elseif roCount == 2 then
						write("\nI told you, that file/folder is ")
						cWrite("read-only", colors.yellow, true)
						print("!")
					elseif roCount == 3 then
						write("\nNope. The file/folder is ")
						cWrite("read-only", colors.yellow, true)
						print(".")
					elseif roCount == 4 then
						write("\nDoes the phrase ")
						cWrite("read-only", colors.yellow, true)
						print(" mean nothing to you?")
					elseif roCount == 5 then
						print("\nAlright wise-ass, that's enough.")
					elseif roCount > 5 then
						write("\nThat's ")
						cWrite("read-only", colors.yellow, true)
						print(", damn you!")
					end
				end
				while true do
					sleep(0.05)
					if roCount < 5 then
						write("Overwrite [Y/N]? Or [R]ename?\n")
						c = choice("nry", false)
					else
						write("Overwrite [ /N]? Or [R]ename?\n")
						c = choice("nr", false)
					end
					if c == 3 then
						if fs.isReadOnly(writePath) then
							roCount = roCount + 1
							showROmessage(roCount)
						else
							break
						end
					elseif c == 1 then
						print("Abort.")
						return false
					elseif c == 2 then
						print("New name:")
						if shell.dir() == "" then
							write("/")
						else
							write("/" .. shell.dir() .. "/")
						end
						writePath = fs.combine(shell.dir(), read())
						roCount = roCount + 1
						if fs.isReadOnly(writePath) then
							showROmessage(roCount)
						else
							break
						end
					end
				end
			end
			local file = fs.open(writePath, "w")
			file.write(input.contents)
			file.close()
			sWrite("Wrote to '")
			cWrite(writePath, colors.yellow)
			sPrint("'")
		end
	elseif not didAbort then
		print("fail!")
	end

elseif mode == "pack" then

	if not pastebinUpload then
		if fs.isReadOnly(outputPath) then
			error("Output path is read-only.")
		elseif fs.exists(outputPath) and (outputPath ~= inputPath) then
			doContinue, doOverwrite = overwriteOutputPath(inputPath, outputPath, false, justOverwrite)
		elseif fs.combine("", outputPath) == "" then
			error("Output path cannot be root.")
		end
		if not doContinue then
			return false
		elseif outputPath == inputPath then
			doOverwrite = true
		end
	end
	archive = buildArchive(inputPath, mainFile, useCompression)
	if exists then
		if useCompression then
			sPrint("Using CCA compression.")
		elseif selfExtractor then
			sPrint("Tacking on self-extractor.")
			archive = ([[
local tArg = {...}
local selfDelete = false -- if true, deletes extractor after running
local file
local outputPath = ]] ..

(selfExtractorFolder and (
	"shell.resolve(\"" .. selfExtractorFolder .. "\")"
) or (
	"tArg[1] and shell.resolve(tArg[1]) or " .. ((defaultAutoExtractPath and ("\"" .. defaultAutoExtractPath .. "\"")) or "shell.getRunningProgram()")
)) .. [[

local safeColorList = {[colors.white] = true,[colors.lightGray] = true,[colors.gray] = true,[colors.black] = true}
local stc = function(color) if (term.isColor() or safeColorList[color]) then term.setTextColor(color) end end
local choice = function()
	local input = "yn"
	write("[")
	for a = 1, #input do
		write(input:sub(a,a):upper())
		if a < #input then
			write(",")
		end
	end
	print("]?")
	local evt,char
	repeat
		evt,char = os.pullEvent("char")
	until string.find(input:lower(),char:lower())
	if verbose then
		print(char:upper())
	end
	local pos = string.find(input:lower(), char:lower())
	return pos, char:lower()
end
local archive = textutils.unserialize(]] ..

textutils.serialize(archive) ..

[[)
if fs.isReadOnly(outputPath) then
	error("Output path is read-only. Abort.")
elseif fs.getFreeSpace(outputPath) <= #archive then
	error("Insufficient space. Abort.")
end

]] .. ( justOverwrite and [[
if fs.exists(outputPath) and fs.combine("", outputPath) ~= "" then
	fs.delete(outputPath)
end
]] or [[
if fs.exists(outputPath) and fs.combine("", outputPath) ~= "" then
	print("File/folder already exists! Overwrite?")
	stc(colors.lightGray)
	print("(Use -o when making the extractor to always overwrite.)")
	stc(colors.white)
	if choice() ~= 1 then
		error("Chose not to overwrite. Abort.")
	else
		fs.delete(outputPath)
	end
end
]]
) ..
[[
if selfDelete or (fs.combine("", outputPath) == shell.getRunningProgram()) then
	fs.delete(shell.getRunningProgram())
end
for name, contents in pairs(archive.data) do
	stc(colors.lightGray)
	write("'" .. name .. "'...")
	if contents == true then -- indicates empty directory
		fs.makeDir(fs.combine(outputPath, name))
	else
		file = fs.open(fs.combine(outputPath, name), "w")
		if file then
			file.write(contents)
			file.close()
		end
	end
	if file then
		stc(colors.green)
		print("good")
	else
		stc(colors.red)
		print("fail")
	end
end
stc(colors.white)
write("Unpacked to '")
stc(colors.yellow)
write(outputPath .. "/")
stc(colors.white)
print("'.")
]])

		end
		if pastebinUpload then
			sWrite("Uploading to Pastebin...")
			local id, url = uploadToPastebin(archive, fs.getName(inputPath))
			if id then
				setTextColor(colors.green)
				sPrint("success!")
				setTextColor(colors.white)
				sPrint("Uploaded to '" .. url .. "'.")
				specialPrint("Retrieve with \"", "progdor -pb " .. id .. " " .. fs.getName(inputPath), "\".", colors.yellow)
				sPrint("You may need to do a Captcha on the website.")
				if not fs.exists(progdor.PBlogPath) then
					setTextColor(colors.lightGray)
					specialPrint("(PB uploads are logged at \"", progdor.PBlogPath, "\".)", colors.yellow)
					setTextColor(colors.white)
				end
				-- precautionary log file
				local file = fs.open(progdor.PBlogPath, "a")
				file.writeLine("uploaded \"" .. inputPath .. "\" to \"" .. url .. "\"")
				file.close()
			else
				sPrint("failed!")
			end
		else
			if doOverwrite then
				fs.delete(outputPath)
			end
			local file = fs.open(outputPath, "w")
			file.write(archive)
			file.close()
			if selfExtract then
				specialPrint("Written self-extractor to '", outputPath, "'.", colors.yellow)
			else
				specialPrint("Written to '", outputPath, "'.", colors.yellow)
			end
		end
	else
		error("No such input path exists.")
		return false
	end

elseif mode == "unpack" then -- unpack OR upload

	if pastebinUpload then
		local file = fs.open(inputPath, "r")
		archive = file.readAll()
		file.close()
		sWrite("Uploading to Pastebin...")
		local id, url = uploadToPastebin(archive, fs.getName(inputPath))
		if id then
			setTextColor(colors.green)
			sPrint("success!")
			setTextColor(colors.white)
			sPrint("Uploaded to '" .. url .. "'.")
			specialPrint("Retrieve with \"", "progdor -pb " .. id .. " " .. fs.getName(inputPath), "\".", colors.yellow)
			sPrint("You may need to do a Captcha on the website.")
			if not fs.exists(progdor.PBlogPath) then
				setTextColor(colors.lightGray)
				specialPrint("(PB uploads are logged at \"", progdor.PBlogPath, "\".)", colors.yellow)
				setTextColor(colors.white)
			end
			-- precautionary log file
			local file = fs.open(progdor.PBlogPath, "a")
			file.writeLine("uploaded \"" .. inputPath .. "\" to \"" .. url .. "\"")
			file.close()
		else
			setTextColor(colors.red)
			sPrint("failed!")
			setTextColor(colors.white)
			return false
		end
	elseif pastebinGet or directDownload then
		local url, contents
		if pastebinGet and directDownload then
			error("Cannot do both pastebin get and direct download.")
		elseif fs.isReadOnly(outputPath) then
			error("Output path is read-only.")
		elseif fs.combine(outputPath, "") == "" then
			error("Output path cannot be root.")
		else
			if pastebinGet then
				url = "http://www.pastebin.com/raw/" .. pastebinGet
			elseif directDownload then
				url = directDownload
			end
			if fs.exists(outputPath) and (outputPath ~= inputPath) or outputPath == shell.getRunningProgram() then
				doContinue, doOverwrite = overwriteOutputPath(inputPath, outputPath, true, justOverwrite)
			end
			if not doContinue then
				return false
			elseif outputPath == inputPath then
				doOverwrite = true
			end
			sWrite("Connecting to \"")
			setTextColor(colors.yellow)
			sWrite(url)
			setTextColor(colors.white)
			sWrite("\"...")
			local handle = http.get(url)
			if handle then
				cPrint("success!", colors.green)
				contents = handle.readAll()
				handle.close()

				-- detects if you didn't solve the captcha, since archives commonly trigger anti-spam measures
				if (
					pastebinGet and
					(not textutils.unserialize(contents)) and
					contents:find("Your paste has triggered our automatic SPAM detection filter.")
				) then
					specialPrint("You must go to '", url, "' and do the Captcha to be able to download that paste.", colors.yellow)
					return false
				end

				setTextColor(colors.lightGray)
				sWrite("Parsing archive...")
				archive = parseArchiveData(contents)
				if archive then
					setTextColor(colors.green)
					sPrint("good")
				else
					setTextColor(colors.red)
					sPrint("Invalid archive file.")
					return false
				end
				if doOverwrite then
					fs.delete(outputPath)
				end
				writeArchiveData(archive, outputPath)
			else
				setTextColor(colors.red)
				sPrint("failed!")
				setTextColor(colors.white)
				return false
			end
		end
	else -- regular unpack
		if exists then
			if fs.isReadOnly(outputPath) then
				error("Output path is read-only.")
			elseif fs.exists(outputPath) and (outputPath ~= inputPath) or outputPath == shell.getRunningProgram() then
				doContinue, doOverwrite = overwriteOutputPath(inputPath, outputPath, true, justOverwrite)
			end
			if not doContinue then
				return false
			elseif outputPath == inputPath then
				doOverwrite = true
			end
			setTextColor(colors.lightGray)
			sWrite("Parsing archive...")
			archive = parseArchive(inputPath)
			if archive then
				setTextColor(colors.green)
				sPrint("good")
				if doOverwrite then
					fs.delete(outputPath)
				end
				writeArchiveData(archive, outputPath)
			else
				setTextColor(colors.red)
				sPrint("Invalid archive file.")
				return false
			end
		else
			error("No such input path exists.")
		end
	end

elseif mode == "inspect" then

	if exists and (not fs.isDir(inputPath)) then
		archive = parseArchive(inputPath, true)
		local totalSize = 0
		local amountOfFiles = 0
		local averageSize = 0

		local output = {}

		if archive then
			for k,v in pairs(archive) do
				if k == "data" then
					for name, contents in pairs(v) do
						if contents then -- don't count directories, where contents == false
							totalSize = totalSize + #contents
							amountOfFiles = amountOfFiles + 1
						end
					end
					averageSize = math.ceil(totalSize / amountOfFiles)
				else
					output[#output + 1] = k .. " = \"" .. tostring(v) .. "\""
				end
			end
			sPrint("# of files: " .. amountOfFiles)
			sPrint("Total size: " .. totalSize .. " bytes (" .. round(totalSize / 1024, 1) .. " KB)")
			sPrint("Aveg. size: " .. averageSize .. " bytes (" .. round(averageSize / 1024, 1) .. " KB)")
			sPrint(("-"):rep(scr_x))
			for i = 1, #output do
				sPrint(output[i])
			end
		else
			error("Invalid archive file.")
		end
	else
		if fs.isDir(inputPath) then
			error("Cannot inspect directories.")
		else
			error("No such input path exists.")
		end
	end

end
