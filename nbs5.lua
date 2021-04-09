--[[
NoteBlock Song API
by MysticT
Twekaed by Soni
Modified for NBS v5 by LDDestroier (WIP)
--]]

local nbs5 = {}

-- yield to avoid error
local function yield()
	os.queueEvent("yield")
	os.pullEvent("yield")
end

-- read short integer (16-bit) from file
local function readShort(file)
	return file.read() + file.read() * 256
end
_G.readShort = readShort


-- read integer (32-bit) from file
local function readInt(file)
	return file.read() + file.read() * 256 + file.read() * 65536 + file.read() * 16777216
end

-- read string from file
local function readString(file)
	local s, c = ""
	local len = readInt(file)
	for i = 1, len do
		c = file.read()
		if not c then
			break
		end
		s = s .. string.char(c)
	end
	return s
end

local function makeBitNum(num, bytes)
	local output = ""
	for i = 0, bytes - 1 do
		output = output .. string.char(bit32.band(bit32.rshift(num, i * 8), 0xFF))
	end
	return output
end

-- write short integer (16-bit) to file
local function writeShort(file, int)
	file.write(makeBitNum(int, 2))
end

-- write integer (32-bit) to file
local function writeInt(file, int)
	file.write(makeBitNum(int, 4))
end

-- write string to file
local function writeString(file, str)
	writeInt(file, #str)
	file.write(str)
end

-- read nbs file header
local function readNBSHeader(file)
	local header = {}
	header.lenght = readShort(file)
	if header.lenght > 0 then
		-- old NBS
		header.nbs_version = 0
		header.height = readShort(file)
		header.name = readString(file)
		if header.name == "" then
			header.name = "Untitled"
		end
		header.author = readString(file)
		if header.author == "" then
			header.author = "Unknown"
		end
		header.original_author = readString(file)
		if header.original_author == "" then
			header.original_author = "Unknown"
		end
		header.description = readString(file)
		header.tempo = readShort(file) / 100
		header.autosave = file.read()
		header.autosave_duration = file.read()
		header.time_signature = file.read()
		header.minutes_spent = readInt(file)
		header.left_clicks = readInt(file)
		header.right_clicks = readInt(file)
		header.blocks_added = readInt(file)
		header.blocks_removed = readInt(file)
		header.filename = readString(file)
		
	else
		-- NBS v5
		header.nbs_version = file.read()
		header.vanilla_instruments = file.read()
		header.lenght = readShort(file)
		header.height = readShort(file)
		header.name = readString(file)
		if header.name == "" then
			header.name = "Untitled"
		end
		header.author = readString(file)
		if header.author == "" then
			header.author = "Unknown"
		end
		header.original_author = readString(file)
		if header.original_author == "" then
			header.original_author = "Unknown"
		end
		header.description = readString(file)
		header.tempo = readShort(file) / 100
		header.autosave = file.read()
		header.autosave_duration = file.read()
		header.time_signature = file.read()
		header.minutes_spent = readInt(file)
		header.left_clicks = readInt(file)
		header.right_clicks = readInt(file)
		header.blocks_added = readInt(file)
		header.blocks_removed = readInt(file)
		header.filename = readString(file)
		header.looping = file.read()
		header.max_looping = file.read()
		header.loop_start = readShort(file)
		
	end

	return header
end

-- jump to the next tick in the file
local function nextTick(file, tSong)
	local jump = readShort(file)
	for i = 1, jump - 1 do
		tSong[#tSong + 1] = {}
	end
	return jump > 0
end

-- read the notes in a tick
-- TODO cleanup, move checks to player:nbs.lua
local function readTick(file)
	local t = {}
	local n = 0
	local jump = readShort(file)

	while jump > 0 do
		n = n + jump
		write(".")
		local instrument = file.read() + 1
		if instrument > 16 then
			return nil, "(v5) Can't convert custom instruments"
		end

		local note = file.read() - 33
		local velocity = file.read()
		local pan = file.read()
		local pitch_mod = readShort(file)

		if note < 0 or note > 24 then
			return nil, "(v5) Notes must be in Minecraft's 2 octaves (" .. note .. ")"
		end

		if not t[instrument] then
			t[instrument] = {}
		end

		t[instrument][n] = note
		jump = readShort(file)
	end

	return t
end

-- API functions

-- save a converted song to a file
function nbs5.saveSong(tSong, sPath)
	local file = fs.open(sPath, "w")
	if file then
		file.write(textutils.serialize(tSong))
		file.close()
		return true
	end

	return false, "Error opening file "..sPath
end

-- save a song as an NBS v5 file
function nbs5.saveSongNBS(tSong, sPath)
	
end

-- load and convert an .nbs file and save it
function nbs5.load(sPath, bVerbose)
	local file = fs.open(sPath, "rb")
	if file then
		if bVerbose then
			print("Reading header...")
		end

		local tSong = {}
		local header = readNBSHeader(file)
		tSong.header = header
		tSong.name = header.name
		tSong.author = header.author
		tSong.original_author = header.original_author
		tSong.lenght = header.lenght / header.tempo
		tSong.delay = 1 / header.tempo

		if bVerbose then
			print("Reading ticks...")
		end

		if header.nbs_version == 0 then

			while nextTick(file, tSong) do
				local tick, err = readTick(file, tSong)
				if tick then
					table.insert(tSong, tick)
				else
					file.close()
					return nil, err
				end
				yield()
			end

			pcall(function()
				local layers = {}
				for i=1, header.height do
					table.insert(layers, {
						name=readString(file),
						volume=file.read() + 0
					})
				end
				tSong.layers = layers

				local insts = {}
				for i=1, file.read() + 0 do
					insts[#insts + 1] = {
						name = readString(file),
						file = readString(file),
						pitch = file.read() + 0,
						key = (file.read() + 0) ~= 0
					}
				end
				tSong.instruments = insts
			end)
		
		else

			while nextTick(file, tSong) do
				local tick, err = readTick(file, tSong)
				if tick then
					table.insert(tSong, tick)
				else
					file.close()
					return nil, err
				end
				yield()
			end

			pcall(function()
				local layers = {}
				for i=1, header.height do
					table.insert(layers, {
						name = readString(file),
						lock = file.read(),
						volume = file.read(),
						pan = file.read()
					})
				end
				tSong.layers = layers

				local insts = {}
				for i=1, file.read() + 0 do
					insts[#insts + 1] = {
						name = readString(file),
						file = readString(file),
						pitch = file.read() + 0,
						key = (file.read() + 0) ~= 0
					}
				end
				tSong.instruments = insts
			end)

		end

		file.close()

		return tSong
	end

	return nil, "Error opening file "..sPath

end

return nbs5
