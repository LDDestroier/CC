-- wireless redstone solution

print("Enter a key:")
local key = read()
local channel = 1005

local occupiedSides = {}
local inputSides = {}

local oppositeSides = {
	top = "bottom",
	bottom = "top",
	right = "left",
	left = "right",
	front = "back",
	back = "front"
}

local modem = peripheral.find("modem")
modem.open(channel)

local evt

while true do
	evt = {os.pullEvent()}
	if evt[1] == "redstone" then
		for side, oSide in pairs(oppositeSides) do
			if redstone.getInput(side) and not occupiedSides[side] then
				inputSides[side] = true
				occupiedSides[side] = true
				occupiedSides[oSide] = true
				modem.transmit(channel, channel, {
					cmd = "turnOn",
					key = key,
					side = side,
				})
			elseif redstone.getOutput(side) == false and inputSides[side] then
				inputSides[side] = false
				occupiedSides[side] = false
				occupiedSides[oSide] = false
				modem.transmit(channel, channel, {
					cmd = "turnOff",
					key = key,
					side = side
				})
			end
		end
	elseif evt[1] == "modem_message" then
		local msg = evt[5]
		if type(msg) == "table" then
			if msg.key == key and msg.cmd and oppositeSides[msg.side or false] then

				if msg.cmd == "turnOn" then
					inputSides[msg.side] = true
					occupiedSides[msg.side] = true
					occupiedSides[oppositeSides[msg.side]] = true
				elseif msg.cmd == "turnOff" then
					inputSides[msg.side] = false
					occupiedSides[msg.side] = false
					occupiedSides[oppositeSides[msg.side]] = false
				end
			end
		end
	end
end
