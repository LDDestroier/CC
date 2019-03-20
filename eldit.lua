-- Eldit (still being made)
-- by LDDestroier
-- wget https://raw.githubusercontent.com/LDDestroier/CC/master/eldit.lua

local scr_x, scr_y = term.getSize()

local argData = {
	["-l"] = "number"
}

local eldit = {}
eldit.buffer = {{}}			-- stores all text, organized like eldit.buffer[yPos][xPos]
eldit.clipboards = {}		-- all clipboard entries
eldit.selectedClipboard = 1	-- which clipboard to use
eldit.scrollX = 0			-- horizontal scroll
eldit.scrollY = 0			-- vertical scroll
eldit.selections = {}
eldit.size = {
	x = 1,			-- top left corner X
	y = 1,			-- top left corner Y
	width = scr_x,	-- horizontal size
	height = scr_y	-- vertical size
}

-- I'm never using regular argument parsing again, this function rules
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

local argList = interpretArgs({...}, argData)

eldit.filename = argList[1]
eldit.cursors = {{
	x = 1,
	y = math.max(1, argList["-l"] or 1),
	lastX = 1
}}

local eClearLine = function(y)
	local cx, cy = term.getCursorPos()
	term.setCursorPos(eldit.size.x, y or cy)
	term.write((" "):rep(eldit.size.width))
	term.setCursorPos(cx, cy)
end

local eClear = function()
	local cx, cy = term.getCursorPos()
	for y = eldit.size.y, eldit.size.y + eldit.size.height - 1 do
		term.setCursorPos(eldit.size.x, y)
		term.write((" "):rep(eldit.size.width))
	end
	term.setCursorPos(cx, cy)
end

local sortSelections = function()
	for id,sel in pairs(eldit.selections) do
		table.sort(sel, function(a,b)
			return (a.y * eldit.size.width) + a.x < (b.y * eldit.size.width) + b.x
		end)
	end
end

local sortCursors = function()
	table.sort(eldit.cursors, function(a,b)
		return (a.y * eldit.size.width) + a.x < (b.y * eldit.size.width) + b.x
	end)
end

local explode = function(div, str, replstr, includeDiv)
	if (div == '') then
		return false
	end
	local pos, arr = 0, {}
	for st, sp in function() return string.find(str, div, pos, false) end do
		table.insert(arr, string.sub(replstr or str, pos, st - 1 + (includeDiv and #div or 0)))
		pos = sp + 1
	end
	table.insert(arr, string.sub(replstr or str, pos))
	return arr
end

local readFile = function(path)
	if fs.exists(path) then
		local file = fs.open(path, "r")
		local contents = file.readAll()
		file.close()
		return contents
	else
		return nil
	end
end

local writeFile = function(path, contents)
	if fs.isReadOnly(path) or fs.isDir(path) then
		return false
	else
		local file = fs.open(path, "w")
		file.write(contents)
		file.close()
		return true
	end
end

prompt = function(prebuffer, precy, _eldit)
	local keysDown = {}					-- list of all keys being pressed
	local miceDown = {}					-- list of all mouse buttons being pressed
	eldit = _eldit or eldit				-- you can replace the "eldit" table if you want I guess
	local defaultBarLife = 10			-- default amount of time bar msg will stay onscreen
	local barmsg = "Started Eldit."		-- message displayed on bottom screen
	local barlife = defaultBarLife
	local lastMouse = {}				-- last place you clicked onscreen
	local isSelecting = false			-- whether or not you are selecting text
	if type(prebuffer) == "string" then	-- enter a "prebuffer" (string or table) to set the contents
		for i = 1, #prebuffer do
			if prebuffer:sub(i,i) == "\n" then
				eldit.buffer[#eldit.buffer + 1] = {}
			else
				eldit.buffer[#eldit.buffer][#eldit.buffer[#eldit.buffer] + 1] = prebuffer:sub(i,i)
			end
		end
	elseif type(prebuffer) == "table" then
		eldit.buffer = prebuffer
	end
	local isCursorBlink = false			-- blinks the background color on each cursor
	local isInsert = false				-- will overwrite characters instead of appending them

	-- list of all characters that will stop a CTRL+Backspace or CTRL+Delete or CTRL+Left/Right
	local interruptable = {
		[" "] = true,
		["["] = true, ["]"] = true,
		["{"] = true, ["}"] = true,
		["("] = true, [")"] = true,
		["|"] = true,
		["/"] = true,
		["\\"] = true,
		["+"] = true,
		["-"] = true,
		["*"] = true,
		["="] = true,
		["."] = true,
		[","] = true
	}

	-- goes over every selection and checks if it is selected
	-- (x, y) = position on buffer
	local checkIfSelected = function(x, y)
		sortSelections()
		local fin
		if y >= 1 and y <= #eldit.buffer then
			if x >= 1 and x <= #eldit.buffer[y] + 1 then
				for id, sel in pairs(eldit.selections) do

					if y == sel[1].y then
						if sel[2].y == sel[1].y then
							fin = x >= sel[1].x and x <= sel[2].x
						else
							fin = x >= sel[1].x
						end
					elseif y == sel[2].y then
						if sel[2].y == sel[1].y then
							fin = x >= sel[1].x and x <= sel[2].x
						else
							fin = x <= sel[2].x
						end
					elseif y > sel[1].y and y < sel[2].y then
						fin = true
					end

					if fin then
						return id
					end

				end
			end
		end
		return false
	end

	-- goes over every cursor and checks if they are at (x, y)
	-- (x,y) = position on buffer
	local checkIfCursor = function(x, y)
		for id, cur in pairs(eldit.cursors) do
			if x == cur.x and y == cur.y then
				return id
			end
		end
		return false
	end

	-- returns character at (x, y) on the buffer
	local getChar = function(x, y)
		if eldit.buffer[y] then
			return eldit.buffer[y][x]
		else
			return nil
		end
	end

	-- the big boi function, draws **EVERYTHING**
	local render = function()
		local cx, cy
		local tab = {
			[" "] = true,
			["\9"] = true
		}
		local lineNoLen = #tostring(#eldit.buffer)
		local textPoses = {math.huge, math.huge}		-- used to identify space characters without text
		for y = 1, eldit.size.height - 1 do -- minus one because it reserves space for the bar
			cy = y + eldit.scrollY
			-- find text
			if eldit.buffer[cy] then
				for x = 1, #eldit.buffer[cy] do
					if (not tab[eldit.buffer[cy][x]]) and eldit.buffer[cy][x] then
						textPoses[1] = x
						break
					end
				end
				for x = #eldit.buffer[cy], 1, -1 do
					if (not tab[eldit.buffer[cy][x]]) and eldit.buffer[cy][x] then
						textPoses[2] = x
						break
					end
				end
			end
			local isHighlighted = false
			for id,cur in pairs(eldit.cursors) do
				if cy == cur.y then
					isHighlighted = true
					break
				end
			end
			if not isHighlighted then
				for id,sel in pairs(eldit.selections) do
					if cy >= sel[1].y and cy <= sel[2].y then
						isHighlighted = true
						break
					end
				end
			end
			term.setCursorPos(eldit.size.x, eldit.size.y + y - 1)
			if cy <= #eldit.buffer then
				if isHighlighted then
					term.setBackgroundColor(colors.gray)
					term.setTextColor(colors.white)
				else
					term.setBackgroundColor(colors.black)
					term.setTextColor(colors.lightGray)
				end
				term.write(cy .. (" "):rep(lineNoLen - #tostring(y)))
			else
				term.write(" ")
			end
			-- actually draw text
			for x = lineNoLen + 1, eldit.size.width do
				term.setCursorPos(eldit.size.x + x - 1, eldit.size.y + y - 1)
				cx = x + eldit.scrollX - lineNoLen

				if checkIfSelected(cx, cy) then
					term.setBackgroundColor(colors.blue)
				else
					term.setBackgroundColor(colors.black)
				end

				if checkIfCursor(cx, cy) and isCursorBlink then
					if isInsert then
						term.setTextColor(colors.black)
						term.setBackgroundColor(colors.white)
					else
						term.setTextColor(colors.black)
						term.setBackgroundColor(colors.lightGray)
					end
				else
					term.setTextColor(colors.white)
				end
				if textPoses[1] and textPoses[2] and eldit.buffer[cy] then
					if cx < textPoses[1] and eldit.buffer[cy][cx] then
						term.setTextColor(colors.gray)
						term.write("|")
					elseif (cx > textPoses[2] and eldit.buffer[cy][cx]) then
						term.setTextColor(colors.gray)
						term.write("-")
					else
						term.write(getChar(cx, cy) or " ")
					end
				else
					term.write(getChar(cx, cy) or " ")
				end
			end
		end
		term.setCursorPos(eldit.size.x, eldit.size.y + eldit.size.height - 1)
		term.setBackgroundColor(colors.gray)
		eClearLine()
		if barlife > 0 then
			term.write(barmsg)
		else
			for id,cur in pairs(eldit.cursors) do
				term.write("(" .. cur.x .. "," .. cur.y .. ") ")
			end
		end
	end

	-- if all cursors are offscreen, will scroll so that at least one of them is onscreen
	local scrollToCursor = function()
		lineNoLen = #tostring(#eldit.buffer)
		local lowCur, highCur = eldit.cursors[1], eldit.cursors[1]
		local leftCur, rightCur = eldit.cursors[1], eldit.cursors[1]
		for id,cur in pairs(eldit.cursors) do
			if cur.y < lowCur.y then
				lowCur = cur
			elseif cur.y > highCur.y then
				highCur = cur
			end
			if cur.x < leftCur.x then
				leftCur = cur
			elseif cur.y > rightCur.x then
				rightCur = cur
			end
		end
		if lowCur.y - eldit.scrollY < 1 then
			eldit.scrollY = highCur.y - 1
		elseif highCur.y - eldit.scrollY > eldit.size.height - 1 then
			eldit.scrollY = lowCur.y - eldit.size.height + 1
		end
		if leftCur.x - eldit.scrollX < 1 then
			eldit.scrollX = rightCur.x - 1
		elseif rightCur.x - eldit.scrollX > eldit.size.width - lineNoLen then
			eldit.scrollX = leftCur.x - (eldit.size.width - lineNoLen)
		end
	end

	-- gets the widest line length in all the buffer
	local getMaximumWidth = function()
		local maxX = 0
		for y = 1, #eldit.buffer do
			maxX = math.max(maxX, #eldit.buffer[y])
		end
		return maxX
	end

	-- scrolls the screen, and fixes it if it's set to some weird value
	local adjustScroll = function(modx, mody)
		modx, mody = modx or 0, mody or 0
		local lineNoLen = #tostring(#eldit.buffer)
		if mody then
			eldit.scrollY = math.min(
				math.max(
					0,
					eldit.scrollY + mody
				),
				math.max(
					0,
					#eldit.buffer - eldit.size.height + 1
				)
			)
		end
		if modx then
			eldit.scrollX = math.min(
				math.max(
					0,
					eldit.scrollX + modx
				),
				math.max(
					0,
					getMaximumWidth() - eldit.size.width + 1 - lineNoLen
				)
			)
		end
	end

	-- removes any cursors that share positions
	local removeRedundantCursors = function()
		local xes = {}
		for i = #eldit.cursors, 1, -1 do
			if xes[eldit.cursors[i].x] == eldit.cursors[i].y then
				table.remove(eldit.cursors, i)
			else
				xes[eldit.cursors[i].x] = eldit.cursors[i].y
			end
		end
	end

	-- deletes text at every cursor position, either forward or backward or neutral
	local deleteText = function(mode, direction, _cx, _cy)
		local xAdjList = {}
		local yAdj = 0
		sortCursors()
		for id,cur in pairs(eldit.cursors) do
			cx = _cx or cur.x - (xAdjList[_cy or cur.y] or 0)
			cy = _cy or cur.y - yAdj

			if mode == "single" or (direction == "forward" and cx == #eldit.buffer[cy] or (direction == "backward" and cx == 1)) then
				if direction == "forward" then
					if cx < #eldit.buffer[cy] then
						xAdjList[cy] = (xAdjList[cy] or 0) + 1
						table.remove(eldit.buffer[cy], cx)
					elseif cy < #eldit.buffer then
						for i = 1, #eldit.buffer[cy + 1] do
							table.insert(eldit.buffer[cy], eldit.buffer[cy + 1][i])
						end
						table.remove(eldit.buffer, cy + 1)
						yAdj = yAdj + 1
					end
				elseif direction == "backward" then
					if cx > 1 then
						cx = cx - 1
						xAdjList[cy] = (xAdjList[cy] or 0) + 1
						table.remove(eldit.buffer[cy], cx)
					elseif cy > 1 then
						cx = #eldit.buffer[cy - 1] + 1
						for i = 1, #eldit.buffer[cy] do
							table.insert(eldit.buffer[cy - 1], eldit.buffer[cy][i])
						end
						table.remove(eldit.buffer, cy)
						yAdj = yAdj + 1
						cy = cy - 1
					end
				else
					if cx >= 1 and cx <= #eldit.buffer[cy] then
						table.remove(eldit.buffer[cy], cx)
					elseif cx == #eldit.buffer[cy] + 1 and cy < #eldit.buffer then
						for i = 1, #eldit.buffer[cy + 1] do
							table.insert(eldit.buffer[cy], eldit.buffer[cy + 1][i])
						end
						table.remove(eldit.buffer, cy + 1)
						yAdj = yAdj + 1
					end
				end
			elseif mode == "word" then
				local pos = cx
				if direction == "forward" then
					repeat
						pos = pos + 1
					until interruptable[eldit.buffer[cy][pos]] or pos >= #eldit.buffer[cy]
					for i = pos, cx, -1 do
						xAdjList[cy] = (xAdjList[cy] or 0) + 1
						table.remove(eldit.buffer[cy], i)
					end
				else
					repeat
						pos = pos - 1
					until interruptable[eldit.buffer[cy][pos]] or pos <= 1
					pos = math.max(1, pos)
					for i = cx - 1, pos, -1 do
						table.remove(eldit.buffer[cy], i)
					end
					cx = pos
				end
			elseif mode == "line" then -- like word but is only interrupted by newline
				if direction == "forward" then
					for i = cx, #eldit.buffer[cy] do
						eldit.buffer[cy][i] = nil
					end
				else
					for i = cx, 1, -1 do
						table.remove(eldit.buffer[cy], i)
					end
				end
			end

			if _cx then
				return yAdj
			else
				cur.x = cx
				cur.y = cy
				cur.lastX = cx
			end

		end
		removeRedundantCursors()
		if not isSelecting then
			scrollToCursor()
		end
		return yAdj
	end

	-- moves the cursor by (xmod, ymod), and fixes its position if it's set to an invalid one
	local adjustCursor = function(_xmod, _ymod, setLastX, mode)
		for id,cur in pairs(eldit.cursors) do
			if mode == "word" then
				xmod = (_xmod / math.abs(_xmod))
				ymod = 0
				repeat
					xmod = xmod + (_xmod / math.abs(_xmod))
				until interruptable[eldit.buffer[cur.y][cur.x + xmod]] or cur.x + xmod >= #eldit.buffer[cur.y] or cur.x + xmod <= 1
				xmod = xmod - math.min(0, math.max(xmod, -1))
			else
				xmod = _xmod
				ymod = _ymod
			end
			if mode == "flip" then
				if eldit.buffer[cur.y + ymod] then
					eldit.buffer[cur.y], eldit.buffer[cur.y + ymod] = eldit.buffer[cur.y + ymod], eldit.buffer[cur.y]
				end
			end
			cur.x = cur.x + xmod
			cur.y = cur.y + ymod
			cur.y = math.max(1, math.min(cur.y, #eldit.buffer))
			if xmod ~= 0 then
				repeat
				if cur.x < 1 and cur.y > 1 then
						cur.y = cur.y - 1
						cur.x = cur.x + #eldit.buffer[cur.y] + 1
					elseif cur.x > #eldit.buffer[cur.y] + 1 and cur.y < #eldit.buffer then
						cur.x = cur.x - #eldit.buffer[cur.y] - 1
						cur.y = cur.y + 1
					end
				until (cur.x >= 1 and cur.x <= #eldit.buffer[cur.y] + 1) or ((cur.y == 1 and xmod < 0) or (cur.y == #eldit.buffer and xmod > 0))
			end
			if setLastX then
				cur.lastX = cur.x
			else
				cur.x = cur.lastX
			end
			if cur.y < 1 then
				cur.y = math.max(1, math.min(cur.y, #eldit.buffer))
				cur.x = 1
			elseif cur.y > #eldit.buffer then
				cur.y = math.max(1, math.min(cur.y, #eldit.buffer))
				cur.x = #eldit.buffer[cur.y] + 1
			else
				cur.y = math.max(1, math.min(cur.y, #eldit.buffer))
				cur.x = math.max(1, math.min(cur.x, #eldit.buffer[cur.y] + 1))
			end
		end
		removeRedundantCursors()
		if (not keysDown[keys.leftCtrl]) and not (xmod == 0 and ymod == 0) then
			eldit.selections = {}
			isSelecting = false
		end
		if not isSelecting then
			scrollToCursor()
		end
	end

	-- deletes the parts of the buffer that are selected, then clears the selection list
	local deleteSelections = function()
		sortSelections()
		if #eldit.selections == 0 then
			return {}, {}
		end
		local xAdjusts = {}
		local yAdjusts = {}
		local xAdj = 0
		local yAdj = 0
		for y = 1, #eldit.buffer do
			xAdjusts[y] = {}
			if checkIfSelected(#eldit.buffer[y] + 1, y) then
				yAdj = yAdj + 1
			end
			yAdjusts[y + 1] = yAdj
			xAdj = 0
			for x = 2, #eldit.buffer[y] do
				xAdjusts[y][x] = xAdj
				if checkIfSelected(x, y) then
					xAdj = xAdj + 1
				end
			end
		end
		for y = #eldit.buffer, 1, -1 do
			for x = #eldit.buffer[y] + 1, 1, -1 do

				if checkIfSelected(x, y) then
					if x == #eldit.buffer[y] + 1 then
						if eldit.buffer[y + 1] then
							for i = 1, #eldit.buffer[y + 1] do
								table.insert(eldit.buffer[y], eldit.buffer[y + 1][i])
							end
							table.remove(eldit.buffer, y + 1)
						end
					else
						deleteText("single", nil, x, y)
					end
				end

			end
		end
		eldit.selections = {}
		adjustCursor(0, 0, true)
		return xAdjusts, yAdjusts
	end

	-- puts text at every cursor position
	local placeText = function(text, cursorList)
		local xAdjusts, yAdjusts = deleteSelections()
		removeRedundantCursors()
		sortCursors()
		local xAdjList = {}
		for id,cur in pairs(cursorList or eldit.cursors) do
			cur.y = cur.y - (yAdjusts[cur.y] or 0)
			cur.x = cur.x - ((xAdjusts[cur.y] or {})[cur.x] or 0) + (xAdjList[cur.y] or 0)
			for i = 1, #text do
				if isInsert then
					if cur.x == #eldit.buffer[cur.y] + 1 then
						for i = 1, #eldit.buffer[cur.y + 1] do
							table.insert(eldit.buffer[cur.y], eldit.buffer[cur.y + 1][i])
						end
						table.remove(eldit.buffer, cur.y + 1)
					end
					eldit.buffer[cur.y][cur.x + i - 1] = text:sub(i,i)
				else
					table.insert(eldit.buffer[cur.y], cur.x, text:sub(i,i))
					if #xAdjusts + #yAdjusts == 0 then
						xAdjList[cur.y] = (xAdjList[cur.y] or 0) + 1
					end
				end
				cur.x = cur.x + 1
			end
			cur.lastX = cur.x
		end
		if not isSelecting then
			scrollToCursor()
		end
	end

	-- adds a new line to the buffer at every cursor position
	local makeNewLine = function(cursorList)
		for id,cur in pairs(cursorList or eldit.cursors) do
			table.insert(eldit.buffer, cur.y + 1, {})
			for i = cur.x, #eldit.buffer[cur.y] do
				if i > cur.x or not isInsert then
					table.insert(eldit.buffer[cur.y + 1], eldit.buffer[cur.y][i])
				end
				eldit.buffer[cur.y][i] = nil
			end
			cur.x = 1
			cur.y = cur.y + 1
		end
		if not isSelecting then
			scrollToCursor()
		end
	end

	-- saves to file, duhh
	local saveFile = function()
		local compiled = ""
		for y = 1, #eldit.buffer do
			compiled = compiled .. table.concat(eldit.buffer[y])
			if y < #eldit.buffer then
				compiled = compiled .. "\n"
			end
		end
		writeFile(eldit.filename, compiled)
		barmsg = "Saved to '" .. eldit.filename .. "'."
		barlife = defaultBarLife
	end

	local evt
	local tID = os.startTimer(0.5)		-- timer for cursor blinking
	local bartID = os.startTimer(0.1)	-- timer for bar message to go away
	local doRender = true				-- if true, renders

	-- converts numerical key events to usable numbers
	local numToKey = {
		-- number bar
		[2] = 1,
		[3] = 2,
		[4] = 3,
		[5] = 4,
		[6] = 5,
		[7] = 6,
		[8] = 7,
		[9] = 8,
		[10] = 9,
		[11] = 0,
		-- number pad
		[79] = 1,
		[80] = 2,
		[81] = 3,
		[75] = 4,
		[76] = 5,
		[77] = 6,
		[71] = 7,
		[72] = 8,
		[73] = 9,
		[82] = 0,
	}

	-- here we go my man
	scrollToCursor()
	while true do
		evt = {os.pullEvent()}
		if evt[1] == "timer" then
			if evt[2] == tID then
				if isCursorBlink then
					tID = os.startTimer(0.4)
				else
					tID = os.startTimer(0.3)
				end
				isCursorBlink = not isCursorBlink
				doRender = true
			elseif evt[2] == bartID then
				bartID = os.startTimer(0.1)
				barlife = math.max(0, barlife - 1)
			end
		elseif (evt[1] == "char" and not keysDown[keys.leftCtrl]) then
			placeText(evt[2])
			doRender = true
		elseif evt[1] == "paste" then
			if keysDown[keys.leftShift] then
				local cb = eldit.clipboards[eldit.selectedClipboard]
				local cbb = {}
				if cb then
					deleteSelections()
					sortCursors()
					for i = 1, math.max(#cb, #eldit.cursors) do
						cbb[i] = cb[(i % #cb) + 1]
					end
					for i = 1, #cbb do
						if eldit.cursors[i] then
							for y = 1, #cbb[i] do
								placeText(table.concat(cbb[i][y]), {eldit.cursors[i]})
								if y < #cbb[i] then
									makeNewLine({eldit.cursors[i]})
								end
							end
						else
							makeNewLine({eldit.cursors[#eldit.cursors]})
							for y = 1, #cbb[i] do
								placeText(table.concat(cbb[i][y]), {eldit.cursors[#eldit.cursors]})
								if y < #cbb[i] then
									makeNewLine({eldit.cursors[#eldit.cursors]})
								end
							end
						end
					end
					barmsg = "Pasted from clipboard " .. eldit.selectedClipboard .. "."
				else
					barmsg = "Clipboard " .. eldit.selectedClipboard .. " is empty."
				end
				barlife = defaultBarLife
			else
				placeText(evt[2])
			end
			doRender = true
		elseif evt[1] == "key" then
			keysDown[evt[2]] = true
			-- KEYBOARD SHORTCUTS
			if keysDown[keys.leftCtrl] or keysDown[keys.rightCtrl] then

				if keysDown[keys.leftShift] or keysDown[keys.rightShift] then
					if evt[2] == keys.c or evt[2] == keys.x then
						if #eldit.selections == 0 then
							barmsg = "No selections have been made."
							barlife = defaultBarLife
						else
							eldit.clipboards[eldit.selectedClipboard] = {}
							local cb = eldit.clipboards[eldit.selectedClipboard]
							sortSelections()
							local id, selY
							for y = 1, #eldit.buffer do
								for x = 1, #eldit.buffer[y] do
									id = checkIfSelected(x, y)
									if id then
										selY = y - eldit.selections[id][1].y + 1
										cb[id] = cb[id] or {}
										cb[id][selY] = cb[id][selY] or {}
										table.insert(cb[id][selY], eldit.buffer[y][x])
									end
								end
							end
							if evt[2] == keys.x then
								deleteSelections()
								barmsg = "Cut to clipboard " .. eldit.selectedClipboard .. "."
								barlife = defaultBarLife
							else
								barmsg = "Copied to clipboard " .. eldit.selectedClipboard .. "."
								barlife = defaultBarLife
							end
						end
					end
					-- In-editor pasting is done with the "paste" event!
				else
					if numToKey[evt[2]] then -- if that's a number then
						eldit.selectedClipboard = numToKey[evt[2]]
						barmsg = "Selected clipboard " .. eldit.selectedClipboard .. "."
						barlife = defaultBarLife
					elseif evt[2] == keys.backspace then
						if #eldit.selections > 0 then
							deleteSelections()
						else
							deleteText("word", "backward")
						end
						doRender, isCursorBlink = true, false

					elseif evt[2] == keys.delete then
						if #eldit.selections > 0 then
							deleteSelections()
						else
							deleteText("word", "forward")
						end
						doRender, isCursorBlink = true, false

					elseif evt[2] == keys.q then
						return "exit"

					elseif evt[2] == keys.s then
						saveFile()

					elseif evt[2] == keys.a then
						eldit.selections = {{
							{
								x = 1,
								y = 1
							},{
								x = #eldit.buffer[#eldit.buffer],
								y = #eldit.buffer
							}
						}}
						doRender = true

					elseif evt[2] == keys.left then
						adjustCursor(-1, 0, true, "word")
						doRender, isCursorBlink = true, true

					elseif evt[2] == keys.right then
						adjustCursor(1, 0, true, "word")
						doRender, isCursorBlink = true, true

					elseif evt[2] == keys.up then
						adjustCursor(0, -1, false, "flip")
						doRender, isCursorBlink = true, true

					elseif evt[2] == keys.down then
						adjustCursor(0, 1, false, "flip")
						doRender, isCursorBlink = true, true

					end
				end

			else

				if evt[2] == keys.tab then
					placeText("\9")
					doRender = true
				elseif evt[2] == keys.insert then
					isInsert = not isInsert
					doRender, isCursorBlink = true, true

				elseif evt[2] == keys.enter then
					makeNewLine()
					doRender, isCursorBlink = true, false

				elseif evt[2] == keys.home then
					eldit.cursors = {{
						x = 1,
						y = eldit.cursors[1].y,
						lastX = 1
					}}
					scrollToCursor()
					doRender, isCursorBlink = true, true

				elseif evt[2] == keys["end"] then
					eldit.cursors = {{
						x = #eldit.buffer[eldit.cursors[1].y] + 1,
						y = eldit.cursors[1].y,
						lastX = #eldit.buffer[eldit.cursors[1].y] + 1
					}}
					scrollToCursor()
					doRender, isCursorBlink = true, true

				elseif evt[2] == keys.pageUp then
					adjustScroll(0, -eldit.size.height)
					doRender = true

				elseif evt[2] == keys.pageDown then
					adjustScroll(0, eldit.size.height)
					doRender = true

				elseif evt[2] == keys.backspace then
					if #eldit.selections > 0 then
						deleteSelections()
					else
						deleteText("single", "backward")
					end
					doRender, isCursorBlink = true, false

				elseif evt[2] == keys.delete then
					if #eldit.selections > 0 then
						deleteSelections()
					else
						deleteText("single", "forward")
					end
					doRender, isCursorBlink = true, false

				elseif evt[2] == keys.left then
					adjustCursor(-1, 0, true)
					doRender, isCursorBlink = true, true

				elseif evt[2] == keys.right then
					adjustCursor(1, 0, true)
					doRender, isCursorBlink = true, true

				elseif evt[2] == keys.up then
					adjustCursor(0, -1, false)
					doRender, isCursorBlink = true, true

				elseif evt[2] == keys.down then
					adjustCursor(0, 1, false)
					doRender, isCursorBlink = true, true

				end

			end
		elseif evt[1] == "key_up" then
			keysDown[evt[2]] = nil
		elseif evt[1] == "mouse_click" then
			local lineNoLen = #tostring(#eldit.buffer)
			miceDown[evt[2]] = {x = evt[3], y = evt[4]}
			if keysDown[keys.leftCtrl] then
				table.insert(eldit.cursors, {
					x = evt[3] + eldit.scrollX - lineNoLen,
					y = evt[4] + eldit.scrollY,
					lastX = evt[3] + eldit.scrollX - lineNoLen
				})
			else
				eldit.cursors = {{
					x = evt[3] + eldit.scrollX - lineNoLen,
					y = evt[4] + eldit.scrollY,
					lastX = evt[3] + eldit.scrollX - lineNoLen
				}}
				eldit.selections = {}
			end
			lastMouse = {
				x = evt[3],
				y = evt[4],
				scrollX = eldit.scrollX,
				scrollY = eldit.scrollY,
				lineNoLen = lineNoLen,
				ctrl = keysDown[keys.leftCtrl],
				curID = #eldit.cursors,
			}
			sortSelections()
			adjustCursor(0, 0, true)
			doRender = true
		elseif evt[1] == "mouse_drag" then
			local lineNoLen = #tostring(#eldit.buffer)
			miceDown[evt[2]] = {x = evt[3], y = evt[4]}
			if lastMouse.x and lastMouse.y and lastMouse.curID then
				local adjMX, adjMY = lastMouse.x + lastMouse.scrollX, lastMouse.y + lastMouse.scrollY
				local adjEX, adjEY = evt[3] + eldit.scrollX, evt[4] + eldit.scrollY
				local selID
				if (lastMouse.ctrl and not isSelecting) or #eldit.selections == 0 then
					selID = #eldit.selections + 1
				else
					selID = #eldit.selections + 0
				end
				eldit.selections[selID] = {
					{
						x = math.min(adjMX, #(eldit.buffer[adjMY] or "") + lineNoLen) - lineNoLen,
						y = adjMY
					},
					{
						x = math.min(adjEX, #(eldit.buffer[adjEY] or "") + lineNoLen) - lineNoLen,
						y = adjEY
					}
				}
				if isSelecting then
					--lastMouse.ctrl = false
				end
				sortSelections()
				eldit.cursors[lastMouse.curID] = {
					x = eldit.selections[selID][1].x,
					y = eldit.selections[selID][1].y,
					lastX = eldit.selections[selID][1].x
				}

				isSelecting = true
				adjustCursor(0, 0)
				doRender = true
			end
		elseif evt[1] == "mouse_up" then
			miceDown[evt[2]] = nil
			isSelecting = false
			sortSelections()
		elseif evt[1] == "mouse_scroll" then
			if keysDown[keys.leftAlt] then
				adjustScroll((keysDown[keys.leftCtrl] and eldit.size.width or 1) * evt[2], 0)
			else
				adjustScroll(0, (keysDown[keys.leftCtrl] and eldit.size.height or 1) * evt[2])
			end
			if isSelecting then
				os.queueEvent("mouse_drag", 1, evt[3], evt[4])
			end
			doRender = true
		end
		if doRender then
			if not (evt[1] == "mouse_scroll" and isSelecting) then
				render()
				doRender = false
			end
		end
	end
end

if not eldit.filename then
	print("eldit [filename]")
	return
end

local contents = readFile(eldit.filename)

local result = {prompt(contents)}
if result[1] == "exit" then
	term.setBackgroundColor(colors.black)
	term.scroll(1)
	term.setCursorPos(1, scr_y)
end
