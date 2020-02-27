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
windont.useSetVisible = true

local scr_x, scr_y = term.getSize()
local keysDown = {}

local instances = {}
local knownNames = {
	["rom/programs/shell.lua"] = "CraftOS Shell",
	["rom/programs/edit.lua"] = "Edit",
	["rom/programs/gps.lua"] = "GPS",
	["rom/programs/list.lua"] = "List",
	["rom/programs/shutdown.lua"] = "Shutting down...",
	["rom/programs/reboot.lua"] = "Rebooting...",
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
	["terminate"] = true
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
local debugOverlay = windont.newWindow(1, 1, scr_x, scr_y, {
	backColor = "-"
})
desktop.redraw()

local instanceBoxCheck = function(i, x, y, useMain)
	assert(type(x) == "number", "x must be number")
	assert(type(y) == "number", "y must be number")
	return (
		x < 1 or x > (useMain and instances[i].mainWindow.meta.width or instances[i].termWindow.meta.width) or
		y < 1 or y > (useMain and instances[i].mainWindow.meta.height or instances[i].termWindow.meta.height)
	)
end

local focusInstance = function(i)
	if instances[i or false] then
		if i ~= 1 then
			local instance = instances[i]
			instances[1].focused = false
			table.remove(instances, i)
			table.insert(instances, 1, instance)
			instances[1].focused = true
		end
	end
end

-- checks if (x, y) is within a rectangle between (rx1, ry1), (rx2, ry2)
local rectangleCheck = function(x, y, rx1, ry1, rx2, ry2)
	return
		(x >= rx1 and x <= rx2) and
		(y >= ry1 and y <= ry2)
end

-- checks which instance should be selected if you were to click on (x, y)
local checkInstanceByPos = function(x, y, useTerm)
	for i = 1, #instances do
		if rectangleCheck(
			x,
			y,
			instances[i].mainWindow.meta.x + (useTerm and 1 or 0),
			instances[i].mainWindow.meta.y + (useTerm and 1 or 0),
			instances[i].mainWindow.meta.x + (useTerm and 1 or 0) + (useTerm and instances[i].termWindow or instances[i].mainWindow).meta.width - 1,
			instances[i].mainWindow.meta.y + (useTerm and 1 or 0) + (useTerm and instances[i].termWindow or instances[i].mainWindow).meta.height - 1
		) then
			return i
		end
	end
	return false
end

local resumeInstance = function(i, _evt, isCoordinateEvent)
	local evt = {}
	for k,v in pairs(_evt) do
		evt[k] = v
	end
	if isCoordinateEvent then
		evt[3] = evt[3] - instances[i].mainWindow.meta.x
		evt[4] = evt[4] - instances[i].mainWindow.meta.y
	end
	repeat
		if (isCoordinateEvent and instanceBoxCheck(i, evt[3], evt[4])) then
			break
		end
		oldTerm = term.redirect(instances[i].termWindow)
		success, result = coroutine.resume(instances[i].coroutine, table.unpack(evt))

		instances[i].program = shell.resolveProgram(instances[i].environment.multishell.getTitle(multishell.getCurrent()))
		instances[i].setTitle()

		term.redirect(oldTerm)
		if success and coroutine.status(instances[i].coroutine) ~= "dead" then
			instances[i].cFilter = result
		else
			instances[i].alive = false
		end
	until true
end

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
			alwaysRender = false,
			blink = false
		})
		output.oldTermPos = {1, 2, width, height}
		output.oldMainPos = {x, y, width, height + 1}
	else
		output.mainWindow = windont.newWindow(x, y, width + 2, height + 2, {
			baseTerm = desktop,
			alwaysRender = false,
			backColor = "7"
		})
		output.termWindow = windont.newWindow(2, 2, width, height, {
			baseTerm = output.mainWindow,
			alwaysRender = false,
		})
		output.oldTermPos = {2, 2, width, height}
		output.oldMainPos = {x, y, width + 2, height + 2}
	end

	local mw = output.mainWindow	-- contains the titlebar, and is the base terminal for termWindow
	local tw = output.termWindow	-- contains the program's terminal output

	tw.meta.transformation = function(x, y, char, text, back, meta)
		if x > mw.meta.width - 2 then
			return {x, y, " "}, {x, y, "-"}, {x, y, "-"}
		else
			return {x, y, char}, {x, y, text}, {x, y, back}
		end
	end

	output.refreshMainWindow = function()
		for y = 1, mw.meta.height do
			mw.setCursorPos(1, y)
			if y == 1 or y == mw.meta.height then
				mw.blit(
					(" "):rep(mw.meta.width),
					("7"):rep(mw.meta.width),
					("7"):rep(mw.meta.width)
				)
			else
				mw.blit(" ","7","7")
				mw.setCursorPos(mw.meta.width, y)
				mw.blit(" ","7","7")
			end
		end
	end
	output.refreshMainWindow()
	output.program = program or "rom/programs/shell.lua"
	output.setTitle = function()
		output.title = pName or (type(output.program) == "string" and (knownNames[fs.combine("", output.program)] or fs.getName(output.program))) or tostring(output.program)
	end
	output.setTitle()
	-- pausing will probably be implemented later
	output.paused = false
	output.timeMod = 0
	output.clockMod = 0
	output.timers = {}

	output.alive = true
	output.focused = true
	output.manipMode = 0

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
--		mw.setCursorPos(mw.meta.width - 3, 1)
--		mw.write(" \22\94\215")	-- minimize / maximize / close
		mw.setCursorPos(mw.meta.width - 1, 1)
		mw.write(" \215")	-- close
	end

	if type(program) == "string" then
		output.main = function()
			tw.clear()
			return shell.run(program)
		end
	elseif type(program) == "function" then
		output.main = program
	end

	output.environment = {}
	setmetatable(output.environment, {__index = _ENV})
	setfenv(output.main, output.environment)

	output.coroutine = coroutine.create(output.main)
	output.cFilter = nil

	for i = 1, #instances do
		instances[i].focused = false
	end

	table.insert(instances, 1, output)

	resumeInstance(1, {}, false)

	return output
end

local moveInstance = function(i, x, y, newWidth, newHeight, relative)
	desktop.clear()
	newWidth = math.max(newWidth or instances[i].mainWindow.meta.width, 3)
	newHeight = math.max(newHeight or instances[i].mainWindow.meta.height, 3)
	if relative then
		if x == 0 and y == 0 then
			if (not newWidth or newWidth == instances[i].mainWindow.meta.width) and (not newHeight or newHeight == instances[i].mainWindow.meta.height) then
				return
			end
		end
		instances[i].mainWindow.reposition(instances[i].mainWindow.meta.x + x, instances[i].mainWindow.meta.y + y, newWidth, newHeight)
	else
		if x == instances[i].mainWindow.meta.x and y == instances[i].mainWindow.meta.y then
			if (not newWidth or newWidth == instances[i].mainWindow.meta.width) and (not newHeight or newHeight == instances[i].mainWindow.meta.height) then
				return
			end
		end
		instances[i].mainWindow.reposition(x, y, newWidth, newHeight)
	end
	instances[i].termWindow.reposition(
		2, 2,
		math.max(instances[i].oldTermPos[3], instances[i].mainWindow.meta.width - 2),
		math.max(instances[i].oldTermPos[4], instances[i].mainWindow.meta.height - 2)
	)
	instances[i].termWindow.redraw(nil, nil, nil, {force = true})
	instances[i].refreshMainWindow()
end

local render = function()
	local wins = {}
	for i = 1, #instances do
		wins[i] = instances[i].mainWindow
		instances[i].termWindow.redraw()
	end
	windont.render({force = true}, table.unpack(wins))
	windont.render({}, debugOverlay, overlay, desktop)
end

local makeNewWindow = function(program)
	newInstance(2, 2, math.max(scr_x - 16, 8), math.max(scr_y - 6, 5), program or "rom/programs/shell.lua")
	local good = false
	while not good do
		good = true
		if #instances == 1 then
			return
		else
			for i = 2, #instances do
				if instances[1].mainWindow.meta.x == instances[i].mainWindow.meta.x and instances[1].mainWindow.meta.y == instances[i].mainWindow.meta.y then
					instances[1].mainWindow.reposition(instances[1].mainWindow.meta.x + 2, instances[1].mainWindow.meta.y + 2)
					good = false
					break
				end
			end
		end
	end
end

local cleanExit = function()
	term.setBackgroundColor(colors.black)
	term.clear()
	term.setCursorPos(1, 1)
	print("Thanks for using Windon't Shell!")
end

local main = function()

	makeNewWindow()

	local evt, success, result, oldTerm
	local cx, cy
	local isCoordinateEvent
	local usedCoordinateEvent
	local isManipulatingInstance = false
	-- handles input system
	local keyTimer = os.startTimer(0.05)

	while true do
		evt = {coroutine.yield()}
		cx, cy = term.getCursorBlink()
		if evt[1] == "key" and not evt[3] then
			keysDown[evt[2]] = 0
		elseif evt[1] == "key_up" then
			keysDown[evt[2]] = nil
		end
		if evt[1] == "term_resize" then
			scr_x, scr_y = term.getSize()
			desktop.reposition(1, 1, scr_x, scr_y)
			overlay.reposition(1, 1, scr_x, scr_y)
		end
		if evt[1] == "mouse_click" then
			focusInstance(checkInstanceByPos(evt[3], evt[4]))
			if not checkInstanceByPos(evt[3], evt[4]) then
				if evt[2] == 2 then
					makeNewWindow()
				end
			elseif evt[2] == 1 then
				if evt[4] == instances[1].mainWindow.meta.y and evt[3] == (instances[1].mainWindow.meta.x + instances[1].mainWindow.meta.width - 1) then
					instances[1].alive = false
				end
			end
		end
		if evt[1] == "terminate" and not instances[1] then
			cleanExit()
			return true
		end
		if evt[1] == "timer" and evt[2] == keyTimer then
			keyTimer = os.startTimer(0)
			for k,v in pairs(keysDown) do
				keysDown[k] = v + 0.05
			end

			if instances[1] then
				term.setCursorPos(
					instances[1].termWindow.meta.cursorX + instances[1].mainWindow.meta.x,
					instances[1].termWindow.meta.cursorY + instances[1].mainWindow.meta.y
				)
				term.setCursorBlink(instances[1].termWindow.meta.blink)
				overlay.clear()
			else
				local msg = "Right click to open shell."
				term.setCursorBlink(false)
				overlay.setCursorPos(scr_x / 2 - #msg / 2, scr_y / 2)
				overlay.write("Right click to open shell.")
			end
			render()

			-- move windows with arrow keys (for now)
			if false then
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
			end
		else
			usedCoordinateEvent = false
			isCoordinateEvent = false
			for i = 1, #instances do
				if (not isManipulatingInstance) and evt[1] == "mouse_click" and (keysDown[keys.leftAlt] or (
					(checkInstanceByPos(evt[3], evt[4], false) == i) and not (checkInstanceByPos(evt[3], evt[4], true) == i)
				)) then
					if evt[2] == 1 then
						-- dragging a window
						if instances[i].manipMode == 0 then
							instances[i].manipMode = 1
							isManipulatingInstance = true
							instances[i].dragging = {instances[i].mainWindow.meta.x - evt[3], instances[i].mainWindow.meta.y - evt[4]}
						end
					elseif evt[2] == 2 then
						-- resizing a window
						if instances[i].manipMode == 0 then
							instances[i].manipMode = 2
							isManipulatingInstance = true
							instances[i].oldTermPos = {
								instances[i].termWindow.meta.x,
								instances[i].termWindow.meta.y,
								instances[i].termWindow.meta.width,
								instances[i].termWindow.meta.height
							}
							instances[i].oldMainPos = {
								instances[i].mainWindow.meta.x,
								instances[i].mainWindow.meta.y,
								instances[i].mainWindow.meta.width,
								instances[i].mainWindow.meta.height
							}
							if evt[3] > (instances[i].mainWindow.meta.x + (instances[i].mainWindow.meta.width) - 1) - 2 then
								instances[i].resizingRight = (instances[i].mainWindow.meta.x + instances[i].mainWindow.meta.width - 1) - evt[3]
							elseif evt[3] < (instances[i].mainWindow.meta.x + 2) then
								instances[i].resizingLeft = (instances[i].mainWindow.meta.x - 1) - evt[3]
							end
							if evt[4] > (instances[i].mainWindow.meta.y + (instances[i].mainWindow.meta.height) - 1) - 2 then
								instances[i].resizingBottom = (instances[i].mainWindow.meta.y + instances[i].mainWindow.meta.height - 1) - evt[4]
							elseif evt[4] < (instances[i].mainWindow.meta.y + 2) then
								instances[i].resizingTop = (instances[i].mainWindow.meta.y - 1) - evt[4]
							end
						end
					end
				else
					if evt[1] == "mouse_up" then
						if instances[i].manipMode == 2 then
							instances[i].mainWindow.clear()
							instances[i].termWindow.reposition(2, 2, instances[i].mainWindow.meta.width - 2, instances[i].mainWindow.meta.height - 2)
							instances[i].termWindow.redraw(nil, nil, nil, {force = true})
						end
						instances[i].manipMode = 0
						isManipulatingInstance = false
						instances[i].dragging = nil
						instances[i].resizingRight = nil
						instances[i].resizingLeft = nil
						instances[i].resizingBottom = nil
						instances[i].resizingTop = nil
					elseif evt[1] == "mouse_drag" then
						if isManipulatingInstance then
							if instances[i].manipMode == 1 then
								moveInstance(
									i,
									instances[i].dragging[1] + evt[3],
									instances[i].dragging[2] + evt[4]
								)
							elseif instances[i].manipMode == 2 then
								local newX, newY = instances[i].mainWindow.meta.x, instances[i].mainWindow.meta.y
								local oriX, oriY = instances[i].mainWindow.meta.x, instances[i].mainWindow.meta.y
								local newWidth, newHeight = instances[i].mainWindow.meta.width, instances[i].mainWindow.meta.height
								local oriWidth, oriHeight = instances[i].mainWindow.meta.width, instances[i].mainWindow.meta.height
								if instances[i].resizingRight then
									newWidth = instances[i].resizingRight + (evt[3] - instances[i].oldMainPos[1] + 1)
								end
								if instances[i].resizingLeft then
									newX = instances[i].resizingLeft + evt[3] + 1
									newWidth = instances[i].oldMainPos[3] + (instances[i].oldMainPos[1] - newX)
								end
								if instances[i].resizingBottom then
									newHeight = instances[i].resizingBottom + (evt[4] - instances[i].oldMainPos[2] + 1)
								end
								if instances[i].resizingTop then
									newY = instances[i].resizingTop + evt[4] + 1
									newHeight = instances[i].oldMainPos[4] + (instances[i].oldMainPos[2] - newY)
								end
								moveInstance(
									i,
									newX,
									newY,
									newWidth,
									newHeight
								)
								if newWidth ~= oriWidth or newHeight ~= oriHeight then
									resumeInstance(i, {"term_resize"}, false)
								end
							end
						end
					end
					if (instances[i].cFilter == evt[1] or instances[i].cFilter == "terminate" or (not instances[i].cFilter)) then
						if (instances[i].focused or not FocusEvents[evt[1]]) then
							resumeInstance(i, evt, CoordinateEvents[evt[1]])
							if CoordinateEvents[evt[1]] then
								usedCoordinateEvent = true
							end
						end
					end
				end
				instances[i].writeTitleBar()
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
	end
end

main()
