local scr_x, scr_y = term.getSize()
local midX, midY = .5 * scr_x, .5 * scr_y
local origTX, origBG = term.getTextColor(), term.getBackgroundColor()

local winLength = 4
local sleepDelay = 0.05
local moveCount = 0

local board = {} 	-- connect 4 board; formatted like board[y][x]
local block = {}	-- bottom blockage; formatted like block[x]

local waiting = false

local boardX, boardY = 7, 6 -- size of board

local palette = {
	bg = colors.black, 		-- color of backdrop
	board = colors.white,	-- color of board
	txt = colors.white		-- color of text
}

local tiles = {
	["bl"] = palette.bg,	-- blank space
	["P1"] = colors.red,	-- player 1
	["P2"] = colors.blue	-- player 2
}

local you = "P1"
local nou = "P2"

local cwrite = function(text, y, doClear)
	local cx, cy = term.getCursorPos()
	term.setCursorPos(midX - math.floor(#text / 2), y or cy)
	if doClear then term.clearLine() end
	term.write(text)
end

local cblit = function(char, text, back, y, doClear)
	local cx, cy = term.getCursorPos()
	term.setCursorPos(midX - math.floor(#text / 2), y or cy)
	if doClear then term.clearLine() end
	term.blit(char, text, back)
end

local resetBoard = function()
	board = {}
	for y = 1, boardY do
		board[y] = {}
		for x = 1, boardX do
			board[y][x] = {"bl", 0} -- owner, half-in mod
		end
	end
	for x = 1, boardX do
		block[x] = true
	end
end

local addPiece = function(owner, x)
	if board[1][x][1] == "bl" then
		board[1][x] = {owner, 0, x, 1}
		return true
	else
		return false
	end
end

local moveTilesDown = function()
	local settled = true --	allows for animated falling tiles
	for y = boardY, 1, -1 do
		for x = 1, boardX do
			if board[y][x][1] ~= "bl" then
				if board[y][x][2] == -1 then
					board[y][x][2] = 0
					settled = false
				elseif (y + 1 <= boardY) then
					if board[y + 1][x][1] == "bl" then
						if board[y][x][2] == 0 then
							board[y][x][2] = 1
							settled = false
						elseif board[y][x][2] == 1 then
							board[y + 1][x] = {board[y][x][1], -1, x, y + 1}
							board[y][x] = {"bl", 0, x, y}
							settled = false
						end
					end
				elseif not block[x] then
					if board[y][x][2] == 0 then
						board[y][x][2] = 1
						settled = false
					else
						board[y][x] = {"bl", 0, x, y}
					end
				end
			end
		end
	end
	return settled
end

resetBoard()

local tileChar = {
	{
		"\131\148",
		"\143\133",
	},
	{
		"10",
		"00",
	},
	{
		"01",
		"11",
	}
}

local to_blit = {
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
	[colors.black] = "f",
}

term.setBackgroundColor(palette.bg)
term.clear()

local checkIfWinner = function()
	local conditions = {}

	-- check horizontal
	for y = 1, boardY do
		for x = 1, boardX - winLength + 1 do
			conditions[#conditions+1] = {}
			for w = 0, winLength - 1 do
				conditions[#conditions][w+1] = board[y][x+w]
			end
		end
	end

	-- check vertical
	for y = boardY - winLength + 1, 1, -1 do
		for x = 1, boardX do
			conditions[#conditions+1] = {}
			for w = 0, winLength - 1 do
				conditions[#conditions][w+1] = board[y+w][x]
			end
		end
	end

	-- check diagonals
	for y = 1, boardY - winLength + 1 do
		for x = 1, boardX - winLength + 1 do
			conditions[#conditions+1] = {}
			conditions[#conditions+1] = {}
			for w = 0, winLength - 1 do
				conditions[#conditions-1][w+1] = board[y+(winLength-w-1)][x+w]
				conditions[#conditions][w+1]   = board[y+w][x+w]
			end
		end
	end

	local winner, check
	for set = 1, #conditions do
		winner = true
		check = conditions[set][1][1]
		for piece = 2, #conditions[set] do
			if conditions[set][piece][1] == "bl" or conditions[set][piece][1] ~= check then
				winner = false
				break
			end
		end
		if winner then
			return conditions[set][1][1], conditions[set]
		end
	end
	return false
end

local renderBoard = function()
	local tileColRep = {
		["1"] = to_blit[palette.board]
	}
	local cx, cy
	for y = 1, boardY + 1 do
		if y == boardY + 1 then
			term.setTextColor(palette.txt)
			for x = 1, boardX do
				term.setCursorPos(midX - (boardX) + (x - 1) * #tileChar[1][1], 4)
				term.write(x)
			end
			cwrite("SPACE to clear", scr_y, false)
		else
			for ymod = 1, #tileChar[1] do
				for x = 0, boardX do
					cx = x * #tileChar[1][1] + (midX - boardX) - 2
					cy = y * #tileChar[1] + ymod + (midY - boardY) - 1
					if x == 0 then
						term.setCursorPos(cx + 1, cy)
						term.blit("\149", to_blit[palette.bg], to_blit[palette.board])
					else
						term.setCursorPos(cx, cy)
						if (board[y][x][2] == 0) or (board[y][x][2] == -1 and ymod == 1) or (board[y][x][2] == 1 and ymod == 2) then
							tileColRep["0"] = to_blit[tiles[ board[y][x][1] ]]
						elseif board[y][x][2] == 2 then
							tileColRep["0"] = to_blit[palette.board]
						else
							tileColRep["0"] = to_blit[tiles["bl"]]
						end
						term.blit(
							tileChar[1][ymod],
							tileChar[2][ymod]:gsub(".", tileColRep),
							tileChar[3][ymod]:gsub(".", tileColRep)
						)
					end
				end
			end
		end
	end
end

local getInput = function()
	local evt
	while true do
		evt = {os.pullEvent()}
		if evt[1] == "char" then
			if tonumber(evt[2]) then
				if tonumber(evt[2]) >= 1 and tonumber(evt[2]) <= boardX then
					if not waiting then
						if board[1][tonumber(evt[2])][1] == "bl" then
							addPiece(you, tonumber(evt[2]))
							moveCount = moveCount + 1
							you, nou = nou, you
							waiting = true
						end
					end
				end
			end
			if evt[2] == " " then
				os.queueEvent("clear_board")
				for y = 1, boardY do
					for x = 1, boardX do
						board[y][x][2] = 0
					end
				end
				for x = 1, boardX do
					block[x] = false
					sleep(0.05)
				end
				moveCount = 0
				you, nou = "P1", "P2"
				sleep(1)
				for x = 1, boardX do
					block[x] = true
				end
			elseif evt[2] == "q" then
				return "exit"
			end
		end
	end
end

local main = function()
	local winner, winPieces
	while true do
		renderBoard()
		while not moveTilesDown() do
			sleep(sleepDelay)
			renderBoard()
		end
		winner, winPieces = checkIfWinner()
		term.setTextColor(palette.txt)
		if winner then
			cblit(
				"Winner: " .. winner,
				to_blit[palette.txt]:rep(8) .. to_blit[tiles[winner]]:rep(#winner),
				to_blit[palette.bg]:rep(8 + #winner),
				1,
				true
			)
			parallel.waitForAny(function()
				while true do
					for p = 1, #winPieces do
						board[winPieces[p][4]][winPieces[p][3]][2] = 0
					end
					renderBoard()
					sleep(0.3)
					for p = 1, #winPieces do
						board[winPieces[p][4]][winPieces[p][3]][2] = 2
					end
					renderBoard()
					sleep(0.2)
				end
			end, function()
				local evt
				repeat
					evt = {os.pullEvent()}
				until evt[1] == "clear_board"
			end)
		elseif moveCount >= boardX * boardY then
			cwrite("It's a tie.", 1, true)
			waiting = true
		else
			waiting = false
			cblit(
				"It's " .. you .. "'s turn.",
				to_blit[palette.txt]:rep(5) .. to_blit[tiles[you]]:rep(#you) .. to_blit[palette.txt]:rep(8),
				to_blit[palette.bg]:rep(13 + #you),
				1,
				true
			)
		end
		sleep(sleepDelay)
	end
end

parallel.waitForAny(main, getInput)
cwrite("Thanks for playing!", 1, true)
term.setCursorPos(1, scr_y)
term.clearLine()
