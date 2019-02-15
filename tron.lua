--[[
	TRON Light Cycle Game
	programmed by LDDestroier

	wget https://raw.githubusercontent.com/LDDestroier/CC/master/tron.lua
--]]

local port = 701
local kioskMode = false
local debugShowKeys = false
local useLegacyMouseControl = false

local scr_x, scr_y = term.getSize()
local scr_mx, scr_my = scr_x / 2, scr_y / 2
local isColor = term.isColor()

-- lower value = faster game. I'd reccommend 0.1 for SMP play.
local gameDelayInit = 0.1
local doDrawPlayerNames = false
local useSetVisible = true

local initGrid = {
	x1 = -100,
	y1 = -100,
	x2 = 100,
	y2 = 100,
	border = "#",
	voidcol = "f",
	forecol = "8",
	backcol = "7",
	edgecol = "0"
}
local resetPlayers = function()
	return {
		[1] = {
			num = 1,
			x = -2,
			y = -5,
			direction = -1,
			char = "@",
			color = {
				colors.blue,
				colors.blue,
				colors.blue,
				colors.cyan,
				colors.cyan,
				colors.lightBlue,
				colors.lightBlue,
				colors.cyan,
				colors.cyan
			},
			dead = false,
			putTrail = true,
			name = "BLU"
		},
		[2] = {
			num = 2,
			x = 2,
			y = -5,
			direction = -1,
			char = "@",
			color = {
				colors.red,
				colors.red,
				colors.red,
				colors.orange,
				colors.orange,
				colors.yellow,
				colors.yellow,
				colors.orange,
				colors.orange
			},
			dead = false,
			putTrail = true,
			name = "RED"
		}
	}
end
local tArg = {...}
local useSkynet = (tArg[1] or ""):lower() == "skynet"
local useOnce = (tArg[2] or tArg[1] or ""):lower() == "quick"
local argumentName = tArg[3] or tArg[2] or tArg[1] or nil
local skynetPath = "skynet"
local skynetURL = "https://raw.githubusercontent.com/osmarks/skynet/master/client.lua"

local modem, skynet
if useSkynet then
	if fs.exists(skynetPath) then
		skynet = dofile(skynetPath)
		skynet.open(port)
	else
		local prog = http.get(skynetURL)
		if prog then
			local file = fs.open(skynetPath, "w")
			file.write(prog.readAll())
			file.close()
			skynet = dofile(skynetPath)
			skynet.open(port)
		else
			error("Could not download Skynet.")
		end
	end
else
	modem = peripheral.find("modem")
	if (not modem) and ccemux then
		ccemux.attach("top", "wireless_modem")
		modem = peripheral.find("modem")
	end
	if modem then
		modem.open(port)
	else
		error("You should attach a modem.")
	end
end

local transmit = function(port, message)
	if useSkynet then
		skynet.send(port, message)
	else
		modem.transmit(port, port, message)
	end
end

local gamename = ""
local isHost
local squareGrid = true

local waitingForGame = true
local toblit = {
	[0] = " ",
	[colors.white] = "0",
	[colors.orange] = "1",
	[colors.magenta] = "2",
	[colors.lightBlue] = "3",
	[colors.yellow] = "4",
	[colors.lime] = "5",
	[colors.pink] = "6",
	[colors.gray] = "7",
	[colors.lightGray] = "8",
	[colors.cyan] = "9",
	[colors.purple] = "a",
	[colors.blue] = "b",
	[colors.brown] = "c",
	[colors.green] = "d",
	[colors.red] = "e",
	[colors.black] = "f"
}
local tograyCol, tograyBlit = {
	[0] = 0,
	[colors.white] = colors.white,
	[colors.orange] = colors.lightGray,
	[colors.magenta] = colors.lightGray,
	[colors.lightBlue] = colors.white,
	[colors.yellow] = colors.white,
	[colors.lime] = colors.lightGray,
	[colors.pink] = colors.lightGray,
	[colors.gray] = colors.gray,
	[colors.lightGray] = colors.lightGray,
	[colors.cyan] = colors.lightGray,
	[colors.purple] = colors.gray,
	[colors.blue] = colors.gray,
	[colors.brown] = colors.gray,
	[colors.green] = colors.gray,
	[colors.red] = colors.white,
	[colors.black] = colors.black
}, {}

local tocolors = {}
for k,v in pairs(toblit) do
	tocolors[v] = k
end
for k,v in pairs(tograyCol) do
	tograyBlit[toblit[k]] = toblit[v]
end

local termwrite, termclear = term.write, term.clear
local termsetCursorPos, termgetCursorPos = term.setCursorPos, term.getCursorPos
local tableunpack, tableremove = unpack, table.remove
local mathfloor, mathceil, mathcos, mathsin, mathrandom, mathrad = math.floor, math.ceil, math.cos, math.sin, math.random, math.rad

local termsetTextColor = function(col)
	return term.setTextColor(isColor and col or tograyCol[col])
end

local termsetBackgroundColor = function(col)
	return term.setBackgroundColor(isColor and col or tograyCol[col])
end

local termblit = function(char, text, back)
	if isColor then
		return term.blit(char, text, back)
	else
		return term.blit(
			char,
			text:gsub(".", tograyBlit),
			back:gsub(".", tograyBlit)
		)
	end
end

local tsv = function(visible)
	if term.current().setVisible and useSetVisible then
		term.current().setVisible(visible)
	end
end

local copyTable
copyTable = function(tbl, ...)
	local output = {}
	for k,v in pairs(tbl) do
		if type(v) == "table" then
			output[k] = copyTable(v)
		else
			output[k] = v
		end
	end
	for i = 1, #arg do
		output[#output+1] = arg[i]
	end
	return output
end

grid = copyTable(initGrid)

local you, nou = 1, 2

local keysDown, netKeysDown = {}, {}
local lastDirectionPressed, netLastDirectionPressed

-- the scrolling of the screen
local scrollX = 0
local scrollY = 0

-- used when panning with WASD
local scrollAdjX = 0
local scrollAdjY = 0

local lockInput = false
local player

player = resetPlayers()

local images = {
	logo = {
		{
			"          ",
			"     ",
			"                ",
			"         ",
			"            ",
			"                  ",
			"                      ",
		},
		{
			" f7777777777777777777f   f77777f  7f    f777",
			" f99979999979999999999f 799999799 77f7  f997",
			"     799          79999f997    9977997f f997",
			"     799    7797777fffff997    9977997797997",
			"     799    799 799977f7797fff7997799  79797",
			"     799    799   7797f 797999997 799    797",
			"     777    777    7777  7777777  777     77",
		},
		{
			" 7999999999f9999999997   7999997  97    799f",
			" 7777997777f77777779997 997777997 997f  799f",
			"     997          f7777799    799f99997 799f",
			"     997    997f9997fff799    799f997ff7999f",
			"     997    997 f7999fff999777997f997  f799f",
			"     997    997   f9997 f7999977f 997    f7f",
			"     fff    fff    ffff  fffffff  fff     ff",
		}
	},
	win = {
		{
			"",
			"",
			"",
			"",
			"",
			"",
		},
		{
			"55      55 555555 5      5 55",
			"55      5555 55 5 55 5   5 55",
			"55   5  55   55   5555   5 55",
			"55  55  55   55   55 5   5 55",
			"5 55 5  55 5 55   55   555  5",
			"555    555 555555 55     5 55",
		},
		{
			"5       5 5555555 55    55 5 ",
			"5       5    5    555   55 5 ",
			"5   5   5    5    5  55 55 5 ",
			"5 55 55 5    5    5   5555 5 ",
			"555   555 5  5  5 5     55 5 ",
			"5       5 5555555 5     55 5 ",
		}
	},
	lose = {
		{
			"",
			"",
			"",
			"",
			"",
			"",
		},
		{
			"ee        eee e  eeeee  eeeeeee",
			"ee      eee e e ee   ee ee   ee",
			"ee      ee    e ee      e    e ",
			"ee      ee    e eeeee e eeeeee ",
			"ee      e e   e  e    e ee     ",
			"eeeeeee e eeeee  eeeeee eeeeeee",
		},
		{
			"e       eeeeee  eeeeeee eeeeeee",
			"e       e    ee e       e      ",
			"e       e    ee eeeeeee eeeee  ",
			"e       e    ee      ee e      ",
			"e       ee  eee e    ee e    ee",
			"eeeeeee  eeee   eeeeee  eeeeeee",
		}
	},
	tie = {
		{
			"",
			"",
			"",
			"",
			"",
			"",
		},
		{
			"77888800 0000000 0888877",
			"   88   00  0  0 08    7",
			"   88       0    0    7 ",
			"   88       0    088887 ",
			"   88    0  0    08     ",
			"   88    0000000 0888877",
		},
		{
			"7788880 00000000 0888877",
			"   8       00    0      ",
			"   8       00    08888  ",
			"   8       00    0      ",
			"   8    0  00  0 0     7",
			"   8    00000000 0888877",
		},
	},
	timeout = {
		{
			"",
			"",
			" ",
			" ",
			" ",
			"   ",
			"   ",
			"    ",
			"    ",
			"   ",
		},
		{
			"00000000000000ff0000000f",
			"0fff000fff000ff0ff00f000",
			"0ffffffffff00f000f00ffff",
			" fffff0ffff00f0f0f00ffff",
			" 000ff000000000f00000000",
			"   000000f0ff0ff0000f",
			"   0f00f0ffffff000f00",
			"   0ff0f0ffffff7f0f0",
			"   0ffff0ffffff7f0f0",
			"   000000000000ff000",
		},
		{
			"ffffffffffffff00fffffff0",
			" 0f0fff0f0ffffffffffffff",
			" 0f0ff00f00ffffffffff000",
			" 0f0fffffffffffffffffff0",
			" fffffffffffffffffffffff",
			"   ffffff0f00f00ffff0",
			"   ffffff0f00f0ffffff",
			"   ff0fff0f00f0fffff",
			"   ffffff0ffff0fffff",
			"   fffffffffffffffff",
		},
	}
}
for k,v in pairs(images) do
	v.x = #v[1][1]
	v.y = #v[1]
end

local drawImage = function(im, x, y)
	local cx, cy = termgetCursorPos()
	termsetBackgroundColor(	tocolors[initGrid.voidcol] )
	termsetTextColor(		tocolors[initGrid.voidcol] )
	for iy = 1, #im[1] do
		for ix = 1, #im[1][iy] do
			termsetCursorPos(x+(ix-1),y+(iy-1))
			if not (im[2][iy]:sub(ix,ix) == " " and im[3][iy]:sub(ix,ix) == " ") then
				termblit(
					im[1][iy]:sub(ix,ix),
					im[2][iy]:sub(ix,ix),
					im[3][iy]:sub(ix,ix)
				)
			end
		end
	end
	termsetCursorPos(cx,cy)
end

local deadGuys = {}
local trail = {}
local lastTrails = {}
isPuttingDown = false

local putTrailXY = function(x, y, p)
	trail[y] = trail[y] or {}
	trail[y][x] = {
		player = p,
		age = 0
	}
end

local putTrail = function(p)
	putTrailXY(p.x, p.y, p.num)
end

local getTrail = function(x, y)
	if trail[y] then
		if trail[y][x] then
			return player[trail[y][x].player].char, player[trail[y][x].player].color, trail[y][x].age
		end
	end
	return false
end

local ageTrails = function()
	for y,l in pairs(trail) do
		for x,v in pairs(l) do
			trail[y][x].age = trail[y][x].age + 1
		end
	end
end

local control, revControl = {
	up = keys.up,
	down = keys.down,
	left = keys.left,
	right = keys.right,
	lookUp = keys.w,
	lookDown = keys.s,
	lookLeft = keys.a,
	lookRight = keys.d,
	release = keys.space
}, {}
for k,v in pairs(control) do
	revControl[v] = k
end

local gridFore, gridBack
if squareGrid then
	gridFore = {
		"+-------",
		"|       ",
		"|       ",
		"|       ",
		"|       "
	}
	gridBack = {
		"+------------",
		"|            ",
		"|            ",
		"|            ",
		"|            ",
		"|            ",
		"|            ",
		"|            "
	}
else
	gridFore = {
		"    /      ",
		"   /       ",
		"  /        ",
		" /         ",
		"/__________"
	}
	gridBack = {
		"       /        ",
		"      /         ",
		"     /          ",
		"    /           ",
		"   /            ",
		"  /             ",
		" /              ",
		"/_______________"
	}
end

local dirArrow = {
	[-1] = "^",
	[0] = ">",
	[1] = "V",
	[2] = "<"
}

local doesIntersectBorder = function(x, y)
	return x == grid.x1 or x == grid.x2 or y == grid.y1 or y == grid.y2
end

--draws grid and background at scroll 'x' and 'y', along with trails and players
local drawGrid = function(x, y, onlyDrawGrid, useSetVisible)
	if useSetVisible then
		tsv(false)
	end
	x, y = mathfloor(x + 0.5), mathfloor(y + 0.5)
	local bg = {{},{},{}}
	local foreX, foreY
	local backX, backY
	local adjX, adjY
	local trailChar, trailColor, trailAge, isPlayer
	for sy = 1, scr_y do
		bg[1][sy] = ""
		bg[2][sy] = ""
		bg[3][sy] = ""
		for sx = 1, scr_x do
			adjX = (sx + x)
			adjY = (sy + y)
			foreX = 1 + (sx + x) % #gridFore[1]
			foreY = 1 + (sy + y) % #gridFore
			backX = 1 + mathfloor(sx + (x / 2)) % #gridBack[1]
			backY = 1 + mathfloor(sy + (y / 2)) % #gridBack
			trailChar, trailColor, trailAge = getTrail(adjX, adjY)
			isPlayer = false
			if not onlyDrawGrid then
				for i = 1, #player do
					if player[i].x == adjX and player[i].y == adjY then
						isPlayer = i
						break
					end
				end
			end
			if isPlayer and (not onlyDrawGrid) and (not doesIntersectBorder(adjX, adjY)) then
				bg[1][sy] = bg[1][sy] .. dirArrow[player[isPlayer].direction]
				bg[2][sy] = bg[2][sy] .. toblit[player[isPlayer].color[1]]
				bg[3][sy] = bg[3][sy] .. grid.voidcol
			else
				if (not onlyDrawGrid) and trailChar and trailColor then
					trailColor = trailColor[1 + ((trailAge - 1) % #trailColor)]
					bg[1][sy] = bg[1][sy] .. trailChar
					bg[2][sy] = bg[2][sy] .. toblit[trailColor]
					bg[3][sy] = bg[3][sy] .. grid.voidcol
				else
					if (not onlyDrawGrid) and (adjX < grid.x1 or adjX > grid.x2 or adjY < grid.y1 or adjY > grid.y2) then
						bg[1][sy] = bg[1][sy] .. " "
						bg[2][sy] = bg[2][sy] .. grid.voidcol
						bg[3][sy] = bg[3][sy] .. grid.voidcol
					elseif (not onlyDrawGrid) and doesIntersectBorder(adjX, adjY) then
						bg[1][sy] = bg[1][sy] .. grid.border
						bg[2][sy] = bg[2][sy] .. grid.voidcol
						bg[3][sy] = bg[3][sy] .. grid.edgecol
					else
						if gridFore[foreY]:sub(foreX,foreX) ~= " " then
							bg[1][sy] = bg[1][sy] .. gridFore[foreY]:sub(foreX,foreX)
							bg[2][sy] = bg[2][sy] .. grid.forecol
							bg[3][sy] = bg[3][sy] .. grid.voidcol
						elseif gridBack[backY]:sub(backX,backX) ~= " " then
							bg[1][sy] = bg[1][sy] .. gridBack[backY]:sub(backX,backX)
							bg[2][sy] = bg[2][sy] .. grid.backcol
							bg[3][sy] = bg[3][sy] .. grid.voidcol
						else
							bg[1][sy] = bg[1][sy] .. " "
							bg[2][sy] = bg[2][sy] .. grid.voidcol
							bg[3][sy] = bg[3][sy] .. grid.voidcol
						end
					end
				end
			end
		end
	end
	for sy = 1, scr_y do
		termsetCursorPos(1,sy)
		termblit(
			bg[1][sy],
			bg[2][sy],
			bg[3][sy]
		)
	end
	if doDrawPlayerNames and (not onlyDrawGrid) then
		for i = 1, #player do
			termsetTextColor(player[i].color[1])
			adjX = player[i].x - (scrollX + scrollAdjX) - mathfloor(#player[i].name / 2)
			adjY = player[i].y - (scrollY + scrollAdjY) - 2
			for cx = adjX, adjX + #player[i].name do
				if doesIntersectBorder(adjX + (scrollX + scrollAdjX), adjY + (scrollY + scrollAdjY)) then
					termsetBackgroundColor(tocolors[grid.edgecol])
				else
					termsetBackgroundColor(tocolors[grid.voidcol])
				end
				termsetCursorPos(cx, adjY)
				termwrite(player[i].name:sub(cx-adjX+1, cx-adjX+1))
			end
		end
	end
	if useSetVisible then
		tsv(true)
	end
end

local render = function(useSetVisible, netTime)
	local p = player[you]
	drawGrid(scrollX + scrollAdjX, scrollY + scrollAdjY, false, useSetVisible)
	termsetCursorPos(1,1)
	termsetTextColor(player[you].color[1])
	termsetBackgroundColor(tocolors[grid.voidcol])
	term.write("P" .. you)
	term.setTextColor(colors.white)
	if skynet and netTime then
		term.write(" " .. tostring(os.epoch() - netTime) .. "ms")
	end
	if debugShowKeys then
		term.setCursorPos(1,2)
		term.write("dir = " .. player[you].direction .. " ")
		local y = 3
		for k,v in pairs(keysDown) do
			if v then
				term.setCursorPos(1,y)
				term.write(k.." = "..tostring(v).." ")
				y = y + 1
			end
		end
	end
end

local pleaseWait = function()
	local periods = 1
	local maxPeriods = 5
	termsetBackgroundColor(colors.black)
	termsetTextColor(colors.gray)
	termclear()

	local tID = os.startTimer(0.2)
	local evt
	local txt = "Waiting for game"

	while true do
		termsetCursorPos(mathfloor(scr_x / 2 - (#txt + maxPeriods) / 2), scr_y - 2)
		termwrite(txt .. ("."):rep(periods))
		evt = {os.pullEvent()}
		if evt[1] == "timer" and evt[2] == tID then
			tID = os.startTimer(0.5)
			periods = (periods % maxPeriods) + 1
			term.clearLine()
		elseif evt[1] == "key" and evt[2] == keys.q then
            return
        end
	end
end

local startCountdown = function()
	local cName = "PLAYER " .. you
	local col = colors.white
	for k,v in pairs(colors) do
		if player[you].color[1] == v then
			cName = k:upper()
			col = v
			break
		end
	end
	local cMessage = "You are "
	scrollX = player[you].x - mathfloor(scr_x / 2)
	scrollY = player[you].y - mathfloor(scr_y / 2)
	for i = 3, 1, -1 do
		render(true)
		termsetTextColor(colors.white)
		for x = 1, #cMessage+1 do
			termsetCursorPos(-1 + x + mathfloor(scr_x / 2 - (#cMessage + #cName) / 2), mathfloor(scr_y / 2) + 2)
			if cMessage:sub(x,x) ~= " " and x <= #cMessage then
				termwrite(cMessage:sub(x,x))
			end
		end
		termsetTextColor(col)
		termwrite(cName)
		termsetTextColor(colors.white)
		termsetCursorPos(mathfloor(scr_x / 2 - 2), mathfloor(scr_y / 2) + 4)
		termwrite(i .. "...")
		sleep(1)
	end
end

local makeMenu = function(x, y, options, doAnimate)
	local cpos = 1
	local cursor = "> "
	local gsX, gsY = 0, 0
	local step = 0
	local lastPos = cpos
	if not doAnimate then
		drawImage(images.logo, mathceil(scr_x / 2 - images.logo.x / 2), 2)
	end
	local rend = function()
		if doAnimate then
			drawImage(images.logo, mathceil(scr_x / 2 - images.logo.x / 2), 2)
		end
		for i = 1, #options do
			if i == cpos then
				termsetCursorPos(x, y + (i - 1))
				termsetTextColor(colors.white)
				termwrite(cursor .. options[i])
			else
				if i == lastPos then
					termsetCursorPos(x, y + (i - 1))
					termwrite((" "):rep(#cursor))
					lastPos = nil
				else
					termsetCursorPos(x + #cursor, y + (i - 1))
				end
				termsetTextColor(colors.gray)
				termwrite(options[i])
			end
		end
	end
	local gstID, evt = mathrandom(1,65535)
	if doAnimate then
		os.queueEvent("timer", gstID)
	end
	while true do
		rend()
		tsv(true)
		evt = {os.pullEvent()}
		tsv(false)
		if evt[1] == "key" then
			if evt[2] == keys.up then
				lastPos = cpos
				cpos = (cpos - 2) % #options + 1
			elseif evt[2] == keys.down then
				lastPos = cpos
				cpos = (cpos % #options) + 1
			elseif evt[2] == keys.home then
				lastPos = cpos
				cpos = 1
			elseif evt[2] == keys["end"] then
				lastPos = cpos
				cpos = #options
			elseif evt[2] == keys.enter then
				tsv(true)
				return cpos
			end
		elseif evt[1] == "mouse_click" then
			if evt[4] >= y and evt[4] < y+#options then
				if cpos == evt[4] - (y - 1) then
					tsv(true)
					return cpos
				else
					cpos = evt[4] - (y - 1)
				end
			end
		elseif evt[1] == "timer" and evt[2] == gstID then
			gstID = os.startTimer(gameDelayInit)
			drawGrid(gsX, gsY, true)
			step = step + 1
			if mathceil(step / 100) % 2 == 1 then
				gsX = gsX + 1
			else
				gsY = gsY - 1
			end
		end
	end
end

local titleScreen = function()
	termclear()
	local menuOptions
	if kioskMode then
		menuOptions = {
			"Start Game",
			"How to Play",
		}
	else
		menuOptions = {
			"Start Game",
			"How to Play",
			"Grid Demo",
			"Exit"
		}
	end
	local choice = makeMenu(2, scr_y - 4, menuOptions, true)
	if choice == 1 then
		return "start"
	elseif choice == 2 then
		return "help"
	elseif choice == 3 then
		return "demo"
	elseif choice == 4 then
		return "exit"
	end
end

local cleanExit = function()
	termsetBackgroundColor(colors.black)
	termsetTextColor(colors.white)
	termclear()
	termsetCursorPos(1,1)
	print("Thanks for playing!")
end

local parseMouseInput = function(button, x, y, direction)
	local output = false
	local cx = x - scr_mx
	local cy = y - scr_my
	
	if useLegacyMouseControl then -- outdated mouse input
		cx = cx * (scr_y / scr_x)
		if cx > cy then
			if -cx > cy then
				output = "up"
			else
				output = "right"
			end
		else
			if -cx < cy then
				output = "down"
			else
				output = "left"
			end
		end
	else
		cx = cx + scrollAdjX
		cy = cy + scrollAdjY
		if button == 1 then -- move player
			if direction % 2 == 0 then -- moving horizontally
				if cy > 0 then
					output = "down"
				elseif cy < 0 then
					output = "up"
				end
			else -- moving vertically
				if cx > 0 then
					output = "right"
				elseif cx < 0 then
					output = "left"
				end
			end
		elseif button == 2 then -- release trail
			output = "release"
		end
	end
	
	return control[output]
end

local getInput = function()
	local evt
	local mkey = -1
	while true do
		evt = {os.pullEvent()}
		if lockInput then
			keysDown = {}
		else
			if evt[1] == "key" then
				if (not keysDown[evt[2]]) and (
					evt[2] == control.up or
					evt[2] == control.down or
					evt[2] == control.left or
					evt[2] == control.right
				) then
					lastDirectionPressed = revControl[evt[2]]
				end
				keysDown[evt[2]] = true
			elseif evt[1] == "key_up" then
				keysDown[evt[2]] = false
			elseif evt[1] == "mouse_click" or (useLegacyMouseControl and evt[1] == "mouse_drag") then
				if evt[1] == "mouse_drag" then
					keysDown[mkey] = false
				end
				mkey = parseMouseInput(evt[2], evt[3], evt[4], player[you].direction) or -1
				lastDirectionPressed = revControl[mkey]
				keysDown[mkey] = true
			elseif evt[1] == "mouse_up" then
				keysDown[mkey] = false
				mkey = parseMouseInput(evt[2], evt[3], evt[4], player[you].direction) or -1
				keysDown[mkey] = false
			end		
		end
	end
end

local scrollToPosition = function(x, y)
	for i = 1, 16 do
		scrollX = (scrollX + x - (scr_x/2)) / 2
		scrollY = (scrollY + y - (scr_y/2)) / 2
		render(true)
		sleep(0.05)
	end
end

local gridDemo = function()
	keysDown = {}
	while true do
		if keysDown[keys.left] then
			scrollX = scrollX - 1
		end
		if keysDown[keys.right] then
			scrollX = scrollX + 1
		end
		if keysDown[keys.up] then
			scrollY = scrollY - 1
		end
		if keysDown[keys.down] then
			scrollY = scrollY + 1
		end
		if keysDown[keys.q] then
			return "end"
		end
		drawGrid(scrollX, scrollY, false, true)
		ageTrails()
		sleep(gameDelay)
	end
end

local sendInfo = function(gameID)
	transmit(port, {
		player = isHost and player or nil,
		name = player[you].name,
		putTrail = isPuttingDown,
		gameID = gameID,
		time = os.epoch(),
		keysDown = isHost and nil or keysDown,
		trail = isHost and lastTrails or nil,
		deadGuys = isHost and deadGuys or nil,
		lastDir = lastDirectionPressed
	})
end

local waitForKey = function(time, blockMouse)
	sleep(time or 0.5)
	local evt
	repeat
		evt = os.pullEvent()
	until evt == "key" or ((not blockMouse) and evt == "mouse_click")
end

local imageAnim = function(image)
	while true do
		drawImage(image, mathceil(scr_x / 2 - image.x / 2), mathfloor(scr_y / 2 - image.y / 2))
		sleep(0.5)
		render(true)
		sleep(0.5)
	end
end

local deadAnimation = function(doSend)
	for k,v in pairs(deadGuys) do
		player[k].char = "X"
		lockInput = true
	end
	if doSend then
		sendInfo(gamename)
	end
	if deadGuys[you] or deadGuys[nou] then
		termsetTextColor(colors.white)
		if deadGuys[you] and deadGuys[nou] then
			os.queueEvent("tron_complete", "tie", isHost, player[nou].name)
			scrollToPosition(player[nou].x, player[nou].y)
			scrollToPosition(player[you].x, player[you].y)
			parallel.waitForAny(function() imageAnim(images.tie) end, waitForKey)
			return "end"
		else
			if deadGuys[you] then
				scrollX, scrollY = player[nou].x - scr_x / 2, player[nou].y - scr_y / 2
				os.queueEvent("tron_complete", "lose", isHost, player[nou].name)
				scrollToPosition(player[you].x, player[you].y)
				parallel.waitForAny(function() imageAnim(images.lose) end, waitForKey)
				return "end"
			elseif deadGuys[nou] then
				os.queueEvent("tron_complete", "win", isHost, player[nou].name)
				scrollToPosition(player[nou].x, player[nou].y)
				parallel.waitForAny(function() imageAnim(images.win) end, waitForKey)
				return "end"
			end
		end
	end
end

local moveTick = function(doSend)
	local p
	for i = 1, #player do
		p = player[i]
		if not p.dead then
			if isHost then
				p.x = p.x + mathfloor(mathcos(mathrad(p.direction * 90)))
				p.y = p.y + mathfloor(mathsin(mathrad(p.direction * 90)))
				if doesIntersectBorder(p.x, p.y) or getTrail(p.x, p.y) then
					p.dead = true
					deadGuys[i] = true
				elseif p.putTrail then
					putTrail(p)
					lastTrails[#lastTrails+1] = {p.x, p.y, p.num}
					if #lastTrails > #player then
						tableremove(lastTrails, 1)
					end
				end
			end
			for a = 1, #player do
				if (a ~= i) and (player[a].x == p.x and player[a].y == p.y) then
					p.dead = true
					deadGuys[i] = true
					if (p.direction + 2) % 4 == player[a].direction % 4 then
						player[a].dead = true
						deadGuys[a] = true
					end
					break
				end
			end
		end
	end
	return deadAnimation(doSend)
end

local setDirection = function(p, checkDir, lastDir)
	if (lastDir == control.left) and (checkDir or p.direction) ~= 0 then
		p.direction = 2
	elseif (lastDir == control.right) and (checkDir or p.direction) ~= 2 then
		p.direction = 0
	elseif (lastDir == control.up) and (checkDir or p.direction) ~= 1 then
		p.direction = -1
	elseif (lastDir == control.down) and (checkDir or p.direction) ~= -1 then
		p.direction = 1
	end
end

local game = function()
	local outcome
	local p, np, timeoutID, tID, evt, netTime
	while true do
		netTime = nil
		if isHost then
			sleep(gameDelay)
		else
			timeoutID = os.startTimer(3)
			repeat
				evt, tID = os.pullEvent()
			until evt == "move_tick" or (evt == "timer" and tID == timeoutID)
			if evt == "timer" then
				os.queueEvent("tron_complete", "timeout", isHost, player[nou].name)
				parallel.waitForAny(function() imageAnim(images.timeout) end, waitForKey)
				return
			elseif evt == "move_tick" then
				netTime = tID
			end
		end
		p = player[you]
		np = player[nou]

		if isHost then
			setDirection(p, nil, control[lastDirectionPressed])
			setDirection(np, nil, control[netLastDirectionPressed])
			p.putTrail = not keysDown[control.release]
		else
			setDirection(p, nil, control[lastDirectionPressed])
			isPuttingDown = not keysDown[control.release]
		end

		if keysDown[control.lookLeft] then
			scrollAdjX = scrollAdjX - 2
		end
		if keysDown[control.lookRight] then
			scrollAdjX = scrollAdjX + 2
		end
		if keysDown[control.lookUp] then
			scrollAdjY = scrollAdjY - 1.25
		end
		if keysDown[control.lookDown] then
			scrollAdjY = scrollAdjY + 1.25
		end

		scrollAdjX = scrollAdjX * 0.8
		scrollAdjY = scrollAdjY * 0.8

		if isHost then
			outcome = moveTick(true)
		else
			outcome = deadAnimation(true)
		end
		ageTrails()
		if outcome == "end" then
			return
		else
			scrollX = p.x - mathfloor(scr_x / 2)
			scrollY = p.y - mathfloor(scr_y / 2)
			render(true, (not isHost) and netTime)
		end
	end
end

local networking = function()
	local evt, side, channel, repchannel, msg, distance
	while true do
		if useSkynet then
			evt, channel, msg = os.pullEvent("skynet_message")
		else
			evt, side, channel, repchannel, msg, distance = os.pullEvent("modem_message")
		end
		if channel == port and type(msg) == "table" then
			if type(msg.gameID) == "string" then
				if waitingForGame and (type(msg.new) == "number") then
					if msg.new < os.time() then
						isHost = false
						gamename = msg.gameID
						gameDelay = tonumber(msg.gameDelay) or gameDelayInit
						grid = msg.grid or copyTable(initGrid)
						player = msg.player or player
					else
						isHost = true
						you, nou = nou, you
					end
					you, nou = nou, you
					player[nou].name = msg.name or player[nou].name
					transmit(port, {
						player = player,
						gameID = gamename,
						new = isHost and (-math.huge) or (math.huge),
						grid = initGrid
					})
					waitingForGame = false
					netKeysDown = {}
					os.queueEvent("new_game", gameID)
					return gameID
				elseif msg.gameID == gamename then
					if not isHost then
						if type(msg.player) == "table" then
							player[nou].name = msg.name or player[nou].name
							player = msg.player
							if msg.trail then
								for i = 1, #msg.trail do
									putTrailXY(unpack(msg.trail[i]))
								end
							end
							deadGuys = msg.deadGuys
							os.queueEvent("move_tick", msg.time)
						end
					elseif type(msg.keysDown) == "table" then
						netKeysDown = msg.keysDown
						netLastDirectionPressed = msg.lastDir
						player[nou].putTrail = msg.putTrail
						player[nou].name = msg.name or player[nou].name
					end
				end
			end
		end
	end
end

local helpScreen = function()
	termsetBackgroundColor(colors.black)
	termsetTextColor(colors.white)
	termclear()
	termsetCursorPos(1,2)
	print([[
		Move with arrow keys.
		Pan the camera with WASD.
		Hold SPACE to create gaps.

		That's basically it.
		Press any key to go back.
	]])
	waitForKey(0.25)
end

local startGame = function()
	-- reset all info between games
	trail = {}
	deadGuys = {}
	lastDirectionPressed = nil
	netLastDirectionPressed = nil
	gameDelay = gameDelayInit
	grid = copyTable(initGrid)
	player = resetPlayers()
	you, nou = 1, 2
	gamename = ""
	for i = 1, 32 do
		gamename = gamename .. string.char(mathrandom(1,126))
	end

	waitingForGame = true
	transmit(port, {
		player = player,
		gameID = gamename,
		new = os.time(),
		gameDelay = gameDelayInit,
		name = argumentName or player[you].name,
		grid = initGrid
	})
	rVal = parallel.waitForAny( pleaseWait, networking )
	sleep(0.1)
	if rVal == 2 then
		startCountdown()
		parallel.waitForAny( getInput, game, networking )
	end
end

local decision

local main = function()
	local rVal
	while true do
		decision = titleScreen()
		lockInput = false
		if decision == "start" then
			startGame()
		elseif decision == "help" then
			helpScreen()
		elseif decision == "demo" then
			parallel.waitForAny( getInput, gridDemo )
		elseif decision == "exit" then
			return cleanExit()
		end
	end
end

if useOnce then
	if useSkynet then
		parallel.waitForAny(startGame, skynet.listen)
		skynet.socket.close()
	else
		startGame()
	end
else
	if useSkynet then
		parallel.waitForAny(main, skynet.listen)
		skynet.socket.close()
	else
		main()
	end
end
