--[[
	TRON Light Cycle Game
	programmed by LDDestroier
	 Get with:
	wget https://raw.githubusercontent.com/LDDestroier/CC/master/tron.lua
--]]

local port = 701
local kioskMode = false			-- disables options menu
local useLegacyMouseControl = false	-- if true, click move regions will be divided into diagonal quadrants

local scr_x, scr_y = term.getSize()
local scr_mx, scr_my = scr_x / 2, scr_y / 2
local isColor = term.isColor()
local doShowByImage = true	-- show "By LDDestroier" in title

local gameDelayInit = 0.1	-- lower value = faster game. I recommend 0.1 for SMP play.
local doDrawPlayerNames = true	-- draws the names of players onscreen
local doRenderOwnName = false	-- if doDrawPlayerNames, also draws your own name
local useSetVisible = false	-- use term.current().setVisible, which speeds things up at the cost of multishell
local gridID = 1		-- determines which grid is used
local mode = "menu"

-- initial grid information, (hopefully) transferred to non-host players
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
			x = -3,
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
			trailLevel = 10,
			trailMax = 10,
			trailRegen = 0.1,
			putTrail = true,
			name = "BLU",
			initName = "BLU"
		},
		[2] = {
			num = 2,
			x = 3,
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
			trailLevel = 10,
			trailMax = 10,
			trailRegen = 0.1,
			putTrail = true,
			name = "RED",
			initName = "RED"
		}
	}
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
	["skynet"] = false,	-- use Skynet HTTP multiplayer
	["quick"] = false,	-- start one game immediately
	["griddemo"] = false,	-- only move the grid
	["--update"] = false,	-- updates TRON to the latest version
	["--gridID"] = "number"	-- grid ID to use
}

local gridFore, gridBack
local gridList = {
	[1] = {		-- broken up and cool looking
		{
			"+-    -+------",
			"|      |      ",
			"       |      ",
			".      |      ",
			"+------+-   --",
			"|      |      ",
			"|             ",
			"|      .      ",
		},
		{
			"+-      -+--------",
			"|        |        ",
			"         |        ",
			"         |        ",
			"         |        ",
			"|        |        ",
			"+--------+-      -",
			"|        |        ",
			"|                 ",
			"|                 ",
			"|                 ",
			"|        |        ",
		}
	},
	[2] = {		-- flat diagonal sorta
		{
			"    /      ",
			"   /       ",
			"  /        ",
			" /         ",
			"/__________"
		},
		{
			"       /        ",
			"      /         ",
			"     /          ",
			"    /           ",
			"   /            ",
			"  /             ",
			" /              ",
			"/_______________"
		}
	},
	[3] = {		-- basic simple grid
		{
			"+-------",
			"|       ",
			"|       ",
			"|       ",
			"|       "
		},
		{
			"+------------",
			"|            ",
			"|            ",
			"|            ",
			"|            ",
			"|            ",
			"|            ",
			"|            "
		}
	},
	[4] = {		-- diamond grid
		{
			"   /\\   ",
			"  /  \\  ",
			" /    \\ ",
			"/      \\",
			"\\      /",
			" \\    / ",
			"  \\  /  ",
			"   \\/   ",
		},
		{
			"     /\\     ",
			"    /  \\    ",
			"   /    \\   ",
			"  /      \\  ",
			" /        \\ ",
			"/          \\",
			"\\          /",
			" \\        / ",
			"  \\      /  ",
			"   \\    /   ",
			"    \\  /    ",
			"     \\/     ",
		}
	},
	[5] = {		-- brick and mortar
		{
			"|          ",
			"|          ",
			"|          ",
			"|          ",
			"===========",
			"     |     ",
			"     |     ",
			"     |     ",
			"     |     ",
			"===========",
		},
		{
			"|      ",
			"|      ",
			"=======",
			"   |   ",
			"   |   ",
			"=======",
		},
	},
	[6] = {		-- pain background
		{
			"@                                                   ",
			"@                                                   ",
			"@                                                   ",
			"@                                                   ",
			"@                                                   ",
			"@                                                   ",
			"@                                                   ",
			"@                                                   ",
			"@                                                   ",
			"@                                                   ",
			"@                                                   ",
			"@                                                   ",
			"@                                                   ",
			"@                                                   ",
			"@                                                   ",
			"@                                                   ",
			"@                                                   ",
			"@                                                   ",
			"@                                                   ",
			"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@SCREEN@MAX@",
		},
		{
			"%%..",
			"%%..",
			"%%..",
			"..%%",
			"..%%",
			"..%%"
		},
	},
	[7] = {		-- some
		{
			" "
		},
		{
			"+-----------------------------------------------------",
			"|   Somebody once told me the world is gonna roll me  ",
			"|   I ain't the sharpest tool in the shed / She was   ",
			"| looking kind of dumb with her finger and her thumb  ",
			"|  In the shape of an \"L\" on her forehead / Well the  ",
			"|    years start coming and they don't stop coming    ",
			"|    Fed to the rules and I hit the ground running    ",
			"| Didn't make sense not to live for fun / Your brain  ",
			"|   gets smart but your head gets dumb / So much to   ",
			"|  do, so much to see / So what's wrong with taking   ",
			"| the back streets? / You'll never know if you don't  ",
			"|   go / You'll never shine if you don't glow / Hey   ",
			"| now, you're an all-star, get your game on, go play  ",
			"|  Hey now, you're a rock star, get the show on, get  ",
			"|     paid / And all that glitters is gold / Only     ",
			"|  shooting stars break the mold / It's a cool place  ",
			"|   and they say it gets colder / You're bundled up   ",
			"|  now, wait till you get older / But the meteor men  ",
			"|      beg to differ / Judging by the hole in the     ",
			"|   satellite picture / The ice we skate is getting   ",
			"| pretty thin / The water's getting warm so you might ",
			"| as well swim / My world's on fire, how about yours? ",
			"|    That's the way I like it and I never get bored   ",
			"|  Hey now, you're an all-star, get your game on, go  ",
			"|  play / Hey now, you're a rock star, get the show   ",
			"|   on, get paid / All that glitters is gold / Only   ",
			"|   shooting stars break the mold / Hey now, you're   ",
			"|  an all-star, get your game on, go play / Hey now,  ",
			"|    you're a rock star, get the show, on get paid    ",
			"|    And all that glitters is gold / Only shooting    ",
			"|  stars... / Somebody once asked could I spare some  ",
			"|  change for gas? / I need to get myself away from   ",
			"|  this place / I said yep, what a concept / I could  ",
			"|  use a little fuel myself / And we could all use a  ",
			"|   little change / Well, the years start coming and  ",
			"|   they don't stop coming / Fed to the rules and I   ",
			"|  hit the ground running / Didn't make sense not to  ",
			"| live for fun / Your brain gets smart but your head  ",
			"|   gets dumb / So much to do, so much to see / So    ",
			"|     what's wrong with taking the back streets?      ",
			"|   You'll never know if you don't go (go!) / You'll  ",
			"|   never shine if you don't glow / Hey now, you're   ",
			"|  an all-star, get your game on, go play / Hey now,  ",
			"|    you're a rock star, get the show on, get paid    ",
			"|    And all that glitters is gold / Only shooting    ",
			"|   stars break the mold / And all that glitters is   ",
			"|      gold / Only shooting stars break the mold      ",
		}
	}
}

local argList = interpretArgs({...}, argData)

local useSkynet = argList["skynet"]
local useOnce = argList["quick"]
local doGridDemo = argList["griddemo"]
local doUpdateGame = argList["--update"]
if gridList[argList["--gridID"]] then
	gridID = argList["--gridID"]
end
local argumentName = argList[1]
local argumentPassword = argList[2] or ""

if useSkynet and (not http.websocket) then
	error("Skynet is not supported on this version of ComputerCraft.")
end

local skynetPath = fs.combine(fs.getDir(shell.getRunningProgram()), "skynet.lua")
local skynetURL = "https://raw.githubusercontent.com/osmarks/skynet/master/client.lua"

if argumentName then
	argumentName = argumentName:sub(1, 15) -- gotta enforce that limit
end

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

local round = function(num, places)
	return math.floor(num * 10^places + 0.5) / 10^places
end

if doUpdateGame then
	print("Downloading...")
	local net = http.get("https://github.com/LDDestroier/CC/raw/master/tron.lua")
	if net then
		local file = fs.open(shell.getRunningProgram(), "w")
		file.write(net.readAll())
		file.close()
		print("Updated!")
	else
		printError("Couldn't update!")
	end
	if useOnce then
		return
	else
		sleep(0.2)
		shell.run( shell.getRunningProgram(), table.concat({...}, " "):gsub("--update", "") )
		return
	end
end

local cwrite = function(text, y, xdiff, wordPosCheck)
	wordPosCheck = wordPosCheck or #text
	termsetCursorPos(mathfloor(scr_x / 2 - math.floor(0.5 + #text + (xdiff or 0)) / 2), y or (scr_y - 2))
	term.write(text)
	return (scr_x / 2) - (#text / 2) + wordPosCheck
end

local modem, skynet
local setUpModem = function()
	if not doGridDemo then
		if useSkynet then
			if fs.exists(skynetPath) then
				skynet = dofile(skynetPath)
				term.clear()
				cwrite("Connecting to Skynet...", scr_y / 2)
				skynet.open(port)
			else
				term.clear()
				cwrite("Downloading Skynet...", scr_y / 2)
				local prog = http.get(skynetURL)
				if prog then
					local file = fs.open(skynetPath, "w")
					file.write(prog.readAll())
					file.close()
					skynet = dofile(skynetPath)
					cwrite("Connecting to Skynet...", 1 + scr_y / 2)
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
	end
end
setUpModem()

local transmit = function(port, message)
	if useSkynet then
		skynet.send(port, message)
	else
		modem.transmit(port, port, message)
	end
end

local gamename = ""
local isHost

local waitingForGame = true

-- used in skynet matches if you are player 2
local ping = 0

local copyTable
copyTable = function(tbl, ...)
	local output = {}
	local arg = arg or {...}
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
local miceDown = {}

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

local images
if _HOST then -- need to add some NFP image replacements for older versions of CC
	images = {
		logo = {
			{
				" \149\131\131\131\131\131\131\131\131\131\149\151\131\131\131\131\131\131\131\139\139   \135\135\131\131\131\139\139  \159\139    \149\131\131\149",
				" \149\131\131\131\148\128\151\131\131\131\149\130\131\131\131\131\131\139\128\128\128\138 \151\128\159\131\131\131\144\128\148 \149\130\130\144  \149\128\128\149",
				"     \149\128\149          \130\130\131\131\129\149\128\128\151\128\128\128\148\128\128\149\149\128\128\139\139 \149\128\128\149",
				"     \149\128\149    \151\131\148\139\147\131\131\139\128\128\128\149\128\128\149\128\128\128\149\128\128\149\149\128\149\143\143\136\131\128\128\149",
				"     \149\128\149    \149\128\149 \130\139\128\128\139\144\128\138\144\128\139\143\143\143\135\128\159\133\149\128\149  \130\130\144\128\149",
				"     \149\128\149    \149\128\149   \139\144\128\130\139 \139\139\144\128\128\128\159\135\135 \149\128\149    \139\139\149",
				"     \143\143\143    \143\143\143    \138\143\143\143  \130\139\143\143\143\135\129  \143\143\143     \130\133",
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
				"\128\149\128\128\128\128\128\128\128\149\149\128\128\128\128\128\128\128\128\138\128\128\128\128\149\128\128\128\149",
				"\128\149\128\128\128\128\128\128\128\149\130\129\128\128\149\128\131\128\128\128\130\144\128\128\149\128\128\128\149",
				"\128\149\128\128\135\144\128\128\128\149\128\128\128\128\149\128\128\128\128\149\139\128\139\128\149\128\128\128\149",
				"\128\149\159\129\159\128\139\128\128\149\128\128\128\128\149\128\128\128\128\149\128\130\144\130\133\128\128\128\149",
				"\128\130\128\135\128\130\144\130\128\149\159\144\128\128\149\128\143\128\128\149\128\128\128\139\128\128\128\143\144",
				"\128\159\129\128\128\128\128\139\128\149\149\128\128\128\128\128\128\128\128\149\128\128\128\128\149\128\128\128\149",
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
				"\128\149\128\128\128\128\128\128\159\129\128\128\128\130\144\128\129\128\128\128\128\128\130\128\128\128\128\128\128\128\128",
				"\128\149\128\128\128\128\128\128\128\159\129\128\130\144\128\128\128\151\128\128\128\130\131\128\128\149\128\128\128\130\131",
				"\128\149\128\128\128\128\128\128\128\149\128\128\128\149\128\128\128\128\131\131\131\131\139\128\128\130\131\131\131\148\128",
				"\128\149\128\128\128\128\128\128\128\149\128\128\128\149\128\128\130\131\131\131\131\144\128\128\128\151\131\131\131\129\128",
				"\128\149\128\128\128\128\128\128\128\130\144\128\159\129\128\128\143\144\128\128\128\133\128\128\128\149\128\128\128\159\143",
				"\128\128\128\128\128\128\128\128\130\144\128\128\128\159\129\128\144\128\128\128\128\128\159\128\128\128\128\128\128\128\128",
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
				"\128\128\128\128\128\128\128\149\149\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128",
				"\128\128\128\128\149\128\128\128\130\129\128\149\128\128\128\131\128\128\149\128\128\128\128\131",
				"\128\128\128\128\149\128\128\128\128\128\128\149\128\128\128\128\128\128\130\131\131\131\148\128",
				"\128\128\128\128\149\128\128\128\128\128\128\149\128\128\128\128\128\128\151\131\131\131\129\128",
				"\128\128\128\128\149\128\128\128\159\144\128\149\128\128\128\143\128\128\149\128\128\128\128\143",
				"\128\128\128\128\149\128\128\128\149\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128",
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
				"\151\131\131\131\131\149\151\131\131\131\131\149\151\131\155\159\134\131\149\151\131\131\131\148",
				"\141\147\128\151\140\133\141\147\128\151\140\133\149\128\128\129\128\128\149\149\128\140\140\158",
				" \149\128\149\128\128\143\133\128\149\143\144\149\128\157\152\149\128\149\149\128\136\140\142",
				" \149\128\149\128\128\149\128\128\128\128\149\149\128\149\128\149\128\149\149\128\128\128\149",
				" \130\131\131\128\128\131\131\131\131\131\129\131\131\129\128\131\131\129\131\131\131\131\131",
				"   \151\131\131\131\131\149\149\131\148\149\131\148\149\131\131\131\131\148",
				"   \149\128\156\148\128\149\149\128\149\149\128\149\138\140\148\128\156\142",
				"   \149\128\138\149\128\149\149\128\149\133\128\149 \128\149\128\149",
				"   \149\128\128\128\128\149\149\128\128\128\128\149 \128\149\128\149",
				"   \131\131\131\131\131\129\130\131\131\131\131\131\128\128\131\131\129",
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
		},
		ldd = {
			{
				"                                               ",
				" \131\140\139\151\148\151\148 \143  \151\156\147\144\128\131\130\149\136\140\129\135\140\140\159\143\143\144\143\143\144\159\156\147\144\131\128\131\149\136\140\129\131\140\139",
				" \128\131\130 \148\151  \128  \149\149\149\149\128\143\159\149\138\143\144\141\131\130 \149\149 \128\140\136\149\149\149\149\143\128\143\149\138\143\144\128\131\130",
				" \131\131\129 \130\129  \143\140\140\130\131\131        \130\131\129 \138\133 \143 \143 \131\131        \131 \131",
			},
			{
				"                                               ",
				" f7ff7f7 f  fbfbbbffff9f99fff9ff9f9f9999fff9f9f",
				" 77f f7  b  fbfbbfbfff9f9f f9 99ff9f9f9ffff999f",
				" 777 77  bbbbbb        999 99 9 9 99        9 9",
			},
			{
				"                                               ",
				" 7f77f7f b  bfbfbfb999f9ff999f99f9f9ff9f999f9f9",
				" 7f7 7f  b  bfbfbbf999f9f9 9f 9f99f9f999999f9f9",
				" fff ff  ffffff        fff ff f f ff        f f",
			},
		}
	}
else
	images = {
		logo = {
			{
				"                                          ",
				"                                          ",
				"                                          ",
				"                                          ",
				"                                          ",
				"                                          ",
				"                                          ",
			},
			{
				"7777777777 77777777    77777777  77     77",
				"    77           777  777    777 777    77",
				"    77            777 77      77 7777   77",
				"    77     7777777    77      77 77777  77",
				"    77     77  7777   77      77 77   7777",
				"    77     77   7777  777    777 77    777",
				"    77     77    7777  77777777  77     77",
			},
			{
				"9999999999 99999999    99999999  99     99",
				"    99           999  999    999 999    99",
				"    99            999 99      99 9999   99",
				"    99     9999999    99      99 99999  99",
				"    99     99  9999   99      99 99   9999",
				"    99     99   9999  999    999 99    999",
				"    99     99    9999  99999999  99     99",
			},
		},
		win = {
			{
				"                            ",
				"                            ",
				"                            ",
				"                            ",
				"                            ",
				"                            ",
				"                            ",
			},
			{
				"77     77 777777 77    77 77",
				"77     77 777777 777   77 77",
				"77  7  77   77   7777  77 77",
				"77 777 77   77   77 77 77 77",
				"7777 7777   77   77  7777   ",
				"777   777 777777 77   777 77",
				"77     77 777777 77    77 77",
			},
			{
				"55     55 555555 55    55 55",
				"55     55 555555 555   55 55",
				"55  5  55   55   5555  55 55",
				"55 555 55   55   55 55 55 55",
				"5555 5555   55   55  5555   ",
				"555   555 555555 55   555 55",
				"55     55 555555 55    55 55",
			},
		},
		lose = {
			{
				"                           ",
				"                           ",
				"                           ",
				"                           ",
				"                           ",
				"                           ",
				"                           ",
				"                           ",
			},
			{
				"77     777777   77777 77777",
				"77    77777777 777777 77777",
				"77    777  777 77     77   ",
				"77    77    77 77777  7777 ",
				"77    77    77  77777 77   ",
				"77    777  777     77 77   ",
				"77777 77777777 777777 77777",
				"77777  777777  77777  77777",
			},
			{
				"ee     eeeeee   eeeee eeeee",
				"ee    eeeeeeee eeeeee eeeee",
				"ee    eee  eee ee     ee   ",
				"ee    ee    ee eeeee  eeee ",
				"ee    ee    ee  eeeee ee   ",
				"ee    eee  eee     ee ee   ",
				"eeeee eeeeeeee eeeeee eeeee",
				"eeeee  eeeeee  eeeee  eeeee",
			},
		},
		tie = {
			{
				"                         ",
				"                         ",
				"                         ",
				"                         ",
				"                         ",
				"                         ",
				"                         ",
			},
			{
				"77777777 77777777 7777777",
				"   77       77    77     ",
				"   77       77    77     ",
				"   77       77    777777 ",
				"   77       77    77     ",
				"   77       77    77     ",
				"   77    77777777 7777777",
			},
			{
				"77888800 00000000 0888877",
				"   88       00    08     ",
				"   88       00    08     ",
				"   88       00    088887 ",
				"   88       00    08     ",
				"   88       00    08     ",
				"   88    00000000 0888877",
			},
		},
		timeout = {
			{
				"                            ",
				"                            ",
				"                            ",
				"                            ",
				"                            ",
				"                            ",
				"                            ",
				"                            ",
				"                            ",
				"                            ",
				"                            ",
				"                            ",
				"                            ",
				"                            ",
				"                            ",
				"                            ",
			},
			{
				"7777777 777 777   777 777777",
				"7777777 777 7777 7777 777777",
				"7777777 777 777777777 777777",
				"  777   777 777777777 77777 ",
				"  777   777 777777777 777777",
				"  777   777 777777777 777777",
				"  777   777 777   777 777777",
				"                            ",
				"   7777777 777 777 7777777  ",
				"   7777777 777 777 7777777  ",
				"   7777777 777 777 7777777  ",
				"   777 777 777 777   777    ",
				"   777 777 777 777   777    ",
				"   7777777 7777777   777    ",
				"   7777777 7777777   777    ",
				"   7777777 7777777   777    ",
			},
			{
				"0000000 000 000   000 000000",
				"0fffff0 0f0 0ff0 0ff0 0ffff0",
				"000f000 0f0 0fff0fff0 0f0000",
				"  0f0   0f0 0f0fff0f0 0fff0 ",
				"  0f0   0f0 0f00f00f0 0f0000",
				"  0f0   0f0 0f00000f0 0ffff0",
				"  000   000 000   000 000000",
				"                            ",
				"   0000000 000 000 0000000  ",
				"   0fffff0 0f0 0f0 0fffff0  ",
				"   0f000f0 0f0 0f0 000f000  ",
				"   0f0 0f0 0f0 0f0   0f0    ",
				"   0f0 0f0 0f0 0f0   0f0    ",
				"   0f000f0 0f000f0   0f0    ",
				"   0fffff0 0fffff0   0f0    ",
				"   0000000 0000000   000    ",
			},
		},
		ldd = {
			{
				"                                          ",
				"                                          ",
				"                                          ",
				"                                          ",
				"                                          ",
				"                                          ",
				"                                          ",
				"                                          ",
				"                                          ",
				"                                          ",
				"                                          ",
			},
			{
				"               777 7 7                    ",
				"               7 7 7 7                    ",
				"               77   7                     ",
				"               7 7  7                     ",
				"    77  77     777  7      777 777        ",
				"7   7 7 7 7 77         777 7 7  7  777    ",
				"7   7 7 7 7 7  777 777 7 7 7 7  7  7   777",
				"7   7 7 7 7 77 7    7  77  7 7  7  77  7 7",
				"7   77  77  7  777  7  7 7 777 777 7   77 ",
				"777         77   7  7  7 7         777 7 7",
				"               777  7                  7 7",
			},
			{
				"               777 7 7                    ",
				"               7 7 7 7                    ",
				"               77   7                     ",
				"               7 7  7                     ",
				"    bb  bb     777  7      999 999        ",
				"b   b b b b 99         999 9 9  9  999    ",
				"b   b b b b 9  999 999 9 9 9 9  9  9   999",
				"b   b b b b 99 9    9  99  9 9  9  99  9 9",
				"b   bb  bb  9  999  9  9 9 999 999 9   99 ",
				"bbb         99   9  9  9 9         999 9 9",
				"               999  9                  9 9",
			},
		}
	}
end

for k,v in pairs(images) do
	-- give them easy-to-access x and y sizes
	v.x = #v[1][1]
	v.y = #v[1]
	-- fix white artifacting that occurs due to " " correlating to WHITE in term.blit
	for y = 1, v.y do
		for x = 1, v.x do
			if v[2][y]:sub(x,x) ~= "" and v[3][y]:sub(x,x) ~= "" then
				if (v[2][y]:sub(x,x) == " " and v[3][y]:sub(x,x) ~= " ") then
					images[k][2][y] = v[2][y]:sub(1, x - 1) .. initGrid.voidcol .. v[2][y]:sub(x + 1)
				elseif (v[2][y]:sub(x,x) ~= " " and v[3][y]:sub(x,x) == " ") then
					images[k][3][y] = v[3][y]:sub(1, x - 1) .. initGrid.voidcol .. v[3][y]:sub(x + 1)
				end
			end
		end
	end
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
					im[2][iy]:sub(ix,ix):gsub("[ f]",initGrid.voidcol),
					im[3][iy]:sub(ix,ix):gsub("[ f]",initGrid.voidcol)
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

gridFore, gridBack = table.unpack(gridList[gridID])

local dirArrow = {
	[-1] = "^",
	[0] = ">",
	[1] = "V",
	[2] = "<"
}

local doesIntersectBorder = function(x, y)
	return mathfloor(x) == grid.x1 or mathfloor(x) == grid.x2 or mathfloor(y) == grid.y1 or mathfloor(y) == grid.y2
end

--draws grid and background at scroll 'x' and 'y', along with trails and players
local drawGrid = function(x, y, onlyDrawGrid, useSetVisible)
	tsv(false)
	x, y = mathfloor(x + 0.5), mathfloor(y + 0.5)
	local bg = {{},{},{}}
	local foreX, foreY
	local backX, backY
	local adjX, adjY
	local trailChar, trailColor, trailAge, isPlayer, isPredict
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
			isPredict = false
			if not onlyDrawGrid then
				for i = 1, #player do
					if player[i].x == adjX and player[i].y == adjY then
						isPlayer = i
						break
					elseif (not isHost) and useSkynet and i == you and (
						adjX == math.floor(player[i].x + (0.02 * round(ping, 0)) * math.cos(math.rad(player[i].direction * 90))) and
						adjY == math.floor(player[i].y + (0.02 * round(ping, 0)) * math.sin(math.rad(player[i].direction * 90)))
					) then
						isPredict = i
						break
					end
				end
			end
			if isPlayer and (not onlyDrawGrid) and (not doesIntersectBorder(adjX, adjY)) then
				bg[1][sy] = bg[1][sy] .. dirArrow[player[isPlayer].direction]
				bg[2][sy] = bg[2][sy] .. toblit[player[isPlayer].color[1]]
				bg[3][sy] = bg[3][sy] .. grid.voidcol
			elseif isPredict and (not onlyDrawGrid) and (not doesIntersectBorder(adjX, adjY)) then
				bg[1][sy] = bg[1][sy] .. "o"
				bg[2][sy] = bg[2][sy] .. grid.forecol
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
			if doRenderOwnName or (i ~= you) then
				termsetTextColor(player[i].color[1])
				adjX = mathfloor(player[i].x - (scrollX + scrollAdjX) - (#player[i].name / 2) + 1)
				adjY = mathfloor(player[i].y - (scrollY + scrollAdjY) - 1.5)
				for cx = adjX, adjX + #player[i].name do
					if doesIntersectBorder(adjX + mathfloor(0.5 + scrollX + scrollAdjX), adjY + mathfloor(0.5 + scrollY + scrollAdjY)) then
						termsetBackgroundColor(tocolors[grid.edgecol])
					else
						termsetBackgroundColor(tocolors[grid.voidcol])
					end
					termsetCursorPos(cx, adjY)
					termwrite(player[i].name:sub(cx-adjX+1, cx-adjX+1))
				end
			end
		end
	end
	tsv(true)
end

local getTime = function()
	if os.epoch then
		return os.epoch("utc")
	else
		return 24 * os.day() + os.time()
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

	for x = 0, p.trailMax - 1 do
		if not (x - p.trailLevel >= -0.4) then
			if (x - p.trailLevel) > -0.7 then
				term.setTextColor(colors.gray)
				term.write("@")
			elseif (x - p.trailLevel) > -1 then
				term.setTextColor(colors.lightGray)
				term.write("@")
			else
				term.setTextColor(colors.white)
				term.write("@")
			end
		end
	end
	term.setCursorPos(1,2)
	if netTime and useSkynet then
		ping = (getTime() - netTime)
		term.setTextColor(colors.white)
		term.write(" " .. tostring(ping) .. " ms")
	end
	term.setTextColor(colors.white)
end

local pleaseWait = function()
	local periods = 1
	local maxPeriods = 5
	termsetBackgroundColor(colors.black)
	termsetTextColor(colors.gray)
	termclear()

	local tID = os.startTimer(0.2)
	local evt, txt
	if useSkynet then
		txt = "Waiting for Skynet game"
	else
		txt = "Waiting for modem game"
	end

	while true do
		cwrite("(Press 'Q' to cancel)", 2)
		cwrite(txt, scr_y - 2, maxPeriods)
		termwrite(("."):rep(periods))
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
		termwrite(player[you].name)
		termsetTextColor(colors.white)
		termsetCursorPos(mathfloor(scr_x / 2 - 2), mathfloor(scr_y / 2) + 4)
		termwrite(i .. "...")
		sleep(1)
	end
end

local makeMenu = function(x, fromX, y, options, doAnimate, scrollInfo, _cpos)
	local cpos = _cpos or 1
	local xmod = 0
	local cursor = "> "
	local gsX, gsY = (scrollInfo or {})[2] or 0, (scrollInfo or {})[3] or 0
	local step = (scrollInfo or {})[1] or 0
	local lastPos = cpos
	local image
	if not doAnimate then
		drawImage(images.logo, mathceil(scr_x / 2 - images.logo.x / 2), 2)
		if useSkynet then
			term.setTextColor(colors.lightGray)
			cwrite("Skynet Enabled", 2 + images.logo.y)
		end
	end
	local rend = function()
		if (step % 150 > 100) and doShowByImage then
			image = images.ldd
		else
			image = images.logo
		end
		if doAnimate then
			drawImage(
				image,
				mathceil(scr_x / 2 - image.x / 2),
				2
			)
			if useSkynet then
				term.setTextColor(colors.lightGray)
				cwrite("Skynet Enabled", 2 + image.y)
			end
		end
		for i = 1, #options do
			if i == cpos then
				termsetCursorPos(fromX + xmod, y + (i - 1))
				termsetTextColor(colors.white)
				termwrite(cursor .. options[i])
			else
				if i == lastPos then
					termsetCursorPos(fromX + xmod, y + (i - 1))
					termwrite((" "):rep(#cursor))
					lastPos = nil
				else
					termsetCursorPos(fromX + xmod + #cursor, y + (i - 1))
				end
				termsetTextColor(colors.gray)
				termwrite(options[i])
			end
		end
	end

	rend()
	local tID = os.startTimer(0.05)

	while true do
		evt = {os.pullEvent()}
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
				return cpos, {step, gsX, gsY}
			end
		elseif evt[1] == "mouse_click" then
			if evt[4] >= y and evt[4] < y+#options then
				if cpos == evt[4] - (y - 1) then
					return cpos, {step, gsX, gsY}
				else
					cpos = evt[4] - (y - 1)
					doRend = true
				end
			end
		elseif evt[1] == "timer" then
			if evt[2] == tID then
				tID = os.startTimer(0.05)
				drawGrid(gsX, gsY, true)
				step = step + 1
				if mathceil(step / 100) % 2 == 1 then
					gsX = gsX + 1
				else
					gsY = gsY - 1
				end

				if x > fromX and xmod < x - fromX then
					xmod = math.min(xmod + 1, x - fromX)
				elseif xmod > x - fromX then
					xmod = math.max(xmod - 1, x - fromX)
				end
				doRend = true
			end
		end
		if lastPos ~= cpos or doRend then
			rend()
			doRend = false
		end
	end
end

local specialRead = function(scrollInfo, specialNames, message, preInput)
	specialNames = specialNames or {}
	local gsX, gsY = (scrollInfo or {})[2] or 0, (scrollInfo or {})[3] or 0
	local step = (scrollInfo or {})[1] or 0
	local tID = os.startTimer(0.05)
	local buff = {}
	local cpos = 1
	local maxSize = 15
	local evt
	for x = 1, #preInput do
		buff[x] = preInput:sub(x, x)
		cpos = cpos + 1
	end
	term.setCursorBlink(true)
	local rend = function()
		drawGrid(gsX, gsY, true)
		term.setTextColor(colors.white)
		cwrite(message, scr_y - 5)
		termsetTextColor(specialNames[table.concat(buff):lower()] or colors.white)
		term.setCursorPos( cwrite(table.concat(buff), scr_y - 3, nil, cpos) - 1, scr_y - 3)
		term.setTextColor(colors.white)
	end
	while true do
		evt = {os.pullEvent()}
		if evt[1] == "timer" and evt[2] == tID then
			-- render the bg
			tID = os.startTimer(0.05)
			step = step + 1
			if mathceil(step / 100) % 2 == 1 then
				gsX = gsX + 1
			else
				gsY = gsY - 1
			end
			rend()
		elseif evt[1] == "char" then
			if #buff < maxSize then
				table.insert(buff, cpos, evt[2])
				cpos = cpos + 1
				rend()
			end
		elseif evt[1] == "key" then
			if evt[2] == keys.left then
				cpos = math.max(1, cpos - 1)
			elseif evt[2] == keys.right then
				cpos = math.min(#buff + 1, cpos + 1)
			elseif evt[2] == keys.home then
				cpos = 1
			elseif evt[2] == keys["end"] then
				cpos = #buff
			elseif evt[2] == keys.backspace then
				if cpos > 1 then
					table.remove(buff, cpos - 1)
					cpos = cpos - 1
					rend()
				end
			elseif evt[2] == keys.delete then
				if buff[cpos] then
					table.remove(buff, cpos)
					rend()
				end
			elseif evt[2] == keys.enter then
				term.setCursorBlink(false)
				return table.concat(buff), {step, gsX, gsY}
			end
		end
	end
end

local passwordChange = function(scrollInfo)
	return specialRead(scrollInfo, {}, "Enter a password.", argumentPassword or "") or ""
end

local nameChange = function(scrollInfo)
	-- this has no functional significance. just some shoutouts
	local specialNames = {
		["blu"] = colors.blue,
		["red"] = colors.red,
		["ldd"] = colors.orange,
		["lddestroier"] = colors.orange,
		["hydraz"] = colors.yellow,
		["hugeblank"] = colors.orange,
		["bagel"] = colors.orange,
		["3d6"] = colors.lime,
		["lyqyd"] = colors.red,
		["squiddev"] = colors.cyan,
		["oeed"] = colors.lime,
		["dog"] = colors.purple,
		["nothy"] = colors.lightGray,
		["kepler"] = colors.cyan,
		["kepler155c"] = colors.cyan,
		["anavrins"] = colors.blue,
		["redmatters"] = colors.red,
		["fatmanchummy"] = colors.purple,
		["crazed"] = colors.lightBlue,
		["ape"] = colors.brown,
		["everyos"] = colors.red,
		["lemmmy"] = colors.red,
		["yemmel"] = colors.red,
		["apemanzilla"] = colors.brown,
		["osmarks"] = colors.green,
		["gollark"] = colors.green,
		["dece"] = colors.cyan,
		["hpwebcamable"] = colors.lightGray,
		["theoriginalbit"] = colors.blue,
		["bombbloke"] = colors.red,
		["kingofgamesyami"] = colors.lightBlue,
		["pixeltoast"] = colors.lime,
		["creator"] = colors.yellow,
		["dannysmc"] = colors.purple,
		["dannysmc95"] = colors.purple,
		["kingdaro"] = colors.blue,
		["valithor"] = colors.orange,
		["logandark"] = colors.lightGray,
		["lupus590"] = colors.lightGray,
		["nitrogenfingers"] = colors.green,
		["gravityscore"] = colors.lime,
		["1lann"] = colors.gray,
		["konlab"] = colors.brown,
		["elvishjerricco"] = colors.pink
	}
	return specialRead(scrollInfo, specialNames, "Enter your name.", argumentName or player[you].initName)
end

local titleScreen = function()
	termclear()
	local menuOptions, options, choice, scrollInfo
	if kioskMode then
		menuOptions = {
			"Start Game",
			"How to Play",
		}
	else
		menuOptions = {
			"Start Game",
			"How to Play",
			"Options...",
			"Exit"
		}
	end
	local currentX = 2
	while true do
		choice, scrollInfo = makeMenu(2, currentX, scr_y - #menuOptions, menuOptions, true, scrollInfo)
		currentX = 2
		if choice == 1 then
			return "start"
		elseif choice == 2 then
			return "help"
		elseif choice == 3 then
			local _cpos
			while true do
				options = {
					"Grid Demo",
					"Change Name",
					"Change Grid",
					"Change Password",
					(useSkynet and "Disable" or "Enable") .. " Skynet",
					"Back..."
				}
				choice, scrollInfo = makeMenu(8, currentX, scr_y - #options, options, true, scrollInfo, _cpos)
				currentX = 8
				_cpos = choice
				if choice == 1 then
					return "demo"
				elseif choice == 2 then
					local newName = nameChange(scrollInfo)
					if #newName > 0 then
						if newName:upper() == "BLU" or newName:upper() == "RED" or newName:gsub(" ","") == "" then
							argumentName = nil
						else
							argumentName = newName
						end
					else
						argumentName = nil
					end
				elseif choice == 3 then
					gridID = (gridID % #gridList) + 1
					gridFore, gridBack = table.unpack(gridList[gridID])
				elseif choice == 4 then
					argumentPassword = passwordChange(scrollInfo)
				elseif choice == 5 then
					if http.websocket then
						useSkynet = not useSkynet
						setUpModem()
						if skynet and not useSkynet then
							skynet.socket.close()
						end
					else
						term.clear()
						term.setTextColor(colors.white)
						cwrite("Alas, this version of CC", 	-2 + scr_y / 2)
						cwrite("does not support Skynet.", 	-1 + scr_y / 2)
						term.setTextColor(colors.lightGray)
						cwrite("Use CC:Tweaked or CCEmuX", 	 1 + scr_y / 2)
						cwrite("instead for netplay.", 		 2 + scr_y / 2)
						cwrite("Press any key to go back.",  4 + scr_y / 2)
						sleep(0.1)
						os.pullEvent("key")
					end
				elseif choice == 6 then
					break
				end
			end
		elseif choice == 4 then
			return "exit"
		end
	end
end

local cleanExit = function()
	termsetBackgroundColor(colors.black)
	termsetTextColor(colors.white)
	termclear()
	cwrite("Thanks for playing!", 2)
	termsetCursorPos(1, scr_y)
end

local parseMouseInput = function(button, x, y, direction)
	local output = false
	local cx = x - scr_mx
	local cy = y - scr_my

	if useLegacyMouseControl or mode == "demo" then -- outdated mouse input, useful for grid demo though
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
			miceDown = {}
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
				miceDown[evt[2]] = {evt[3], evt[4]}
				mkey = parseMouseInput(evt[2], evt[3], evt[4], player[you].direction) or -1
				lastDirectionPressed = revControl[mkey]
				keysDown[mkey] = true
			elseif evt[1] == "mouse_drag" then
				miceDown[evt[2]] = {evt[3], evt[4]}
			elseif evt[1] == "mouse_up" then
				keysDown[mkey] = false
				miceDown[evt[2]] = nil
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
	miceDown = {}
	scrollX, scrollY = math.floor(scr_x * -0.5), math.floor(scr_y * -0.75)
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
		sleep(0.05)
	end
end

local sendInfo = function(gameID, doSendTime)
	transmit(port, {
		player = isHost and player or nil,
		name = player[you].name,
		putTrail = isPuttingDown,
		gameID = gameID,
		time = doSendTime and getTime(),
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
		sendInfo(gamename, isHost)
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

local debugMoveMode = false	-- only works if host
local moveTick = function(doSend)
	local p
	local hasMoved
	for i = 1, #player do
		p = player[i]
		hasMoved = false
		if not p.dead then
			if isHost then
				if debugMoveMode then
					if (i == 1 and keysDown[control.left]) or (i == 2 and netKeysDown[control.left]) then
						p.x = p.x - 1
						hasMoved = true
					end
					if (i == 1 and keysDown[control.right]) or (i == 2 and netKeysDown[control.right]) then
						p.x = p.x + 1
						hasMoved = true
					end
					if (i == 1 and keysDown[control.up]) or (i == 2 and netKeysDown[control.up]) then
						p.y = p.y - 1
						hasMoved = true
					end
					if (i == 1 and keysDown[control.down]) or (i == 2 and netKeysDown[control.down]) then
						p.y = p.y + 1
						hasMoved = true
					end
				else
					p.x = p.x + mathfloor(mathcos(mathrad(p.direction * 90)))
					p.y = p.y + mathfloor(mathsin(mathrad(p.direction * 90)))
					hasMoved = true
				end
				if hasMoved and (doesIntersectBorder(p.x, p.y) or getTrail(p.x, p.y)) then
					p.dead = true
					deadGuys[i] = true
				else
					if p.putTrail or (p.trailLevel < 1) then
						if hasMoved then
							putTrail(p)
							lastTrails[#lastTrails+1] = {p.x, p.y, p.num}
							if #lastTrails > #player then
								tableremove(lastTrails, 1)
							end
						end
						if p.putTrail then
							p.trailLevel = math.min(p.trailLevel + p.trailRegen, p.trailMax)
						else
							p.trailLevel = math.max(p.trailLevel - 1, 0)
						end
					else
						p.trailLevel = math.max(p.trailLevel - 1, 0)
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
		return true
	elseif (lastDir == control.right) and (checkDir or p.direction) ~= 2 then
		p.direction = 0
		return true
	elseif (lastDir == control.up) and (checkDir or p.direction) ~= 1 then
		p.direction = -1
		return true
	elseif (lastDir == control.down) and (checkDir or p.direction) ~= -1 then
		p.direction = 1
		return true
	elseif isPuttingDown == keysDown[control.release] then
		return true
	else
		return false
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
		p  = player[you]
		np = player[nou]

		if isHost then
			setDirection(p, nil, control[lastDirectionPressed])
			setDirection(np, nil, control[netLastDirectionPressed])
			p.putTrail = not keysDown[control.release]
		else
			setDirection(p, nil, control[lastDirectionPressed])
			isPuttingDown = not keysDown[control.release]
			sendInfo(gamename, isHost)
		end

		if miceDown[3] then
			scrollAdjX = scrollAdjX + (miceDown[3][1] - scr_x / 2) / (scr_x / 4)
			scrollAdjY = scrollAdjY + (miceDown[3][2] - scr_y / 2) / (scr_y / 2.795)
		else
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
		end

		scrollAdjX = scrollAdjX * 0.8
		scrollAdjY = scrollAdjY * 0.8

		if isHost then
			outcome = moveTick(true)
		else
			outcome = deadAnimation(false)
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

local cTime -- current UTC time when looking for game
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
				if waitingForGame and (type(msg.time) == "number") then
					if msg.password == argumentPassword or (argumentPassword == "" and not msg.password) then

						-- called while waiting for match
						if msg.time < cTime then
							isHost = false
							you, nou = nou, you
							gamename = msg.gameID
							gameDelay = tonumber(msg.gameDelay) or gameDelayInit
							grid = msg.grid or copyTable(initGrid)
							player = msg.player or player
							player[you].name = argumentName or player[you].initName
						else
							isHost = true
						end

						player[nou].name = msg.name or player[nou].initName

						transmit(port, {
							player = player,
							gameID = gamename,
							time = cTime,
							name = argumentName,
							password = argumentPassword,
							grid = initGrid
						})
						waitingForGame = false
						netKeysDown = {}
						os.queueEvent("new_game", gameID)
						return gameID
					end

				elseif msg.gameID == gamename then

					-- called during gameplay
					if not isHost then
						if type(msg.player) == "table" then
							player[nou].name = msg.name or player[nou].name
							player = msg.player
							if msg.trail then
								for i = 1, #msg.trail do
									putTrailXY(table.unpack(msg.trail[i]))
								end
							end
							deadGuys = msg.deadGuys
							os.queueEvent("move_tick", msg.time)
						end
					elseif type(msg.keysDown) == "table" then
						netKeysDown = msg.keysDown
						netLastDirectionPressed = msg.lastDir
						player[nou].putTrail = msg.putTrail
						player[nou].name = msg.name or "???" --player[nou].name
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
	Move your lightcycle with the
	 arrow keys or by tapping
	 left click.

	Pan the camera with WASD or
	 by holding middle click.

	Release the trail with spacebar
	 or by holding right click.

	If you're P2 (red), a gray circle
	will indicate where you'll turn,
	to help with Skynet's netlag.

	Press any key to go back.
	]])
	waitForKey(0.25)
end

local startGame = function()
	-- reset all info between games
	keysDown = {}
	miceDown = {}
	scrollAdjX = 0
	scrollAdjY = 0

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
	cTime = getTime()
	transmit(port, {
		player = player,
		gameID = gamename,
		gameDelay = gameDelayInit,
		time = cTime,
		password = argumentPassword,
		name = argumentName,
		grid = initGrid
	})
	rVal = parallel.waitForAny( pleaseWait, networking )
	sleep(0.1)
	player[you].name = argumentName or player[you].initName
	if rVal == 2 then
		startCountdown()
		parallel.waitForAny( getInput, game, networking )
	end
end

local decision

local main = function()
	return pcall(function()
		local rVal
		while true do
			mode = "menu"
			decision = titleScreen()
			lockInput = false
			if decision == "start" then
				mode = "game"
				if useSkynet then
					parallel.waitForAny(startGame, skynet.listen)
				else
					startGame()
				end
			elseif decision == "help" then
				mode = "help"
				helpScreen()
			elseif decision == "demo" then
				mode = "demo"
				parallel.waitForAny( getInput, gridDemo )
			elseif decision == "exit" then
				return cleanExit()
			end
		end
	end)
end

if doGridDemo then
	parallel.waitForAny(function()
		local step, gsX, gsY = 0, 0, 0
		while true do
			drawGrid(gsX, gsY, true)
			step = step + 1
			if mathceil(step / 100) % 2 == 1 then
				gsX = gsX + 1
			else
				gsY = gsY - 1
			end
			sleep(0.05)
		end
	end, function()
		sleep(0.1)
		local evt, key
		repeat
			evt, key = os.pullEvent("key")
		until key == keys.q
		sleep(0.1)
	end)
else
	if useOnce then
		term.setCursorBlink(false)
		if useSkynet then
			parallel.waitForAny(startGame, skynet.listen)
			skynet.socket.close()
		else
			startGame()
		end
		term.setCursorPos(1, scr_y)
	else
		main()
		if skynet then
			skynet.socket.close()
		end
	end
end
