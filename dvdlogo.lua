local nfte = require "nfte"

local mon = peripheral.find("monitor")
if mon then
	mon.setTextScale(0.5)
	term.redirect(mon)
end

local scr_x, scr_y = term.getSize()
local max, min = math.max, math.min
local floor, ceil = math.floor, math.ceil

getSize = function(image)
	local x, y = 0, #image[1]
	for y = 1, #image[1] do
		x = max(x, #image[1][y])
	end
	return x, y
end

local loadImageDataNFT = function(image, background) -- string image
	local output = {{},{},{}} -- char, text, back
	local y = 1
	background = (background or " "):sub(1,1)
	local text, back = " ", background
	local doSkip, c1, c2 = false
	local maxX = 0
	local bx
	for i = 1, #image do
		if doSkip then
			doSkip = false
		else
			output[1][y] = output[1][y] or ""
			output[2][y] = output[2][y] or ""
			output[3][y] = output[3][y] or ""
			c1, c2 = image:sub(i,i), image:sub(i+1,i+1)
			if c1 == tchar then
				text = c2
				doSkip = true
			elseif c1 == bchar then
				back = c2
				doSkip = true
			elseif c1 == "\n" then
				maxX = max(maxX, #output[1][y])
				y = y + 1
				text, back = " ", background
			else
				output[1][y] = output[1][y]..c1
				output[2][y] = output[2][y]..text
				output[3][y] = output[3][y]..back
			end
		end
	end
	for y = 1, #output[1] do
		output[1][y] = output[1][y] .. (" "):rep(maxX - #output[1][y])
		output[2][y] = output[2][y] .. (" "):rep(maxX - #output[2][y])
		output[3][y] = output[3][y] .. (background):rep(maxX - #output[3][y])
	end
	return output
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

local logo = {
	xvel = (math.random(0, 1) * 2) - 1,
	yvel = (math.random(0, 1) * 2) - 1,
	x = floor(scr_x / 2),
	y = floor(scr_y / 2),
	img = loadImageDataNFT([[
    00f      0f0f
   0ff0   f00f0f   0f0f     0f0ff0    f00f
   00     0f0f    00f0f0f   0f0f     00
0f0f   0f0f     0f0f0f     00    0f0f
0f       00f     0f0f
              0ff0
     0f0f
0f0f0f0f
0f0f       0f0f
   f00f0f
           f0	]])
}

local imgXsize, imgYsize = getSize(logo.img)
local xWall, yWall

local render = function()
	drawImage(logo.img, floor(logo.x), floor(logo.y))
end

local tick = function()
	scr_x, scr_y = term.getSize()
	xWall = scr_x - imgXsize + 1
	yWall = scr_y - imgYsize + 1
	logo.x = min(max(logo.x + logo.xvel, 1), xWall)
	logo.y = min(max(logo.y + logo.yvel, 1), yWall)

	if floor(logo.x) == 1 or floor(logo.x) == xWall then
		logo.xvel = -logo.xvel
	end
	if floor(logo.y) == 1 or floor(logo.y) == yWall then
		logo.yvel = -logo.yvel
	end
	render()
end

term.setBackgroundColor(colors.black)
term.clear()

while true do
	tick()
	sleep(0.05)
end
