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

local windont = {baseTerm = term.current()}

local config = {
	defaultTextColor = "0",				-- default text color (what " " corresponds to in term.blit's second argument)
	defaultBackColor = "f",				-- default background color (what " " corresponds to in term.blit's third argument)
}

windont.render = function(...)
	local windows = {...}
	local bT = windont.baseTerm
	local scr_x, scr_y = bT.getSize()
	local screenBuffer = {{}, {}, {}}
	local blitList = {}	-- list of blit commands per line
	local c	= 1 		-- current blitList entry
	local cx, cy		-- each window's absolute X and Y
	local buffer

	-- check if space on screenBuffer is transparent
	local check = function(x, y)
		if screenBuffer[1][y] then
			return screenBuffer[1][y][x] and (screenBuffer[2][y][x] or screenBuffer[3][y][x])
		end
	end

	for y = 1, scr_y do
		screenBuffer[1][y] = {}
		screenBuffer[2][y] = {}
		screenBuffer[3][y] = {}
		blitList = {}
		c = 1
		for x = 1, scr_x do
			for i = 1, #windows do
				if windows[i].meta.visible then
					buffer = windows[i].meta.buffer
					cx = x - windows[i].meta.x + 1
					cy = y - windows[i].meta.y + 1
					if type(buffer[1][cy]) == "table" then
						screenBuffer[1][y][x] = screenBuffer[1][y][x] or buffer[1][cy][cx]
						screenBuffer[2][y][x] = screenBuffer[2][y][x] or (buffer[2][cy][cx] ~= "-" and buffer[2][cy][cx])
						screenBuffer[3][y][x] = screenBuffer[3][y][x] or (buffer[3][cy][cx] ~= "-" and buffer[3][cy][cx])
					else
						screenBuffer[1][y][x] = screenBuffer[1][y][x]
						screenBuffer[2][y][x] = screenBuffer[2][y][x]
						screenBuffer[3][y][x] = screenBuffer[3][y][x]
					end
				end
			end
			screenBuffer[2][y][x] = screenBuffer[2][y][x] or config.defaultTextColor
			screenBuffer[3][y][x] = screenBuffer[3][y][x] or config.defaultBackColor
			if check(x, y) then
				if check(x - 1, y) then
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
		end
	end
end

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

	local bT = windont.baseTerm

	local output = {}
	misc = misc or {}
	local meta = {
		x = x or 1,							-- x position of the window
		y = y or 1,							-- y position of the window
		width = width,						-- width of the buffer
		height = height,					-- height of the buffer
		buffer = {},						-- stores contents of terminal in buffer[1][y][x] format

		cursorX = misc.cursorX or 1,
		cursorY = misc.cursorY or 1,

		textColor = misc.textColor or "0",	-- current text color
		backColor = misc.backColor or "f",	-- current background color

		blink = true,					-- cursor blink
		isColor = term.isColor(),		-- if true, then it's an advanced computer
		alwaysRender = false,			-- render after every terminal operation
		visible = true,					-- if false, don't render ever

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

	-- initialize the buffer
	meta.buffer = meta.newBuffer(meta.width, meta.height, " ", meta.textColor, meta.backColor)

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
			bT.setCursorPos(meta.x, meta.y)
			bT.blit(
				table.unpack(meta.buffer[1][meta.cursorY]),
				table.unpack(meta.buffer[2][meta.cursorY]),
				table.unpack(meta.buffer[3][meta.cursorY])
			)
		end
	end

	output.blit = function(char, text, back)
		assert(type(char) == "string" and type(text) == "string" and type(back) == "string", "all arguments must be strings")
		assert(#char == #text and #text == #back, "arguments must be same length")
		for i = 1, #char do
			if meta.cursorX >= 1 and meta.cursorX <= meta.width and meta.cursorY >= 1 and meta.cursorY <= meta.height then
				meta.buffer[1][meta.cursorY][meta.cursorX] = char:sub(i,i)
				meta.buffer[2][meta.cursorY][meta.cursorX] = text:sub(i,i) == " " and config.defaultTextColor or text:sub(i,i)
				meta.buffer[3][meta.cursorY][meta.cursorX] = back:sub(i,i) == " " and config.defaultBackColor or back:sub(i,i)
				meta.cursorX = meta.cursorX + 1
			end
		end
		if meta.alwaysRender then
			--local limit = math.max(0, meta.width - meta.cursorX + 1)
			bT.setCursorPos(meta.x, meta.y)
			bT.blit(
				table.unpack(meta.buffer[1][meta.cursorY]),
				table.unpack(meta.buffer[2][meta.cursorY]),
				table.unpack(meta.buffer[3][meta.cursorY])
			)
		end
	end

	output.setCursorPos = function(x, y)
		assert(type(x) == "number", "argument #1 must be number, got " .. type(x))
		assert(type(y) == "number", "argument #2 must be number, got " .. type(y))
		meta.cursorX, meta.cursorY = x, y
		if meta.alwaysRender then
			bT.setCursorPos(meta.x + meta.cursorX - 1, meta.y + meta.cursorY - 1)
		end
	end

	output.getCursorPos = function()
		return meta.cursorX, meta.cursorY
	end

	output.setTextColor = function(color)
		if to_blit[color] then
			meta.textColor = color
		else
			error("Invalid color (got " .. color .. ")")
		end
	end
	output.setTextColour = output.setTextColor

	output.setBackgroundColor = function(color)
		if to_blit[color] then
			meta.backColor = color
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
		meta.visible = visible and true or false
	end

	output.clear = function()
		meta.buffer = meta.newBuffer(meta.width, meta.height, " ", meta.textColor, meta.backColor)
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
		return table.concat(meta.buffer[1][y]), table.concat(meta.buffer[2][y]), table.concat(meta.buffer[3][y])
	end

	output.scroll = function(amount)
		if amplitude > 0 then
			for i = 1, amplitude do
				table.remove(meta.buffer[1], 1)
				table.remove(meta.buffer[2], 1)
				table.remove(meta.buffer[3], 1)
			end
		else
			for i = 1, -amplitude do
				meta.buffer[1][#meta.buffer[1]] = nil
				meta.buffer[2][#meta.buffer[2]] = nil
				meta.buffer[3][#meta.buffer[3]] = nil
			end
		end
		meta.buffer = meta.newBuffer(meta.width, meta.height, " ", meta.textColor, meta.backColor, meta.buffer)
		if meta.alwaysRender then
			output.redraw()
		end
	end

	output.getSize = function()
		return height, width
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
		bT.setCursorPos(meta.x + meta.cursorX - 1, meta.y + meta.cursorY - 1)
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

	output.meta = meta

	output.redraw = function()
		windont.render(output)
	end

	return output

end

return windont
