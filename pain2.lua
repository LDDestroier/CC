--[[

 8888888b.     d8888 8888888 888b    888  .d8888b.
 888   Y88b   d88888   888   8888b   888 d88P  Y88b
 888    888  d88P888   888   88888b  888        888
 888   d88P d88P 888   888   888Y88b 888      .d88P
 8888888P' d88P  888   888   888 Y88b888  .od888P"
 888      d88P   888   888   888  Y88888 d88P"
 888     d8888888888   888   888   Y8888 888"
 888    d88P     888 8888888 888    Y888 888888888

Download with:
	wget https://github.com/LDDestroier/CC/raw/master/pain2.lua

To-do:
	* Add more tools, such as Fill or Color Picker.
	* Add an actual menu.
	* Add a help screen, and don't make it as bland-looking as PAIN 1's.
	* Add support for every possible image format under the sun.
	* Add the ability to add/remove layers.

--]]

local pain = {
	running = true,	-- if true, will run. otherwise, quit
	layer = 1,		-- current layer selected
	image = {},		-- table of 2D canvases
	manip = {},		-- basic canvas manipulation functions
	timers = {},	-- built-in timer system
	windows = {},	-- various windows drawn to the screen
}

keys.ctrl = 256
keys.alt = 257
keys.shift = 258

local keysDown = {}
local miceDown = {}

pain.color = {
	char = " ",
	text = "f",
	back = "0"
}

pain.controlHoldCheck = {}	-- used to check if an input has just been used or not
pain.control = {
	quit = {
		key = keys.q,
		holdDown = false,
		modifiers = {
			[keys.leftCtrl] = true
		},
	},
	scrollUp = {
		key = keys.up,
		holdDown = true,
		modifiers = {},
	},
	scrollDown = {
		key = keys.down,
		holdDown = true,
		modifiers = {},
	},
	scrollLeft = {
		key = keys.left,
		holdDown = true,
		modifiers = {},
	},
	scrollRight = {
		key = keys.right,
		holdDown = true,
		modifiers = {},
	},
	singleScroll = {
		key = keys.tab,
		holdDown = true,
		modifiers = {},
	},
	resetScroll = {
		key = keys.a,
		holdDown = false,
		modifiers = {},
	},
	cancelTool = {
		key = keys.space,
		holdDown = false,
		modifiers = {},
	},
	nextTextColor = {
		key = keys.rightBracket,
		holdDown = false,
		modifiers = {
			[keys.shift] = true
		},
	},
	prevTextColor = {
		key = keys.leftBracket,
		holdDown = false,
		modifiers = {
			[keys.shift] = true
		},
	},
	nextBackColor = {
		key = keys.rightBracket,
		holdDown = false,
		modifiers = {},
	},
	prevBackColor = {
		key = keys.leftBracket,
		holdDown = false,
		modifiers = {},
	},
	shiftDotsRight = {
		key = keys.right,
		holdDown = false,
		modifiers = {
			[keys.shift] = true
		}
	},
	shiftDotsLeft = {
		key = keys.left,
		holdDown = false,
		modifiers = {
			[keys.shift] = true
		}
	},
	shiftDotsUp = {
		key = keys.up,
		holdDown = false,
		modifiers = {
			[keys.shift] = true
		}
	},
	shiftDotsDown = {
		key = keys.down,
		holdDown = false,
		modifiers = {
			[keys.shift] = true
		}
	},
	toggleLayerMenu = {
		key = keys.l,
		holdDown = false,
		modifiers = {}
	}
}

local checkControl = function(name, forceHoldDown)
	local modlist = {
		keys.ctrl,
		keys.shift,
		keys.alt,
	}
	for i = 1, #modlist do
		if pain.control[name].modifiers[modlist[i]] then
			if not keysDown[modlist[i]] then
				return false
			end
		else
			if keysDown[modlist[i]] then
				return false
			end
		end
	end
	if pain.control[name].key then
		if keysDown[pain.control[name].key] then
			local holdDown = pain.control[name].holdDown
			if forceHoldDown ~= nil then
				holdDown = forceHoldDown
			end
			if holdDown then
				return true
			else
				if not pain.controlHoldCheck[name] then
					pain.controlHoldCheck[name] = true
					return true
				end
			end
		else
			pain.controlHoldCheck[name] = false
			return false
		end
	end
end

-- stores the native color palettes, in case the current iteration of ComputerCraft doesn't come with term.nativePaletteColor
-- if you're using ATOM, feel free to minimize this whole table
pain.nativePalette = {
	[ 1 ] = {
		0.94117647409439,
		0.94117647409439,
		0.94117647409439,
	},
	[ 2 ] = {
		0.94901961088181,
		0.69803923368454,
		0.20000000298023,
	},
	[ 4 ] = {
		0.89803922176361,
		0.49803921580315,
		0.84705883264542,
	},
	[ 8 ] = {
		0.60000002384186,
		0.69803923368454,
		0.94901961088181,
	},
	[ 16 ] = {
		0.87058824300766,
		0.87058824300766,
		0.42352941632271,
	},
	[ 32 ] = {
		0.49803921580315,
		0.80000001192093,
		0.098039217293262,
	},
	[ 64 ] = {
		0.94901961088181,
		0.69803923368454,
		0.80000001192093,
	},
	[ 128 ] = {
		0.29803922772408,
		0.29803922772408,
		0.29803922772408,
	},
	[ 256 ] = {
		0.60000002384186,
		0.60000002384186,
		0.60000002384186,
	},
	[ 512 ] = {
		0.29803922772408,
		0.60000002384186,
		0.69803923368454,
	},
	[ 1024 ] = {
		0.69803923368454,
		0.40000000596046,
		0.89803922176361,
	},
	[ 2048 ] = {
		0.20000000298023,
		0.40000000596046,
		0.80000001192093,
	},
	[ 4096 ] = {
		0.49803921580315,
		0.40000000596046,
		0.29803922772408,
	},
	[ 8192 ] = {
		0.34117648005486,
		0.65098041296005,
		0.30588236451149,
	},
	[ 16384 ] = {
		0.80000001192093,
		0.29803922772408,
		0.29803922772408,
	},
	[ 32768 ] = {
		0.066666670143604,
		0.066666670143604,
		0.066666670143604,
	}
}

local hexColors = "0123456789abcdef"

-- load Windon't API
-- if you're using ATOM, feel free to minimize this whole function
local windont = require "windont"

windont.default.alwaysRender = false

local scr_x, scr_y = term.getSize()

pain.windows.toolPreview 	= windont.newWindow(1,          1, scr_x, scr_y, {textColor = "-", backColor = "-"})
pain.windows.mainMenu 		= windont.newWindow(1,          1, scr_x, scr_y, {textColor = "-", backColor = "-"})
pain.windows.layerMenu 		= windont.newWindow(scr_x - 20, 1, 20,    scr_y, {textColor = "-", backColor = "-"})
pain.windows.smallPreview 	= windont.newWindow(1,          1, scr_x, scr_y, {textColor = "-", backColor = "-"})
pain.windows.grid 			= windont.newWindow(1,          1, scr_x, scr_y, {textColor = "-", backColor = "-"})

local function tableCopy(tbl)
	local output = {}
	for k, v in next, tbl do
		output[k] = type(v) == "table" and tableCopy(v) or v
	end
	return output
end

pain.startTimer = function(name, duration)
	if type(duration) ~= "number" then
		error("duration must be number")
	elseif type(name) ~= "string" then
		error("name must be string")
	else
		pain.timers[name] = duration
	end
end

pain.cancelTimer = function(name)
	if type(name) ~= "string" then
		error("name must be string")
	else
		pain.timers[name] = nil
	end
end

pain.tickTimers = function()
	local done = {}
	for k,v in next, pain.timers do
		pain.timers[k] = v - 1
		if pain.timers[k] <= 0 then
			done[k] = true
		end
	end
	for k,v in next, done do
		pain.timers[k] = nil
	end
	return done
end

-- a 'canvas' refers to a single layer only
-- canvases are also windon't objects, like terminals


-- stolen from the paintutils API...nwehehehe
local getDotsInLine = function( startX, startY, endX, endY )
	local out = {}
	startX = math.floor(startX)
	startY = math.floor(startY)
	endX = math.floor(endX)
	endY = math.floor(endY)
	if startX == endX and startY == endY then
		out = {{startX, startY}}
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
            out[#out+1] = {x, math.floor(y+0.5)}
            y = y + dy
        end
    else
        local x = minX
        local dx = xDiff / yDiff
        if maxY >= minY then
            for y=minY,maxY do
                out[#out+1] = {math.floor(x+0.5), y}
                x = x + dx
            end
        else
            for y=minY,maxY,-1 do
                out[#out+1] = {math.floor(x+0.5), y}
                x = x - dx
            end
        end
    end
    return out
end

pain.manip.touchDot = function(canvas, x, y)
	for c = 1, 3 do
		canvas.meta.buffer[c][y] = canvas.meta.buffer[c][y] or {}
		for xx = 1, x do
			canvas.meta.buffer[c][y][xx] = canvas.meta.buffer[c][y][xx] or "-"
		end
	end
	return true
end

pain.manip.setDot = function(canvas, x, y, char, text, back)
	if pain.manip.touchDot(canvas, x, y) then
		canvas.meta.buffer[1][y][x] = char
		canvas.meta.buffer[2][y][x] = text
		canvas.meta.buffer[3][y][x] = back
	end
end

pain.manip.setDotLine = function(canvas, x1, y1, x2, y2, char, text, back)
	local dots = getDotsInLine(x1, y1, x2, y2)
	for i = 1, #dots do
		pain.manip.setDot(canvas, dots[i][1], dots[i][2], char, text, back)
	end
end

pain.manip.changePainColor = function(mode, amount, doLoop)
	local cNum = hexColors:find(pain.color[mode])
	local sNum
	if doLoop then
		sNum = ((cNum + amount - 1) % 16) + 1
	else
		sNum = math.min(math.max(cNum + amount, 1), 16)
	end
	pain.color[mode] = hexColors:sub(sNum, sNum)
end

pain.manip.shiftDots = function(canvas, xDist, yDist)
	local output = {{}, {}, {}}
	for c = 1, 3 do
		for y,vy in next, canvas.meta.buffer[c] do
			output[c][y + yDist] = {}
			for x,vx in next, vy do
				output[c][y + yDist][x + xDist] = vx
			end
		end
	end
	canvas.meta.buffer = output
end

local whitespace = {
	["\009"] = true,
	["\010"] = true,
	["\013"] = true,
	["\032"] = true,
	["\128"] = true
}

-- checks if a char/text/back combination should be considered "transparent"
pain.checkTransparent = function(char, text, back)
	if whitespace[char] then
		return (not back) or (back == "-")
	else
		return ((not back) or (back == "-")) and ((not text) or (text == "-") )
	end
end

-- checks if a certain x,y position on the canvas exists
pain.checkDot = function(canvas, x, y)
	if paint.manip.touchDot(canvas, x, y) then
		if canvas[1][y][x] then
			return canvas[1][y][x], canvas[2][y][x], canvas[3][y][x]
		end
	end
end

local tools = {}
tools.pencil = {
	run = function(canvas, initEvent, toolInfo)
		local mx, my, evt = initEvent[3], initEvent[4]
		local oldX, oldY
		local mode = initEvent[2]	-- 1 = draw, 2 = erase
		if keysDown[keys.shift] then
			return tools.line.run(canvas, initEvent, toolInfo)
		else
			local setDot = function()
				pain.manip.setDotLine(
					canvas,
					oldX or (mx - (canvas.meta.x - 1)),
					oldY or (my - (canvas.meta.y - 1)),
					mx - (canvas.meta.x - 1),
					my - (canvas.meta.y - 1),
					mode == 1 and pain.color.char or nil, -- " ",
					mode == 1 and pain.color.text or nil, -- "-",
					mode == 1 and pain.color.back or nil -- "-"
				)
			end
			while miceDown[mode] do
				evt = {os.pullEvent()}
				if evt[1] == "mouse_click" or evt[1] == "mouse_drag" then
					oldX, oldY = mx - (canvas.meta.x - 1), my - (canvas.meta.y - 1)
					mx, my = evt[3], evt[4]
					setDot()
				elseif evt[1] == "refresh" then
					oldX, oldY = mx - (canvas.meta.x - 1), my - (canvas.meta.y - 1)
					setDot()
				end
			end
		end
	end,
	options = {}
}

tools.line = {
	run = function(canvas, initEvent, toolInfo)
		local mx, my, evt = initEvent[3], initEvent[4]
		local initX, initY
		local oldX, oldY
		local mode = initEvent[2]	-- 1 = draw, 2 = erase
		local setDot = function(sCanvas)
			if initX and initY then
				pain.manip.setDotLine(
					sCanvas,
					initX,
					initY,
					mx - (canvas.meta.x - 1),
					my - (canvas.meta.y - 1),
					mode == 1 and pain.color.char or nil, --" ",
					mode == 1 and pain.color.text or nil, -- "-",
					mode == 1 and pain.color.back or nil -- "-"
				)
			end
		end
		toolInfo.showToolPreview = true
		while miceDown[mode] do
			evt = {os.pullEvent()}
			if evt[1] == "mouse_click" or evt[1] == "mouse_drag" then
				oldX, oldY = mx - (canvas.meta.x - 1), my - (canvas.meta.y - 1)
				mx, my = evt[3], evt[4]
				if not (initX and initY) then
					initX = mx - (canvas.meta.x - 1)
					initY = my - (canvas.meta.y - 1)
				end
				setDot(pain.windows.toolPreview)
			elseif evt[1] == "mouse_up" then
				setDot(canvas)
			elseif evt[1] == "refresh" then
				oldX, oldY = mx - (canvas.meta.x - 1), my - (canvas.meta.y - 1)
				setDot(pain.windows.toolPreview)
			end
		end
	end,
	options = {}
}

local genPalette = function()
	local palette = {}
	for i = 0, 15 do
		palette[2^i] = pain.nativePalettes[2^i]
	end
	return palette
end

local newCanvas = function()
	local canvas = windont.newWindow(1, 1, 1, 1, {textColor = "-", backColor = "-"})
	canvas.meta.x = 1
	canvas.meta.y = 1
	return canvas
end

local getGridFromPos = function(x, y, scrollX, scrollY)
	local grid
	if (x >= 0 and y >= 0) then
		grid = {
			"$$..%%..%%..%%..",
			"$$..%%..%%..%%..",
			"$$..%%..%%..%%..",
			"..$$..%%..%%..$$",
			"..$$..%%..%%..$$",
			"..$$..%%..%%..$$",
			"%%..$$..%%..$$..",
			"%%..$$..%%..$$..",
			"%%..$$..%%..$$..",
			"..%%..$$..$$..%%",
			"..%%..$$..$$..%%",
			"..%%..$$..$$..%%",
			"%%..%%..$$..%%..",
			"%%..%%..$$..%%..",
			"%%..%%..$$..%%..",
			"..%%..$$..$$..%%",
			"..%%..$$..$$..%%",
			"..%%..$$..$$..%%",
			"%%..$$..%%..$$..",
			"%%..$$..%%..$$..",
			"%%..$$..%%..$$..",
			"..$$..%%..%%..$$",
			"..$$..%%..%%..$$",
			"..$$..%%..%%..$$",
		}
	else
		if (x < 0 and y >= 0) then
			-- too far to the left, but not too far up
			grid = {
				"GO#RIGHT#",
				"#---\16####",
				"##---\16###",
				"###---\16##",
				"####---\16#",
				"###---\16##",
				"##---\16###",
				"#---\16####",
			}
		elseif (x >= 0 and y < 0) then
			-- too far up, but not too far to the left
			grid = {
				"#GO##DOWN#",
				"#|#######|",
				"#||#####||",
				"#\31||###||\31",
				"##\31||#||\31#",
				"###\31|||\31##",
				"####\31|\31###",
				"#####\31####",
				"##########",
			}
		else
			grid = {
				"\\##\\",
				"\\\\##",
				"#\\\\#",
				"##\\\\",
			}
		end
	end
	local xx = (x % #grid[1]) + 1
	return grid[(y % #grid) + 1]:sub(xx, xx), "7", "f"
end

local drawGrid = function(canvas)
	local xx
	for y = 1, pain.windows.grid.meta.height do
		for x = 1, pain.windows.grid.meta.width do
			pain.windows.grid.meta.buffer[1][y][x], pain.windows.grid.meta.buffer[2][y][x], pain.windows.grid.meta.buffer[3][y][x] = getGridFromPos(x - canvas.meta.x, y - canvas.meta.y)
		end
	end
end

local copyCanvasBuffer = function(buffer, x1, y1, x2, y2)
	local output = {{}, {}, {}}
	for c = 1, 3 do
		for y = y1, y2 do
			output[c][y] = {}
			if buffer[c][y] then
				for x = x1, x2 do
					output[c][y][x] = buffer[c][y][x]
				end
			end
		end
	end
	return output
end

local main = function()
	local render = function(canvasList)
		drawGrid(canvasList[1])
		local rList = {
--			pain.windows.mainMenu,
--			pain.windows.layerMenu,
--			pain.windows.smallPreview,
			pain.windows.toolPreview,
		}
		for i = 1, #canvasList do
			rList[#rList + 1] = canvasList[i]
		end
		rList[#rList + 1] = pain.windows.grid
		windont.render(
			{baseTerm = term.current()},
			table.unpack(rList)
		)
	end
	local canvas, evt
	local tCompleted = {}
	local mainTimer = os.startTimer(0.05)
	local resumeTimer = os.startTimer(0.05)

	pain.startTimer("render", 0.05)

	-- initialize first layer
	pain.image[1] = newCanvas()

	local cTool = {
		name = "pencil",
		lastEvent = nil,
		active = false,
		coroutine = nil,
		doRender = false,			-- if true after resuming the coroutine, renders directly after resuming
		showToolPreview = false		-- if true, will render the tool preview INSTEAD of the current canvas
	}

	local resume = function(newEvent)
		if cTool.coroutine then
			if (cTool.lastEvent == (newEvent or evt[1])) or (not cTool.lastEvent) then
				cTool.doQuickResume = false
				if cTool.showToolPreview then
					pain.windows.toolPreview.meta.buffer = copyCanvasBuffer(
						canvas.meta.buffer,
						-canvas.meta.x,
						-canvas.meta.y,
						-canvas.meta.x + scr_x + 1,
						-canvas.meta.y + scr_y + 1
					)
					pain.windows.toolPreview.meta.x = canvas.meta.x
					pain.windows.toolPreview.meta.y = canvas.meta.y
					pain.windows.toolPreview.meta.width = canvas.meta.width
					pain.windows.toolPreview.meta.height = canvas.meta.height
				end
				cTool.active, cTool.lastEvent = coroutine.resume(cTool.coroutine, table.unpack(newEvent or evt))
			end
			if checkControl("cancelTool") then
				cTool.active = false
			end
			if (not cTool.active) or coroutine.status(cTool.coroutine) == "dead" then
				cTool.active = false
			end
			if not cTool.active then
				if type(cTool.lastEvent) == "string" then
					if cTool.lastEvent:sub(1,4) == "ERR:" then
						error(cTool.lastEvent:sub(5))
					end
				end
				cTool.coroutine = nil
				cTool.lastEvent = nil
				cTool.showToolPreview = false
				pain.windows.toolPreview.clear()
			end
			if cTool.doRender then
				render({canvas})
				cTool.doRender = false
			end
		end
	end

	while pain.running do

		evt = {os.pullEvent()}


		if evt[1] == "timer" and evt[2] == mainTimer then
			mainTimer = os.startTimer(0.05)
			tCompleted = pain.tickTimers()		-- get list of completed pain timers
			canvas = pain.image[pain.layer]		-- 'canvas' is a term object, you smarmy cunt
			for k,v in next, keysDown do keysDown[k] = v + 1 end

			local singleScroll = checkControl("singleScroll")

			if checkControl("quit") then	-- why did I call myself a cunt
				pain.running = false
			end

			if checkControl("scrollRight", not singleScroll) then
				canvas.meta.x = canvas.meta.x - 1
			end

			if checkControl("scrollLeft", not singleScroll) then
				canvas.meta.x = canvas.meta.x + 1
			end

			if checkControl("scrollDown", not singleScroll) then
				canvas.meta.y = canvas.meta.y - 1
			end

			if checkControl("scrollUp", not singleScroll) then
				canvas.meta.y = canvas.meta.y + 1
			end

			if checkControl("shiftDotsRight") then
				pain.manip.shiftDots(canvas, 1, 0)
			end

			if checkControl("shiftDotsLeft") then
				pain.manip.shiftDots(canvas, -1, 0)
			end

			if checkControl("shiftDotsUp") then
				pain.manip.shiftDots(canvas, 0, -1)
			end

			if checkControl("shiftDotsDown") then
				pain.manip.shiftDots(canvas, 0, 1)
			end

			if checkControl("resetScroll") then
				canvas.meta.x = 1
				canvas.meta.y = 1
			end

			if checkControl("nextTextColor") then
				pain.manip.changePainColor("text", 1, false)
			end

			if checkControl("nextBackColor") then
				pain.manip.changePainColor("back", 1, false)
			end

			if checkControl("prevTextColor") then
				pain.manip.changePainColor("text", -1, false)
			end

			if checkControl("prevBackColor") then
				pain.manip.changePainColor("back", -1, false)
			end

			resume({"refresh"})

			if tCompleted.render then
				pain.startTimer("render", 0.05)
				render({cTool.showToolPreview and pain.windows.toolPreview or canvas})
			end

		else

			if evt[1] == "term_resize" then
				scr_x, scr_y = term.getSize()
			elseif evt[1] == "key" or evt[1] == "key_up" then
				if evt[1] == "key" then
					if not evt[3] then
						keysDown[evt[2]] = 0
					end
				elseif evt[1] == "key_up" then
					keysDown[evt[2]] = nil
				end
				keysDown[keys.ctrl] = keysDown[keys.leftCtrl] or keysDown[keys.rightCtrl]
				keysDown[keys.shift] = keysDown[keys.leftShift] or keysDown[keys.rightShift]
				keysDown[keys.alt] = keysDown[keys.leftAlt] or keysDown[keys.rightAlt]
			elseif evt[1] == "mouse_up" then
				miceDown[evt[2]] = nil
			elseif (evt[1] == "mouse_click" or evt[1] == "mouse_drag") then
				miceDown[evt[2]] = {evt[3], evt[4]}
				if evt[1] == "mouse_click" then
					if not cTool.active then
						cTool.coroutine = coroutine.create(function(...)
							local result, message = pcall(tools[cTool.name].run, ...)
							if not result then
								error("ERR:" .. message, 2)
							end
						end)
						cTool.active = coroutine.resume(cTool.coroutine, canvas, evt, cTool)
					end
				end
			end

			resume()

		end

	end

	term.setCursorPos(1, scr_y)
	term.clearLine()

end

main()
