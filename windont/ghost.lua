local tArg = {...}
local filename = tArg[1]

local contrast = 2			-- lower value means higher contrast
local addSpeed = 4			-- higher value means brighter colors show up faster
local subtractSpeed = 2		-- higher value means darker colors take over faster
local minimumStatic = -8	-- lower value means static will be less frequent (not less powerful)
local maximumStatic = 0		-- higher value means static will be more powerful (not less frequent) (if zero, disables static)
local tint = {
	1,
	0.749,
	0,
}

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

windont.useSetVisible = true

local newTerm = windont.newWindow(1, 1, term.getSize())
local gstTerm = windont.newWindow(1, 1, term.getSize())
newTerm.meta.alwaysRender = false
gstTerm.meta.alwaysRender = false

local scr_x, scr_y = term.getSize()

local palette = {}
local nativePalette = {}

local alpha, rv_alpha 	= {"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"}, {}
local bright, rv_bright = {"f","7","c","a","b","d","9","8","e","5","2","1","6","3","4","0"}, {}
for k,v in pairs(bright) do
	rv_bright[v] = k
end
for k,v in pairs(alpha) do
	rv_alpha[v] = k
end

local resetPalette = function()
	local p
	for i = 0, 15 do
		p = 2 ^ (-1 + rv_alpha[bright[i + 1]])
		palette[p] = {
			((i + contrast) / (15 + contrast)) * tint[1],
			((i + contrast) / (15 + contrast)) * tint[2],
			((i + contrast) / (15 + contrast)) * tint[3],
		}
		nativePalette[p] = {term.getPaletteColor(p)}
		term.setPaletteColor(p, table.unpack(palette[p]))
	end
end

resetPalette()

newTerm.setPaletteColor = function(col, r, g, b)
	return nil
end
newTerm.setPaletteColour = newTerm.setPaletteColor

gstTerm.meta.metaTransformation = function(meta)
	for y = 1, meta.height do
		for x = 1, meta.width do

			local BGCOL = newTerm.meta.buffer[3][y][x]
			local TXCOL
			if newTerm.meta.buffer[1][y][x] == " " then
				TXCOL = BGCOL
			else
				TXCOL = newTerm.meta.buffer[2][y][x]
			end
			local CHAR
			if newTerm.meta.buffer[1][y][x] == " " and meta.buffer[1][y][x] ~= " " then
				CHAR = meta.buffer[1][y][x]
			else
				CHAR = newTerm.meta.buffer[1][y][x]
			end

			meta.buffer[1][y][x] = CHAR

			if rv_bright[TXCOL] >= rv_bright[meta.buffer[2][y][x]] then
				meta.buffer[2][y][x] = bright[ math.min(16, math.min(rv_bright[meta.buffer[2][y][x]] + addSpeed, rv_bright[TXCOL]) + math.max(0, math.random(minimumStatic, maximumStatic))) ]
			else
				meta.buffer[2][y][x] = bright[ math.max(rv_bright[meta.buffer[2][y][x]] - subtractSpeed, 1) ]
			end

			if rv_bright[BGCOL] >= rv_bright[meta.buffer[3][y][x]] then
				meta.buffer[3][y][x] = bright[ math.min(16, math.min(rv_bright[meta.buffer[3][y][x]] + addSpeed, rv_bright[BGCOL]) + math.max(0, math.random(minimumStatic, maximumStatic))) ]
			else
				meta.buffer[3][y][x] = bright[ math.max(rv_bright[meta.buffer[3][y][x]] - subtractSpeed, 1) ]
			end

			if meta.buffer[2][y][x] == "f" and meta.buffer[3][y][x] == "f" and newTerm.meta.buffer[1][y][x] == " " then
				meta.buffer[1][y][x] = " "
			end

		end
	end
end

local oldTerm = term.redirect(newTerm)

parallel.waitForAny(function()
	shell.run(filename or "/rom/programs/shell.lua")
end, function()
	while true do
		gstTerm.redraw()
		newTerm.restoreCursor()
		sleep(0)
	end
end)

term.redirect(oldTerm)
for i = 0, 15 do
	term.setPaletteColor(2^i, table.unpack(nativePalette[2^i]))
end
newTerm.redraw()
term.setCursorPos(1, scr_y)
