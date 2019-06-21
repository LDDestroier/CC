-- Workspaces for ComputerCraft
-- by LDDestroier

local tArg = {...}

local instances = {}
local configPath = ".workspace_config"

local config = {
	workspaceMoveSpeed = 0.1,
	defaultProgram = "rom/programs/shell.lua",
	timesRan = 0,
	WSmap = {
		{true,true,true},
		{true,true,true},
		{true,true,true},
	}
}

-- values determined after every new/removed workspace
local gridWidth, gridHeight, gridMinX, gridMinY

-- used by argument parser
local argList, argErrors

local getMapSize = function()
	local xmax, xmin, ymax, ymin = -math.huge, math.huge, -math.huge, math.huge
	local isRowEmpty
	for y, v in pairs(config.WSmap) do
		isRowEmpty = true
		for x, vv in pairs(v) do
			if vv then
				xmin = math.min(xmin, x)
				xmax = math.max(xmax, x)
				isRowEmpty = false
			end
		end
		if not isRowEmpty then
			ymin = math.min(ymin, y)
			ymax = math.max(ymax, y)
		end
	end
	return xmax, ymax, xmin, ymin
end

local readFile = function(path)
	local file = fs.open(path, "r")
	local contents = file.readAll()
	file.close()
	return contents
end

local saveConfig = function()
	local file = fs.open(configPath, "w")
	file.write( textutils.serialize(config) )
	file.close()
end

local loadConfig = function()
	if fs.exists(configPath) then
		local contents = readFile(configPath)
		local newConfig = textutils.unserialize(contents)
		for k,v in pairs(newConfig) do
			config[k] = v
		end
	end
end

loadConfig()
saveConfig()

-- lists all keys currently pressed
local keysDown = {}

-- amount of time (seconds) until workspace indicator disappears
local workspaceIndicatorDuration = 0.6

-- if held down while moving workspace, will swap positions
local swapKey = keys.tab

local scr_x, scr_y = term.getSize()
local windowWidth = scr_x
local windowHeight = scr_y
local doDrawWorkspaceIndicator = false

local scroll = {0,0}		-- change this value when scrolling
local realScroll = {0,0}	-- this value changes depending on scroll for smoothness purposes
local focus = {}			-- currently focused instance, declared when loading from config

local isRunning = true

local cwrite = function(text, y, terminal)
	terminal = terminal or term.current()
	local cx, cy = terminal.getCursorPos()
	local sx, sy = terminal.getSize()
	terminal.setCursorPos(sx / 2 - #text / 2, y or (sy / 2))
	terminal.write(text)
end

-- start up lddterm (I'm starting to think I should've used window API)
local lddterm = {}
lddterm.alwaysRender = false		-- renders after any and all screen-changing functions.
lddterm.useColors = true			-- normal computers do not allow color, but this variable doesn't do anything yet
lddterm.baseTerm = term.current()	-- will draw to this terminal
lddterm.transformation = nil		-- will modify the current buffer as an NFT image before rendering
lddterm.cursorTransformation = nil	-- will modify the cursor position
lddterm.drawFunction = nil			-- will draw using this function instead of basic NFT drawing
lddterm.adjustX = 0					-- moves entire screen X
lddterm.adjustY = 0					-- moves entire screen Y
lddterm.selectedWindow = 1			-- determines which window controls the cursor
lddterm.windows = {}				-- internal list of all lddterm windows

-- draws one of three things:
--  1. workspace grid indicator
--  2. "PAUSED" screen
--  3. "UNPAUSED" screen
local drawWorkspaceIndicator = function(terminal, wType)
	gridWidth, gridHeight, gridMinX, gridMinY = getMapSize()
	terminal = terminal or lddterm.baseTerm
	if wType == 1 then
		for y = gridMinY - 1, gridHeight + 1 do
			for x = gridMinX - 1, gridWidth + 1 do
				terminal.setCursorPos((x - gridMinX) + scr_x / 2 - (gridWidth - gridMinX) / 2, (y - gridMinY) + scr_y / 2 - (gridHeight - gridMinY) / 2)
				if instances[y] then
					if instances[y][x] then
						if focus[1] == x and focus[2] == y then
							terminal.blit(" ", "8", "8")
						elseif instances[y][x].active then
							terminal.blit(" ", "7", "7")
						else
							terminal.blit(" ", "0", "f")
						end
					else
						terminal.blit(" ", "0", "0")
					end
				else
					terminal.blit(" ", "0", "0")
				end
			end
		end
	elseif wType == 2 then
		local msg = "PAUSED"
		terminal.setCursorPos(scr_x / 2 - #msg / 2 - 2, scr_y / 2 - 1)
		terminal.blit((" "):rep(#msg + 2), ("f"):rep(#msg + 2), ("0"):rep(#msg + 2))
		terminal.setCursorPos(scr_x / 2 - #msg / 2 - 2, scr_y / 2)
		terminal.blit(" " .. msg .. " ", ("f"):rep(#msg + 2), ("0"):rep(#msg + 2))
		terminal.setCursorPos(scr_x / 2 - #msg / 2 - 2, scr_y / 2 + 1)
		terminal.blit((" "):rep(#msg + 2), ("f"):rep(#msg + 2), ("0"):rep(#msg + 2))
	elseif wType == 3 then
		local msg = "UNPAUSED"
		terminal.setCursorPos(scr_x / 2 - #msg / 2 - 2, scr_y / 2 - 1)
		terminal.blit((" "):rep(#msg + 2), ("f"):rep(#msg + 2), ("0"):rep(#msg + 2))
		terminal.setCursorPos(scr_x / 2 - #msg / 2 - 2, scr_y / 2)
		terminal.blit(" " .. msg .. " ", ("f"):rep(#msg + 2), ("0"):rep(#msg + 2))
		terminal.setCursorPos(scr_x / 2 - #msg / 2 - 2, scr_y / 2 + 1)
		terminal.blit((" "):rep(#msg + 2), ("f"):rep(#msg + 2), ("0"):rep(#msg + 2))
	end
end

-- converts blit colors to colors api, and back
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

-- separates string into table based on divider
local explode = function(div, str, replstr, includeDiv)
	if (div == '') then
		return false
	end
	local pos, arr = 0, {}
	for st, sp in function() return string.find(str, div, pos, false) end do
		table.insert(arr, string.sub(replstr or str, pos, st - 1 + (includeDiv and #div or 0)))
		pos = sp + 1
	end
	table.insert(arr, string.sub(replstr or str, pos))
	return arr
end

-- determines the size of the terminal before rendering always
local determineScreenSize = function()
	scr_x, scr_y = lddterm.baseTerm.getSize()
	lddterm.screenWidth = scr_x
	lddterm.screenHeight = scr_y
end

determineScreenSize()

-- takes two or more windows and checks if the first of them overlap the other(s)
lddterm.checkWindowOverlap = function(window, ...)
	if #lddterm.windows < 2 then
		return false
	end
	local list, win = {...}
	for i = 1, #list do
		win = list[i]
		if win ~= window then

			if (
				window.x < win.x + win.width and
				win.x < window.x + window.width and
				window.y < win.y + win.height and
				win.y < window.y + window.height
			) then
				return true
			end

		end
	end
	return false
end

local fixCursorPos = function()
	local cx, cy
	if lddterm.windows[lddterm.selectedWindow] then
		if lddterm.cursorTransformation then
			cx, cy = lddterm.cursorTransformation(
				lddterm.windows[lddterm.selectedWindow].cursor[1],
				lddterm.windows[lddterm.selectedWindow].cursor[2]
			)
			lddterm.baseTerm.setCursorPos(
				cx + lddterm.windows[lddterm.selectedWindow].x - 1,
				cy + lddterm.windows[lddterm.selectedWindow].y - 1
			)
		else
			lddterm.baseTerm.setCursorPos(
				-1 + lddterm.windows[lddterm.selectedWindow].cursor[1] + lddterm.windows[lddterm.selectedWindow].x,
				lddterm.windows[lddterm.selectedWindow].cursor[2] + lddterm.windows[lddterm.selectedWindow].y - 1
			)
		end
		lddterm.baseTerm.setCursorBlink(lddterm.windows[lddterm.selectedWindow].blink)
	end
end

-- renders the screen with optional transformation function
lddterm.render = function(transformation, drawFunction)
	-- determine new screen size and change lddterm screen to fit
	old_scr_x, old_scr_y = scr_x, scr_y
	determineScreenSize()
	if old_scr_x ~= scr_x or old_scr_y ~= scr_y then
		lddterm.baseTerm.clear()
	end
	local image = lddterm.screenshot()
	if type(transformation) == "function" then
		image = transformation(image)
	end
	if drawFunction then
		drawFunction(image, lddterm.baseTerm)
	else
		for y = 1, #image[1] do
			lddterm.baseTerm.setCursorPos(1 + lddterm.adjustX, y + lddterm.adjustY)
			lddterm.baseTerm.blit(image[1][y], image[2][y], image[3][y])
		end
	end
	if doDrawWorkspaceIndicator then
		drawWorkspaceIndicator(nil, doDrawWorkspaceIndicator)
	end
	fixCursorPos()
end

lddterm.newWindow = function(width, height, x, y, meta)
	meta = meta or {}
	local window = {
		width = math.floor(width),
		height = math.floor(height),
		blink = true,
		cursor = meta.cursor or {1, 1},
		colors = meta.colors or {"0", "f"},
		clearChar = meta.clearChar or " ",
		visible = meta.visible or true,
		x = math.floor(x) or 1,
		y = math.floor(y) or 1,
		buffer = {{},{},{}},
	}
	for y = 1, height do
		window.buffer[1][y] = {}
		window.buffer[2][y] = {}
		window.buffer[3][y] = {}
		for x = 1, width do
			window.buffer[1][y][x] = window.clearChar
			window.buffer[2][y][x] = window.colors[1]
			window.buffer[3][y][x] = window.colors[2]
		end
	end

	window.handle = {}
	window.handle.setCursorPos = function(x, y)
		window.cursor = {x, y}
		fixCursorPos()
	end
	window.handle.getCursorPos = function()
		return window.cursor[1], window.cursor[2]
	end
	window.handle.setCursorBlink = function(blink)
		window.blink = blink or false
	end
	window.handle.getCursorBlink = function()
		return window.blink
	end
	window.handle.scroll = function(amount)
		if amount > 0 then
			for i = 1, amount do
				for c = 1, 3 do
					table.remove(window.buffer[c], 1)
					window.buffer[c][window.height] = {}
					for xx = 1, width do
						window.buffer[c][window.height][xx] = (
							c == 1 and window.clearChar or
							c == 2 and window.colors[1] or
							c == 3 and window.colors[2]
						)
					end
				end
			end
		elseif amount < 0 then
			for i = 1, -amount do
				for c = 1, 3 do
					window.buffer[c][window.height] = nil
					table.insert(window.buffer[c], 1, {})
					for xx = 1, width do
						window.buffer[c][1][xx] = (
							c == 1 and window.clearChar or
							c == 2 and window.colors[1] or
							c == 3 and window.colors[2]
						)
					end
				end
			end
		end
		if lddterm.alwaysRender then
			lddterm.render(lddterm.transformation, lddterm.drawFunction)
		end
	end
	window.handle.scrollX = function(amount)
		if amount > 0 then
			for i = 1, amount do
				for c = 1, 3 do
					for y = 1, window.height do
						table.remove(window.buffer[c][y], 1)
						window.buffer[c][y][window.width] = (
							c == 1 and window.clearChar or
							c == 2 and window.colors[1] or
							c == 3 and window.colors[2]
						)
					end
				end
			end
		elseif amount < 0 then
			for i = 1, -amount do
				for c = 1, 3 do
					for y = 1, window.height do
						window.buffer[c][y][window.width] = nil
						table.insert(window.buffer[c][y], 1, (
							c == 1 and window.clearChar or
							c == 2 and window.colors[1] or
							c == 3 and window.colors[2]
						))
					end
				end
			end
		end
		if lddterm.alwaysRender then
			lddterm.render(lddterm.transformation, lddterm.drawFunction)
		end
	end
	window.handle.write = function(text, x, y, ignoreAlwaysRender)
		assert(text ~= nil, "expected string 'text'")
		text = tostring(text)
		local cx = math.floor(tonumber(x) or window.cursor[1])
		local cy = math.floor(tonumber(y) or window.cursor[2])
		text = text:sub(math.max(0, -cx - 1))
		for i = 1, #text do
			if cx >= 1 and cx <= window.width and cy >= 1 and cy <= window.height then
				window.buffer[1][cy][cx] = text:sub(i,i)
				window.buffer[2][cy][cx] = window.colors[1]
				window.buffer[3][cy][cx] = window.colors[2]
			end
			cx = math.min(cx + 1, window.width + 1)
		end
		window.cursor = {cx, cy}
		if lddterm.alwaysRender and not ignoreAlwaysRender then
			lddterm.render(lddterm.transformation, lddterm.drawFunction)
		end
	end
	window.handle.writeWrap = function(text, x, y, ignoreAlwaysRender)
		local words = explode(" ", text, nil, true)
		local cx, cy = x or window.cursor[1], y or window.cursor[2]
		for i = 1, #words do
			if cx + #words[i] > window.width + 1 then
				cx = 1
				if cy >= window.height then
					window.handle.scroll(1)
					cy = window.height
				else
					cy = cy + 1
				end
			end
			window.handle.write(words[i], cx, cy, true)
			cx = cx + #words[i]
		end
		if lddterm.alwaysRender and not ignoreAlwaysRender then
			lddterm.render(lddterm.transformation, lddterm.drawFunction)
		end
	end
	window.handle.blit = function(char, textCol, backCol, x, y)
		if type(char) == "number" then
			char = tostring(char)
		end
		if type(textCol) == "number" then
			textCol = tostring(textCol)
		end
		if type(backCol) == "number" then
			backCol = tostring(backCol)
		end
		assert(char ~= nil, "expected string 'char'")
		local cx = math.floor(tonumber(x) or window.cursor[1])
		local cy = math.floor(tonumber(y) or window.cursor[2])
		char = char:sub(math.max(0, -cx - 1))
		for i = 1, #char do
			if cx >= 1 and cx <= window.width and cy >= 1 and cy <= window.height then
				window.buffer[1][cy][cx] = char:sub(i,i)
				window.buffer[2][cy][cx] = textCol:sub(i,i)
				window.buffer[3][cy][cx] = backCol:sub(i,i)
			end
			cx = cx + 1
		end
		window.cursor = {cx, cy}
		if lddterm.alwaysRender and not ignoreAlwaysRender then
			lddterm.render(lddterm.transformation, lddterm.drawFunction)
		end
	end
	window.handle.print = function(text, x, y)
		text = text and tostring(text)
		window.handle.write(text, x, y, true)
		window.cursor[1] = 1
		if window.cursor[2] >= window.height then
			window.handle.scroll(1)
		else
			window.cursor[2] = window.cursor[2] + 1
			if lddterm.alwaysRender then
				lddterm.render(lddterm.transformation, lddterm.drawFunction)
			end
		end
	end
	window.handle.clear = function(char, ignoreAlwaysRender)
		local cx = 1
		for y = 1, window.height do
			for x = 1, window.width do
				if char then
					cx = (x % #char) + 1
				end
				window.buffer[1][y][x] = char and char:sub(cx, cx) or window.clearChar
				window.buffer[2][y][x] = window.colors[1]
				window.buffer[3][y][x] = window.colors[2]
			end
		end
		if lddterm.alwaysRender and not ignoreAlwaysRender then
			lddterm.render(lddterm.transformation, lddterm.drawFunction)
		end
	end
	window.handle.clearLine = function(cy, char, ignoreAlwaysRender)
		cy = math.floor(cy or window.cursor[2])
		local cx = 1
		for x = 1, window.width do
			if char then
				cx = (x % #char) + 1
			end
			window.buffer[1][cy or window.cursor[2]][x] = char and char:sub(cx, cx) or window.clearChar
			window.buffer[2][cy or window.cursor[2]][x] = window.colors[1]
			window.buffer[3][cy or window.cursor[2]][x] = window.colors[2]
		end
		if lddterm.alwaysRender and not ignoreAlwaysRender then
			lddterm.render(lddterm.transformation, lddterm.drawFunction)
		end
	end
	window.handle.clearColumn = function(cx, char, ignoreAlwaysRender)
		cx = math.floor(cx)
		char = char and char:sub(1,1)
		for y = 1, window.height do
			window.buffer[1][y][cx or window.cursor[1]] = char and char or window.clearChar
			window.buffer[2][y][cx or window.cursor[1]] = window.colors[1]
			window.buffer[3][y][cx or window.cursor[1]] = window.colors[2]
		end
		if lddterm.alwaysRender and not ignoreAlwaysRender then
			lddterm.render(lddterm.transformation, lddterm.drawFunction)
		end
	end
	window.handle.getSize = function()
		return window.width, window.height
	end
	window.handle.isColor = function()
		return lddterm.useColors
	end
	window.handle.isColour = window.handle.isColor
	window.handle.setTextColor = function(color)
		if to_blit[color] then
			window.colors[1] = to_blit[color]
		end
	end
	window.handle.setTextColour = window.handle.setTextColor
	window.handle.setBackgroundColor = function(color)
		if to_blit[color] then
			window.colors[2] = to_blit[color]
		end
	end
	window.handle.setBackgroundColour = window.handle.setBackgroundColor
	window.handle.getTextColor = function()
		return to_colors[window.colors[1]] or colors.white
	end
	window.handle.getTextColour = window.handle.getTextColor
	window.handle.getBackgroundColor = function()
		return to_colors[window.colors[2]] or colors.black
	end
	window.handle.getBackgroundColour = window.handle.getBackgroundColor
	window.handle.reposition = function(x, y)
		window.x = math.floor(x or window.x)
		window.y = math.floor(y or window.y)
		if lddterm.alwaysRender then
			lddterm.render(lddterm.transformation, lddterm.drawFunction)
		end
	end
	window.handle.setPaletteColor = function(...)
		return lddterm.baseTerm.setPaletteColor(...)
	end
	window.handle.setPaletteColour = window.handle.setPaletteColor
	window.handle.getPaletteColor = function(...)
		return lddterm.baseTerm.getPaletteColor(...)
	end
	window.handle.getPaletteColour = window.handle.getPaletteColor
	window.handle.getPosition = function()
		return window.x, window.y
	end
	window.handle.restoreCursor = function()
		lddterm.baseTerm.setCursorPos(
			-1 + window.cursor[1] + window.x,
			window.cursor[2] + window.y - 1
		)
	end
	window.handle.setVisible = function(visible)
		window.visible = visible or false
	end

	window.handle.redraw = lddterm.render
	window.handle.current = window.handle

	window.layer = #lddterm.windows + 1
	lddterm.windows[window.layer] = window

	return window, window.layer
end

lddterm.setLayer = function(window, _layer)
	local layer = math.max(1, math.min(#lddterm.windows, _layer))

	local win = window
	table.remove(lddterm.windows, win.layer)
	table.insert(lddterm.windows, layer, win)

	if lddterm.alwaysRender then
		lddterm.render(lddterm.transformation, lddterm.drawFunction)
	end
	return true
end

local old_scr_x, old_scr_y

-- gets screenshot of whole lddterm desktop, OR a single window
lddterm.screenshot = function(window)
	local output = {{},{},{}}
	local line
	if window then
		for y = 1, #window.buffer do
			line = {"","",""}
			for x = 1, #window.buffer do
				line = {
					line[1] .. window.buffer[1][y][x],
					line[2] .. window.buffer[2][y][x],
					line[3] .. window.buffer[3][y][x]
				}
			end
			output[1][y] = line[1]
			output[2][y] = line[2]
			output[3][y] = line[3]
		end
	else
		for y = 1, scr_y do
			line = {"","",""}
			for x = 1, scr_x do

				c = " "
				lt, lb = t, b
				t, b = "0", "f"
				for l, v in pairs(lddterm.windows) do
					if lddterm.windows[l] then
						if lddterm.windows[l].visible then
							sx = 1 + x - lddterm.windows[l].x
							sy = 1 + y - lddterm.windows[l].y
							if lddterm.windows[l].buffer[1][sy] then
								if lddterm.windows[l].buffer[1][sy][sx] then
									c = lddterm.windows[l].buffer[1][sy][sx] or c
									t = lddterm.windows[l].buffer[2][sy][sx] or t
									b = lddterm.windows[l].buffer[3][sy][sx] or b
									break
								end
							end
						end
					end
				end
				line = {
					line[1] .. c,
					line[2] .. t,
					line[3] .. b
				}
			end
			output[1][y] = line[1]
			output[2][y] = line[2]
			output[3][y] = line[3]
		end
	end
	return output
end

local newInstance = function(x, y, program, initialStart)
	x, y = math.floor(x), math.floor(y)
	if instances[y] then
		if instances[y][x] then
			return
		end
	end
	gridWidth, gridHeight, gridMinX, gridMinY = getMapSize()
	for yy = gridMinY, y do
		instances[yy] = instances[yy] or {}
	end
	instances[y] = instances[y] or {}
	for xx = gridMinX, x do
		instances[y][xx] = instances[y][xx] or false
	end
	local window = lddterm.newWindow(windowWidth, windowHeight, 1, 1)

	local func = function()
		term.redirect(window.handle)

		local runProgram = function()
			instances[y][x].paused = false
			if not instances[y][x].program or type(instances[y][x].program) == "string" then
				pcall(loadfile(instances[y][x].program, nil, nil, instances[y][x].env))
			elseif type(instances[y][x].program) == "function" then
				pcall(function() load(instances[y][x].program, nil, nil, instances[y][x].env) end)
			end
		end

		local evt
		while true do

			if initialStart then
				runProgram()
			end

			instances[y][x].active = false
			instances[y][x].paused = false
			instances[y][x].program = config.defaultProgram

			term.clear()
			term.setCursorBlink(false)
			cwrite("This workspace is inactive.", 0 + scr_y / 2)
			cwrite("Press SPACE to start the workspace.", 1 + scr_y / 2)

			coroutine.yield()

			repeat
				evt = {os.pullEventRaw()}
			until (evt[1] == "key" and evt[2] == keys.space) or evt[1] == "terminate"
			sleep(0)
			if evt[1] == "terminate" then
				isRunning = false
				return
			end

			term.setCursorPos(1,1)
			term.clear()
			term.setCursorBlink(true)

			instances[y][x].active = true

			if not initialStart then
				runProgram()
			end

		end
	end

	instances[y][x] = {
		x = x,
		y = y,
		active = initialStart,
		program = program or config.defaultProgram,
		window = window,
		timer = {},
		clockMod = 0,
		lastClock = 0,
		extraEvents = {},
		paused = false
	}

	instances[y][x].env = {}
	setmetatable(instances[y][x].env, {__index = _ENV})

	instances[y][x].co = coroutine.create(func)
end

-- prevents wiseassed-ness
config.workspaceMoveSpeed = math.min(math.max(config.workspaceMoveSpeed, 0.001), 1)

local tickDownInstanceTimers = function(x, y)
	timersToDelete = {}
	for id, duration in pairs(instances[y][x].timer) do
		if duration <= 0.05 then
			instances[y][x].extraEvents[#instances[y][x].extraEvents + 1] = {"timer", id}
			timersToDelete[#timersToDelete + 1] = id
		else
			instances[y][x].timer[id] = duration - 0.05
		end
	end
	for i = 1, #timersToDelete do
		instances[y][x].timer[timersToDelete[i]] = nil
	end
end

local scrollWindows = function(doScrollWindows, tickDownTimers)
	local changed = false
	local timersToDelete = {}
	if doScrollWindows then
		if realScroll[1] < scroll[1] then
			realScroll[1] = math.min(realScroll[1] + config.workspaceMoveSpeed, scroll[1])
			changed = true
		elseif realScroll[1] > scroll[1] then
			realScroll[1] = math.max(realScroll[1] - config.workspaceMoveSpeed, scroll[1])
			changed = true
		end
		if realScroll[2] < scroll[2] then
			realScroll[2] = math.min(realScroll[2] + config.workspaceMoveSpeed, scroll[2])
			changed = true
		elseif realScroll[2] > scroll[2] then
			realScroll[2] = math.max(realScroll[2] - config.workspaceMoveSpeed, scroll[2])
			changed = true
		end
	end
	gridWidth, gridHeight, gridMinX, gridMinY = getMapSize()
	for y = gridMinY, gridHeight do
		if instances[y] then
			for x = gridMinX, gridWidth do
				if instances[y][x] then

					instances[y][x].window.x = math.floor(1 + (instances[y][x].x + realScroll[1] - 1) * scr_x)
					instances[y][x].window.y = math.floor(1 + (instances[y][x].y + realScroll[2] - 1) * scr_y)
					if not instances[y][x].paused then
						tickDownInstanceTimers(x, y)
					end

				end
			end
		end
	end
	return changed
end

local swapInstances = function(xmod, ymod)
	for k,v in pairs(instances[focus[2]][focus[1]]) do
		if k ~= "x" and k ~= "y" then
			instances[focus[2]][focus[1]][k], instances[focus[2] + ymod][focus[1] + xmod][k] = instances[focus[2] + ymod][focus[1] + xmod][k], instances[focus[2]][focus[1]][k]
		end
	end
end

local addWorkspace = function(xmod, ymod)
	config.WSmap[focus[2] + ymod] = config.WSmap[focus[2] + ymod] or {}
	if not config.WSmap[focus[2] + ymod][focus[1] + xmod] then
		config.WSmap[focus[2] + ymod][focus[1] + xmod] = true
		newInstance(focus[1] + xmod, focus[2] + ymod, config.defaultProgram, false)
		saveConfig()
		gridWidth, gridHeight, gridMinX, gridMinY = getMapSize()
	else
--		print("There's already a workspace there.")
	end
end

local removeWorkspace = function(xmod, ymod)
	if config.WSmap[focus[2] + ymod][focus[1] + xmod] then
		local good = false
		for y = -1, 1 do
			for x = -1, 1 do
				if math.abs(x) + math.abs(y) == 1 then
					if instances[focus[2] + y] then
						if instances[focus[2] + y][focus[1] + x] then
							good = true
							break
						end
					end
				end
			end
			if good then
				break
			end
		end
		if good then
			lddterm.windows[instances[focus[2] + ymod][focus[1] + xmod].window.layer] = nil
			config.WSmap[focus[2] + ymod][focus[1] + xmod] = nil
			instances[focus[2] + ymod][focus[1] + xmod] = nil
			local isRowEmpty
			local remList = {}
			for y, v in pairs(config.WSmap) do
				isRowEmpty = true
				for x, vv in pairs(v) do
					if vv then
						isRowEmpty = false
						break
					end
				end
				if isRowEmpty then
					remList[#remList + 1] = y
				end
			end
			for i = 1, #remList do
				config.WSmap[remList[i]] = nil
			end
			saveConfig()
			gridWidth, gridHeight, gridMinX, gridMinY = getMapSize()
		end
	else
--		print("There's no such workspace.")
	end
end

local displayHelp = function()
	cwrite("CTRL+SHIFT+ARROW to switch workspace.   ",	-3 + scr_y / 2)
	cwrite("CTRL+SHIFT+TAB+ARROW to swap.           ",	-2 + scr_y / 2)
	cwrite("CTRL+SHIFT+[WASD] to create a workspace ",	-1 + scr_y / 2)
	cwrite(" up/left/down/right respectively.       ",	 0 + scr_y / 2)
	cwrite("CTRL+SHIFT+P to pause a workspace.      ",	 1 + scr_y / 2)
	cwrite("CTRL+SHIFT+Q to delete a workspace.     ",	 2 + scr_y / 2)
	cwrite("Terminate an inactive workspace to exit.",	 3 + scr_y / 2)
end

local inputEvt = {
	key = true,
	key_up = true,
	char = true,
	mouse_click = true,
	mouse_scroll = true,
	mouse_drag = true,
	mouse_up = true,
	paste = true,
	terminate = true
}

local checkIfCanRun = function(evt, x, y)
	return (
		justStarted or (
			(not instances[y][x].paused) and (
				not instances[y][x].eventFilter or
				instances[y][x].eventFilter == evt[1] or
				evt[1] == "terminate"
			) and (
				(not inputEvt[evt[1]]) and
				instances[y][x].active or (
					x == focus[1] and
					y == focus[2]
				) or
				evt[1] == "terminate"
			)
		)
	)
end

local main = function()
	local enteringCommand
	local justStarted = true
	local tID, wID
	local pCounter, program = 0
	local oldOSreplace = {}	-- used when replacing certain os functions per-instance

	for y, v in pairs(config.WSmap) do
		for x, vv in pairs(v) do
			pCounter = pCounter + 1
			if vv then
				if not focus[1] then
					focus = {x, y}
				end
				program = (argList[pCounter] and fs.exists(argList[pCounter])) and argList[pCounter] or config.defaultProgram
				newInstance(x, y, program, x == focus[1] and y == focus[2])
			end
		end
	end

	scrollWindows(true, false)

	term.clear()
	if config.timesRan <= 0 then
		displayHelp()
		sleep(0.1)
		os.pullEvent("key")

		os.queueEvent("mouse_click", 0, 0, 0)
	end

	config.timesRan = config.timesRan + 1
	saveConfig()

	local previousTerm, cSuccess

	local setInstanceSpecificFunctions = function(x, y)
		os.startTimer = function(duration)
			local t
			while true do
				t = math.random(1, 2^30)
				if not instances[y][x].timer[t] then
					instances[y][x].timer[t] = math.floor(duration * 20) / 20
					return t
				end
			end
		end
		os.cancelTimer = function(id)
			instances[y][x].timer[id] = nil
		end
		os.clock = function()
			return oldOSreplace.clock() + instances[y][x].clockMod
		end
	end

	-- timer for instance timers and window scrolling
	tID = os.startTimer(0.05)

	-- if true, timer events won't be accepted by instances (unless it's an extraEvent)
	local banTimerEvent

	while isRunning do
		gridWidth, gridHeight, gridMinX, gridMinY = getMapSize()
		local evt = {os.pullEventRaw()}
		enteringCommand = false
		if evt[1] == "key" then
			keysDown[evt[2]] = true
		elseif evt[1] == "key_up" then
			keysDown[evt[2]] = nil
		elseif evt[1] == "timer" then
			if evt[2] == wID then
				enteringCommand = true
				doDrawWorkspaceIndicator = false
				banTimerEvent = true
			else
				if evt[2] == tID then
					banTimerEvent = true
					tID = os.startTimer(0.05)
					scrollWindows(true, true)
				else
					banTimerEvent = false
					scrollWindows(false, true)
				end
			end
		end

		if (keysDown[keys.leftCtrl] or keysDown[keys.rightCtrl]) and (keysDown[keys.leftShift] or keysDown[keys.rightShift]) then
			if evt[1] == "key" and evt[2] == keys.p then
				if instances[focus[2]][focus[1]].active then
					instances[focus[2]][focus[1]].paused = not instances[focus[2]][focus[1]].paused
					enteringCommand = true
					doDrawWorkspaceIndicator = instances[focus[2]][focus[1]].paused and 2 or 3
					wID = os.startTimer(workspaceIndicatorDuration)
					if instances[focus[2]][focus[1]].paused then
						instances[focus[2]][focus[1]].lastClock = os.clock() + instances[focus[2]][focus[1]].clockMod
					else
						instances[focus[2]][focus[1]].clockMod = instances[focus[2]][focus[1]].lastClock - os.clock()
					end
				end
			end
			if keysDown[keys.left] then
				if instances[focus[2]][focus[1] - 1] then
					if keysDown[swapKey] then
						swapInstances(-1, 0)
					end
					focus[1] = focus[1] - 1
					scroll[1] = scroll[1] + 1
					keysDown[keys.left] = false
				end
				doDrawWorkspaceIndicator = 1
				wID = os.startTimer(workspaceIndicatorDuration)
				enteringCommand = true
			end
			if keysDown[keys.right] then
				if instances[focus[2]][focus[1] + 1] then
					if keysDown[swapKey] then
						swapInstances(1, 0)
					end
					focus[1] = focus[1] + 1
					scroll[1] = scroll[1] - 1
					keysDown[keys.right] = false
				end
				doDrawWorkspaceIndicator = 1
				wID = os.startTimer(workspaceIndicatorDuration)
				enteringCommand = true
			end
			if keysDown[keys.up] then
				if instances[focus[2] - 1] then
					if instances[focus[2] - 1][focus[1]] then
						if keysDown[swapKey] then
							swapInstances(0, -1)
						end
						focus[2] = focus[2] - 1
						scroll[2] = scroll[2] + 1
						keysDown[keys.up] = false
					end
				end
				doDrawWorkspaceIndicator = 1
				wID = os.startTimer(workspaceIndicatorDuration)
				enteringCommand = true
			end
			if keysDown[keys.down] then
				if instances[focus[2] + 1] then
					if instances[focus[2] + 1][focus[1]] then
						if keysDown[swapKey] then
							swapInstances(0, 1)
						end
						focus[2] = focus[2] + 1
						scroll[2] = scroll[2] - 1
						keysDown[keys.down] = false
					end
				end
				doDrawWorkspaceIndicator = 1
				wID = os.startTimer(workspaceIndicatorDuration)
				enteringCommand = true
			end
			if keysDown[keys.w] then
				addWorkspace(0, -1)
				doDrawWorkspaceIndicator = 1
				wID = os.startTimer(workspaceIndicatorDuration)
				keysDown[keys.w] = false
				gridWidth, gridHeight, gridMinX, gridMinY = getMapSize()
			end
			if keysDown[keys.s] then
				addWorkspace(0, 1)
				doDrawWorkspaceIndicator = 1
				wID = os.startTimer(workspaceIndicatorDuration)
				keysDown[keys.s] = false
				gridWidth, gridHeight, gridMinX, gridMinY = getMapSize()
			end
			if keysDown[keys.a] then
				addWorkspace(-1, 0)
				doDrawWorkspaceIndicator = 1
				wID = os.startTimer(workspaceIndicatorDuration)
				keysDown[keys.a] = false
				gridWidth, gridHeight, gridMinX, gridMinY = getMapSize()
			end
			if keysDown[keys.d] then
				addWorkspace(1, 0)
				doDrawWorkspaceIndicator = 1
				wID = os.startTimer(workspaceIndicatorDuration)
				keysDown[keys.d] = false
				gridWidth, gridHeight, gridMinX, gridMinY = getMapSize()
			end
			if keysDown[keys.q] then
				removeWorkspace(0, 0)
				doDrawWorkspaceIndicator = 1
				wID = os.startTimer(workspaceIndicatorDuration)
				keysDown[keys.q] = false
				local good = false
				for y = -1, 1 do
					for x = -1, 1 do
						if math.abs(x) + math.abs(y) == 1 then
							if instances[focus[2] + y] then
								if instances[focus[2] + y][focus[1] + x] then
									focus = {
										focus[1] + x,
										focus[2] + y
									}
									scroll = {
										scroll[1] - x,
										scroll[2] - y
									}
									good = true
									break
								end
							end
						end
					end
					if good then
						break
					end
				end
				gridWidth, gridHeight, gridMinX, gridMinY = getMapSize()
			end
		end

		if not enteringCommand then

			oldOSreplace.startTimer = os.startTimer
			oldOSreplace.cancelTimer = os.cancelTimer
			oldOSreplace.clock = os.clock

			for y = gridMinY, gridHeight do
				if instances[y] then
					for x = gridMinX, gridWidth do
						if instances[y][x] then
							if #instances[y][x].extraEvents ~= 0 then
								for i = 1, #instances[y][x].extraEvents do
									if checkIfCanRun(instances[y][x].extraEvents[i], x, y) then
										previousTerm = term.redirect(instances[y][x].window.handle)
										setInstanceSpecificFunctions(x, y)
										cSuccess, instances[y][x].eventFilter = coroutine.resume(instances[y][x].co, table.unpack(instances[y][x].extraEvents[i]))
										term.redirect(previousTerm)
									else
										break
									end
								end
								instances[y][x].extraEvents = {}
							end

							if justStarted or (checkIfCanRun(evt, x, y) and not (banTimerEvent and evt[1] == "timer")) then
								previousTerm = term.redirect(instances[y][x].window.handle)
								setInstanceSpecificFunctions(x, y)
								cSuccess, instances[y][x].eventFilter = coroutine.resume(instances[y][x].co, table.unpack(evt))
								term.redirect(previousTerm)
							end

						end
					end
				end
			end

			os.startTimer = oldOSreplace.startTimer
			os.cancelTimer = oldOSreplace.cancelTimer
			os.clock = oldOSreplace.clock
		end

		lddterm.selectedWindow = instances[focus[2]][focus[1]].window.layer
		lddterm.render()
		justStarted = false

	end
end

local function interpretArgs(tInput, tArgs)
	local output = {}
	local errors = {}
	local usedEntries = {}
	for aName, aType in pairs(tArgs) do
		output[aName] = false
		for i = 1, #tInput do
			if not usedEntries[i] then
				if tInput[i] == aName and not output[aName] then
					if aType then
						usedEntries[i] = true
						if type(tInput[i+1]) == aType or type(tonumber(tInput[i+1])) == aType then
							usedEntries[i+1] = true
							if aType == "number" then
								output[aName] = tonumber(tInput[i+1])
							else
								output[aName] = tInput[i+1]
							end
						else
							output[aName] = nil
							errors[1] = errors[1] and (errors[1] + 1) or 1
							errors[aName] = "expected " .. aType .. ", got " .. type(tInput[i+1])
						end
					else
						usedEntries[i] = true
						output[aName] = true
					end
				end
			end
		end
	end
	for i = 1, #tInput do
		if not usedEntries[i] then
			output[#output+1] = tInput[i]
		end
	end
	return output, errors
end

local argData = {
	["--help"] = false,
	["-h"] = false,
	["--config"] = false,
	["-c"] = false
}

argList, argErrors = interpretArgs({...}, argData)

if argList["--help"] or argList["-h"] then
	displayHelp()
	write("\n")
	return
elseif argList["--config"] or argList["-c"] then
	shell.run("rom/programs/edit.lua", configPath)
	return
end

if _G.currentlyRunningWorkspace then
	print("Workspace is already running.")
	return
else
	_G.currentlyRunningWorkspace = true
end

_G.instances = instances

local result, message = pcall(main)

_G.currentlyRunningWorkspace = false

term.clear()
term.setCursorPos(1,1)
if result then
	print("Thanks for using Workspace!")
else
	print("There was an error, and Workspace had to stop.")
	print("The error goes as follows:\n")
	print(message)
end
