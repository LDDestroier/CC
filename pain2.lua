-- pain2

local scr_x, scr_y = term.getSize()
local mx, my = scr_x/2, scr_y/2		-- midpoint of screen
local keysDown = {}					-- list of all pushed keys
local miceDown = {}					-- list of all clicked mice buttons
local dragPoses = {{{},{}}, {{},{}}, {{},{}}}	-- records initial and current mouse position per button while scrolling

local TICKNO = 0				-- iterates every time main() loops
local flashPaletteOnBar = 0		-- whether or not to flash the dot palette numbers on the bottom bar, 0 is false, greater than 0 is true

-- debug renderer is slower, but the normal one isn't functional yet
local useDebugRenderer = false

local canvas = {
	{{},{},{}}
}

local render
local pain = {
	scrollX = 0,				-- x position of scroll
	scrollY = 0,				-- y position of scroll
	frame = 1,
	dot = 1,
	brushSize = 2,				-- size of brush for tools like brush or line
	barmsg = "Started PAIN.",	-- message shown on the bottom bar for 'barlife' ticks
	barlife = 12,				-- amount of time until barmsg will cease to render
	showBar = true,				-- whether or not to show the bottom bar
	doRender = true,			-- if true, will render and set doRender to false
	isInFocus = true,			-- will not accept any non-mouse input while false
	exportMode = "nft",			-- saving will use this format
	limitOneMouseButton = true,	-- disallows using more than one mouse button at a time
	size = {
		x = 1,
		y = 1,
		width = scr_x,
		height = scr_y
	},
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
			"a"
		},
		[3] = {
			" ",
			"f",
			"b"
		},
		[4] = {
			" ",
			"f",
			"c"
		},
		[5] = {
			" ",
			"f",
			"d"
		},
		[6] = {
			" ",
			"f",
			"2"
		},
		[7] = {
			" ",
			"f",
			"3"
		},
		[8] = {
			" ",
			"f",
			"4"
		},
		[9] = {
			" ",
			"f",
			"5"
		},
	},
	tool = "pencil"
}


-- NFTE API START --

local nfte = {}

local tchar = string.char(31)	-- for text colors
local bchar = string.char(30)	-- for background colors
local nchar = string.char(29)	-- for differentiating multiple frames in ANFT

-- every flippable block character that doesn't need a color swap
local xflippable = {
	["\129"] = "\130",
	["\132"] = "\136",
	["\133"] = "\138",
	["\134"] = "\137",
	["\137"] = "\134",
	["\135"] = "\139",
	["\140"] = "\140",
	["\141"] = "\142",
}
-- every flippable block character that needs a color swap
local xinvertable = {
	["\144"] = "\159",
	["\145"] = "\157",
	["\146"] = "\158",
	["\147"] = "\156",
	["\148"] = "\151",
	["\152"] = "\155",
	["\149"] = "\149",
	["\150"] = "\150",
	["\153"] = "\153",
	["\154"] = "\154"
}
for k,v in pairs(xflippable) do
	xflippable[v] = k
end
for k,v in pairs(xinvertable) do
	xinvertable[v] = k
end
local bl = {	-- blit
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
}
local lb = {} 	-- tilb
for k,v in pairs(bl) do
	lb[v] = k
end
local ldchart = {	-- converts colors into a lighter shade
	["0"] = "0",
	["1"] = "4",
	["2"] = "6",
	["3"] = "0",
	["4"] = "0",
	["5"] = "0",
	["6"] = "0",
	["7"] = "8",
	["8"] = "0",
	["9"] = "3",
	["a"] = "2",
	["b"] = "9",
	["c"] = "1",
	["d"] = "5",
	["e"] = "2",
	["f"] = "7"
}

local dlchart = {	-- converts colors into a darker shade
	["0"] = "8",
	["1"] = "c",
	["2"] = "a",
	["3"] = "9",
	["4"] = "1",
	["5"] = "d",
	["6"] = "2",
	["7"] = "f",
	["8"] = "7",
	["9"] = "b",
	["a"] = "7",
	["b"] = "7",
	["c"] = "7",
	["d"] = "7",
	["e"] = "7",
	["f"] = "f"
}
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

local getSizeNFP = function(image)
	local xsize = 0
	if type(image) ~= "table" then return 0,0 end
	for y = 1, #image do xsize = math.max(xsize, #image[y]) end
	return xsize, #image
end

nfte.getSize = function(image)
	assert(checkValid(image), "Invalid image.")
	local x, y = 0, #image[1]
	for y = 1, #image[1] do
		x = math.max(x, #image[1][y])
	end
	return x, y
end

nfte.crop = function(image, x1, y1, x2, y2)
	assert(checkValid(image), "Invalid image.")
	local output = {{},{},{}}
	for y = y1, y2 do
		output[1][#output[1]+1] = image[1][y]:sub(x1,x2)
		output[2][#output[2]+1] = image[2][y]:sub(x1,x2)
		output[3][#output[3]+1] = image[3][y]:sub(x1,x2)
	end
	return output
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

nfte.drawImageCenter = function(image, x, y, terminal)
	terminal = terminal or term.current()
	local scr_x, scr_y = terminal.getSize()
	local imageX, imageY = getSize(image)
	return drawImage(
		image,
		round(0.5 + (x and x or (scr_x/2)) - imageX/2),
		round(0.5 + (y and y or (scr_y/2)) - imageY/2),
		terminal
	)
end

nfte.drawImageCenterTransparent = function(image, x, y, terminal)
	terminal = terminal or term.current()
	local scr_x, scr_y = terminal.getSize()
	local imageX, imageY = getSize(image)
	return drawImageTransparent(
		image,
		round(0.5 + (x and x or (scr_x/2)) - imageX/2),
		round(0.5 + (y and y or (scr_y/2)) - imageY/2),
		terminal
	)
end

nfte.colorSwap = function(image, text, back)
	assert(checkValid(image), "Invalid image.")
	local output = {{},{},{}}
	for y = 1, #image[1] do
		output[1][y] = image[1][y]
		output[2][y] = image[2][y]:gsub(".", text)
		output[3][y] = image[3][y]:gsub(".", back or text)
	end
	return output
end

nfte.flipX = function(image)
	assert(checkValid(image), "Invalid image.")
	local output = {{},{},{}}
	for y = 1, #image[1] do
		output[1][y] = image[1][y]:gsub(".", xinvertable):gsub(".", xflippable):reverse()
		output[2][y] = ""
		output[3][y] = ""
		for x = 1, #image[1][y] do
			if xinvertable[image[1][y]:sub(x,x)] then
				output[2][y] = image[3][y]:sub(x,x) .. output[2][y]
				output[3][y] = image[2][y]:sub(x,x) .. output[3][y]
			else
				output[2][y] = image[2][y]:sub(x,x) .. output[2][y]
				output[3][y] = image[3][y]:sub(x,x) .. output[3][y]
			end
		end
	end
	return output
end

nfte.flipY = function(image)
	assert(checkValid(image), "Invalid image.")
	local output = {{},{},{}}
	for y = #image[1], 1, -1 do
		output[1][#output[1]+1] = image[1][y]
		output[2][#output[2]+1] = image[2][y]
		output[3][#output[3]+1] = image[3][y]
	end
	return output
end

nfte.makeRectangle = function(width, height, char, text, back)
	assert(type(width) == "number", "width must be number")
	assert(type(height) == "number", "height must be number")
	local output = {{},{},{}}
	for y = 1, height do
		output[1][y] = (char or " "):rep(width)
		output[2][y] = (text or " "):rep(width)
		output[3][y] = (back or " "):rep(width)
	end
	return output
end

nfte.grayOut = function(image)
	assert(checkValid(image), "Invalid image.")
	local output = {{},{},{}}
	local chart = {
		["0"] = "0",
		["1"] = "8",
		["2"] = "8",
		["3"] = "8",
		["4"] = "8",
		["5"] = "8",
		["6"] = "8",
		["7"] = "7",
		["8"] = "8",
		["9"] = "7",
		["a"] = "7",
		["b"] = "7",
		["c"] = "7",
		["d"] = "7",
		["e"] = "7",
		["f"] = "f"
	}
	for y = 1, #image[1] do
		output[1][y] = image[1][y]
		output[2][y] = image[2][y]:gsub(".", chart)
		output[3][y] = image[3][y]:gsub(".", chart)
	end
	return output
end

nfte.lighten = function(image, amount)
	assert(checkValid(image), "Invalid image.")
	if (amount or 1) < 0 then
		return nfte.darken(image, -amount)
	else
		local output = deepCopy(image)
		for i = 1, amount or 1 do
			for y = 1, #output[1] do
				output[1][y] = output[1][y]
				output[2][y] = output[2][y]:gsub(".",ldchart)
				output[3][y] = output[3][y]:gsub(".",ldchart)
			end
		end
		return output
	end
end

nfte.darken = function(image, amount)
	assert(checkValid(image), "Invalid image.")
	if (amount or 1) < 0 then
		return nfte.lighten(image, -amount)
	else
		local output = deepCopy(image)
		for i = 1, amount or 1 do
			for y = 1, #output[1] do
				output[1][y] = output[1][y]
				output[2][y] = output[2][y]:gsub(".",dlchart)
				output[3][y] = output[3][y]:gsub(".",dlchart)
			end
		end
		return output
	end
end

nfte.stretchImage = function(_image, sx, sy, noRepeat)
	assert(checkValid(_image), "Invalid image.")
	local output = {{},{},{}}
	local image = deepCopy(_image)
	if sx < 0 then image = flipX(image) end
	if sy < 0 then image = flipY(image) end
	sx, sy = math.abs(sx), math.abs(sy)
	local imageX, imageY = getSize(image)
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

nfte.stretchImageKeepAspect = function(image, sx, sy, noRepeat)
	assert(checkValid(image), "Invalid image.")
	local imX, imY = nfte.getSize(image)
	local aspect = sx / sy
	local imAspect = imX / imY
	if imAspect > aspect then
		return nfte.stretchImage(image, sx, sx / imAspect, noRepeat)
	elseif imAspect < aspect then
		return nfte.stretchImage(image, sy * imAspect, sy, noRepeat)
	else
		return nfte.stretchImage(image, sx, sy, noRepeat)
	end
end

-- will stretch and unstretch an image to radically lower its resolution
nfte.pixelateImage = function(image, amntX, amntY)
	assert(checkValid(image), "Invalid image.")
	local imageX, imageY = getSize(image)
	return stretchImage(stretchImage(image,imageX/math.max(amntX,1), imageY/math.max(amntY,1)), imageX, imageY)
end

nfte.merge = function(...)
	local images = {...}
	local output = {{},{},{}}
	local imageX, imageY = 0, 0
	local imSX, imSY
	for i = 1, #images do
		imageY = math.max(
			imageY,
			#images[i][1][1] + (images[i][3] == true and 0 or (images[i][3] - 1))
		)
		for y = 1, #images[i][1][1] do
			imageX = math.max(
				imageX,
				#images[i][1][1][y] + (images[i][2] == true and 0 or (images[i][2] - 1))
			)
		end
	end
	-- if either coordinate is true, center it
	for i = 1, #images do
		imSX, imSY = getSize(images[i][1])
		if images[i][2] == true then
			images[i][2] = round(1 + (imageX / 2) - (imSX / 2))
		end
		if images[i][3] == true then
			images[i][3] = round(1 + (imageY / 2) - (imSY / 2))
		end
	end

	-- will later add code to adjust X/Y positions if negative values are given

	local image, xadj, yadj
	local tx, ty
	for y = 1, imageY do
		output[1][y] = {}
		output[2][y] = {}
		output[3][y] = {}
		for x = 1, imageX do
			for i = #images, 1, -1 do
				image, xadj, yadj = images[i][1], images[i][2], images[i][3]
				tx, ty = x-(xadj-1), y-(yadj-1)
				output[1][y][x] = output[1][y][x] or " "
				output[2][y][x] = output[2][y][x] or " "
				output[3][y][x] = output[3][y][x] or " "
				if image[1][ty] then
					if (image[1][ty]:sub(tx,tx) ~= "") and (tx >= 1) then
						output[1][y][x] = (image[1][ty]:sub(tx,tx) == " " and output[1][y][x] or image[1][ty]:sub(tx,tx))
						output[2][y][x] = (image[2][ty]:sub(tx,tx) == " " and output[2][y][x] or image[2][ty]:sub(tx,tx))
						output[3][y][x] = (image[3][ty]:sub(tx,tx) == " " and output[3][y][x] or image[3][ty]:sub(tx,tx))
					end
				end
			end
		end
		output[1][y] = table.concat(output[1][y])
		output[2][y] = table.concat(output[2][y])
		output[3][y] = table.concat(output[3][y])
	end
	return output
end

local rotatePoint = function(x, y, angle, originX, originY)
	return
		round( (x-originX) * math.cos(angle) - (y-originY) * math.sin(angle) ) + originX,
		round( (x-originX) * math.sin(angle) + (y-originY) * math.cos(angle) ) + originY
end

nfte.rotateImage = function(image, angle, originX, originY)
	assert(checkValid(image), "Invalid image.")
	if imageX == 0 or imageY == 0 then
		return image
	end
	local output = {{},{},{}}
	local realOutput = {{},{},{}}
	local tx, ty, corners
	local imageX, imageY = getSize(image)
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









local setBarMsg = function(message)
	pain.barmsg = message
	pain.barlife = 16
	pain.doRender = true
end

local controlHoldCheck = {}	-- used to prevent repeated inputs on non-repeating controls
local control = {
	quit = {
		key = keys.q,
		holdDown = false,
		modifiers = {
			[keys.leftCtrl] = true
		},
	},
	scrollUp = { -- decrease scrollY
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
	resetScroll = {
		key = keys.a,
		holdDown = false,
		modifiers = {},
	},
	switchNextFrame = {
		key = keys.rightBracket,
		holdDown = false,
		modifiers = {
			[keys.leftShift] = true
		},
	},
	switchPrevFrame = {
		key = keys.leftBracket,
		holdDown = false,
		modifiers = {
			[keys.leftShift] = true
		},
	},
	swapNextFrame = {
		key = keys.rightBracket,
		holdDownn = false,
		modifiers = {
			[keys.leftShift] = true,
			[keys.leftAlt] = true,
		}
	},
	swapPrevFrame = {
		key = keys.leftBracket,
		holdDownn = false,
		modifiers = {
			[keys.leftShift] = true,
			[keys.leftAlt] = true,
		}
	},
	increaseBrushSize = {
		key = keys.equals,
		holdDown = false,
		modifiers = {},
	},
	increaseBrushSize_Alt = {
		key = keys.numPadAdd,
		holdDown = false,
		modifiers = {},
	},
	decreaseBrushSize = {
		key = keys.minus,
		holdDown = false,
		modifiers = {},
	},
	decreaseBrushSize_Alt = {
		key = keys.numPadSubtract,
		holdDown = false,
		modifiers = {},
	},
	moveMod = {
		key = keys.leftShift,
		holdDown = true,
		modifiers = {
			[keys.leftShift] = true
		},
	},
	creepMod = {
		key = keys.leftAlt,
		holdDown = true,
		modifiers = {
			[keys.leftAlt] = true
		},
	},
	toolMod = {
		key = keys.leftShift,
		holdDown = true,
		modifiers = {
			[keys.leftShift] = true
		},
	},
	pencilTool = {
		key = keys.p,
		holdDown = false,
		modifiers = {
			[keys.leftShift] = true
		},
	},
	brushTool = {
		key = keys.b,
		holdDown = false,
		modifiers = {
			[keys.leftShift] = true
		},
	},
	textTool = {
		key = keys.t,
		holdDown = false,
		modifiers = {
			[keys.leftShift] = true
		},
	},
	lineTool = {
		key = keys.l,
		holdDown = false,
		modifiers = {
			[keys.leftShift] = true
		},
	},
	selectPalette_0 = {
		key = keys.zero,
		holdDown = false,
		modifiers = {},
	},
	selectPalette_1 = {
		key = keys.one,
		holdDown = false,
		modifiers = {},
	},
	selectPalette_2 = {
		key = keys.two,
		holdDown = false,
		modifiers = {},
	},
	selectPalette_3 = {
		key = keys.three,
		holdDown = false,
		modifiers = {},
	},
	selectPalette_4 = {
		key = keys.four,
		holdDown = false,
		modifiers = {},
	},
	selectPalette_5 = {
		key = keys.five,
		holdDown = false,
		modifiers = {},
	},
	selectPalette_6 = {
		key = keys.six,
		holdDown = false,
		modifiers = {},
	},
	selectPalette_7 = {
		key = keys.seven,
		holdDown = false,
		modifiers = {},
	},
	selectPalette_8 = {
		key = keys.eight,
		holdDown = false,
		modifiers = {},
	},
	selectPalette_9 = {
		key = keys.nine,
		holdDown = false,
		modifiers = {},
	},
	selectNextPalette = {
		key = keys.rightBracket,
		holdDown = false,
		modifiers = {},
	},
	selectPrevPalette = {
		key = keys.leftBracket,
		holdDown = false,
		modifiers = {},
	},
}

local checkControl = function(name)
	local modlist = {
		keys.leftCtrl,
--		keys.rightCtrl,
		keys.leftShift,
--		keys.rightShift,
		keys.leftAlt,
--		keys.rightAlt,
	}
	for i = 1, #modlist do
		if control[name].modifiers[modlist[i]] then
			if not keysDown[modlist[i]] then
				return false
			end
		else
			if keysDown[modlist[i]] then
				return false
			end
		end
	end
	if keysDown[control[name].key] then
		if control[name].holdDown then
			return true
		else
			if not controlHoldCheck[name] then
				controlHoldCheck[name] = true
				return true
			end
		end
	else
		controlHoldCheck[name] = false
		return false
	end
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
	x, y = 1 + x - pain.size.x, 1 + y - pain.size.y
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
	x, y = 1 - pain.size.x + x, 1 - pain.size.y + y
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
		"..%%",
		"..%%",
		"..%%",
		"%%..",
		"%%..",
		"%%..",
	}
	if x < 1 or y < 1 then
		return "/", "7", "f"
	else
		local sx, sy = 1 + (1 + x) % #grid[1], 1 + (2 + y) % #grid
		return grid[sy]:sub(sx,sx), "7", "f"
	end
end

local getEvents = function(...)
	local evt
	while true do
		evt = {os.pullEvent()}
		for i = 1, #arg do
			if evt[1] == arg[i] then
				return table.unpack(evt)
			end
		end
	end
end

-- every tool at your disposal
local tools = {
	pencil = {
		info = {
			name = "Pencil",
			swapTool = "line",	-- if swap button is held, will turn into this tool
			altTool = "text",	-- if middle mouse button is held, will use this tool (overrides swapTool)
			swapArg = {			-- any values in this table will override those in 'arg' if using swapTool
				size = 1
			},
			altArg = {},		-- any values in this table will override those in 'arg' if using altTool
		},
		run = function(arg)
			if arg.event == "mouse_click" then
				if arg.actButton == 1 then
					placeDot(arg.sx, arg.sy, arg.frame, arg.dot)
				elseif arg.actButton == 2 then
					deleteDot(arg.sx, arg.sy, arg.frame)
				end
				dragPos = {arg.sx, arg.sy}
			else
				if #dragPos == 0 then
					dragPos = {arg.sx, arg.sy}
				end
				local poses = getDotsInLine(arg.sx, arg.sy, dragPos[1], dragPos[2])
				for i = 1, #poses do
					if arg.actButton == 1 then
						placeDot(poses[i].x, poses[i].y, arg.frame, arg.dot)
					elseif arg.actButton == 2 then
						deleteDot(poses[i].x, poses[i].y, arg.frame)
					end
				end
				dragPos = {arg.sx, arg.sy}
			end
		end
	},
	brush = {
		info = {
			name = "Brush",
			swapTool = "line",
			altTool = "text",
			swapArg = {},
			altArg = {}
		},
		run = function(arg)
			if arg.event == "mouse_click" then
				for y = -arg.size, arg.size do
					for x = -arg.size, arg.size do
						if math.sqrt(x^2 + y^2) <= arg.size / 2 then
							if arg.actButton == 1 then
								placeDot(arg.sx + x, arg.sy + y, arg.frame, arg.dot)
							elseif arg.actButton == 2 then
								deleteDot(arg.sx + x, arg.sy + y, arg.frame)
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
								if arg.actButton == 1 then
									placeDot(poses[i].x + x, poses[i].y + y, arg.frame, arg.dot)
								elseif arg.actButton == 2 then
									deleteDot(poses[i].x + x, poses[i].y + y, arg.frame)
								end
							end
						end
					end
				end
				dragPos = {arg.sx, arg.sy}
			end
		end
	},
	text = {
		info = {
			name = "Text",
			swapTool = "pencil",
			altTool = "text",
			swapArg = {},
			altArg = {}
		},
		run = function(arg)
			pain.paused = true
			pain.barmsg = "Type text to add to canvas."
			pain.barlife = 1
			render()
			term.setCursorPos(arg.x, arg.y)
			term.setTextColor(to_colors[arg.dot[2]])
			term.setBackgroundColor(to_colors[arg.dot[3]])
			local text = read()
			-- re-render every keypress, requires custom read function
			for i = 1, #text do
				placeDot(arg.sx + i - 1, arg.sy, arg.frame, {text:sub(i,i), pain.dots[pain.dot][2], pain.dots[pain.dot][3]})
			end
			pain.paused = false
			keysDown = {}
			miceDown = {}
		end
	},
	line = {
		info = {
			name = "Line",
			swapTool = "pencil",
			altTool = "brush",
			swapArg = {},
			altArg = {}
		},
		run = function(arg)
			local dots
			while miceDown[arg.button] do
				arg.size = arg.size or pain.brushSize
				dots = getDotsInLine(
					dragPoses[arg.button][1].x + (arg.scrollX - pain.scrollX),
					dragPoses[arg.button][1].y + (arg.scrollY - pain.scrollY),
					dragPoses[arg.button][2].x,
					dragPoses[arg.button][2].y
				)
				render()
				for i = 1, #dots do
					if dots[i].x >= pain.size.x and dots[i].x < pain.size.x + pain.size.width then
						for y = -arg.size, arg.size do
							for x = -arg.size, arg.size do
								if math.sqrt(x^2 + y^2) <= arg.size / 2 then
									if (not pain.showBar) or dots[i].y + y < -1 + pain.size.y + pain.size.height then
										term.setCursorPos(dots[i].x + x, dots[i].y + y)
										if arg.actButton == 1 then
											term.blit(table.unpack(arg.dot))
										elseif arg.actButton == 2 then
											term.blit(getGridAtPos(dots[i].x + pain.scrollX + x, dots[i].y + pain.scrollY + y))
										end
									end
								end
							end
						end
					end
				end

				os.pullEvent()
			end
			-- write dots to canvas
			for i = 1, #dots do
				for y = -arg.size, arg.size do
					for x = -arg.size, arg.size do
						if math.sqrt(x^2 + y^2) <= arg.size / 2 then
							if arg.actButton == 1 then
								placeDot(dots[i].x + x + pain.scrollX, dots[i].y + y + pain.scrollY, arg.frame, arg.dot)
							elseif arg.actButton == 2 then
								deleteDot(dots[i].x + x + pain.scrollX, dots[i].y + y + pain.scrollY, arg.frame)
							end
						end
					end
				end
			end
		end
	},
}

-- ran every event on separate coroutine
-- will check if you should be using a tool given mouse and key inputs, then runs said tool
local tryTool = function()
	local swapArg = {}
	local t = tools[pain.tool]
	if miceDown[3] then
		swapArg = t.info.altArg or {}
		t = tools[t.info.altTool]
	end
	if checkControl("toolMod") then
		swapArg = t.info.swapArg or {}
		t = tools[t.info.swapTool]
	end
	swapArg.actButton = miceDown[3] and 1
	for butt = 1, 3 do
		if miceDown[butt] and t then
			t.run({
				x 			= swapArg.x or miceDown[butt].x,
				y 			= swapArg.y or miceDown[butt].y,
				sx 			= swapArg.sx or ((swapArg.x or miceDown[butt].x) + pain.scrollX),
				sy 			= swapArg.sy or ((swapArg.y or miceDown[butt].y) + pain.scrollY),
				scrollX 	= swapArg.scrollX or pain.scrollX,
				scrollY 	= swapArg.scrollY or pain.scrollY,
				frame 		= swapArg.frame or pain.frame,
				dot 		= swapArg.dot or pain.dots[pain.dot],
				size 		= swapArg.size or pain.brushSize,
				button	 	= swapArg.button or butt,
				actButton 	= swapArg.actButton or butt,	-- will act as if this button is held, if not nil
				event 		= swapArg.event or miceDown[butt].event
			})
			pain.doRender = true
			break
		end
	end
end

-- shows everything on screen
render = function(x, y, width, height)
	local buffer = {{},{},{}}
	local cx, cy
	x = x or pain.size.x
	y = y or pain.size.y
	width = width or pain.size.width
	height = height or pain.size.height
	-- see, it wouldn't do if I just individually set the cursor position for every dot
	if useDebugRenderer then

		term.clear()
		local cx, cy
		for yy, line in pairs(canvas[pain.frame][1]) do
			for xx, dot in pairs(canvas[pain.frame][1][yy]) do
				cx = xx - pain.scrollX
				cy = yy - pain.scrollY
				if cx >= x and cx <= (x + width - 1) and cy >= y and cy <= (x + width - 1) then
					term.setCursorPos(cx, cy)
					term.blit(
						canvas[pain.frame][1][yy][xx],
						canvas[pain.frame][2][yy][xx],
						canvas[pain.frame][3][yy][xx]
					)
				end
			end
		end

	else

		local gChar, gText, gBack
		for yy = 1, -1 + height + y do
			buffer[1][yy] = ""
			buffer[2][yy] = ""
			buffer[3][yy] = ""
			if pain.showBar and yy == height then
				term.setTextColor(colors.black)
				term.setBackgroundColor(colors.lightGray)
				term.setCursorPos(pain.size.x, -1 + pain.size.y + pain.size.height)
				term.write("[" .. pain.scrollX .. "," .. pain.scrollY .. "] ")
				for i = 1, #pain.dots do
					if flashPaletteOnBar > 0 then
						if i == pain.dot then
							term.blit(tostring(i), "0", pain.dots[i][3])
						else
							term.blit(tostring(i), "7", pain.dots[i][3])
						end
					else
						term.blit(table.unpack(pain.dots[i]))
					end
				end
				if pain.barlife > 0 then
					term.write(" " .. pain.barmsg)
				else
					term.write(" " .. tools[pain.tool].info.name .. " tool")
				end
				term.write((" "):rep(x + width - term.getCursorPos()))
			else
				for xx = 1, width do
					cx = xx + pain.scrollX
					cy = yy + pain.scrollY
					if canvas[pain.frame][1][cy] then
						if canvas[pain.frame][1][cy][cx] then
							for c = 1, 3 do
								buffer[c][yy] = buffer[c][yy] .. canvas[pain.frame][c][cy][cx]
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
			term.setCursorPos(x, y + yy)
			term.blit(buffer[1][yy+1], buffer[2][yy+1], buffer[3][yy+1])
		end

	end

	if false then
		term.setCursorPos(1,1)
		write(textutils.serialize(miceDown))
	end

end

local getInput = function()
	local evt, adjX, adjY, paletteListX
	local keySwapList = {
		[keys.rightShift] = keys.leftShift,
		[keys.rightAlt] = keys.leftAlt,
		[keys.rightCtrl] = keys.leftCtrl,
	}
	while true do
		evt = {os.pullEvent()}
		if evt[1] == "mouse_click" or evt[1] == "mouse_drag" then

			-- start X for the list of color palettes to choose from
			paletteListX = 5 + #tostring(pain.scrollX) + #tostring(pain.scrollY)

			-- (x, y) relative to (pain.size.x, pain.size.y)
			adjX, adjY = 1 + evt[3] - pain.size.x, 1 + evt[4] - pain.size.y

			if adjX >= 1 and adjX <= pain.size.width and adjY >= 1 and adjY <= pain.size.height then

				pain.isInFocus = true

				if adjY == pain.size.height then

					if evt[1] == "mouse_click" then
						if adjX >= paletteListX and adjX <= -1 + paletteListX + #pain.dots then
							pain.dot = 1 + adjX - paletteListX
							setBarMsg("Selected palette " .. pain.dot .. ".")
						else
							-- openBarMenu()
						end
					end

				else

					if pain.limitOneMouseButton then
						dragPoses = {
							dragPoses[1] or {{},{}},
							dragPoses[2] or {{},{}},
							dragPoses[3] or {{},{}}
						}
						dragPoses = {
							[evt[2]] = {
								{
									x = dragPoses[evt[2]][1].x or evt[3],
									y = dragPoses[evt[2]][1].y or evt[4]
								},
								{
									x = evt[3],
									y = evt[4]
								}
							}
						}
						if evt[1] == "mouse_click" or miceDown[evt[2]] then
							miceDown = {{},{},{}}
							miceDown = {
								[evt[2]] = {
									event = evt[1],
									button = evt[2],
									x = evt[3],
									y = evt[4],
								}
							}
						end
					else
						dragPoses[evt[2]] = {
							{
								x = dragPoses[evt[2]][1].x or evt[3],
								y = dragPoses[evt[2]][1].y or evt[4]
							},
							{
								x = evt[3],
								y = evt[4]
							}
						}
						if evt[1] == "mouse_click" or miceDown[evt[2]] then
							miceDown[evt[2]] = {
								event = evt[1],
								button = evt[2],
								x = evt[3],
								y = evt[4],
							}
						end
					end

				end
			else
				pain.isInFocus = false
			end
		elseif evt[1] == "key" then
			if pain.isInFocus then
				keysDown[evt[2]] = true
				keysDown[keySwapList[evt[2]] or evt[2]] = true
			else
				keysDown = {}
			end
		elseif evt[1] == "mouse_up" then
			if pain.limitOneMouseButton then
				dragPoses = {{{},{}}, {{},{}}, {{},{}}}
			else
				dragPoses[evt[2]] = {{},{}}, {{},{}}, {{},{}}
			end
			miceDown[evt[2]] = false
		elseif evt[1] == "key_up" then
			keysDown[evt[2]] = false
			keysDown[keySwapList[evt[2]] or evt[2]] = false
		end
	end
end

-- executes everything that doesn't run asynchronously
main = function()
	while true do

		if not pain.paused then

			if pain.doRender then
				render()
				pain.doRender = false
			end

			if checkControl("quit") then
				return true
			end

			-- handle scrolling
			if checkControl("resetScroll") then
				pain.scrollX = 0
				pain.scrollY = 0
				pain.doRender = true
			else
				if checkControl("increaseBrushSize") or checkControl("increaseBrushSize_Alt") then
					pain.brushSize = math.min(pain.brushSize + 1, 16)
					setBarMsg("Increased brush size to " .. pain.brushSize .. ".")
				elseif checkControl("decreaseBrushSize") or checkControl("decreaseBrushSize_Alt") then
					pain.brushSize = math.max(pain.brushSize - 1, 1)
					setBarMsg("Decreased brush size to " .. pain.brushSize .. ".")
				elseif checkControl("scrollLeft") then
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
			if checkControl("selectNextPalette") then
				if pain.dot < #pain.dots then
					pain.dot = pain.dot + 1
					flashPaletteOnBar = 6
					setBarMsg("Switched to next palette " .. pain.dot .. ".")
				else
					setBarMsg("Reached end of palette list.")
				end
			end
			if checkControl("selectPrevPalette") then
				if pain.dot > 1 then
					pain.dot = pain.dot - 1
					flashPaletteOnBar = 6
					setBarMsg("Switched to previous palette " .. pain.dot .. ".")
				else
					setBarMsg("Reached beginning of palette list.")
				end
			end
			for i = 0, 9 do
				if checkControl("selectPalette_" .. i) then
					if pain.dots[i] then
						pain.dot = i
						flashPaletteOnBar = 6
						setBarMsg("Selected palette " .. pain.dot .. ".")
						break
					else
						setBarMsg("There is no palette " .. i .. ".")
						break
					end
				end
			end
			if checkControl("pencilTool") then
				pain.tool = "pencil"
				setBarMsg("Selected pencil tool.")
			elseif checkControl("textTool") then
				pain.tool = "text"
				setBarMsg("Selected text tool.")
			elseif checkControl("brushTool") then
				pain.tool = "brush"
				setBarMsg("Selected brush tool.")
			elseif checkControl("lineTool") then
				pain.tool = "line"
				setBarMsg("Selected line tool.")
			end

			-- decrement bar life and palette number indicator
			-- if it's gonna hit zero, make sure it re-renders

			if pain.barlife == 1 then
				pain.doRender = true
			end
			pain.barlife = math.max(pain.barlife - 1, 0)

			if flashPaletteOnBar == 1 then
				pain.doRender = true
			end
			flashPaletteOnBar = math.max(flashPaletteOnBar - 1, 0)

		end

		TICKNO = TICKNO + 1
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

-- exit cleanly

term.setCursorPos(1, scr_y)
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clearLine()
