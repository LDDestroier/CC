local getAPI = function(apiname, apipath, apiurl, doDoFile, doScroll)
	apipath = fs.combine(".roterm-api", apipath)
	if (not fs.exists(apipath)) then
		if doScroll then term.scroll(1) end
		print(apiname .. " API not found! Downloading...")
		local prog = http.get(apiurl)
		if not prog then
			if doScroll then term.scroll(1) end
			error("Failed to download " .. apiname .. " API. Abort.")
			term.setCursorPos(1,1)
			return
		end
		local file = fs.open(apipath,"w")
		file.write(prog.readAll())
		file.close()
	end
	if doDoFile then
		return dofile(apipath)
	else
		os.loadAPI(apipath)
	end
	if not _ENV[fs.getName(apipath)] then
		if doScroll then term.scroll(1) end
		error("Failed to load " .. apiname .. " API. Abort.")
		term.setCursorPos(1,1)
		return
	else
		return _ENV[fs.getName(apipath)]
	end
end

local nfte 	= getAPI("NFT Extra", 	"nfte.lua", 	"https://github.com/LDDestroier/NFT-Extra/raw/master/nfte.lua", true)
local lddterm 	= getAPI("LDDTerm", 	"lddterm.lua", 	"https://github.com/LDDestroier/CC/raw/master/lddterm-cc.lua", 	true)

local scr_x, scr_y = term.getSize()

lddterm.alwaysRender = false
lddterm.baseTerm = term.current()
local win = lddterm.newWindow(scr_x, scr_y, 1, 1)
local t = win.handle

local angle = 0

term.redirect(t)

lddterm.transformation = function(image)
	local output, adjX, adjY = nfte.rotateImage(image, math.rad(angle))
	return output
end

lddterm.drawFunction = function(image, baseTerm)
	baseTerm.clear()
	nfte.drawImageCenter(image, nil, nil, baseTerm)
end

lddterm.cursorTransformation = function(x, y)
	local originX = math.floor(scr_x / 2)
	local originY = math.floor(scr_y / 2)
	local ang = math.rad(angle)
	return
		math.floor( 0.5 + (x-originX) * math.cos(ang) - (y-originY) * math.sin(ang) ) + originX,
		math.floor( 0.5 + (x-originX) * math.sin(ang) + (y-originY) * math.cos(ang) ) + originY
end

parallel.waitForAny(
	function()
		shell.run("/rom/programs/shell.lua")
	end,
	function()
		local evt
		local tID = os.startTimer(0.05)
		while true do
			evt = {os.pullEvent()}
			if evt[1] == "key" then
				if evt[2] == keys.pageDown then
					angle = (angle + 2) % 360
					lddterm.render(lddterm.transformation, lddterm.drawFunction)
				elseif evt[2] == keys.pageUp then
					angle = (angle - 2) % 360
					lddterm.render(lddterm.transformation, lddterm.drawFunction)
				end
			elseif evt[1] == "timer" then
				if evt[2] == tID then
					lddterm.render(lddterm.transformation, lddterm.drawFunction)
					tID = os.startTimer(0.05)
				end
			end
		end
	end
)
