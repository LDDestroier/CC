--[[
 pastebin get tfyqv2ww toy
 std pb tfyqv2ww toy
--]]

local channel = 180
local modem
local scr_x, scr_y = term.getSize()
local valchar = "#"      --character used for fading
local hedchar = "@"      --character used for tip of line
local s = {              --default color combinations
	[1] = { --A classical black-and-white color fade, perfect for looking classy and pretentious.
		colors.black,
		colors.gray,
		colors.lightGray,
		colors.white,
	},
	[2] = { --If you're feeling blue, then this randomly selected set of four colors should make you feel even worse!
		colors.black,
		colors.blue,
		colors.cyan,
		colors.lightBlue,
	},
	[3] = { --This one's purple. Tha-that's it. Like purple? Good.
		colors.black,
		colors.red,
		colors.magenta,
		colors.pink,
	},
	[4] = { --I'll admit, the creativity is lacking in this color. I mean, what was I thinking?
		colors.black,
		colors.gray,
		colors.green,
		colors.lime,
	},
	[5] = { --NOBODY CALLS ME YELLOW
		colors.black,
		colors.brown,
		colors.orange,
		colors.yellow,
	},
}
local p = math.random(1,#s)
local g = function(num,sa) --This interprets the color palate and turns it into a fadey thing.
	if not sa then sa = s[p] end
	local values = {
		[1] = {bg=sa[1], txt=sa[1], char=valchar},
		[2] = {bg=sa[1], txt=sa[2], char=valchar},
		[3] = {bg=sa[2], txt=sa[1], char=valchar},
		[4] = {bg=sa[2], txt=sa[2], char=valchar},
		[5] = {bg=sa[3], txt=sa[2], char=valchar},
		[6] = {bg=sa[3], txt=sa[3], char=valchar},
		[7] = {bg=sa[3], txt=sa[4], char=valchar},
		[8] = {bg=sa[4], txt=sa[3], char=valchar},
		[9] = {bg=sa[4], txt=sa[4], char=hedchar},
	}
	if not num then return #values end
	return values[num]
end
local size = g()
local grid = {}
local ah = {}
for b = 1, scr_x do
	ah[b] = {v = 0, r = s[p]}
end
for b = 1, scr_y do
	grid[b] = ah
end

local between = function(num,min,max)
	return (num > min and num or min) < max and num or max
end

local getDotsInLine = function( startX, startY, endX, endY ) --graciously stolen from the paintutils, and PAIN
    local out = {}
    startX = math.floor(startX)
    startY = math.floor(startY)
    endX = math.floor(endX)
    endY = math.floor(endY)
    if startX == endX and startY == endY then
        out = {{x=startX,y=startY}}
        return out
    end
    local minX = math.min( startX, endX )
    if minX == startX then
        minY = startY
        maxX = endX
        maxY = endY
    else
        minY = endY
        maxX = startX
        maxY = startY
    end
    local xDiff = maxX - minX
    local yDiff = maxY - minY
    if xDiff > math.abs(yDiff) then
        local y = minY
        local dy = yDiff / xDiff
        for x=minX,maxX do
            table.insert(out,{x=x,y=math.floor(y+0.5)})
            y = y + dy
        end
    else
        local x = minX
        local dx = xDiff / yDiff
        if maxY >= minY then
            for y=minY,maxY do
                table.insert(out,{x=math.floor(x+0.5),y=y})
                x = x + dx
            end
        else
            for y=minY,maxY,-1 do
                table.insert(out,{x=math.floor(x+0.5),y=y})
                x = x - dx
            end
        end
    end
    return out
end
local getModemInput = function()
	while true do
		local _,side,freq,rfreq,msg,dist = os.pullEvent("modem_message")
		if freq == channel then
			if type(msg) == "table" then
				if type(msg.x) == "number" and type(msg.y) == "number" and type(msg.r) == "table" then
					if (msg.x >= 1 and msg.x <= scr_x) and (msg.y >= 1 and msg.y <= scr_y) and (#msg.r == 4) then
						grid[msg.y][msg.x] = {v = size, r = msg.r}
					end
				end
			end
		end
	end
end
local render = function(grid)
	local q
	for y = 1, #grid do
		for x = 1, #grid[y] do
			q = grid[y][x]
			if q then
				term.setCursorPos(x,y)
				term.setTextColor(g( between( q.v+1, 1, size ),  q.r ).txt )
				term.setBackgroundColor(g( between(q.v+1,1,size), q.r ).bg )
				term.write(g(between(q.v+1,1,size),q.r).char)
			end
		end
	end
end
local downByOne = function(grid)
	local output = {}
	for y = 1, #grid do
		output[y] = {}
		for x = 1, #grid[y] do
			output[y][x] = {}
			if grid[y][x].v > 0 then
				output[y][x].v = grid[y][x].v - 1
			else
				output[y][x].v = 0
			end
			output[y][x].r = grid[y][x].r
		end
	end
	return output
end
local getInput = function()
	local mx,my,oldx,oldy,dots
	while true do
		local evt = {os.pullEvent()}
		modem = peripheral.find("modem")
		if modem then modem.open(channel) end
		if evt[1] == "key" then
			if evt[2] == keys.q then
				sleep(0)
				return
			end
		elseif evt[1] == "mouse_click" or evt[1] == "mouse_drag" then
			oldx,oldy = mx or evt[3],my or evt[4]
			mx,my = evt[3],evt[4]
			dots = getDotsInLine(oldx,oldy,mx,my)
			for a = 1, #dots do
				grid[dots[a].y][dots[a].x] = {v = size, r = s[p]}
				if modem then
					modem.transmit(channel,channel,{x=dots[a].x, y=dots[a].y, r=s[p]})
				end
			end
		elseif evt[1] == "mouse_up" then
			mx,my = nil,nil
		end
	end
end
local dothRendering = function()
	local t = false --term.current().setVisible
	while true do
		if t then t(false) end
		render(grid)
		if t then t(true) end
		grid = downByOne(grid)
		sleep(0)
	end
end

local funclist = {
	getInput,
	dothRendering,
	getModemInput,
}

parallel.waitForAny(unpack(funclist))