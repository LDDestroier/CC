local scr_x, scr_y = term.getSize()
local keysDown, miceDown = {}, {}

-- recommended at 0.1 for netplay, which you'll be doing all the time so yeah
local gameDelayInit = 0.1

local useAbsoluteMainDir = false

local config = {
	mainDir = useAbsoluteMainDir and "ccbn-data" or fs.combine(fs.getDir(shell.getRunningProgram()), "ccbn-data")
}
config.chipDir = fs.combine(config.mainDir, "chipdata")
config.objectDir = fs.combine(config.mainDir, "objectdata")

local players = {}
local objects = {}
local projectiles = {}
local game = {
	custom = 0,
	customMax = 200,
	customSpeed = 1,
	inChipSelect = true,
	paused = false,
	turnNumber = 0
}

local you = 1
local yourID = os.getComputerID()

local revKeys = {}
for k,v in pairs(keys) do
	revKeys[v] = k
end

local gameID = math.random(0, 2^30)
local waitingForGame = false
local isHost = true
local channel = 1024

local chips, objectTypes = {}, {}

local interpretArgs = function(tInput, tArgs)
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

local argList = interpretArgs({...}, {
	["skynet"] = false,	-- use Skynet HTTP multiplayer
	["debug"] = false,	-- show various variable values
})

local FRAME = 0
local useSkynet = argList.skynet
local showDebug = argList.debug

local stage = {
	panels = {},
	damage = {},
	panelWidth = 6,
	panelHeight = 2,
	scrollX = 0,
	scrollY = 6
}

stage.scrollX = -1 + (scr_x - (6 * stage.panelWidth)) / 2

local stageChanged = true

local round = function(num)
	return math.floor(0.5 + num)
end

-- ripped from NFTE
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
local getSize = function(image)
	local x, y = 0, #image[1]
	for y = 1, #image[1] do
		x = math.max(x, #image[1][y])
	end
	return x, y
end
local colorSwap = function(image, text, back)
	local output = {{},{},{}}
	for y = 1, #image[1] do
		output[1][y] = image[1][y]
		output[2][y] = image[2][y]:gsub(".", text)
		output[3][y] = image[3][y]:gsub(".", back or text)
	end
	return output
end
local makeRectangle = function(width, height, char, text, back)
	local output = {{},{},{}}
	for y = 1, height do
		output[1][y] = (char or " "):rep(width)
		output[2][y] = (text or " "):rep(width)
		output[3][y] = (back or " "):rep(width)
	end
	return output
end
local stretchImage = function(_image, sx, sy, noRepeat)
	local output = {{},{},{}}
	local image = deepCopy(_image)
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
local merge = function(...)
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
local pixelateImage = function(image, amntX, amntY)
	local imageX, imageY = getSize(image)
	return stretchImage(stretchImage(image,imageX/math.max(amntX,1), imageY/math.max(amntY,1)), imageX, imageY)
end
local drawImage = function(image, x, y, terminal)
	terminal = terminal or term.current()
	local cx, cy = terminal.getCursorPos()
	for iy = 1, #image[1] do
		terminal.setCursorPos(x, y + (iy - 1))
		terminal.blit(image[1][iy], image[2][iy], image[3][iy])
	end
	terminal.setCursorPos(cx,cy)
end

local skynet
local skynetPath = "skynet"
local skynetURL = "https://raw.githubusercontent.com/osmarks/skynet/master/client.lua"

local modem
local getModem = function()
	if useSkynet then
		if skynet then
			local isOpen = false
			for i = 1, #skynet.open_channels do
				if skynet.open_channels == channel then
					isOpen = true
				end
			end
			if not isOpen then
				skynet.open(channel)
			end
			return skynet
		else
			if fs.exists(skynetPath) then
				skynet = dofile(skynetPath)
				skynet.open(channel)
			else
				local prog = http.get(skynetURL)
				if prog then
					local file = fs.open(skynetPath, "w")
					file.write(prog.readAll())
					file.close()
					skynet = dofile(skynetPath)
					skynet.open(channel)
				else
					error("Skynet can't be downloaded! Use modems instead.")
				end
			end
		end
	else
		local modems = {peripheral.find("modem")}
		if #modems == 0 then
			if ccemux then
				ccemux.attach("top", "wireless_modem")
				modem = peripheral.wrap("top")
			else
				error("A modem is needed.")
			end
		else
			modem = modems[1]
		end
		modem.open(channel)
		return modem
	end
end

local transmit = function(msg)
	if useSkynet then
		skynet.send(channel, msg)
	else
		modem.transmit(channel, channel, msg)
	end
end

local receive = function()
	if useSkynet then
		return ({skynet.receive(channel)})[2]
	else
		return ({os.pullEvent("modem_message")})[5]
	end
end

local images = {
	logo = {
		{
			"    ",
			"          ",
			"             ",
			"           ",
			"          ",
			"          ",
			"         ",
			"",
			" ",
			"  ",
			"    ",
		},
		{
			" f3ff3f333 f333ff3f3333f33f3f3f3ff3f3f3ff333333  ",
			" b ffbfbbbbfbbbbfbfb b fbbfbfbb ffbfbbbbfbb  b   ",
			" bbbbbbbb  bbb  bbbb b bbbbbbbbbbbbbbbfbbb   b   ",
			"          a11aa11a11a111a11a1aaa111aaaaaaaaaa3fa ",
			"          aaa1aaa1aa1aaaa1aa1aa1aaaaeeeeeeee33aaa",
			"          a1a1a1a1aa1aaaa1aa1aa1aaaeeeeeee00eeeef",
			"         faaa1a1a1aa1aaaa1aaaa11aa1eeeee00eeeeeea",
			"faaaa1a1111a11a1aaaaaa1a1a1a1a1aaa1eee00eeeeeeeea",
			"f1a1a11aaaaa1aaa1a11a1a1aa11aa11a1aa33eeeeeeeeea ",
			"f1a1a11aaaaa1aa1aa1aa1a1aa11aa111aaa33aeeeeeeea  ",
			"a1aa111111a11aaa11a11aa11111a111a11aaaaaaaaaa    ",
		},
		{
			" 3f33f3f3f 3f3f33f3ff3f3ff3f3f3f33f3f3f33ffff3f  ",
			" b bbfbfbffbfbffbfbf b bffbfbfb bbfbfbfbbff  b   ",
			" ffffffff  fff  ffff f fffffffffffffffffff   f   ",
			"          1aa11aa1aa1aaa1aa1aaa1aaaaaeeeeeee3aaf ",
			"          111a1111aa1aaa1aa1aaa111aeeeeeeeee333af",
			"          1aa11aa1aa1aaa1aa1aaa1aaaeeeeeeeeeeeeaa",
			"         a111a1aa1aa1aaa1aa111a111aeeeeeeeeeeeeaa",
			"a1aa1a1aaaa1aa1aaaaaa1a1a1a1a1a1a1aeeeeeeeeeeeeaf",
			"a11a1a111aa1aaa1a11a1aa1a1a111a11aa333eeeeeeeeaa ",
			"a1aa1a1aaaa1aaaa11a11aa1a1a1a1a1a1aaaaeeeeaaaaf  ",
			" aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaffffffffff    ",
		},
	},
	win = {
		{
			"              ",
			"             ",
			"              ",
			"                ",
			"            ",
		},
		{
			"55  55f555f555  55  55     555555555f   55f5f",
			"ff5f5555 55555  55  55 f5  55  55  55f5 55f55",
			" 5555 55  5555  55  55 555 55  55  5555f55555",
			"  55  5f f5555  55  f5f5f5f5   55  55 5f55 55",
			"  55  555555555555   555f555 55555555   55 55",
		},
		{
			"5f  5f55555f5f  5f  5f     5f55555f55   5f555",
			"55f55f5f f5f5f  5f  5f 55  5f  5f  555f 5f555",
			" f5ff 5f  5f5f  5f  5f 55f 5f  5f  5ff555ff5f",
			"  5f  55 55f5f  5f  55555555   5f  5f f55f ff",
			"  5f  f555fff555ff   55ff55f 55555f5f   5f 5f",
		},
	},
	lose = {
		{
			"      ",
			"                      ",
			"               ",
			"                      ",
			"      ",
		},
		{
			"111ff 11111111    111111111111111111111ff ",
			"11 11111    11    11      11  11    11 111",
			"11  1111111 11    11111   11  11111 11  11",
			"11 f1111    11    11      11  11    11 f11",
			"11111 111111111111111111  11  11111111111 ",
		},
		{
			"11111 11111f1f    11111f11111f11111f11111 ",
			"1f f1f1f    1f    1f      1f  1f    1f f1f",
			"1f  1f1ffff 1f    1ffff   1f  1ffff 1f  1f",
			"1f 11f1f    1f    1f      1f  1f    1f 11f",
			"111ff 11111f11111f11111f  1f  11111f111ff ",
		},
	},
	panel = {
		normal = {{"","",""},{"eeeee7","e78877","eeeeee"},{"77777e","78888e","eeeeee"}},
		cracked = {{"","",""},{"eeeee7","e88888","eeeeee"},{"77777e","87777e","eeeeee"}},
		broken = {{"","",""},{"eeeeef","eff8f7","eeeeee"},{"     e","788f8e","eeeeee"}}
	},
	player = {
		["6"] = {{"","  ","","  ",""},{"f5ff","4  4","66ff","2  2","affa"},{"5f55","4  f","6f66","2  2"," aaf"}},
		["7"] = {{"","  ","","","  "},{"5555","  f4","ffff","2f22"," fa "},{"5ff5","  4f","6666"," 2ff"," af "}},
	},
	rockcube = {{"","",""},{"7887","8777","7777"},{"8778","7778","8888"}},
	cannon = {{"",""},{"ff","77"},{"77","  ",}},
	buster = {{""},{"f4"},{"4f"}}
}

local cwrite = function(text, y)
	local cx, cy = term.getCursorPos()
	term.setCursorPos(0.5 + scr_x / 2 - #text / 2, y or (scr_y / 2))
	term.write(text)
end

local act = {stage = {}, player = {}, projectile = {}, object = {}}
act.stage.newPanel = function(x, y, panelType, owner)
	stage.panels[y] = stage.panels[y] or {}
	stage.panels[y][x] = {
		panelType = panelType,
		reserved = false,
		crackedLevel = 0,	-- 0 is okay, 1 is cracked, 2 is broken
		owner = owner or (x > 3 and 2 or 1),
		originalOwner = owner or (x > 3 and 2 or 1),
		cooldown = {
			owner = 0,
			broken = 0,
		}
	}
end
act.player.checkPlayerAtPos = function(x, y, ignoreThisOne)
	x, y = round(x), round(y)
	for id, player in pairs(players) do
		if id ~= ignoreThisOne then
			if player.x == x and player.y == y then
				return id
			end
		end
	end
end
act.stage.checkExist = function(x, y)
	if stage.panels[y] then
		if stage.panels[y][x] then
			return true
		end
	end
	return false
end
act.stage.crackPanel = function(x, y, amount)
	local maxCrack
	if act.stage.checkExist(x, y) then
		if act.player.checkPlayerAtPos(x, y) then
			maxCrack = 1
		else
			maxCrack = 2
		end
		if math.max(0, math.min(maxCrack, stage.panels[y][x].crackedLevel + amount)) ~= stage.panels[y][x].crackedLevel then
			stage.panels[y][x].crackedLevel = math.max(0, math.min(maxCrack, stage.panels[y][x].crackedLevel + amount))
			if stage.panels[y][x].crackedLevel == 2 then
				stage.panels[y][x].cooldown.broken = 300
			else
				stage.panels[y][x].cooldown.broken = 0
			end
			stageChanged = true
		end
	end
end
act.stage.setDamage = function(x, y, damage, owner, time, noFlinch, safePlayers, safeObjects)
	x, y = round(x), round(y)
	stage.damage[y] = stage.damage[y] or {}
	stage.damage[y][x] = stage.damage[y][x] or {}
	stage.damage[y][x][owner] = {
		owner = owner,
		time = time,
		damage = damage,
		flinching = not noFlinch,
		safePlayers = safePlayers or {},
		safeObjects = safeObjects or {}
	}
	stageChanged = true
end
act.stage.getDamage = function(x, y, pID, oID, pIDsafeCheck, oIDsafeCheck)
	local totalDamage = 0
	local flinching = false
	x, y = round(x), round(y)
	if stage.damage[y] then
		if stage.damage[y][x] then
			for k, v in pairs(stage.damage[y][x]) do
				if k ~= (players[pID] or {}).owner and k ~= (objects[oID] or {}).owner and v.damage then
					if not (v.safePlayers[pIDsafeCheck] or v.safeObjects[oIDsafeCheck]) then
						totalDamage = totalDamage + v.damage
						flinching = flinching or v.flinching
					end
				end
			end
		end
	end
	return totalDamage, flinching
end

local premadeFolders = {
	[1] = {
		{"cannon", "a"},
		{"cannon", "a"},
		{"hicannon", "b"},
		{"hicannon", "b"},
		{"shotgun", "b"},
		{"shotgun", "b"},
		{"vgun", "l"},
		{"vgun", "l"},
		{"crossgun", "l"},
		{"minibomb", "b"},
		{"minibomb", "b"},
		{"lilbomb", "b"},
		{"recov120", "a"},
		{"recov120", "a"},
		{"recov80", "l"},
		{"recov50", "l"},
		{"recov50", "l"},
		{"sword", "s"},
		{"sword", "s"},
		{"sword", "s"},
		{"panelreturn", "s"},
		{"widesword", "s"},
		{"widesword", "s"},
		{"longsword", "s"},
		{"busterup", "s"},
		{"crackout", "b"},
		{"shockwave", "b"},
		{"areagrab", "s"},
		{"areagrab", "s"},
		{"panelgrab", "s"},
	},
	[2] = {
		{"cannon", "a"},
		{"cannon", "a"},
		{"hicannon", "a"},
		{"hicannon", "a"},
		{"mcannon", "a"},
		{"mcannon", "a"},
		{"airshot1", "a"},
		{"airshot1", "a"},
		{"airshot2", "a"},
		{"vulcan1", "c"},
		{"vulcan1", "c"},
		{"shockwave", "c"},
		{"minibomb", "c"},
		{"minibomb", "c"},
		{"crossbomb", "c"},
		{"panelreturn", "s"},
		{"sword", "s"},
		{"sword", "s"},
		{"longsword", "s"},
		{"busterup", "s"},
		{"widesword", "s"},
		{"rockcube", "a"},
		{"areagrab", "s"},
		{"areagrab", "s"},
		{"panelgrab", "s"},
		{"panelshot", "s"},
		{"panelshot", "s"},
		{"recov50", "l"},
		{"recov50", "l"},
		{"recov50", "l"},
	},
	[3] = {
		{"cannon", "a"},
		{"hicannon", "a"},
		{"mcannon", "b"},
		{"airshot2", "a"},
		{"airshot2", "a"},
		{"rockcube", "s"},
		{"shockwave", "a"},
		{"lilbomb", "l"},
		{"lilbomb", "l"},
		{"areagrab", "s"},
		{"areagrab", "s"},
		{"fightersword", "f"},
		{"panelreturn", "s"},
		{"panelreturn", "s"},
		{"panelshot", "f"},
		{"panelshot", "f"},
		{"doubleshot", "f"},
		{"tripleshot", "f"},
		{"invis", "l"},
		{"recov30", "l"},
		{"recov30", "l"},
		{"vulcan2", "c"},
		{"vulcan1", "c"},
		{"boomer1", "c"},
		{"geddon1", "f"},
		{"shotgun", "d"},
		{"shotgun", "d"},
		{"vgun", "d"},
		{"vgun", "d"},
		{"spreader", "d"},
	}
}

act.player.newPlayer = function(x, y, owner, direction, image)
	local pID = #players + 1
	players[pID] = {
		x = x,							-- X and Y positions are relative to grid, not screen
		y = y,							-- ditto my man
		owner = owner,					-- Either 1 or 2, indicates the red/blue alignment
		type = "player",				-- Used for quickly identifying a player/object/projectile at a glance
		direction = direction or 1,		-- Either -1 or 1, indicates facing left or right
		health = 600,					-- Once it hits 0, your player is deleted
		maxHealth = 600,				-- You cannot heal past this value
		image = image,					-- Because of CC limitations, I'm just going to have one player sprite
		canMove = true,					-- If false, pushing the move buttons won't do diddly fuck
		canShoot = true,				-- If false, pushing the shoot buttons won't do fuckly didd
		isDead = false,					-- If true, the current game is over and the opponent wins
		busterPower = 2,				-- Strength of MegaBuster
		cooldown = {					-- All cooldown values are decremented every tick
			move = 0,						-- If above 0, you cannot move
			shoot = 0,						-- If above 0, you cannot shoot
			iframe = 0						-- If above 0, you will flash and be indestructible
		},
		control = {
			moveUp = false,
			moveDown = false,
			moveLeft = false,
			moveRight = false,
			buster = false,
			chip = false,
			custom = false
		},
		chipQueue = {},					-- Attacks are used in a queue, which is filled each turn
		folder = premadeFolders[math.random(1, 3)]
	}
	return pID
end

act.object.newObject = function(x, y, owner, direction, objectType)
	local oID = #objects + 1
	objects[oID] = {
		x = x,
		y = y,
		image = objectTypes[objectType].image,
		friendlyFire = objectTypes[objectType].friendlyFire or true,
		health = objectTypes[objectType].health or 500,
		maxHealth = objectTypes[objectType].maxHealth or 500,
		smackDamage = objectTypes[objectType].smackDamage or 100,
		doYeet = objectTypes[objectType].doYeet or false,
		delayedTime = objectTypes[objectType].delayedTime or math.huge,
		delayedFunc = objectTypes[objectType].delayedFunc or function() end,
		xvel = 0,
		yvel = 0,
		owner = owner,
		direction = direction,
		type = "object",
		objectType = objectType,
		frame = 0,
		cooldown = {
			iframe = 0,
		}
	}
	return oID
end

act.object.checkObjectAtPos = function(x, y, ignoreThisOne)
	x, y = round(x), round(y)
	for id, obj in pairs(objects) do
		if id ~= ignoreThisOne then
			if obj.x == x and obj.y == y then
				return id
			end
		end
	end
	return false
end

local control = {
	moveUp = keys.up,
	moveDown = keys.down,
	moveLeft = keys.left,
	moveRight = keys.right,
	buster = keys.z,
	chip = keys.x,
	custom = keys.c
}

local getControls = function()
	if players[you] then
		for k,v in pairs(control) do
			players[you].control[k] = keysDown[v] or false
		end
	end
end

act.stage.checkIfSolid = function(x, y)
	x, y = round(x), round(y)
	if stage.panels[y] then
		if stage.panels[y][x] then
			if stage.panels[y][x].crackedLevel < 2 then
				return true
			end
		end
	end
	return false
end

act.stage.checkIfWalkable = function(x, y, pID, oID)
	if x >= 1 and x <= 6 then
		x, y = round(x), round(y)
		if act.stage.checkIfSolid(x, y) then
			if not act.object.checkObjectAtPos(x, y, oID) then
				if not act.player.checkPlayerAtPos(x, y, pID) and (not pID or stage.panels[y][x].owner == players[pID].owner) then
					return true
				end
			end
		end
	end
	return false
end

act.player.movePlayer = function(pID, xmove, ymove, doCooldown)
	local player = players[pID]
	if (xmove ~= 0 or ymove ~= 0) and act.stage.checkIfWalkable(player.x + xmove, player.y + ymove, pID) then
		player.x = player.x + xmove
		player.y = player.y + ymove
		if doCooldown then
			if gameDelayInit < 0.1 then
				player.cooldown.move = 3
			else
				player.cooldown.move = 2
			end
		end
		if stage.panels[player.y - ymove][player.x - xmove].crackedLevel == 1 then
			act.stage.crackPanel(player.x - xmove, player.y - ymove, 1)
		end
		return true
	else
		return false
	end
end

act.object.moveObject = function(oID, xmove, ymove)
	local object = objects[oID]
	if (xmove ~= 0 or ymove ~= 0) and act.stage.checkIfWalkable(object.x + xmove, object.y + ymove, nil, oID) then
		object.x = object.x + xmove
		object.y = object.y + ymove
		return true
	else
		return false
	end
end

local movePlayers = function()
	local xmove, ymove, p
	for i = 1, #players do
		xmove, ymove = 0, 0
		p = players[i]
		if p.canMove then
			if p.cooldown.move == 0 then
				if p.control.moveUp then
					ymove = -1
				elseif p.control.moveDown then
					ymove = 1
				elseif p.control.moveRight then
					xmove = 1
				elseif p.control.moveLeft then
					xmove = -1
				end
				act.player.movePlayer(i, xmove, ymove, true)
			end
			if stage.panels[p.y] then
				if stage.panels[p.y][p.x] then
					if stage.panels[p.y][p.x].owner ~= p.owner then
						repeat
							if p.owner == 1 then
								p.x = p.x - 1
							else
								p.x = p.x + 1
							end
						until stage.panels[p.y][p.x].owner == p.owner
					end
				end
			end
		end
	end
end

local reduceCooldowns = function()
	for id, player in pairs(players) do
		for k,v in pairs(player.cooldown) do

			players[id].cooldown[k] = math.max(0, v - 1)

		end
	end
	for id, object in pairs(objects) do
		for k,v in pairs(object.cooldown) do

			objects[id].cooldown[k] = math.max(0, v - 1)

		end
	end
	for y, row in pairs(stage.damage) do
		for x, panel in pairs(row) do
			for owner, damageData in pairs(panel) do

				stage.damage[y][x][owner].time = math.max(0, damageData.time - 1)
				if damageData.time == 0 then
					stage.damage[y][x][owner] = nil
				end

			end
		end
	end
	for y, row in pairs(stage.panels) do
		for x, panel in pairs(row) do
			for k,v in pairs(panel.cooldown) do

				stage.panels[y][x].cooldown[k] = math.max(0, v - 1)
				if k == "owner" then
					if stage.panels[y][x].owner == stage.panels[y][x].originalOwner then
						stage.panels[y][x].cooldown.owner = 0
					elseif v == 0 then
						stageChanged = true
						stage.panels[y][x].owner = stage.panels[y][x].originalOwner
					end
				elseif k == "broken" and v == 0 and panel.crackedLevel == 2 then
					stageChanged = true
					stage.panels[y][x].crackedLevel = 0
				end

			end
		end
	end
end

act.projectile.checkProjectileCollisions = function(info)

	local struckPlayer = false
	local struckObject = false
	local cPlayer = act.player.checkPlayerAtPos(info.x, info.y) --, info.owner)
	local cObject = act.object.checkObjectAtPos(info.x, info.y) --, info.owner)

	if cPlayer then
		if players[cPlayer].cooldown.iframe == 0 and players[cPlayer].owner ~= info.owner then
			struckPlayer = cPlayer
		end
	end
	if cObject then
		if objects[cObject].cooldown.iframe == 0 then
			struckObject = cObject
		end
	end
	return struckPlayer, struckObject
end

local readFile = function(path)
	if fs.exists(path) then
		local file = fs.open(path, "r")
		local contents = file.readAll()
		file.close()
		return contents
	end
end

act.projectile.newProjectile = function(x, y, player, chipType, noFlinch, altDamage)
	local id = #projectiles + 1
	projectiles[id] = {
		x = x,
		y = y,
		safeObjects = {},
		safePlayers = {},
		type = "projectile",
		initX = x,
		initY = y,
		id = id,
		owner = player.owner,
		player = player,
		direction = player.direction,
		frame = 0,
		noFlinch = noFlinch,	-- overwrite a projectile's flinchingness
		altDamage = altDamage,	-- overwrite a projectile's damage
		chipType = chipType
	}
	return id
end

-- loads all chips and objects from file
local loadChips = function(env)
	local cList = fs.list(config.chipDir)
	local oList = fs.list(config.objectDir)
	local contents
	local cOutput, oOutput = {}, {}
	for i = 1, #cList do
		if not fs.isDir(fs.combine(config.chipDir, cList[i])) then
			cOutput[cList[i]] = loadfile( fs.combine(config.chipDir, cList[i]))(
				stage,
				players,
				objects,
				projectiles,
				act,
				images
			)
		end
	end
	for i = 1, #oList do
		if not fs.isDir(fs.combine(config.objectDir, oList[i])) then
			oOutput[oList[i]] = loadfile( fs.combine(config.objectDir, oList[i]))(
				stage,
				players,
				objects,
				projectiles,
				act,
				images
			)
		end
	end
	return cOutput, oOutput
end

local stageImageStitch

local makeStageImageStitch = function()
	local buffer, im = {}
	for y = #stage.panels, 1, -1 do
		if stage.panels[y] then
			for x = 1, #stage.panels[y] do
				if stage.panels[y][x] then
					if stage.panels[y][x].crackedLevel == 0 then
						im = images.panel[stage.panels[y][x].panelType]
					elseif stage.panels[y][x].crackedLevel == 1 then
						im = images.panel.cracked
					elseif stage.panels[y][x].crackedLevel == 2 then
						im = images.panel.broken
					end
					if stage.panels[y][x].owner == 2 then
						im = colorSwap(im, {e = "b"})
					end
					if act.stage.getDamage(x, y) > 0 then
						im = colorSwap(im, {["7"] = "4", ["8"] = "4"})
					end
					buffer[#buffer + 1] = {
						im,
						(x - 1) * stage.panelWidth  + 1,
						(y - 1) * stage.panelHeight + 1
					}
				end
			end
		end
	end
	return merge(table.unpack(buffer))
end

local render = function(extraImage)
	local buffer, im = {}
	local sx, sy
	if stageChanged or true then
		stageImageStitch = makeStageImageStitch()
		stageChanged = false
	end
	local sortedList = {}
	for k,v in pairs(projectiles) do
		sortedList[#sortedList+1] = v
	end
	for k,v in pairs(players) do
		sortedList[#sortedList+1] = v
	end
	for k,v in pairs(objects) do
		sortedList[#sortedList+1] = v
	end
	table.sort(sortedList, function(a,b) return a.y >= b.y end)
	if extraImage then
		buffer[#buffer + 1] = {
			colorSwap(extraImage[1], {["f"] = " "}),
			extraImage[2],
			extraImage[3]
		}
	end
	for k,v in pairs(sortedList) do
		if v.type == "player" then
			if not v.isDead then
				if v.cooldown.iframe == 0 or (FRAME % 2 == 0) then
					sx = (v.x - 1) * stage.panelWidth  + 2
					sy = (v.y - 1) * stage.panelHeight - 2
					buffer[#buffer + 1] = {
						colorSwap(images.player[v.image], {["f"] = " "}),
						sx + stage.scrollX,
						sy + stage.scrollY
					}
				end
			end
		elseif v.type == "projectile" then
			sx = math.floor((v.x - 1) * stage.panelWidth + 4)
			sy = math.floor((v.y - 1) * stage.panelHeight)
			if sx >= -1 and sx <= scr_x and v.imageData then

				for kk, imd in pairs(v.imageData) do
					buffer[#buffer + 1] = {
						colorSwap(imd[1], {["f"] = " "}),
						math.floor((imd[2] - 1) * stage.panelWidth  + 4 + stage.scrollX),
						math.floor((imd[3] - 1) * stage.panelHeight + 1 + stage.scrollY)
					}
				end

			end
		elseif v.type == "object" then
			sx = (v.x - 1) * stage.panelWidth + 3
			sy = (v.y - 1) * stage.panelHeight
			buffer[#buffer + 1] = {
				colorSwap(v.image, {["f"] = " "}),
				math.floor(sx + stage.scrollX),
				math.floor(sy + stage.scrollY)
			}
		end
	end
	buffer[#buffer + 1] = {
		stageImageStitch,
		stage.scrollX + 1,
		stage.scrollY + 1
	}
	buffer[#buffer + 1] = {makeRectangle(scr_x, scr_y, "f", "f", "f"), 1, 1}
	drawImage(colorSwap(merge(table.unpack(buffer)), {[" "] = "f"}), 1, 1)

	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.black)
	if players[you] then
		if chips[players[you].chipQueue[1]] then
			term.setCursorPos(1, scr_y)
			term.write(chips[players[you].chipQueue[1]].info.name)
		end
	end

	local HPs = {{},{}}
	for id, player in pairs(players) do
		HPs[player.owner] = HPs[player.owner] or {}
		HPs[player.owner][#HPs[player.owner] + 1] = player.health

		if player.owner == 1 then
			term.setCursorPos(1, #HPs[player.owner])
			term.write(player.health)
		else
			term.setCursorPos(scr_x - 3, #HPs[player.owner])
			term.write(player.health)
		end
	end

	if game.custom == game.customMax and FRAME % 16 <= 12 and not game.inChipSelect then
		cwrite("PUSH '" .. revKeys[control.custom]:upper() .. "'!", 2)
	end
	term.setTextColor(colors.lightGray)
	term.setCursorPos(6, 1)
	term.write("CUSTOM")
	term.setTextColor(colors.white)
	term.write("[")
	local barLength = scr_x - 18
	if game.custom == game.customMax then
		term.setTextColor(colors.gray)
		term.setBackgroundColor(colors.lime)
	else
		term.setTextColor(colors.gray)
		term.setBackgroundColor(colors.green)
	end
	for i = 1, barLength do
		if (i / barLength) <= (game.custom / game.customMax) then
			if game.custom == game.customMax then
				term.write("@")
			else
				term.write("=")
			end
		else
			term.setBackgroundColor(colors.black)
			term.write(" ")
		end
	end
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.black)
	term.write("]")

	if showDebug then
		term.setCursorPos(1, scr_y - 1)
		term.write("Frame: " .. FRAME .. ", isHost = " .. tostring(isHost) .. ", you = " .. tostring(you))
	end
end

local getInput = function()
	local evt
	keysDown = {}
	miceDown = {}
	while true do
		evt = {os.pullEvent()}
		if evt[1] == "key" then
			keysDown[evt[2]] = true
			if keysDown[keys.leftCtrl] and keysDown[keys.t] then
				if skynet and useSkynet then
					skynet.socket.close()
				end
				return
			end
		elseif evt[1] == "key_up" then
			keysDown[evt[2]] = nil
		elseif evt[1] == "mouse_click" or evt[1] == "mouse_drag" then
			miceDown[evt[2]] = {evt[3], evt[4]}
		elseif evt[1] == "mouse_up" then
			miceDown[evt[2]] = nil
		end
	end
end

local chipSelectScreen = function()
	local inQueue = {}	-- selected chips in menu, by folder position
	local pile = {}		-- chips for you to choose from, by folder position
	local rPile, r = {}
	local player = players[you]
	for i = 1, 5 do
		repeat
			r = math.random(1, #player.folder)
		until not rPile[r]
		pile[#pile + 1] = r
		rPile[r] = true
	end
	local cursor = 1

	local checkIfChoosable = function(c)
		local chip, compareChip = player.folder[pile[c]]
		local isSameChip = true
		local isSameCode = true
		for i = 1, #inQueue do
			compareChip = player.folder[inQueue[i]]
			if compareChip[1] ~= chip[1] then
				isSameChip = false
			end
			if compareChip[2] ~= chip[2] then
				isSameCode = false
			end
		end
		return isSameCode or isSameChip
	end

	local renderMenu = function()
		local chip
		term.setBackgroundColor(colors.gray)
		term.setTextColor(colors.yellow)
		for y = 4, scr_y - 2 do
			term.setCursorPos(3, y)
			term.write((" "):rep(scr_x - 4))
		end
		cwrite(" Turn " .. game.turnNumber .. ", Select Chips: ", 3)
		term.setTextColor(colors.lightGray)
		cwrite(" (Push '" .. revKeys[control.chip]:upper() .. "' to add / '" .. revKeys[control.buster]:upper() .. "' to remove) ", 4)
		cwrite(" (Push ENTER to confirm loadout) ", 5)
		for y = 1, #pile do
			if checkIfChoosable(y) then
				if y == cursor then
					term.setBackgroundColor(colors.lightGray)
					term.setTextColor(colors.white)
				else
					term.setBackgroundColor(colors.gray)
					term.setTextColor(colors.white)
				end
			else
				if y == cursor then
					term.setBackgroundColor(colors.lightGray)
					term.setTextColor(colors.gray)
				else
					term.setBackgroundColor(colors.gray)
					term.setTextColor(colors.lightGray)
				end
			end
			chip = player.folder[pile[y]]
			term.setCursorPos(4, y + 5)
			term.write(chips[chip[1]].info.name .. " " .. chip[2]:upper())
		end
		term.setBackgroundColor(colors.gray)
		term.setTextColor(colors.lightBlue)
		for y = 1, #inQueue do
			chip = player.folder[inQueue[y]]
			term.setCursorPos(20, y + 5)
			term.write(chips[chip[1]].info.name .. " " .. chip[2]:upper())
		end
		term.setTextColor(colors.white)
		if player.folder[pile[cursor]] then
			term.setCursorPos(5, 12)
			term.write("Description:")
			term.setCursorPos(4, 13)
			term.write(chips[player.folder[pile[cursor]][1]].info.description)
		end
	end

	local evt
	render()
	while true do
		renderMenu()
		evt = {os.pullEvent()}
		if evt[1] == "key" then
			if evt[2] == keys.up then
				cursor = math.max(cursor - 1, 1)
			elseif evt[2] == keys.down then
				cursor = math.min(cursor + 1, #pile)
			elseif evt[2] == control.chip then
				if pile[cursor] then
					if checkIfChoosable(cursor) then
						table.insert(inQueue, pile[cursor])
						table.remove(pile, cursor)
					end
				end
			elseif evt[2] == control.buster then
				if #inQueue > 0 then
					table.insert(pile, inQueue[#inQueue])
					table.remove(inQueue, #inQueue)
				end
			elseif evt[2] == keys.enter then
				player.chipQueue = {}
				for i = 1, #inQueue do
					player.chipQueue[#player.chipQueue + 1] = player.folder[inQueue[i]][1]
				end
				table.sort(inQueue, function(a,b) return a > b end)
				for i = 1, #inQueue do
					table.remove(inQueue, i)
				end
				return
			end
			cursor = math.min(math.max(cursor, 1), #pile)
		end
	end
end

local checkDeadPlayers = function()
	local deadPlayers, thereIsDead = {}, false
	for id, player in pairs(players) do
		if player.isDead then
			deadPlayers[id] = true
			thereIsDead = true
		end
	end
	return thereIsDead, deadPlayers
end

local waitingForClientChipSelection = false
local runGame = function()
	local evt, getStateInfo
	render()
	sleep(0.35)
	while true do
		FRAME = FRAME + 1

		if game.inChipSelect then
			game.turnNumber = game.turnNumber + 1
			chipSelectScreen()
			if isHost then
				game.custom = 0
				local msg
				render()
				cwrite("Waiting for other player...", scr_y - 3)

				transmit({
					gameID = gameID,
					command = "turn_ready",
					pID = you,
				})

				repeat
					sleep(0)
				until cliChipSelect

				players[cliChipSelect.pID].chipQueue = cliChipSelect.chipQueue
				players[cliChipSelect.pID].folder = cliChipSelect.folder
				cliChipSelect = false

				transmit({
					gameID = gameID,
					command = "turn_ready",
					pID = 1,
				})
				term.clearLine()
				cwrite("READY!", scr_y - 3)
				sleep(0.5)
			else
				transmit({
					gameID = gameID,
					command = "turn_ready",
					pID = you,
					chipQueue = players[you].chipQueue,
					folder = players[you].folder,
				})
				render()
				cwrite("Waiting for other player...", scr_y - 3)
				repeat
					msg = receive()
					msg = type(msg) == "table" and msg or {}
				until (
					msg.gameID == gameID and
					msg.command == "turn_ready" and
					players[msg.pID]
				)
				term.clearLine()
				cwrite("READY!", scr_y - 3)
				sleep(0.5)
			end
			game.inChipSelect = false
		end

		if isHost then
			getControls()
			for id, proj in pairs(projectiles) do
				local success, imageData = chips[proj.chipType].logic(proj)
				if success then
					projectiles[id].imageData = imageData
					projectiles[id].frame = proj.frame + 1
				else
					projectiles[id] = nil
				end
			end

			for y = 1, #stage.panels do
				for x = 1, #stage.panels[y] do
					stage.panels[y][x].reserved = false
				end
			end

			for id, player in pairs(players) do
				if not player.isDead then
					if player.canMove then
						stage.panels[player.y][player.x].reserved = id
					end
					local dmg, flinching = act.stage.getDamage(player.x, player.y, id)
					if player.cooldown.iframe == 0 and dmg > 0 then
						player.health = math.max(0, player.health - dmg)
						if player.health == 0 then
							player.isDead = true
						elseif flinching then
							player.cooldown.iframe = 16
							player.cooldown.move = 8
							player.cooldown.shoot = 6
						end
					elseif player.cooldown.shoot == 0 then
						if player.canShoot then
							if player.control.chip then
								if player.chipQueue[1] then
									if chips[player.chipQueue[1]] then
										act.projectile.newProjectile(player.x, player.y, player, player.chipQueue[1])
										for k,v in pairs(chips[player.chipQueue[1]].info.cooldown or {}) do
											player.cooldown[k] = v
										end
										if true then
											table.remove(player.chipQueue, 1)
										else
											player.chipQueue[#player.chipQueue + 1] = player.chipQueue[1]
											table.remove(player.chipQueue, 1)
										end
									end
								end
							elseif player.control.buster then
								act.projectile.newProjectile(player.x, player.y, player, "buster")
								for k,v in pairs(chips.buster.info.cooldown or {}) do
									player.cooldown[k] = v
								end
							end
						end
					end
				end
			end
			for id, object in pairs(objects) do
				local dmg, flinching = act.stage.getDamage(object.x, object.y, nil, not object.friendlyFire and id, nil, id)
				if object.cooldown.iframe == 0 and dmg > 0 then
					object.health = object.health - dmg
					if object.health <= 0 then
						table.remove(objects, id)
					else
						object.cooldown.iframe = 2
					end
				end
				if objects[id] then
					if object.xvel ~= 0 or object.yvel ~= 0 then
						if not act.object.moveObject(id, object.xvel, object.yvel) then
							if act.player.checkPlayerAtPos(object.x + object.xvel, object.y) or act.object.checkObjectAtPos(object.x + object.xvel, object.y) then
								act.stage.setDamage(object.x + object.xvel, object.y + object.yvel, object.smackDamage, 0, 2, false)
								table.remove(objects, id)
							else
								object.xvel = 0
								object.yvel = 0
								object.x = round(object.x)
								object.y = round(object.y)
							end
						end
					end
					object.frame = object.frame + 1
					if object.frame > 1 and object.frame % object.delayedTime == 0 then
						object.delayedFunc(object)
					end
				end
			end
			if players[you] then
				if players[you].control.custom and game.custom == game.customMax then
					game.inChipSelect = true
				end
			end
			render()
			movePlayers()
			sleep(gameDelayInit)
			game.custom = math.min(game.customMax, game.custom + 1)
			transmit({
				gameID = gameID,
				command = "get_state",
				players = players,
				projectiles = projectiles,
				objects = objects,
				game = game,
				stageDamage = stage.damage,
				stagePanels = stage.panels,
				id = id
			})
			reduceCooldowns()
		else
			getControls()
			if players[you] then
				transmit({
					gameID = gameID,
					command = "set_controls",
					id = yourID,
					pID = you,
					control = players[you].control
				})
			end
			if players[you] then
				if players[you].control.custom and game.custom == game.customMax then
					transmit({
						gameID = gameID,
						command = "chip_select",
						id = yourID,
					})
				end
			end
			render()
			evt, getStateInfo = os.pullEvent("ccbn_get_state")
			players = getStateInfo.players
			projectiles = getStateInfo.projectiles
			objects = getStateInfo.objects
			game = getStateInfo.game
			stage.damage = getStateInfo.stageDamage
			stage.panels = getStateInfo.stagePanels
		end

		if checkDeadPlayers() then
			render()
			break
		end

	end

	local thereIsDead, deadPlayers = checkDeadPlayers()
	if thereIsDead then
		sleep(0.5)
		parallel.waitForAny(function()
			while true do
				if deadPlayers[you] then
					render({images.lose, true, 6})
				else
					render({images.win, true, 6})
				end
				sleep(1)
				render()
				sleep(0.5)
			end
		end, function() os.pullEvent("key") end)
		sleep(0.05)
	end
end

local interpretNetMessage = function(msg)
	if waitingForGame then
		if msg.command == "find_game" then
			local time = os.epoch("utc")
			if msg.time > time then
				isHost = false
				you = 2
			else
				isHost = true
				you = 1
			end
			return true
		end
	elseif msg.gameID == gameID then
		if isHost then
			if msg.command == "set_controls" then
				if players[msg.pID] then
					players[msg.pID].control = msg.control
				end
			elseif msg.command == "chip_select" then
				if game.custom == game.customMax then
					game.inChipSelect = true
				end
			elseif msg.command == "turn_ready" then
				if (
					type(msg.chipQueue) == "table" and
					players[msg.pID] and
					type(msg.folder) == "table"
				) then
					cliChipSelect = {
						folder = msg.folder,
						chipQueue = msg.chipQueue,
						pID = msg.pID
					}
				end
			end
		else
			if msg.command == "get_state" then
				os.queueEvent("ccbn_get_state", {
					players = msg.players,
					projectiles = msg.projectiles,
					objects = msg.objects,
					game = msg.game,
					stageDamage = msg.stageDamage,
					stagePanels = msg.stagePanels
				})
			end
		end
	end
end

local networking = function()
	local msg
	while true do
		msg = receive()
		if type(msg) == "table" then
			interpretNetMessage(msg)
		end
	end
end

local startGame = function()
	getModem()
	local time = os.epoch("utc")
	chips, objectTypes = loadChips(getfenv())
	stage.panels = {}
	stage.damage = {}
	players = {}
	objects = {}
	projectiles = {}
	game.custom = 0
	game.customSpeed = 1
	game.inChipSelect = true
	game.paused = false
	act.player.newPlayer(2, 2, 1, 1, "6")
	act.player.newPlayer(5, 2, 2, -1, "7")
	for y = 1, 3 do
		for x = 1, 6 do
			act.stage.newPanel(x, y, "normal")
		end
	end
	transmit({
		gameID = gameID,
		command = "find_game",
		respond = false,
		id = yourID,
		time = time,
--		chips = chips
	})
	local msg
	waitingForGame = true
	term.clear()
	cwrite("Waiting for game...")
	repeat
		msg = receive()
	until interpretNetMessage(msg)
	gameID = isHost and gameID or msg.gameID
--	chips = isHost and chips or msg.chips
	transmit({
		gameID = gameID,
		command = "find_game",
		respond = true,
		id = yourID,
		time = isHost and math.huge or -math.huge,
--		chips = isHost and chips
	})
	waitingForGame = false
	parallel.waitForAny(runGame, networking)
end

local makeMenu = function(x, y, options, _cpos)
	local cpos = _cpos or 1
	local cursor = "> "
	local lastPos = cpos
	local rend = function()
		for i = 1, #options do
			if i == cpos then
				term.setCursorPos(x, y + (i - 1))
				term.setTextColor(colors.white)
				term.write(cursor .. options[i])
			else
				if i == lastPos then
					term.setCursorPos(x, y + (i - 1))
					term.write((" "):rep(#cursor))
					lastPos = nil
				else
					term.setCursorPos(x + #cursor, y + (i - 1))
				end
				term.setTextColor(colors.gray)
				term.write(options[i])
			end
		end
	end
	local evt
	rend()
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
				return cpos
			end
		elseif evt[1] == "mouse_click" then
			if evt[4] >= y and evt[4] < y+#options then
				if cpos == evt[4] - (y - 1) then
					return cpos
				else
					lastPos = cpos
					cpos = evt[4] - (y - 1)
					rend()
				end
			end
		end
		if lastPos ~= cpos then
			rend()
		end
	end
end

local howToPlay = function()
	local help = {
		" (Scroll with mousewheel / arrows)",
		" (Exit with 'Q')",
		("="):rep(scr_x),
		"",
		"   If you're not familiar with",
		" Megaman Battle Network, buckle up.",
		"",
		" Battles are separated into 'turns'.",
		" At the beginning of each turn, you",
		" select one or more battlechips to use",
		" during that turn.",
		"",
		" Selecting battlechips has certain rules.",
		" Battlechips are given alphabetic codes",
		" You can only pick two or more battlechips",
		" that have the same code, or are of the same",
		" chip type. That means you can pick a",
		" Cannon A and a Minibomb A, but you can't",
		" add an extra Cannon B without removing",
		" the Minibomb B.",
		" ____   ____      ____         ",
		"|    | |    |    |  ^ |        ",
		"|  "..revKeys[control.buster]:upper().." | |  "..revKeys[control.chip]:upper().." |    |  | |        ",
		"|____| |____|    |____|        ",
		"           ____   ____   ____  ",
		"          |    | |  | | |    | ",
		"          | <- | |  V | | -> | ",
		"          |____| |____| |____| ",
		"",
		" To move, use the ARROW KEYS.",
		" Fire the MegaBuster with '"..revKeys[control.buster]:upper().."'. It's a free",
		" action, but not very strong.",
		" Use the currently selected battlechip",
		" (indicated in the bottom-left corner)",
		" with '"..revKeys[control.chip]:upper().."'.",
		"",
		" Once you use up all your chips, you will",
		" need to wait for the Custom bar to refill.",
		" Once it is full, push '"..revKeys[control.custom]:upper().."' and the turn will",
		" end, and you can pick more battlechips.",
		"",
		" Keep in mind that this erases all currently",
		" loaded battlechips, and that the opponent",
		" can also end the turn without warning, so",
		" make sure that your battlechips are used",
		" before the bar fills!",
		"",
		"  ___________________________________",
		" |yours|yours|yours|enemy|enemy|enemy|",
		" |_____|_____|_____|_____|_____|_____|",
		" |yours|yours|yours|enemy|enemy|enemy|",
		" |_____|_____|_____|_____|_____|_____|",
		" |yours|yours|yours|enemy|enemy|enemy|",
		" |_____|_____|_____|_____|_____|_____|",
		"",
		" The stage that you stand on can also be",
		" manipulated. Some chips, such as AreaGrab",
		" can take away ownership of one or more",
		" panels from the enemy for a short while.",
		" Some chips, such as CrackShot, will break",
		" panels, rendering them unusable for a short",
		" while. Some chips will crack panels, such",
		" as Geddon1. Stepping off of a cracked panel",
		" will cause it to break.",
		"",
		" That's all I can think of. Sorry for all that",
		" wall of text, and I hope you enjoy the game!",
		"",
		" ___   __   __   _             _         ",
		"/   \\ |  | |  | | \\   |   | | / \\ | /  | ",
		"| ___ |  | |  | |  |  |   | | |   |/\\  | ",
		"\\__|  |__| |__| |_/   |__ \\_/ \\_/ |  \\ . ",
	}

	local scroll = 0
	local maxScroll = #help - scr_y + 2

	local rend = function(scroll)
		term.setBackgroundColor(colors.black)
		term.setTextColor(colors.white)
		for y = 1, scr_y do
			term.setCursorPos(1,y)
			term.clearLine()
			term.write(help[y + scroll] or "")
		end
	end

	local evt
	while true do
		evt = {os.pullEvent()}
		if evt[1] == "key" then
			if evt[2] == keys.q then
				return
			elseif evt[2] == keys.up then
				scroll = scroll - 1
			elseif evt[2] == keys.down then
				scroll = scroll + 1
			elseif evt[2] == keys.pageUp then
				scroll = scroll - scr_y
			elseif evt[2] == keys.pageDown then
				scroll = scroll + scr_y
			elseif evt[2] == keys.home then
				scroll = 0
			elseif evt[2] == keys["end"] then
				scroll = maxScroll
			end
		elseif evt[1] == "mouse_scroll" then
			scroll = scroll + evt[2]
		end
		scroll = math.min(maxScroll, math.max(0, scroll))
		rend(scroll)
	end

	sleep(0.1)
	os.pullEvent("key")
end

local titleScreen = function()
	local menuOptions = {
		"Start Game",
		"How to Play",
		"Exit"
	}
	local choice
	while true do
		term.setBackgroundColor(colors.black)
		term.clear()
		drawImage(images.logo, 2, 2)
		if useSkynet then
			term.setTextColor(colors.lightGray)
			cwrite("Skynet Enabled", 2 + #images.logo[1])
		end
		choice = makeMenu(2, scr_y - #menuOptions, menuOptions)
		if choice == 1 then
			parallel.waitForAny(startGame, getInput)
		elseif choice == 2 then
			howToPlay()
		elseif choice == 3 then
			return
		end
	end
end

titleScreen()

term.setBackgroundColor(colors.black)
term.clear()
cwrite("Thanks for playing!")
term.setCursorPos(1, scr_y)
