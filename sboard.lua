local newBoard = function(x, y, width, height, backgroundColor)
	local board = {}
	board.contents = {}
	board.height = height or gameConfig.board_height
	board.width = width or gameConfig.board_width
	board.x = x
	board.y = y
	board.blankColor = "f"			-- color if no minos are in that spot
	board.transparentColor = "f"	-- color if the board tries to render where there is no board

	for y = 1, board.height do
		board.contents[y] = string.rep(backgroundColor or board.blankColor, width)
	end
	
	board.Write = function(x, y, color)
		x = math.ceil(x)
		y = math.ceil(y)
		board.contents[y] = board.contents[y]:sub(1, x - 1) .. color .. board.contents[y]:sub(x + 1)
	end

	board.GetDot = function(x, y)
		if x > 0 and y > 0 then
			if board.contents[y] then
				if board.contents[y]:sub(x,x) ~= "" then
					return board.contents[y]:sub(x, x)
				end
			end
		end
	end

	board.Render = function(...)	-- takes list of minos that it will render atop the board
		local charLine1 = string.rep("\143", board.width)
		local charLine2 = string.rep("\131", board.width)
		local transparentLine = string.rep(board.transparentColor, board.width)
		local colorLine1, colorLine2, colorLine3

		local newColor1, newColor2, newColor3
		local otherBoards = {...}
		local otherBoard

		local tY = 0
		local ix, iy

		for y = 1, board.height, 3 do
			colorLine1, colorLine2, colorLine3 = "", "", ""
			for x = 1, board.height do
				newColor1, newColor2, newColor3 = nil, nil, nil
				for i = 1, #otherBoards do
					otherBoard = otherBoards[i]
					ix = x - otherBoard.x + 1
					iy = y - otherBoard.y + 1
					if otherBoard.GetDot(ix, iy + 0) ~= otherBoard.transparentColor then
						newColor1 = otherBoard.GetDot(ix, iy + 0)
					end
					if otherBoard.GetDot(ix, iy + 1) ~= otherBoard.transparentColor then
						newColor2 = otherBoard.GetDot(ix, iy + 1)
					end
					if otherBoard.GetDot(ix, iy + 2) ~= otherBoard.transparentColor then
						newColor3 = otherBoard.GetDot(ix, iy + 2)
					end
				end
				colorLine1 = colorLine1 .. (newColor1 or (board.contents[y + 0] and board.contents[y + 0]:sub(x,x) or board.blankColor))
				colorLine2 = colorLine2 .. (newColor2 or (board.contents[y + 1] and board.contents[y + 1]:sub(x,x) or board.blankColor))
				colorLine3 = colorLine3 .. (newColor3 or (board.contents[y + 2] and board.contents[y + 2]:sub(x,x) or board.blankColor))
			end

			if (y + 0) > board.height then
				colorLine1 = transparentLine
			end
			if (y + 1) > board.height then
				colorLine2 = transparentLine
			end
			if (y + 2) > board.height then
				colorLine3 = transparentLine
			end

			term.setCursorPos(board.x, board.y + tY)
			term.blit(charLine1, colorLine1, colorLine2)
			tY = tY + 1
			term.setCursorPos(board.x, board.y + tY)
			term.blit(charLine2, colorLine2, colorLine3)
			tY = tY + 1
		end
	end

	return board
end

return {
	newBoard = newBoard;
}
