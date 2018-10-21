--[[
	PAIN image editor for ComputerCraft
	Get it with
	 wget https://raw.githubusercontent.com/LDDestroier/CC/master/pain.lua
	 std ld pain pain
	
	This is a beta release. You fool!
	To do:
		+ add special character selector
--]]
local askToSerialize = false
local defaultSaveFormat = 4 -- will change if importing image, or making new file with extension in name
--[[
	defaultSaveFormat possible parameters:
	1. NFP (paint)
	2. NFT (npaintpro)
	3. BLT (blittle)
	4. Native PAIN
	5. GIF
	6. UCG
--]]
local readNonImageAsNFP = true
local useFlattenGIF = true
local undoBufferSize = 8

local displayHelp = function()
	local progname = fs.getName(shell.getRunningProgram())
	print(progname)
	print(progname.." <filename>")
	print(progname.." [-h/--help]")
	print("Press F1 in program for more.")
end

local tsv = term.current().setVisible
local undoBuffer
local undoPos = 1
local pMode = 0
local scr_x, scr_y = term.getSize()
screenEdges = {
	scr_x,
	scr_y,
}

local tArg = {...}
if (tArg[1] == "--help" or tArg[1] == "-h") and shell then
	return displayHelp()
end

if tArg[2] == "view" then
	pMode = 1
elseif (tArg[2] == "moo") and (not fs.exists("moo")) then
	return print("This PAIN does not have Super Cow Powers.")
end

local fileName
if (not term.isColor()) and (pMode ~= 1) then
	error("PAIN only works with Advanced Computers at the moment.")
end
local barmsg = "Press F1 for help."
local tse = textutils.serialise
local tun = textutils.unserialise
local paintEncoded
local lastPaintEncoded
local frame = 1
local doRender = false
local metaHistory = {}
local bepimode = false      -- this is a family-friendly program! now stand still while I murder you
local evenDrawGrid = true   -- will you evenDraw(the)Grid ?
local renderBlittle = false -- whether or not to render all in blittle
local firstTerm, blittleTerm = term.current()
local firstBG = term.getBackgroundColor()
local firstTX = term.getTextColor()
local changedImage = false

local _
local tableconcat = table.concat

local rendback = {
	b = colors.black,
	t = colors.gray,
}

local grid

local yield = function()
	os.queueEvent("yield")
	os.pullEvent("yield")
end

local paint = {
	scrollX = 0,
	scrollY = 0,
	t = colors.gray,
	b = colors.white,
	m = 1,	--  in case you want to use PAIN as a level editor or something
	c = " ",
	doGray = false,
}
local boxchar = {topLeft = true, topRight = true, left = true, right = true, bottomLeft = true, bottomRight = true}
local swapColors = false -- swaps background and text colors, for use with those tricky box characters
local scrollX, scrollY = 0, 0

local keysDown = {}
local miceDown = {}

local doRenderBar = 1 -- Not true or false

local fixstr = function(str)
	return str:gsub("\\(%d%d%d)",string.char)
end

local choice = function(input,breakkeys,returnNumber)
	local fpos = 0
	repeat
		event, key = os.pullEvent("key")
		if type(key) == "number" then key = keys.getName(key) end
		if key == nil then key = " " end
		if type(breakkeys) == "table" then
			for a = 1, #breakkeys do
				if key == breakkeys[a] then
					return ""
				end
			end
		end
		fpos = string.find(input, key)
	until fpos
	return returnNumber and fpos or key
end
local explode = function(div,str)
    if (div=='') then return false end
    local pos,arr = 0,{}
    for st,sp in function() return string.find(str,div,pos,true) end do
        arr[#arr+1] = str:sub(pos,st-1)
        pos = sp + 1
    end
    arr[#arr+1] = str:sub(pos)
    return arr
end

local function cutString(max_line_length, str) -- from stack overflow
   local lines = {}
   local line
   str:gsub('(%s*)(%S+)', 
      function(spc, word) 
         if not line or #line + #spc + #word > max_line_length then
            lines[#lines+1] = line
            line = word
         else
            line = line..spc..word
         end
      end
   )
   lines[#lines+1] = line
   return lines
end

local getDrawingCharacter = function(topLeft, topRight, left, right, bottomLeft, bottomRight) -- thank you oli414
  local data = 128
  if not bottomRight then
        data = data + (topLeft and 1 or 0)
        data = data + (topRight and 2 or 0)
        data = data + (left and 4 or 0)
        data = data + (right and 8 or 0)
        data = data + (bottomLeft and 16 or 0)
  else
        data = data + (topLeft and 0 or 1)
        data = data + (topRight and 0 or 2)
        data = data + (left and 0 or 4)
        data = data + (right and 0 or 8)
        data = data + (bottomLeft and 0 or 16)
  end
  return {char = string.char(data), inverted = bottomRight}
end

local cutUp = function(len,tbl)
	local output = {}
	local e = 0
	local s
	for a = 1, #tbl do
		if #(tbl[a]:gsub(" ","")) == 0 then
			s = {""}
		else
			s = cutString(len,tbl[a])
		end
		for b = 1, #s do
			output[#output+1] = s[b]
		end
	end
	return output
end

local getEvents = function(...)
	local arg, output = table.pack(...)
	while true do
		output = {os.pullEvent()}
		for a = 1, #arg do
			if type(arg[a]) == "boolean" then
				if doRender == arg[a] then
					return {}
				end
			elseif output[1] == arg[a] then
				return unpack(output)
			end
		end
	end
end

local sanitize = function(sani,tize)
	local _,x = string.find(sani,tize)
	if x then
		return sani:sub(x+1)
	else
		return sani
	end
end
local ro = function(input, max)
	return math.floor(input % max)
end

local guiHelp = function(inputText)
	term.redirect(firstTerm)
	scr_x, scr_y = term.current().getSize()
	local _helpText = inputText or [[

 'PAIN' Help Page
Programmed by LDDestroier/EldidiStroyrr

(use UP/DOWN or scrollwheel, exit with Q)
If you want to use PAIN to its full capacity, then READ EVERYTHING HERE! Its not TOO long, and it's completely worth it!

Syntax:
>pain <filename> [view]
>pain [-n]
>pain [-h/--help]

[view]: disable all writing capability to view a file
"-n" or no arguments: create new document, declare name upon saving
"-h" or "--help": display short syntax help

You can see what colors are selected based on the word "PAIN" on the hotbar.

Hotkeys:
 left/right ctrl: toggle the menu

 left click:
  +shift = drag and let go to make a line
  -alone = place pixel

 right click: delete pixel

 middle click OR "t": place text down with current colors, cancel with X

 "z":
  +left alt = redo
  -alone = undo

 "p": pick colors from position onscreen, cancel with X

 "n": change box character for drawing, cancel with CTRL, N, or by clicking outside

 "[" or mouse scroll down:
  +shift = change to previous text color
  -alone = change to previous background color

 "]" or mouse scroll up:
  +shift = change to next text color
  -alone = change to next background color

 "F1":
  -alone = access help screen

 "F3:"
  -alone = view all connected monitors

 spacebar:
  +shift = toggle grid
  -alone = toggle bar visibility

 arrow keys:
  +shift = move entire picture
  +tab = move one pixel at a time
  -alone = looks around the canvas smoothly

 "+" (or equals):
  +left alt = swap the current frame with the next frame
  -alone = change to next frame

 "-":
  +left alt = swap the current frame with the previous frame
  -alone = change to previous frame

 "a": set the coordinates to 0,0

 "n": open block character selection

 "b": toggle redirect to blittle, to preview in teletext characters

 "c": input coordinates to scroll over to

 "g": toggle grayscale mode. everything is in shades of gray. if you Save, it saves in grayscale.

 "f":
  +shift = fill all empty pixels with background color and selected box character
  -alone = absolutely nothing (which is what you are about to become)

 "m": set metadata for pixels (for game makers, otherwise safe to ignore)


 Le Menu (access with CTRL):

 -left click on a menu item to select it.
 -if you click on the menubar, let go on an option to select it.

 "File > Save"
 Saves all frames to a specially formatted PAIN paint file. The format PAIN uses is very inefficient despite my best efforts, so Export if you don\39t use text or multiple frame.

"File > Save As"
 Same as "File > Save", but you change the filename.

 "File > Export"
 Exports current frame to NFP, NFT, BLT, or the horribly inefficient PAIN format.

 "Edit > Delete Frame"
 Deletes the current frame. Tells you off if you try to delete the only frame.

 "Edit > Clear"
 Deletes all pixels on the current frame.

 "Edit > Crop Frame"
 Deletes all pixels that are outside of the screen.

 "Edit > Change Box Character"
 Opens the block character selection. Used for making those delicious subpixel pictures.

 "Edit > BLittle Shrink"
 Shrinks the current frame using the BLittle API. Very lossy, and unreversable without Undo.

 "Window > Set Screen Size"
 Sets the sizes of the screen border references displayed on the canvas.

 "Window > Set Grid Colors"
 Sets the backdrop colors to your currently selected color configuration.

 "About > PAIN"
 Tells you about PAIN and its developer.

 "About > File Formats"
 Tells you the ins and outs of the file formats, and a brief description of their creators.

 "About > Help"
 Opens up this help page.

 "Exit"
 Durr I dunno, I think it exits.


I hope my PAIN causes you joy.
]]
	_helpText = explode("\n",_helpText)
	helpText = cutUp(scr_x,_helpText)
	local helpscroll = 0
	term.setBackgroundColor(colors.gray)
	term.setTextColor(colors.white)
	term.clear()
	local evt, key
	while true do
		term.clear()
		for a = 1, scr_y do
			term.setCursorPos(1,a)
			term.clearLine()
			write(helpText[a-helpscroll] or "")
		end
		repeat
			evt,key = os.pullEvent()
		until evt == "key" or evt == "mouse_scroll"
		if evt == "key" then
			if key == keys.up then
				helpscroll = helpscroll + 1
			elseif key == keys.down then
				helpscroll = helpscroll - 1
			elseif key == keys.pageUp then
				helpscroll = helpscroll + scr_y
			elseif key == keys.pageDown then
				helpscroll = helpscroll - scr_y
			elseif (key == keys.q) or (key == keys.space) then
				doRender = true
				if renderBlittle then term.redirect(blittleTerm) end
				scr_x, scr_y = term.current().getSize()
				return
			end
		elseif evt == "mouse_scroll" then
			helpscroll = helpscroll - key
		end
		if helpscroll > 0 then
			helpscroll = 0
		elseif helpscroll < -(#helpText-(scr_y-3)) then
			helpscroll = -(#helpText-(scr_y-3))
		end
	end
end

local tableRemfind = function(tbl, str)
	local out = tbl
	for a = 1, #tbl do
		if tbl[a] == str then
			table.remove(out,a)
			return out,a
		end
	end
	return {}
end

local stringShift = function(str,amt)
	return str:sub(ro(amt-1,#str)+1)..str:sub(1,ro(amt-1,#str))
end

local deepCopy
deepCopy = function(obj)
	if type(obj) ~= 'table' then return obj end
	local res = {}
	for k, v in pairs(obj) do res[deepCopy(k)] = deepCopy(v) end
	return res
end

local clearLines = function(y1, y2)
	local cx,cy = term.getCursorPos()
	for y = y1, y2 do
		term.setCursorPos(1,y)
		term.clearLine()
	end
	term.setCursorPos(cx,cy)
end

local renderBottomBar = function(txt,extraClearY)
	term.setCursorPos(1,scr_y - math.floor(#txt/scr_x))
	term.setBackgroundColor(colors.lightGray)
	term.setTextColor(colors.black)
	clearLines(scr_y - (math.floor(#txt/scr_x) - (extraClearY or 0)), scr_y)
	return write(txt)
end

local bottomPrompt = function(txt,history,cho,breakkeys,returnNumber,writeIndent)
	local writeIndent = renderBottomBar(txt,writeIndent)
	local out
	sleep(0)
	if cho then
		out = choice(cho,breakkeys,returnNumber)
	else
		out = read(_,history)
	end
	return out,writeIndent
end

local makeSubMenu = function(x,y,options)
	local longestLen = 0
	for a = 1, #options do
		if #options[a] > longestLen then
			longestLen = #options[a]
		end
	end
	longestLen = longestLen + 1
	term.setTextColor(colors.black)
	local sel = 1
	local rend = function()
		for a = #options, 1, -1 do
			term.setCursorPos(x or 1, ((y or (scr_y-1)) - (#options-1)) + (a - 1))
			term.setBackgroundColor(a == sel and colors.white or colors.lightGray)
			term.write(options[a])
			term.setBackgroundColor(colors.lightGray)
			term.write((" "):rep(longestLen-#options[a]))
		end
	end
	local usingMouse = false
	while true do
		rend()
		local evt, key, mx, my = os.pullEvent()
		if evt == "key" then
			if key == keys.up then
				sel = sel - 1
			elseif key == keys.down then
				sel = sel + 1
			elseif (key == keys.enter) or (key == keys.right) then
				return sel, longestLen
			elseif (key == keys.leftCtrl) or (key == keys.rightCtrl) or (key == keys.backspace) or (key == keys.left) then
				return false, longestLen
			end
		elseif evt == "mouse_drag" or evt == "mouse_click" then
			if (mx >= x) and (mx < x+longestLen) and (my <= y and my > y-#options) then
				sel = math.min(#options,math.max(1,(my+#options) - y))
				usingMouse = true
			else
				usingMouse = false
				if evt == "mouse_click" then
					return false
				end
			end
		elseif evt == "mouse_up" then
			if usingMouse then
				return sel, longestLen
			end
		end
		if sel > #options then sel = 1 elseif sel < 1 then sel = #options end
	end
end

local getDotsInLine = function( startX, startY, endX, endY ) -- stolen from the paintutils API...nwehehehe
	local out = {}
	startX = math.floor(startX)
	startY = math.floor(startY)
	endX = math.floor(endX)
	endY = math.floor(endY)
	if startX == endX and startY == endY then
		out = {{x=startX,y=startY}}
		return out
	end
    local minX = math.min( startX, endX )
	if minX == startX then
		minY = startY
		maxX = endX
		maxY = endY
	else
		minY = endY
		maxX = startX
		maxY = startY
	end
	local xDiff = maxX - minX
	local yDiff = maxY - minY
	if xDiff > math.abs(yDiff) then
        local y = minY
        local dy = yDiff / xDiff
        for x=minX,maxX do
            out[#out+1] = {x=x,y=math.floor(y+0.5)}
            y = y + dy
        end
    else
        local x = minX
        local dx = xDiff / yDiff
        if maxY >= minY then
            for y=minY,maxY do
                out[#out+1] = {x=math.floor(x+0.5),y=y}
                x = x + dx
            end
        else
            for y=minY,maxY,-1 do
                out[#out+1] = {x=math.floor(x+0.5),y=y}
                x = x - dx
            end
        end
    end
    return out
end

local movePaintEncoded = function(pe,xdiff,ydiff)
	local outpootis = deepCopy(pe)
	for a = 1, #outpootis do
		outpootis[a].x = outpootis[a].x+xdiff
		outpootis[a].y = outpootis[a].y+ydiff
	end
	return outpootis
end

local clearRedundant = function(dots)
	local input = {}
	local pheight = 0
	local pwidth = 0
	for a = 1, #dots do
		if dots[a].y > pheight then
			pheight = dots[a].y
		end
		if dots[a].x > pwidth then
			pwidth = dots[a].x
		end
	end
	for a = 1, #dots do
		if not input[dots[a].y] then input[dots[a].y] = {} end
		input[dots[a].y][dots[a].x] = dots[a]
	end
	local output = {}
	local frame = 0
	for y = 1, pheight do
		for x = 1, pwidth do
			if input[y] then
				if input[y][x] then
					output[#output+1] = input[y][x]
				end
			end
			if frame >= 50 then
				-- yield()
				frame = 0
			end
		end
	end
	return output
end

local grayOut = function(color)
	local c = deepCopy(_G.colors)
	local grays = {
		[c.white] = c.white,
		[c.orange] = c.lightGray,
		[c.magenta] = c.lightGray,
		[c.lightBlue] = c.lightGray,
		[c.yellow] = c.white,
		[c.lime] = c.lightGray,
		[c.pink] = c.lightGray,
		[c.gray] = c.gray,
		[c.lightGray] = c.lightGray,
		[c.cyan] = c.lightGray,
		[c.purple] = c.gray,
		[c.blue] = c.gray,
		[c.brown] = c.gray,
		[c.green] = c.lightGray,
		[c.red] = c.gray,
		[c.black] = c.black,
	}
	if (not color) or (color == " ") then return color end
	local newColor = grays[color] or 1
	return newColor
end

local getOnscreenCoords = function(tbl,_x,_y)
	local screenTbl = {}
	for a = 1, #tbl do
		if tbl[a].x+paint.scrollX > 0 and tbl[a].x+paint.scrollX <= scr_x then
			if tbl[a].y+paint.scrollY > 0 and tbl[a].y+paint.scrollY <= scr_y then
				screenTbl[#screenTbl+1] = {tbl[a].x+paint.scrollX,tbl[a].y+paint.scrollY}
			end
		end
	end
	if not _x and _y then
		return screenTbl
	else
		for a = 1, #screenTbl do
			if screenTbl[a][1] == _x and screenTbl[a][2] == _y then
				return true
			end
		end
		return false
	end
end

local fillTool = function(info,cx,cy,color,layer) -- takes a frame, not the whole paintEncoded
	local x,y
	local output = {}
	for a = 1, #info do
		if (info[a].x == cx) and (info[a].y == cy) then
			x = cx
			y = cy
			replaceColor = info[a].b
			break
		end
	end
	if not x and y then
		return
	end
	if color == replaceColor then
		return
	end
	table.insert(output,{
		["x"] = x,
		["y"] = y,
		["b"] = color,
		["t"] = color,
		["c"] = " ",
		["m"] = paint.m
	})
	local loops = 0
	local tAffectedPoints = {
		[1] = {
			x = x+tTerm.scroll.x,
			z = z+tTerm.scroll.z
		}
	}
	while #tAffectedPoints > 0 do
		if loops%200 == 0 then
			sleep(0.05)
		end
		for i=-1,1,2 do
			local x = tAffectedPoints[1]["x"]+i
			local z = tAffectedPoints[1]["z"]
			if tBlueprint[layer][x][z] == replaceColor and x >= tTerm.viewable.sX and x <= tTerm.viewable.eX and z >= tTerm.viewable.sZ and z <= tTerm.viewable.eZ then
				drawPoint(x,z,color,layer,true,true)
				table.insert(tAffectedPoints,{["x"] = x,["z"] = z})
			end
			x = tAffectedPoints[1]["x"]
			z = tAffectedPoints[1]["z"]+i
			if tBlueprint[layer][x][z] == replaceColor and x >= tTerm.viewable.sX and x <= tTerm.viewable.eX and z >= tTerm.viewable.sZ and z <= tTerm.viewable.eZ then
				drawPoint(x,z,color,layer,true,true)
				table.insert(tAffectedPoints,{["x"] = x,["z"] = z})
			end
		end
		table.remove(tAffectedPoints,1)
		loops = loops+1
	end
end

local clearAllRedundant = function(info)
	local output = {}
	for a = 1, #info do
		output[a] = clearRedundant(info[a])
		if a % 4 == 0 then yield() end
	end
	return output
end

local saveFile = function(path,info)
	local output = clearAllRedundant(info)
	local fileout = textutils.serialize(output):gsub("  ",""):gsub("\n",""):gsub(" = ","="):gsub(",}","}"):gsub("}},{{","}},\n{{")
	if #fileout >= fs.getFreeSpace(fs.getDir(path)) then
		barmsg = "Not enough space."
		return
	end
	local file = fs.open(path,"w")
	file.write(fileout)
	file.close()
end
local renderBar = function(msg,dontSetVisible)
	if (doRenderBar == 0) or renderBlittle then return end
	if tsv and (not dontSetVisible) then tsv(false) end
	term.setCursorPos(1,scr_y)
	term.setBackgroundColor(colors.lightGray)
	term.setTextColor(colors.black)
	term.clearLine()
	term.setBackgroundColor(paint.b or rendback.b)
	term.setTextColor(paint.t or rendback.t)
	term.setCursorPos(2,scr_y)
	term.write("PAIN")
	term.setBackgroundColor(colors.lightGray)
	term.setTextColor(colors.black)
	local fmsg = tableconcat({"Fr:",frame,"/",#paintEncoded," (",paint.scrollX,",",paint.scrollY,")"})
	term.setCursorPos(7,scr_y)
	term.write(msg)
	term.setCursorPos(scr_x-(#fmsg),scr_y)
	term.write(fmsg)
	if tsv and (not dontSetVisible) then tsv(true) end
end

local getTablePaint = function(pe)
	local output = {}
	for a = 1, #pe do
		if not output[pe[a].y] then output[pe[a].y] = {} end
		output[pe[a].y][pe[a].x] = pe[a]
	end
	return output
end

local renderPainyThings = function(xscroll,yscroll,doGrid)
	local yadjust = (renderBlittle and 0 or doRenderBar)
	if bepimode then
		grid = {
			"Bepis",
			"episB",
			"pisBe",
			"isBep",
			"sBepi",
		}
	else
		grid = {
			"%%..",
			"%%..",
			"%%..",
			"..%%",
			"..%%",
			"..%%",
		}
	end
	term.setBackgroundColor(rendback.b)
	term.setTextColor(rendback.t)
	local badchar = "/"
	local blittlelabel = "blittle max"
	local screenlabel = "screen max"
	
	if doGrid then
		for y = 1, scr_y - yadjust do 
			term.setCursorPos(1,y)
			-- the single most convoluted line I've ever written that works, and I love it
			term.write(stringShift(grid[ro(y+(yscroll+2),#grid)+1],xscroll+1):rep(math.ceil(scr_x/#grid[ro(y+(yscroll+2),#grid)+1])):sub(1,scr_x))
			term.setCursorPos((xscroll <= 0) and (1-xscroll) or 0,y)
			if ((screenEdges[2]+1)-yscroll) == y then --regular limit
				term.write( (string.rep("@", math.max(0,( (screenEdges[1])     ) - (#screenlabel+1)  )) ..screenlabel:gsub(" ","@"):upper().."@@"):sub(xscroll>0 and xscroll or 0):sub(1,1+screenEdges[1]) )
			elseif (((screenEdges[2]*3)+1)-yscroll) == y then --blittle limit
				term.write( (string.rep("@", math.max(0,( ((screenEdges[1]*2))   ) - (#blittlelabel+1) ))..blittlelabel:gsub(" ","@"):upper().."@@"):sub(xscroll>0 and xscroll or 0):sub(1,1+screenEdges[1]*2) )
			end
			-- Stupid easter eggs, ho! --
			if 1000-yscroll == y then
				term.setCursorPos(1000-xscroll,y)
				term.write(" What ARE you doing? Stop messing around! ")
			end
			if 2016-yscroll == y then
				term.setCursorPos(200-xscroll,y)
				term.write(" Lines don't like to be intersected, you know. ")
			end
			if 2017-yscroll == y then
				term.setCursorPos(200-xscroll,y)
				term.write(" It makes them very crossed. ")
			end
			if 800-yscroll == y then
				term.setCursorPos(1700-xscroll,y)
				term.write(" You stare deeply into the void. ")
			end
			if 801-yscroll == y then
				term.setCursorPos(1704-xscroll,y)
				term.write(" And the void ")
			end
			if 802-yscroll == y then
				term.setCursorPos(1704-xscroll,y)
				term.write(" stares back. ")
			end
			--Is this the end?--
			if (xscroll > ((screenEdges[1]*2)-scr_x)) then
				for y = 1, scr_y do
					if y+yscroll <= (screenEdges[2]*3) then
						if not (y == scr_y and doRenderBar == 1) then
							term.setCursorPos((screenEdges[1]+1)-(xscroll-screenEdges[1]),y)
							term.write("@")
						end
					end
				end
			end
			if (xscroll > (screenEdges[1]-scr_x)) then --regular limit
				for y = 1, scr_y do
					if y+yscroll <= screenEdges[2] then
						if not (y == scr_y and doRenderBar == 1) then
							term.setCursorPos((screenEdges[1]+1)-xscroll,y)
							term.write("@")
						end
					end
				end
			end
		end
		--render areas that won't save
		if xscroll < 0 then
			for y = 1, scr_y do
				if not (y == scr_y and doRenderBar == 1) then
					term.setCursorPos(1,y)
					term.write(badchar:rep(-xscroll))
				end
			end
		end
		if yscroll < 0 then
			for y = 1, -yscroll do
				if not (y == scr_y and doRenderBar == 1) then
					term.setCursorPos(1,y)
					term.write(badchar:rep(scr_x))
				end
			end
		end
	else
		for y = 1, scr_y - yadjust do
			term.setCursorPos(1,y)
			term.clearLine()
		end
	end
end

CTB = function(_color) --Color To Blit
	local blitcolors = {
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
	if _color == nil then return nil end
	return blitcolors[_color] or "f"
end

BTC = function(_color,allowZero) --Blit To Color
	local blitcolors = {
		[" "] = allowZero and 0 or nil,
		["0"] = colors.white,
		["1"] = colors.orange,
		["2"] = colors.magenta,
		["3"] = colors.lightBlue,
		["4"] = colors.yellow,
		["5"] = colors.lime,
		["6"] = colors.pink,
		["7"] = colors.gray,
		["8"] = colors.lightGray,
		["9"] = colors.cyan,
		["a"] = colors.purple,
		["b"] = colors.blue,
		["c"] = colors.brown,
		["d"] = colors.green,
		["e"] = colors.red,
		["f"] = colors.black,
	}
	if _color == nil then return nil end
	return blitcolors[_color]
end

importFromPaint = function(theInput)
	local output = {}
	local input
    if type(theInput) == "string" then
        input = explode("\n",theInput)
    else
        input = {}
        for y = 1, #theInput do
            input[y] = ""
            for x = 1, #theInput[y] do
                input[y] = input[y]..(CTB(theInput[y][x]) or " ")
            end
        end
    end
	for a = 1, #input do
		line = input[a]
		for b = 1, #line do
			if (line:sub(b,b) ~= " ") and BTC(line:sub(b,b)) then
				output[#output+1] = {
					x = b,
					y = a,
					t = colors.white,
					b = BTC(line:sub(b,b)) or colors.black,
					c = " ",
				}
			end
		end
	end
	return output
end

local getBlittle = function()
	if not blittle then
		if fs.exists("/.painapi/blittle") then
			os.loadAPI("/.painapi/blittle")
			if not blittleTerm then
				blittleTerm = blittle.createWindow()
			end
			return blittleTerm, firstTerm
		else
			local geet = http.get("http://pastebin.com/raw/ujchRSnU")
			if not geet then
				return false
			else
				geet = geet.readAll()
				local file = fs.open("/.painapi/blittle","w")
				file.write(geet)
				file.close()
				os.loadAPI("/.painapi/blittle")
				--fs.delete("/.painapi/")
				if not blittleTerm then
					blittleTerm = blittle.createWindow()
				end
				return blittleTerm, firstTerm
			end
		end
	else
		if not blittleTerm then
			blittleTerm = blittle.createWindow()
		end
		return blittleTerm, firstTerm
	end
end

local getUCG = function()
	if not ucg then
		if fs.exists("/.painapi/ucg") then
			os.loadAPI("/.painapi/ucg")
			return true
		else
			local geet = http.get("https://raw.githubusercontent.com/ardera/libucg/master/src/libucg")
			if not geet then
				return false
			else
				geet = geet.readAll()
				local file = fs.open("/.painapi/ucg","w")
				file.write(geet)
				file.close()
				os.loadAPI("/.painapi/ucg")
			end
		end
	end
end

local getBitmap = function()
	if not bitmap then
		if fs.exists("/.painapi/bitmap") then
			os.loadAPI("/.painapi/bitmap")
			return true
		else
			local geet = http.get("https://pastebin.com/raw/Y3JeZWzV")
			if not geet then
				return false
			else
				geet = geet.readAll()
				local file = fs.open("/.painapi/bitmap","w")
				file.write(geet)
				file.close()
				os.loadAPI("/.painapi/bitmap")
			end
		end
	end
end

local getBBPack = function()
	if not bbpack then
		if fs.exists("/.painapi/bbpack") then
			os.loadAPI("/.painapi/bbpack")
			return true
		else
			local geet = http.get("https://pastebin.com/raw/cUYTGbpb")
			if not geet then
				return false
			else
				geet = geet.readAll()
				local file = fs.open("/.painapi/bbpack","w")
				file.write(geet)
				file.close()
				os.loadAPI("/.painapi/bbpack")
			end
		end
	end
end

local getGIF = function()
	getBBPack()
	if not GIF then
		if fs.exists("/.painapi/GIF") then
			os.loadAPI("/.painapi/GIF")
			return true
		else
			local geet = http.get("https://pastebin.com/raw/5uk9uRjC")
			if not geet then
				return false
			else
				geet = geet.readAll()
				local file = fs.open("/.painapi/GIF","w")
				file.write(geet)
				file.close()
				os.loadAPI("/.painapi/GIF")
			end
		end
	end
end

local NFPserializeImage = function(str)
	local bepis = explode("\n",str)
	local output = {}
	for y = 1, #bepis do
		output[y] = {}
		for x = 1, #bepis[y] do
			output[y][x] = BTC(bepis[y]:sub(x,x),true)
		end	
	end
	return textutils.unserialize(textutils.serialize(output):gsub("\n",""):gsub(" ",""):gsub(",}","}"))
end

local importFromBitmap = function(fileName)
	getBitmap()
	local image = bitmap.ImageHelpers.parseFile(fileName).pixels
	local output = {}
	local closest, termSets = bitmap.Colors.findClosestColor, bitmap.Colors.termSets
	for y = 1, #image do
		local line = image[y]
		for x = 1, #line do
			output[#output+1] = {
				x = x,
				y = y,
				t = colors.white,
				c = " ",
				b = closest(termSets, unpack(line[x])),
				m = 0,
			}
		end
	end
	return output
end

local exportToBitmap = function(theInput)
	getBitmap()
	--er, I don't think this is possible at the moment
end

local importFromGIF = function(filename,verbose)
	getGIF()
	local output = {}
	local image
	local rawGif = GIF.loadGIF(filename)
	if useFlattenGIF then
		if verbose then
			print("Flattening...")
		end
		rawGif = GIF.flattenGIF(rawGif)
		sleep(0)
	end
	local cx, cy = term.getCursorPos()
	for a = 1, #rawGif do
		output[a] = importFromPaint(GIF.toPaintutils(rawGif[a]))
		if verbose then
			term.setCursorPos(cx,cy)
			write("Did "..a.."/"..#rawGif.." ")
		end
		if a % 1 then sleep(0) end --used to be a % 2, might change later
	end
	return output
end

local exportToPaint

local exportToGIF = function(input)
	getGIF()
	local outGIF = {}
	for a = 1, #paintEncoded do
		outGIF[a] = NFPserializeImage(exportToPaint(paintEncoded[a]))
		sleep(0)
	end
	if useFlattenGIF then
		return GIF.flattenGIF(GIF.buildGIF(table.unpack(outGIF)),true)
	else
		return GIF.buildGIF(table.unpack(outGIF))
	end
end

local importFromUCG = function(filename)
	getUCG()
	return importFromPaint(ucg.readFile(filename))
end

local exportToUCG = function(filename, input)
	getUCG()
	ucg.writeFile(filename, NFPserializeImage(exportToPaint(input)))
end

renderPAIN = function(dots,xscroll,yscroll,doPain,dontRenderBar)
	if tsv then tsv(false) end
	local beforeTX,beforeBG = term.getTextColor(), term.getBackgroundColor()
	local cx,cy = term.getCursorPos()
	local FUCK, SHIT = pcall(function()
		if doPain then
			if (not renderBlittle) then
				if not dontRenderBar then
					renderBar(barmsg,true)
				end
				renderPainyThings(xscroll,yscroll,evenDrawGrid)
			else
				term.clear()
			end
		end
		for a = 1, #dots do
			local d = dots[a]
			if doPain then
				if not ((d.y-yscroll >= 1 and d.y-yscroll <= scr_y-(renderBlittle and 0 or doRenderBar)) and (d.x-xscroll >= 1 and d.x-xscroll <= scr_x)) then
					d = nil
				end
			end
			if d then
				term.setCursorPos(d.x-(xscroll or 0),d.y-(yscroll or 0))
				term.setTextColor(      (paint.doGray and grayOut(d.t) or d.t) or rendback.t)
				term.setBackgroundColor((paint.doGray and grayOut(d.b) or d.b) or rendback.b)
				term.write(d.c or " ")
			end
		end
	end)
	term.setBackgroundColor(beforeBG or rendback.b)
	term.setTextColor(beforeTX or rendback.t)
	term.setCursorPos(cx,cy)
	if tsv then tsv(true) end
	if not FUCK then error(SHIT) end --GOD DAMN IT
end

renderPAINFS = function(filename,xscroll,yscroll,frameNo,doPain)
	local tun, tse = textutils.unserialize, textutils.serialize
	local file = fs.open(filename,"r")
	local contents = file.readAll()
	local amntFrames
	file.close()
	local tcontents = tun(contents)
	if type(tcontents) ~= "table" then
		tcontents = importFromPaint(contents)
	else
		amntFrames = #tcontents
		tcontents = tcontents[frameNo or 1]
	end
	renderPAIN(tcontents,xscroll,yscroll,doPain)
	return amntFrames
end

local putDotDown = function(dot) -- only 'x' and 'y' are required arguments
	paintEncoded[frame][#paintEncoded[frame]+1] = {
		x = dot.x + paint.scrollX,
		y = dot.y + paint.scrollY,
		c = dot.c or paint.c,
		b = dot.b or (swapColors and paint.t or paint.b),
		t = dot.t or (swapColors and paint.b or paint.t),
		m = dot.m or paint.m,
	}
end

local saveToUndoBuffer = function()
	if undoPos < #undoBuffer then
		for a = #undoBuffer, undoPos+1, -1 do
			table.remove(undoBuffer,a)
		end
	end
	if undoPos >= undoBufferSize then
		for a = 2, #undoBuffer do
			undoBuffer[a-1] = undoBuffer[a]
		end
		undoBuffer[#undoBuffer] = deepCopy(paintEncoded)
	else
		undoPos = undoPos + 1
		undoBuffer[undoPos] = deepCopy(paintEncoded)
	end
end

local doUndo = function()
	undoPos = math.max(1,undoPos-1)
	paintEncoded = deepCopy(undoBuffer[undoPos])
	if not paintEncoded[frame] then
		frame = #paintEncoded
	end
end

local doRedo = function()
	undoPos = math.min(#undoBuffer,undoPos+1)
	paintEncoded = deepCopy(undoBuffer[undoPos])
	if not paintEncoded[frame] then
		frame = #paintEncoded
	end
end

local putDownText = function(x,y)
	term.setCursorPos(x,y)
	term.setTextColor((paint.doGray and grayOut(paint.t or rendback.t)) or (paint.t or rendback.t))
	term.setBackgroundColor((paint.doGray and grayOut(paint.b or rendback.b)) or (paint.b or rendback.b))
	local msg = read()
	if #msg > 0 then
		for a = 1, #msg do
			putDotDown({x=(x+a)-1, y=y, c=msg:sub(a,a)})
		end
	end
	saveToUndoBuffer()
end

local deleteDot = function(x,y) --deletes all dots at point x,y
	local good = false
	for a = #paintEncoded[frame],1,-1 do
		local b = paintEncoded[frame][a]
		if (x == b.x) and (y == b.y) then
			table.remove(paintEncoded[frame],a)
			good = true
		end
	end
	return good
end

exportToPaint = function(input,noTransparent) --exports paintEncoded frame to regular paint format. input is expected to be paintEncoded[frame]
	local doopTXT, doopTXCOL, doopBGCOL = {}, {}, {}
	local p = input
	local pheight = 0
	local pwidth = 0
	for a = 1, #p do
		if p[a].y > pheight then
			pheight = p[a].y
		end
		if p[a].x > pwidth then
			pwidth = p[a].x
		end
	end
	for k,v in pairs(p) do
		if not doopBGCOL[v.y] then
			doopBGCOL[v.y] = {}
			doopTXCOL[v.y] = {}
			doopTXT[v.y] = {}
		end
		doopBGCOL[v.y][v.x] = CTB(v.b)
		doopTXCOL[v.y][v.x] = CTB(v.t)
		doopTXT[v.y][v.x] = v.c
	end
	local nfpoutputTXT, nfpoutputTXCOL, nfpoutputBGCOL = "", "", ""
	for y = 1, pheight do
		if doopBGCOL[y] then
			for x = 1, pwidth do
				if doopBGCOL[y][x] then
					nfpoutputBGCOL = nfpoutputBGCOL..doopBGCOL[y][x]
					nfpoutputTXCOL = nfpoutputTXCOL..doopTXCOL[y][x]
					nfpoutputTXT = nfpoutputTXT..(((doopTXT[y][x] == " " and noTransparent) and "\128" or doopTXT[y][x]) or " ")
				else
					nfpoutputBGCOL = nfpoutputBGCOL..(noTransparent and "0" or " ")
					nfpoutputTXCOL = nfpoutputTXCOL..(noTransparent and "0" or " ")
					nfpoutputTXT = nfpoutputTXT.." "
				end
			end
		end
		if y ~= pheight then
			nfpoutputBGCOL = nfpoutputBGCOL.."\n"
			nfpoutputTXCOL = nfpoutputTXCOL.."\n"
			nfpoutputTXT = nfpoutputTXT.."\n"
		end
	end
	return nfpoutputBGCOL, pheight, pwidth
end

local exportToNFT = function(input)
	local pwidths = {}
	local doot = {}
	local pheight = 0
	for k, dot in pairs(input) do
		pwidths[dot.y] = math.max((pwidths[dot.y] or 0), dot.x)
		pheight = math.max(pheight, dot.y)
		doot[dot.y] = doot[dot.y] or {}
		doot[dot.y][dot.x] = {
			char = dot.c,
			text = CTB(dot.t),
			back = CTB(dot.b)
		}
	end
	
	local bgcode, txcode = "\30", "\31"
	local output = ""
	local text, back
	
	for y = 1, pheight do
		pwidths[y] = pwidths[y] or 0
		if doot[y] then
			for x = 1, pwidths[y] do
				doot[y][x] = doot[y][x] or {
					text = " ",
					back = " ",
					char = " ",
				}
			end
		else
			doot[y] = false
		end
	end

	for y = 1, pheight do
		
		text, back = "0", "f"
		if doot[y] then
			for x = 1, pwidths[y] do
				
				if doot[y][x] then
					if doot[y][x].back ~= back then
						back = doot[y][x].back
						output = output .. bgcode .. back
					end
					if doot[y][x].text ~= text then
						text = doot[y][x].text
						output = output .. txcode .. text
					end
					output = output .. doot[y][x].char
				else
					output = output .. " "
				end
				
			end
		end
		
		if y < pheight then
			output = output .. "\n"
		end
	end
	return output
end

local importFromNFT = function(input) --imports NFT formatted string image to paintEncoded[frame] formatted table image. please return a paintEncoded[frame] formatted table.
	local tinput = explode("\n",input)
	local tcol,bcol
	local cx --represents the x position in the picture
	local sx --represents the x position in the file
	local output = {}
	for y = 1, #tinput do
		tcol,bcol = colors.white,colors.black
		cx, sx = 1, 0
		while sx < #tinput[y] do
			sx = sx + 1
			if tinput[y]:sub(sx,sx) == "\30" then
				bcol = BTC(tinput[y]:sub(sx+1,sx+1))
				sx = sx + 1
			elseif tinput[y]:sub(sx,sx) == "\31" then
				tcol = BTC(tinput[y]:sub(sx+1,sx+1))
				sx = sx + 1
			else
				if tcol and bcol then
					output[#output+1] = {
						["x"] = cx,
						["y"] = y,
						["b"] = bcol,
						["t"] = tcol,
						["c"] = tinput[y]:sub(sx,sx),
						["m"] = 0,
					}
				end
				cx = cx + 1
			end
		end
	end
	return output
end

exportToBLT = function(input,filename,doAllFrames,noSave)
	local output = {}
	local thisImage,pheight,pwidth,nfpinput
	getBlittle()
	for a = doAllFrames and 1 or frame, doAllFrames and #input or frame do
		output[#output+1] = blittle.shrink(NFPserializeImage(exportToPaint(input[a]),true),colors.black)
	end
	if #output == 1 then output = output[1] end
	if not noSave then
		blittle.save(output,filename)
	end
	return output
end

importFromBLT = function(input) --takes in filename, not contents
	local output = {}
	getBlittle()
	local wholePic = blittle.load(input)
	if wholePic.height then wholePic = {wholePic} end
	local image
	for a = 1, #wholePic do
		image = wholePic[a]
		output[#output+1] = {}
		for y = 1, image.height*3 do
			for x = 1, math.max(#image[1][math.ceil(y/3)],#image[2][math.ceil(y/3)],#image[3][math.ceil(y/3)])*2 do
				output[#output][#output[#output]+1] = {
					m = 0,
					x = x,
					y = y,
					t = BTC((image[2][math.ceil(y/3)]:sub(math.ceil(x/2),math.ceil(x/2)).."0"):sub(1,1)),
					b = BTC((image[3][math.ceil(y/3)]:sub(math.ceil(x/2),math.ceil(x/2)).."0"):sub(1,1)),
					c = BTC((image[1][math.ceil(y/3)]:sub(math.ceil(x/2),math.ceil(x/2)).." "):sub(1,1)),
				}
			end
		end
	end
	return output
end

local getTheDoots = function(pe)
	local hasBadDots = false
	local baddestX,baddestY = 1,1
	for b = 1, #pe do
		local doot = pe[b]
		if doot.x <= 0 or doot.y <= 0 then
			hasBadDots = true
			if doot.x < baddestX then
				baddestX = doot.x
			end
			if doot.y < baddestY then
				baddestY = doot.y
			end
		end
		if b % 64 == 0 then yield() end
	end
	return baddestX, baddestY
end

local checkBadDots = function()
	local hasBadDots = false
	for a = 1, #paintEncoded do
		local radx,rady = getTheDoots(paintEncoded[a])
		if radx ~= 1 or rady ~= 1 then
			hasBadDots = true
		end
	end
	if hasBadDots then
		local ting = bottomPrompt("Dot(s) are OoB! Save or fix? (Y/N/F)",_,"ynf",{keys.leftCtrl,keys.rightCtrl})
		if ting == "f" then
			for a = 1, #paintEncoded do
				local baddestX, baddestY = getTheDoots(paintEncoded[a])
				paintEncoded[a] = movePaintEncoded(paintEncoded[a],-(baddestX-1),-(baddestY-1))
			end
		elseif ting ~= "y" then
			barmsg = ""
			return false
		end
	end
end

local convertToGrayscale = function(pe)
	local output = pe
	for a = 1, #pe do
		for b = 1, #pe[a] do
			output[a][b].b = grayOut(pe[a][b].b)
			output[a][b].t = grayOut(pe[a][b].t)
			if not output[a][b].m then output[a][b].m = 1 end
		end
		if a % 2 == 0 then yield() end
	end
	return output
end

local reRenderPAIN = function()
	local _reallyDoRenderBar = doRenderBar
	doRenderBar = 1
	renderPAIN(paintEncoded[frame],paint.scrollX,paint.scrollY,true,true)
	doRenderBar = _reallyDoRenderBar
end

local boxCharSelector = function()
	local co = function(pos)
		if pos then
			term.setTextColor(colors.lime)
			term.setBackgroundColor(colors.green)
		else
			term.setTextColor(colors.lightGray)
			term.setBackgroundColor(colors.gray)
		end
	end
	local rend = function()
		term.setCursorPos(4,scr_y)
		term.setBackgroundColor(colors.lightGray)
		term.setTextColor(colors.gray)
		term.clearLine()
		term.write("Press CTRL when ready.")
		term.setCursorPos(1,scr_y-2) co(boxchar.topLeft) write("Q") co(boxchar.topRight) write("W")
		term.setCursorPos(1,scr_y-1) co(boxchar.left) write("A") co(boxchar.right) write("S")
		term.setCursorPos(1,scr_y-0) co(boxchar.bottomLeft) write("Z") co(boxchar.bottomRight) write("X")
	end
	while true do
		rend()
		local evt = {os.pullEvent()}
		if evt[1] == "key" then
			local key = evt[2]
			if key == keys.leftCtrl or key == keys.rightCtrl or key == keys.n then
				break
			else
				if key == keys.q then boxchar.topLeft = not boxchar.topLeft end
				if key == keys.w then boxchar.topRight = not boxchar.topRight end
				if key == keys.a then boxchar.left = not boxchar.left end
				if key == keys.s then boxchar.right = not boxchar.right end
				if key == keys.z then boxchar.bottomLeft = not boxchar.bottomLeft end
				if key == keys.x then boxchar.bottomRight = not boxchar.bottomRight end
			end
		elseif evt[1] == "mouse_click" or evt[1] == "mouse_drag" then
			local button, mx, my = evt[2], evt[3], evt[4]
			if my >= scr_y-2 then
				if mx == 1 then
					if my == scr_y - 2 then boxchar.topLeft = not boxchar.topLeft end
					if my == scr_y - 1 then boxchar.left = not boxchar.left end
					if my == scr_y - 0 then boxchar.bottomLeft = not boxchar.bottomLeft end
				elseif mx == 2 then
					if my == scr_y - 2 then boxchar.topRight = not boxchar.topRight end
					if my == scr_y - 1 then boxchar.right = not boxchar.right end
					if my == scr_y - 0 then boxchar.bottomRight = not boxchar.bottomRight end
				elseif evt[1] == "mouse_click" then
					break
				end
			elseif evt[1] == "mouse_click" then
				break
			end
		end
	end
	if boxchar.topLeft and boxchar.topRight and boxchar.left and boxchar.right and boxchar.bottomLeft and boxchar.bottomRight then
		swapColors = false
		return " "
	else
		local output = getDrawingCharacter(boxchar.topLeft, boxchar.topRight, boxchar.left, boxchar.right, boxchar.bottomLeft, boxchar.bottomRight)
		swapColors = not output.inverted
		return output.char
	end
end

local specialCharSelector = function()
	local sy = scr_y - 9
	local chars = {}
	local buff = 0
	for y = 1, 16 do
		for x = 1, 16 do
			chars[y] = chars[y] or {}
			chars[y][x] = string.char(buff)
                        buff = buff + 1
		end
	end
	local char = paint.c
	local render = function()
		for y = 1, #chars do
			for x = 1, #chars do
				term.setCursorPos(x,y+sy)
				if chars[y][x] == char then
					term.blit(chars[y][x], "5", "d")
				else
					term.blit(chars[y][x], "8", "7")
				end
			end
		end
	end
	local evt, butt, x, y
	render()
	while true do
		evt, butt, x, y = os.pullEvent()
		if evt == "mouse_click" then
			if chars[y-sy] then
				if chars[y-sy][x] then
					if (chars[y-sy][x] ~= char) then
						char = chars[y-sy][x]
						render()
					end
				else
					return char
				end
			else
				return char
			end
		elseif evt == "key" then
			if key == keys.c or key == keys.q then
				return char
			end
		end
	end
end

local dontDragThisTime = false
local resetInputState = function()
	miceDown = {}
	keysDown = {}
	isDragging = false
	dontDragThisTime = true
end

local gotoCoords = function()
	local newX = bottomPrompt("Goto X:")
	newX = tonumber(newX)
	local newY
		if newX then
		newY = bottomPrompt("Goto Y:")
		newY = tonumber(newY)
		paint.scrollX = newX or paint.scrollX
		paint.scrollY = newY or paint.scrollY
	end
end

local renderAllPAIN = function()
	renderPAIN(paintEncoded[frame],paint.scrollX,paint.scrollY,true)
end

local displayMenu = function()
	menuOptions = {"File","Edit","Window","About","Exit"}
	local diss = " "..tableconcat(menuOptions," ")
	local cleary = scr_y-math.floor(#diss/scr_x)

	local fileSave = function()
		checkBadDots()
		local output = deepCopy(paintEncoded)
		if paint.doGray then
			output = convertToGrayscale(output)
		end
		doRender = true
		if not fileName then
			renderBottomBar("Save as: ")
			local fnguess = read()
			if fs.isReadOnly(fnguess) then
				barmsg = "'"..fnguess.."' is read only."
				return false
			elseif fnguess:gsub(" ","") == "" then
				return false
			elseif fs.isDir(fnguess) then
				barmsg = "'"..fnguess.."' is already a directory."
				return false
			elseif #fnguess > 255 then
				barmsg = "Filename is too long."
				return false
			else
				fileName = fnguess
			end
		end
		saveFile(fileName,output)
		term.setCursorPos(9,scr_y)
		return fileName
	end
	local filePrint = function()
		local usedDots, dot = {}, {}
		for a = 1, #paintEncoded[frame] do
			dot = paintEncoded[frame][a]
			if dot.x > paint.scrollX and dot.x < (paint.scrollX + 25) and dot.y > paint.scrollX and dot.y < (paint.scrollY + 21) then
				if dot.c ~= " " then
					usedDots[dot.t] = usedDots[dot.t] or {}
					usedDots[dot.t][#usedDots[dot.t]+1] = {
						x = dot.x - paint.scrollX,
						y = dot.y - paint.scrollY,
						char = dot.c
					}
				end
			end
		end
		local dyes = {
			[1] = "bonemeal",
			[2] = "orange dye",
			[4] = "magenta dye",
			[8] = "light blue dye",
			[16] = "dandelion yellow",
			[32] = "lime dye",
			[64] = "pink dye",
			[128] = "gray dye",
			[256] = "light gray dye",
			[512] = "cyan dye",
			[1024] = "purple dye",
			[2048] = "lapis lazuli",
			[4096] = "cocoa beans",
			[8192] = "cactus green",
			[16384] = "rose red",
			[32768] = "ink sac",
		}
		local printer = peripheral.find("printer")
		if not printer then
			barmsg = "No printer found."
			return false
		end
		local page
		for color, dotList in pairs(usedDots) do
			term.setBackgroundColor(colors.black)
			term.setTextColor((color == colors.black) and colors.gray or color)
			term.clear()
			cwrite("Please insert "..dyes[color].." into the printer.", nil, math.floor(scr_y/2))
			term.setTextColor(colors.lightGray)
			cwrite("Then, press spacebar.", nil, math.floor(scr_y/2) + 1)
			local evt
			sleep(0)
			repeat
				evt = {os.pullEvent("key")}
			until evt[2] == keys.space
			page = page or printer.newPage()
			if not page then
				barmsg = "Check ink/paper."
				return
			end
			for k,v in pairs(usedDots[color]) do
				printer.setCursorPos(v.x, v.y)
				printer.write(v.char)
			end
		end
		printer.endPage()
		barmsg = "Printed."
	end
	local fileExport = function(menuX,getRightToIt,_fileName)
		local exportMode
		if not tonumber(getRightToIt) then
			exportMode = makeSubMenu(menuX or 8,scr_y-2,{"Paint","NFT","BLT","PAIN Native","GIF","UCG"})
		else
			exportMode = getRightToIt
		end
		doRender = true
		if exportMode == false then return false end
		local pe, exportName, writeIndent, result
		if exportMode == 4 then
			local exNm = fileSave()
			if exNm then
				changedImage = false
				return exNm
			else
				return nil
			end
		else
			checkBadDots()
			if _fileName then
				exportName, writeIndent = _fileName, #_fileName
			else
				exportName, writeIndent = bottomPrompt("Export to: /")
			end
			nfpoutput = ""
			if fs.combine("",exportName) == "" then
				barmsg = "Export cancelled."
				return
			end
			if fs.isReadOnly(exportName) then
				barmsg = "That's read-only."
				return
			end
			if fs.exists(exportName) and (not _fileName) then
				local plea = (shell.getRunningProgram() == fs.combine("",exportName)) and "Overwrite ORIGINAL file!?" or "Overwrite?"
				result, _wIn = bottomPrompt(plea.." (Y/N)",_,"yn",{keys.leftCtrl,keys.rightCtrl})
				writeIndent = writeIndent + _wIn
				if result ~= "y" then return end
			end
			local output
			pe = deepCopy(paintEncoded)
			if paint.doGray then
				pe = convertToGrayscale(pe)
			end
			local doSerializeBLT = false
		end
		if exportMode == 1 then
			output = exportToPaint(pe[frame])
			if askToSerialize then
				result, _wIn = bottomPrompt("Save as serialized? (Y/N)",_,"yn",{})
				writeIndent = writeIndent + _wIn
			else result, _wIn = "n", 0 end
			if result == "y" then
				output = textutils.serialize(NFPserializeImage(output)):gsub(" ",""):gsub("\n",""):gsub(",}","}")
			end
		elseif exportMode == 2 then
			output = exportToNFT(pe[frame])
		elseif exportMode == 3 then
			local doAllFrames, _wIn = bottomPrompt("Save all frames, or current? (Y/N)",_,"yn",{keys.leftCtrl,keys.rightCtrl},writeIndent)
			writeIndent = writeIndent + _wIn
			if askToSerialize then
				doSerializeBLT = bottomPrompt("Save as serialized? (Y/N)",_,"yn",{},writeIndent) == "y"
			end
			output = textutils.serialise(exportToBLT(pe,exportName,doAllFrames == "y",doSerializeBLT))
		elseif exportMode == 5 then
			getGIF()
			GIF.saveGIF(exportToGIF(pe),exportName)
		elseif exportMode == 6 then
			exportToUCG(exportName,pe[frame])
		end
		if ((exportMode ~= 3) and (exportMode ~= 4) and (exportMode ~= 5) and (exportMode ~= 6)) or doSerializeBLT then
			local file = fs.open(exportName,"w")
			file.write(output)
			file.close()
		end
		return exportName
	end

	local editDelFrame = function()
		local outcum = bottomPrompt("Thou art sure? (Y/N)",_,"yn",{keys.leftCtrl,keys.rightCtrl})
		doRender = true
		if outcum == "y" then
			if #paintEncoded == 1 then
				barmsg = "Fat chance."
				return
			end
			table.remove(paintEncoded,frame)
			barmsg = "Deleted frame "..frame.."."
			if paintEncoded[frame-1] then
				frame = frame - 1
			else
				frame = frame + 1
			end
			if #paintEncoded < frame then
				repeat
					frame = frame - 1
				until #paintEncoded >= frame
			end
			saveToUndoBuffer()
		end
	end
	local editClear = function()
		local outcum = bottomPrompt("Clear the frame? (Y/N)",_,"yn",{keys.leftCtrl,keys.rightCtrl})
		if outcum == "y" then
			paintEncoded[frame] = {}
			saveToUndoBuffer()
			barmsg = "Cleared frame "..frame.."."
		end
		doRender = true
	end
	local editCrop = function()
		local outcum = bottomPrompt("Crop all but visible? (Y/N)",_,"yn",{keys.leftCtrl,keys.rightCtrl})
		if outcum == "y" then
			local ppos = 1
			local deletedAmnt = 0
			for a = #paintEncoded[frame], 1, -1 do
				local x, y = paintEncoded[frame][a].x, paintEncoded[frame][a].y
				if (x <= paint.scrollX) or (x > paint.scrollX + scr_x) or (y <= paint.scrollY) or (y > paint.scrollY + scr_y) then
					table.remove(paintEncoded[frame],a)
					deletedAmnt = deletedAmnt + 1
				else
					ppos = ppos + 1
				end
				if ppos > #paintEncoded[frame] then break end
			end
			saveToUndoBuffer()
			barmsg = "Cropped frame."
		end
		doRender = true
	end
	local editBoxCharSelector = function()
		paint.c = boxCharSelector()
	end
	local editSpecialCharSelector = function()
		paint.c = boxCharSelector()
	end

	local windowSetScrSize = function()
		local x,y
		x = bottomPrompt("Scr.X OR monitor name:",{},nil,{keys.leftCtrl,keys.rightCtrl})
		if x == "" then
			return
		elseif x == "pocket" then
			screenEdges = {26,20}
		elseif x == "turtle" then
			screenEdges = {39,13}
		elseif x == "computer" then
			screenEdges = {51,19}
		elseif tonumber(x) then
			if tonumber(x) <= 0 then
				barmsg = "Screen X must be greater than 0."
				return
			end
			screenEdges[1] = math.abs(tonumber(x))
			y = bottomPrompt("Scr.Y:",{},nil,{keys.leftCtrl,keys.rightCtrl})
			if tonumber(y) then
				if tonumber(y) <= 0 then
					barmsg = "Screen Y must be greater than 0."
					return
				end
				screenEdges[2] = math.abs(tonumber(y))
			end
			barmsg = "Screen size changed."
		else
			local mon = peripheral.wrap(x)
			if not mon then
				barmsg = "No such monitor."
				return
			else
				if peripheral.getType(x) ~= "monitor" then
					barmsg = "That's not a monitor."
					return
				else
					screenEdges[1], screenEdges[2] = mon.getSize()
					barmsg = "Screen size changed."
					return
				end
			end
		end
	end
	local aboutPAIN = function()
		local helpText = [[
 
 ### ### ### #  #
 # # # #  #  ## #
 ### ###  #  # ##
 #   # #  #  #  #
 #   # # ### #  #

Advanced Paint Editor
 by LDDestroier
 or EldidiStroyrr
  if you please!

PAIN is a multi-frame paint program with the intention of becoming a stable, well-used CC drawing utility.

The main focus during development is to add more functions that you might see in MSPAINT such as lines or a proper fill tool (which I don't have, yet), as well as to export/import to and from as many image formats as possible.

My ultimate goal is to have PAIN be the default paint program for most every operating system on the forums. In order to do this, I'll need to make sure that PAIN is stable, easy to use, and can be easily limited by an OS to work with more menial tasks like making a single icon or what have you.
]]
		guiHelp(helpText)
	end
	local aboutFileFormats = function()
		local helpText = [[
Here's info on the file formats.

 "NFP":
Used in rom/programs/paint, and the format for paintutils. It's a handy format, but the default rendering function is inefficient as hell, and it does not store text data, only background.
Cannot save multiple frames.

 "NFT":
Used in npaintpro and most everything else, it's my favorite of the file formats because it does what NFP does, but allows for text in the pictures. Useful for storing screenshots or small icons where an added level of detail is handy. Created by nitrogenfingers, thank him.
Cannot save multiple frames.

 "BLT":
Used exclusively with Bomb Bloke's BLittle API, and as such is handy with making pictures with block characters. Just keep in mind that those 2*3 grid squares in PAIN represent individual characters in BLT.
BLT can save multiple frames!

 "PAIN Native":
The basic, tabular, and wholly inefficient format that PAIN uses. Useful for doing math within the program, not so much for long term file storage. It stores text, but just use NFT if you don't need multiple frames.
Obviously, this can save multiple frames.

 "GIF":
The API was made by Bomb Bloke, huge thanks for that, but GIF is a universal file format used in real paint programs. Very useful for converting files on your computer to something like NFP, but doesn't store text. Be careful when opening up big GIF files, they can take a long time to load.
Being GIF, this saves multiple frames!

 "UCG":
Stands for Universal Compressed Graphics. This format was made by ardera, and uses Huffman Code and run-length encoding in order to reduce file sizes tremendously. However, it only saves backgrounds and not text data.
Cannot save multiple frames.


I recommend using NFT if you don't need frames, NFP if you don't need text, UCG if the picture is really big, Native PAIN if you need both text and multiframe support, and GIF if you want to use something like MS Paint or Pinta or Gimp or whatever.
]]
		guiHelp(helpText)
	end
	local menuPoses = {}
	local menuFunctions = {
		[1] = function() --File
			while true do
				--renderAllPAIN()
				local output, longestLen = makeSubMenu(1,cleary-1,{"Save","Save As","Export",((peripheral.find("printer")) and "Print" or nil)})
				doRender = true
				if output == 1 then --Save
					local _fname = fileExport(_,defaultSaveFormat,fileName)
					if _fname then
						barmsg = "Saved as '".._fname.."'"
						lastPaintEncoded = deepCopy(paintEncoded)
						changedImage = false
					end
					break
				elseif output == 2 then --Save As
					local oldfilename = fileName
					fileName = nil
					local res = fileExport(_,defaultSaveFormat)
					if not res then
						fileName = oldfilename
					end
					barmsg = "Saved as '"..fileName.."'"
				elseif output == 3 then --Export
					local res = fileExport(longestLen+1)
					if res then
						barmsg = "Exported as '"..res.."'"
						break
					end
				elseif output == 4 then --Print
					filePrint()
					break
				elseif output == false then
					return "nobreak"
				end
				reRenderPAIN()
			end
		end,
		[2] = function() --Edit
			local output = makeSubMenu(6,cleary-1,{"Delete Frame","Clear Frame","Crop Frame","Choose Box Character","Choose Special Character","BLittle Shrink"})
			doRender = true
			if output == 1 then
				editDelFrame()
			elseif output == 2 then
				editClear()
			elseif output == 3 then
				editCrop()
			elseif output == 4 then
				editBoxCharSelector()
			elseif output == 5 then
				editSpecialCharSelector()
			elseif output == 6 then
				local res = bottomPrompt("You sure? It's unreversable! (Y/N)",_,"yn",{keys.leftCtrl,keys.rightCtrl})
				if res == "y" then
					getBlittle()
					local bltPE = blittle.shrink(NFPserializeImage(exportToPaint(paintEncoded[frame])))
					_G.SHRINKOUT = bltPE
					paintEncoded[frame] = {}
					for y = 1, bltPE.height do
						for x = 1, bltPE.width do
							paintEncoded[frame][#paintEncoded[frame]+1] = {
								c = bltPE[1][y]:sub(x,x),
								t = BTC(bltPE[2][y]:sub(x,x),true),
								b = BTC(bltPE[3][y]:sub(x,x),true),
								x = x,
								y = y,
							}
						end
					end
					saveToUndoBuffer()
					doRender = true
					barmsg = "Shrunk image."
				end
			elseif output == false then
				return "nobreak"
			end
		end,
		[3] = function() --Window
			local output = makeSubMenu(11,cleary-1,{"Set Screen Size","Set Scroll XY","Set Grid Colors"})
			doRender = true
			if output == 1 then
				windowSetScrSize()
			elseif output == 2 then
				gotoCoords()
			elseif output == 3 then
				rendback.b = paint.b
				rendback.t = paint.t
				doRender = true
			elseif output == false then
				return "nobreak"
			end
		end,
		[4] = function() --About
			local output = makeSubMenu(17,cleary-1,{"PAIN","File Formats","Help!"})
			doRender = true
			if output == 1 then
				aboutPAIN()
			elseif output == 2 then
				aboutFileFormats()
			elseif output == 3 then
				guiHelp()
				doRender = true
			end
		end,
		[5] = function() --Exit
			if changedImage then
				local outcum = bottomPrompt("Abandon unsaved work? (Y/N)",_,"yn",{keys.leftCtrl,keys.rightCtrl})
				sleep(0)
				if outcum == "y" then
					return "exit"
				else
					doRender = true
					return nil
				end
			else
				return "exit"
			end
		end,
	}
	local cursor = 1
	local redrawmenu = true
	local initial = os.time()
	local clickdelay = 0.003

	local redrawTheMenu = function()
		for a = cleary,scr_y do
			term.setCursorPos(1,a)
			term.setBackgroundColor(colors.lightGray)
			term.clearLine()
		end
		term.setCursorPos(2,cleary)
		for a = 1, #menuOptions do
			if a == cursor then
				term.setTextColor(colors.black)
				term.setBackgroundColor(colors.white)
			else
				term.setTextColor(colors.black)
				term.setBackgroundColor(colors.lightGray)
			end
			menuPoses[a] = {term.getCursorPos()}
			write(menuOptions[a])
			term.setBackgroundColor(colors.lightGray)
			if a ~= #menuOptions then
				write(" ")
			end
		end
		redrawmenu = false
	end

	while true do
		if redrawmenu then
			redrawTheMenu()
			redrawmenu = false
		end
		local event,key,x,y = getEvents("key","char","mouse_click","mouse_up","mouse_drag")
		if event == "key" then
			if key == keys.left then
				redrawmenu = true
				cursor = cursor - 1
			elseif key == keys.right then
				redrawmenu = true
				cursor = cursor + 1
			elseif key == keys.enter then
				redrawmenu = true
				local res = menuFunctions[cursor]()
				if res == "exit" then
					return "exit"
				elseif res == "nobreak" then
					reRenderPAIN()
				else
					return
				end
			elseif key == keys.leftCtrl or key == keys.rightCtrl then
				doRender = true
				return
			end
		elseif event == "char" then
			for a = 1, #menuOptions do
				if key:lower() == menuOptions[a]:sub(1,1):lower() and a ~= cursor then
					cursor = a
					redrawmenu = true
					break
				end
			end
		elseif event == "mouse_click" or event == "mouse_up" then
			if y < cleary then
				return
			elseif key == 1 and initial+clickdelay < os.time() then --key? more like button
				for a = 1, #menuPoses do
					if y == menuPoses[a][2] then
						if x >= menuPoses[a][1] and x <= menuPoses[a][1]+#menuOptions[a] then
							cursor = a
							redrawTheMenu()
							local res = menuFunctions[a]()
							coroutine.yield()
							if res == "exit" then
								return "exit"
							else
								return
							end
						end
					end
				end
			end
		end
		if (initial+clickdelay < os.time()) and string.find(event,"mouse") then
			if key == 1 then --key? key? what key? all I see is button!
				for a = 1, #menuPoses do
					if y == menuPoses[a][2] then
						if x >= menuPoses[a][1] and x <= menuPoses[a][1]+#menuOptions[a] then
							cursor = a
							redrawmenu = true
							break
						end
					end
				end
			end
		end
		if cursor < 1 then
			cursor = #menuOptions
		elseif cursor > #menuOptions then
			cursor = 1
		end
	end
end

local lastMX,lastMY,isDragging

local doNonEventDrivenMovement = function() --what a STUPID function name, dude
	local didMove
	while true do
		didMove = false
		if (not keysDown[keys.leftShift]) and (not isDragging) and (not keysDown[keys.tab]) then
			if keysDown[keys.right] then
				paint.scrollX = paint.scrollX + 1
				didMove = true
			elseif keysDown[keys.left] then
				paint.scrollX = paint.scrollX - 1
				didMove = true
			end
			if keysDown[keys.down] then
				paint.scrollY = paint.scrollY + 1
				didMove = true
			elseif keysDown[keys.up] then
				paint.scrollY = paint.scrollY - 1
				didMove = true
			end
			if didMove then
				if lastMX and lastMY then
					if miceDown[1] then
						os.queueEvent("mouse_click",1,lastMX,lastMY)
					end
					if miceDown[2] then
						os.queueEvent("mouse_click",2,lastMX,lastMY)
					end
				end
				doRender = true
			end
		end
		sleep(0)
	end
end

local linePoses = {}
local dragPoses = {}

local listAllMonitors = function()
	term.setBackgroundColor(colors.gray)
	term.setTextColor(colors.white)
	local periphs = peripheral.getNames()
	local mons = {}
	for a = 1, #periphs do
		if peripheral.getType(periphs[a]) == "monitor" then
			mons[#mons+1] = periphs[a]
		end
	end
	if #mons == 0 then
		mons[1] = "No monitors found."
	end
	term.setCursorPos(3,1)
	term.clearLine()
	term.setTextColor(colors.yellow)
	term.write("All monitors:")
	term.setTextColor(colors.white)
	for y = 1, #mons do
		term.setCursorPos(2,y+1)
		term.clearLine()
		term.write(mons[y])
	end
	sleep(0)
	getEvents("char","mouse_click")
	doRender = true
end

local getInput = function() --gotta catch them all
	local button, x, y, oldmx, oldmy, origx, origy
	local isDragging = false
	local proceed = false
	renderBar(barmsg)
	while true do
		doRender = false
		local oldx,oldy = paint.scrollX,paint.scrollY
		local evt = {getEvents("mouse_scroll","mouse_click", "mouse_drag","mouse_up","key","key_up",true)}
		if (evt[1] == "mouse_scroll") and (not viewing) then
			local dir = evt[2]
			if dir == 1 then
				if keysDown[keys.leftShift] or keysDown[keys.rightShift] then
					paint.t = paint.t * 2
					if paint.t > 32768 then
						paint.t = 32768
					end
				else
					paint.b = paint.b * 2
					if paint.b > 32768 then
						paint.b = 32768
					end
				end
			else
				if keysDown[keys.leftShift] or keysDown[keys.rightShift] then
					paint.t = math.ceil(paint.t / 2)
					if paint.t < 1 then
						paint.t = 1
					end
				else
					paint.b = math.ceil(paint.b / 2)
					if paint.b < 1 then
						paint.b = 1
					end
				end
			end
			renderBar(barmsg)
		elseif ((evt[1] == "mouse_click") or (evt[1] == "mouse_drag")) and (not viewing) then
			if evt[1] == "mouse_click" then
				origx, origy = evt[3], evt[4]
			end
			oldmx,oldmy = x or evt[3], y or evt[4]
			lastMX,lastMY = evt[3],evt[4]
			button,x,y = evt[2],evt[3],evt[4]
			if renderBlittle then
				x = 2*x
				y = 3*y
				lastMX = 2*lastMX
				lastMY = 3*lastMY
			end
			linePoses = {{x=oldmx,y=oldmy},{x=x,y=y}}
			miceDown[button] = true
			doRender = true
			if y <= scr_y-(renderBlittle and 0 or doRenderBar) then
				if (button == 3) then
					putDownText(x,y)
					miceDown = {}
					keysDown = {}
				elseif button == 1 then
					if keysDown[keys.leftShift] and evt[1] == "mouse_click" then
						isDragging = true
					end
					if isDragging then
						if evt[1] == "mouse_click" or dontDragThisTime then
							dragPoses[1] = {x=x,y=y}
						end
						dragPoses[2] = {x=x,y=y}
					elseif (not dontDragThisTime) then
						if evt[1] == "mouse_drag" then
							local points = getDotsInLine(linePoses[1].x,linePoses[1].y,linePoses[2].x,linePoses[2].y)
							for a = 1, #points do
								putDotDown({x=points[a].x, y=points[a].y})
							end
						else
							putDotDown({x=x, y=y})
						end
						changedImage = true
					end
					dontDragThisTime = false
				elseif button == 2 and y <= scr_y-(renderBlittle and 0 or doRenderBar) then
					deleteDot(x+paint.scrollX,y+paint.scrollY)
					changedImage = true
				end
			elseif origy >= scr_y-(renderBlittle and 0 or doRenderBar) then
				keysDown = {}
				local res = displayMenu()
				if res == "exit" then break end
				doRender = true
			end
		elseif (evt[1] == "mouse_up") and (not viewing) then
			origx,origy = 0,0
			local button = evt[2]
			miceDown[button] = false
			oldmx,oldmy = nil,nil
			lastMX, lastMY = nil,nil
			if isDragging then
				local points = getDotsInLine(dragPoses[1].x,dragPoses[1].y,dragPoses[2].x,dragPoses[2].y)
				for a = 1, #points do
					putDotDown({x=points[a].x, y=points[a].y})
				end
				changedImage = true
				doRender = true
			end
			saveToUndoBuffer()
			isDragging = false
		elseif evt[1] == "key" then
			local key = evt[2]
			if (not keysDown[keys.leftShift]) and (keysDown[keys.tab]) then
				if key == keys.right and (not keysDown[keys.right]) then
					paint.scrollX = paint.scrollX + 1
					doRender = true
				elseif key == keys.left and (not keysDown[keys.left]) then
					paint.scrollX = paint.scrollX - 1
					doRender = true
				end
				if key == keys.down and (not keysDown[keys.down]) then
					paint.scrollY = paint.scrollY + 1
					doRender = true
				elseif key == keys.up and (not keysDown[keys.up]) then
					paint.scrollY = paint.scrollY - 1
					doRender = true
				end
			end
			keysDown[key] = true
			if key == keys.space then
				if keysDown[keys.leftShift] then
					evenDrawGrid = not evenDrawGrid
				else
					doRenderBar = math.abs(doRenderBar-1)
				end
				doRender = true
			end
			if key == keys.b then
				local blTerm, oldTerm = getBlittle()
				renderBlittle = not renderBlittle
				isDragging = false
				term.setBackgroundColor(rendback.b)
				term.clear()
				if renderBlittle then
					term.redirect(blTerm)
					blTerm.setVisible(true)
				else
					term.redirect(oldTerm)
					blTerm.setVisible(false)
				end
				doRender = true
				scr_x, scr_y = term.current().getSize()
			end
			if (key == keys.c) and (not renderBlittle) then
				gotoCoords()
				resetInputState()
				doRender = true
			end
			if (keysDown[keys.leftShift]) and (not isDragging) then
				if key == keys.left then
					paintEncoded[frame] = movePaintEncoded(paintEncoded[frame],-1,0)
					saveToUndoBuffer()
					doRender = true
					changedImage = true
				elseif key == keys.right then
					paintEncoded[frame] = movePaintEncoded(paintEncoded[frame],1,0)
					saveToUndoBuffer()
					doRender = true
					changedImage = true
				elseif key == keys.up then
					paintEncoded[frame] = movePaintEncoded(paintEncoded[frame],0,-1)
					saveToUndoBuffer()
					doRender = true
					changedImage = true
				elseif key == keys.down then
					paintEncoded[frame] = movePaintEncoded(paintEncoded[frame],0,1)
					saveToUndoBuffer()
					doRender = true
					changedImage = true
				end
			end
			if keysDown[keys.leftAlt] then
				if #paintEncoded > 1 then
					if key == keys.equals and paintEncoded[frame+1] then --basically plus
						local first = deepCopy(paintEncoded[frame])
						local next = deepCopy(paintEncoded[frame+1])
						paintEncoded[frame] = next
						paintEncoded[frame+1] = first
						frame = frame + 1
						barmsg = "Swapped prev frame."
						doRender = true
						changedImage = true
						saveToUndoBuffer()
					end
					if key == keys.minus and paintEncoded[frame-1] then
						local first = deepCopy(paintEncoded[frame])
						local next = deepCopy(paintEncoded[frame-1])
						paintEncoded[frame] = next
						paintEncoded[frame-1] = first
						frame = frame - 1
						barmsg = "Swapped next frame."
						doRender = true
						changedImage = true
						saveToUndoBuffer()
					end
				end
			end
			if not keysDown[keys.leftAlt] then
				if key == keys.equals then --basically 'plus'
					if renderBlittle then
						frame = frame + 1
						if frame > #paintEncoded then frame = 1 end
					else
						if not paintEncoded[frame+1] then
							paintEncoded[frame+1] = {}
							local sheet = paintEncoded[frame]
							if keysDown[keys.leftShift] then
								paintEncoded[frame+1] = deepCopy(sheet)
							end
						end
						frame = frame + 1
					end
					saveToUndoBuffer()
					doRender = true
					changedImage = true
				elseif key == keys.minus then
					if renderBlittle then
						frame = frame - 1
						if frame < 1 then frame = #paintEncoded end
					else
						if frame > 1 then
							frame = frame - 1
						end
					end
					saveToUndoBuffer()
					doRender = true
					changedImage = true
				end
			end
			if not renderBlittle then
				if key == keys.m then
					local incum = bottomPrompt("Set meta: ",metaHistory)
					paint.m = incum:gsub(" ","") ~= "" and incum or paint.m
					if paint.m ~= metaHistory[#metaHistory] then
						metaHistory[#metaHistory+1] = paint.m
					end
					doRender = true
					isDragging = false
				end
				if key == keys.f7 then
					bepimode = not bepimode
					doRender = true
				end
				if key == keys.t then
					renderBottomBar("Click to place text.")
					local mevt
					repeat
						mevt = {os.pullEvent()}
					until (mevt[1] == "key" and mevt[2] == keys.x) or (mevt[2] == 1 and (mevt[4] or scr_y) < scr_y-(renderBlittle and 0 or doRenderBar))
					if not (mevt[1] == "key" and mevt[2] == keys.x) then
						local x,y = mevt[3],mevt[4]
						if renderBlittle then
							x = 2*x
							y = 3*y
						end
						putDownText(x,y)
						miceDown = {}
						keysDown = {}
					end
					doRender = true
					changedImage = true
					isDragging = false
				end
				if key == keys.p then 
					renderBottomBar("Pick color with cursor:")
					paintEncoded = clearAllRedundant(paintEncoded)
					local mevt
					repeat
						mevt = {os.pullEvent()}
					until (mevt[1] == "key" and mevt[2] == keys.x) or (mevt[2] == 1 and mevt[4] <= scr_y)
					if not (mevt[1] == "key" and mevt[2] == keys.x) then
						local x, y = mevt[3]+paint.scrollX, mevt[4]+paint.scrollY
						if renderBlittle then
							x = 2*x
							y = 3*y
						end
						local p
						for a = 1, #paintEncoded[frame] do
							p = paintEncoded[frame][a]
							if (p.x == x) and (p.y == y) then
								paint.t = p.t or paint.t
								paint.b = p.b or paint.b
								paint.c = p.c or paint.c
								paint.m = p.m or paint.m
								miceDown = {}
								keysDown = {}
								doRender = true
								isDragging = false
								break
							end
						end
						miceDown = {}
						keysDown = {}
					end
					doRender = true
					isDragging = false
				end
				if (key == keys.leftCtrl or key == keys.rightCtrl) then
					keysDown = {[207] = keysDown[207]}
					isDragging = false
					local res = displayMenu()
					paintEncoded = clearAllRedundant(paintEncoded)
					if res == "exit" then break end
					doRender = true
				end
			end
			if (key == keys.f and keysDown[keys.leftShift]) then
				local deredots = {}
				changedImage = true
				for a = 1, #paintEncoded[frame] do
					local dot = paintEncoded[frame][a]
					if dot.x-paint.scrollX > 0 and dot.x-paint.scrollX <= scr_x then
						if dot.y-paint.scrollY > 0 and dot.y-paint.scrollY <= scr_y then
							deredots[#deredots+1] = {dot.x-paint.scrollX, dot.y-paint.scrollY}
						end
					end
				end
				for y = 1, scr_y do
					for x = 1, scr_x do
						local good = true
						for a = 1, #deredots do
							if (deredots[a][1] == x) and (deredots[a][2] == y) then
								good = bad
								break
							end
						end
						if good then
							putDotDown({x=x, y=y})
						end
					end
				end
				saveToUndoBuffer()
				doRender = true
			end
			if key == keys.g then
				paint.doGray = not paint.doGray
				changedImage = true
				saveToUndoBuffer()
				doRender = true
			end
			if key == keys.a then
				paint.scrollX = 0
				paint.scrollY = 0
				doRender = true
			end
			if key == keys.n then
				if keysDown[keys.leftShift] then
					paint.c = specialCharSelector()
				else
					paint.c = boxCharSelector()
				end
				resetInputState()
				doRender = true
			end
			if key == keys.f1 then
				guiHelp()
				resetInputState()
				isDragging = false
			end
			if key == keys.f3 then
				listAllMonitors()
				resetInputState()
				isDragging = false
			end
			if key == keys.leftBracket then
				os.queueEvent("mouse_scroll",2,1,1)
			elseif key == keys.rightBracket then
				os.queueEvent("mouse_scroll",1,1,1)
			end
			if key == keys.z then
				if keysDown[keys.leftAlt] and undoPos < #undoBuffer then
					doRedo()
					barmsg = "Redood."
					doRender = true
				elseif undoPos > 1 then
					doUndo()
					barmsg = "Undood."
					doRender = true
				end
			end
		elseif evt[1] == "key_up" then
			local key = evt[2]
			keysDown[key] = false
		end
		if (oldx~=paint.scrollX) or (oldy~=paint.scrollY) then
			doRender = true
		end
		if doRender then
			renderAllPAIN()
			doRender = false
		end
	end
end

local checkIfNFP = function(str) --does not check table format, only string format
	local good = {
		[0] = true,
		[1] = true,
		[2] = true,
		[3] = true,
		[4] = true,
		[5] = true,
		[6] = true,
		[7] = true,
		[8] = true,
		[9] = true,
		a = true,
		b = true,
		c = true,
		d = true,
		e = true,
		f = true,
		[" "] = true,
		["\n"] = true
	}
	for a = 1, #str do
		if not good[str:sub(a,a):lower()] then
			return false
		end
	end
	return true
end

runPainEditor = function(...) --needs to be cleaned up
	local tArg = table.pack(...)
	if not (tArg[1] == "-n" or (not tArg[1])) then
		fileName = shell.resolve(tostring(tArg[1]))
	end
	
	if not fileName then
		paintEncoded = {{}}
	elseif not fs.exists(fileName) then
		local ex = fileName:sub(-4):lower()
		if ex == ".nfp" then
			defaultSaveFormat = 1
		elseif ex == ".nft" then
			defaultSaveFormat = 2
		elseif ex == ".blt" then
			defaultSaveFormat = 3
		elseif ex == ".gif" then
			defaultSaveFormat = 5
		elseif ex == ".ucg" then
			defaultSaveFormat = 6
		else
			defaultSaveFormat = 4
		end
		paintEncoded = {{}}
	elseif fs.isDir(fileName) then
		if math.random(1,32) == 1 then
			write("Oh")
			sleep(0.2)
			write(" My")
			sleep(0.2)
			print(" God")
			sleep(0.3)
			write("That is a")
			sleep(0.1)
			term.setTextColor(colors.red)
			write(" FUCKING")
			sleep(0.4)
			print(" FOLDER.")
			term.setTextColor(colors.white)
			sleep(0.2)
			print("You crazy person.")
			sleep(0.2)
		else
			print("That's a folder.")
		end
		return
	else
		local file = fs.open(fileName,"r")
		local contents = file.readAll()
		file.close()
		if type(tun(contents)) ~= "table" then
			term.setTextColor(colors.white)
			if contents:sub(1,3) == "BLT" then --thank you bomb bloke for this easy identifier
				if pMode ~= 1 then print("Importing from BLT...") end
				paintEncoded = importFromBLT(fileName)
				defaultSaveFormat = 3
			elseif contents:sub(1,2) == "BM" then
				if pMode ~= 1 then print("Importing from BMP...") end
	            paintEncoded = {importFromBitmap(fileName)}
				defaultSaveFormat = 4
			elseif contents:sub(1,3) == "GIF" then
				if pMode ~= 1 then print("Importing from GIF, this'll take a while...") end
				paintEncoded = importFromGIF(fileName,true)
				defaultSaveFormat = 5
			elseif contents:sub(1,4) == "?!7\2" then
				if pMode ~= 1 then print("Importing from UCG...") end
				paintEncoded = {importFromUCG(fileName)}
				defaultSaveFormat = 6
	        elseif contents:find(string.char(30)) and contents:find(string.char(31)) then
				if pMode ~= 1 then print("Importing from NFT...") end
				defaultSaveFormat = 2
				paintEncoded = {importFromNFT(contents)}
			elseif (checkIfNFP(contents) or readNonImageAsNFP) then
				print("Importing from NFP...")
				paintEncoded = {importFromPaint(contents)}
				defaultSaveFormat = 1
			else
				return print("That is not a valid image file.")
			end
		else
			paintEncoded = tun(contents)
			defaultSaveFormat = 4
		end
	end
	
	--paintEncoded = tun(tse(paintEncoded):gsub("bg","b"):gsub("txt","t"):gsub("char","c"):gsub("meta","m")) -- gotta have backwards compatibility, sorta, okay maybe not
	
	if not paintEncoded[frame] then paintEncoded = {paintEncoded} end
	if pMode == 1 then
		doRenderBar = 0
		renderPAIN(paintEncoded[tonumber(tArg[5]) or 1],-(tonumber(tArg[3]) or 0),-(tonumber(tArg[4]) or 0)) -- 'pain filename view X Y frame'
		sleep(0)
		return
	else
		renderPAIN(paintEncoded[frame],paint.scrollX,paint.scrollY,true)
	end
	lastPaintEncoded = deepCopy(paintEncoded)
	undoBuffer = {deepCopy(paintEncoded)}
	parallel.waitForAny(getInput,doNonEventDrivenMovement)
	
	term.setCursorPos(1,scr_y)
	term.setBackgroundColor(colors.black)
	term.clearLine()
end

if not shell then return end

runPainEditor(...)
