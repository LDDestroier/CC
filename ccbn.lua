-- slowly, I'll get rid of NFTE as a dependency by copying over specific functions from it
-- local nfte = dofile("nfte.lua")

local scr_x, scr_y = term.getSize()
local keysDown, miceDown = {}, {}

local players = {}
local projectiles = {}
local you = 1

local FRAME = 0

local stage = {
	panels = {},
	panelWidth = 6,
	panelHeight = 2,
	scrollX = 0,
	scrollY = 6
}

-- ripped from NFTE
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

local images = {
	panel = {
		normal = {{"","",""},{"eeeee7","e78877","eeeeee"},{"77777e","78888e","eeeeee"}},
--		cracked = ,
--		broken = ,
--		ice = ,
--		sand = ,
	},
	player = {{"","  ","","  ",""},{"fbff","b  b","bbff","b  b","bffb"},{"bfbb","b  f","bfbb","b  b"," bbf"}},
	cannon = {{"",""},{"ff","77"},{"77","  ",}},
}

local act = {stage = {}, player = {}, projectile = {}}
act.stage.newPanel = function(x, y, panelType, owner)
	stage.panels[y] = stage.panels[y] or {}
	stage.panels[y][x] = {
		panelType = panelType,
		reserved = false,
		crackedLevel = 0,	-- 0 is okay, 1 is cracked, 2 is broken
		owner = owner or (x > 3 and 2 or 1),
		damage = {},
		cooldown = {
			owner = 0,
			broken = 0,
		}
	}
end
act.stage.checkExist = function(x, y)
	if stage.panels[y] then
		if stage.panels[y][x] then
			return true
		end
	end
	return false
end
act.stage.setDamage = function(x, y, damage, owner, time)
	if act.stage.checkExist(x, y) then
		stage.panels[y][x].damage[owner] = {
			owner = owner,
			time = time,
			damage = damage,
		}
	end
end
act.stage.getDamage = function(x, y, owner)
	if act.stage.checkExist(x, y) then
		local totalDamage = 0
		for k,v in pairs(stage.panels[y][x].damage) do
			if k ~= owner then
				totalDamage = totalDamage + v.damage
			end
		end
		return totalDamage
	else
		return 0
	end
end

act.player.newPlayer = function(x, y, owner)
	players[#players + 1] = {
		x = x,
		y = y,
		owner = owner,
		direction = 1,
		health = 1000,
		maxHealth = 1000,
		cooldown = {
			move = 0,
			shoot = 0,
			iframe = 0
		},
		control = {
			moveUp = false,
			moveDown = false,
			moveLeft = false,
			moveRight = false,
			buster = false,
			chip = false,
			custom = false
		}
	}
end

act.projectile.newProjectile = function(x, y, owner)
	projectiles[#projectiles + 1] = {
		x = x,
		y = y,
		owner = owner,
		speed = 0.25,
		direction = 1,
		penetrating = false,
		time = 50,
		damage = 40,
		damageTime = 2
	}
end

for y = 1, 3 do
	for x = 1, 6 do
		act.stage.newPanel(x, y, "normal")
	end
end
act.player.newPlayer(2, 2, 1)
act.player.newPlayer(5, 2, 2)

local render = function()
	--term.clear()
	local buffer, im = {}
	local sx, sy
	for k,v in pairs(projectiles) do
		sx = math.floor((v.x - 1) * stage.panelWidth  + 4 + stage.scrollX)
		sy = math.floor((v.y - 1) * stage.panelHeight + 1 + stage.scrollY)
		if sx >= -1 and sx <= scr_x then
			buffer[#buffer + 1] = {
				colorSwap(images.cannon, {["f"] = " "}),
				sx,
				sy
			}
		end
	end
	for i = 1, #players do
		if players[i].cooldown.iframe == 0 or (FRAME % 2 == 0) then
			sx = (players[i].x - 1) * stage.panelWidth  + 3 + stage.scrollX
			sy = (players[i].y - 1) * stage.panelHeight - 1 + stage.scrollY
			buffer[#buffer + 1] = {
				colorSwap(images.player, {["f"] = " "}),
				sx,
				sy
			}
		end
	end
	for y = #stage.panels, 1, -1 do
		for x = 1, #stage.panels[y] do
			im = images.panel[stage.panels[y][x].panelType]
			if stage.panels[y][x].owner == 2 then
				im = colorSwap(im, {e = "b"})
			end
			if act.stage.getDamage(x, y) > 0 then
				im = colorSwap(im, {["7"] = "4", ["8"] = "4"})
			end
			buffer[#buffer + 1] = {
				im,
				(x - 1) * stage.panelWidth  + 2 + stage.scrollX,
				(y - 1) * stage.panelHeight + 2 + stage.scrollY
			}
		end
	end
	buffer[#buffer + 1] = {makeRectangle(scr_x, scr_y, "f", "f", "f"), 1, 1}
	drawImage(colorSwap(merge(table.unpack(buffer)), {[" "] = "f"}), 1, 1)
	term.setCursorPos(1,1)
	term.write(players[you].health)
	term.setCursorPos(scr_x - 3,1)
	term.write(players[2].health)
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
	for k,v in pairs(control) do
		players[you].control[k] = keysDown[v] or false
	end
end

local checkIfWalkable = function(x, y, p)
	if stage.panels[y] then
		if stage.panels[y][x] then
			if stage.panels[y][x].crackedLevel < 2 then
				if (not stage.panels[y][x].reserved) or stage.panels[y][x].reserved == p then
					if stage.panels[y][x].owner == p or stage.panels[y][x].owner == 0 then
						return true
					end
				end
			end
		end
	end
	return false
end

local movePlayers = function()
	local xmove, ymove, p
	for i = 1, #players do
		xmove, ymove = 0, 0
		p = players[i]
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
			if (xmove ~= 0 or ymove ~= 0) and checkIfWalkable(p.x + xmove, p.y + ymove, p.owner) then
				p.x = p.x + xmove
				p.y = p.y + ymove
				p.cooldown.move = 4
			end
		end
	end
end

local reduceCooldowns = function()
	for i = 1, #players do
		for k,v in pairs(players[i].cooldown) do
			players[i].cooldown[k] = math.max(0, v - 1)
		end
	end
	for y = 1, #stage.panels do
		for x = 1, #stage.panels[y] do

			for owner, damageData in pairs(stage.panels[y][x].damage) do
				stage.panels[y][x].damage[owner].time = math.max(0, damageData.time - 1)
				if damageData.time == 0 then
					stage.panels[y][x].damage[owner] = nil
				end
			end

		end
	end
end

local getInput = function()
	local evt
	while true do
		evt = {os.pullEvent()}
		if evt[1] == "key" then
			keysDown[evt[2]] = true
		elseif evt[1] == "key_up" then
			keysDown[evt[2]] = nil
		elseif evt[1] == "mouse_click" or evt[1] == "mouse_drag" then
			miceDown[evt[2]] = {evt[3], evt[4]}
		elseif evt[1] == "mouse_up" then
			miceDown[evt[2]] = nil
		end
	end
end

local round = function(num)
	return math.floor(0.5 + num)
end

local checkPlayerAtPos = function(x, y, ignoreThisOne)
	for i = 1, #players do
		if i ~= ignoreThisOne then
			if players[i].x == x and players[i].y == y then
				return i
			end
		end
	end
end

local runGame = function()
	while true do
		FRAME = FRAME + 1
		getControls()

		for id, proj in pairs(projectiles) do
			proj.x = proj.x + proj.speed * proj.direction
			proj.time = math.max(0, proj.time - 1)
			if proj.time == 0 then
				projectiles[id] = nil
			else
				local projX, projY = round(proj.x), round(proj.y)
				act.stage.setDamage(
					projX,
					projY,
					proj.damage,
					proj.owner,
					proj.damageTime
				)
				local cPlayer = checkPlayerAtPos(projX, projY, proj.owner)
				if (not proj.penetrating) and cPlayer then
					if players[cPlayer].cooldown.iframe == 0 then
						projectiles[id] = nil
					end
				end
			end
		end

		for y = 1, #stage.panels do
			for x = 1, #stage.panels[y] do
				stage.panels[y][x].reserved = false
			end
		end

		for id, player in pairs(players) do
			stage.panels[player.y][player.x].reserved = id
			local dmg = act.stage.getDamage(player.x, player.y, player.owner)
			if player.cooldown.iframe == 0 and dmg > 0 then
				player.health = player.health - dmg
				player.cooldown.iframe = 32
			elseif player.control.buster and player.cooldown.shoot == 0 then
				act.projectile.newProjectile(player.x, player.y, player.owner)
				player.cooldown.shoot = 8
				player.cooldown.move = 5
			end
		end

		reduceCooldowns()
		movePlayers()

		render()
		sleep(0.05)
	end
end

parallel.waitForAny(getInput, runGame)
