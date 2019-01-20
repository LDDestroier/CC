--[[
SUPER Dodge!!
A remake of that last game I made. Mostly an experiment with cool background.
Get with
 pastebin get 5BUnGkUJ dodge2
And soon
 std ld dodge2 dodge2

This game isn't finished, but it is certainly playable.

...you fool!
--]]
local scr_x, scr_y = term.getSize()
local sprite = {}
sprite.dw = {{128,128,128,128,128,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,128,256,256,128,128,},{0,16384,16384,16384,16384,0,},{16384,2,2,2,2,16384,},{16384,2,2,16,16,16384,},{16384,16,16,16,2,16384,},{0,16384,16384,16384,16384,0,},}
sprite.uw = {{0,16384,16384,16384,16384,0,},{16384,16,16,2,2,16384,},{16384,16,2,2,2,16384,},{16384,2,2,16,16,16384,},{0,16384,16384,16384,16384,0,},{128,128,256,256,128,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,256,256,256,256,128,},{128,128,128,128,128,128,},}
sprite.guy = {{2,0,8192,32,32,0},{16384,8192,8192,32,2048,32},{2,0,8192,32,32,0}}
sprite.guybig = {{},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,32,32,32,32,32,32,32,},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,32,32,32,32,32,32,32,32,32,32,32,32,32,},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,32,32,32,32,32,32,32,32,32768,32768,32,32,32,32,32,32,32,},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,32,32,32,32,32,32,32,32,32,32,32768,8,8,32768,32,32,32,32,32,32,},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,32,32,32,32,32,32,32,32,32,32,0,8,8,8,8,32768,32,32,32,32,0,},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,32,32,32,32,32,32,32,32,32,32,32,32,32768,8,8,8,32768,32,32,32,32,32,0,},{0,0,0,0,0,0,0,0,0,0,0,0,0,8192,8192,8192,32,32,32,32,32,32,32,32,32,32,32,32,32768,32768,32768,32,32,32,32,32,0,0,},{0,0,0,0,0,0,0,0,0,0,0,0,0,8192,8192,8192,8192,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,0,0,},{0,0,0,0,0,0,0,0,0,0,0,0,0,8192,8192,8192,8192,8192,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,0,0,0,},{0,0,0,0,0,0,0,0,0,0,0,0,8192,8192,8192,8192,8192,8192,8192,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,0,0,0,0,},{0,0,0,0,0,0,0,0,0,0,0,0,8192,8192,8192,8192,8192,8192,8192,8192,8192,32,32,32,32,32,32,32,32,32,32,32,32,0,0,0,0,0,},{0,0,0,0,0,0,0,0,0,0,0,0,0,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,32,32,32,32,32,32,32,0,0,0,0,0,0,},{0,0,0,0,0,0,0,0,0,0,0,0,256,256,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,0,0,0,0,0,0,0,0,},{0,0,0,0,0,0,0,0,0,0,0,256,256,256,256,256,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,0,0,0,0,0,0,0,0,0,},{0,0,0,0,0,0,0,0,0,0,0,2,2048,256,256,256,256,8192,8192,8192,8192,8192,8192,8192,8192,8192,8192,0,0,0,0,0,0,0,0,0,0,0,},{0,0,0,0,0,0,2,2,2,2,2,2,2048,2048,2048,256,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},{0,0,0,0,2,2,2,2,2,2,16,16,16,16,16,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},{0,0,0,2,2,2,2,2,2,16,16,16,16,16,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},{0,0,0,0,0,0,2,2,2,2,16,16,16,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},{0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},{0,0,0,0,0,2,0,0,0,2,2,2,2,2,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},{0,0,0,0,0,0,0,0,0,2,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,}}
sprite.title = {{1,1,1,1,1,0,1,0,0,0,1,0,1,1,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,0,0,0,0,0,0,0,0,},{1,1,1,1,1,0,1,0,0,0,1,0,1,1,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,0,0,0,0,0,0,0,0,},{1,0,0,0,0,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,},{1,1,1,1,1,0,1,0,0,0,1,0,1,1,1,1,1,0,1,1,1,1,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,},{0,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,},{0,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,},{1,1,1,1,1,0,1,1,1,1,1,0,1,0,0,0,0,0,1,1,1,1,1,0,1,0,0,0,1,0,0,0,0,0,0,0,0,},{1,1,1,1,1,0,1,1,1,1,1,0,1,0,0,0,0,0,1,1,1,1,1,0,1,0,0,0,1,0,0,0,0,0,0,0,0,},{},{8,8,8,8,8,0,0,0,0,8,8,8,8,8,0,0,8,8,8,8,8,0,0,0,0,8,8,8,8,0,0,8,8,8,8,8,8,},{8,8,8,8,8,8,0,0,8,8,8,8,8,8,8,0,8,8,8,8,8,8,0,0,8,8,8,8,8,8,0,8,8,8,8,8,8,},{8,8,0,0,8,8,8,0,8,8,0,0,0,8,8,0,8,8,0,0,8,8,8,0,8,8,0,0,8,8,0,8,8,0,0,0,0,},{8,8,0,0,0,8,8,0,8,8,0,0,0,8,8,0,8,8,0,0,0,8,8,0,8,8,0,0,0,0,0,8,8,8,8,8,0,},{8,8,0,0,0,8,8,0,8,8,0,0,0,8,8,0,8,8,0,0,0,8,8,0,8,8,0,8,8,8,0,8,8,0,0,0,0,},{8,8,0,0,8,8,8,0,8,8,0,0,0,8,8,0,8,8,0,0,8,8,8,0,8,8,0,0,8,8,0,8,8,0,0,0,0,},{8,8,8,8,8,8,0,0,8,8,8,8,8,8,8,0,8,8,8,8,8,8,0,0,8,8,8,8,8,8,0,8,8,8,8,8,8,},{8,8,8,8,8,0,0,0,0,8,8,8,8,8,0,0,8,8,8,8,8,0,0,0,0,8,8,8,8,0,0,8,8,8,8,8,8,}}
sprite.bg = {{32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768},{32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768},{4096,32768,32768,32768,32768,32768,32768,32768,32768,4096,4096,4096,4096,4096,4096,4096,4096,4096},{4096,4096,4096,4096,4096,4096,4096,4096,4096,4096,0,0,0,0,0,0,0,0},{},{},{},{},{},{},{},{},{},{},{},{4096,4096,4096,4096,4096,4096,4096,4096,4096,4096,0,0,0,0,0,0,0,0},{4096,32768,32768,32768,32768,32768,32768,32768,32768,4096,4096,4096,4096,4096,4096,4096,4096,4096},{32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768},{32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768}}

local gm = {
	x = 2,
	y = math.floor(scr_y/2),
	score = 0,
	hiscore = 0,
	deaths = 0,
}
local walls = {}

local keysDown = {}

local inc = function(a)
  local x,y = term.getCursorPos()
  term.setCursorPos(x,y+a)
end

local addWall = function()
	table.insert(walls,{x=scr_x,y=math.random(4,scr_y-4)})
end

local moveWalls
moveWalls = function()
	for k,v in pairs(walls) do
		if walls[k] then
			walls[k].x = walls[k].x - 1
			if walls[k].x <= -5 then
				walls[k] = nil
				moveWalls()
				break
			end
		end
	end
end

local renderBG = function(scroll,bgscroll)
	local ivl = 5 --interval
	local skew = 2
	term.setBackgroundColor(colors.black)
	term.clear()
	local pos = (ivl - scroll) + 1
	while pos <= scr_x do
		local endpos = ((pos-(scr_x/2))*(skew))+(scr_x/2)
		local midpos = ((pos-(scr_x/2))*(skew*0.8))+(scr_x/2) -- skew*0.75 is perfect lines
 		paintutils.drawLine(endpos, scr_y,      midpos, scr_y*0.75, colors.cyan) --render bottom
		paintutils.drawLine(midpos, scr_y*0.75, pos   , scr_y*0.5,  colors.lightBlue) --render bottom
		paintutils.drawLine(endpos, 1,          midpos, scr_y*0.25, colors.cyan) --render top
		paintutils.drawLine(midpos, scr_y*0.25, pos,    scr_y*0.5,  colors.lightBlue) --render top
		pos = pos + ivl
	end
	for x = 1-bgscroll, scr_x, 18 do
		paintutils.drawImage(sprite.bg,x,1)
	end
end
local gap = 6
local t = term.current().setVisible

local checkCollision = function()
	for k,v in pairs(walls) do
		if gm.x >= v.x-3 and gm.x <= v.x+3 then --intentionally allowed front and back to touch wall
			if math.abs((gm.y+1) - v.y) >= (gap/2)-1 then
				return false
			end
		end
	end
	return true
end

local render = function(scroll,bgscroll)
	if t then t(false) end
	renderBG(scroll,bgscroll)
	paintutils.drawImage(sprite.guy,gm.x,gm.y)
	
	for k,v in pairs(walls) do
		paintutils.drawImage(sprite.uw,v.x,v.y+(gap/2))
		paintutils.drawImage(sprite.dw,v.x,(v.y-(gap/2))-scr_y)
	end
	
	term.setCursorPos(2,1)
	term.setBackgroundColor(colors.black)
	term.clearLine()
	write("SCORE: "..gm.score.."  ")
	if t then t(true) end
end

local game = function()
	local scroll = 1
	local frame = 0
	local maxframe = 32
	local bgscroll = 0
	while true do
		render(math.floor(scroll),math.floor(bgscroll))
		scroll = scroll + 0.5
		frame = frame + 1
		bgscroll = bgscroll + 2
		if scroll % 5 == 0 then
			scroll = 0
		end
		if frame == maxframe then
			addWall()
			frame = 1
		end
		if bgscroll % 18 == 0 then
			bgscroll = 0
		end
		moveWalls()
		
		if keysDown[keys.up] and gm.y > 2 then
			gm.y = gm.y - 1
		end
		if keysDown[keys.down] and gm.y < scr_y-3 then
			gm.y = gm.y + 1
		end
		local isHit = not checkCollision()
		if isHit then
			return
		end
		gm.score = gm.score + 1
		if gm.hiscore < gm.score then --conglaturations
			gm.hiscore = gm.score
		end
		sleep(0)
	end
end

local getInput = function()
	while true do
		local evt, key = os.pullEvent()
		if evt == "key" then
			keysDown[key] = true
		elseif evt == "key_up" then
			keysDown[key] = false
		end
		if key == keys.q then
			return
		end
	end
end

local cleanExit = function()
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	term.clear()
	term.setCursorPos(1,1)
	print("Thanks for playing!")
	if t then t(true) end
	sleep(0.05)
end

local showTitle = function()
	if gm.deaths == 0 then
		local x = -38
		local y = scr_y
		repeat
			y = y - 1
			x = x + 2
			if t then t(false) end
			term.setBackgroundColor(colors.black)
			term.clear()
			paintutils.drawImage(sprite.guybig,math.floor(x),math.floor(y))
			if t then t(true) end
			sleep(0)
		until y <= -24
	end
	term.setBackgroundColor(colors.white)
	term.clear()
	sleep(0)
	term.setBackgroundColor(colors.black)
	term.clear()
	paintutils.drawImage(sprite.title,3,2)
	sleep(0.1)
	term.setCursorPos(4,scr_y)
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.black)
	term.write("PUSH ANY KEY TO NEXT")
	term.setCursorPos(2,1)
	write("TOP: "..gm.hiscore.." | LAST: "..gm.score)
	os.pullEvent("char")
end

while true do
	showTitle()
	walls = {}
	gm.y = math.floor(scr_y/2)
	gm.score = 0
	keysDown = {}
	local res = parallel.waitForAny(getInput,game)
	if res == 2 then
		gm.deaths = gm.deaths + 1
	else
		cleanExit()
		break
	end
end