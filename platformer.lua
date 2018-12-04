local game = {}
game.path = ".game"
game.apiPath = fs.combine(game.path, "api")
game.spritePath = fs.combine(game.path, "sprite")
game.imagePath = fs.combine(game.path, "image")
game.configPath = fs.combine(game.path, "config.cfg")

local scrollX = 0
local scrollY = 0

local keysDown = {}

local getAPI = function(apiName, apiPath, apiURL, doDoFile)
	write("Getting " .. apiName .. "...")
	local prog = http.get(apiURL)
	if prog then
		print("success!")
		local file = fs.open(apiPath, "w")
		file.write(prog.readAll())
		file.close()
		if doDoFile then
			_ENV[fs.getName(apiPath)] = dofile(apiPath)
		else
			os.loadAPI(apiPath)
		end
	else
		error("fail!")
	end
end

if not nfte then
	getAPI("NFT Extra", "nfte", "https://github.com/LDDestroier/NFT-Extra/raw/master/nfte", false)
end

local sprites = {}
-- load sprites from sprite folder
for k, set in pairs(fs.list(game.spritePath)) do
	sprites[set] = {}
	for num, name in pairs(fs.list(fs.combine(game.spritePath, set))) do
		sprites[set][name:gsub(".nft", "")] = nfte.loadImage(fs.combine(game.spritePath, set .. "/" .. name))
		print("Loaded " .. name:gsub(".nft",""))
	end
end

local players = {}
local newPlayer = function(name, spriteset)
	return {
		name = name,			-- player name
		spriteset = spriteset,	-- set of sprites to use
		sprite = "stand",		-- current sprite
		direction = 1,			-- 1 is right, -1 is left
		xsize = 10,				-- hitbox x size
		ysize = 8,				-- hitbox y size
		x = 0,					-- x position
		y = 0,					-- y position
		xvel = 0,				-- x velocity
		yvel = 0,				-- y velocity
		jumpHeight = 4,			-- height of jump
		moveSpeed = 4,			-- speed of walking
		slideSleed = 6,			-- speed of sliding
		grounded = false,		-- is on solid ground
		shots = 0,				-- how many shots onscreen
		maxShots = 3,			-- maximum shots onscreen
		control = {				-- inputs
			up = false,
			down = false,
			left = false,
			right = false,
			jump = false,
			shoot = false
		}
	}
end

deriveControls = function(keyList)
	return {
		up = keysDown[keys.up],
		down = keysDown[keys.down],
		left = keysDown[keys.left],
		right = keysDown[keys.right],
		jump = keysDown[keys.z],
		shoot = keysDown[keys.x]
	}
end

isSolid = function(x, y)
	-- replace with actual stage later
	if y >= 11 then
		return true
	else
		return false
	end
end

isPlayerTouchingSolid = function(player, xmod, ymod, ycutoff)
	for y = 1 + (ycutoff or 0), player.ysize do
		for x = 1, player.xsize do
			if isSolid(x + (xmod or 0), y + (ymod or 0)) then
				return true
			end
		end
	end
	return false
end

you = 1
players[you] = newPlayer("LDD", "megaman")

movePlayer = function(player, x, y)
	i = player.yvel / math.abs(player.yvel)
	for y = 1, math.abs(player.yvel) do
		if isPlayerTouchingSolid(player, 0, -i) then
			player.yvel = 0
			player.grounded = true
			break
		else
			player.y = player.y - i
			player.grounded = false
		end
	end
	i = player.xvel / math.abs(player.xvel)
	for x = 1, math.abs(player.xvel) do
		if isPlayerTouchingSolid(player, i, 0) then
			player.xvel = 0
			break
		else
			player.x = player.x + i
		end
	end
end

moveTick = function()
	local i
	for num, player in pairs(players) do

		-- falling

		player.yvel = player.yvel - 1

		-- jumping

		if player.control.jump and player.grounded then
			player.yvel = player.yvel - player.jumpHeight
			player.grounded = false
		end

		-- walking

		if player.control.right then
			player.direction = 1
			player.xvel = player.moveSpeed
		elseif player.control.left then
			player.direction = -1
			player.xvel = -player.moveSpeed
		else
			player.xvel = 0
		end

		-- movement

		movePlayer(player, xvel, yvel)
	end
end

render = function()
	term.clear()
	for num,player in pairs(players) do
		term.setCursorPos(1,num)
		print("(" .. player.x .. ", " .. player.y .. ")")
		if player.direction == -1 then
			nfte.drawImage( nfte.flipX(sprites[player.spriteset][player.sprite]), player.x - scrollX, player.y - scrollY )
		else
			nfte.drawImage( sprites[player.spriteset][player.sprite], player.x - scrollX, player.y - scrollY )
		end
	end
end

-- determines what sprite a player uses
determineSprite = function(player)
	-- figure this out later
	return "stand1"
end

local getInput = function()
	local evt
	while true do
		evt = {os.pullEvent()}
		if evt[1] == "key" then
			keysDown[evt[2]] = true
		elseif evt[1] == "key_up" then
			keysDown[evt[2]] = false
		end
	end
end

main = function()
	while true do
		players[you].control = deriveControls(keysDown)
		moveTick()
		players[you].sprite = determineSprite(players[you])
		render()
		sleep(0.5)
	end
end

parallel.waitForAny(getInput, main)
