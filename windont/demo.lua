local windont, ONE, TWO, INSTRUCTIONS

term.clear()

local x1, y1 = 2, 5
local x2, y2 = 13, 2

-- demo transformation function
-- mess with these all you like
-- just remember that they apply in reverse (x and y are positions on the screen from 1 to the window's width/height)

local getRandomColor = function(_cols)
	local cols = _cols or "0123456789abcdef"
	local p = math.random(1, #cols)
	return cols:sub(p, p)
end

local TF = {
	-- returns new X, new Y, and new character / text color / background color
	meta = function(cols)
		return function(meta)
			for y = 1, meta.height do
				for x = 1, meta.width do
					if meta.buffer[2][y][x] ~= "-" then
						meta.buffer[3][y][x] = getRandomColor(cols)
					end
				end
			end
		end
	end
}

local keysDown = {}

local tickTimer = os.startTimer(0.05)

local scr_x, scr_y = term.current().getSize()

local pBlit = function(t, y, str)
	t.setCursorPos(1, y)
	t.blit((" "):rep(#str), str, str)
end

local pWrite = function(t, x, y, str)
	t.setCursorPos(x, y)
	t.write(str)
end

windont = dofile("windont.lua")

windont.doClearScreen = true
windont.default.alwaysRender = false

INSTRUCTIONS = windont.newWindow(2, scr_y - 5, scr_x - 4, 3, {backColor = "-"})
ONE = windont.newWindow(1, 1, 9, 5, {backColor = "e"})
TWO = windont.newWindow(1, 1, 19, 10, {backColor = "-", textColor = "-"})

pWrite(INSTRUCTIONS, 1, 1, "Arrow keys to move windon't ONE (red)")
pWrite(INSTRUCTIONS, 1, 2, "WASD keys to move windon't TWO (blue)")
pWrite(INSTRUCTIONS, 1, 3, "Press 'Q' to quit")

ONE.setTextColor(0)
ONE.setBackgroundColor(colors.gray)
pWrite(ONE, 2, 2, "  I'm  ")
pWrite(ONE, 2, 3, "Stencil")
pWrite(ONE, 2, 4, "  Man  ")

TWO.setTextColor(colors.gray)
TWO.setBackgroundColor(colors.green)
pBlit(TWO, 1,  "------5------------")
pBlit(TWO, 2,  "5-55-----555---555-")
pBlit(TWO, 3,  "55--5-5-5---5-5---5")
pBlit(TWO, 4,  "5---5-5-5-----55555")
pBlit(TWO, 5,  "5---5-5-5---5-5----")
pBlit(TWO, 6,  "5---5-5--555---5555")
pBlit(TWO, 8,  "ddddddddddddddddddd")
pBlit(TWO, 9,  "ddddddddddddddddddd")
pBlit(TWO, 10, "ddddddddddddddddddd")

ONE.meta.metaTransformation = TF.meta("e-")
TWO.meta.metaTransformation = TF.meta(
	string.rep("5", 50) ..
	string.rep("d", 40) ..
	string.rep("4", 1)
)

while true do

	evt = {os.pullEvent()}
	scr_x, scr_y = term.current().getSize()

	if evt[1] == "timer" and evt[2] == tickTimer then
		tickTimer = os.startTimer(0.05)

		-- control windont ONE
		if keysDown[keys.up] then
			y1 = y1 - 1
		end
		if keysDown[keys.down] then
			y1 = y1 + 1
		end
		if keysDown[keys.left] then
			x1 = x1 - 1
		end
		if keysDown[keys.right] then
			x1 = x1 + 1
		end

		-- control windont TWO
		if keysDown[keys.w] then
			y2 = y2 - 1
		end
		if keysDown[keys.s] then
			y2 = y2 + 1
		end
		if keysDown[keys.a] then
			x2 = x2 - 1
		end
		if keysDown[keys.d] then
			x2 = x2 + 1
		end

		ONE.reposition(x1, y1)
		TWO.reposition(x2, y2)

		windont.render(ONE, TWO, INSTRUCTIONS)

		TWO.setCursorPos(2, 9)
		TWO.write("blits: " .. windont.info.BLIT_CALLS .. "  ")

		for k,v in pairs(keysDown) do
			keysDown[k] = v + 1
		end

	elseif evt[1] == "key" and evt[3] == false then
		keysDown[evt[2]] = 0
		if evt[2] == keys.q then
			sleep(0)
			break
		elseif evt[2] == keys.r then
			x1, y1 = 2, 5
			x2, y2 = 13, 2
		end
	elseif evt[1] == "key_up" then
		keysDown[evt[2]] = nil
	end
end

term.setCursorPos(1, scr_y)
