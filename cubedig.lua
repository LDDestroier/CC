-- Turtle program that digs a rectangular area.

local tArg = {...}

local dx = tonumber(tArg[1])
local dy = tonumber(tArg[2])
local dz = tonumber(tArg[3])

-- relative position, used for printing a graphic
local pos = {
	x = 0,
	y = 0,
	z = 0,
	f = 0
}

assert(dx, "Invalid X input.")
assert(dy, "Invalid X input.")
assert(dz, "Invalid X input.")

-- done to offset the fact that the turtle occupies the rectangle it'll dig out, usually
dz = dz - 1

local dig = function(direction)
	if direction == -1 then 			-- down
		while turtle.inspectDown() do
            turtle.digDown()
        end
	elseif direction == 1 then			-- up
		while turtle.inspectUp() do
            turtle.digUp()
        end
	else								-- forwards
		while turtle.inspect() do
			turtle.dig()
		end
	end
end

local move = function(direction)
	if direction == "up" then
		turtle.up()
		pos.y = pos.y + 1
	elseif direction == "down" then
		turtle.down()
		pos.y = pos.y - 1
	elseif direction == "forward" then
		turtle.forward()
		pos.x = pos.x + math.cos(math.rad(pos.f * 90))
	elseif direction == "back" then
        turtle.forward()
        pos.x = pos.x - math.cos(math.rad(pos.f * 90))
	elseif direction == "left" then
		pos.f = (pos.f - 1) % 4
	elseif direction == "right" then
		pos.f = (pos.f + 1) % 4
	end
end

local turn = function(dir, doDig)
	if dir then
		move( "right" )
		if doDig then
			dig( 0 )
			move( "forward" )
		end
		move( "right" )
	else
		move( "left" )
		if doDig then
			dig( 0 )
			move( "forward" )
		end
		move( "left" )
	end
end

local printData = function()
	local dirs = {
		[0] = "Forwards",
		[1] = "Right",
		[2] = "Backwards",
		[3] = "Left"
	}
	term.clear()
	term.setCursorPos(1,1)
	write("Relative Pos.: (")
	write(pos.x .. ", ")
	write(pos.y .. ", ")
	print(pos.z .. ")")
	print("Relative dir.: " .. dirs[pos.f])
	print("Fuel: " .. turtle.getFuelLevel())
end

local doTurn = true
for y = 1, math.abs(dy) do
	for x = 1, dx do
		for z = 1, dz do
			dig( 0 )
			move( "forward" )
			printData()
		end
		turn(doTurn, x < dx)
		printData()
		if x < dx then
			doTurn = not doTurn
		end
	end
	if y ~= math.abs(dy) then
		if dy > 0 then
			dig( 1 )
			move( "up" )
		else
			dig( -1 )
			move( "down" )
		end
		printData()
	end
end
