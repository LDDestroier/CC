local doGlobalize = false
local lddwindow = {}

local to_colors = {
	[" "] = 0,
	["0"] = colors.white,
	["1"] = colors.orange,
	["2"] = colors.magenta,
	["3"] = colors.lightBlue,
	["4"] = colors.yellow,
	["5"] = colors.lime,
	["6"] = colors.pink,
	["7"] = colors.gray,
	["8"] = colors.lightGray,
	["9"] = colors.cyan,
	["a"] = colors.purple,
	["b"] = colors.blue,
	["c"] = colors.brown,
	["d"] = colors.green,
	["e"] = colors.red,
	["f"] = colors.black,
}
local to_blit = {}
for k,v in pairs(to_colors) do
	to_blit[v] = k
end

local stringSub = string.sub
local stringGsub = string.gsub
local tableConcat = table.concat

lddwindow.newWindow = function(nativeTerm, x, y, width, height, visible)
	local output = {
		info = {
			buffer = {{},{},{}},
			x = x,
			y = y,
			textColor = "0",
			backColor = "f",
			cursorX = 1,
			cursorY = 1,
			nativeTerm = nativeTerm or term.current(),
			width = width,
			height = height,
			blink = true,
			palette = {},
		}
	}
	if visible == nil then
		output.info.visible = true
	elseif type(visible) == "boolean" then
		output.info.visible = visible
	else
		output.info.visible = true
	end
	
	local genTblLine = function(char, length)
		local blankLine = {}
		for i = 1, length do
			blankLine[i] = char
		end
		return blankLine
	end
	
	for i = 0, 15 do
--		output.info.palette[2^i] = output.info.nativeTerm.nativePaletteColor(2^i)
		output.info.palette[2^i] = term.nativePaletteColor(2^i)
	end
	
	local fixBuffer = function()
		for y = math.max(output.info.height, #output.info.buffer[1]), 1, -1 do
			if y > output.info.height then
				output.info.buffer[1][y] = nil
				output.info.buffer[2][y] = nil
				output.info.buffer[3][y] = nil
			else
				output.info.buffer[1][y] = output.info.buffer[1][y] or {}
				output.info.buffer[2][y] = output.info.buffer[2][y] or {}
				output.info.buffer[3][y] = output.info.buffer[3][y] or {}
				for x = math.max(output.info.width, #(output.info.buffer[1][1] or {})), 1, -1 do
					if x > output.info.width then
						output.info.buffer[1][y][x] = nil
						output.info.buffer[2][y][x] = nil
						output.info.buffer[3][y][x] = nil
					else
						output.info.buffer[1][y][x] = output.info.buffer[1][y][x] or " "
						output.info.buffer[2][y][x] = output.info.buffer[2][y][x] or output.info.textColor
						output.info.buffer[3][y][x] = output.info.buffer[3][y][x] or output.info.backColor
					end
				end
			end
		end
	end
	
	fixBuffer()
	
	output.reposition = function(x, y, width, height)
		output.info.x = tonumber(x) or output.info.x
		output.info.y = tonumber(y) or output.info.y
		output.info.width = tonumber(width) or output.info.width
		output.info.height = tonumber(height) or output.info.height
		fixBuffer()
	end
	
	output.setCursorPos = function(x, y)
		output.info.cursorX = x or output.info.cursorX
		output.info.cursorY = y or output.info.cursorY
	end
	
	output.getCursorPos = function()
		return output.info.cursorX, output.info.cursorY
	end
	
	output.setCursorBlink = function(blink)
		output.info.blink = blink and true or false
	end
	
	output.getCursorBlink = function(blink)
		return output.info.blink
	end
	
	output.isColor = function()
		return true
	end
	output.isColour = output.isColor
	
	output.getSize = function()
		return output.info.width, output.info.height
	end
	
	output.current = function()
		return output
	end
	
	output.clear = function()
		for y = 1, output.info.height do
			output.info.buffer[1][y] = genTblLine(" ", output.info.width)
			output.info.buffer[2][y] = genTblLine(output.info.textColor, output.info.width)
			output.info.buffer[3][y] = genTblLine(output.info.backColor, output.info.width)
		end
	end
	
	output.clearLine = function()
		if output.info.cursorY >= 1 and output.info.cursorY <= output.info.height then
			output.info.buffer[1][output.info.cursorY] = genTblLine(" ", output.info.width)
			output.info.buffer[2][output.info.cursorY] = genTblLine(output.info.textColor, output.info.width)
			output.info.buffer[3][output.info.cursorY] = genTblLine(output.info.backColor, output.info.width)
		end
	end
	
	output.setTextColor = function(color)
		output.info.textColor = to_blit[color]
	end
	output.setTextColour = output.setTextColor
	
	output.setBackgroundColor = function(color)
		output.info.backColor = to_blit[color]
	end
	output.setBackgroundColour = output.setBackgroundColor
	
	output.getTextColor = function()
		return output.info.textColor
	end
	output.getTextColour = output.getTextColor
	
	output.getBackgroundColor = function()
		return output.info.backColor
	end
	output.getBackgroundColour = output.getBackgroundColor
	
	output.write = function(char)
		local cx
		if output.info.cursorY >= 1 and output.info.cursorY <= height then
			for i = 1, #char do
				cx = -1 + i + output.info.cursorX
				if cx >= 1 and cx <= output.info.width then
					output.info.buffer[1][output.info.cursorY][cx] = stringSub(char, i, i)
					output.info.buffer[2][output.info.cursorY][cx] = output.info.textColor
					output.info.buffer[3][output.info.cursorY][cx] = output.info.backColor
				end
			end
		end
		output.info.cursorX = output.info.cursorX + #char
	end
	
	output.blit = function(char, text, back)
		local cx
		assert(#char == #text and #text == #back, "arguments must be same length")
		if output.info.cursorY >= 1 and output.info.cursorY <= height then
			for i = 1, #char do
				cx = -1 + i + output.info.cursorX
				if cx >= 1 and cx <= output.info.width then
					output.info.buffer[1][cy][cx] = stringSub(char, i, i)
					output.info.buffer[2][cy][cx] = stringSub(text, i, i)
					output.info.buffer[3][cy][cx] = stringSub(back, i, i)
				end
			end
		end
		output.info.cursorX = output.info.cursorX + #char
	end
	
	output.native = function()
		if true then
			return output.info.nativeTerm
		else
			return output
		end
	end
	
	output.nativePaletteColor = output.info.nativeTerm.nativePaletteColor
	output.nativePaletteColour = output.info.nativeTerm.nativePaletteColour
	
	output.setPaletteColor = function(slot, r, g, b)
		output.info.palette[slot] = {r, g, b}
	end
	output.setPaletteColour = output.setPaletteColor
	
	output.getPaletteColor = function(slot)
		return output.info.palette[slot][1], output.info.palette[slot][2], output.info.palette[slot][3]
	end
	output.getPaletteColour = output.getPaletteColor
	
	output.scroll = function(distance)
		for y = distance, output.info.height do
			for c = 1, 3 do
				output.info.buffer[c][y] = output.info.buffer[c][y + distance] or genTblLine(" ", output.info.width)
			end
		end
	end
	
	output.setVisible = function(visible)
		output.info.visible = visible and true or false
	end
	
	-- draws the window
	output.render = function(x, y, ...)
		x = x or output.info.x
		y = y or output.info.y
		-- can render to multiple terminals
		local termList = {...}
		if output.info.visible then
			if #termList == 0 then
				nTerm = nTerm or output.info.nativeTerm
				for yy = 1, output.info.height do
					nTerm.setCursorPos(x, -1 + y + yy)
					nTerm.blit(
						tableConcat(output.info.buffer[1][yy]),
						tableConcat(output.info.buffer[2][yy]),
						tableConcat(output.info.buffer[3][yy])
					)
				end
			else
				for i = 1, #termList do
					for yy = 1, output.info.height do
						termList[i].setCursorPos(x, -1 + y + yy)
						termList[i].blit(
							tableConcat(output.info.buffer[1][yy]),
							tableConcat(output.info.buffer[2][yy]),
							tableConcat(output.info.buffer[3][yy])
						)
					end
				end
			end
		end
	end
	
	-- turns window into an NFT string image
	output.screenshot = function()
		local image = ""
		local tcol, bcol
		local tchar, bchar = string.char(31), string.char(30)
		for y = 1, output.info.height do
			tcol, bcol = "", ""
			for x = 1, output.info.width do
				if tcol ~= output.info.buffer[2][y][x] then
					tcol = output.info.buffer[2][y][x]
					image = image .. tchar .. tcol
				end
				if bcol ~= output.info.buffer[3][y][x] then
					bcol = output.info.buffer[3][y][x]
					image = image .. bchar .. bcol
				end
				image = image .. output.info.buffer[1][y][x]
			end
			if y < output.info.height then
				image = image .. "\n"
			end
		end
		return image
	end
	
	return output
end

if doGlobalize then
	_G.lddwindow = lddwindow
end

return lddwindow
