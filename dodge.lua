--[[
  Wall Dodge! What a riveting game!
  Dodge the walls before they kill you.
  
  Download with:
   pastebin get fDTts7wz dodge
   std PB fDTts7wz dodge
   std ld dodge dodge
--]]

local scr_x, scr_y = term.getSize()
local keysDown = {} -- holds all pressed keys. It's way better than using "key" event for movement
local walls = {}    -- holds all screen data for walls. I could do slants if I wanted, not just walls
local frame = 0     -- for every screen update-oh, you know what a frame is
local maxFrame = 26 -- max frames until new wall
local fframe = 0    -- not a typo. is the buffer of spaces until the spaces between walls shrinks
local maxFFrame = 6 -- max fframes until the space between walls gets slightly tighter (down to 5, good luck m8)
local pause = false -- pausing is a nice thing
local tsv = function(visible) -- monitors don't have term.current().setVisible, damn you
	if term.current().setVisible then
		term.current().setVisible(visible)
	end
end
for a = 1, scr_x do
	table.insert(walls,{top=1,bottom=scr_y,color=colors.black})
end

local score = 0  --increases for every wall.
local time = 0   --in seconds, increases in increments of 0.1

local addNewWall = function(top,bottom,color)
	table.remove(walls,1)
	table.insert(walls,{top=top,bottom=bottom,color=color})
end

local guyX = 2
local guyY = math.floor(scr_y/2)

local maxY = scr_y-1
local minY = 2

local clearLines = function(y1,y2)
	local _x,_y = term.getCursorPos()
	for a = y1, y2 or y1 do
		term.setCursorPos(1,a)
		term.clearLine()
	end
	term.setCursorPos(_x,_y)
end

local renderTEXT = function(_txt)
	local txt = _txt or "YOU ARE DEAD"
	local midY = math.floor(scr_y/2)
	for a = 0, 2 do
		term.setBackgroundColor(colors.gray)
		clearLines(midY-a,midY+a)
		sleep(0.1)
	end
	term.setCursorPos(4,midY)
	term.write(txt)
end

local trymove = function(dir)
	if (guyY+dir)>=minY and (guyY+dir)<=maxY then
		guyY = guyY + dir
		return true
	end
	return false
end

local render = function()
	tsv(false)
	term.setBackgroundColor(colors.white)
	term.setTextColor(colors.white)
	term.clear()
	term.setCursorPos(guyX,guyY)
	term.setBackgroundColor(colors.black)
	term.write(" ")
	term.setCursorPos(1,1)
	term.clearLine()
	term.setCursorPos(1,scr_y)
	term.clearLine()
	for x = 1, #walls do
		term.setBackgroundColor(walls[x].color)
		for y = 2, walls[x].top do
			term.setCursorPos(x,y)
			term.write(" ")
		end
		for y = walls[x].bottom, scr_y - 1 do
			term.setCursorPos(x,y)
			term.write(" ")
		end
	end
	term.setCursorPos(2,1)
	term.setBackgroundColor(colors.black)
	term.write("SCORE: "..score.." | TIME: "..time)
	tsv(true)
end

local keepTime = function()
	time = 0
	while true do
		sleep(0.1)
		if not pause then
			time = time + 0.1
		end
	end
end

local doGame = function()
	local wf = 0
	local gap = 2
	local ypos, randomcol
	while true do
		if not pause then
			if frame >= maxFrame or wf > 0 then
				if frame >= maxFrame then
					frame = 0
					fframe = fframe + 1
					ypos = math.random(4, scr_y-3)
					wf = 3
					randomcol = 2^math.random(1, 14)
				end
				if wf > 0 then
					wf = wf - 1
				end
				if not term.isColor() then
					randomcol = colors.black --Shame.
				end
				addNewWall(ypos-gap, ypos+gap, randomcol)
			else
				frame = frame + 1
				addNewWall(1,scr_y,colors.black)
			end
			if fframe >= maxFFrame then
				fframe = 0
				if maxFrame > 7 then
					maxFrame = maxFrame - 1
				end
			end
			if keysDown[keys.up] then
				trymove(-1)
			end
			if keysDown[keys.down] then
				trymove(1)
			end
			if walls[guyX-1].top > 1 or walls[guyX-1].bottom < scr_y then
				if walls[guyX].top < walls[guyX-1].top or walls[guyX].bottom > walls[guyX-1].bottom then
					score = score + 1
				end
			end
			render()
		end
		sleep(0.05)
		if guyY <= walls[guyX].top or guyY >= walls[guyX].bottom then
			return "dead"
		end
	end
end

local getInput = function()
	while true do
		local evt = {os.pullEvent()}
		if evt[1] == "key" then
			if evt[2] == keys.q then
				return "quit"
			end
			if evt[2] == keys.p then
				pause = not pause
				if pause then
					local pauseMSGs = {
						"PAUSED",
						"Paused. Press 'P' to resume",
						"The game is paused",
						"GAME PAUSE !",
						"What, gotta catch your breath?",
						"Paused, the game is, hmmm?",
						"PAUSED GAME",
						"GAME PAUSED",
						"THE GAME IS PAUSED",
						"THE PAUSED IS GAME",
						"Buh-buh-buh-BEEP",
						"UNPAUSE WITH 'P'",
						"Tip: press UP to go up",
						"Tip: press DOWN to go down",
						"YOU HAVE NO CHANCE TO SURVIVE MAKE YOUR TIME",
						"-PAUSED-",
						"=PAUSED=",
						"PAISED",
						"THOUST GAME BE PAUSETH",
						"Yon game is paused. Obvious exits are 'Q', 'CTRL+T'",
						"Tip: don't hit the walls",
						"Tip: press 'P' to pause the game",
					}
					renderTEXT(pauseMSGs[math.random(1,#pauseMSGs)])
					keysDown[keys.up] = false
					keysDown[keys.down] = false
				end
			end
			keysDown[evt[2]] = true
		end
		if evt[1] == "key_up" then
			keysDown[evt[2]] = false
		end
	end
end

local uut = parallel.waitForAny(getInput, doGame, keepTime)
if uut == 2 then
	renderTEXT()
end
sleep(0.05)
term.setCursorPos(1,scr_y)
term.setBackgroundColor(colors.black)
term.clearLine()
