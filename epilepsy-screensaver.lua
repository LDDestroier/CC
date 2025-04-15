-- trippy screensaver
-- LDDestroier

local delay = 0.05

local function dist(x1, y1, x2, y2)
	return math.sqrt((x1 - x2)^2 + ((y1 - y2)^2 / 0.6666))
end

local char_lookup = "     -=@@=-"

local function render(tick, _x, _y, width, height)
	local line
	local buffer = {}
	local stick = math.sin(math.rad(tick))
	local cx = stick                    * ((width  - 5) / 2) + (width  / 2)
	local cy = math.cos(math.rad(tick)) * ((height - 5) / 2) + (height / 2)
	local i
	for y = _y, height do
		line = ""
		for x = _x, width do
			i = (math.floor(
				((stick + 1) / 3) * dist(x - tick, y - tick / 2, cx, cy) ^ 2 - tick
			) % #char_lookup) + 1
			line = line .. (char_lookup:sub(i, i) or " ")
		end
		term.setCursorPos(_x, y)
		term.write(line)
	end
end

local evt
local tickTimer = os.startTimer(delay)
local tick = 0

while true do
	evt = {os.pullEvent()}

	if evt[1] == "timer" and evt[2] == tickTimer then
		render(tick, 1, 1, term.getSize())
		tick = (tick + 0.25) % 720
		tickTimer = os.startTimer(delay)
	
	elseif evt[1] == "key" and evt[2] == keys.q then
		sleep(0.05)
		break
	end
end

term.clear()
term.setCursorPos(1, 1)
print("Fucker")
