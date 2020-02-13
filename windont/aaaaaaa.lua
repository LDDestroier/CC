if not fs.exists("windont.lua") then
	print("'windont.lua' not found! Downloading...")
	local net = http.get("https://github.com/LDDestroier/CC/raw/master/windont/windont.lua")
	if net then
		local file = fs.open("windont.lua", "w")
		file.write(net.readAll())
		file.close()
		net.close()
	else
		error("Could not download Windon't.", 0)
	end
end

local windont = require "windont"

local transformation = function(x, y, char, text, back, meta)
	return {x, y, char:upper()}
end

windont.default.alwaysRender = true

local win = windont.newWindow(1, 1, term.getSize())
win.meta.transformation = transformation

local pList, sList = {}, {}
for i = 0, 15 do
	pList[i] = {math.random(0, 359), math.random(0, 359), math.random(0, 359)}
	sList[i] = {}
end

term.redirect(win)

local low, high = 20, 40
local cDiv = 15

parallel.waitForAny(
	function()
		shell.run("rom/programs/shell.lua")
	end,
	function()
		local r, g, b
		while true do
			for i = 0, 15 do
				sList[i][1] = math.sin(math.rad(pList[i][1])) / cDiv
				sList[i][2] = math.sin(math.rad(pList[i][2])) / cDiv
				sList[i][3] = math.sin(math.rad(pList[i][3])) / cDiv

				pList[i][1] = (pList[i][1] + math.random(low, high)) % 360
				pList[i][2] = (pList[i][1] + math.random(low, high)) % 360
				pList[i][3] = (pList[i][1] + math.random(low, high)) % 360

				r, g, b = term.nativePaletteColor(2^i)
				term.setPaletteColor(2^i, r + sList[i][1], g + sList[i][2], b + sList[i][3])
			end
			sleep(0.05)
		end
	end
)
