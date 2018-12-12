local scr_x, scr_y = term.getSize()
local mx, my = scr_x/2, scr_y/2
local debugMode = false

-- rainbow pattern
local palette = {"e","1","4","5","d","9","b","a","2"}

local distance = function(x1, y1, x2, y2)
	return math.sqrt( (x2 - x1) ^ 2 + (y2 - y1) ^ 2 )
end

local round = function(num)
	return math.floor(num + 0.5)
end

local render = function(iterate, xscroll, yscroll)
	local buffer, cx, cy = {{},{},{}}
	for y = 1, scr_y do
		buffer[1][y] = {}
		buffer[2][y] = {}
		buffer[3][y] = {}
		for x = 1, scr_x do
			cx = ((x - mx) > 0 and 1 or -1) * (math.abs(x - mx) ^ 1.2) / 1.5
			cy = ((y - my) > 0 and 1 or -1) * (math.abs(y - my) ^ 1.2)

			buffer[1][y][x] = "\127"
			--buffer[1][y][x] = ("FUCK"):sub(1+(cx%4),1+(cx%4))

			buffer[2][y][x] = palette[1 + round(
				iterate + distance( cx - xscroll, cy - yscroll, 0, 0 )
			) % #palette] or " "

			buffer[3][y][x] = palette[1 + round(
				iterate + distance( cx + xscroll, cy + yscroll, 0, 0 )
			) % #palette] or " "
		end
	end

	for y = 1, scr_y do
		term.setCursorPos(1,y)
		if debugMode then
			term.write(#buffer[1][y]..", "..#buffer[2][y]..", "..#buffer[3][y])
		else
			term.blit(
				table.concat(buffer[1][y]),
				table.concat(buffer[2][y]),
				table.concat(buffer[3][y])
			)
		end
	end
end

local main = function()
	term.clear()
	local wave = 0
	while true do
		render(
			wave,
			math.sin(math.rad(wave * 2)) * scr_x * 0.4,
			math.cos(math.rad(wave * 3.5)) * scr_y * 0.4
		)
		wave = (wave + 1) % (360 * 7)
		sleep(0.05)
	end
end

local waitForInput = function()
	local evt
	sleep(0.25)
	os.pullEvent("key")
end

parallel.waitForAny(main, waitForInput)
term.clear()
term.setCursorPos(1,1)
sleep(0.05)
