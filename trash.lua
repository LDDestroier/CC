-- TRASH by LDDestroier
-- Syntax:
--  > trash.lua [program] [arg1] [arg2] ...
--
--   Close the program or use LeftCTRL + LeftSHIFT + Backspace
-- to throw it in the traaaaaaaaash

local tArg = {...}

local scr_x, scr_y = term.getSize()

local images = {
	handOpen = {
		{"     ","","","","  ","       ","         ",},
		{"  00ffff   ","fffff000000","ffff0000000","  ff0000000","     f000  ","    f000   ","    00     ",},
		{"  f00000   ","0000000000f","0000000000f","  0000000ff","     000f  ","    00ff   ","    ff     ",}
	},
	handClosed = {
		{"      "," "," "," ","    ","       "},
		{"   fffff   "," fff0000000"," ff00000000"," ff00000000"," 0fff000   ","   0000    "},
		{"   00000   "," 000000000f"," 000000000f"," 0000000fff"," f00000f   ","   ffff    "}
	},
	trashCan = {
		{"",""," ","  ","   ","    ","    ","     ","      "},
		{"888ffffffff888","f8877787778788","8878888788878 "," f88788788788 "," f8878878878  ","  8878878788  ","  f887878788  ","  887787778   ","   88888888   "},
		{"7788888888887f","8878887888788f"," 887887888788 "," 88788788788f "," 88788788788  ","  887878878f  ","  887878788f  ","  f8887888f   ","   ffffffff   ",  }
	},
	trashLid = {
		{"           ","           ","   ","",  },
		{"fffffffffff","fffffffffff","ffffffffff8","f888877778888f"},
		{"fffffffffff","fffffffffff","fff8888888f","88888888888888"}
	}
}

-- start up lddterm
local lddterm = {}
lddterm.alwaysRender = false		-- renders after any and all screen-changing functions.
lddterm.useColors = true		-- normal computers do not allow color, but this variable doesn't do anything yet
lddterm.baseTerm = term.current()	-- will draw to this terminal
lddterm.transformation = nil		-- will modify the current buffer as an NFT image before rendering
lddterm.cursorTransformation = nil	-- will modify the cursor position
lddterm.drawFunction = nil		-- will draw using this function instead of basic NFT drawing
lddterm.adjustX = 0			-- moves entire screen X
lddterm.adjustY = 0			-- moves entire screen Y
lddterm.selectedWindow = 1		-- determines which window controls the cursor
lddterm.windows = {}

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

-- if the screen changes size, the effect is broken
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

				c = "."
				lt, lb = t, b
				t, b = "0", "f"
				for l = 1, #lddterm.windows do
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

-- load an abbridged NFTE API

local nfte = {}

local tchar = string.char(31)	-- for text colors
local bchar = string.char(30)	-- for background colors
local nchar = string.char(29)	-- for differentiating multiple frames in ANFT

local round = function(num)
	return math.floor(num + 0.5)
end

local deepCopy
deepCopy = function(tbl)
	local output = {}
	for k,v in pairs(tbl) do
		if type(v) == "table" then
			output[k] = deepCopy(v)
		else
			output[k] = v
		end
	end
	return output
end

local function stringWrite(str,pos,ins,exc)
	str, ins = tostring(str), tostring(ins)
	local output, fn1, fn2 = str:sub(1,pos-1)..ins..str:sub(pos+#ins)
	if exc then
		repeat
			fn1, fn2 = str:find(exc,fn2 and fn2+1 or 1)
			if fn1 then
				output = stringWrite(output,fn1,str:sub(fn1,fn2))
			end
		until not fn1
	end
	return output
end

local checkValid = function(image)
	if type(image) == "table" then
		if #image == 3 then
			return (#image[1] == #image[2] and #image[2] == #image[3])
		end
	end
	return false
end

local checkIfANFT = function(image)
	if type(image) == "table" then
		return type(image[1][1]) == "table"
	elseif type(image) == "string" then
		return image:find(nchar) and true or false
	end
end

-- returns (x, y) size of a loaded NFT image
nfte.getSize = function(image)
	assert(checkValid(image), "Invalid image.")
	local x, y = 0, #image[1]
	for y = 1, #image[1] do
		x = math.max(x, #image[1][y])
	end
	return x, y
end

local loadImageDataNFT = function(image, background) -- string image
	local output = {{},{},{}} -- char, text, back
	local y = 1
	background = (background or " "):sub(1,1)
	local text, back = " ", background
	local doSkip, c1, c2 = false
	local maxX = 0
	local bx
	for i = 1, #image do
		if doSkip then
			doSkip = false
		else
			output[1][y] = output[1][y] or ""
			output[2][y] = output[2][y] or ""
			output[3][y] = output[3][y] or ""
			c1, c2 = image:sub(i,i), image:sub(i+1,i+1)
			if c1 == tchar then
				text = c2
				doSkip = true
			elseif c1 == bchar then
				back = c2
				doSkip = true
			elseif c1 == "\n" then
				maxX = math.max(maxX, #output[1][y])
				y = y + 1
				text, back = " ", background
			else
				output[1][y] = output[1][y]..c1
				output[2][y] = output[2][y]..text
				output[3][y] = output[3][y]..back
			end
		end
	end
	for y = 1, #output[1] do
		output[1][y] = output[1][y] .. (" "):rep(maxX - #output[1][y])
		output[2][y] = output[2][y] .. (" "):rep(maxX - #output[2][y])
		output[3][y] = output[3][y] .. (background):rep(maxX - #output[3][y])
	end
	return output
end

local loadImageDataNFP = function(image, background)
	local output = {}
	local x, y = 1, 1
	for i = 1, #image do
		output[y] = output[y] or {}
		if bl[image:sub(i,i)] then
			output[y][x] = bl[image:sub(i,i)]
			x = x + 1
		elseif image:sub(i,i) == "\n" then
			x, y = 1, y + 1
		end
	end
	return output
end

-- takes a loaded image and returns a loaded NFT image
nfte.convertFromNFP = function(image, background)
	background = background or " "
	local output = {{},{},{}}
	if type(image) == "string" then
		image = loadImageDataNFP(image)
	end
	local imageX, imageY = getSizeNFP(image)
	local bx
	for y = 1, imageY do
		output[1][y] = ""
		output[2][y] = ""
		output[3][y] = ""
		for x = 1, imageX do
			if image[y][x] then
				bx = (x % #background) + 1
				output[1][y] = output[1][y]..lb[image[y][x] or background:sub(bx,bx)]
				output[2][y] = output[2][y]..lb[image[y][x] or background:sub(bx,bx)]
				output[3][y] = output[3][y]..lb[image[y][x] or background:sub(bx,bx)]
			end
		end
	end
	return output
end

-- loads the raw string NFT image data
nfte.loadImageData = function(image, background)
	assert(type(image) == "string", "NFT image data must be string.")
	local output = {}
	-- images can be ANFT, which means they have multiple layers
	if checkIfANFT(image) then
		local L, R = 1, 1
		while L do
			R = (image:find(nchar, L + 1) or 0)
			output[#output+1] = loadImageDataNFT(image:sub(L, R - 1), background)
			L = image:find(nchar, R + 1)
			if L then L = L + 2 end
		end
		return output, "anft"
	elseif image:find(tchar) or image:find(bchar) then
		return loadImageDataNFT(image, background), "nft"
	else
		return convertFromNFP(image), "nfp"
	end
end

-- loads an image file. will convert from NFP if necessary
nfte.loadImage = function(path, background)
	local file = io.open(path, "r")
	if file then
		io.input(file)
		local output, format = loadImageData(io.read("*all"), background)
		io.close()
		return output, format
	else
		error("No such file exists, or is directory.")
	end
end

local unloadImageNFT = function(image)
	assert(checkValid(image), "Invalid image.")
	local output = ""
	local text, back = " ", " "
	local c, t, b
	for y = 1, #image[1] do
		for x = 1, #image[1][y] do
			c, t, b = image[1][y]:sub(x,x), image[2][y]:sub(x,x), image[3][y]:sub(x,x)
			if (t ~= text) or (x == 1) then
				output = output..tchar..t
				text = t
			end
			if (b ~= back) or (x == 1) then
				output = output..bchar..b
				back = b
			end
			output = output..c
		end
		if y ~= #image[1] then
			output = output.."\n"
			text, back = " ", " "
		end
	end
	return output
end

-- takes a loaded NFT image and converts it back into regular NFT (or ANFT)
nfte.unloadImage = function(image)
	assert(checkValid(image), "Invalid image.")
	local output = ""
	if checkIfANFT(image) then
		for i = 1, #image do
			output = output .. unloadImageNFT(image[i])
			if i ~= #image then
				output = output .. nchar .. "\n"
			end
		end
	else
		output = unloadImageNFT(image)
	end
	return output
end

-- draws an image with the topleft corner at (x, y)
nfte.drawImage = function(image, x, y, terminal)
	assert(checkValid(image), "Invalid image.")
	assert(type(x) == "number", "x value must be number, got " .. type(x))
	assert(type(y) == "number", "y value must be number, got " .. type(y))
	terminal = terminal or term.current()
	local cx, cy = terminal.getCursorPos()
	for iy = 1, #image[1] do
		terminal.setCursorPos(x, y + (iy - 1))
		terminal.blit(image[1][iy], image[2][iy], image[3][iy])
	end
	terminal.setCursorPos(cx,cy)
end

-- draws an image with the topleft corner at (x, y), with transparency
nfte.drawImageTransparent = function(image, x, y, terminal)
	assert(checkValid(image), "Invalid image.")
	assert(type(x) == "number", "x value must be number, got " .. type(x))
	assert(type(y) == "number", "y value must be number, got " .. type(y))
	terminal = terminal or term.current()
	local cx, cy = terminal.getCursorPos()
	local c, t, b
	for iy = 1, #image[1] do
		for ix = 1, #image[1][iy] do
			c, t, b = image[1][iy]:sub(ix,ix), image[2][iy]:sub(ix,ix), image[3][iy]:sub(ix,ix)
			if b ~= " " or c ~= " " then
				terminal.setCursorPos(x + (ix - 1), y + (iy - 1))
				terminal.blit(c, t, b)
			end
		end
	end
	terminal.setCursorPos(cx,cy)
end

-- draws an image centered at (x, y) or center screen
nfte.drawImageCenter = function(image, x, y, terminal)
	terminal = terminal or term.current()
	local scr_x, scr_y = terminal.getSize()
	local imageX, imageY = nfte.getSize(image)
	return nfte.drawImage(
		image,
		round(0.5 + (x and x or (scr_x/2)) - imageX/2),
		round(0.5 + (y and y or (scr_y/2)) - imageY/2),
		terminal
	), round(0.5 + (x and x or (scr_x/2)) - imageX/2), round(0.5 + (y and y or (scr_y/2)) - imageY/2)
end

-- draws an image centered at (x, y) or center screen, with transparency
nfte.drawImageCenterTransparent = function(image, x, y, terminal)
	terminal = terminal or term.current()
	local scr_x, scr_y = terminal.getSize()
	local imageX, imageY = getSize(image)
	return nfte.drawImageTransparent(
		image,
		round(0.5 + (x and x or (scr_x/2)) - imageX/2),
		round(0.5 + (y and y or (scr_y/2)) - imageY/2),
		terminal
	)
end

-- stretches an image so that its new height and width are (sx, sy).
-- if noRepeat, it will only draw one of each character for each pixel
--  in the original image, so as to not mess up text in images.
nfte.stretchImage = function(_image, sx, sy, noRepeat)
	assert(checkValid(_image), "Invalid image.")
	local output = {{},{},{}}
	local image = deepCopy(_image)
	if sx < 0 then image = flipX(image) end
	if sy < 0 then image = flipY(image) end
	sx, sy = math.abs(sx), math.abs(sy)
	local imageX, imageY = nfte.getSize(image)
	local tx, ty
	if sx == 0 or sy == 0 then
		for y = 1, math.max(sy, 1) do
			output[1][y] = ""
			output[2][y] = ""
			output[3][y] = ""
		end
		return output
	else
		for y = 1, sy do
			for x = 1, sx do
				tx = round((x / sx) * imageX)
				ty = math.ceil((y / sy) * imageY)
				if not noRepeat then
					output[1][y] = (output[1][y] or "")..image[1][ty]:sub(tx,tx)
				else
					output[1][y] = (output[1][y] or "").." "
				end
				output[2][y] = (output[2][y] or "")..image[2][ty]:sub(tx,tx)
				output[3][y] = (output[3][y] or "")..image[3][ty]:sub(tx,tx)
			end
		end
		if noRepeat then
			for y = 1, imageY do
				for x = 1, imageX do
					if image[1][y]:sub(x,x) ~= " " then
						tx = round(((x / imageX) * sx) - ((0.5 / imageX) * sx))
						ty = round(((y / imageY) * sy) - ((0.5 / imageY) * sx))
						output[1][ty] = stringWrite(output[1][ty], tx, image[1][y]:sub(x,x))
					end
				end
			end
		end
		return output
	end
end

local rotatePoint = function(x, y, angle, originX, originY)
	return
		round( (x-originX) * math.cos(angle) - (y-originY) * math.sin(angle) ) + originX,
		round( (x-originX) * math.sin(angle) + (y-originY) * math.cos(angle) ) + originY
end

-- rotates an image around (originX, originY) or its center, by angle radians
nfte.rotateImage = function(image, angle, originX, originY)
	assert(checkValid(image), "Invalid image.")
	if imageX == 0 or imageY == 0 then
		return image
	end
	local output = {{},{},{}}
	local realOutput = {{},{},{}}
	local tx, ty, corners
	local imageX, imageY = nfte.getSize(image)
	local originX, originY = originX or math.floor(imageX / 2), originY or math.floor(imageY / 2)
	corners = {
		{rotatePoint(1, 		1, 		angle, originX, originY)},
		{rotatePoint(imageX, 	1, 		angle, originX, originY)},
		{rotatePoint(1, 		imageY, angle, originX, originY)},
		{rotatePoint(imageX, 	imageY, angle, originX, originY)},
	}
	local minX = math.min(corners[1][1], corners[2][1], corners[3][1], corners[4][1])
	local maxX = math.max(corners[1][1], corners[2][1], corners[3][1], corners[4][1])
	local minY = math.min(corners[1][2], corners[2][2], corners[3][2], corners[4][2])
	local maxY = math.max(corners[1][2], corners[2][2], corners[3][2], corners[4][2])

	for y = 1, (maxY - minY) + 1 do
		output[1][y] = {}
		output[2][y] = {}
		output[3][y] = {}
		for x = 1, (maxX - minX) + 1 do
			tx, ty = rotatePoint(x + minX - 1, y + minY - 1, -angle, originX, originY)
			output[1][y][x] = " "
			output[2][y][x] = " "
			output[3][y][x] = " "
			if image[1][ty] then
				if tx >= 1 and tx <= #image[1][ty] then
					output[1][y][x] = image[1][ty]:sub(tx,tx)
					output[2][y][x] = image[2][ty]:sub(tx,tx)
					output[3][y][x] = image[3][ty]:sub(tx,tx)
				end
			end
		end
	end
	for y = 1, #output[1] do
		output[1][y] = table.concat(output[1][y])
		output[2][y] = table.concat(output[2][y])
		output[3][y] = table.concat(output[3][y])
	end
	return output, math.ceil(minX), math.ceil(minY)
end

local tWindow = lddterm.newWindow(scr_x, scr_y, 1, 1)
tWindow.blink = false
local tOriginal = term.redirect(tWindow.handle)

local program = tArg[1] or "/rom/programs/shell.lua"

local rendTimer = os.startTimer(0.05)
table.remove(tArg, 1)
parallel.waitForAny(function()
	shell.run(program, table.unpack(tArg))
end, function()
	local evt
	local keysDown = {}
	while true do
		evt = {os.pullEvent()}
		if evt[1] == "timer" and evt[2] == rendTimer then
			lddterm.render()
			rendTimer = os.startTimer(0.05)
		elseif evt[1] == "key" then
			keysDown[evt[2]] = true
			if keysDown[keys.leftCtrl] and keysDown[keys.leftShift] and evt[2] == keys.backspace then
				return
			end
		elseif evt[1] == "key_up" then
			keysDown[evt[2]] = false
		end
	end
end)

term.setCursorBlink(false)

local fullScreenshot = lddterm.screenshot()
local screenshot
local screenshot_X, screenshot_Y = nfte.getSize(fullScreenshot)

term.setBackgroundColor(colors.black)

for i = screenshot_X, math.floor(math.sqrt(scr_x * 3)), -2 do
	screenshot = nfte.stretchImage(fullScreenshot, i, i / (screenshot_X / screenshot_Y))
	term.clear()
	nfte.drawImageCenter(screenshot)
	lddterm.render()
	sleep(0.05)
end

local handX, handY = scr_x + 4, -5
for x = handX, math.floor(scr_x / 2) + 1, -2 do
	term.clear()
	nfte.drawImageCenter(screenshot)
	nfte.drawImageTransparent(images.handOpen, handX, handY)
	lddterm.render()
	sleep(0.05)
	handX = handX - 2.0
	handY = handY + (scr_y / scr_x) * 2
end

handX, handY = math.floor(handX), math.floor(handY)
local anchorX, anchorY = handX, handY
local scrollX, scrollY = 0, 0

term.clear()
local _, imageX, imageY = nfte.drawImageCenter(screenshot)
nfte.drawImageTransparent(images.handClosed, handX, handY)
lddterm.render()
sleep(0.5)

for i = 1, 10 do
	handX = handX + 0.5
	handY = handY + 0.4
	term.clear()
	nfte.drawImage(screenshot, imageX + (handX - anchorX), imageY + (handY - anchorY))
	nfte.drawImageTransparent(images.handClosed, handX, handY)
	lddterm.render()
	sleep(0.05)
end

sleep(0.4)

for i = 1, 10 do
	handX = handX - (0.6 + (i / 8))
	handY = handY - (0.1 + (i / 12))
	if i >= 2 then
		scrollX = scrollX + 1
	end
	term.clear()
	nfte.drawImage(screenshot, scrollX + imageX + (handX - anchorX), scrollY + imageY + (handY - anchorY))
	nfte.drawImageTransparent(images.handClosed, scrollX + handX, scrollY + handY)
	lddterm.render()
	sleep(0.05)
end
local imageYvel = -0.9
local imageRotate = 0
imageX = imageX + (handX - anchorX)
imageY = imageY + (handY - anchorY)

local rImage, rX, rY

for i = 1, 41 do
	if i <= 5 then
		handX = handX - 1
		handY = handY - 0.8
	end
	term.clear()
	rImage, rX, rY = nfte.rotateImage(screenshot, imageRotate)
	nfte.drawImage(rImage, scrollX + imageX, scrollY + imageY)
	nfte.drawImageTransparent(images.handOpen, scrollX + handX, scrollY + handY)
	nfte.drawImageTransparent(images.trashCan, (scr_x / 2) - (177 - scrollX), scrollY + 32 + (scr_y - 19) / 2 + (scr_x - 51) / 10)
	lddterm.render()

	sleep(0.05)

	imageRotate = imageRotate + 0.12
	scrollX = scrollX + 4
	if i < 20 then
		scrollY = scrollY - 0.25
	else
		scrollY = scrollY - 0.8
	end
	imageX = imageX - 4
	imageY = imageY + imageYvel

	imageYvel = imageYvel + 0.07
end

sleep(0.5)

local scene = lddterm.screenshot()

for i = 1, 6 do
	nfte.drawImage(scene, 1, 1)
	nfte.drawImageTransparent(images.trashLid, (scr_x / 2) - (179 - scrollX), ((scr_y - 19) / 4) + i - 3)
	lddterm.render()
	sleep(0.05)
end

local lidAngle, rotLid = 0

for i = 1, 10 do
	lidAngle = lidAngle + 0.0371
	rotLid = nfte.rotateImage(images.trashLid, lidAngle)
	nfte.drawImage(scene, 1, 1)
	nfte.drawImageTransparent(rotLid, (scr_x / 2) - (179 - scrollX), 1 + ((scr_y - 19) / 4))
	lddterm.render()
	sleep(0.05)
end

sleep(0.5)

term.redirect(tOriginal)
term.setCursorPos(1, scr_y)
