-- Wavey Path
-- Makes a wavey path to the right

local wpath = {}

wpath.cols = "e145d9ba26"
wpath.bwcols = "087f78"
wpath.waveLen = 3
wpath.textScale = 2.5
wpath.delay = 0.05
wpath.doFlip = false

local rbow,bbow
local sizePath = "size.lua"

if not peripheral.find("monitor") then
	error("A monitor is needed to use WPath.")
end

local reset = function()
	rbow,bbow = "",""
	for a = 1,#wpath.cols do
		rbow = rbow..wpath.cols:sub(a,a):rep(wpath.waveLen)
	end
	for a = 1,#wpath.bwcols do
		bbow = bbow..wpath.bwcols:sub(a,a):rep(wpath.waveLen)
	end
end
reset()

local mons = {peripheral.find("monitor")}
local setscales = function()
	for a = 1, #mons do
		mons[a].setTextScale(wpath.textScale)
	end
end

local wrap = function(txt,amnt)
	local output = {}
	for a = 0, #txt-1 do
		output[((a+amnt) % #txt)+1] = txt:sub(a+1,a+1)
	end
	return table.concat(output)
end

local render = function(shift,mon)
	local line
	if not mon.getSize then
		return
	end
	local scr_x,scr_y = mon.getSize()
	scr_y = scr_y + (scr_y % 2)
	bow = mon.isColor() and rbow or bbow
	local txcol, bgcol
	for y = 1, scr_y do
		mon.setCursorPos(1,y)
		line = bow:rep(scr_x):sub(1,scr_x)
		local text = ("#"):rep(scr_x)
		if wpath.doFlip then
			txcol = wrap(line:reverse(), math.abs(scr_y/2-y)+shift-1)
			bgcol = wrap(line:reverse(), math.abs(scr_y/2-y)+shift)
		else
			txcol = wrap(line, -1*math.abs(y-scr_y/2)+shift-1)
			bgcol = wrap(line, -1*math.abs(y-scr_y/2)+shift)
		end
		mon.blit(text,txcol,bgcol)
	end
end

local DOITNOW = function(KILLME, KILLMENOW)
	local shift = 0
	while true do
		if wpath.doFlip then
			shift = (shift - 1)
		else
			shift = (shift + 1)
		end
		mons = {peripheral.find("monitor")}
		setscales()
		for a = 1, #mons do
			render(shift, mons[a])
		end
		sleep(wpath.delay)
	end
end

--parallel.waitForAny(checkForReset,DOITNOW)
DOITNOW()
