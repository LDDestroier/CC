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
	img = {
		{
			"       ",
			"        ",
			"          ",
			"         ",
			"         ",
			"                          ",
			"        ",
			"  ",
			"       ",
			"    ",
			"                    ",
		}, {
			"  00000000000    ff000000ff ",
			" ff0 0f00 f0f   f000fff  00f",
			" 00   f00  000ff000 f00   00",
			"f00 ff00   f0f000   00  ff00",
			"            0000   f0000000 ",
			"            f0              ",
			"   fffffff000000fffffff     ",
			"ff000000000000000f000000ff  ",
			"f000000fff     ffff0000000  ",
			" 0000f0000000000000000000   ",
			"         00000000           ",
		}, {
			"  0000000000f    0000000000 ",
			" 00f f00f 000   000ff00  f00",
			" 00   00f  00f000ff 00f   00",
			"00f 000f   00000f   00  000f",
			"00000ff     00ff   000000ff ",
			"            0f              ",
			"   00000000000000000000     ",
			"00000000fffffffff000000000  ",
			"0000000000     0000000000f  ",
			" ffff000000000000000fffff   ",
			"         ffffffff           ",
		}
	}
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
