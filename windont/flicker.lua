if not fs.exists("windont.lua") then
	print("'windont.lua' not found! Downloading...")
	local net = http.get("https://github.com/LDDestroier/CC/raw/master/windont/windont.lua")
	if net then
		local file = fs.open("windont.lua", "w")
		file.write(net.readAll())
		file.close()
		net.close()
	else
		error("Could not download Windon't.", 0)
	end
end

local windont = require("windont")

local newTerm = windont.newWindow(1, 1, 51, 19)
newTerm.meta.alwaysRender = false

local tint = {
	1,
	1,
	1,
}

local scr_x, scr_y = term.getSize()

local palette = {}
local nativePalette = {}

local resetPalette = function()
	for i = 0, 15 do
		palette[2^i] = {
			(1 - i / 15) * tint[1],
			(1 - i / 15) * tint[2],
			(1 - i / 15) * tint[3],
		}
		nativePalette[2^i] = {term.getPaletteColor(2^i)}
		term.setPaletteColor(2^i, table.unpack(palette[2^i]))
	end
end

resetPalette()

newTerm.setPaletteColor = function(col, r, g, b)
	return nil
end
newTerm.setPaletteColour = newTerm.setPaletteColor

local intensity = 4

local shades = {
	["0"] = {"0","1","2","3"},	-- white
	["8"] = {"4","5","6","7"},	-- lightGray
	["7"] = {"8","9","a","b"},	-- gray
	["f"] = {"d","e","f","f"},	-- black

	["1"] = {"3","4","5","6"},
	["2"] = {"4","5","6","7"},
	["3"] = {"4","5","6","7"},
	["4"] = {"2","3","4","5"},
	["5"] = {"3","4","5","6"},
	["6"] = {"2","3","4","5"},
	["9"] = {"5","6","7","8"},
	["a"] = {"6","7","8","9"},
	["b"] = {"6","7","8","9"},
	["c"] = {"7","8","9","a"},
	["d"] = {"5","6","7","8"},
	["e"] = {"4","5","6","7"},
}

newTerm.meta.textTransformation = function(x, y, dot, meta)
	return x, y, shades[dot[2]][math.random(1, intensity)]
end

newTerm.meta.backTransformation = function(x, y, dot, meta)
	return x, y, shades[dot[3]][math.random(1, intensity)]
end

local oldTerm = term.redirect(newTerm)

parallel.waitForAny(function()
	shell.run("/rom/programs/shell.lua")
end, function()
	while true do
		newTerm.redraw()
		sleep(0)
	end
end)

newTerm.meta.textTransformation = nil
newTerm.meta.backTransformation = nil
newTerm.redraw()

term.redirect(oldTerm)
for i = 0, 15 do
	term.setPaletteColor(2^i, table.unpack(nativePalette[2^i]))
end
term.setCursorPos(1, scr_y)
