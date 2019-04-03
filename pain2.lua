-- pain2

local scr_x, scr_y = term.getSize()
local mx, my = scr_x/2, scr_y/2
local keysDown = {}
local miceDown = {}

-- debug renderer is slower, but the normal one isn't functional yet
local useDebugRenderer = false

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
	brushSize = 2,
	barmsg = "Started PAIN.",
	barlife = 12,
	showBar = true,
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

local setBarMsg = function(message)
	pain.barmsg = message
	pain.barlife = 16
	pain.doRender = true
end

local control = {
	scrollUp = { -- decrease scrollY
		key = keys.up,
		modifiers = {},
	},
	scrollDown = {
		key = keys.down,
		modifiers = {},
	},
	scrollLeft = {
		key = keys.left,
		modifiers = {},
	},
	scrollRight = {
		key = keys.right,
		modifiers = {},
	},
	resetScroll = {
		key = keys.a,
		modifiers = {},
	},
	switchNextFrame = {
		key = keys.plus,
		modifiers = {},
	},
	moveMod = {
		key = keys.leftShift,
		modifiers = {},
	},
	creepMod = {
		key = keys.leftAlt,
		modifiers = {},
	},
	toolSelect = {
		key = keys.leftShift,
		modifiers = {},
	},
	pencilTool = {
		key = keys.p,
		modifiers = {
			[keys.leftShift] = true
		},
	},
	brushTool = {
		key = keys.b,
		modifiers = {
			[keys.leftShift] = true
		},
	},
	textTool = {
		key = keys.t,
		modifiers = {
			[keys.leftShift] = true
		},
	},
}

local checkControl = function(name)
	local modlist = {
		[keys.leftCtrl] = keysDown[keys.leftCtrl],
		[keys.rightCtrl] = keysDown[keys.rightCtrl],
		[keys.leftShift] = keysDown[keys.leftShift],
		[keys.rightShift] = keysDown[keys.rightShift],
		[keys.leftAlt] = keysDown[keys.leftAlt],
		[keys.rightAlt] = keysDown[keys.rightAlt],
	}
	for k,down in pairs(modlist) do
		if control[name].modifiers[k] then
			if not down then
				return false
			end
		else
			if down then
				return false
			end
		end
	end
	return keysDown[control[name].key]
end

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

-- deletes a dot on the canvas, fool
local deleteDot = function(x, y, frame)
	if canvas[frame][1][y] then
		if canvas[frame][1][y][x] then
			canvas[frame][1][y][x] = nil
			canvas[frame][2][y][x] = nil
			canvas[frame][3][y][x] = nil
		end
	end
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

local getGridAtPos = function(x, y)
	local grid = {
		{"%","%",".","."},
		{"%","%",".","."},
		{"%","%",".","."},
		{".",".","%","%"},
		{".",".","%","%"},
		{".",".","%","%"},
	}
	if x < 1 or y < 1 then
		return "/", "7", "f"
	else
		return grid[1 + (2 + y) % #grid][1 + (1 + x) % #grid[1]], "7", "f"
	end
end

-- shows everything on screen
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

		local gChar, gText, gBack
		for yy = y, height do
			buffer[1][yy] = ""
			buffer[2][yy] = ""
			buffer[3][yy] = ""
			if pain.showBar and yy == height then
				buffer[2][yy] = ("f"):rep(width)
				buffer[3][yy] = ("8"):rep(width)
				buffer[1][yy] = ("["..pain.scrollX..","..pain.scrollY.."] "..pain.barmsg..(" "):rep(width)):sub(1, width)
			else
				for xx = x, width do
					cx = xx + pain.scrollX
					cy = yy + pain.scrollY
					if canvas[frame][1][cy] then
						if canvas[frame][1][cy][cx] then
							for c = 1, 3 do
								buffer[c][yy] = buffer[c][yy] .. canvas[frame][c][cy][cx]
							end
						else
							gChar, gText, gBack = getGridAtPos(cx, cy)
							buffer[1][yy] = buffer[1][yy] .. gChar
							buffer[2][yy] = buffer[2][yy] .. gText
							buffer[3][yy] = buffer[3][yy] .. gBack
						end
					else
						gChar, gText, gBack = getGridAtPos(cx, cy)
						buffer[1][yy] = buffer[1][yy] .. gChar
						buffer[2][yy] = buffer[2][yy] .. gText
						buffer[3][yy] = buffer[3][yy] .. gBack
					end
				end
			end
		end
		for yy = 0, height - 1 do
			term.setCursorPos(1, y + yy)
			term.blit(buffer[1][yy+1], buffer[2][yy+1], buffer[3][yy+1])
		end

	end
end

-- every tool at your disposal
local tools = {
	pencil = function(arg)
		if arg.event == "mouse_click" then
			if arg.button == 1 then
				placeDot(arg.sx, arg.sy, frame, arg.dot)
			elseif arg.button == 2 then
				deleteDot(arg.sx, arg.sy, frame)
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
					deleteDot(poses[i].x, poses[i].y, frame)
				end
			end
			dragPos = {arg.sx, arg.sy}
		end
	end,
	brush = function(arg)
		if arg.event == "mouse_click" then
			for y = -arg.size, arg.size do
				for x = -arg.size, arg.size do
					if math.sqrt(x^2 + y^2) <= arg.size / 2 then
						if arg.button == 1 then
							placeDot(arg.sx + x, arg.sy + y, frame, arg.dot)
						elseif arg.button == 2 then
							deleteDot(arg.sx + x, arg.sy + y, frame)
						end
					end
				end
			end
			dragPos = {arg.sx, arg.sy}
		else
			if #dragPos == 0 then
				dragPos = {arg.sx, arg.sy}
			end
			local poses = getDotsInLine(arg.sx, arg.sy, dragPos[1], dragPos[2])
			for i = 1, #poses do
				for y = -arg.size, arg.size do
					for x = -arg.size, arg.size do
						if math.sqrt(x^2 + y^2) <= arg.size / 2 then
							if arg.button == 1 then
								placeDot(poses[i].x + x, poses[i].y + y, frame, arg.dot)
							elseif arg.button == 2 then
								deleteDot(poses[i].x + x, poses[i].y + y, frame)
							end
						end
					end
				end
			end
			dragPos = {arg.sx, arg.sy}
		end
	end,
	text = function(arg)
		pain.paused = true
		pain.barmsg = "Type text to add to canvas."
		pain.barlife = 1
		render(1, 1, scr_x, scr_y)
		term.setCursorPos(arg.x, arg.y)
		term.setTextColor(to_colors[arg.dot[2]])
		term.setBackgroundColor(to_colors[arg.dot[3]])
		local text = read()
		-- re-render every keypress, requires custom read function
		for i = 1, #text do
			placeDot(arg.sx + i - 1, arg.sy, frame, {text:sub(i,i), pain.dots[dot][2], pain.dots[dot][3]})
		end
		pain.paused = false
		keysDown = {}
		miceDown = {}
	end
}

local tryTool = function()
	for butt = 1, 3 do
		if miceDown[butt] and tools[pain.tool] then
			tools[pain.tool]({
				x = miceDown[butt][1],
				y = miceDown[butt][2],
				sx = miceDown[butt][1] + pain.scrollX,
				sy = miceDown[butt][2] + pain.scrollY,
				dot = pain.dots[dot],
				size = pain.brushSize,
				button = butt,
				event = miceDown[butt][3]
			})
			pain.doRender = true
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
	end
end

-- executes everything that doesn't run asynchronously
main = function()
	while true do

		if not pain.paused then
			if pain.doRender then
				render(1, 1, scr_x, scr_y)
				pain.doRender = false
			end

			-- handle scrolling
			if checkControl("resetScroll") then
				pain.scrollX = 0
				pain.scrollY = 0
				pain.doRender = true
			else
				if checkControl("scrollLeft") then
					pain.scrollX = pain.scrollX - 1
					pain.doRender = true
				end
				if checkControl("scrollRight") then
					pain.scrollX = pain.scrollX + 1
					pain.doRender = true
				end
				if checkControl("scrollUp") then
					pain.scrollY = pain.scrollY - 1
					pain.doRender = true
				end
				if checkControl("scrollDown") then
					pain.scrollY = pain.scrollY + 1
					pain.doRender = true
				end
			end

			if checkControl("toolSelect") then
				-- dot palette selection
				if keysDown[keys.one] and pain.dots[1] then
					dot = 1
					setBarMsg("Selected palette " .. dot .. ".")
					pain.doRender = true
				elseif keysDown[keys.two] and pain.dots[2] then
					dot = 2
					setBarMsg("Selected palette " .. dot .. ".")
					pain.doRender = true
				elseif keysDown[keys.three] and pain.dots[3] then
					dot = 3
					setBarMsg("Selected palette " .. dot .. ".")
					pain.doRender = true
				elseif keysDown[keys.four] and pain.dots[4] then
					dot = 4
					setBarMsg("Selected palette " .. dot .. ".")
					pain.doRender = true
				elseif keysDown[keys.five] and pain.dots[5] then
					dot = 5
					setBarMsg("Selected palette " .. dot .. ".")
					pain.doRender = true
				elseif keysDown[keys.six] and pain.dots[6] then
					dot = 6
					setBarMsg("Selected palette " .. dot .. ".")
					pain.doRender = true
				elseif keysDown[keys.seven] and pain.dots[7] then
					dot = 7
					setBarMsg("Selected palette " .. dot .. ".")
					pain.doRender = true
				elseif keysDown[keys.eight] and pain.dots[8] then
					dot = 8
					setBarMsg("Selected palette " .. dot .. ".")
					pain.doRender = true
				elseif keysDown[keys.nine] and pain.dots[9] then
					dot = 9
					setBarMsg("Selected palette " .. dot .. ".")
					pain.doRender = true
				elseif keysDown[keys.zero] and pain.dots[0] then
					dot = 0
					setBarMsg("Selected palette " .. dot .. ".")
					pain.doRender = true
				end
			else
				if checkControl("pencilTool") then
					pain.tool = "pencil"
					setBarMsg("Selected pencil tool.")
				elseif checkControl("textTool") then
					pain.tool = "text"
					setBarMsg("Selected text tool.")
				elseif checkControl("brushTool") then
					pain.tool = "brush"
					setBarMsg("Selected brush tool.")
				end
			end

			pain.barlife = math.max(pain.barlife - 1, 0)
			if pain.barlife == 0 and pain.barmsg ~= "" then
				pain.barmsg = ""
				pain.doRender = true
			end

		end

		sleep(0.05)
	end
end

local keepTryingTools = function()
	while true do
		os.pullEvent()
		tryTool()
	end
end

term.clear()

parallel.waitForAny( main, getInput, keepTryingTools )
