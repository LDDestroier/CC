local scr_x, scr_y = term.getSize()
local keysDown, miceDown = {}, {}

local players = {}
local projectiles = {}
local you = 1
local yourID = os.getComputerID()

local gameID = "test-game"
local waitingForGame = false
local isHost = true
local channel = 1024

local FRAME = 0
local useSkynet = false -- will be added much later

local stage = {
	panels = {},
	damage = {},
	panelWidth = 6,
	panelHeight = 2,
	scrollX = 0,
	scrollY = 6
}

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

local modem
local getModem = function()
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

local transmit = function(msg)
	if useSkynet then
		-- add skynet stuff later
	else
		modem.transmit(channel, channel, msg)
	end
end

local receive = function()
	if useSkynet then
		-- again, skynet is for later, keep your pants on
	else
		local evt = {os.pullEvent("modem_message")}
		return evt[5]
	end
end

local images = {
	panel = {
		normal = {{"","",""},{"eeeee7","e78877","eeeeee"},{"77777e","78888e","eeeeee"}},
	},
	player = {
		["6"] = {{"","  ","","  ",""},{"f5ff","4  4","66ff","2  2","affa"},{"5f55","4  f","6f66","2  2"," aaf"}},
		["7"] = {{"","  ","","","  "},{"5555","  f4","ffff","2f22"," fa "},{"5ff5","  4f","6666"," 2ff"," af "}},
	},
	cannon = {{"",""},{"ff","77"},{"77","  ",}},
	buster = {{""},{"f4"},{"4f"}}
}

local act = {stage = {}, player = {}, projectile = {}}
act.stage.newPanel = function(x, y, panelType, owner)
	stage.panels[y] = stage.panels[y] or {}
	stage.panels[y][x] = {
		panelType = panelType,
		reserved = false,
		crackedLevel = 0,	-- 0 is okay, 1 is cracked, 2 is broken
		owner = owner or (x > 3 and 2 or 1),
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
act.stage.setDamage = function(x, y, damage, owner, time, noFlinch)
	x, y = round(x), round(y)
	stage.damage[y] = stage.damage[y] or {}
	stage.damage[y][x] = stage.damage[y][x] or {}
	stage.damage[y][x][owner] = {
		owner = owner,
		time = time,
		damage = damage,
		flinching = not noFlinch
	}
end
act.stage.getDamage = function(x, y, owner)
	local totalDamage = 0
	local flinching = false
	x, y = round(x), round(y)
	if stage.damage[y] then
		if stage.damage[y][x] then
			for k, v in pairs(stage.damage[y][x]) do
				if k ~= owner and v.damage then
					totalDamage = totalDamage + v.damage
					flinching = flinching or v.flinching
				end
			end
		end
	end
	return totalDamage, flinching
end

act.player.newPlayer = function(x, y, owner, direction, image)
	players[#players + 1] = {
		x = x,
		y = y,
		owner = owner,
		type = "player",
		direction = direction or 1,
		health = 1000,
		maxHealth = 1000,
		image = image,
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
		},
		chipQueue = {
			"minibomb",
			"lilbomb",
			"crossbomb",
			"boomer",
			"cannon",
			"sword",
			"widesword",
			"longsword",
			"lifesword"
		}
	}
end

local checkPlayerAtPos = function(x, y, ignoreThisOne)
	x, y = round(x), round(y)
	for id, player in pairs(players) do
		if id ~= ignoreThisOne then
			if player.x == x and player.y == y then
				return id
			end
		end
	end
end

local chips = {

	buster = {
		info = {
			name = "MegaBuster",
			description = "Fires a weak shot forwards!",
			cooldown = {
				shoot = 4,
				move = 2
			}
		},
		logic = function(info)
			info.x = info.x + (2 / stage.panelWidth) * info.direction
			info.y = info.y
			act.stage.setDamage(info.x, info.y, 1, info.owner, 1, true)

			-- delete projectile if collide with player
			local hasStruck = false
			local cPlayer = checkPlayerAtPos(info.x, info.y, info.owner)
			if cPlayer then
				if players[cPlayer].cooldown.iframe == 0 and players[cPlayer].owner ~= info.owner then
					hasStruck = cPlayer
				end
			end
			if info.frame > 50 or hasStruck then
				return false
			else
				return true, {{images.buster, info.x, info.y}}
			end
		end
	},

	cannon = {
		info = {
			name = "Cannon",
			description = "Fires a shot forwards!",
			cooldown = {
				shoot = 10,
				move = 5
			}
		},
		logic = function(info)
			info.x = info.x + (2 / stage.panelWidth) * info.direction
			info.y = info.y
			act.stage.setDamage(info.x, info.y, 40, info.owner, 2)

			-- delete projectile if collide with player
			local hasStruck = false
			local cPlayer = checkPlayerAtPos(info.x, info.y, info.owner)
			if cPlayer then
				if players[cPlayer].cooldown.iframe == 0 and players[cPlayer].owner ~= info.owner then
					hasStruck = cPlayer
				end
			end
			if info.frame > 50 or hasStruck then
				return false
			else
				return true, {{images.cannon, info.x, info.y}}
			end
		end
	},

	sword = {
		info = {
			name = "Sword",
			description = "Slash forwards 1 panel!",
			cooldown = {
				shoot = 8,
				move = 5
			}
		},
		logic = function(info)

			act.stage.setDamage(info.x + info.direction, info.y, 80, info.owner, 4)

			return false
		end
	},

	longsword = {
		info = {
			name = "LongSword",
			description = "Slash forwards 2 panels!",
			cooldown = {
				shoot = 8,
				move = 5
			}
		},
		logic = function(info)

			act.stage.setDamage(info.x + info.direction,     info.y, 80, info.owner, 4)
			act.stage.setDamage(info.x + info.direction * 2, info.y, 80, info.owner, 4)

			return false
		end
	},

	widesword = {
		info = {
			name = "WideSword",
			description = "Slash column in front!",
			cooldown = {
				shoot = 8,
				move = 5
			}
		},
		logic = function(info)

			act.stage.setDamage(info.x + info.direction, info.y - 1, 80, info.owner, 4)
			act.stage.setDamage(info.x + info.direction, info.y,     80, info.owner, 4)
			act.stage.setDamage(info.x + info.direction, info.y + 1, 80, info.owner, 4)

			return false
		end
	},

	lifesword = {
		info = {
			name = "LifeSword",
			description = "Slash 2x3 area with devastating power!",
			cooldown = {
				shoot = 10,
				move = 5
			}
		},
		logic = function(info)

			act.stage.setDamage(info.x + info.direction,     info.y - 1, 400, info.owner, 4)
			act.stage.setDamage(info.x + info.direction * 2, info.y - 1, 400, info.owner, 4)
			act.stage.setDamage(info.x + info.direction,     info.y,     400, info.owner, 4)
			act.stage.setDamage(info.x + info.direction * 2, info.y,     400, info.owner, 4)
			act.stage.setDamage(info.x + info.direction,     info.y + 1, 400, info.owner, 4)
			act.stage.setDamage(info.x + info.direction * 2, info.y + 1, 400, info.owner, 4)

			return false
		end
	},

	boomer = {
		info = {
			name = "Boomer",
			description = "Boomerang that orbits stage!",
			cooldown = {
				shoot = 10,
				move = 5
			}
		},
		logic = function(info)
			if info.direction == 1 then
				if info.frame == 0 then
					info.x = 0
					info.y = 3
				end
				if info.y > 1 then
					if info.x <= 6 then
						info.x = info.x + (2 / stage.panelWidth)
					else
						info.y = info.y - (2 / stage.panelHeight)
					end
				elseif info.x > 0 then
					info.x = info.x - (2 / stage.panelWidth)
				else
					return false
				end
			elseif info.direction == -1 then
				if info.frame == 0 then
					info.x = 7
					info.y = 3
				end
				if info.y > 1 then
					if info.x > 1 then
						info.x = info.x - (2 / stage.panelWidth)
					else
						info.y = info.y - (2 / stage.panelHeight)
					end
				elseif info.x <= 7 then
					info.x = info.x + (2 / stage.panelWidth)
				else
					return false
				end
			end
			act.stage.setDamage(info.x, info.y, 60, info.owner, 2, false)
			return true, {{images.cannon, info.x, info.y}}
		end
	},

	minibomb = {
		info = {
			name = "MiniBomb",
			description = "Lob a small bomb 2 panels forward!",
			cooldown = {
				shoot = 10,
				move = 5
			}
		},
		logic = function(info)
			local maxDist = 3
			local maxFrames = 10
			local parabola = math.sin((math.pi / maxFrames) * info.frame) * 2
			if parabola < 0.1 and info.frame > 3 then
				act.stage.setDamage(info.x, info.y, 50, info.owner, 2, false)
				return false
			else
				info.x = info.x + (maxDist / maxFrames) * info.direction
			end
			return true, {{images.cannon, info.x, info.y - parabola}}
		end
	},

	lilbomb = {
		info = {
			name = "LilBomb",
			description = "Lob a little bomb 2 panels forward!",
			cooldown = {
				shoot = 10,
				move = 5
			}
		},
		logic = function(info)
			local maxDist = 3
			local maxFrames = 10
			local parabola = math.sin((math.pi / maxFrames) * info.frame) * 2
			if parabola < 0.1 and info.frame > 3 then
				act.stage.setDamage(info.x, info.y - 1, 50, info.owner, 2, false)
				act.stage.setDamage(info.x, info.y,     50, info.owner, 2, false)
				act.stage.setDamage(info.x, info.y + 1, 50, info.owner, 2, false)
				return false
			else
				info.x = info.x + (maxDist / maxFrames) * info.direction
			end
			return true, {{images.cannon, info.x, info.y - parabola}}
		end
	},

	crossbomb = {
		info = {
			name = "CrossBomb",
			description = "Lob a cross-shaped bomb 2 panels forward!",
			cooldown = {
				shoot = 10,
				move = 5
			}
		},
		logic = function(info)
			local maxDist = 3
			local maxFrames = 10
			local parabola = math.sin((math.pi / maxFrames) * info.frame) * 2
			if parabola < 0.1 and info.frame > 3 then
				act.stage.setDamage(info.x,     info.y - 1, 50, info.owner, 2, false)
				act.stage.setDamage(info.x,     info.y,     50, info.owner, 2, false)
				act.stage.setDamage(info.x,     info.y + 1, 50, info.owner, 2, false)
				act.stage.setDamage(info.x - 1, info.y,     50, info.owner, 2, false)
				act.stage.setDamage(info.x + 1, info.y,     50, info.owner, 2, false)
				return false
			else
				info.x = info.x + (maxDist / maxFrames) * info.direction
			end
			return true, {{images.cannon, info.x, info.y - parabola}}
		end
	}

}

act.projectile.newProjectile = function(x, y, player, chipType)
	local id = #projectiles + 1
	projectiles[id] = {
		x = x,
		y = y,
		type = "projectile",
		initX = x,
		initY = y,
		id = id,
		owner = player.owner,
		player = player,
		direction = player.direction,
		frame = 0,
		chipType = chipType
	}
end

for y = 1, 3 do
	for x = 1, 6 do
		act.stage.newPanel(x, y, "normal")
	end
end

act.player.newPlayer(2, 2, 1, 1, "6")
act.player.newPlayer(5, 2, 2, -1, "7")

local render = function()
	local buffer, im = {}
	local sx, sy
	local sortedList = {}
	for k,v in pairs(projectiles) do
		sortedList[#sortedList+1] = v
	end
	for k,v in pairs(players) do
		sortedList[#sortedList+1] = v
	end
	table.sort(sortedList, function(a,b) return a.y >= b.y end)
	for k,v in pairs(sortedList) do
		if v.type == "player" then
			if v.cooldown.iframe == 0 or (FRAME % 2 == 0) then
				sx = (v.x - 1) * stage.panelWidth  + 3 + stage.scrollX
				sy = (v.y - 1) * stage.panelHeight - 1 + stage.scrollY
				buffer[#buffer + 1] = {
					colorSwap(images.player[v.image], {["f"] = " "}),
					sx,
					sy
				}
			end
		elseif v.type == "projectile" then
			sx = math.floor((v.x - 1) * stage.panelWidth  + 4 + stage.scrollX)
			sy = math.floor((v.y - 1) * stage.panelHeight + 1 + stage.scrollY)
			if sx >= -1 and sx <= scr_x and v.imageData then

				for kk, imd in pairs(v.imageData) do
					buffer[#buffer + 1] = {
						colorSwap(imd[1], {["f"] = " "}),
						math.floor((imd[2] - 1) * stage.panelWidth  + 4 + stage.scrollX),
						math.floor((imd[3] - 1) * stage.panelHeight + 1 + stage.scrollY)
					}
				end

			end
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

	if chips[players[you].chipQueue[1]] then
		term.setCursorPos(1, scr_y)
		term.write(chips[players[you].chipQueue[1]].info.name)
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
	term.setCursorPos(1, scr_y - 1)
	term.write("Frame: " .. FRAME .. ", isHost = " .. tostring(isHost) .. ", you = " .. tostring(you))
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
					if stage.panels[y][x].owner == players[p].owner or stage.panels[y][x].owner == 0 then
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
			if (xmove ~= 0 or ymove ~= 0) and checkIfWalkable(p.x + xmove, p.y + ymove, i) then
				p.x = p.x + xmove
				p.y = p.y + ymove
				p.cooldown.move = 3
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

local runGame = function()
	while true do
		FRAME = FRAME + 1

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
				stage.panels[player.y][player.x].reserved = id
				local dmg, flinching = act.stage.getDamage(player.x, player.y, player.owner)
				if player.cooldown.iframe == 0 and dmg > 0 then
					player.health = player.health - dmg
					if player.health <= 0 then
						table.remove(players, id)
					elseif flinching then
						player.cooldown.iframe = 16
						player.cooldown.move = 8
						player.cooldown.shoot = 6
					end
				elseif player.cooldown.shoot == 0 then
					if player.control.chip then
						if player.chipQueue[1] then
							if chips[player.chipQueue[1]] then
								act.projectile.newProjectile(player.x, player.y, player, player.chipQueue[1])
								for k,v in pairs(chips[player.chipQueue[1]].info.cooldown or {}) do
									player.cooldown[k] = v
								end
								table.remove(player.chipQueue, 1)
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
			reduceCooldowns()
			movePlayers()
			transmit({
				gameID = gameID,
				command = "get_state",
				players = players,
				projectiles = projectiles,
				stage = stage,
				id = id
			})
		else
			getControls()
			transmit({
				gameID = gameID,
				command = "set_controls",
				id = yourID,
				pID = you,
				control = players[you].control
			})
		end

		render()
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
				players[msg.pID].control = msg.control
			end
		else
			if msg.command == "get_state" then
				players = msg.players
				projectiles = msg.projectiles
				stage.panels = msg.stage.panels
				stage.damage = msg.stage.damage
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
	transmit({
		gameID = gameID,
		command = "find_game",
		respond = false,
		id = yourID,
		time = time,
	})
	local msg
	waitingForGame = true
	repeat
		msg = receive()
	until interpretNetMessage(msg)
	transmit({
		gameID = gameID,
		command = "find_game",
		respond = true,
		id = yourID,
		time = isHost and math.huge or -math.huge,
	})
	waitingForGame = false
	parallel.waitForAny(getInput, runGame, networking)
end

startGame()
