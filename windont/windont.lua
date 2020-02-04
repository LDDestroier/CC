--  Windon't
-- enhanced window API by LDDestroier
-- intended for general use within all me new programs
--
-- Unique features:
--  + Transparency within windows
--  + Built-in window layering

-- stores each base terminal's framebuffers to optimize rendering
local oldScreenBuffer = {}

local table_insert = table.insert
local table_concat = table.concat
local math_floor = math.floor
local to_blit = {}
local to_colors = {}

local table_compare = function(tbl1, tbl2)
	if type(tbl1) ~= "table" or type(tbl2) ~= "table" then
		return tbl1 == tbl2
	else
		for k,v in pairs(tbl1) do
			if tbl1[k] ~= tbl2[k] then
				return false
			end
		end
		for k,v in pairs(tbl2) do
			if tbl1[k] ~= tbl2[k] then
				return false
			end
		end
		return true
	end
end

local getTime = function()
	return 24 * os.day() + os.time()
end

for i = 1, 16 do
	to_blit[2 ^ (i - 1)] = ("0123456789abcdef"):sub(i, i)
	to_colors[("0123456789abcdef"):sub(i, i)] = 2 ^ (i - 1)
end
to_blit[0], to_colors["-"] = "-", 0

local nativePalette = {		-- native palette colors, since some terminals are naughty and don't contain term.nativePaletteColor()
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

-- check if space on screenBuffer is transparent
local checkTransparent = function(buffer, x, y, blitLayer)
	if buffer[blitLayer or 1][y] then
		if blitLayer then
			return (buffer[blitLayer][y][x] and buffer[blitLayer][y][x] ~= "-")
		else
			if (not buffer[2][y][x] or buffer[2][y][x] == "-") and (not buffer[3][y][x] or buffer[3][y][x] == "-") then
				return false
			elseif (not buffer[3][y][x] or buffer[3][y][x] == "-") and (not buffer[1][y][x] or buffer[1][y][x] == " ") then
				return false
			else
				return buffer[1][y][x] and buffer[2][y][x] and buffer[3][y][x]
			end
		end
	end
end

local expect = function(value, default, valueType)
	if value == nil or (valueType and type(value) ~= valueType) then
		return default
	else
		return value
	end
end

local windont = {
	doClearScreen = false,				-- if true, will clear the screen during render
	ignoreUnchangedLines = true,		-- if true, the render function will check each line it renders against the last framebuffer and ignore it if they are the same
	useSetVisible = false,				-- if true, sets the base terminal's visibility to false before rendering
	sameCharWillStencil = false,		-- if true, if one window is layered atop another and both windows have a spot where the character is the same, and the top window's text color is transparent, it will use the TEXT color of the lower window instead of the BACKGROUND color
	default = {
		baseTerm = term.current(),		-- default base terminal for all windows
		textColor = "0",				-- default text color (what " " corresponds to in term.blit's second argument)
		backColor = "f",				-- default background color (what " " corresponds to in term.blit's third argument)
		blink = true,
		visible = true,
		alwaysRender = true,			-- if true, new windows will always render if they are written to
	},
	info = {
		BLIT_CALLS = 0,				-- amount of term.blit calls during the last render
		LAST_RENDER_TIME = 0,		-- last time in which render was called
		LAST_RENDER_AMOUNT = 0,		-- amount of windows drawn during last render
		LAST_RENDER_WINDOWS = {},	-- table of the last window objects that were rendered
	}
}

-- draws one or more windon't objects
-- should not draw over any terminal space that isn't occupied by a window

windont.render = function(options, ...)
--	potential options:
--		number:		onlyX1
--		number:		onlyX2
--		number:		onlyY
--		boolean:	force		(forces render / ignores optimiztaion that compares current framebuffer to old one)
--		terminal:	baseTerm	(forces to render onto this terminal instead of the window's base terminal)

	local windows = {...}
	options = options or {}
	local bT, scr_x, scr_y

	-- checks if "options" is actually the first window, just in case
	if type(options.meta) == "table" then
		if (
			type(options.meta.buffer) == "table" and
			type(options.meta.x) == "number" and
			type(options.meta.y) == "number" and
			type(options.meta.newBuffer) == "function"
		) then
			table_insert(windows, 1, options)
		end
	end

	local screenBuffer = {{}, {}, {}}
	local blitList = {}	-- list of blit commands per line
	local c	= 1 		-- current blitList entry

	local cTime = getTime()

	local AMNT_OF_BLITS = 0	-- how many blit calls are there?

	local cx, cy							-- each window's absolute X and Y
	local char_cx, text_cx, back_cx			-- each window's transformed absolute X's in table form
	local char_cy, text_cy, back_cy			-- each window's transformed absolute X's in table form
	local buffer							-- each window's buffer
	local newChar, newText, newBack			-- if the transformation function declares a new dot, this is it
	local oriChar, oriText, oriBack
	local char_out, text_out, back_out		-- three tables, directly returned from the transformation functions

	local baseTerms = {}
	if type(options.baseTerm) == "table" then
		for i = 1, #windows do
			baseTerms[options.baseTerm] = baseTerms[options.baseTerm] or {}
			baseTerms[options.baseTerm][i] = true
		end
	else
		for i = 1, #windows do
			baseTerms[windows[i].meta.baseTerm] = baseTerms[windows[i].meta.baseTerm] or {}
			baseTerms[windows[i].meta.baseTerm][i] = true
		end
	end

	for bT, bT_list in pairs(baseTerms) do
		if bT == output then
			bT = options.baseTerm or output.meta.baseTerm
		end
		if windont.useSetVisible and bT.setVisible then
			bT.setVisible(false)
		end
		scr_x, scr_y = bT.getSize()
		-- try entire buffer transformations
		for i = #windows, 1, -1 do
			if bT_list[i] then
				if windows[i].meta.metaTransformation then
					-- metaTransformation functions needn't return a value
					windows[i].meta.metaTransformation(windows[i].meta)
				end
			end
		end
		for y = options.onlyY or 1, options.onlyY or scr_y do
			screenBuffer[1][y] = {}
			screenBuffer[2][y] = {}
			screenBuffer[3][y] = {}
			blitList = {}
			c = 1
			for x = options.onlyX1 or 1, math.min(scr_x, options.onlyX2 or scr_x) do
				for i = #windows, 1, -1 do
					if bT_list[i] then
						newChar, newText, newBack = nil
						if windows[i].meta.visible then
							buffer = windows[i].meta.buffer

							cx = 1 + x + -windows[i].meta.x
							cy = 1 + y + -windows[i].meta.y
							char_cx, text_cx, back_cx = cx, cx, cx
							char_cy, text_cy, back_cy = cy, cy, cy

							oriChar = (buffer[1][cy] or {})[cx]
							oriText = (buffer[2][cy] or {})[cx]
							oriBack = (buffer[3][cy] or {})[cx]

							-- try transformation
							if windows[i].meta.transformation then
								char_out, text_out, back_out = windows[i].meta.transformation(cx, cy, oriChar, oriText, oriBack, windows[i].meta)

								if char_out then
									char_cx = math_floor(char_out[1] or cx)
									char_cy = math_floor(char_out[2] or cy)
									if (char_out[1] % 1 ~= 0) or (char_out[2] % 1 ~= 0) then
										newChar = " "
									else
										newChar = char_out[3]
									end
								end

								if text_out then
									text_cx = math_floor(text_out[1] or cx)
									text_cy = math_floor(text_out[2] or cy)
									newText = text_out[3]
								end

								if back_out then
									back_cx = math_floor(back_out[1] or cx)
									back_cy = math_floor(back_out[2] or cy)
									newBack = back_out[3]
								end
							end

							if checkTransparent(buffer, char_cx, char_cy) or checkTransparent(buffer, text_cx, text_cy) or checkTransparent(buffer, back_cx, back_cy) then

								screenBuffer[2][y][x] = newText or checkTransparent(buffer, text_cx, text_cy, 2) and (buffer[2][text_cy][text_cx]) or (
									(buffer[1][text_cy][text_cx] == screenBuffer[1][y][x]) and (windont.sameCharWillStencil) and
										screenBuffer[2][y][x]
									or
										screenBuffer[3][y][x]
									)
								screenBuffer[1][y][x] = newChar or checkTransparent(buffer, char_cx, char_cy   ) and (buffer[1][char_cy][char_cx]) or screenBuffer[1][y][x]
								screenBuffer[3][y][x] = newBack or checkTransparent(buffer, back_cx, back_cy, 3) and (buffer[3][back_cy][back_cx]) or screenBuffer[3][y][x]
							end
						end
					end
				end

				if windont.doClearScreen then
					screenBuffer[1][y][x] = screenBuffer[1][y][x] or " "
				end
				screenBuffer[2][y][x] = screenBuffer[2][y][x] or windont.default.backColor	-- intentionally not the default text color
				screenBuffer[3][y][x] = screenBuffer[3][y][x] or windont.default.backColor

				if checkTransparent(screenBuffer, x, y) then
					if checkTransparent(screenBuffer, -1 + x, y) then
						blitList[c][1] = blitList[c][1] .. screenBuffer[1][y][x]
						blitList[c][2] = blitList[c][2] .. screenBuffer[2][y][x]
						blitList[c][3] = blitList[c][3] .. screenBuffer[3][y][x]
					else
						c = x
						blitList[c] = {
							screenBuffer[1][y][x],
							screenBuffer[2][y][x],
							screenBuffer[3][y][x]
						}
					end
				end
			end
			if (not oldScreenBuffer[bT]) or (not windont.ignoreUnchangedLines) or (options.force) or (
				(not table_compare(screenBuffer[1][y], oldScreenBuffer[bT][1][y])) or
				(not table_compare(screenBuffer[2][y], oldScreenBuffer[bT][2][y])) or
				(not table_compare(screenBuffer[3][y], oldScreenBuffer[bT][3][y]))
			) then
				for k,v in pairs(blitList) do
					bT.setCursorPos(k, y)
					bT.blit(v[1], v[2], v[3])
					AMNT_OF_BLITS = 1 + AMNT_OF_BLITS
				end
			end
		end
		oldScreenBuffer[bT] = screenBuffer
		if windont.useSetVisible and bT.setVisible then
			if not multishell then
				bT.setVisible(true)
			elseif multishell.getFocus() == multishell.getCurrent() then
				bT.setVisible(true)
			end
		end
	end

	windont.info.LAST_RENDER_AMOUNT = #windows
	windont.info.BLIT_CALLS = AMNT_OF_BLITS
	windont.info.LAST_RENDER_WINDOWS = windows
	windont.info.LAST_RENDER_TIME = cTime
	windont.info.LAST_RENDER_DURATION = getTime() + -cTime

end

-- creates a new windon't object that can be manipulated the same as a regular window

windont.newWindow = function( x, y, width, height, misc )

	-- check argument types
	assert(type(x) == "number", "argument #1 must be number, got " .. type(x))
	assert(type(y) == "number", "argument #2 must be number, got " .. type(y))
	assert(type(width) == "number", "argument #3 must be number, got " .. type(width))
	assert(type(height) == "number", "argument #4 must be number, got " .. type(height))

	-- check argument validity
	assert(x > 0, "x position must be above zero")
	assert(y > 0, "y position must be above zero")
	assert(width > 0, "width must be above zero")
	assert(height > 0, "height must be above zero")

	local output = {}
	misc = misc or {}
	local meta = {
		x 				= expect(x, 1),												-- x position of the window
		y 				= expect(y, 1),												-- y position of the window
		width 			= width,															-- width of the buffer
		height			= height,															-- height of the buffer
		buffer 			= expect(misc.buffer, {}, "table"),							-- stores contents of terminal in buffer[1][y][x] format
		renderBuddies 	= expect(misc.renderBuddies, {}, "table"),						-- renders any other window objects stored here after rendering here
		baseTerm 		= expect(misc.baseTerm, windont.default.baseTerm, "table"),	-- base terminal for which this window draws on
		isColor 		= expect(misc.isColor, term.isColor(), "boolean"),				-- if true, then it's an advanced computer

		transformation 	= expect(misc.transformation, nil, "function"),			-- function that transforms the char/text/back dots of the window
		metaTransformation = expect(misc.miscTransformation, nil, "function"),			-- function that transforms the whole output.meta function

		cursorX 		= expect(misc.cursorX, 1),
		cursorY 		= expect(misc.cursorY, 1),

		textColor 		= expect(misc.textColor, windont.default.textColor, "string"),			-- current text color
		backColor 		= expect(misc.backColor, windont.default.backColor, "string"),			-- current background color

		blink 			= expect(misc.blink, windont.default.blink, "boolean"),				-- cursor blink
		alwaysRender 	= expect(misc.alwaysRender, windont.default.alwaysRender, "boolean"),	-- render after every terminal operation
		visible 		= expect(misc.visible, windont.default.visible, "boolean"),			-- if false, don't render ever

		-- make a new buffer (optionally uses an existing buffer as a reference)
		newBuffer = function(width, height, char, text, back, drawAtop)
			local output = drawAtop or {{}, {}, {}}
			for y = 1, height do
				output[1][y] = output[1][y] or {}
				output[2][y] = output[2][y] or {}
				output[3][y] = output[3][y] or {}
				for x = 1, width do
					output[1][y][x] = output[1][y][x] or (char or " ")
					output[2][y][x] = output[2][y][x] or (text or "0")
					output[3][y][x] = output[3][y][x] or (back or "f")
				end
			end
			return output
		end
	}

	bT = meta.baseTerm

	-- initialize the buffer
	meta.buffer = meta.newBuffer(meta.width, meta.height, " ", meta.textColor, meta.backColor)

	output.meta = meta

	output.write = function(text)
		assert(type(text) == "string" or type(text) == "number", "expected string, got " .. type(text))
		local initX = meta.cursorX
		for i = 1, #tostring(text) do
			if meta.cursorX >= 1 and meta.cursorX <= meta.width and meta.cursorY >= 1 and meta.cursorY <= meta.height then
				if not meta.buffer[1] then
					error("what the fuck happened")
				end
				meta.buffer[1][meta.cursorY][meta.cursorX] = tostring(text):sub(i,i)
				meta.buffer[2][meta.cursorY][meta.cursorX] = meta.textColor
				meta.buffer[3][meta.cursorY][meta.cursorX] = meta.backColor
			end
			meta.cursorX = meta.cursorX + 1
		end
		if meta.alwaysRender then
			output.redraw(
				-1 + meta.x + initX,
				-1 + meta.x + meta.cursorX,
				-1 + meta.y + meta.cursorY
			)
		end
	end

	output.blit = function(char, text, back)
		assert(type(char) == "string" and type(text) == "string" and type(back) == "string", "all arguments must be strings")
		assert(#char == #text and #text == #back, "arguments must be same length")
		local initX = meta.cursorX
		for i = 1, #char do
			if meta.cursorX >= 1 and meta.cursorX <= meta.width and meta.cursorY >= 1 and meta.cursorY <= meta.height then
				meta.buffer[1][meta.cursorY][meta.cursorX] = char:sub(i,i)
				meta.buffer[2][meta.cursorY][meta.cursorX] = text:sub(i,i) == " " and windont.default.textColor or text:sub(i,i)
				meta.buffer[3][meta.cursorY][meta.cursorX] = back:sub(i,i) == " " and windont.default.backColor or back:sub(i,i)
				meta.cursorX = meta.cursorX + 1
			end
		end
		if meta.alwaysRender then
			output.redraw(
				-1 + meta.x + initX,
				-1 + meta.x + meta.cursorX,
				-1 + meta.y + meta.cursorY
			)
		end
	end

	output.setCursorPos = function(x, y)
		assert(type(x) == "number", "argument #1 must be number, got " .. type(x))
		assert(type(y) == "number", "argument #2 must be number, got " .. type(y))
		meta.cursorX, meta.cursorY = math.floor(x), math.floor(y)
		if meta.alwaysRender then
			if bT == output then
				bT = output.meta.baseTerm
			end
			bT.setCursorPos(
				-1 + meta.x + meta.cursorX,
				-1 + meta.y + meta.cursorY
			)
		end
	end

	output.getCursorPos = function()
		return meta.cursorX, meta.cursorY
	end

	output.setTextColor = function(color)
		if to_blit[color] then
			meta.textColor = to_blit[color]
		else
			error("Invalid color (got " .. color .. ")")
		end
	end
	output.setTextColour = output.setTextColor

	output.setBackgroundColor = function(color)
		if to_blit[color] then
			meta.backColor = to_blit[color]
		else
			error("Invalid color (got " .. color .. ")")
		end
	end
	output.setBackgroundColour = output.setBackgroundColor

	output.getTextColor = function()
		return to_colors[meta.textColor]
	end
	output.getTextColour = output.getTextColor

	output.getBackgroundColor = function()
		return to_colors[meta.backColor]
	end
	output.getBackgroundColour = output.getBackgroundColor

	output.setVisible = function(visible)
		assert(type(visible) == "boolean", "bad argument #1 (expected boolean, got " .. type(visible) .. ")")
		meta.visible = visible and true or false
	end

	output.clear = function()
		meta.buffer = meta.newBuffer(meta.width, meta.height, " ", meta.textColor, meta.backColor)
		if meta.alwaysRender then
			output.redraw()
		end
	end

	output.clearLine = function()
		meta.buffer[1][meta.cursorY] = nil
		meta.buffer[2][meta.cursorY] = nil
		meta.buffer[3][meta.cursorY] = nil
		meta.buffer = meta.newBuffer(meta.width, meta.height, " ", meta.textColor, meta.backColor, meta.buffer)
		if meta.alwaysRender then
			bT.setCursorPos(meta.x, -1 + meta.y + meta.cursorY)
			bT.blit(
				(" "):rep(meta.width),
				(meta.textColor):rep(meta.width),
				(meta.backColor):rep(meta.width)
			)
		end
	end

	output.getLine = function(y)
		assert(type(y) == "number", "bad argument #1 (expected number, got " .. type(y) .. ")")
		assert(meta.buffer[1][y], "Line is out of range.")
		return table_concat(meta.buffer[1][y]), table_concat(meta.buffer[2][y]), table_concat(meta.buffer[3][y])
	end

	output.scroll = function(amplitude)
		if math.abs(amplitude) < meta.height then	-- minor optimization
			local blank = {{}, {}, {}}
			for x = 1, meta.width do
				blank[1][x] = " "
				blank[2][x] = meta.textColor
				blank[3][x] = meta.backColor
			end
			for y = 1, meta.height do
				meta.buffer[1][y] = meta.buffer[1][y + amplitude] or blank[1]
				meta.buffer[2][y] = meta.buffer[2][y + amplitude] or blank[2]
				meta.buffer[3][y] = meta.buffer[3][y + amplitude] or blank[3]
			end
		else
			meta.buffer = meta.newBuffer(meta.width, meta.height, " ", meta.textColor, meta.backColor)
		end
		if meta.alwaysRender then
			if math_floor(amplitude) ~= 0 then
				output.redraw()
			end
		end
	end

	output.getSize = function()
		return width, height
	end

	output.isColor = function()
		return meta.isColor
	end
	output.isColour = output.isColor

	output.reposition = function(x, y, width, height)
		assert(type(x) == "number", "bad argument #1 (expected number, got " .. type(x) .. ")")
		assert(type(y) == "number", "bad argument #2 (expected number, got " .. type(y) .. ")")
		meta.x = math_floor(x)
		meta.y = math_floor(y)
		if width then
			assert(type(width) == "number", "bad argument #3 (expected number, got " .. type(width) .. ")")
			assert(type(height) == "number", "bad argument #4 (expected number, got " .. type(height) .. ")")
			meta.width = width
			meta.height = height
			meta.buffer = meta.newBuffer(meta.width, meta.height, " ", meta.textColor, meta.backColor, meta.buffer)
		end
		if meta.alwaysRender then
			output.redraw()
		end
	end

	output.restoreCursor = function()
		bT.setCursorPos(
			math.max(0, -1 + meta.x + meta.cursorX),
			math.max(0, -1 + meta.y + meta.cursorY)
		)
		bT.setCursorBlink(meta.blink)
	end

	output.getPosition = function()
		return meta.x, meta.y
	end

	output.setCursorBlink = function(blink)
		meta.blink = blink and true or false
	end

	output.getCursorBlink = function(blink)
		return meta.blink
	end

	output.setPaletteColor = bT.setPaletteColor
	output.setPaletteColour = bT.setPaletteColour
	output.getPaletteColor = bT.getPaletteColor
	output.getPaletteColour = bT.getPaletteColour

	if bT.getPaletteColor then
		output.nativePaletteColor = bT.nativePaletteColor or function(col)
			if nativePalette[col] then
				return table.unpack(nativePalette[col])
			else
				return table.unpack(nativePalette[1]) -- I don't get how this function takes in non-base2 numbers...
			end
		end
	end

	output.redraw = function(x1, x2, y)
		if #meta.renderBuddies > 0 then
			windont.render({onlyX1 = x1, onlyX2 = x2, onlyY = y}, output, table.unpack(meta.renderBuddies))
		else
			windont.render({onlyX1 = x1, onlyX2 = x2, onlyY = y}, output)
		end
		output.restoreCursor()
	end

	if meta.alwaysRender then
		output.redraw()
	end

	return output

end

return windont
