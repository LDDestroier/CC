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

To-do:
	+ Add proper top-off (game over)
	+ Add score, and let lineclears and piece dropping add to it
	+ Tweak controls, rotating the piece will cause horizontal movement to look janky
	+ Add an actual menu, and not that shit LDRIS 1 had
	+ Multiplayer!
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
		pause = keys.p,
		restart = keys.r,
		open_chat = keys.t,
		quit = keys.q,
	},
	soft_drop_multiplier = 2.0,		-- (SDF) the factor in which soft dropping effects the gravity
	move_repeat_delay = 0.25,		-- (DAS) amount of time you must be holding the movement keys for it to start repeatedly moving (seconds)
	move_repeat_interval = 0.05,	-- (ARR) speed at which the pieces move when holding the movement keys (seconds per tick)
	appearance_delay = 0.0,			-- (ARE) amount of seconds it will take for the next piece to arrive after the current one locks into place
	lock_delay = 0.5,				-- (Lock Delay) amount of seconds it will take for a resting mino to lock into placed
}

-- ideally, only clients with IDENTICAL game configs should face one another
local gameConfig = {
	minos = {},					-- list of all the minos (pieces) that will spawn into the board
	kickTables = {},			-- list of all kick tables for pieces
	currentKickTable = "SRS",	-- current kick table
	randomBag = "random",		-- current pseudorandom number generator
								-- "7bag" = normal tetris guideline random
								-- "14bag" = doubled bag size
								-- "random" = using math.random
	board_width = 10,			-- width of play area
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

local switch = function(check)
    return function(cases)
        if type(cases[check]) == "function" then
            return cases[check]()
        elseif type(cases["default"] == "function") then
            return cases["default"]()
        end
    end
end

-- current state of the game; can be used to perfectly recreate the current scene of a game
-- can NOT include functions, as it must be serialized and sent to a second player
-- that includes board and mino objects, bitch
gameState = {}

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
local makeNewBoard = function(x, y, width, height)
	local board = {}
	board.contents = {}
	board.height = height or gameConfig.board_height
	board.width = width or gameConfig.board_width
	board.x = x
	board.y = y
	board.blankColor = "7"			-- color if no minos are in that spot
	board.transparentColor = "f"	-- color if the board tries to render where there is no board
	board.garbageColor = "8"
	board.visibleHeight = height and math.floor(height / 2) or gameConfig.board_height_visible

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
		local mino

		local tY = board.y + math.floor((board.height - board.visibleHeight) * (2 / 3)) - 2

		for y = board.height, 1 + (board.height - board.visibleHeight), -3 do
			colorLine1, colorLine2, colorLine3 = "", "", ""
			for x = 1, board.width do

				minoColor1, minoColor2, minoColor3 = nil, nil, nil
				for i = 1, #minos do
					mino = minos[i]
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

				colorLine1 = colorLine1 .. (minoColor1 or ((board.contents[y - 0] and board.contents[y - 0]:sub(x, x)) or board.blankColor))
				colorLine2 = colorLine2 .. (minoColor2 or ((board.contents[y - 1] and board.contents[y - 1]:sub(x, x)) or board.blankColor))
				colorLine3 = colorLine3 .. (minoColor3 or ((board.contents[y - 2] and board.contents[y - 2]:sub(x, x)) or board.blankColor))

			end

			if (y - 0) < (board.height - board.visibleHeight) then
				colorLine1 = transparentLine
			end
			if (y - 1) < (board.height - board.visibleHeight) then
				colorLine2 = transparentLine
			end
			if (y - 2) < (board.height - board.visibleHeight) then
				colorLine3 = transparentLine
			end

			term.setCursorPos(board.x, board.y + tY)
			term.blit(charLine1, colorLine2, colorLine1)
			tY = tY - 1
			term.setCursorPos(board.x, board.y + tY)
			term.blit(charLine2, colorLine3, colorLine2)
			tY = tY - 1
		end
	end

	return board
end

local makeNewMino = function(minoID, board, xPos, yPos, oldeMino)
	local mino = oldeMino or {}
	if not gameConfig.minos[minoID] then
		error("tried to spawn mino with invalid ID '" .. minoID .. "'")
	else
		mino.shape = gameConfig.minos[minoID].shape
		mino.spinID = gameConfig.minos[minoID].spinID
		mino.kickID = gameConfig.minos[minoID].kickID
		mino.color = gameConfig.minos[minoID].color
		mino.name = gameConfig.minos[minoID].name
	end

	mino.finished = false
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
		return (
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
		mino.shape = output
		-- it's time to do some floor and wall kicking
		if mino.CheckCollision(0, 0) then
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
					mino.finished = true
				end
			else
				mino.lockTimer = clientConfig.lock_delay
			end
		end

		return success
	end

	mino.Move = function(x, y, doSlam, expendLockMove)
		local didSlam
		local didCollide = false
		local didMoveX = true
		local didMoveY = true
		local step, round
		
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
			mino.movesLeft = mino.movesLeft - 1
			if mino.movesLeft <= 0 then
				if mino.CheckCollision(0, 1) then
					mino.finished = true
				end
			else
				mino.lockTimer = clientConfig.lock_delay
			end
		end

		return didCollide, didMoveX, didMoveY, yHighestDidChange
	end

	-- writes the mino to the board
	mino.Write = function()
		for y = 1, mino.height do
			for x = 1, mino.width do
				if mino.CheckSolid(x, y, false) then
					mino.board.Write(x + mino.x - 1, y + mino.y - 1, mino.color)
				end
			end
		end
	end

	return mino
end

local pseudoRandom = function()
	return switch(gameConfig.randomBag) {
		["random"] = function()
			return math.random(1, #gameConfig.minos)
		end,
		["7bag"] = function()
			-- will implement 7bag later
			return math.random(1, #gameConfig.minos)
		end,
		["14bag"] = function()
			-- will implement 14bag later
			return math.random(1, #gameConfig.minos)
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
			newContents[y] = string.rep(board.blankColor, board.width)
		end
		gameState.board.contents = newContents
	end

	return clearedLines

end

StartGame = function()
	gameState = {
		gravity = gameConfig.startingGravity,
		board = makeNewBoard(2, 2, gameConfig.board_width, gameConfig.board_height),
		score = 0,
	}
	gameState.mino = {}

	local makeDefaultMino = function()
		return makeNewMino(
			pseudoRandom(),
			gameState.board,
			math.floor(gameState.board.width / 2 - 1),
			math.floor(gameConfig.board_height_visible + 0),
			gameState.mino
		)
	end

	gameState.mino = makeDefaultMino()

	local mino, board = gameState.mino, gameState.board
	local ghostMino = makeNewMino(mino.minoID, gameState.board, mino.x, mino.y, {})
	
	local keysDown = {}
	local tickDelay = 0.05

	local render = function()
		board.Render(ghostMino, mino)
	end

	local tick = function(gameState)
		local didCollide, didMoveX, didMoveY, yHighestDidChange = mino.Move(0, gameState.gravity, true)
		mino.resting = (not didMoveY) and mino.CheckCollision(0, 1)

		if yHighestDidChange then
			mino.movesLeft = gameConfig.lock_move_limit
		end

		if mino.resting then
			mino.lockTimer = mino.lockTimer - tickDelay
			if mino.lockTimer <= 0 then
				mino.finished = true
			end
		else
			mino.lockTimer = clientConfig.lock_delay
		end

		if mino.finished then
			mino.Write()
			gameState.mino = makeDefaultMino()
			ghostMino = makeNewMino(mino.minoID, gameState.board, mino.x, mino.y, {})

			handleLineClears(gameState)
		end

		-- debug info

		term.setCursorPos(2, scr_y - 1)
		term.clearLine()
		term.write("(" .. mino.x .. ":" .. mino.xFloat .. ", " .. mino.y .. ":" .. mino.yFloat .. ")   ")

		term.setCursorPos(2, scr_y - 0)
		term.clearLine()
		term.write(mino.movesLeft .. "   ")
	end

	local checkControl = function(controlName, repeatTime, repeatDelay)
		repeatDelay = repeatDelay or 1
		if keysDown[clientConfig.controls[controlName]] then
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
		else
			return false
		end
	end

	local controlTick = function(gameState, onlyFastActions)
		local dc, dmx, dmy	-- did collide, did move X, did move Y
		local didSlowAction = false
		if not onlyFastActions then
			if checkControl("move_left", clientConfig.move_repeat_delay, clientConfig.move_repeat_interval) then
				mino.Move(-1, 0, true, true)
				didSlowAction = true
			end
			if checkControl("move_right", clientConfig.move_repeat_delay, clientConfig.move_repeat_interval) then
				mino.Move(1, 0, true, true)
				didSlowAction = true
			end
			if checkControl("soft_drop", 0) then
				mino.Move(0, gameState.gravity * clientConfig.soft_drop_multiplier, true, false)
				didSlowAction = true
			end
			if checkControl("hard_drop", false) then
				mino.Move(0, board.height, true, false)
				mino.finished = true
				didSlowAction = true
			end
			if checkControl("sonic_drop", false) then
				mino.Move(0, board.height, true, true)
				didSlowAction = true
			end
		end
		if checkControl("rotate_left", false) then
			mino.Rotate(-1, true)
		end
		if checkControl("rotate_right", false) then
			mino.Rotate(1, true)
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

		-- render board
		render()

		evt = {os.pullEvent()}

		if evt[1] == "key" and not evt[3] then
			keysDown[evt[2]] = 1
			if not didControlTick then
				didControlTick = controlTick(gameState, false)
			else
				controlTick(gameState, true)
			end
		elseif evt[1] == "key_up" then
			keysDown[evt[2]] = nil
		end

		if evt[1] == "timer" then
			if evt[2] == tickTimer then
				tickTimer = os.startTimer(0.05)
				for k,v in pairs(keysDown) do
					keysDown[k] = 1 + v
				end
				if not didControlTick then
					controlTick(gameState, false)
				end
				tick(gameState)
				didControlTick = false
			end
		end
	end

end

term.clear()
StartGame()