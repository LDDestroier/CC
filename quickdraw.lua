--[[
 QuickDraw!
  Can you outshoot the cowbow?
   I bet you can! It's actually really easy...

 pastebin get uGTzMxNL quickdraw
 std pb uGTzMxNL quickdraw
 std ld quickdraw
--]]

local difficulty = 1.2 --amount of time you have to shoot im'

local isRunning = true	--whether the game should loop
local over = false		--whether you or the guy is dead

local wins = 0
local losses = 0

local s = {
	enemy = {
		getready = {{},{},{0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,},{0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,},{0,0,0,0,0,0,0,0,0,0,0,0,0,16,16,16,16,},{0,0,0,0,0,0,0,0,0,0,0,0,0,16,16,16,16,},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,16,},{0,0,0,0,0,0,0,0,0,0,0,0,4096,4096,128,4096,4096,4096,4096,},{0,0,0,0,0,0,0,0,0,0,0,4096,0,4096,128,4096,4096,0,4096,},{0,0,0,0,0,0,0,0,0,0,0,4096,0,4096,128,4096,4096,0,4096,},{0,0,0,0,0,0,0,0,0,0,0,4096,0,4096,128,4096,4096,0,4096,},{0,0,0,0,0,0,0,0,0,0,0,0,256,4096,128,4096,4096,4096,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,2048,2048,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,2048,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,2048,},},
		shoot1 = {{},{},{0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,},{0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,},{0,0,0,0,0,0,0,0,0,0,0,0,0,16,16,16,16,},{0,0,0,0,0,0,0,0,0,0,0,0,0,16,16,16,16,},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,16,},{0,0,0,0,0,0,0,0,0,0,0,0,0,4096,128,4096,4096,},{0,0,0,0,0,0,0,0,0,0,0,0,4096,4096,128,4096,4096,4096,},{0,0,0,0,0,0,0,0,0,0,0,4096,0,4096,4096,128,4096,4096,},{0,0,0,0,0,0,0,0,0,0,0,256,0,4096,4096,128,4096,4096,},{0,0,0,0,0,0,0,0,0,0,0,0,0,4096,4096,128,4096,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,2048,2048,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,2048,2048,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,2048,},},
		shoot2 = {{},{},{0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,},{0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,},{0,0,0,0,0,0,0,0,0,0,0,0,0,16,16,16,16,},{0,0,0,0,0,0,0,0,0,0,0,0,0,16,16,16,16,},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,16,},{0,0,0,0,0,0,0,0,0,0,0,0,256,4096,4096,128,4096,},{0,0,0,0,0,0,0,0,0,0,0,0,4096,4096,4096,128,4096,4096,},{0,0,0,0,0,0,0,0,0,0,0,0,0,4096,4096,128,4096,0,4096,},{0,0,0,0,0,0,0,0,0,0,0,0,0,4096,4096,128,4096,0,4096,},{0,0,0,0,0,0,0,0,0,0,0,0,0,4096,4096,128,4096,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,2048,2048,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,2048,0,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,2048,},},
		laugh = {{},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,},{0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,1,1,32768,1,1,32768,1,1,32768,32768,1,1,32768,1,1,},{0,0,0,0,0,0,0,0,0,0,0,0,0,16,16,16,16,0,0,0,1,1,1,1,32768,1,1,32768,1,32768,1,1,32768,1,32768,1,1,},{0,0,0,0,0,0,0,0,0,0,0,0,0,16,16,16,16,0,1,1,1,1,1,1,32768,32768,32768,32768,1,32768,32768,32768,32768,1,32768,1,1,},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,16,0,0,0,0,1,1,1,1,32768,1,1,32768,1,32768,1,1,32768,1,1,1,1,},{0,0,0,0,0,0,0,0,0,0,0,0,0,4096,4096,128,4096,0,0,0,0,0,1,1,32768,1,1,32768,1,32768,1,1,32768,1,32768,1,1,},{0,0,0,0,0,0,0,0,0,0,0,0,4096,4096,4096,128,4096,4096,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,},{0,0,0,0,0,0,0,0,0,0,0,4096,0,4096,4096,128,4096,0,4096,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,},{0,0,0,0,0,0,0,0,0,0,0,4096,0,4096,4096,128,4096,0,4096,},{0,0,0,0,0,0,0,0,0,0,0,0,4096,4096,4096,128,4096,4096,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,2048,2048,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,2048,0,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,2048,},},
		dead = {{},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,},{0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,1,1,1,32768,32768,1,1,32768,1,32768,1,32768,1,1,1,},{0,0,0,0,0,0,0,0,0,0,0,4096,0,16,16,16,16,0,4096,0,1,1,1,1,32768,1,1,32768,1,32768,1,32768,1,32768,1,1,1,},{0,0,0,0,0,0,0,0,0,0,0,4096,0,16,16,16,16,0,1,1,1,1,1,1,32768,32768,32768,32768,1,32768,32768,32768,1,32768,1,1,1,},{0,0,0,0,0,0,0,0,0,0,0,4096,0,0,16,16,0,0,4096,0,1,1,1,1,32768,1,1,32768,1,32768,1,32768,1,1,1,1,1,},{0,0,0,0,0,0,0,0,0,0,0,4096,0,4096,4096,128,4096,0,4096,0,0,0,1,1,32768,1,1,32768,1,32768,1,32768,1,32768,1,1,1,},{0,0,0,0,0,0,0,0,0,0,0,0,4096,4096,4096,128,4096,4096,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,},{0,0,0,0,0,0,0,0,0,0,0,0,0,4096,4096,128,4096,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,},{0,0,0,0,0,0,0,0,0,0,0,0,0,4096,4096,128,4096,},{0,0,0,0,0,0,0,0,0,0,0,0,0,4096,4096,128,4096,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,2048,2048,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,2048,0,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,2048,},{0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,2048,},},
	},
	bg = {{8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,},{8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,},{8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,},{8,8,8,8,8,1,1,1,1,8,8,8,1,1,8,8,8,8,8,8,8,8,8,8,8,8,8,1,1,1,1,1,1,8,8,8,8,8,8,8,8,8,8,16,16,8,8,8,8,8,8,},{8,8,8,1,1,1,1,1,1,1,1,1,1,1,1,1,8,8,8,8,8,8,8,8,8,1,1,1,1,1,1,1,1,1,8,8,8,8,8,8,8,8,16,16,16,16,8,8,8,8,8,},{8,8,8,1,1,1,1,1,1,1,1,1,1,1,1,1,8,8,8,8,8,8,8,8,8,1,1,1,1,1,1,1,1,1,8,8,8,8,8,8,8,8,8,16,16,8,8,8,8,8,8,},{8,8,8,1,1,1,1,1,1,1,1,1,1,1,1,8,8,8,8,8,8,8,8,8,8,8,8,1,1,8,1,1,1,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,},{8,8,8,8,8,1,1,1,8,8,8,1,1,1,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,},{8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,},{8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,},{8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,},{8,8,8,8,8,128,128,128,128,128,128,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,},{8,8,8,8,8,128,128,128,128,128,128,128,128,128,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,16,16,16,16,16,16,16,16,16,16,},{16,16,16,16,16,128,128,128,128,128,128,128,128,128,16,16,16,16,16,16,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,},{16,16,16,16,16,128,128,128,128,128,128,128,128,128,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,},{16,16,16,16,16,128,128,128,128,128,128,128,128,128,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,},{256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,},{256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,},{16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,},},
}
_s = s

local scr_x, scr_y = term.getSize()

local yield = function()
	os.queueEvent("yield")
	os.pullEvent("yield")
end

local RPGslowprint = function(text,rate)
	local cX,cY = term.getCursorPos()
	yield()
	local uutcome = parallel.waitForAny(function()
		textutils.slowPrint(text,rate or 20)
	end, function()
		os.pullEvent("key")
	end)
	if uutcome == 2 then
		term.setCursorPos(cX,cY)
		print(text)
	end
end

local displayHelp = function(cli)
	local helptext = [[
 QuickDraw by EldidiStroyrr

 HOW TO PLAY:

  1) Click and hold on the green square for three seconds.
  2) As soon as it says DRAW, quickly move your mouse over the guy and let go.
  3) If you win, it'll get slightly harder

 Press 'Q' to quit ingame.
]]
	if cli then
		print(helptext)
	else
		term.setBackgroundColor(colors.gray)
		term.setTextColor(colors.white)
		term.setCursorPos(1,2)
		term.clear()
		RPGslowprint(helptext,30)
		term.setCursorPos(2,scr_y-1)
		term.write("Press any key to continue!")
		yield()
		os.pullEvent("key")
	end
end

function mixImages( img1, img2 )
	local output = { }
	for a = 1, #img2 do
		output[ a ] = { }
		if not img1[ a ] then
			for b = 1, #img2[ a ] do
				output[ a ][ b ] = img2[ a ][ b ]
			end
		else
			for b = 1, #img2[ a ] do
				if img1[ a ][ b ] then
					if img1[ a ][ b ] ~= 0 then
						output[ a ][ b ] = img1[ a ][ b ]
					else
						output[ a ][ b ] = img2[ a ][ b ]
					end
				else
					output[ a ][ b ] = img2[ a ][ b ]
				end
			end
		end
	end
	return output
end

local function clear()
	local b,t = term.getBackgroundColor(), term.getTextColor()
	term.setBackgroundColor(colors.black)
	term.clear()
	term.setBackgroundColor(b)
end

local function cprint(txt)
	local pX, pY = term.getCursorPos()
	term.setCursorPos((scr_x/2)-math.floor(#txt/2),(scr_y/2)+4)
	term.write(txt)
	term.setCursorPos(pX,pY)
end

local gameArea, alive

local function handleShooting()
	currentSprite = "getready"
	sleep(difficulty/4)
	paintutils.drawImage(mixImages(s.enemy.shoot1,s.bg),1,1)
	currentSprite = "shoot1"
	sleep(difficulty/4)
	paintutils.drawImage(mixImages(s.enemy.shoot2,s.bg),1,1)
	currentSprite = "shoot2"
	sleep(difficulty/2)
	os.queueEvent("thoseWhoDig",false)
	return false, "dead"
end

function drawHitBox(color)
	paintutils.drawFilledBox(scr_x-3,scr_y-2,scr_x,scr_y,color)
	term.setBackgroundColor(colors.lightBlue)
	term.setTextColor(colors.white)
	local txt = "YOU: "..wins.." / ENEMY: "..losses
	term.setCursorPos(scr_x-(#txt+1)+1,1)
	term.write(txt)
	term.setBackgroundColor(colors.lightGray)
	term.setTextColor(colors.gray)
	local txt = "TIME: "..tostring(difficulty):sub(1,5).." SEC"
	term.setCursorPos(2,scr_y-1)
	term.write(txt)
end

function exitGame()
	if not isRunning then
		term.setCursorPos(1,scr_y)
		term.setBackgroundColor(colors.black)
		term.write(string.rep(" ",scr_x-4))
		term.setCursorPos(1,scr_y)
		sleep(0)
	end
	error()
end

currentSprite = "getready"

local function countdown()
	term.setCursorPos((scr_x/2)-2,scr_y/2)
	term.setTextColor(colors.black)
	term.setBackgroundColor(colors.lightBlue)
	cprint("3...")
	sleep(0.8)
	cprint("2...")
	sleep(0.8)
	cprint("1...")
	sleep(0.8)
	cprint("DRAW!")
end

function getInput()
	alive = true
	os.pullEvent("getMeSomeInput")
	while true do
		local evt
		if gameArea == "beginning1" then
			evt = {os.pullEvent()}
			if evt[1] == "mouse_click" then
				if evt[3] >= scr_x-3 and evt[4] >= scr_y-2 then
					local res = parallel.waitForAny(function()
						while true do
							local evt = {os.pullEvent()}
							if evt[1] == "mouse_up" or evt[1] == "mouse_click" then
								break
							elseif evt[1] == "mouse_drag" then
								if (evt[3] < scr_x-3) or (evt[4] < scr_y-2) then
									break
								end
							end
						end
					end, countdown)
					if (res == 1) and not over then
						cprint("FOUL!!")
						exitGame()
					end
					os.queueEvent("imready")
					parallel.waitForAny(function()
						while alive do
							evt = {os.pullEvent()}
							if evt[1] == "mouse_up" then
								local x,y = evt[3],evt[4]
								if _s.enemy[currentSprite][y] then
									if _s.enemy[currentSprite][y][x] then
										if _s.enemy[currentSprite][y][x] ~= 0 then
											os.queueEvent("thoseWhoDig",true,x,y)
											break
										end
									end
								end
								sleep(0.2)
							elseif evt[1] == "mouse_click" then --yay for anticheating
								sleep(1)
							end
						end
					end, handleShooting)
				end
			elseif evt[1] == "key" then
				if evt[2] == keys.q then
					isRunning = false
					exitGame()
				end
			end
		end
	end
end

local flash = {
	colors.white,
	colors.lightGray,
	colors.black,
	colors.gray,
}

local tArg = {...}
if tArg[1] == "help" then
	return displayHelp(true)
end

function game()
	over = false
	term.setTextColor(colors.white)
	while true do
		gameArea = "beginning1"
		paintutils.drawImage(mixImages(s.enemy.getready,s.bg),1,1)
		drawHitBox(colors.green)
		currentSprite = "getready"
		os.queueEvent("getMeSomeInput")
		os.pullEvent("imready")
		os.queueEvent("shootStart!")
		local _,alive,x,y = os.pullEvent("thoseWhoDig")
		over = true
		if not alive then
			for a = 1, #flash do
				term.setBackgroundColor(flash[a])
				term.clear()
				sleep(0.1)
			end
			losses = losses + 1
			paintutils.drawImage(mixImages(s.enemy.laugh,s.bg),1,1)
			term.setTextColor(colors.red)
			term.setBackgroundColor(colors.lightBlue)
			sleep(0.5)
			exitGame()
		else
			paintutils.drawImage(mixImages(s.enemy.dead,s.bg),1,1)
			paintutils.drawPixel(x,y,colors.red)
			sleep(0.2)
			term.setBackgroundColor(colors.lightBlue)
			term.setTextColor(colors.black)
			cprint("YOU WIN!")
			wins = wins + 1
			sleep(0.8)
			difficulty = difficulty * 0.92
			exitGame()
		end
	end
end

clear()
displayHelp(false)
while isRunning do
	parallel.waitForAny(getInput,game)
	if isRunning then
		sleep(0.8)
	end
end