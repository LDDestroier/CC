-- CC:Tweaked piano

local spamMode = true

local notes = {
	[0] 	= keys.a,			-- F#2
	[1] 	= keys.z,			-- G2
	[2] 	= keys.s,			-- G#2
	[3] 	= keys.x,			-- A2
	[4] 	= keys.d,			-- A#2
	[5] 	= keys.c,			-- B2
	[6] 	= keys.v,			-- C3
	[7] 	= keys.g,			-- C#3
	[8] 	= keys.b,			-- D3
	[9] 	= keys.h,			-- D#3
	[10] 	= keys.n,			-- E3
	[11] 	= keys.m,			-- F3
	[12] 	= keys.k,			-- F#3
	[13] 	= keys.comma,		-- G3
	[14] 	= keys.l,			-- G#3
	[15] 	= keys.period,		-- A3
	[16] 	= keys.semiColon,	-- A#3
	[17] 	= keys.slash,		-- B3
	[18] 	= keys.q,			-- C4
	[19] 	= keys.two,			-- C#4
	[20] 	= keys.w,			-- D4
	[21] 	= keys.three,		-- D#4
	[22] 	= keys.e,			-- E4
	[23] 	= keys.r,			-- F4
	[24] 	= keys.five,		-- F#4
}

local kNotes = {}
local notesDown = {}
for k,v in pairs(notes) do
	kNotes[v] = k
	notesDown[k] = false
end

local speaker = peripheral.find("speaker")

local between = function(n, min, max)
	return math.min(math.max(n, min), max)
end

local playNote = function(note, instrument, volume)
	speaker.playNote(instrument or "harp", volume or 1, between(note, 0, 24))
end

local drawPiano = function()
	-- add render function later
end

local evt
local tID = os.startTimer(0)
drawPiano()
while true do
	evt = {os.pullEventRaw()}
	if evt[1] == "key" then
		if kNotes[evt[2]] and not evt[3] then
			playNote(kNotes[evt[2]])
			notesDown[kNotes[evt[2]]] = 1
			drawPiano()
		end
	elseif evt[1] == "key_up" then
		if kNotes[evt[2]] then
			notesDown[kNotes[evt[2]]] = false
			drawPiano()
		end
	elseif evt[1] == "timer" and evt[2] == tID then
		tID = os.startTimer(0)
		if spamMode then
			for k,v in pairs(notesDown) do
				if v then
					playNote(k, nil, v)
					notesDown[k] = math.max(0, v - 0.03)
				end
			end
		end
	elseif evt[1] == "terminate" then
		return
	end
end
