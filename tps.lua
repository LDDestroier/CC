--[[
	Turtle Positioning System
	Use two turtles as an expensive and crappy GPS server! Use ALL the fuel!

	wget https://raw.githubusercontent.com/LDDestroier/CC/master/tps.lua
	std ld tps tps.lua
--]]

local chestX = 0 -- fill this in!
local chestY = 0 -- fill this in!
local chestZ = 0 -- fill this in!

local startx,starty,startz --if there isn't a file storing them
startx = 0
starty = 64
startz = 0

local chest = true

if not gps then -- I love error handling
	return printError("GPS API wasn't found. Are you using an older version of ComputerCraft?")
else
	if type(gps) == "table" then
		if not (gps.locate) then
			return printError("gps.locate seems to be missing.")
		else
			if type(gps.locate) == "string" then
				return printError("Is this a joke? gps.locate is a string. This does not make sense.")
			elseif type(gps.locate) == "table" then
				return printError("What the... gps.locate is a table! Knock it off.")
			elseif type(gps.locate) == "number" then
				return printError("Eh? gps.locate is a number! This doesn't ADD UP!")
			end
		end
	end
end

local cfilename = ".coords"

local tArg = {...}
local modem = peripheral.find("modem")
if not turtle then
	if pocket then
		return printError("Yo dipshit, pocket computers can't run TPS.")
	else
		return printError("Er. This is a turtle program, you know?")
	end
end
if not modem then
	local l = peripheral.wrap("right")
	local r = peripheral.wrap("left")
	if r and l then
		return printError("Dangit, you messed up! Craft a WIRELESS turtle!")
	else
		return printError("You need a wireless modem.")
	end
end
modem.open(gps.CHANNEL_GPS)

local tew,tps
local requests = 0
local scr_x, scr_y = term.getSize()

local fuels = {
	["minecraft:coal"] = 80,
	["minecraft:coal_block"] = 80*9,
}

local dro = function(input)
	return input % 4
end

local fixNumber = function(num)
	return math.floor(num+0.5)
end

local getDist = function(x1,y1,z1,x2,y2,z2)
	return math.abs(x2-x1)+math.abs(y2-y1)+math.abs(z2-z1)
end

local directionNames = {
	[0] = "South",
	[1] = "West",
	[2] = "North",
	[3] = "East",
}

local dudes = {}

local total

local sendRequest = function()
	total = 0
	for k,v in pairs(dudes) do
		if v > 0 then
			modem.transmit( k, gps.CHANNEL_GPS, { tew.x, tew.y, tew.z } )
			dudes[k] = dudes[k] - 1
			requests = requests + 1
			total = total + 1
		end
	end
	tew.lock = (total == 0)
end

local adjustCoords = function(dir, dist)
	if dir == -1 then
		tew.y = tew.y + 1
	elseif dir == -2 then
		tew.y = tew.y - 1
	else
		tew.x = fixNumber(tew.x - math.sin(math.rad(dir*90)))
		tew.z = fixNumber(tew.z + math.cos(math.rad(dir*90)))
	end
	tps(true)
end

local gotoCoords = function( gx, gy, gz )
	if (gx == tew.x) and (gy == tew.y) and (gz == tew.z) then
		return
	end

	local cx,cy,cz = tew.x,tew.y,tew.z

	while (gx ~= tew.x) or (gy ~= tew.y) or (gz ~= tew.z) do

		for a = 1, math.abs(gy-cy) do
			if tew.y == gy then
				break
			end
			tew.lock = false
			if gy > cy then
				tew.up()
			else
				tew.down()
			end
		end
		if tew.x ~= gx then
			tew.lock = false
			tew.turn(3)
			for a = 1, math.abs(gx-cx) do
				if tew.x == gx then
					break
				end
				tew.lock = false
				if gx > cx then
					tew.forward()
				else
					tew.back()
				end
			end
		end
		if tew.z ~= gz then
			tew.lock = false
			tew.turn(0)
			for a = 1, math.abs(gz-cz) do
				if tew.z == gz then
					break
				end
				tew.lock = false
				if gz > cz then
					tew.forward()
				else
					tew.back()
				end
			end
		end

	end
end

local saveTheWhales = function() --HOPEFULLY the path is unobstructed by blocks
	local bC = {
		x = tew.x,
		y = tew.y,
		z = tew.z,
		direction = tew.direction,
	}
	gotoCoords(chestX,((chestY>bC.y) and (chestY-1) or (chestY+1)),chestZ)
	for a = 1, 16 do
		if turtle.inspectUp() then
			turtle.suckUp()
		elseif turtle.inspectDown() then
			turtle.suckDown()
		elseif turtle.inspect() then
			turtle.suck()
		end
	end
	gotoCoords(bC.x,bC.y,bC.z)
	tew.lock = false
	tew.turn(bC.direction)
end

local checkIfCanFuel = function()
	local currentSlot = turtle.getSelectedSlot()
	for a = 1, 16 do
		local item = turtle.getItemDetail(a)
		if item then
			if fuels[item.name] then
				return true
			end
		end
	end
	return false
end

local doRefuel = function()
	while true do
		local currentSlot = turtle.getSelectedSlot()
		for a = 1, 16 do
			local item = turtle.getItemDetail(a)
			if item then
				if fuels[item.name] then
					turtle.select(a)
					turtle.refuel(1)
					turtle.select(currentSlot)
					term.setCursorPos(1,scr_y)
					term.clearLine()
					return true
				end
			end
		end
		sleep(0) -- INSERT MORE FUEL!
		term.setCursorPos(1,scr_y)
		term.write("Insert more fuel!!")
	end
	return false
end

local handleFuel = function(chest)
	if type(turtle.getFuelLevel()) == "number" then
		if chest and (not checkIfCanFuel()) then
			local dist = getDist(tew.x,tew.y,tew.z,chestX,chestY,chestZ)
			if dist+10 > turtle.getFuelLevel() then -- gives me some leeway
				saveTheWhales() -- PANIC
				doRefuel()
			end
		end
		if turtle.getFuelLevel() == 0 then
			doRefuel()
		end
	else
		return true
	end
end

-- 'tew' is a reproduction of the turtle API, but tracked and written to a file located at cfilename (default: "/.coords")

tew = { --already localized
	lock = false,
	direction = 0,
	x = startx,
	y = starty,
	z = startz,
	forward = function(dist,doFuelThing)
		local success, msg
		for a = 1, dist or 1 do
			if tew.lock then
				repeat
					sleep(0)
				until not tew.lock
			end
			handleFuel(doFuelThing)
			success, msg = turtle.forward()
			if success then
				adjustCoords(dro(tew.direction),1)
				--os.queueEvent("tew_move")
				sendRequest()
			else
				return success, msg
			end
		end
		return true
	end,
	back = function(dist,doFuelThing)
		local success, msg
		for a = 1, dist or 1 do
			if tew.lock then
				repeat
					sleep(0)
				until not tew.lock
			end
			handleFuel(doFuelThing)
			success, msg = turtle.back()
			if success then
				adjustCoords(dro(tew.direction+2),1)
				--os.queueEvent("tew_move")
				sendRequest()
			else
				return success, msg
			end
		end
		return true
	end,
	up = function(dist,doFuelThing)
		local success, msg
		for a = 1, dist or 1 do
			if tew.lock then
				repeat
					sleep(0)
				until not tew.lock
			end
			handleFuel(doFuelThing)
			success, msg = turtle.up()
			if success then
				adjustCoords(-1,1)
				--os.queueEvent("tew_move")
				sendRequest()
			else
				return success, msg
			end
		end
		return true
	end,
	down = function(dist,doFuelThing)
		local success, msg
		for a = 1, dist or 1 do
			if tew.lock then
				repeat
					sleep(0)
				until not tew.lock
			end
			handleFuel(doFuelThing)
			success, msg = turtle.down()
			if success then
				adjustCoords(-2,1)
				--os.queueEvent("tew_move")
				sendRequest()
			else
				return success, msg
			end
		end
		return true
	end,
	turnRight = function(times,doFuelThing)
		handleFuel(doFuelThing)
		for a = 1, times or 1 do
			if tew.lock then
				repeat
					sleep(0)
				until not tew.lock
			end
			turtle.turnRight()
			tew.direction = dro(tew.direction+1)
			tps(true)
		end
		return true
	end,
	turnLeft = function(times,doFuelThing)
		handleFuel(doFuelThing)
		for a = 1, times or 1 do
			if tew.lock then
				repeat
					sleep(0)
				until not tew.lock
			end
			turtle.turnRight()
			tew.direction = dro(tew.direction+1)
			tps(true)
		end
		return true
	end,
	turn = function(dir)
		if dir == tew.direction then
			return true
		end
		repeat
			tew.turnRight()
		until tew.direction == dir
		return true
	end
}

tps = function( doWrite )
	if doWrite then
		local file = fs.open(cfilename,"w")
		file.write(tew.x.."\n"..tew.y.."\n"..tew.z.."\n"..tew.direction.."\n"..chestX.."\n"..chestY.."\n"..chestZ)
		file.close()
	else
		if not fs.exists(cfilename) then
			tps(true)
		end
		local file = fs.open(cfilename,"r")
		tew.x = tonumber(file.readLine())
		tew.y = tonumber(file.readLine())
		tew.z = tonumber(file.readLine())
		tew.direction = tonumber(file.readLine())
		chestX = tonumber(file.readLine())
		chestY = tonumber(file.readLine())
		chestZ = tonumber(file.readLine())
		file.close()
	end
end

tps(false)
tew.lock = true

local doTurtleMove = function()
	while true do
		tew.forward(   1,true)
		tew.turnRight( 1,true)
		tew.forward(   1,true)
		tew.up(        1,true)
		tew.turnRight( 1,true)
		tew.forward(   1,true)
		tew.turnRight( 1,true)
		tew.forward(   1,true)
		tew.down(      1,true)
		tew.turnRight( 1,true)
	end
end

local handleRequests = function() --also handles manual exit
	local evt, side, chan, repchan, message, distance
	while true do
		evt, side, chan, repchan, message, distance = os.pullEvent()
		if evt == "modem_message" then
			if (chan == gps.CHANNEL_GPS) and (message == "PING") then
				dudes[repchan] = 4
				--os.queueEvent("tew_receive")
				sendRequest()
			end
		elseif evt == "key" then
			if side == keys.x then
				return
			end
		end
	end
end

local getEvents = function(...)
	local evt
	while true do
		evt = {os.pullEvent()}
		for a = 1, #arg do
			if arg[a] == evt[1] then
				return unpack(evt)
			end
		end
	end
end

local colClearLine = function(col,y,char)
	local cbg,ctxt,cx,cy = term.getBackgroundColor(), term.getTextColor(), term.getCursorPos()
	local scr_x,scr_y = term.getSize()
	term.setCursorPos(1,y or cy)
	term.setBackgroundColor(col or cbg)
	term.write((char or " "):rep(scr_x))
	term.setBackgroundColor(cbg)
	term.setTextColor(ctxt)
	term.setCursorPos(cx,cy)
end

local prettyPrint = function(left,right)
	local ctxt = term.getTextColor()
	term.setTextColor(term.isColor() and colors.yellow or colors.lightGray)
	write(left)
	term.setTextColor(ctxt)
	print(right)
end

local displayData = function()
	while true do
		term.clear()
		term.setCursorPos(1,1)
		colClearLine(colors.gray)
		prettyPrint("\nFuel: ",turtle.getFuelLevel())
		prettyPrint("X/Y/Z: ",tew.x.."/"..tew.y.."/"..tew.z)
		prettyPrint("Direction: ",tew.direction.." ("..directionNames[tew.direction]..")")
		prettyPrint("Requests: ",requests)
		colClearLine(colors.gray)
		print("\nPress 'X' to exit.")
		sleep(0)
	end
end

local displayHelp = function()
	local data = [[
	Turtle GPS System (TPS)
	by LDDestroier/EldidiStroyrr
	Place a chest down, and fill it with fuel.
	Place the turtle down (you did), and specify its own coordinates ('1') and the chest coordinates ('2').
	Start!]]
	print(data)
	sleep(0.1)
	os.pullEvent("key")
end

local okaythen = false
while not okaythen do
	term.clear()
	term.setCursorPos(1,1)
	print()
	print("Push '1' to change coordinates...")
	print("Push '2' to change chest coordinates...")
	print("Push 'X' to cancel...")
	print("Push 'Spacebar' to start immediately...")
	local _x,_y = term.getCursorPos()
	local buttmode = 0
	local res = parallel.waitForAny(
		function()
			while true do
				local _,char = os.pullEvent("char")
				if char:lower() == "1" then
					buttmode = 1
					return
				elseif char:lower() == "2" then
					buttmode = 2
					return
				elseif char:lower() == " " then
					okaythen = true
					return
				elseif char:lower() == "x" then
					buttmode = -1
					return
				end
			end
		end,
		function()
		for a = 1, 3*10 do
			term.setCursorPos(_x,_y)
			term.write("Starting in "..(3-(a/10)).." seconds...")
			sleep(0.1)
		end
	end)

	if res == 1 then
		term.clear()
		term.setCursorPos(1,1)
		if buttmode == 1 then
			print("Turtle position input.")
			colClearLine(colors.white)
			write("\nX: ")
			tew.x = tonumber(read()) or tew.x
			write("Y: ")
			tew.y = tonumber(read()) or tew.y
			write("Z: ")
			tew.z = tonumber(read()) or tew.z
			print("Direction (F3 -> 'f'): ")
			for k,v in pairs(directionNames) do
				print(" "..k.." = '"..v.."'")
			end
			write(">")
			tew.direction = tonumber(read()) or tew.direction
			tps(true)
		elseif buttmode == 2 then
			print("Refuel Chest input.")
			colClearLine(colors.white)
			write("\nChest X: ")
			chestX = tonumber(read()) or chestX
			write("Chest Y: ")
			chestY = tonumber(read()) or chestY
			write("Chest Z: ")
			chestZ = tonumber(read()) or chestZ
			tps(true)
		elseif buttmode == -1 then
			print("Cancelled.")
			error()
		end
	else
		okaythen = true
	end
end

parallel.waitForAny(
	handleRequests,
	doTurtleMove,
	displayData
)

term.setCursorPos(1, scr_y-2)
print("Thank you for using TPS!")
sleep(0)
