--[[

   ,--,
,---.'|
|   | :        ,---,     ,-.----.       ,---,   .--.--.          ,----,
:   : |      .'  .' `\   \    /  \   ,`--.' |  /  /    '.      .'   .' \
|   ' :    ,---.'     \  ;   :    \  |   :  : |  :  /`. /    ,----,'    |
;   ; '    |   |  .`\  | |   | .\ :  :   |  ' ;  |  |--`     |    :  .  ;
'   | |__  :   : |  '  | .   : |: |  |   :  | |  :  ;_       ;    |.'  /
|   | :.'| |   ' '  ;  : |   |  \ :  '   '  ;  \  \    `.    `----'/  ;
'   :    ; '   | ;  .  | |   : .  /  |   |  |   `----.   \     /  ;  /
|   |  ./  |   | :  |  ' ;   | |  \  '   :  ;   __ \  \  |    ;  /  /-,
;   : ;    '   : | /  ;  |   | ;\  \ |   |  '  /  /`--'  /   /  /  /.`|
|   ,/     |   | '` ,/   :   ' | \.' '   :  | '--'.     /  ./__;      :
'---'      ;   :  .'     :   : :-'   ;   |.'    `--'---'   |   :    .'
           |   ,.'       |   |.'     '---'                 ;   | .'
           '---'         `---'                             `---'

LDRIS 2 (Work in Progress)

Current features:
	+ Legitimate SRS rotation!
	+ Line clearing! Crazy!
	+ 7bag randomization!
	+ Decent fucking controls!
	+ Ghost piece!
	+ Piece holding!
	+ Piece queue! It's even animated!

To-do:
	+ Add score, and let lineclears and piece dropping add to it
	+ Add an actual menu, and not that shit LDRIS 1 had
	+ Multiplayer, as well as an implementation of garbage
	+ Cheese race mode
	+ Change color palletes so that the ghost piece isn't the color of dirt
	+ Add in-game menu for changing controls (some people can actually tolerate guideline)
--]]


local scr_x, scr_y = term.getSize()

-- client config can be changed however you please
local clientConfig = {
	controls = {
		rotate_left = keys.z,		-- by left, I mean counter-clockwise
		rotate_right = keys.x,		-- by right, I mean clockwise
		move_left = keys.left,
		move_right = keys.right,
		soft_drop = keys.down,
		hard_drop = keys.up,
		sonic_drop = keys.space,
		hold = keys.leftShift,
		pause = keys.p,
		restart = keys.r,
		open_chat = keys.t,
		quit = keys.q,
	},
	soft_drop_multiplier = 4.0,		-- (SDF) the factor in which soft dropping effects the gravity
	move_repeat_delay = 0.25,		-- (DAS) amount of time you must be holding the movement keys for it to start repeatedly moving (seconds)
	move_repeat_interval = 0.05,	-- (ARR) speed at which the pieces move when holding the movement keys (seconds per tick)
	appearance_delay = 0,			-- (ARE) amount of seconds it will take for the next piece to arrive after the current one locks into place
	lock_delay = 0.5,				-- (Lock Delay) amount of seconds it will take for a resting mino to lock into placed
	queue_length = 5,				-- amount of pieces visible in the queue (limited by size of UI)
}

-- ideally, only clients with IDENTICAL game configs should face one another
local gameConfig = {
	minos = {},					-- list of all the minos (pieces) that will spawn into the board
	kickTables = {},			-- list of all kick tables for pieces
	currentKickTable = "SRS",	-- current kick table
	randomBag = "singlebag",	-- current pseudorandom number generator
								-- "singlebag" = normal tetris guideline random
								-- "doublebag" = doubled bag size
								-- "random" = using math.random
	board_width = 11,			-- width of play area
	board_height = 40,			-- height of play area
	board_height_visible = 20,	-- height of play area that will render on screen (anchored to bottom)
	spin_mode = 1,				-- 1 = allows T-spins
								-- 2 = allows J/L-spins
								-- 3 = allows ALL SPINS! Similar to STUPID mode in tetr.io
	can_rotate = true,			-- if false, will disallow ALL piece rotation (meme mode)
	startingGravity = 0.15,		-- gravity per tick for minos
	lock_move_limit = 30,		-- amount of moves a mino can do after descending below its lowest point yet traversed
								-- used as a method of preventing stalling -- set it to math.huge for infinite
}

_WRITE_TO_DEBUG_MONITOR = true

local cospc_debuglog = function(header, text)
	if _WRITE_TO_DEBUG_MONITOR then
		if ccemux then
			ccemux.attach("right", "monitor")
			local t = term.redirect(peripheral.wrap("right"))
			if text == 0 then
				term.clear()
				term.setCursorPos(1, 1)
			else
				term.setTextColor(colors.yellow)
				term.write(header or "SYS")
				term.setTextColor(colors.white)
				print(": " .. text)
			end
			term.redirect(t)
		end
	end	
end

local switch = function(check)
    return function(cases)
        if type(cases[check]) == "function" then
            return cases[check]()
        elseif type(cases["default"] == "function") then
            return cases["default"]()
        end
    end
end

local roundToPlaces = function(number, places)
	return math.floor(number * 10^places) / (10^places)
end

-- current state of the game; can be used to perfectly recreate the current scene of a game
-- that includes board and mino objects, bitch
-- gameState = {}

--[[
	(later, I'll probably store mino data in a separate file)
	spinID:	1 = considered a "T" piece, can be spun
			2 = considered a "J" or "L" piece, can be spun if that's allowed
			3 = considered every other piece, can be spun if STUPID mode is on
]]
do	-- define minos
	gameConfig.minos[1] = {
		shape = {
			"    ",
			"@@@@",
			"    ",
			"    ",
		},
		spinID = 3,
		color = "3",
		name = "I",
		kickID = 2,
	}
	gameConfig.minos[2] = {
		shape = {
			" @ ",
			"@@@",
			"    ",
		},
		spinID = 1,
		color = "a",
		name = "I",
		kickID = 1,
	}
	gameConfig.minos[3] = {
		shape = {
			"  @",
			"@@@",
			"   ",
		},
		spinID = 2,
		color = "1",
		name = "L",
		kickID = 1,
	}
	gameConfig.minos[4] = {
		shape = {
			"@  ",
			"@@@",
			"   ",
		},
		spinID = 2,
		color = "b",
		name = "J",
		kickID = 1,
	}
	gameConfig.minos[5] = {
		shape = {
			"@@",
			"@@",
		},
		spinID = 3,
		color = "4",
		name = "O",
		kickID = 2,
		spawnOffsetX = 1,
	}
	gameConfig.minos[6] = {
		shape = {
			" @@",
			"@@ ",
			"   ",
		},
		spinID = 2,
		color = "5",
		name = "S",
		kickID = 1,
	}
	gameConfig.minos[7] = {
		shape = {
			"@@ ",
			" @@",
			"   ",
		},
		spinID = 2,
		color = "e",
		name = "Z",
		kickID = 1,
	}
end

do	-- define SRS kick table
	gameConfig.kickTables["SRS"] = {
		[1] = {},	-- used on J, L, S, T, Z tetraminos
		[2] = {},	-- used on I tetraminos
	}
	local srs = gameConfig.kickTables["SRS"]
	srs[1] = {
		["01"] = {{ 0, 0}, {-1, 0}, {-1, 1}, { 0,-2}, {-1,-2}},
		["10"] = {{ 0, 0}, { 1, 0}, { 1,-1}, { 0, 2}, { 1, 2}},
		["12"] = {{ 0, 0}, { 1, 0}, { 1,-1}, { 0, 2}, { 1, 2}},
		["21"] = {{ 0, 0}, {-1, 0}, {-1, 1}, { 0,-2}, {-1,-2}},
		["23"] = {{ 0, 0}, { 1, 0}, { 1, 1}, { 0,-2}, { 1,-2}},
		["32"] = {{ 0, 0}, {-1, 0}, {-1,-1}, { 0, 2}, {-1, 2}},
		["30"] = {{ 0, 0}, {-1, 0}, {-1,-1}, { 0, 2}, {-1, 2}},
		["03"] = {{ 0, 0}, { 1, 0}, { 1, 1}, { 0,-2}, { 1,-2}},
		["02"] = {{ 0, 0}, { 0, 1}, { 1, 1}, {-1, 1}, { 1, 0}, {-1, 0}},
		["13"] = {{ 0, 0}, { 1, 0}, { 1, 2}, { 1, 1}, { 0, 2}, { 0, 1}},
		["20"] = {{ 0, 0}, { 0,-1}, {-1,-1}, { 1,-1}, {-1, 0}, { 1, 0}},
		["31"] = {{ 0, 0}, {-1, 0}, {-1, 2}, {-1, 1}, { 0, 2}, { 0, 1}},
	}
	srs[2] = {
		["01"] = {{ 0, 0}, {-2, 0}, { 1, 0}, {-2,-1}, { 1, 2}},
		["10"] = {{ 0, 0}, { 2, 0}, {-1, 0}, { 2, 1}, {-1,-2}},
		["12"] = {{ 0, 0}, {-1, 0}, { 2, 0}, {-1, 2}, { 2,-1}},
		["21"] = {{ 0, 0}, { 1, 0}, {-2, 0}, { 1,-2}, {-2, 1}},
		["23"] = {{ 0, 0}, { 2, 0}, {-1, 0}, { 2, 1}, {-1,-2}},
		["32"] = {{ 0, 0}, {-2, 0}, { 1, 0}, {-2,-1}, { 1, 2}},
		["30"] = {{ 0, 0}, { 1, 0}, {-2, 0}, { 1,-2}, {-2, 1}},
		["03"] = {{ 0, 0}, {-1, 0}, { 2, 0}, {-1, 2}, { 2,-1}},
		["02"] = {{ 0, 0}},
		["13"] = {{ 0, 0}},
		["20"] = {{ 0, 0}},
		["31"] = {{ 0, 0}},
	}
end

-- returns a number that's capped between 'min' and 'max', inclusively
local function between(number, min, max)
	return math.min(math.max(number, min), max)
end

-- image-related functions (from NFTE)
local loadImageDataNFT = function(image, background) -- string image
	local output = {{},{},{}} -- char, text, back
	local y = 1
	background = (background or "f"):sub(1,1)
	local text, back = "f", background
	local doSkip, c1, c2 = false
	local tchar = string.char(31)	-- for text colors
	local bchar = string.char(30)	-- for background colors
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

-- draws an image with the topleft corner at (x, y), with transparency
local drawImageTransparent = function(image, x, y, terminal)
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

-- copies the contents of a table
table.copy = function(tbl)
	local output = {}
	for k,v in pairs(tbl) do
		output[k] = type(v) == "table" and table.copy(v) or v
	end
	return output
end
local stringrep = string.rep

-- generates a new board, on which polyominos can be placed and interact
local makeNewBoard = function(x, y, width, height, blankColor)
	local board = {}
	board.contents = {}
	board.height = height or gameConfig.board_height
	board.width = width or gameConfig.board_width
	board.x = x
	board.y = y
	board.blankColor = blankColor or "7"			-- color if no minos are in that spot
	board.transparentColor = "f"	-- color if the board tries to render where there is no board
	board.garbageColor = "8"
	board.visibleHeight = height and math.floor(height / 2) or gameConfig.board_height_visible
	board.alignFromBottom = false

	for y = 1, board.height do
		board.contents[y] = stringrep(board.blankColor, width)
	end
	
	board.Write = function(x, y, color)
		x = math.floor(x)
		y = math.floor(y)
		board.contents[y] = board.contents[y]:sub(1, x - 1) .. color .. board.contents[y]:sub(x + 1)
	end

	board.AddGarbage = function(amount)
		local changePercent = 00	-- higher the percent, the more likely it is that subsequent rows of garbage will have a different hole
		local holeX = math.random(1, board.width)
		for y = amount, board.height do
			board.contents[y - amount + 1] = board.contents[y]
		end
		for y = board.height, board.height - amount + 1, -1 do
			board.contents[y] = stringrep(board.garbageColor, holeX - 1) .. board.blankColor .. stringrep(board.garbageColor, board.width - holeX)
			if math.random(1, 100) <= changePercent then
				holeX = math.random(1, board.width)
			end
		end
	end

	board.Clear = function(color)
		color = color or board.blankColor
		for y = 1, board.height do
			board.contents[y] = stringrep(color, board.width)
		end
	end

	-- used for sending board data over the network
	board.serialize = function(includeInit)
		return textutils.serialize({
			x = includeInit and board.x or nil,
			y = includeInit and board.y or nil,
			height = includeInit and board.height or nil,
			width = includeInit and board.width or nil,
			blankColor = includeInit and board.blankColor or nil,
			visibleHeight = board.visibleHeight or nil,
			contents = board.contents
		})
	end

	board.Render = function(...)	-- takes list of minos that it will render atop the board
		local charLine1 = stringrep("\131", board.width)
		local charLine2 = stringrep("\143", board.width)
		local transparentLine = stringrep(board.transparentColor, board.width)
		local colorLine1, colorLine2, colorLine3
		local minoColor1, minoColor2, minoColor3
		local minos = {...}
		local mino, tY

		if board.alignFromBottom then

			tY = board.y + math.floor((board.height - board.visibleHeight) * (2 / 3)) - 2

			for y = board.height, 1 + (board.height - board.visibleHeight), -3 do
				colorLine1, colorLine2, colorLine3 = "", "", ""
				for x = 1, board.width do

					minoColor1, minoColor2, minoColor3 = nil, nil, nil
					for i = 1, #minos do
						mino = minos[i]
						if mino.visible then
							if mino.CheckSolid(x, y - 0, true) then
								minoColor1 = mino.color
							end
							if mino.CheckSolid(x, y - 1, true) then
								minoColor2 = mino.color
							end
							if mino.CheckSolid(x, y - 2, true) then
								minoColor3 = mino.color
							end
						end
					end

					colorLine1 = colorLine1 .. (minoColor1 or ((board.contents[y - 0] and board.contents[y - 0]:sub(x, x)) or board.blankColor))
					colorLine2 = colorLine2 .. (minoColor2 or ((board.contents[y - 1] and board.contents[y - 1]:sub(x, x)) or board.blankColor))
					colorLine3 = colorLine3 .. (minoColor3 or ((board.contents[y - 2] and board.contents[y - 2]:sub(x, x)) or board.blankColor))

				end

				if (y - 0) <= (board.height - board.visibleHeight) then
					colorLine1 = transparentLine
				end
				if (y - 1) <= (board.height - board.visibleHeight) then
					colorLine2 = transparentLine
				end
				if (y - 2) <= (board.height - board.visibleHeight) then
					colorLine3 = transparentLine
				end

				term.setCursorPos(board.x, board.y + tY)
				term.blit(charLine1, colorLine2, colorLine1)
				tY = tY - 1
				term.setCursorPos(board.x, board.y + tY)
				term.blit(charLine2, colorLine3, colorLine2)
				tY = tY - 1
			end
		
		else

			tY = board.y

			for y = 1 + (board.height - board.visibleHeight), board.height, 3 do
				colorLine1, colorLine2, colorLine3 = "", "", ""
				for x = 1, board.width do

					minoColor1, minoColor2, minoColor3 = nil, nil, nil
					for i = 1, #minos do
						mino = minos[i]
						if mino.visible then
							if mino.CheckSolid(x, y + 0, true) then
								minoColor1 = mino.color
							end
							if mino.CheckSolid(x, y + 1, true) then
								minoColor2 = mino.color
							end
							if mino.CheckSolid(x, y + 2, true) then
								minoColor3 = mino.color
							end
						end
					end

					colorLine1 = colorLine1 .. (minoColor1 or ((board.contents[y + 0] and board.contents[y + 0]:sub(x, x)) or board.blankColor))
					colorLine2 = colorLine2 .. (minoColor2 or ((board.contents[y + 1] and board.contents[y + 1]:sub(x, x)) or board.blankColor))
					colorLine3 = colorLine3 .. (minoColor3 or ((board.contents[y + 2] and board.contents[y + 2]:sub(x, x)) or board.blankColor))

				end

				if (y + 0) > board.height or (y + 0) <= (board.height - board.visibleHeight) then
					colorLine1 = transparentLine
				end
				if (y + 1) > board.height or (y + 1) <= (board.height - board.visibleHeight) then
					colorLine2 = transparentLine
				end
				if (y + 2) > board.height or (y + 2) <= (board.height - board.visibleHeight) then
					colorLine3 = transparentLine
				end

				term.setCursorPos(board.x, board.y + tY)
				term.blit(charLine2, colorLine1, colorLine2)
				tY = tY + 1
				term.setCursorPos(board.x, board.y + tY)
				term.blit(charLine1, colorLine2, colorLine3)
				tY = tY + 1
				
			end
		end
	end

	return board
end

local makeNewMino = function(minoTable, minoID, board, xPos, yPos, oldeMino)
	local mino = oldeMino or {}
	minoTable = minoTable or gameConfig.minos
	if not minoTable[minoID] then
		error("tried to spawn mino with invalid ID '" .. tostring(minoID) .. "'")
	else
		mino.shape = minoTable[minoID].shape
		mino.spinID = minoTable[minoID].spinID
		mino.kickID = minoTable[minoID].kickID
		mino.color = minoTable[minoID].color
		mino.name = minoTable[minoID].name
	end

	mino.finished = false
	mino.active = true
	mino.spawnTimer = 0
	mino.visible = true
	mino.height = #mino.shape
	mino.width = #mino.shape[1]
	mino.minoID = minoID
	mino.x = xPos
	mino.y = yPos
	mino.xFloat = 0
	mino.yFloat = 0
	mino.board = board
	mino.rotation = 0
	mino.resting = false
	mino.lockTimer = 0
	mino.movesLeft = gameConfig.lock_move_limit
	mino.yHighest = mino.y

	mino.serialize = function(includeInit)
		return textutils.serialize({
			minoID = includeInit and mino.minoID or nil,
			rotation = mino.rotation,
			x = x,
			y = y,
		})
	end

	-- takes absolute position (x, y) on board, and returns true if it exists within the bounds of the board
	local DoesSpotExist = function(x, y)
		return board and (
			x >= 1 and
			x <= board.width and
			y >= 1 and
			y <= board.height
		)
	end
	
	-- checks if the mino is colliding with solid objects on its board, shifted by xMod and/or yMod (default 0)
	-- if doNotCountBorder == true, the border of the board won't be considered as solid
	-- returns true if it IS colliding, and false if it is not
	mino.CheckCollision = function(xMod, yMod, doNotCountBorder, round)
		local cx, cy	-- represents position on board
		round = round or math.floor
		for y = 1, mino.height do
			for x = 1, mino.width do

				cx = round(-1 + x + mino.x + xMod)
				cy = round(-1 + y + mino.y + yMod)
				if DoesSpotExist(cx, cy) then
					if mino.board.contents[cy]:sub(cx, cx) ~= mino.board.blankColor and mino.CheckSolid(x, y) then
						return true
					end
				elseif (not doNotCountBorder) and mino.CheckSolid(x, y) then
					return true
				end

			end
		end
		return false
	end

	-- checks whether or not the (x, y) position of the mino's shape is solid.
	mino.CheckSolid = function(x, y, relativeToBoard)
		if relativeToBoard then
			x = x - mino.x + 1
			y = y - mino.y + 1
		end
		x = math.floor(x)
		y = math.floor(y)
		if y >= 1 and y <= mino.height and x >= 1 and x <= mino.width then
			return mino.shape[y]:sub(x, x) ~= " "	
		else
			return false
		end
	end

	-- direction = 1: clockwise
	-- direction = -1: counter-clockwise
	mino.Rotate = function(direction, expendLockMove)
		local oldShape = table.copy(mino.shape)
		local kickTable = gameConfig.kickTables[gameConfig.currentKickTable]
		local output = {}
		local success = false
		local newRotation = ((mino.rotation + direction + 1) % 4) - 1
		local kickRotTranslate = {
			[-1] = "3",
			[ 0] = "0",
			[ 1] = "1",
			[ 2] = "2",
		}
		if mino.active then
			-- get the specific offset table for the type of rotation based on the mino type
			local kickX, kickY
			local kickRot = kickRotTranslate[mino.rotation] .. kickRotTranslate[newRotation]

			-- translate the mino piece
			for y = 1, mino.width do
				output[y] = ""
				for x = 1, mino.height do
					if direction == -1 then
						output[y] = output[y] .. oldShape[x]:sub(-y, -y)
					elseif direction == 1 then
						output[y] = oldShape[x]:sub(y, y) .. output[y]
					end
				end
			end
			mino.width, mino.height = mino.height, mino.width
			mino.shape = output
			-- it's time to do some floor and wall kicking
			if mino.board and mino.CheckCollision(0, 0) then
				for i = 1, #kickTable[mino.kickID][kickRot] do
					kickX = kickTable[mino.kickID][kickRot][i][1]
					kickY = -kickTable[mino.kickID][kickRot][i][2]
					if not mino.Move(kickX, kickY, false) then
						success = true
						break
					end
				end
			else
				success = true
			end
			if success then
				mino.rotation = newRotation
				mino.height, mino.width = mino.width, mino.height
			else
				mino.shape = oldShape
			end

			if expendLockMove then
				mino.movesLeft = mino.movesLeft - 2
				if mino.movesLeft <= 0 then
					if mino.CheckCollision(0, 1) then
						mino.finished = 1
					end
				else
					mino.lockTimer = clientConfig.lock_delay
				end
			end
		end

		return mino, success
	end

	mino.Move = function(x, y, doSlam, expendLockMove)
		local didSlam
		local didCollide = false
		local didMoveX = true
		local didMoveY = true
		local step, round

		if mino.active then
		
			if doSlam then

				mino.xFloat = mino.xFloat + x
				mino.yFloat = mino.yFloat + y

				-- handle Y position
				if y ~= 0 then
					step = y / math.abs(y)
					round = mino.yFloat > 0 and math.floor or math.ceil
					if mino.CheckCollision(0, step) then
						mino.yFloat = 0
						didMoveY = false
					else
						for iy = step, round(mino.yFloat), step do
							if mino.CheckCollision(0, step) then
								didCollide = true
								mino.yFloat = 0
								break
							else
								didMoveY = true
								mino.y = mino.y + step
								mino.yFloat = mino.yFloat - step
							end
						end
					end
				else
					didMoveY = false
				end

				-- handle x position
				if x ~= 0 then
					step = x / math.abs(x)
					round = mino.xFloat > 0 and math.floor or math.ceil
					if mino.CheckCollision(step, 0) then
						mino.xFloat = 0
						didMoveX = false
					else
						for ix = step, round(mino.xFloat), step do
							if mino.CheckCollision(step, 0) then
								didCollide = true
								mino.xFloat = 0
								break
							else
								didMoveX = true
								mino.x = mino.x + step
								mino.xFloat = mino.xFloat - step
							end
						end
					end
				else
					didMoveX = false
				end
				
			else
				if mino.CheckCollision(x, y) then
					didCollide = true
					didMoveX = false
					didMoveY = false
				else
					mino.x = mino.x + x
					mino.y = mino.y + y
					didCollide = false
					didMoveX = true
					didMoveY = true
				end
			end

			local yHighestDidChange = (mino.y > mino.yHighest)
			mino.yHighest = math.max(mino.yHighest, mino.y)

			if yHighestDidChange then
				mino.movesLeft = gameConfig.lock_move_limit
			end

			if expendLockMove then
				if didMoveX or didMoveY then
					mino.movesLeft = mino.movesLeft - 1
					if mino.movesLeft <= 0 then
						if mino.CheckCollision(0, 1) then
							mino.finished = 1
						end
					else
						mino.lockTimer = clientConfig.lock_delay
					end
				end
			end
		else
			didMoveX = false
			didMoveY = false
		end

		return didCollide, didMoveX, didMoveY, yHighestDidChange
	end

	-- writes the mino to the board
	mino.Write = function()
		if mino.active then
			for y = 1, mino.height do
				for x = 1, mino.width do
					if mino.CheckSolid(x, y, false) then
						mino.board.Write(x + mino.x - 1, y + mino.y - 1, mino.color)
					end
				end
			end
		end
	end

	return mino
end

_G.makeNewMino = makeNewMino

local pseudoRandom = function(gameState)
	return switch(gameConfig.randomBag) {
		["random"] = function()
			return math.random(1, #gameConfig.minos)
		end,
		["singlebag"] = function()
			if #gameState.random_bag == 0 then
				-- repopulate random bag
				for i = 1, #gameConfig.minos do
					if math.random(0, 1) == 0 then
						gameState.random_bag[#gameState.random_bag + 1] = i
					else
						table.insert(gameState.random_bag, 1, i)
					end
				end
			end
			local pick = math.random(1, #gameState.random_bag)
			local output = gameState.random_bag[pick]
			table.remove(gameState.random_bag, pick)
			return output
		end,
		["doublebag"] = function()
			if #gameState.random_bag == 0 then
				for r = 1, 2 do
					-- repopulate random bag
					for i = 1, #gameConfig.minos do
						if math.random(0, 1) == 0 then
							gameState.random_bag[#gameState.random_bag + 1] = i
						else
							table.insert(gameState.random_bag, 1, i)
						end
					end
				end
			end
			local pick = math.random(1, #gameState.random_bag)
			local output = gameState.random_bag[pick]
			table.remove(gameState.random_bag, pick)
			return output
		end
	}
end

local handleLineClears = function(gameState)
	local mino, board = gameState.mino, gameState.board

	-- get list of full lines
	local clearedLines = {lookup = {}}
	for y = 1, board.height do
		if not board.contents[y]:find(board.blankColor) then
			clearedLines[#clearedLines + 1] = y
			clearedLines.lookup[y] = true
		end
	end

	-- clear the lines, baby
	if #clearedLines > 0 then
		local newContents = {}
		local i = board.height
		for y = board.height, 1, -1 do
			if not clearedLines.lookup[y] then
				newContents[i] = board.contents[y]
				i = i - 1
			end
		end
		for y = 1, #clearedLines do
			newContents[y] = stringrep(board.blankColor, board.width)
		end
		gameState.board.contents = newContents
	end

	gameState.linesCleared = gameState.linesCleared + #clearedLines

	return clearedLines

end

local StartGame = function(player_number, native_control, board_xmod, board_ymod)
	board_xmod = board_xmod or 0
	board_ymod = board_ymod or 0
	local gameState = {
		gravity = gameConfig.startingGravity,
		pNum = player_number,
		targetPlayer = 0,
		score = 0,
		antiControlRepeat = {},
		topOut = false,
		canHold = true,
		didHold = false,
		heldPiece = false,
		paused = false,
		queue = {},
		queueMinos = {},
		linesCleared = 0,
		random_bag = {},
		gameTickCount = 0,
		controlTickCount = 0,
		controlsDown = {},		-- 
		incomingGarbage = 0,	-- amount of garbage that will be added to board after non-line-clearing mino placement
		combo = 0,				-- amount of successive line clears
		backToBack = 0,			-- amount of tetris/t-spins comboed
		spinLevel = 0,			-- 0 = no special spin
								-- 1 = mini spin
								-- 2 = Z/S/J/L spin
								-- 3 = T spin
	}
	-- create boards
	-- main gameplay board
	gameState.board = makeNewBoard(
		7 + board_xmod,
		1 + board_ymod,
		gameConfig.board_width, gameConfig.board_height
	)

	-- queue of upcoming minos
	gameState.queueBoard = makeNewBoard(
		gameState.board.x + gameState.board.width + 1,
		gameState.board.y,
		4,
		28
		--gameState.board.height - 12
	)

	-- display of currently held mino
	gameState.holdBoard = makeNewBoard(
		--gameState.board.x + gameState.board.width + 1,
		2 + board_xmod,
		--gameState.board.y + gameState.board.visibleHeight * (1/3),
		1 + board_ymod,
		gameState.queueBoard.width,
		4
	)
	gameState.holdBoard.visibleHeight = 4

	-- indicator of incoming garbage
	gameState.garbageBoard = makeNewBoard(
		gameState.board.x - 1,
		gameState.board.y,
		1,
		gameState.board.visibleHeight,
		"f"
	)
	gameState.garbageBoard.visibleHeight = gameState.garbageBoard.height

	-- populate the queue
	for i = 1, clientConfig.queue_length + 1 do
		gameState.queue[i] = pseudoRandom(gameState)
	end
	for i = 1, clientConfig.queue_length do
		gameState.queueMinos[i] = makeNewMino(nil,
			gameState.queue[i + 1],
			gameState.queueBoard,
			1,
			i * 3 + 12
		)
	end
	gameState.queue.cyclePiece = function()
		local output = gameState.queue[1]
		table.remove(gameState.queue, 1)
		gameState.queue[#gameState.queue + 1] = pseudoRandom(gameState)
		return output
	end
	gameState.mino = {}

	local qmAnim = 0

	local makeDefaultMino = function(gameState)
		local nextPiece
		if gameState.didHold then
			if gameState.heldPiece then
				nextPiece, gameState.heldPiece = gameState.heldPiece, gameState.mino.minoID
			else
				nextPiece, gameState.heldPiece = gameState.queue.cyclePiece(), gameState.mino.minoID
			end
		else
			nextPiece = gameState.queue.cyclePiece()
		end
		return makeNewMino(nil,
			nextPiece,
			gameState.board,
			math.floor(gameState.board.width / 2 - 1) + (gameConfig.minos[nextPiece].spawnOffsetX or 0),
			math.floor(gameConfig.board_height_visible + 1) + (gameConfig.minos[nextPiece].spawnOffsetY or 0),
			gameState.mino
		)
	end

	local calculateGarbage = function(gameState, linesCleared)
		local output = 0
		local lncleartbl = {
			[0] = 0,
			[1] = 0,
			[2] = 1,
			[3] = 2,
			[4] = 4,
			[5] = 5,
			[6] = 6,
			[7] = 7,
			[8] = 8
		}

		if (gameState.spinLevel == 3) or (gameState.spinLevel == 2 and gameConfig.spin_mode >= 2) then
			output = output + linesCleared * 2
		else
			output = output + (lncleartbl[linesCleared] or 0)
		end

		-- add combo bonus
		output = output + math.max(0, math.floor(-1 + gameState.combo / 2))

		return output
	end

	local sendGameEvent = function(eventName, ...)
		if native_control then
			os.queueEvent(eventName, ...)
		end
	end

	gameState.mino = makeDefaultMino(gameState)

	local mino, board = gameState.mino, gameState.board
	local holdBoard, queueBoard, garbageBoard = gameState.holdBoard, gameState.queueBoard, gameState.garbageBoard
	local ghostMino = makeNewMino(nil, mino.minoID, gameState.board, mino.x, mino.y, {})

	local garbageMinoShape = {}
	for i = 1, garbageBoard.height do
		garbageMinoShape[#garbageMinoShape + 1] = "@"
	end

	local garbageMino = makeNewMino({
		[1] = {
			shape = garbageMinoShape,
			color = "e"
		}
	}, 1, garbageBoard, 1, garbageBoard.height + 1)
	
	local keysDown = {}
	local tickDelay = 0.05

	local render = function(drawOtherBoards)
		board.Render(ghostMino, mino)
		if drawOtherBoards then
			holdBoard.Render()
			queueBoard.Render(table.unpack(gameState.queueMinos))
			garbageBoard.Render(garbageMino)
		end
	end

	local tick = function(gameState)
		local didCollide, didMoveX, didMoveY, yHighestDidChange = mino.Move(0, gameState.gravity, true)
		local doCheckStuff = false
		local doAnimateQueue = false
		local doMakeNewMino = false

		qmAnim = math.max(0, qmAnim - 0.8)

		-- position queue minos properly
		for i = 1, #gameState.queueMinos do
			gameState.queueMinos[i].y = (i * 3 + 12) + math.floor(qmAnim)
		end

		if not mino.finished then
			mino.resting = (not didMoveY) and mino.CheckCollision(0, 1)

			if yHighestDidChange then
				mino.movesLeft = gameConfig.lock_move_limit
			end

			if mino.resting then
				mino.lockTimer = mino.lockTimer - tickDelay
				if mino.lockTimer <= 0 then
					mino.finished = 1
				end
			else
				mino.lockTimer = clientConfig.lock_delay
			end
		end

		gameState.mino.spawnTimer = math.max(0, gameState.mino.spawnTimer - tickDelay)
		if gameState.mino.spawnTimer == 0 then
			gameState.mino.active = true
			gameState.mino.visible = true
			ghostMino.active = true
			ghostMino.visible = true
		end

		if mino.finished then
			if mino.finished == 1 then -- piece will lock
				gameState.didHold = false
				gameState.canHold = true
				-- check for top-out due to placing a piece outside the visible area of its board
				if false then	-- I'm doing that later
					
				else
					doAnimateQueue = true
					mino.Write()
					doMakeNewMino = true
					doCheckStuff = true
				end
			elseif mino.finished == 2 then -- piece will attempt hold
				if gameState.canHold then
					gameState.didHold = true
					gameState.canHold = false
					-- I would have used a ternary statement, but didn't
					if gameState.heldPiece then
						doAnimateQueue = false
					else
						doAnimateQueue = true
					end
					-- draw held piece
					gameState.holdBoard.Clear()
					makeNewMino(nil,
						gameState.mino.minoID,
						gameState.holdBoard,
						1, 2, {}
					).Write()

					doMakeNewMino = true
					doCheckStuff = true
				else
					mino.finished = false
				end
			else
				error("I don't know how, but that polyomino's finished!")
			end

			if doMakeNewMino then
				gameState.mino = makeDefaultMino(gameState)
				ghostMino = makeNewMino(nil, mino.minoID, gameState.board, mino.x, mino.y, {})
				if (not gameState.didHold) and (clientConfig.appearance_delay > 0) then
					gameState.mino.spawnTimer = clientConfig.appearance_delay
					gameState.mino.active = false
					gameState.mino.visible = false
					ghostMino.active = false
					ghostMino.visible = false
				end
			end

			if doAnimateQueue then
				table.remove(gameState.queueMinos, 1)
				gameState.queueMinos[#gameState.queueMinos + 1] = makeNewMino(nil,
					gameState.queue[clientConfig.queue_length],
					gameState.queueBoard,
					1,
					(clientConfig.queue_length + 1) * 3 + 12
				)
				qmAnim = 3
			end

			-- if the hold attempt fails (say, you already held a piece), it wouldn't do to check for a top-out or line clears
			if doCheckStuff then
				-- check for top-out due to obstructed mino upon entry
				-- attempt to move mino at most 2 spaces upwards before considering it fully topped out
				gameState.topOut = true
				for i = 0, 2 do
					if mino.CheckCollision(0, 1) then
						mino.y = mino.y - 1
					else
						gameState.topOut = false
						break
					end
				end
				
				local linesCleared = handleLineClears(gameState)
				if #linesCleared == 0 then
					gameState.combo = 0
					gameState.backToBack = 0
				else
					gameState.combo = gameState.combo + 1
					if #linesCleared == 4 or gameState.spinLevel >= 1 then
						gameState.backToBack = gameState.backToBack + 1
					else
						gameState.backToBack = 0
					end
				end
				-- calculate garbage to be sent
				local garbage = calculateGarbage(gameState, #linesCleared)
				if garbage > 0 then
					cospc_debuglog(gameState.pNum, "Doled out " .. garbage .. " lines")
				end
				
				-- send garbage to enemy player
				sendGameEvent("attack", gameState.targetPlayer)

				if doMakeNewMino then
					gameState.spinLevel = 0
				end

			end
		end

		-- debug info
		if native_control then
			term.setCursorPos(2, scr_y - 2)
			term.write("Lines: " .. gameState.linesCleared .. "      ")

			term.setCursorPos(2, scr_y - 1)
			term.write("M=" .. mino.movesLeft .. ", TTL=" .. tostring(mino.lockTimer):sub(1, 4) .. "      ")

			term.setCursorPos(2, scr_y - 0)
			term.write("POS=(" .. mino.x .. ":" .. tostring(mino.xFloat):sub(1, 5) .. ", " .. mino.y .. ":" .. tostring(mino.yFloat):sub(1, 5) .. ")      ")
		end
		
	end

	local checkControl = function(controlName, repeatTime, repeatDelay)
		repeatDelay = repeatDelay or 1
		if native_control then
			if keysDown[clientConfig.controls[controlName]] then
				if not gameState.antiControlRepeat[controlName] then
					if repeatTime then
						return 	keysDown[clientConfig.controls[controlName]] == 1 or
								(
									keysDown[clientConfig.controls[controlName]] >= (repeatTime * (1 / tickDelay)) and (
										repeatDelay and ((keysDown[clientConfig.controls[controlName]] * tickDelay) % repeatDelay == 0) or true
									)
								)
					else
						return keysDown[clientConfig.controls[controlName]] == 1
					end
				end
			else
				return false
			end
		else
			if gameState.controlsDown[controlName] then
				if not gameState.antiControlRepeat[controlName] then
					if repeatTime then
						return 	gameState.controlsDown[controlName] == 1 or
								(
									gameState.controlsDown[controlName] >= (repeatTime * (1 / tickDelay)) and (
										repeatDelay and ((gameState.controlsDown[controlName] * tickDelay) % repeatDelay == 0) or true
									)
								)
					else
						return gameState.controlsDown[controlName] == 1
					end
				end
			else
				return false
			end
		end
	end

	local controlTick = function(gameState, onlyFastActions)
		local dc, dmx, dmy	-- did collide, did move X, did move Y
		local didSlowAction = false
		if (not gameState.paused) and gameState.mino.active then
			if not onlyFastActions then
				if checkControl("move_left", clientConfig.move_repeat_delay, clientConfig.move_repeat_interval) then
					if not mino.finished then
						mino.Move(-1, 0, true, true)
						didSlowAction = true
						gameState.antiControlRepeat["move_left"] = true
					end
				end
				if checkControl("move_right", clientConfig.move_repeat_delay, clientConfig.move_repeat_interval) then
					if not mino.finished then
						mino.Move(1, 0, true, true)
						didSlowAction = true
						gameState.antiControlRepeat["move_right"] = true
					end
				end
				if checkControl("soft_drop", 0) then
					mino.Move(0, gameState.gravity * clientConfig.soft_drop_multiplier, true, false)
					didSlowAction = true
					gameState.antiControlRepeat["soft_drop"] = true
				end
				if checkControl("hard_drop", false) then
					mino.Move(0, board.height, true, false)
					mino.finished = 1
					didSlowAction = true
					gameState.antiControlRepeat["hard_drop"] = true
				end
				if checkControl("sonic_drop", false) then
					mino.Move(0, board.height, true, true)
					didSlowAction = true
					gameState.antiControlRepeat["sonic_drop"] = true
				end
				if checkControl("hold", false) then
					if not mino.finished then
						mino.finished = 2
						gameState.antiControlRepeat["hold"] = true
						didSlowAction = true
					end
				end
				if checkControl("quit", false) then
					gameState.topOut = true
					gameState.antiControlRepeat["quit"] = true
					didSlowAction = true
				end
			end
			if checkControl("rotate_left", false) then
				mino.Rotate(-1, true)
				if mino.spinID <= gameConfig.spin_mode then
					if (
						mino.CheckCollision(1, 0) and
						mino.CheckCollision(-1, 0) and
						mino.CheckCollision(0, -1)
					) then
						gameState.spinLevel = 3
					else
						gameState.spinLevel = 0
					end
				end
				gameState.antiControlRepeat["rotate_left"] = true
			end
			if checkControl("rotate_right", false) then
				mino.Rotate(1, true)
				if mino.spinID <= gameConfig.spin_mode then
					if (
						mino.CheckCollision(1, 0) and
						mino.CheckCollision(-1, 0) and
						mino.CheckCollision(0, -1)
					) then
						gameState.spinLevel = 3
					else
						gameState.spinLevel = 0
					end
				end
				gameState.antiControlRepeat["rotate_right"] = true
			end
		end
		if checkControl("pause", false) then
			gameState.paused = not gameState.paused
			gameState.antiControlRepeat["pause"] = true
		end
		return didSlowAction
	end

	local tickTimer = os.startTimer(tickDelay)
	local evt
	local didControlTick = false

	while true do

		-- handle ghost piece
		ghostMino.color = "c"
		ghostMino.shape = mino.shape
		ghostMino.x = mino.x
		ghostMino.y = mino.y
		ghostMino.Move(0, board.height, true)

		garbageMino.y = 1 + garbageBoard.height - gameState.incomingGarbage

		-- render board
		render(true)

		evt = {os.pullEvent()}

		if evt[1] == "key" and not evt[3] then
			keysDown[evt[2]] = 1
			didControlTick = controlTick(gameState, false)
			gameState.controlTickCount = gameState.controlTickCount + 1
		elseif evt[1] == "key_up" then
			keysDown[evt[2]] = nil
		end

		if evt[1] == "timer" then
			if evt[2] == tickTimer then
				tickTimer = os.startTimer(0.05)
				for k,v in pairs(keysDown) do
					keysDown[k] = 1 + v
				end
				controlTick(gameState, didControlTick)
				gameState.controlTickCount = gameState.controlTickCount + 1
				if not gameState.paused then
					tick(gameState)
					gameState.gameTickCount = gameState.gameTickCount + 1
				end
				didControlTick = false
				gameState.antiControlRepeat = {}
			end
		end

		if gameState.topOut then
			-- this will have a more elaborate game over sequence later
			return
		end
	end

end

local TitleScreen = function()
	local animation = function()
		local tsx = 8
		local tsy = 10
		--[[
		local title = {
			[1] = "ee\nee\neeffe",
			[2] = "ddfdffd\ndd   dffd\nddffd",
			[3] = "11f1ff1\n11ff1\n11   11f",
			[4] = "affa\naffa\naf",
			[5] = "3f3f3f\nf33ff3\n3ff3",
			[6] = "4ff44f\n   4ff4\n4f4f"
		}
		--]]
		
		--[[
			1 = "    ",
				"@@@@",
				"    ",
				"    ",

			2 = " @ ",
				"@@@",
				"    ",

			3 = "  @",
				"@@@",
				"   ",
				
			4 = "@  ",
				"@@@",
				"   ",

			5 = "@@",
				"@@",

			6 = " @@",
				"@@ ",
				"   ",

			7 = "@@ ",
				" @@",
				"   ",
		]]

		local animBoard = makeNewBoard(1, 1, scr_x, scr_y * 10/3, "f")
		animBoard.visibleHeight = animBoard.height / 2

		local animMinos = {}

		local iterate = 0
		local mTimer = 100000
		
		local titleMinos = {
			-- L
			makeNewMino(nil, 4, animBoard, tsx + 1, tsy).Rotate(0),
			makeNewMino(nil, 1, animBoard, tsx + 0, tsy).Rotate(3),
			
			-- D
			makeNewMino(nil, 7, animBoard, tsx + 6, tsy).Rotate(3),
			makeNewMino(nil, 3, animBoard, tsx + 4, tsy).Rotate(1),
			nil
		}

		for i = 1, #titleMinos do
			if titleMinos[i] then
				table.insert(animMinos, titleMinos[i])
			end
		end

		while true do
			iterate = (iterate + 10) % 360

			if mTimer <= 0 then
				table.insert(animMinos, makeNewMino(nil,
					math.random(1, 7),
					animBoard,
					math.random(1, animBoard.width - 4),
					animBoard.visibleHeight - 4
				))
				mTimer = 4
			else
				mTimer = mTimer - 1
			end

			for i = 1, #animMinos do
				animMinos[i].Move(0, 0.75, false)
				if animMinos[i].y > animBoard.height then
					table.remove(animMinos, i)
				end
			end

			animBoard.Render(table.unpack(animMinos))

			sleep(0.05)
		end
	end
	local menu = function()
		local options = {"Singleplayer", "How to play", "Quit"}
		
	end
	--animation()
	--StartGame(true, 0, 0)
	parallel.waitForAny(function()
		cospc_debuglog(1, "Starting game.")
		StartGame(1, true, 0, 0)
		cospc_debuglog(1, "Game concluded.")
	end, function()
		while true do
			cospc_debuglog(2, "Starting game.")
			StartGame(2, false, 24, 0)
			cospc_debuglog(2, "Game concluded.")
		end
	end)
end

term.clear()

cospc_debuglog(nil, 0)

cospc_debuglog(nil, "Opened LDRIS2.")

TitleScreen()

cospc_debuglog(nil, "Closed LDRIS2.")

term.setCursorPos(1, scr_y - 1)
term.clearLine()
print("Thank you for playing!")
term.setCursorPos(1, scr_y - 0)
term.clearLine()

sleep(0.05)
