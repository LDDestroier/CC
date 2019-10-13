local scr_x, scr_y = term.getSize()

local ballX, ballY = math.floor(scr_x / 2), math.floor(scr_y / 2)

local tsv = function(visible)
	if term.current().setVisible then
		return term.current().setVisible(visible)
	end
end

local dist = function(x1, y1, x2, y2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

local disadvantageRoll = function(min, max, times)
	local output = math.huge
	for i = 1, times do
		output = math.min(output, math.random(min, max))
	end
	return output
end

local wipeScreen = function(alternate)
	local i = alternate
	tsv(false)
	for y = 1, scr_y do
		i = not i
		term.setCursorPos(1, y)
		for x = 1, scr_x do
			if i then
				if (dist(x, y * 4/3, ballX, ballY) < disadvantageRoll(3,100, 12)) then
					term.blit("\153", "0", "e")
				else
					term.blit("\153", "0", "f")
				end
			else
				if (dist(x, y * 4/3, ballX, ballY) < disadvantageRoll(3,100, 12)) then
					term.blit("\153", "e", "0")
				else
					term.blit("\153", "f", "0")
				end
			end
		end
	end
	tsv(true)
end

local setPalette = function(i)
	local v1 = (2 + math.sin(math.rad(i))) / 3
	local v2 = (2 + math.sin(math.rad(i + 90))) / 3
	local v3 = v1 - 0.1
	term.setPaletteColor(colors.black, v2, v1, v3)
	term.setPaletteColor(colors.white, v1, v2, v2)
	term.setPaletteColor(colors.red, v2, v3, v3)
end

term.clear()

local i = 0
while true do
	i = i + 1
	ballX = ((math.sin(math.rad(i * 2)) + 1) / 2) * (scr_x - 10) + 5
	ballY = ((math.sin(math.rad(i * 3)) + 1) / 2) * (scr_y - 6) + 3
	wipeScreen(i % 2 == 0)
	--wipeScreen(true)
	setPalette(i)
	sleep(0)
end
