-- pain2

local scr_x, scr_y = term.getSize()
local mx, my = scr_x/2, scr_y/2
local keysDown = {}
local miceDown = {}

-- debug renderer is slower, but the normal one isn't functional yet
local useDebugRenderer = true

local canvas = {
	{{},{},{}}
}
local frame = 1
local dot = 1

local pain = {
	screenWidth = scr_x,
	screenHeight = scr_y,
	scrollX = 0,
	scrollY = 0,
	doRender = true,
	dots = {
		[0] = {
			" ",
			" ",
			" "
		},
		[1] = {
			" ",
			"f",
			"0"
		},
		[2] = {
			" ",
			"f",
			"e"
		},
	},
	tool = "pencil"
}

local control = {
	scrollUp = keys.up,			-- decrease scrollY
	scrollDown = keys.down,		-- increase scrollY
	scrollLeft = keys.left,		-- decrease scrollX
	scrollRight = keys.right,	-- increase scrollX
	moveMod = keys.leftShift,	-- hold to move image instead of scrolling
	creepMod = keys.leftAlt,	-- hold to only scroll/move one dot at a time
	toolSelect = keys.leftShift	-- hold and push specific buttons to quick select tool
}

-- converts hex colors to colors api, and back
local to_colors, to_blit = {
	[' '] = 0,
	['0'] = 1,
	['1'] = 2,
	['2'] = 4,
	['3'] = 8,
	['4'] = 16,
	['5'] = 32,
	['6'] = 64,
	['7'] = 128,
	['8'] = 256,
	['9'] = 512,
	['a'] = 1024,
	['b'] = 2048,
	['c'] = 4096,
	['d'] = 8192,
	['e'] = 16384,
	['f'] = 32768,
}, {}
for k,v in pairs(to_colors) do
	to_blit[v] = k
end

-- takes two coordinates, and returns every point between the two
local getDotsInLine = function( startX, startY, endX, endY )
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
            out[#out+1] = {x=x,y=math.floor(y+0.5)}
            y = y + dy
        end
    else
        local x = minX
        local dx = xDiff / yDiff
        if maxY >= minY then
            for y=minY,maxY do
                out[#out+1] = {x=math.floor(x+0.5),y=y}
                x = x + dx
            end
        else
            for y=minY,maxY,-1 do
                out[#out+1] = {x=math.floor(x+0.5),y=y}
                x = x - dx
            end
        end
    end
    return out
end

-- places a dot on the canvas, predictably enough
local placeDot = function(x, y, frame, dot)
	if not canvas[frame][1][y] then
		canvas[frame][1][y] = {}
		canvas[frame][2][y] = {}
		canvas[frame][3][y] = {}
	end
	canvas[frame][1][y][x] = dot[1]
	canvas[frame][2][y][x] = dot[2]
	canvas[frame][3][y][x] = dot[3]
end

-- used for tools that involve dragging
local dragPos = {}

-- every tool at your disposal
local tools = {
	pencil = function(arg)
		if arg.event == "mouse_click" then
			if arg.button == 1 then
				placeDot(arg.sx, arg.sy, frame, arg.dot)
			elseif arg.button == 2 then
				placeDot(arg.sx, arg.sy, frame, {" "," "," "})
			end
			dragPos = {arg.sx, arg.sy}
		else
			if #dragPos == 0 then
				dragPos = {arg.sx, arg.sy}
			end
			local poses = getDotsInLine(arg.sx, arg.sy, dragPos[1], dragPos[2])
			for i = 1, #poses do
				if arg.button == 1 then
					placeDot(poses[i].x, poses[i].y, frame, arg.dot)
				elseif arg.button == 2 then
					placeDot(poses[i].x, poses[i].y, frame, {" "," "," "})
				end
			end
			dragPos = {arg.sx, arg.sy}
		end
	end,
	text = function(arg)
		term.setCursorPos(arg.x, arg.y)
		term.setTextColor(to_colors[arg.dot[2]])
		term.setBackgroundColor(to_colors[arg.dot[3]])
		local text = read()
		-- re-render every keypress, requires custom read function
		for i = 1, #text do
			placeDot(arg.sx + i - 1, arg.sy, frame, {text:sub(i,i), dot[2], dot[3]})
		end
	end
}

local render = function(x, y, width, height)
	local buffer = {{},{},{}}
	local cx, cy
	-- see, it wouldn't do if I just individually set the cursor position for every dot
	if useDebugRenderer then
		
		term.clear()
		local cx, cy
		for yy, line in pairs(canvas[frame][1]) do
			for xx, dot in pairs(canvas[frame][1][yy]) do
				cx = xx - pain.scrollX
				cy = yy - pain.scrollY
				if cx >= x and cx <= (x + width - 1) and cy >= y and cy <= (x + width - 1) then
					term.setCursorPos(cx, cy)
					term.blit(
						canvas[frame][1][yy][xx],
						canvas[frame][2][yy][xx],
						canvas[frame][3][yy][xx]
					)
				end
			end
		end

	else

		for yy = y, height do
			buffer[1][yy] = ""
			buffer[2][yy] = ""
			buffer[3][yy] = ""
			for xx = x, width do
				cx = xx - pain.scrollX
				cy = yy - pain.scrollY
				for c = 1, 3 do
					buffer[c][yy] = buffer[c][yy] .. canvas[frame][c][cy]:sub(cx,cx)
				end
			end
		end
		for yy = 0, height - 1 do
			for xx = 0, width - 1 do
				term.setCursorPos(x + xx, y + yy)
				term.blit(buffer[1][yy+1], buffer[2][yy+1], buffer[3][yy+1])
			end
		end

	end
end

local tryTool = function()
	for butt = 1, 3 do
		if miceDown[butt] and tools[pain.tool] then
			tools[pain.tool]({
				x = miceDown[butt][1],
				y = miceDown[butt][2],
				sx = miceDown[butt][1] + pain.scrollX,
				sy = miceDown[butt][2] + pain.scrollY,
				dot = pain.dots[dot],
				button = butt,
				event = miceDown[butt][3]
			})
			break
		end
	end
end

getInput = function()
	local evt
	while true do
		evt = {os.pullEvent()}
		if evt[1] == "mouse_click" or evt[1] == "mouse_drag" then
			miceDown[evt[2]] = {evt[3], evt[4], evt[1]}
		elseif evt[1] == "key" then
			keysDown[evt[2]] = true
		elseif evt[1] == "mouse_up" then
			miceDown[evt[2]] = false
		elseif evt[1] == "key_up" then
			keysDown[evt[2]] = false
		end
		tryTool()
	end
end

-- executes everything that doesn't run asynchronously
main = function()
	while true do
		
		render(1, 1, scr_x, scr_y)
		
		-- handle scrolling
		if keysDown[control.scrollLeft] then
			pain.scrollX = pain.scrollX - 1
		end
		if keysDown[control.scrollRight] then
			pain.scrollX = pain.scrollX + 1
		end
		if keysDown[control.scrollUp] then
			pain.scrollY = pain.scrollY - 1
		end
		if keysDown[control.scrollDown] then
			pain.scrollY = pain.scrollY + 1
		end
		
		if keysDown[control.toolSelect] then
			-- dot palette selection
			if keysDown[keys.one] then
				dot = 1
			elseif keysDown[keys.two] then
				dot = 2
			elseif keysDown[keys.three] then
				dot = 3
			elseif keysDown[keys.four] then
				dot = 4
			elseif keysDown[keys.five] then
				dot = 5
			elseif keysDown[keys.six] then
				dot = 6
			elseif keysDown[keys.seven] then
				dot = 7
			elseif keysDown[keys.eight] then
				dot = 8
			elseif keysDown[keys.nine] then
				dot = 9
			elseif keysDown[keys.zero] then
				dot = 0
			end
			-- tool selection
			if keysDown[keys.p] then
				pain.tool = "pencil"
			elseif keysDown[keys.t] then
				pain.tool = "text"
			end
		end

		sleep(0.05)
	end
end

term.clear()

parallel.waitForAny( main, getInput )
