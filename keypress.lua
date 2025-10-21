-- Keypress API
-- by LDDestroier

local keypress = {}

local _DEMO = false

if select(1, ...) == "demo" then
	_DEMO = true
end

local r_keys = {}
for k,v in pairs(keys) do
	r_keys[v] = k
end

local keys_down = {}
local last_epoch, last_key = 0, 0
local last_evt
local delta

keypress.keys_down = keys_down

local nonprintable_keys = {
	[keys.backspace] = true,
	[keys.leftCtrl] = true,
	[keys.rightCtrl] = true,
	[keys.leftAlt] = true,
	[keys.rightAlt] = true,
	[keys.leftShift] = true,
	[keys.rightShift] = true,
	[keys.capsLock] = true,
	[keys.enter] = true,
	[keys.insert] = true,
	[keys.delete] = true,
	[keys.home] = true,
	[keys["end"]] = true,
	[keys.pageDown] = true,
	[keys.pageUp] = true,
	[keys.numLock] = true,
	[keys.scrollLock] = true,
	[keys.numPadEnter] = true,
	[keys.up] = true,
	[keys.down] = true,
	[keys.left] = true,
	[keys.right] = true,
}
for i = 1, 15 do
	nonprintable_keys[keys["f" .. i]] = true
end

-- TODO: make these local variables as to not polute the keys table
keys.ctrl = 1001
keys.shift = 1002
keys.alt = 1003

for k,v in pairs(keys) do
	keys_down[k] = false
end

local function modifier_keydowns()
	keys_down[keys.ctrl]  = keys_down[keys.leftCtrl]  or keys_down[keys.rightCtrl]
	keys_down[keys.shift] = keys_down[keys.leftShift] or keys_down[keys.rightShift]
	keys_down[keys.alt]   = keys_down[keys.leftAlt]   or keys_down[keys.rightAlt]
end

local modfier_lookup = {
	[ keys.leftCtrl ] = true,
	[ keys.rightCtrl ] = true,
	[ keys.ctrl ] = true,
	[ keys.leftShift ] = true,
	[ keys.rightShift ] = true,
	[ keys.shift ] = true,
	[ keys.leftAlt ] = true,
	[ keys.rightAlt ] = true,
	[ keys.alt ] = true,

	ctrl = {
		[ keys.leftCtrl ] = true,
		[ keys.rightCtrl ] = true,
		[ keys.ctrl ] = true,
	},

	shift = {
		[ keys.leftShift ] = true,
		[ keys.rightShift ] = true,
		[ keys.shift ] = true,
	},

	alt = {
		[ keys.leftAlt ] = true,
		[ keys.rightAlt ] = true,
		[ keys.alt ] = true,
	}
}

function keypress.resume(...)

	local evt = {...}
	local output1, output2

	if evt[1] == "keypress" and _DEMO then
		-- exit demo with CTRL-C
		if evt[2].key == keys.c and evt[2].ctrl then
			return "keypress_terminatedemo"

		else
			print("key  = keys." .. (r_keys[evt[2]  .key] or "???"))
			write("char = " .. (evt[2].char or "nil"))
			if evt[2].char_pressed then
				print(" (" .. evt[2].char_pressed .. ")")
			else print("") end
			print("note = " .. (evt[2].notation or "(NONE)"))
			write("mods = ")
			write(evt[2].ctrl and "ctrl " or "")
			write(evt[2].alt and "alt " or "")
			print(evt[2].shift and "shift" or "")
			print("")
		end

	elseif evt[1] == "key" then
		keys_down[evt[2]] = true
		modifier_keydowns()

		if nonprintable_keys[evt[2]] or (
			keys_down[keys.ctrl] or keys_down[keys.alt]
		) then
		output1, output2 = "keypress", {
			key = evt[2],
			char = nil, -- represents a printable character -- use this if you're using keypress API for text input
			char_pressed = nil, -- represents the character pressed regardless of if it should print
			time = os.epoch(),
			ctrl = keys_down[keys.ctrl],
			shift = keys_down[keys.shift],
			alt = keys_down[keys.alt]
		}

		output2.notation = keypress.to_vim_notation(output2)
	else
		last_epoch = os.epoch()
		last_key = evt[2]
	end

elseif evt[1] == "key_up" then
	keys_down[evt[2]] = false
	modifier_keydowns()

elseif evt[1] == "char" and last_evt == "key" then
	delta = os.epoch() - last_epoch
	if delta <= 90 then
		output1, output2 = "keypress", {
			key = last_key,
			char = evt[2],
			char_pressed = evt[2],
			time = os.epoch(),
			ctrl = keys_down[keys.ctrl],
			shift = keys_down[keys.shift],
			alt = keys_down[keys.alt]
		}

		output2.notation = keypress.to_vim_notation(output2)
	end

else
	last_key = nil
end

last_evt = evt[1]

return output1, output2
end

-- convert some key codes to characters
local keys_printable_lookup = {
	[ keys.one ]		= "1",
	[ keys.two ]		= "2",
	[ keys.three ]		= "3",
	[ keys.four ]		= "4",
	[ keys.five ]		= "5",
	[ keys.six ]		= "6",
	[ keys.seven ]		= "7",
	[ keys.eight ]		= "8",
	[ keys.nine ]		= "9",
	[ keys.zero ]		= "0",
	[ keys.grave ]		= "`",
	[ keys.equals ]		= "=",
	[ keys.minus ]		= "-",
	[ keys.underscore ]	= "_",
	[ keys.leftBracket ]	= "[",
	[ keys.rightBracket ]	= "]",
	[ keys.apostrophe ]	= "'",
	[ keys.colon ]		= ":",
	[ keys.semiColon ]	= ";",
	[ keys.period ]		= ".",
	[ keys.comma ]		= ",",
	[ keys.slash ]		= "/",
	[ keys.backslash ]	= "\\",
}

local alphabet = "abcdefghijklmnopqrstuvwxyz"
for i = 1, #alphabet do
	keys_printable_lookup[ keys[alphabet:sub(i, i)] ] = alphabet:sub(i, i)
end

-- lookup table to turn keypress events into vim notation
local vim_notation_lookup = {
	[ keys.home ]		= "Home",
	[ keys["end"] ]		= "End",
	[ keys.pageUp ]		= "PageUp",
	[ keys.pageDown ]	= "PageDown",
	[ keys.insert ]		= "Insert",
	[ keys.delete ]		= "Del",
	[ keys.space ]		= "Space",
	[ keys.tab ]		= "Tab",
	[ keys.enter ]		= "Enter",
	[ keys.backspace ]	= "BS",

	[ "<" ]           = "lt",
	[ "|" ]           = "Bar",
	[ "\\" ]          = "Bslash",
	[ "\000" ]        = "Nul",

	[ keys.left ]  = "Left",
	[ keys.right ] = "Right",
	[ keys.up ]    = "Up",
	[ keys.down ]  = "Down",

	-- numpad keys that do not change if numlock is on or off
	[ keys.numPadAdd ]      = "kPlus",
	[ keys.numPadSubtract ] = "kMinus",
	[ keys.numPadDivide ]   = "kDivide",
	[ keys.multiply ]       = "kMultiply",
	[ keys.numPadComma ]    = "kComma",
	[ keys.numPadEnter ]    = "kEnter",
	[ keys.numPadEquals ]   = "kEqual",

	-- NOTE: unsure of actual Vim notation (if any), since I don't own a keyboard with these keys
	[ keys.kanji ]     = "Kanji",
	[ keys.kana ]      = "Kana",
	[ keys.ax ]        = "Ax",
	[ keys.yen ]       = "Yen",
	[ keys.stop ]      = "Stop",
	[ keys.convert ]   = "Convert",
	[ keys.noconvert ] = "NoConvert",

	-- NOTE: I am quite sure these keys are not recognized in Vim, but they *are* in CraftOS
	[ keys.capsLock ]  = "CapsLock",
	[ keys.scollLock ] = "ScrollLock", -- 'scollLock' misspelled in CraftOS
	[ keys.numLock ]   = "NumLock",
	[ keys.pause ]     = "Pause",
}

-- function keys
for i = 1, 15 do
	vim_notation_lookup[ keys["f" .. i] ] = "F" .. i
end

-- treated as though numlock is OFF
local vim_notation_nonumlock = {
	[ keys.numPadDecimal ]  = "kDel",
	[ keys.numPad0 ]        = "Insert",
	[ keys.numPad1 ]        = "kEnd",
	[ keys.numPad2 ]        = "kDown",
	[ keys.numPad3 ]        = "kPageDown",
	[ keys.numPad4 ]        = "kLeft",
	[ keys.numPad5 ]        = "kOrigin",
	[ keys.numPad6 ]        = "kRight",
	[ keys.numPad7 ]        = "kHome",
	[ keys.numPad8 ]        = "kUp",
	[ keys.numPad9 ]        = "kPageUp",
}

-- what to register if numlock is ON
local vim_notation_numlock = {
	[ keys.numPadDecimal ]  = "kPoint",
	[ keys.numPad0 ]        = "k0",
	[ keys.numPad1 ]        = "k1",
	[ keys.numPad2 ]        = "k2",
	[ keys.numPad3 ]        = "k3",
	[ keys.numPad4 ]        = "k4",
	[ keys.numPad5 ]        = "k5",
	[ keys.numPad6 ]        = "k6",
	[ keys.numPad7 ]        = "k7",
	[ keys.numPad8 ]        = "k8",
	[ keys.numPad9 ]        = "k9",
}

-- aliases for vim notation into other vim notation
local vim_notation_alias = {
	[ "kDel" ] 	= "Del",
	[ "kEnd" ] 	= "End",
	[ "kDown" ] 	= "Down",
	[ "kPageDown" ] = "PageDown",
	[ "kLeft" ] 	= "Left",
	[ "kRight" ] 	= "Right",
	[ "kHome" ] 	= "Home",
	[ "kUp" ] 	= "Up",
	[ "kPageUp" ] 	= "PageUp",
}

-- lookup table for shift-modified characters
-- might not be representative of keyboards other than my own
local shifted_keys = {
	['1'] = '!',
	['2'] = '@',
	['3'] = '#',
	['4'] = '$',
	['5'] = '%',
	['6'] = '^',
	['7'] = '&',
	['8'] = '*',
	['9'] = '(',
	['0'] = ')',
	['-'] = '_',
	['='] = '+',
	['`'] = '~',
	['['] = '{',
	[']'] = '}',
	['\\'] = '|',
	[';'] = ':',
	['\''] = '\"',
	[','] = "<",
	['.'] = ">",
	['/'] = "?",
}

local function uppersize(char)
	return shifted_keys[char] or char:upper()
end

function keypress.to_vim_notation( kp )
	if (not kp) or type(kp) ~= "table" then return "", false end
	if not kp.key then return "", false end

	local output = {"<", "", "", "", "", ">"}
	-- output[2] is "M" (alt)
	-- output[3] is "C" (ctrl)
	-- output[4] is "S" (shift)
	-- output[5] is the key code

	-- if the keypress has a printable character, omit the "S" notation
	local do_omit_s = false

	-- check if key is numlock-modifiable
	if vim_notation_numlock[ kp.key ] then
		-- if a character event was queued, that means numlock must have been on!
		if kp.char then
			output[5] = vim_notation_numlock[ kp.key ]
		else
			output[5] = vim_notation_nonumlock[ kp.key ]
		end

	else

		if vim_notation_lookup[ kp.char ] then
			output[5] = vim_notation_lookup[ kp.char ]

		elseif (kp.ctrl or kp.alt) and keys_printable_lookup[ kp.key ] then
			output[5] = keys_printable_lookup[ kp.key ]
			if kp.shift then
				output[5] = uppersize(output[5])
			end
			kp.char_pressed = output[5]
			do_omit_s = true
			output[5] = vim_notation_lookup[ output[5] ] or output[5]

		elseif vim_notation_lookup[ kp.key ] then
			output[5] = vim_notation_lookup[ kp.key ]
		end
	end

	if kp.char then
		do_omit_s = true
	end

	kp.char_pressed = kp.char_pressed or kp.char

	-- tack on modifier codes
	if kp.alt and not modfier_lookup.alt[ kp.key ] then
		output[2] = "M-"
	end

	if kp.ctrl and not modfier_lookup.ctrl[ kp.key ] then
		output[3] = "C-"
	end

	if kp.shift and (not do_omit_s) and not modfier_lookup.shift[ kp.key ] then
		output[4] = "S-"
	end

	-- enforce notation aliases

	if vim_notation_alias[ output[5] ] then
		output[5] = vim_notation_alias[ output[5] ]
	end

	-- for keys without notation, remove the chevrons and use the printed character
	if output[5] == "" then
		if not (kp.ctrl or kp.alt) then
			output[1] = ""
			output[6] = ""
		end
		output[5] = kp.char
	end

	if output[5] then
		return table.concat(output)
	else
		return nil
	end
end

function keypress.process()
	if _DEMO then
		print("Keypress API Demo")
		print("Press CTRL-C to exit.")
	end

	while true do
		local evt, kp = keypress.resume( os.pullEvent() )
		if evt == "keypress" then
			os.queueEvent(evt, kp)

		elseif evt == "keypress_terminatedemo" then
			print("Demo ended.")
			return
		end
	end
end

if _DEMO then
	keypress.process()
end

return keypress
