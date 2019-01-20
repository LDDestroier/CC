local tArg = {...}

local scr_x, scr_y = term.getSize()
local mx, my = scr_x/2, scr_y/2

-- special modes for special people
local mouseMode = tArg[1] == "mouse" or tArg[2] == "mouse"
local fuck = tArg[1] == "fuck" or tArg[2] == "fuck"

-- localize functions to increase speed, maybe, I think
local concat, blit = table.concat, term.blit
local sin, cos, rad, abs, sqrt, floor = math.sin, math.cos, math.rad, math.abs, math.sqrt, math.floor

-- rainbow pattern
local palette = {"e","1","4","5","d","9","b","a","2"}

local distance = function(x1, y1, x2, y2)
	return sqrt( (x2 - x1) ^ 2 + (y2 - y1) ^ 2 )
end

local randCase = function(str)
	local output = ""
	for i = 1, #str do
		output = output .. ((math.random(0,1) == 1) and str:sub(i,i):upper() or str:sub(i,i):lower())
	end
	return output
end

local render = function(iterate, xscroll1, yscroll1, xscroll2, yscroll2)
	local buffer, cx, cy = {{},{},{}}
	for y = 1, scr_y do
		buffer[1][y] = {}
		buffer[2][y] = {}
		buffer[3][y] = {}
		for x = 1, scr_x do
			cx = 0.66 * ((x - mx) > 0 and 1 or -1) * (abs(x - mx) ^ 1.2)
			cy =        ((y - my) > 0 and 1 or -1) * (abs(y - my) ^ 1.2)

			buffer[1][y][x] = fuck and randCase("fuck"):sub(1+(cx%4),1+(cx%4)) or "\127"

			buffer[2][y][x] = palette[1 + floor(
				iterate + distance( cx + xscroll1, cy + yscroll1, 0, 0 )
			) % #palette] or " "

			buffer[3][y][x] = palette[1 + floor(
				iterate + distance( cx + xscroll2, cy + yscroll2, 0, 0 )
			) % #palette] or " "
		end
	end

	for y = 1, scr_y do
		term.setCursorPos(1,y)
		-- suka
		blit(
			concat(buffer[1][y]),
			concat(buffer[2][y]),
			concat(buffer[3][y])
		)
	end
end

local main = function()
	term.clear()
	local wave, evt = 0
	local xscroll1, yscroll1, xscroll2, yscroll2 = 0, 0, 0, 0
	if mouseMode then
		parallel.waitForAny(function()
			while true do
				evt = {os.pullEvent()}
				if evt[1] == "mouse_click" or evt[1] == "mouse_drag" then
					if evt[2] == 1 then
						xscroll1 = mx - evt[3]
						yscroll1 = my - evt[4]
					elseif evt[2] == 2 then
						xscroll2 = mx - evt[3]
						yscroll2 = my - evt[4]
					end
				end
			end
		end,
		function()
			while true do
				render(wave, xscroll1, yscroll1, xscroll2, yscroll2)
				wave = (wave + 1) % (360 * 7)
				sleep(0.05)
			end
		end)
	else
		while true do
			xscroll1 = -sin(rad(wave * 2)) * scr_x * 0.4
			yscroll1 = -cos(rad(wave * 3.5)) * scr_y * 0.4
			xscroll2 = -xscroll1
			yscroll2 = -yscroll1
			render(wave, xscroll1, yscroll1, xscroll2, yscroll2)
			wave = (wave + 1) % (360 * 7)
			sleep(0.05)
		end
	end
end

-- wait for keypress to exit program
local waitForInput = function()
	local evt
	sleep(0.25)
	os.pullEvent("key")
end

parallel.waitForAny(main, waitForInput)
term.clear()
term.setCursorPos(1,1)
sleep(0.05)