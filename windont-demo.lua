local windont, ONE, TWO, INSTRUCTIONS

term.clear()

local x1, y1 = 2, 5
local x2, y2 = 13, 2

-- demo transformation function
-- mess with these all you like
-- just remember that they apply in reverse (x and y are positions on the screen from 1 to the window's width/height)
local TF = {
	-- returns new X, new Y, and new character / text color / background color
	char = function(x, y, meta)
		return x, y, nil
	end,
	text = function(x, y, meta)
		return x, y, nil
	end,
	back = function(x, y, meta)
		return x, y, nil
	end
}

local keysDown = {}

local tickTimer = os.startTimer(0.05)

local scr_x, scr_y = term.current().getSize()

local pBlit = function(t, y, str)
	t.setCursorPos(1, y)
	t.blit(str, str, str)
end

windont = dofile("windont.lua")

windont.config.clearScreen = true

INSTRUCTIONS = windont.newWindow(2, scr_y - 5, scr_x - 4, 3, {backColor = "-"})
ONE = windont.newWindow(1, 1, 9, 5, {backColor = "e"})
TWO = windont.newWindow(1, 1, 19, 10, {backColor = "-"})

INSTRUCTIONS.setCursorPos(1, 1)
INSTRUCTIONS.write("Arrow keys to move windon't ONE (red)")
INSTRUCTIONS.setCursorPos(1, 2)
INSTRUCTIONS.write("WASD keys to move windon't TWO (blue)")
INSTRUCTIONS.setCursorPos(1, 3)
INSTRUCTIONS.write("Press 'Q' to quit")

ONE.setTextColor(0)
ONE.setBackgroundColor(colors.gray)
ONE.setCursorPos(2, 2)
ONE.write("  I'm  ")
ONE.setCursorPos(2, 3)
ONE.write("Stencil")
ONE.setCursorPos(2, 4)
ONE.write("  Man  ")

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

ONE.meta.charTransformation = TF.char
ONE.meta.textTransformation = TF.text
ONE.meta.backTransformation = TF.back

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
