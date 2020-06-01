--[[
  Gitget for ComputerCraft
 A simple GitHub repo downloader!

   pastebin get TZd5PYgz gitget
                              --]]
local verbose = true

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

local argData = {
	["-b"] = "string",	-- string, branch
	["-s"] = false,		-- boolean, silent
	["-y"] = false,		-- boolean, automatically accept to overwrite
}

-- this token has only enough permissions to download files, so don't get any ideas
local token = "0f7e97e6524dcb03f79978ff88235a510f5ff4ae"

local argList = interpretArgs({...}, argData)

local reponame = argList[1]
local repopath = argList[2]
local outpath = argList[3] or ""

local branch = argList["-b"] or "master"
local silent = argList["-s"] or false
local autoOverwrite = argList["-y"]

if outpath:sub(1,1) ~= "/" then
	outpath = fs.combine(shell.dir(), outpath)
end

--thank you ElvishJerricco
local controls = {["\n"]="\\n", ["\r"]="\\r", ["\t"]="\\t", ["\b"]="\\b", ["\f"]="\\f", ["\""]="\\\"", ["\\"]="\\\\"}
local function isArray(t)
	local max = 0
	for k,v in pairs(t) do
		if type(k) ~= "number" then
			return false
		elseif k > max then
			max = k
		end
	end
	return max == #t
end
local whites = {['\n']=true; ['\r']=true; ['\t']=true; [' ']=true; [',']=true; [':']=true}
function removeWhite(str)
	while whites[str:sub(1, 1)] do str = str:sub(2) end return str
end
local function encodeCommon(val, pretty, tabLevel, tTracking)
	local str = ""
	local function tab(s)
		str = str .. ("\t"):rep(tabLevel) .. s
	end
	local function arrEncoding(val, bracket, closeBracket, iterator, loopFunc)
		str = str .. bracket
		if pretty then
			str = str .. "\n"
			tabLevel = tabLevel + 1
		end
		for k,v in iterator(val) do
			tab("")
			loopFunc(k,v)
			str = str .. ","
			if pretty then str = str .. "\n" end
		end
		if pretty then tabLevel = tabLevel - 1 end
		if str:sub(-2) == ",\n" then str = str:sub(1, -3) .. "\n"
		elseif str:sub(-1) == "," then str = str:sub(1, -2) end
		tab(closeBracket)
	end
	if type(val) == "table" then
		assert(not tTracking[val], "Cannot encode a table holding itself recursively")
		tTracking[val] = true
		if isArray(val) then
			arrEncoding(val, "[", "]", ipairs, function(k,v)
				str = str .. encodeCommon(v, pretty, tabLevel, tTracking)
			end)
		else
			arrEncoding(val, "{", "}", pairs, function(k,v)
				assert(type(k) == "string", "JSON object keys must be strings", 2)
				str = str .. encodeCommon(k, pretty, tabLevel, tTracking)
				str = str .. (pretty and ": " or ":") .. encodeCommon(v, pretty, tabLevel, tTracking)
			end)
		end
	elseif type(val) == "string" then str = '"' .. val:gsub("[%c\"\\]", controls) .. '"'
	elseif type(val) == "number" or type(val) == "boolean" then str = tostring(val)
	else error("JSON only supports arrays, objects, numbers, booleans, and strings", 2) end
	return str
end
local function encode(val)
	return encodeCommon(val, false, 0, {})
end
local function encodePretty(val)
	return encodeCommon(val, true, 0, {})
end
local decodeControls = {}
for k,v in pairs(controls) do
	decodeControls[v] = k
end
local function parseBoolean(str)
	if str:sub(1, 4) == "true" then
		return true, removeWhite(str:sub(5))
	else
		return false, removeWhite(str:sub(6))
	end
end
local function parseNull(str)
	return nil, removeWhite(str:sub(5))
end
local numChars = {['e']=true; ['E']=true; ['+']=true; ['-']=true; ['.']=true}
local function parseNumber(str)
	local i = 1
	while numChars[str:sub(i, i)] or tonumber(str:sub(i, i)) do
		i = i + 1
	end
	local val = tonumber(str:sub(1, i - 1))
	str = removeWhite(str:sub(i))
	return val, str
end
local function parseString(str)
	str = str:sub(2)
	local s = ""
	while str:sub(1,1) ~= "\"" do
		local next = str:sub(1,1)
		str = str:sub(2)
		assert(next ~= "\n", "Unclosed string")

		if next == "\\" then
			local escape = str:sub(1,1)
			str = str:sub(2)

			next = assert(decodeControls[next..escape], "Invalid escape character")
		end

		s = s .. next
	end
	return s, removeWhite(str:sub(2))
end
local parseValue, parseMember
local function parseArray(str)
	str = removeWhite(str:sub(2))
	local val = {}
	local i = 1
	while str:sub(1, 1) ~= "]" do
		local v = nil
		v, str = parseValue(str)
		val[i] = v
		i = i + 1
		str = removeWhite(str)
	end
	str = removeWhite(str:sub(2))
	return val, str
end
local function parseObject(str)
	str = removeWhite(str:sub(2))
	local val = {}
	while str:sub(1, 1) ~= "}" do
		local k, v = nil, nil
		k, v, str = parseMember(str)
		val[k] = v
		str = removeWhite(str)
	end
	str = removeWhite(str:sub(2))
	return val, str
end
function parseMember(str)
	local k = nil
	k, str = parseValue(str)
	local val = nil
	val, str = parseValue(str)
	return k, val, str
end
function parseValue(str)
	local fchar = str:sub(1, 1)
	if fchar == "{" then
		return parseObject(str)
	elseif fchar == "[" then
		return parseArray(str)
	elseif tonumber(fchar) ~= nil or numChars[fchar] then
		return parseNumber(str)
	elseif str:sub(1, 4) == "true" or str:sub(1, 5) == "false" then
		return parseBoolean(str)
	elseif fchar == "\"" then
		return parseString(str)
	elseif str:sub(1, 4) == "null" then
		return parseNull(str)
	end
	return nil
end
local function decode(str)
	str = removeWhite(str)
	t = parseValue(str)
	return t
end

local writeToFile = function(filename, contents)
	local file = fs.open(filename,"w")
	file.write(contents)
	file.close()
end

local sPrint = function(str)
	if not silent then
		return print(str)
	end
end

local getFromGitHub
getFromGitHub = function(reponame, repopath, filepath, verbose)
	local jason = http.get("https://api.github.com/repos/" .. reponame .. "/contents/" .. (repopath or ""), {
		["Authorization"] = token
	})
	if not jason then return false end
	local repo = decode(jason.readAll())
	for k,v in pairs(repo) do
		if v.message then
			return false
		else
			if v.type == "file" then
				if verbose then
					sPrint("'" .. fs.combine(filepath, v.name) .. "'")
				end
				writeToFile(fs.combine(filepath, v.name), http.get(v.download_url).readAll())
			elseif v.type == "dir" then
				if verbose then
					sPrint("'" .. fs.combine(filepath,v.name) .. "'")
				end
				fs.makeDir(fs.combine(filepath, v.name))
				getFromGitHub(reponame, fs.combine(repopath, v.name), fs.combine(filepath, v.name), verbose)
			end
		end
	end
end

local displayHelp = function()
	local progname = fs.getName(shell.getRunningProgram())
	sPrint(progname .. " [owner/repo] [repopath] [output dir]")
	sPrint(" -b [branch]")
	sPrint(" -s | runs silent unless asking to overwrite")
	sPrint(" -y | overwrites without asking")
end

if not (reponame and repopath and outpath) then
	return displayHelp()
else
	if fs.exists(outpath) and not fs.isDir(outpath) then
		if autoOverwrite then
			fs.delete(outpath)
			sPrint("Overwritten '" .. outpath .. "'.")
		else
			print("'" .. outpath .. "' already exists!")
			print("Overwrite? (Y/N)")
			local evt,key
			while true do
				evt, key = os.pullEvent("key")
				if key == keys.y then
					if (not fs.isDir(outpath)) then
						fs.delete(outpath)
					end
					break
				elseif key == keys.n then
					print("Abort.")
					coroutine.yield()
					return
				end
			end
		end
	end
	repopath = (repopath == "*") and "" or repopath
	local oldtxt = (term.getTextColor and term.getTextColor()) or colors.white
	sPrint("Downloading...")
	term.setTextColor(term.isColor() and colors.green or colors.lightGray)
	getFromGitHub(reponame, repopath, outpath, verbose)
	term.setTextColor(oldtxt)
	sPrint("Downloaded to /" .. fs.combine("", outpath))
end
