--  Windon't
-- enhanced window API by LDDestroier
-- intended for general use within all me new programs
--
-- Unique features:
--  + Transparency within windows
--  + Built-in window layering

local to_blit, to_colors = {}, {}
for i = 1, 16 do
	to_blit[2 ^ (i - 1)] = ("0123456789abcdef"):sub(i, i)
	to_colors[("0123456789abcdef"):sub(i, i)] = 2 ^ (i - 1)
end
to_blit[0], to_colors["-"] = "-", 0

local getTime = function()
	return 24 * os.day() + os.time()
end

local windont = {
	baseTerm = term.current(),				-- default base terminal for all windows
	config = {
		defaultTextColor = "0",				-- default text color (what " " corresponds to in term.blit's second argument)
		defaultBackColor = "f",				-- default background color (what " " corresponds to in term.blit's third argument)
		clearScreen = true,				-- if true, will clear the screen during render
	},
	info = {
		BLIT_CALLS = 0,				-- amount of term.blit calls during the last render
		LAST_RENDER_TIME = 0,		-- last time in which render was called
		LAST_RENDER_AMOUNT = 0,		-- amount of windows drawn during last render
		LAST_RENDER_WINDOWS = {},	-- table of the last window objects that were rendered
	}
}

-- check if space on screenBuffer is transparent
local check = function(buff, x, y, blitLayer)
	if buff[blitLayer or 1][y] then
		return (blitLayer or buff[1][y][x]) and (
			(not buff[blitLayer or 2][y][x] or buff[blitLayer or 2][y][x] ~= "-") or
			(not buff[blitLayer or 3][y][x] or buff[blitLayer or 3][y][x] ~= "-")
		) and (
			not (buff[1][y][x] == " " and buff[3][y][x] == "-")
		)
	end
end

-- draws one or more windon't objects
-- should not draw over any terminal space that isn't occupied by a window

windont.render = function(...)
	local windows = {...}
	local bT
	local screenBuffer = {{}, {}, {}}
	local scr_x, scr_y
	local blitList = {}	-- list of blit commands per line
	local c	= 1 		-- current blitList entry

	local cTime = getTime()

	local AMNT_OF_BLITS = 0	-- how many blit calls are there?

	local cx, cy					-- each window's absolute X and Y
	local char_cx, text_cx, back_cx	-- each window's transformed absolute X's in table form
	local char_cy, text_cy, back_cy	-- each window's transformed absolute X's in table form
	local buffer					-- each window's buffer
	local newChar, newText, newBack	-- if the transformation function declares a new dot, this is it

	local baseTerms = {}
	for i = 1, #windows do
		baseTerms[windows[i].meta.baseTerm] = baseTerms[windows[i].meta.baseTerm] or {}
		baseTerms[windows[i].meta.baseTerm][i] = true
	end

	if bT == output then
		bT = output.meta.baseTerm
	end

	for bT, bT_list in pairs(baseTerms) do
		scr_x, scr_y = bT.getSize()
		for y = 1, scr_y do
			screenBuffer[1][y] = {}
			screenBuffer[2][y] = {}
			screenBuffer[3][y] = {}
			blitList = {}
			c = 1
			for x = 1, scr_x do
				for i = #windows, 1, -1 do
					if bT_list[i] then
						newChar, newText, newBack = nil
						if windows[i].meta.visible then
							buffer = windows[i].meta.buffer
							cx = x - windows[i].meta.x + 1
							cy = y - windows[i].meta.y + 1
							char_cx, text_cx, back_cx = cx, cx, cx
							char_cy, text_cy, back_cy = cy, cy, cy

							-- try char transformation
							if windows[i].meta.charTransformation then
								char_cx, char_cy, newChar = windows[i].meta.charTransformation(cx, cy, windows[i].meta)
								if char_cx ~= math.floor(char_cx) or char_cy ~= math.floor(char_cy) then
									newChar = " "
								end
								char_cx = math.floor(char_cx)
								char_cy = math.floor(char_cy)
							end

							-- try text transformation
							if windows[i].meta.textTransformation then
								text_cx, text_cy, newText = windows[i].meta.textTransformation(cx, cy, windows[i].meta)
								text_cx = math.floor(text_cx)
								text_cy = math.floor(text_cy)
							end

							-- try back transformation
							if windows[i].meta.backTransformation then
								back_cx, back_cy, newBack = windows[i].meta.backTransformation(cx, cy, windows[i].meta)
								back_cx = math.floor(back_cx)
								back_cy = math.floor(back_cy)
							end

							if check(buffer, char_cx, char_cy) or check(buffer, text_cx, text_cy) or check(buffer, back_cx, back_cy) then
								screenBuffer[1][y][x] = newChar or check(buffer, char_cx, char_cy   ) and (buffer[1][char_cy][char_cx]) or screenBuffer[1][y][x]
								screenBuffer[2][y][x] = newText or check(buffer, text_cx, text_cy, 2) and (buffer[2][text_cy][text_cx]) or screenBuffer[3][y][x]
								screenBuffer[3][y][x] = newBack or check(buffer, back_cx, back_cy, 3) and (buffer[3][back_cy][back_cx]) or screenBuffer[3][y][x]
							end
						end
					end
				end

				if windont.config.clearScreen then
					screenBuffer[1][y][x] = screenBuffer[1][y][x] or " "
				end
				screenBuffer[2][y][x] = screenBuffer[2][y][x] or windont.config.defaultBackColor	-- intentionally not the default text color
				screenBuffer[3][y][x] = screenBuffer[3][y][x] or windont.config.defaultBackColor

				if check(screenBuffer, x, y) then
					if check(screenBuffer, x - 1, y) then
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
			for k,v in pairs(blitList) do
				bT.setCursorPos(k, y)
				bT.blit(v[1], v[2], v[3])
				AMNT_OF_BLITS = AMNT_OF_BLITS + 1
			end
		end
	end

	windont.info.BLIT_CALLS = AMNT_OF_BLITS
	windont.info.LAST_RENDER_AMOUNT = #windows
	windont.info.LAST_RENDER_WINDOWS = windows
	windont.info.LAST_RENDER_TIME = cTime
	windont.info.LAST_RENDER_DURATION = getTime() - cTime

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
		x = x or 1,						-- x position of the window
		y = y or 1,						-- y position of the window
		width = width,						-- width of the buffer
		height = height,					-- height of the buffer
		buffer = {},						-- stores contents of terminal in buffer[1][y][x] format
		renderBuddies = {},					-- renders any other window objects stored here after rendering here
		baseTerm = misc.baseTerm or windont.baseTerm,		-- base terminal for which this window draws on

		charTransformation = nil,			-- function that transforms the characters of the window
		textTransformation = nil,			-- function that transforms the text colors of the window
		backTransformation = nil,			-- function that transforms the BG colors of the window

		cursorX = misc.cursorX or 1,
		cursorY = misc.cursorY or 1,

		textColor = misc.textColor or windont.config.defaultTextColor,	-- current text color
		backColor = misc.backColor or windont.config.defaultBackColor,	-- current background color

		blink = true,				-- cursor blink
		isColor = term.isColor(),		-- if true, then it's an advanced computer
		alwaysRender = true,			-- render after every terminal operation
		visible = true,				-- if false, don't render ever

		-- make a new buffer (optionally uses an existing buffer as a reference)
		newBuffer = function(width, height, char, text, back, drawAtop)
			local output = drawAtop or {{}, {}, {}}
			for y = 1, height do
				output[1][y] = output[1][y] or {}
				output[2][y] = output[2][y] or {}
				output[3][y] = output[3][y] or {}
				for x = 1, width do
					output[1][y][x] = output[1][y][x] or char or " "
					output[2][y][x] = output[2][y][x] or text or "0"
					output[3][y][x] = output[3][y][x] or back or "f"
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
		assert(type(text) == "string", "argument must be string")
		for i = 1, #text do
			if meta.cursorX >= 1 and meta.cursorX <= meta.width and meta.cursorY >= 1 and meta.cursorY <= meta.height then
				meta.buffer[1][meta.cursorY][meta.cursorX] = text:sub(i,i)
				meta.buffer[2][meta.cursorY][meta.cursorX] = meta.textColor
				meta.buffer[3][meta.cursorY][meta.cursorX] = meta.backColor
				meta.cursorX = meta.cursorX + 1
			end
		end
		if meta.alwaysRender then
			--local limit = math.max(0, meta.width - meta.cursorX + 1)
			bT.setCursorPos(meta.x, meta.y + meta.cursorY - 1)
			bT.blit(
				table.concat(meta.buffer[1][meta.cursorY]),
				table.concat(meta.buffer[2][meta.cursorY]),
				table.concat(meta.buffer[3][meta.cursorY])
			)
		end
	end

	output.blit = function(char, text, back)
		assert(type(char) == "string" and type(text) == "string" and type(back) == "string", "all arguments must be strings")
		assert(#char == #text and #text == #back, "arguments must be same length")
		for i = 1, #char do
			if meta.cursorX >= 1 and meta.cursorX <= meta.width and meta.cursorY >= 1 and meta.cursorY <= meta.height then
				meta.buffer[1][meta.cursorY][meta.cursorX] = char:sub(i,i)
				meta.buffer[2][meta.cursorY][meta.cursorX] = text:sub(i,i) == " " and windont.config.defaultTextColor or text:sub(i,i)
				meta.buffer[3][meta.cursorY][meta.cursorX] = back:sub(i,i) == " " and windont.config.defaultBackColor or back:sub(i,i)
				meta.cursorX = meta.cursorX + 1
			end
		end
		if meta.alwaysRender then
			--local limit = math.max(0, meta.width - meta.cursorX + 1)
			bT.setCursorPos(meta.x, meta.y + meta.cursorY - 1)
			bT.blit(
				table.concat(meta.buffer[1][meta.cursorY]),
				table.concat(meta.buffer[2][meta.cursorY]),
				table.concat(meta.buffer[3][meta.cursorY])
			)
		end
	end

	output.setCursorPos = function(x, y)
		assert(type(x) == "number", "argument #1 must be number, got " .. type(x))
		assert(type(y) == "number", "argument #2 must be number, got " .. type(y))
		meta.cursorX, meta.cursorY = x, y
		if meta.alwaysRender then
			if bT == output then
				bT = output.meta.baseTerm
			end
			bT.setCursorPos(meta.x + meta.cursorX - 1, meta.y + meta.cursorY - 1)
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
		assert(type(visible) == "number", "bad argument #1 (expected boolean, got " .. type(visible) .. ")")
		meta.visible = visible and true or false
	end

	output.clear = function()
		meta.buffer = meta.newBuffer(meta.width, meta.height, " ", meta.textColor, meta.backColor)
		if meta.alwaysRender then
			output.redraw()
		end
	end

	output.clearLine = function()
		meta.buffer[meta.cursorY] = nil
		meta.buffer = meta.newBuffer(meta.width, meta.height, " ", meta.textColor, meta.backColor, meta.buffer)
		if meta.alwaysRender then
			bT.setCursorPos(meta.x, meta.y + meta.cursorY - 1)
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
		return table.concat(meta.buffer[1][y]), table.concat(meta.buffer[2][y]), table.concat(meta.buffer[3][y])
	end

	output.scroll = function(amplitude)
		if amplitude > 0 then
			for i = 1, amplitude do
				table.remove(meta.buffer[1], 1)
				table.remove(meta.buffer[2], 1)
				table.remove(meta.buffer[3], 1)
			end
		else
			for i = 1, -amplitude do
				table.insert(meta.buffer[1], 1, false)
				table.insert(meta.buffer[2], 1, false)
				table.insert(meta.buffer[3], 1, false)
			end
		end
		meta.buffer = meta.newBuffer(meta.width, meta.height, " ", meta.textColor, meta.backColor, meta.buffer)
		if meta.alwaysRender then
			output.redraw()
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
		meta.x = math.floor(x)
		meta.y = math.floor(y)
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
			math.max(0, meta.x + meta.cursorX - 1),
			math.max(0, meta.y + meta.cursorY - 1)
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

	output.redraw = function()
		if #meta.renderBuddies > 0 then
			windont.render(output, table.unpack(meta.renderBuddies))
		else
			windont.render(output)
		end
	end

	return output

end

return windont
