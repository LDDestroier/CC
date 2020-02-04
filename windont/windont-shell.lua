if not fs.exists("windont.lua") then
	print("'windont.lua' not found! Downloading...")
	local net = http.get("https://github.com/LDDestroier/CC/raw/master/windont/windont.lua")
	if net then
		local file = fs.open("windont.lua", "w")
		file.write(net.readAll())
		file.close()
		net.close()
	else
		error("Could not download Windon't.", 0)
	end
end
local windont = require "windont"

windont.default.alwaysRender = false

local scr_x, scr_y = term.getSize()
local keysDown = {}

local instances = {}
local knownNames = {
	["rom/programs/shell.lua"] = "CraftOS Shell",
	["rom/programs/edit.lua"] = "Edit",
	["rom/programs/gps.lua"] = "GPS",
	["rom/programs/shutdown.lua"] = "Shutdown",
	["rom/programs/monitor.lua"] = "Monitor Redirect",
	["rom/programs/emu.lua"] = "Emu (CCEmuX)",
	["rom/programs/exit.lua"] = "Goodbye!",
	["rom/programs/lua.lua"] = "Lua Interpreter",

	["rom/programs/fun/adventure.lua"] = "Adventure",
	["rom/programs/fun/worm.lua"] = "Worm",
	["rom/programs/fun/dj.lua"] = "DJ",
	["rom/programs/fun/hello.lua"] = "Hello world!",

	["rom/programs/turtle/dance.lua"] = "Dance!",
	["rom/programs/turtle/craft.lua"] = "Craft",
	["rom/programs/turtle/excavate.lua"] = "Excavate",
	["rom/programs/turtle/refuel.lua"] = "Refueling...",
	["rom/programs/turtle/go.lua"] = "Go (Turtle)",
	["rom/programs/turtle/turn.lua"] = "Turn (Turtle)",

	["rom/programs/http/pastebin.lua"] = "Pastebin",
	["rom/programs/http/wget.lua"] = "Wget",

	["rom/programs/pocket/falling.lua"] = "Falling",

	["rom/programs/rednet/chat.lua"] = "Chat",
	["rom/programs/rednet/repeat.lua"] = "Rednet Repeat",

	["rom/programs/command/exec.lua"] = "Exec (Command)",
	["rom/programs/command/commands.lua"] = "Commands",
}

-- events that can only be passed if the instance is focused
local FocusEvents = {
	["mouse_click"] = true,
	["mouse_drag"] = true,
	["mouse_up"] = true,
	["key"] = true,
	["key_up"] = true,
	["char"] = true,
	["monitor_touch"] = true,
	["paste"] = true,
	-- mouse_scroll is intentionally excluded
}

-- events that must have their XY values altered according to the position of the window
local CoordinateEvents = {
	["mouse_click"] = {3, 4},
	["mouse_drag"] = {3, 4},
	["mouse_up"] = {3, 4},
	["mouse_scroll"] = {3, 4}
}

local desktop = windont.newWindow(1, 1, scr_x, scr_y, {
	backColor = "9"
})
local overlay = windont.newWindow(1, 1, scr_x, scr_y, {
	backColor = "-"
})
desktop.redraw()

local newInstance = function(x, y, width, height, program, pName, addBorder)
	local output = {}
	if addBorder then
		output.mainWindow = windont.newWindow(x, y, width, height + 1, {
			baseTerm = desktop,
			alwaysRender = false,
			backColor = "7"
		})
		output.termWindow = windont.newWindow(1, 2, width, height, {
			baseTerm = output.mainWindow,
			alwaysRender = true,
		})
	else
		output.mainWindow = windont.newWindow(x, y, width + 2, height + 2, {
			baseTerm = desktop,
			alwaysRender = false,
			backColor = "7"
		})
		output.termWindow = windont.newWindow(2, 2, width, height, {
			baseTerm = output.mainWindow,
			alwaysRender = true,
		})
	end

	local mw = output.mainWindow	-- contains the titlebar, and is the base terminal for termWindow
	local tw = output.termWindow	-- contains the program's terminal output

	-- pausing will probably be implemented later
	output.paused = false
	output.timeMod = 0
	output.clockMod = 0
	output.timers = {}

	output.alive = true
	output.focused = true
	output.title = pName or (type(program) == "string" and (knownNames[fs.combine("", program)] or fs.getName(program))) or tostring(program)
	output.writeTitleBar = function()
		mw.setCursorPos(1, 1)
		if output.focused then
			mw.setTextColor(colors.white)
		else
			mw.setTextColor(colors.lightGray)
		end
		mw.setBackgroundColor(colors.gray)
		mw.clearLine()

		if #output.title <= (mw.meta.width - 4) then
			mw.write(output.title)	-- write full title
		else
			mw.write(output.title:sub(1, mw.meta.width - 7) .. "...") -- draw abreviated title
		end
		mw.setCursorPos(mw.meta.width - 3, 1)
		mw.write(" \22\94\215")	-- minimize / maximize / close
	end

	if type(program) == "string" then
		output.main = function()
			tw.clear()
			return shell.run(program)
		end
	elseif type(program) == "function" then
		output.main = program
	end

	--local env = {}
	--setmetatable(env, {__index = _G})
	--setfenv(output.main, env)

	output.coroutine = coroutine.create(output.main)
	output.cFilter = nil

	for i = 1, #instances do
		instances[i].focused = false
	end

	table.insert(instances, 1, output)

	return output
end

local render = function()
	local wins = {}
	for i = 1, #instances do
		wins[i] = instances[i].mainWindow
	end
	windont.render({force = true}, table.unpack(wins))
	windont.render({}, overlay, desktop)
end

local instanceBoxCheck = function(i, x, y)
	return (
		x < 1 or x > instances[i].termWindow.meta.width or
		y < 1 or y > instances[i].termWindow.meta.height
	)
end

local resumeInstance = function(i, _evt, isCoordinateEvent)
	local evt = {}
	for k,v in pairs(_evt) do
		evt[k] = v
	end
	if CoordinateEvents[evt[1]] then
		evt[3] = evt[3] - instances[i].mainWindow.meta.x + instances[i].termWindow.meta.x
		evt[4] = evt[4] - instances[i].mainWindow.meta.y + instances[i].mainWindow.meta.y - 1
		isCoordinateEvent = true
	end
	repeat
		if (isCoordinateEvent and not instanceBoxCheck(i, evt[3], evt[4])) then
			break
		end
		oldTerm = term.redirect(instances[i].termWindow)
		success, result = coroutine.resume(instances[i].coroutine, table.unpack(evt))
		term.redirect(oldTerm)
		if success then
			instances[i].cFilter = result
		else
			instances[i].alive = false
		end
	until true
end

local main = function()

	newInstance(3, 3, 30, 12, "rom/programs/shell.lua", nil)
	newInstance(8, 5, 30, 12, "rom/programs/shell.lua", nil)

	local evt, success, result, oldTerm
	local cx, cy
	local isCoordinateEvent
	local usedCoordinateEvent
	local usingUI = false	-- if true, cannot send events to instances. Only set to true when interacting with the UI
	-- handles input system
	local keyTimer = os.startTimer(0.05)

	while true do
		evt = {coroutine.yield()}
		if evt[1] == "key" and not evt[3] then
			keysDown[evt[2]] = 0
		elseif evt[1] == "key_up" then
			keysDown[evt[2]] = nil
		end
		if evt[1] == "timer" and evt[2] == keyTimer then
			keyTimer = os.startTimer(0.05)
			for k,v in pairs(keysDown) do
				keysDown[k] = v + 0.05
			end

			-- move windows with arrow keys (for now)
			if keysDown[keys.right] then
				desktop.clear()
				instances[1].mainWindow.reposition(instances[1].mainWindow.meta.x + 1, instances[1].mainWindow.meta.y)
			end
			if keysDown[keys.left] then
				desktop.clear()
				instances[1].mainWindow.reposition(instances[1].mainWindow.meta.x - 1, instances[1].mainWindow.meta.y)
			end
			if keysDown[keys.up] then
				desktop.clear()
				instances[1].mainWindow.reposition(instances[1].mainWindow.meta.x,     instances[1].mainWindow.meta.y - 1)
			end
			if keysDown[keys.down] then
				desktop.clear()
				instances[1].mainWindow.reposition(instances[1].mainWindow.meta.x,     instances[1].mainWindow.meta.y + 1)
			end
		else
			usedCoordinateEvent = false
			isCoordinateEvent = false
			for i = 1, #instances do
				instances[i].writeTitleBar()
				if (not usingUI) and (instances[i].cFilter == evt[1] or instances[i].cFilter == "terminate" or (not instances[i].cFilter)) then
					if (instances[i].focused or not FocusEvents[evt[1]]) then
						resumeInstance(i, evt, isCoordinateEvent)
						if CoordinateEvents[evt[1]] then
							usedCoordinateEvent = true
						end
					else
						if (not instances[i].focused) and (evt[1] == "mouse_click") then
							if not usedCoordinateEvent then
								instances[i].focused = true
								instances[1].focused = false
								resumeInstance(1, evt, isCoordinateEvent)
							end
						end
					end
				end
			end
		end

		-- check for dead instances
		for i = #instances, 1, -1 do
			if not instances[i].alive then
				if instances[i].focused then
					if instances[i - 1] then
						instances[i - 1].focused = true
					elseif instances[i + 1] then
						instances[i + 1].focused = true
					end
				end
				table.remove(instances, i)
				desktop.clear()
			end
		end

		-- make sure the focused window is on top
		for i = 1, #instances do
			if instances[i].focused then
				instances[i], instances[1] = instances[1], instances[i]
				break
			end
		end
		render()
	end
end

main()
