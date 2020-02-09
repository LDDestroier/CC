local mon = peripheral.find("monitor")
if mon then
	mon.setTextScale(0.5)
	term.redirect(mon)
end

-- adjusts walls of screen so that it will bounce further/closer to the boundries of the screen
local xMargin, yMargin = 0, 0

local redrawDelay = nil
local changeColors = true

local scr_x, scr_y = term.getSize()
local max, min = math.max, math.min
local floor, ceil = math.floor, math.ceil

if scr_x >= 60 and scr_y >= 25 then
	redrawDelay = redrawDelay or 0.05
else
	redrawDelay = redrawDelay or 0.1
end

local getSize = function(image)
	local x, y = 0, #image[1]
	for y = 1, #image[1] do
		x = max(x, #image[1][y])
	end
	return x, y
end

local drawImage = function(image, x, y, terminal)
	terminal = terminal or term.current()
	local cx, cy = terminal.getCursorPos()
	for iy = 0, #image[1] + 1 do
		terminal.setCursorPos(x - 1, y + (iy - 1))
		if image[1][iy] then
			terminal.blit(
				" " .. image[1][iy] .. " ",
				"f" .. image[2][iy] .. "f",
				"f" .. image[3][iy] .. "f"
			)
		else
			terminal.clearLine()
		end
	end
	terminal.setCursorPos(cx,cy)
end

local colorSwap = function(image, text, back)
	local output = {{},{},{}}
	for y = 1, #image[1] do
		output[1][y] = image[1][y]
		output[2][y] = image[2][y]:gsub(".", text)
		output[3][y] = image[3][y]:gsub(".", back or text)
	end
	return output
end

local logo = {
	xvel = (math.random(0, 1) * 2) - 1,
	yvel = (math.random(0, 1) * 2) - 1,
	x = floor(scr_x / 2),
	y = floor(scr_y / 2),
	img = {
		{
			"       ",
			"      ",
			"      ",
			"       ",
			"        ",
			"              ",
			"              ",
			"    ",
			"  ",
			"    ",
			"              ",
		}, {
			"00ffffffffff000000fffffffffff",
			"000000f0f00000000f000000000f0",
			"0f00fff0000f000ff000ff0000f00",
			"0f00fff0000000f00000f0000ff00",
			"f00ff0000000f0000000f0fff0000",
			"00000000000000000000000000000",
			"000000fffffffffffffff00000000",
			"0fff0000000000000000000fff000",
			"f000000f0ffffffffff0000000000",
			"000f000000ffffff0000000000000",
			"00000000000000000000000000000",
		}, {
			"ff0000000000ffffff000000000ff",
			"ffffff000ff00ffff000ffffff00f",
			"f00ffff00ff00ff000fff00fff00f",
			"f00fff00ffff00000fff00fff000f",
			"0000000fffff000fffff000000fff",
			"fffffffffffff0fffffffffffffff",
			"ffffff000000000000000ffffffff",
			"f000000000ffffff0000000000fff",
			"00000000ffffffffff00000000fff",
			"fff00000000000000000000ffffff",
			"fffffffffffffffffffffffffffff",
		}
	}
}

local imgXsize, imgYsize = getSize(logo.img)
local xWall, yWall

local render = function(colorReplace)
	if colorReplace then
		drawImage(
			colorSwap(logo.img, {["0"] = colorReplace}, {["0"] = colorReplace}),
			floor(logo.x),
			floor(logo.y)
		)
	else
		drawImage(
			logo.img,
			floor(logo.x),
			floor(logo.y)
		)
	end
end

local color = math.random(1, 15)

local tick = function()
	scr_x, scr_y = term.getSize()
	xWall = scr_x - imgXsize + 1 - xMargin
	yWall = scr_y - imgYsize + 1 - yMargin
	logo.x = min(max(logo.x + logo.xvel, 1 + xMargin), xWall)
	logo.y = min(max(logo.y + logo.yvel, 1 + yMargin), yWall)

	if floor(logo.x) == (1 + xMargin) or floor(logo.x) == xWall then
		logo.xvel = -logo.xvel
		color = math.random(1, 15)
	end
	if floor(logo.y) == (1 + yMargin) or floor(logo.y) == yWall then
		logo.yvel = -logo.yvel
		color = math.random(1, 15)
	end
	if changeColors then
		render(string.sub("0123456789abcdef", color, color))
	else
		render()
	end
end

term.setBackgroundColor(colors.black)
term.clear()

local evt
local tID = os.startTimer(redrawDelay)
while true do
	evt = {os.pullEventRaw()}
	if evt[1] == "timer" and evt[2] == tID then
		tick()
		tID = os.startTimer(redrawDelay)
	elseif evt[1] == "terminate" then
		render("8")
		sleep(0.05)
		render("7")
		sleep(0.05)
		term.clear()
		break
	end
end

return 0
