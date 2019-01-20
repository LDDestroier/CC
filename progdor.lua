--[[
 PROGDOR file bundling program

Download with:
 pastebin get YXx5jjMV progdor
 std ld progdor progdor

This is a stable release. You fool!
--]]

local doCompress = false --even if this is false, it will decompress compressed files. nifty, huh?

local doPastebin = false
local tArg = {...}
local input, outpath
if tArg[1] == "-p" then --the p is for pastebin
	doPastebin = true
	input = tArg[2]
	outpath = tArg[3]
else
	input = tArg[1]
	outpath = tArg[2]
end

local progdor = fs.getName(shell.getRunningProgram())
local dir = shell.dir()
local displayHelp = function()
	local txt = progdor.." <input> [output]\nCompression is "..tostring(doCompress):upper().."."
	return print(txt)
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

local fixstr = function(str)
	return str:gsub("\\(%d%d%d)",string.char)
end

local explode = function(div,str)
    if (div=='') then return false end
    local pos,arr = 0,{}
    for st,sp in function() return string.find(str,div,pos,true) end do
        table.insert(arr,str:sub(pos,st-1))
        pos = sp + 1
    end
    table.insert(arr,str:sub(pos))
    return arr
end
local sanitize = function(sani,tize)
	local _,x = string.find(sani,tize)
	if x then
		return sani:sub(x+1)
	else
		return sani
	end
end
local tablize = function(input)
	if type(input) == "string" then
		return explode("\n",input)
	elseif type(input) == "table" then
		return table.concat(input,"\n")
	end
end
local compyress = function(input)
	return string.char(unpack(compress(input)))
end
local decompyress = function(input)
	local out = {}
	for a = 1, #input do
		table.insert(out,string.byte(input:sub(a,a)))
	end
	return decompress(out)
end
local listAll
listAll = function(_path, _files, noredundant)
	local path = _path or ""
	local files = _files or {}
	if #path > 1 then table.insert(files, path) end
	for _, file in ipairs(fs.list(path)) do
		local path = fs.combine(path, file)
		if (file ~= thisProgram) then
			local guud = true
			if guud then
				if fs.isDir(path) then
					listAll(path, files, noredundant)
				else
					table.insert(files, path)
				end
			end
		end
	end
	if noredundant then
		for a = 1, #files do
			if fs.isDir(tostring(files[a])) then
				if #fs.list(tostring(files[a])) ~= 0 then
					table.remove(files,a)
				end
			end
		end
	end
	return files
end
if not (input) then
	return displayHelp()
end
if not outpath then
	outpath = input
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

local postToPastebin = function(name, contents)
	local key = "0ec2eb25b6166c0c27a394ae118ad829"
	local response = http.post(
		"http://pastebin.com/api/api_post.php",
		"api_option=paste&"..
		"api_dev_key="..key.."&"..
		"api_paste_format=lua&"..
		"api_paste_name="..textutils.urlEncode(name).."&"..
		"api_paste_code="..textutils.urlEncode(contents)
	)
	if response then
		local sResponse = response.readAll()
		response.close()
		local sCode = string.match( sResponse, "[^/]+$" )
		return sCode
	else
		return false
	end
	return 
end

function doPack(input,output,doCompress,verbose) --make sure that shell exists before using verbose mode
	local tx = term.getTextColor()
	if not doPastebin then
		if not fs.exists(input) then return 3 end
		if fs.isReadOnly(output) then return 5 end
	end
	local packageSelf = true
	local packageReadOnly = true
	local ro_asked = false
	local ps_asked = false
	if fs.isDir(input) then --if not a package
		local out = {}
		local list = listAll(input,nil,true)
		if verbose then
			for a = 1, #list do --this checks for self and read-only files
				if fs.isReadOnly(list[a]) and (not ro_asked) then
					write("Include read-only files? ")
					if choice("yn",true) == 2 then
						packageReadOnly = false
					end
					ro_asked = true
				end
				if fs.combine("",list[a]) == shell.getRunningProgram() and (not ps_asked) then
					write("Include self? ")
					if choice("yn",true) == 2 then
						packageSelf = false
					end
					ps_asked = true
				end
			end
		end
		for a = 1, #list do --this loop kills fascists
			local is_self = fs.combine("",list[a]) == fs.combine("",shell.getRunningProgram())
			if not ((is_self and not packageSelf) or (fs.isReadOnly(list[a]) and not packageReadOnly)) then
				if verbose then
					write("[")
					if term.isColor() then term.setTextColor(colors.lightGray) end
					write(sanitize(list[a],fs.combine(dir,input)))
					term.setTextColor(tx)
					write("]")
				end
				if fs.isDir(list[a]) then
					out[sanitize(list[a],fs.combine(dir,input))] = true
				else
					local file = fs.open(list[a],"r")
					local cont = file.readAll()
					file.close()
					if doCompress then
						out[sanitize(list[a],fs.combine(dir,input))] = tablize(compyress(cont))
					else
						out[sanitize(list[a],fs.combine(dir,input))] = tablize(cont)
					end
				end
				local tx = term.getTextColor()
				if fs.getName(list[a]):lower() == "peasant" then
					if term.isColor() then
						term.setTextColor(colors.orange)
					end
					print(" BURNINATED")
				else
					if term.isColor() then
						term.setTextColor(colors.green)
					end
					print(" GOOD")
				end
				term.setTextColor(tx)
			else
				if fs.getName(list[a]):lower() == "peasant" then
					print("Spared "..list[a])
				else
					print("Skipped "..list[a])
				end
			end
		end
		local fullOutput = tostring(doCompress).."\n"..fixstr(textutils.serialize(out))
		local sCode
		if doPastebin then
			print("Uploading...")
			sCode = postToPastebin(input,fullOutput)
			return 7, "Code = '"..sCode.."'"
		else
			if fs.isDir(output) then fs.delete(output) end
			local file = fs.open(output,"w")
			file.write(fullOutput)
			file.close()
			return 1
		end
	else --if a package
		local list, isCompy
		if not doPastebin then
			local file = fs.open(input,"r")
			isCompy = file.readLine()
			list = file.readAll()
			file.close()
		else
			local file = http.get("http://pastebin.com/raw/"..tostring(input))
			if file then
				isCompy = file.readLine()
				list = file.readAll()
			else
				return 6
			end
		end
		local list = textutils.unserialize(list)
		if type(list) ~= "table" then
			return 4
		end
		if fs.exists(output) then
			fs.delete(output)
		end
		local amnt = 0
		for k,v in pairs(list) do
			amnt = amnt + 1
		end
		local num = 0
		for k,v in pairs(list) do
			num = num + 1
			if v == true then
				fs.makeDir(fs.combine(output,fs.combine(k,dir)))
			else
				local file = fs.open(fs.combine(output,fs.combine(k,dir)),"w")
				if verbose then
					write("[")
					if term.isColor() then term.setTextColor(colors.lightGray) end
					write(k)
					term.setTextColor(tx)
					write("]")
				end
				if isCompy:gsub(" ","") == "true" then
					file.write(decompyress(tablize(v)))
				else
					file.write(tablize(v))
				end
				file.close()
				local tx = term.getTextColor()
				if fs.getName(k):lower() == "peasant" then
					if term.isColor() then
						term.setTextColor(colors.orange)
					end
					print(" UNBURNINATED")
				else
					if term.isColor() then
						term.setTextColor(colors.green)
					end
					print(" GOOD")
				end
				term.setTextColor(tx)
			end
		end
		return 2
	end
end

local success, res, otherRes = pcall( function() return doPack(input,outpath,doCompress,true) end ) --functionized it!

if not success then
	term.setTextColor(colors.white)
	print("\n***Something went wrong!***")
	return printError(res)
end

if res then
	local msgs = {
		[1] = "Successfully packed '"..input.."/' as '"..outpath.."'",
		[2] = "Successfully unpacked '"..input.."' to '"..outpath.."/'",
		[3] = "That file/folder does not exist.",
		[4] = "That file isn't a packed folder.",
		[5] = "You don't have permission.",
		[6] = "Failed to connect.",
		[7] = "Uploaded successfully.",
	}
	print(msgs[res])
	if otherRes then
		print(otherRes)
	end
end