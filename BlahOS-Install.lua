local tArg = {...}
local outputPath, file = tArg[1] and fs.combine(shell.dir(), tArg[1]) or /
local safeColorList = {[colors.white] = true,[colors.lightGray] = true,[colors.gray] = true,[colors.black] = true}
local stc = function(color) if (term.isColor() or safeColorList[color]) then term.setTextColor(color) end end
local archive = textutils.unserialize("{\
  mainFile = false,\
  compressed = false,\
  data = {\
    [ \"BlahOS/screen.lua\" ] = \"sizeX, sizeY = term.getSize()\\\
printArray = {}\\\
frame = 0\\\
fps = 0\\\
drawFps = false\\\
currentKey = 0\\\
drawBaseX = 1\\\
drawBaseY = 1\\\
maxDrawX = sizeX - drawBaseX - 1\\\
maxDrawY = sizeY - drawBaseY - 2\\\
\\\
--Toolbar vars\\\
local toolbarTextLeft = {}\\\
toolbarTextLeft[1] = \\\"Rename\\\"\\\
toolbarTextLeft[2] = \\\"Cut\\\"\\\
toolbarTextLeft[3] = \\\"Copy\\\"\\\
toolbarTextLeft[4] = \\\"Paste\\\"\\\
toolbarTextLeft[5] = \\\"MkDir\\\"\\\
toolbarTextLeft[6] = \\\"Delete\\\"\\\
\\\
local toolbarTextRight = {}\\\
toolbarTextRight[1] = \\\"Edit\\\"\\\
toolbarTextRight[2] = \\\"Rename\\\"\\\
toolbarTextRight[3] = \\\"Cut\\\"\\\
toolbarTextRight[4] = \\\"Copy\\\"\\\
toolbarTextRight[5] = \\\"Paste\\\"\\\
toolbarTextRight[6] = \\\"MkFile\\\"\\\
toolbarTextRight[7] = \\\"Delete\\\"\\\
\\\
displaytext = function()\\\
	for dlx = 1, maxDrawX do\\\
		for dly = 1, maxDrawY do\\\
			term.setCursorPos(dlx + drawBaseX,dly + drawBaseX)\\\
			local v = printArray[dlx..\\\",\\\"..dly]\\\
			if v ~= nil then\\\
				term.write(v)\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
reload = function()\\\
	selectedTb = 0\\\
	--main.overrideKey = keys[\\\"up\\\"]\\\
	screen.clear()\\\
	currentDir = dir\\\
	selectorRow    = 1\\\
	selectorCoulum = True\\\
	main.drawMenu()\\\
	main.drawCursor()\\\
end\\\
\\\
clear = function()\\\
	for cx = 1, maxDrawX do\\\
		for cy = 1, maxDrawY do\\\
			printArray[cx..\\\",\\\"..cy] = \\\"\\\"\\\
		end\\\
	end\\\
end\\\
\\\
printToScreen = function(_x,_y,a)\\\
	local x, y = math.floor(_x), math.floor(_y)\\\
	if x <= maxDrawX and y <= maxDrawY then\\\
		printArray[x..\\\",\\\"..y] = a\\\
	end\\\
end\\\
\\\
border = function(b)\\\
	term.write(\\\"+\\\")\\\
	term.write(string.rep(\\\"-\\\", sizeX-2))\\\
	term.write(\\\"+\\\")\\\
	for i = 1, sizeY-1 do\\\
		term.write(\\\"|\\\")\\\
		for k = 2, sizeX-1 do\\\
			term.write(\\\" \\\")\\\
		end\\\
		term.write(\\\"|\\\")\\\
		term.setCursorPos(1,i+1)\\\
	end\\\
	term.write(\\\"+\\\")\\\
	term.write(string.rep(\\\"-\\\", sizeX-2))\\\
	term.write(\\\"+\\\")\\\
\\\
	if b then\\\
		for sbl = 2, sizeX - 1 do\\\
			term.setCursorPos(sbl, 3)\\\
			term.write(\\\"-\\\")\\\
		end\\\
		term.setCursorPos(1, 3)\\\
		term.write(\\\"+\\\")\\\
		term.setCursorPos(sizeX, 3)\\\
		term.write(\\\"+\\\")\\\
	end\\\
\\\
	term.setCursorPos(screen.sizeX - 6, 1)\\\
	term.write(\\\"-\\\")\\\
\\\
	term.setCursorPos(2, 2)\\\
end\\\
\\\
drawToolbar = function(b, selected)\\\
	tbText = \\\"\\\"\\\
\\\
	if not b then\\\
		dtbll = table.getn(toolbarTextRight)\\\
\\\
		for dtbl = 1, dtbll do\\\
			if dtbl == selected then\\\
				tbText = tbText..\\\"=\\\"..toolbarTextRight[dtbl]..\\\"=\\\"\\\
			else\\\
				tbText = tbText..\\\"[\\\"..toolbarTextRight[dtbl]..\\\"]\\\"\\\
			end\\\
		end\\\
	else\\\
		dtbll = table.getn(toolbarTextLeft)\\\
\\\
		for dtbl = 1, dtbll do\\\
			if dtbl == selected then\\\
				tbText = tbText..\\\"=\\\"..toolbarTextLeft[dtbl]..\\\"=\\\"\\\
			else\\\
				tbText = tbText..\\\"[\\\"..toolbarTextLeft[dtbl]..\\\"]\\\"\\\
			end\\\
		end\\\
	end\\\
\\\
	term.setCursorPos(1, sizeY - 2)\\\
	term.write(\\\"+\\\")\\\
	term.setCursorPos(sizeX, sizeY - 2)\\\
	term.write(\\\"+\\\")\\\
\\\
	for dtbl = 2, sizeX - 1 do\\\
		term.setCursorPos(dtbl, sizeY - 2)\\\
		term.write(\\\"-\\\")\\\
	end\\\
\\\
	term.setCursorPos(2, sizeY - 1)\\\
	term.write(tbText)\\\
\\\
end\\\
\\\
drawInputField = function()\\\
	local offsetX = 4\\\
	for i = offsetX, sizeX - offsetX do\\\
		printToScreen(i, sizeY / 3, \\\" \\\")\\\
		printToScreen(i, sizeY / 3 + 1, \\\"-\\\")\\\
		printToScreen(i, sizeY / 3 - 1, \\\"-\\\")\\\
	end\\\
	printToScreen(offsetX, sizeY / 3 - 1, \\\"+\\\")\\\
	printToScreen(offsetX, sizeY / 3 + 1, \\\"+\\\")\\\
	printToScreen(sizeX - offsetX, sizeY / 3 - 1, \\\"+\\\")\\\
	printToScreen(sizeX - offsetX, sizeY / 3 + 1, \\\"+\\\")\\\
	printToScreen(offsetX, sizeY / 3, \\\"|\\\")\\\
	printToScreen(sizeX - offsetX, sizeY / 3, \\\"|\\\")\\\
\\\
	displaytext()\\\
\\\
	term.setCursorPos(offsetX + 2, sizeY / 3 + 1)\\\
	return read()\\\
end\\\
\\\
clock = function()\\\
	term.setCursorPos(sizeX - 6, 1)\\\
	term.write(\\\"+\\\")\\\
	term.setCursorPos(sizeX - 6, 3)\\\
	term.write(\\\"+\\\")\\\
	term.setCursorPos(sizeX - 6, 2)\\\
	local time = os.time()\\\
	if drawFps then\\\
		term.write(formatTime(time)..\\\"  FPS: \\\"..fps)\\\
	else\\\
		term.write(\\\"|\\\"..formatTime(time))\\\
	end\\\
end\\\
\\\
getKeyPressed = function()\\\
	local key = currentKey\\\
	currentKey = 0\\\
	return key\\\
end\\\
\\\
formatTime = function(nTime)\\\
	local nHour = math.floor(nTime)\\\
	local nMinute = math.floor((nTime - nHour)*60)\\\
	return string.format(\\\"%02d:%02d\\\", nHour, nMinute)\\\
end\\\
\\\
setKey = function(k)\\\
	currentKey = k\\\
end\\\
\\\
writeToPos = function(x,y,s)\\\
	term.setCursorPos(x,y)\\\
	term.write(s)\\\
end\\\
\\\
displayMessage = function(m,t)\\\
	local offsetX = (sizeX - (string.len(m) + 2)) / 2\\\
	for i = offsetX, sizeX - offsetX do\\\
		printToScreen(i, sizeY / 3, \\\"\\\")\\\
		printToScreen(i, sizeY / 3 + 1, \\\"-\\\")\\\
		printToScreen(i, sizeY / 3 - 1, \\\"-\\\")\\\
	end\\\
	printToScreen(offsetX, sizeY / 3 - 1, \\\"+\\\")\\\
	printToScreen(offsetX, sizeY / 3 + 1, \\\"+\\\")\\\
	printToScreen(sizeX - offsetX, sizeY / 3 - 1, \\\"+\\\")\\\
	printToScreen(sizeX - offsetX, sizeY / 3 + 1, \\\"+\\\")\\\
	printToScreen(offsetX, sizeY / 3, \\\"|\\\")\\\
	printToScreen(sizeX - offsetX, sizeY / 3, \\\"|\\\")\\\
	printToScreen(offsetX + 1, sizeY / 3, m)\\\
\\\
	displaytext()\\\
	local timer = os.startTimer(math.max(0, t - 0.05))\\\
	local evt, k\\\
	sleep(0.05)\\\
	while true do\\\
		evt, k = os.pullEvent()\\\
		if evt == \\\"timer\\\" and k == timer then\\\
			break\\\
		elseif evt == \\\"key\\\" then\\\
			break\\\
		end\\\
	end\\\
	clear()\\\
end\",\
    [ \"BlahOS/screen\" ] = \"sizeX, sizeY = term.getSize()\\\
printArray = {}\\\
frame = 0\\\
fps = 0\\\
drawFps = false\\\
currentKey = 0\\\
drawBaseX = 1\\\
drawBaseY = 1\\\
maxDrawX = sizeX - drawBaseX - 1\\\
maxDrawY = sizeY - drawBaseY - 2\\\
\\\
--Toolbar vars\\\
local toolbarTextLeft = {}\\\
toolbarTextLeft[1] = \\\"Rename\\\"\\\
toolbarTextLeft[2] = \\\"Cut\\\"\\\
toolbarTextLeft[3] = \\\"Copy\\\"\\\
toolbarTextLeft[4] = \\\"Paste\\\"\\\
toolbarTextLeft[5] = \\\"MkDir\\\"\\\
toolbarTextLeft[6] = \\\"Delete\\\"\\\
\\\
local toolbarTextRight = {}\\\
toolbarTextRight[1] = \\\"Edit\\\"\\\
toolbarTextRight[2] = \\\"Rename\\\"\\\
toolbarTextRight[3] = \\\"Cut\\\"\\\
toolbarTextRight[4] = \\\"Copy\\\"\\\
toolbarTextRight[5] = \\\"Paste\\\"\\\
toolbarTextRight[6] = \\\"MkFile\\\"\\\
toolbarTextRight[7] = \\\"Delete\\\"\\\
\\\
displaytext = function()\\\
	for dlx = 1, maxDrawX do\\\
		for dly = 1, maxDrawY do\\\
			term.setCursorPos(dlx + drawBaseX,dly + drawBaseX)\\\
			local v = printArray[dlx..\\\",\\\"..dly]\\\
			if v ~= nil then\\\
				term.write(v)\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
reload = function()\\\
	selectedTb = 0\\\
	--main.overrideKey = keys[\\\"up\\\"]\\\
	screen.clear()\\\
	currentDir = dir\\\
	selectorRow    = 1\\\
	selectorCoulum = True\\\
	main.drawMenu()\\\
	main.drawCursor()\\\
end\\\
\\\
clear = function()\\\
	for cx = 1, maxDrawX do\\\
		for cy = 1, maxDrawY do\\\
			printArray[cx..\\\",\\\"..cy] = \\\"\\\"\\\
		end\\\
	end\\\
end\\\
\\\
printToScreen = function(_x,_y,a)\\\
	local x, y = math.floor(_x), math.floor(_y)\\\
	if x <= maxDrawX and y <= maxDrawY then\\\
		printArray[x..\\\",\\\"..y] = a\\\
	end\\\
end\\\
\\\
border = function(b)\\\
	term.write(\\\"+\\\")\\\
	term.write(string.rep(\\\"-\\\", sizeX-2))\\\
	term.write(\\\"+\\\")\\\
	for i = 1, sizeY-1 do\\\
		term.write(\\\"|\\\")\\\
		for k = 2, sizeX-1 do\\\
			term.write(\\\" \\\")\\\
		end\\\
		term.write(\\\"|\\\")\\\
		term.setCursorPos(1,i+1)\\\
	end\\\
	term.write(\\\"+\\\")\\\
	term.write(string.rep(\\\"-\\\", sizeX-2))\\\
	term.write(\\\"+\\\")\\\
\\\
	if b then\\\
		for sbl = 2, sizeX - 1 do\\\
			term.setCursorPos(sbl, 3)\\\
			term.write(\\\"-\\\")\\\
		end\\\
		term.setCursorPos(1, 3)\\\
		term.write(\\\"+\\\")\\\
		term.setCursorPos(sizeX, 3)\\\
		term.write(\\\"+\\\")\\\
	end\\\
\\\
	term.setCursorPos(screen.sizeX - 6, 1)\\\
	term.write(\\\"-\\\")\\\
\\\
	term.setCursorPos(2, 2)\\\
end\\\
\\\
drawToolbar = function(b, selected)\\\
	tbText = \\\"\\\"\\\
\\\
	if not b then\\\
		dtbll = table.getn(toolbarTextRight)\\\
\\\
		for dtbl = 1, dtbll do\\\
			if dtbl == selected then\\\
				tbText = tbText..\\\"=\\\"..toolbarTextRight[dtbl]..\\\"=\\\"\\\
			else\\\
				tbText = tbText..\\\"[\\\"..toolbarTextRight[dtbl]..\\\"]\\\"\\\
			end\\\
		end\\\
	else\\\
		dtbll = table.getn(toolbarTextLeft)\\\
\\\
		for dtbl = 1, dtbll do\\\
			if dtbl == selected then\\\
				tbText = tbText..\\\"=\\\"..toolbarTextLeft[dtbl]..\\\"=\\\"\\\
			else\\\
				tbText = tbText..\\\"[\\\"..toolbarTextLeft[dtbl]..\\\"]\\\"\\\
			end\\\
		end\\\
	end\\\
\\\
	term.setCursorPos(1, sizeY - 2)\\\
	term.write(\\\"+\\\")\\\
	term.setCursorPos(sizeX, sizeY - 2)\\\
	term.write(\\\"+\\\")\\\
\\\
	for dtbl = 2, sizeX - 1 do\\\
		term.setCursorPos(dtbl, sizeY - 2)\\\
		term.write(\\\"-\\\")\\\
	end\\\
\\\
	term.setCursorPos(2, sizeY - 1)\\\
	term.write(tbText)\\\
\\\
end\\\
\\\
drawInputField = function()\\\
	local offsetX = 4\\\
	for i = offsetX, sizeX - offsetX do\\\
		printToScreen(i, sizeY / 3, \\\" \\\")\\\
		printToScreen(i, sizeY / 3 + 1, \\\"-\\\")\\\
		printToScreen(i, sizeY / 3 - 1, \\\"-\\\")\\\
	end\\\
	printToScreen(offsetX, sizeY / 3 - 1, \\\"+\\\")\\\
	printToScreen(offsetX, sizeY / 3 + 1, \\\"+\\\")\\\
	printToScreen(sizeX - offsetX, sizeY / 3 - 1, \\\"+\\\")\\\
	printToScreen(sizeX - offsetX, sizeY / 3 + 1, \\\"+\\\")\\\
	printToScreen(offsetX, sizeY / 3, \\\"|\\\")\\\
	printToScreen(sizeX - offsetX, sizeY / 3, \\\"|\\\")\\\
\\\
	displaytext()\\\
\\\
	term.setCursorPos(offsetX + 2, sizeY / 3 + 1)\\\
	return read()\\\
end\\\
\\\
clock = function()\\\
	term.setCursorPos(sizeX - 6, 1)\\\
	term.write(\\\"+\\\")\\\
	term.setCursorPos(sizeX - 6, 3)\\\
	term.write(\\\"+\\\")\\\
	term.setCursorPos(sizeX - 6, 2)\\\
	local time = os.time()\\\
	if drawFps then\\\
		term.write(formatTime(time)..\\\"  FPS: \\\"..fps)\\\
	else\\\
		term.write(\\\"|\\\"..formatTime(time))\\\
	end\\\
end\\\
\\\
getKeyPressed = function()\\\
	local key = currentKey\\\
	currentKey = 0\\\
	return key\\\
end\\\
\\\
formatTime = function(nTime)\\\
	local nHour = math.floor(nTime)\\\
	local nMinute = math.floor((nTime - nHour)*60)\\\
	return string.format(\\\"%02d:%02d\\\", nHour, nMinute)\\\
end\\\
\\\
setKey = function(k)\\\
	currentKey = k\\\
end\\\
\\\
writeToPos = function(x,y,s)\\\
	term.setCursorPos(x,y)\\\
	term.write(s)\\\
end\\\
\\\
displayMessage = function(m,t)\\\
	local offsetX = (sizeX - (string.len(m) + 2)) / 2\\\
	for i = offsetX, sizeX - offsetX do\\\
		printToScreen(i, sizeY / 3, \\\"\\\")\\\
		printToScreen(i, sizeY / 3 + 1, \\\"-\\\")\\\
		printToScreen(i, sizeY / 3 - 1, \\\"-\\\")\\\
	end\\\
	printToScreen(offsetX, sizeY / 3 - 1, \\\"+\\\")\\\
	printToScreen(offsetX, sizeY / 3 + 1, \\\"+\\\")\\\
	printToScreen(sizeX - offsetX, sizeY / 3 - 1, \\\"+\\\")\\\
	printToScreen(sizeX - offsetX, sizeY / 3 + 1, \\\"+\\\")\\\
	printToScreen(offsetX, sizeY / 3, \\\"|\\\")\\\
	printToScreen(sizeX - offsetX, sizeY / 3, \\\"|\\\")\\\
	printToScreen(offsetX + 1, sizeY / 3, m)\\\
\\\
	displaytext()\\\
	local timer = os.startTimer(math.max(0, t - 0.05))\\\
	local evt, k\\\
	sleep(0.05)\\\
	while true do\\\
		evt, k = os.pullEvent()\\\
		if evt == \\\"timer\\\" and k == timer then\\\
			break\\\
		elseif evt == \\\"key\\\" then\\\
			break\\\
		end\\\
	end\\\
	clear()\\\
end\",\
    [ \"startup.lua\" ] = \"local d = \\\"\\\"\\\
--try to find the root\\\
\\\
if fs.exists(\\\"/BlahOS\\\") then\\\
	d = \\\"\\\"\\\
elseif fs.exists(\\\"disk/BlahOS\\\") then\\\
	d = \\\"disk\\\"\\\
else\\\
	for i = 2, 9 do\\\
		if fs.exists(\\\"disk\\\" .. i .. \\\"/BlahOS\\\") then\\\
			d = \\\"disk\\\" .. i\\\
			break\\\
		end\\\
	end\\\
end\\\
\\\
--	if not fs.exists(\\\"/BlahOS\\\") then\\\
--		shell.setAlias( \\\"install\\\", d..\\\"/install\\\" )\\\
--	end\\\
\\\
-------\\\
os.loadAPI(d..\\\"/BlahOS/main.lua\\\")\\\
os.loadAPI(d..\\\"/BlahOS/screen.lua\\\")\\\
\\\
-- vars\\\
-- Splash made at BigText.org\\\
local splashText = {\\\
	\\\" ____  _       _        ___  ____  \\\",\\\
	\\\"| __ )| | ____| |__    / _ \\\\\\\\/ ___| \\\",\\\
	\\\"|  _ \\\\\\\\| |/ _  | '_ \\\\\\\\  | | | \\\\\\\\___ \\\\\\\\ \\\",\\\
	\\\"| |_) | | (_| | | | | | |_| |___) |\\\",\\\
	\\\"|____/|_|\\\\\\\\__,_|_| |_|  \\\\\\\\___/|____/ \\\",\\\
}\\\
local randomSplash = {\\\
	\\\"Have some cake\\\",\\\
	\\\"There will be cake\\\",\\\
	\\\"Now with 100% more bugs!\\\",\\\
	\\\"*insert pun here*\\\",\\\
	\\\"DESUDESUDESUDESUDESUDESUDESUDESUDESUDESUDESUDESU\\\",\\\
	\\\"Because we can\\\",\\\
	\\\"I watch you sleep at night\\\",\\\
	\\\"The dungeon master\\\",\\\
	\\\"Now with the amazing resolution of \\\"..screen.sizeX..\\\"x\\\"..screen.sizeY..\\\"!!!\\\",\\\
	\\\"Now with an anoying splash screen!\\\",\\\
	\\\"SCIENCE!\\\",\\\
	\\\"100% lua\\\",\\\
	\\\"Dragonborn\\\",\\\
	\\\"FUS-ROH-DA!\\\",\\\
	\\\"Why don't you take a seat?\\\",\\\
	\\\"An offer you can't refuse\\\",\\\
	\\\"\\\\\\\"MMMMMMPPPPPFFFFFMPPPFFF!!!!\\\\\\\" - Pyro\\\",\\\
	\\\"May contain toxics\\\",\\\
	\\\"Keep out of reach of children\\\",\\\
	\\\"RIP companion cube\\\",\\\
	\\\"HIDE YO KIDZ\\\",\\\
	\\\"Chocolate Rain\\\",\\\
	\\\"NYAN NYAN NYAN\\\"\\\
}\\\
\\\
local splash = function()\\\
	term.clear()\\\
	-- write screen border\\\
	term.setCursorPos(1,1)\\\
	term.write(\\\"+\\\")\\\
	term.write(string.rep(\\\"-\\\", screen.sizeX-2))\\\
	term.write(\\\"+\\\")\\\
	for i = 1, screen.sizeY - 1 do\\\
		term.write(\\\"|\\\")\\\
		for i = 2, screen.sizeX - 1 do\\\
			term.write(\\\" \\\")\\\
		end\\\
		term.write(\\\"|\\\")\\\
		term.setCursorPos(1,i + 1)\\\
	end\\\
	term.write(\\\"+\\\")\\\
	term.write(string.rep(\\\"-\\\", screen.sizeX - 2))\\\
	term.write(\\\"+\\\")\\\
	local xAlign = (screen.sizeX - 33) / 2\\\
\\\
	-- draw splash logo\\\
	for i = 1, table.getn(splashText) do\\\
		term.setCursorPos(xAlign, 2 + i)\\\
		term.write(splashText[i])\\\
	end\\\
	term.setCursorPos(xAlign, 4 + table.getn(splashText))\\\
	term.write(randomSplash[math.random(table.getn(randomSplash))])\\\
\\\
	sleep(3)\\\
	term.clear()\\\
	term.setCursorPos(1,1)\\\
end\\\
\\\
local start = function()\\\
	local ignoref, delay, runnable, args\\\
	local t = os.startTimer(0.05)\\\
	local e, k\\\
	while true do\\\
		ignoref = false\\\
		delay = os.clock()\\\
		e, k = os.pullEvent()\\\
		if e == \\\"timer\\\" and k == t then\\\
			newDir = main.mainLoop(shell.dir())\\\
			shell.setDir(newDir)\\\
\\\
			runnable, args = main.getRunnable()\\\
			if runnable ~= \\\"\\\" and args ~= \\\"\\\" then\\\
				shell.run(runnable, args)\\\
				screen.reload()\\\
			elseif runnable ~= \\\"\\\" and args == \\\"\\\" then\\\
				shell.run(runnable)\\\
				screen.reload()\\\
			end\\\
			t = os.startTimer(0.05)\\\
		elseif e == \\\"key\\\" then\\\
			ignoref = true\\\
			screen.setKey(k)\\\
		end\\\
		delay = os.clock() - delay\\\
		if not ignoref then\\\
			screen.fps = math.floor(1/delay)\\\
		end\\\
	end\\\
end\\\
\\\
splash()\\\
start()\",\
    [ \"Software/Upload\" ] = \"screen.clear()\\\
\\\
screen.border(false)\\\
\\\
for i = 4, screen.sizeX - 4 do\\\
  screen.printToScreen(i, screen.sizeY / 3 + 1 - 2, \\\"-\\\")\\\
  screen.printToScreen(i, screen.sizeY / 3 - 1 - 2, \\\"-\\\")\\\
 end\\\
 screen.printToScreen(4, screen.sizeY / 3 - 1 - 2, \\\"+\\\")\\\
 screen.printToScreen(4, screen.sizeY / 3 - 2, \\\"|\\\")\\\
 screen.printToScreen(screen.sizeX - 4, screen.sizeY / 3 - 1 - 2, \\\"+\\\")\\\
 screen.printToScreen(screen.sizeX - 4, screen.sizeY / 3 - 2, \\\"|\\\")\\\
 \\\
 screen.printToScreen(5, screen.sizeY / 3 - 2, \\\"Write down the FULL path of the file\\\")\\\
 \\\
 screen.displaytext()\\\
 \\\
 file = screen.drawInputField()\\\
 if fs.exists(file) and not fs.isDir(file)then\\\
  \\\
  screen.printToScreen(5, screen.sizeY / 3 - 2, \\\"Please give a title for the paste    \\\")\\\
  screen.displaytext()\\\
  \\\
  title = screen.drawInputField()\\\
  if title == \\\"\\\" then title = \\\"generic paste\\\" end\\\
  \\\
  h = fs.open(file, \\\"r\\\")\\\
  text = h.readAll()\\\
  h.close()\\\
 \\\
  url = \\\"http://textdump.net/submit.php\\\"\\\
  post = \\\"showid=true&title=\\\"..title..\\\"&text=\\\"..text\\\
  \\\
  tmpf = http.post(url, post)\\\
  \\\
  id = tmpf:readAll()\\\
  \\\
  screen.clear()\\\
  screen.border(false)\\\
\\\
  screen.displayMessage(\\\"textdump.net/read.php?id=\\\"..id, 4)\\\
 elseif fs.isDir(file) then\\\
  screen.clear()\\\
  screen.border(false)\\\
  \\\
  screen.displayMessage(\\\"That is a folder, not a file\\\", 3)\\\
 else\\\
  screen.clear()\\\
  screen.border(false)\\\
  \\\
  screen.displayMessage(\\\"File not found\\\", 3)\\\
 end\\\
 \",\
    [ \"BlahOS/main.lua\" ] = \"--Toolbar vars\\\
selectedTb = 0\\\
canUseToolbar   = true\\\
mustDrawToolbar = true\\\
\\\
--General GUI vars\\\
selector       = \\\"->\\\"\\\
selectorRow    = 1\\\
selectorOffset = 0\\\
selectorCoulum = True -- true = left and false = right\\\
maxShow = 12\\\
maxRows = {}\\\
maxRows[true] = 5\\\
maxRows[false] = 5\\\
currentDir = nil\\\
textInputVisible = false\\\
overrideKey = 0\\\
pasteClip = \\\"\\\"\\\
pasteName = \\\"\\\"\\\
pasteMode = 0\\\
-- 0 idle\\\
-- 1 move\\\
-- 2 copy\\\
files = {}\\\
dirs = {}\\\
\\\
runnableProgram = \\\"\\\"\\\
runnableArgs    = \\\"\\\"\\\
\\\
--keys\\\
local bKeys = {}\\\
bKeys[\\\"up\\\"]     = 200\\\
bKeys[\\\"left\\\"]   = 203\\\
bKeys[\\\"down\\\"]   = 208\\\
bKeys[\\\"right\\\"]  = 205\\\
bKeys[\\\"return\\\"] = 28\\\
bKeys[\\\"del\\\"]    = 211\\\
bKeys[\\\"ctrl\\\"]   = 29\\\
bKeys[\\\"alt\\\"]    = 56\\\
bKeys[\\\"f5\\\"]     = 63\\\
\\\
mainLoop = function(dir)\\\
	if currentDir == nil then\\\
		overrideKey = bKeys[\\\"up\\\"]\\\
		screen.clear()\\\
		currentDir = dir\\\
		selectorRow    = 1\\\
		selectorCoulum = True\\\
		drawMenu()\\\
		drawCursor()\\\
	end\\\
\\\
	returnDir = currentDir\\\
\\\
	term.clear()\\\
	term.setCursorPos(1, 1)\\\
\\\
	screen.printToScreen(3,1,dir)\\\
\\\
	--Render stuff here\\\
	screen.border(true)\\\
	screen.clock()\\\
	if mustDrawToolbar then\\\
		screen.drawToolbar(selectorCoulum, selectedTb)\\\
	end\\\
	screen.displaytext()\\\
\\\
	key = screen.getKeyPressed()\\\
\\\
	if overrideKey ~= 0 then\\\
		key = overrideKey\\\
		overrideKey = 0\\\
	end\\\
\\\
	if key ~= 0 then\\\
\\\
--		drawKeyInfo(key)\\\
\\\
		if     canUseToolbar and mustDrawToolbar and selectedTb == 0 and key == bKeys[\\\"ctrl\\\"] then selectedTb = 1\\\
		elseif canUseToolbar and mustDrawToolbar and selectedTb ~= 0 and key == bKeys[\\\"ctrl\\\"] then selectedTb = 0\\\
		elseif canUseToolbar and mustDrawToolbar and selectedTb ~= 0 and key == bKeys[\\\"right\\\"] then selectedTb = normSTb(selectedTb + 1)\\\
		elseif canUseToolbar and mustDrawToolbar and selectedTb ~= 0 and key == bKeys[\\\"left\\\"] then selectedTb = normSTb(selectedTb - 1)\\\
		elseif key == bKeys[\\\"alt\\\"] and false then\\\
			mustDrawToolbar = mustDrawToolbar ~= true\\\
			canUseToolbar = mustDrawToolbar\\\
			selectedTb = 0\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 0 and selectorCoulum == true then\\\
			local selDir = dirs[selectorRow]\\\
			returnDir = fs.combine(dir..\\\"/\\\"..selDir, \\\"\\\")\\\
			if returnDir == \\\"BlahOS\\\" or returnDir == \\\"rom\\\" then\\\
				screen.displayMessage(\\\"WARNING: this is a system folder\\\", 3)\\\
				reloadAll()\\\
			end\\\
			currentDir = nil\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 1 and selectorCoulum == true  and dir ~= \\\"\\\" and selectorRow == 1 then\\\
			screen.displayMessage(\\\"You cannot rename that!\\\",2)\\\
			reloadAll()\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 2 and selectorCoulum == true  and dir ~= \\\"\\\" and selectorRow == 1 then\\\
			screen.displayMessage(\\\"You cannot cut that!\\\",2)\\\
			reloadAll()\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 6 and selectorCoulum == true  and dir ~= \\\"\\\" and selectorRow == 1 then\\\
			screen.displayMessage(\\\"You cannot delete that!\\\",2)\\\
			reloadAll()\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 6 and selectorCoulum == true  and dir ~= \\\"\\\" and selectorRow == 1 then\\\
			screen.displayMessage(\\\"You cannot copy that!\\\",2)\\\
			reloadAll()\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 2 and selectorCoulum == true then\\\
			pasteMode = 1\\\
			pasteName = dirs[selectorRow]\\\
			pasteClip = dir..\\\"/\\\"..dirs[selectorRow]\\\
			screen.displayMessage(\\\"The folder \\\\\\\"\\\"..dirs[selectorRow]..\\\"\\\\\\\" was cut\\\",3)\\\
			reloadAll()\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 3 and selectorCoulum == true then\\\
			pasteMode = 2\\\
			pasteName = dirs[selectorRow]\\\
			pasteClip = dir..\\\"/\\\"..dirs[selectorRow]\\\
			screen.displayMessage(\\\"The folder \\\\\\\"\\\"..dirs[selectorRow]..\\\"\\\\\\\" was copied\\\",3)\\\
			reloadAll()\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 4 and selectorCoulum == true then\\\
			if pasteMode == 0 then\\\
				screen.displayMessage(\\\"Nothing to paste\\\", 2)\\\
			elseif pasteMode == 1 then\\\
				pasteMode = 0\\\
				if fs.exists(dir..\\\"/\\\"..pasteName) then\\\
					fs.delete(dir..\\\"/\\\"..pasteName)\\\
				end\\\
				fs.move(pasteClip, dir..\\\"/\\\"..pasteName)\\\
				screen.displayMessage(\\\"The folder \\\\\\\"\\\"..pasteName..\\\"\\\\\\\" was moved\\\",3)\\\
			elseif pasteMode == 2 then\\\
				if fs.exists(dir..\\\"/\\\"..pasteName) then\\\
					fs.delete(dir..\\\"/\\\"..pasteName)\\\
				end\\\
				fs.copy(pasteClip, dir..\\\"/\\\"..pasteName)\\\
				screen.displayMessage(\\\"The folder \\\\\\\"\\\"..pasteName..\\\"\\\\\\\" was pasted\\\",3)\\\
			end\\\
			overrideKey = bKeys[\\\"up\\\"]\\\
			reloadAll()\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 1 and selectorCoulum == true then\\\
			rndir = dir..\\\"/\\\"..screen.drawInputField()\\\
			if rndir ~= dir..\\\"/\\\" and fs.isDir(rndir) == false and isFile(rndir) == false then\\\
				fs.move(dir..\\\"/\\\"..dirs[selectorRow], rndir)\\\
			end\\\
			overrideKey = bKeys[\\\"up\\\"]\\\
			reloadAll()\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 5 and selectorCoulum == true then\\\
			mkdir = dir..\\\"/\\\"..screen.drawInputField()\\\
			if mkdir ~= dir..\\\"/\\\" and fs.isDir(mkdir) == false and isFile(mkdir) == false then\\\
				fs.makeDir(mkdir)\\\
			end\\\
			overrideKey = bKeys[\\\"up\\\"]\\\
			reloadAll()\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 6 and selectorCoulum == true then\\\
			local validAns = false\\\
			while validAns == false do\\\
				screen.displayMessage(\\\"Are you sure, Yes or No?\\\",3)\\\
				ans = string.lower(screen.drawInputField())\\\
				validAns = ans == \\\"y\\\" or ans == \\\"n\\\" or ans == \\\"yes\\\" or ans == \\\"no\\\"\\\
				if validAns == false then\\\
					screen.displayMessage(\\\"Invalid awnser\\\", 1)\\\
				end\\\
			end\\\
			if ans == \\\"y\\\" or  ans == \\\"yes\\\" then\\\
				fs.delete(dir..\\\"/\\\"..dirs[selectorRow])\\\
			end\\\
			overrideKey = bKeys[\\\"up\\\"]\\\
			reloadAll()\\\
\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 1 and selectorCoulum == false and files[selectorRow] == \\\"\\\" then\\\
			screen.displayMessage(\\\"Nothing to edit\\\",2)\\\
			reloadAll()\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 2 and selectorCoulum == false and files[selectorRow] == \\\"\\\" then\\\
			screen.displayMessage(\\\"Nothing to rename\\\",2)\\\
			reloadAll()\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 3 and selectorCoulum == false and files[selectorRow] == \\\"\\\" then\\\
			screen.displayMessage(\\\"Nothing to cut\\\",2)\\\
			reloadAll()\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 4 and selectorCoulum == false and files[selectorRow] == \\\"\\\" then\\\
			screen.displayMessage(\\\"Nothing to copy\\\",2)\\\
			reloadAll()\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 7 and selectorCoulum == false and files[selectorRow] == \\\"\\\" then\\\
			screen.displayMessage(\\\"Nothing to delete\\\",2)\\\
			reloadAll()\\\
\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 7 and selectorCoulum == false then\\\
			local validAns = false\\\
			while validAns == false do\\\
				screen.displayMessage(\\\"Are you sure, Yes or No?\\\",3)\\\
				ans = string.lower(screen.drawInputField())\\\
				validAns = ans == \\\"y\\\" or ans == \\\"n\\\" or ans == \\\"yes\\\" or ans == \\\"no\\\"\\\
				if validAns == false then\\\
					screen.displayMessage(\\\"Invalid awnser\\\", 1)\\\
				end\\\
			end\\\
			if ans == \\\"y\\\" or  ans == \\\"yes\\\" then\\\
				fs.delete(dir..\\\"/\\\"..files[selectorRow])\\\
			end\\\
			overrideKey = bKeys[\\\"up\\\"]\\\
			reloadAll()\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 6 and selectorCoulum == false then\\\
			rndir = screen.drawInputField()\\\
			if rndir ~= dir..\\\"/\\\" and fs.isDir(dir..\\\"/\\\"..rndir) == false and isFile(dir..\\\"/\\\"..rndir) == false then\\\
				runnableProgram = \\\"edit\\\"\\\
				runnableArgs    = rndir\\\
				currentDir = dir\\\
				reloadAll()\\\
			end\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 5 and selectorCoulum == false then\\\
			if pasteMode == 0 then\\\
				screen.displayMessage(\\\"Nothing to paste\\\",2)\\\
			elseif pasteMode == 1 then\\\
				pasteMode = 0\\\
				if fs.exists(dir..\\\"/\\\"..pasteName) then\\\
					fs.delete(dir..\\\"/\\\"..pasteName)\\\
				end\\\
				fs.move(pasteClip, dir..\\\"/\\\"..pasteName)\\\
				screen.displayMessage(\\\"The folder \\\\\\\"\\\"..pasteName..\\\"\\\\\\\" was moved\\\",3)\\\
			elseif pasteMode == 2 then\\\
				if fs.exists(dir..\\\"/\\\"..pasteName) then\\\
					fs.delete(dir..\\\"/\\\"..pasteName)\\\
				end\\\
				fs.copy(pasteClip, dir..\\\"/\\\"..pasteName)\\\
				screen.displayMessage(\\\"The folder \\\\\\\"\\\"..pasteName..\\\"\\\\\\\" was pasted\\\",3)\\\
			end\\\
			reloadAll()\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 4 and selectorCoulum == false then\\\
			pasteMode = 2\\\
			pasteName = files[selectorRow]\\\
			pasteClip = dir..\\\"/\\\"..files[selectorRow]\\\
			screen.displayMessage(\\\"The folder \\\\\\\"\\\"..files[selectorRow]..\\\"\\\\\\\" was copied\\\",3)\\\
			reloadAll()\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 3 and selectorCoulum == false then\\\
			pasteMode = 1\\\
			pasteName = files[selectorRow]\\\
			pasteClip = dir..\\\"/\\\"..files[selectorRow]\\\
			screen.displayMessage(\\\"The folder \\\\\\\"\\\"..files[selectorRow]..\\\"\\\\\\\" was cut\\\",3)\\\
			reloadAll()\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 2 and selectorCoulum == false then\\\
			rndir = dir..\\\"/\\\"..screen.drawInputField()\\\
			if rndir ~= dir..\\\"/\\\" and fs.isDir(rndir) == false and isFile(rndir) == false then\\\
				fs.move(dir..\\\"/\\\"..files[selectorRow], rndir)\\\
			end\\\
			overrideKey = bKeys[\\\"up\\\"]\\\
			reloadAll()\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 1 and selectorCoulum == false then\\\
			runnableProgram = \\\"edit\\\"\\\
			runnableArgs    = files[selectorRow]\\\
		elseif key == bKeys[\\\"return\\\"] and selectedTb == 0 and selectorCoulum == false then\\\
			runnableArgs = \\\"\\\"\\\
			runnableProgram = files[selectorRow]\\\
		elseif key == bKeys[\\\"f5\\\"] then\\\
			reloadAll()\\\
			currentDir = dir\\\
		end\\\
\\\
		-- try to move the cursor\\\
		if selectedTb == 0 then\\\
			moveCursor(key)\\\
		end\\\
\\\
	end\\\
	-- End Render\\\
	return returnDir\\\
end\\\
\\\
isFile = function(s)\\\
	fls = getFiles()\\\
	found = false\\\
	for flsl = 1, table.getn(fls) do\\\
		if fls[flsl] == s then\\\
			found = true\\\
			break\\\
		end\\\
	end\\\
	return found\\\
end\\\
\\\
reloadAll = function()\\\
	selectedTb = 0\\\
	overrideKey = bKeys[\\\"up\\\"]\\\
	screen.clear()\\\
	selectorRow    = 1\\\
	selectorCoulum = True\\\
	drawMenu()\\\
	drawCursor()\\\
end\\\
\\\
reload = function()\\\
	overrideKey = bKeys[\\\"up\\\"]\\\
	screen.clear()\\\
	drawMenu()\\\
	drawCursor()\\\
end\\\
\\\
moveCursor = function(d)\\\
	resetCursor()\\\
\\\
	if selectorRow == nil then\\\
		selectorRow = 1\\\
	end\\\
	if selectorCoulum == nil then\\\
		selectorCoulum = true\\\
	end\\\
\\\
	if d == bKeys[\\\"right\\\"] and maxRows[false] ~= 0 then\\\
		selectorRow = 1\\\
		selectorCoulum = false\\\
	elseif d == bKeys[\\\"left\\\"] and maxRows[true] ~= 0 then\\\
		selectorCoulum = true\\\
		selectorRow = 1\\\
	elseif d == bKeys[\\\"up\\\"] and selectorRow > 1 then\\\
		selectorRow = selectorRow - 1\\\
	elseif d == bKeys[\\\"down\\\"] and selectorRow < maxRows[selectorCoulum] then\\\
		selectorRow = selectorRow + 1\\\
	end\\\
\\\
	if selectorRow > 11 then\\\
		selectorOffset = selectorRow - 11\\\
		drawMenu()\\\
		elseif selectorOffset > 0 and selectorRow < 12 then\\\
		selectorOffset = 0\\\
		drawMenu()\\\
	else\\\
		electorOffset = 0\\\
	end\\\
\\\
	-- draw the cursor\\\
	drawCursor()\\\
\\\
end\\\
\\\
getRunnable = function()\\\
	local runnable = runnableProgram\\\
	local args    = runnableArgs\\\
\\\
	runnableProgram = \\\"\\\"\\\
	runnableArgs    = \\\"\\\"\\\
\\\
	return runnable, args\\\
end\\\
\\\
drawKeyInfo = function(k)\\\
	local offset = screen.sizeX - 9\\\
	screen.printToScreen(offset, 2, \\\"Key: \\\"..k)\\\
end\\\
\\\
drawCursor = function()\\\
	local x = 1\\\
	local y = selectorRow + 3\\\
\\\
	if selectorRow > 11 then\\\
		y = 11 + 3\\\
	end\\\
\\\
	if selectorCoulum == false then\\\
		x = screen.sizeX / 2 - 1\\\
	end\\\
	screen.printToScreen(x, y, selector)\\\
end\\\
\\\
getFiles = function()\\\
	local list = fs.list(currentDir)\\\
	local size = table.getn(list)\\\
	local fills = {}\\\
\\\
	for f = 1, size do\\\
		if fs.isDir(currentDir..\\\"/\\\"..list[f]) == false then\\\
			fills[#fills + 1] = list[f]\\\
		end\\\
	end\\\
\\\
	if table.getn(fills) == 0 then\\\
		fills[1] = \\\"\\\"\\\
	end\\\
\\\
	return fills\\\
end\\\
\\\
getDirs = function()\\\
	local list = fs.list(currentDir)\\\
	local size = table.getn(list)\\\
	local fills = {}\\\
\\\
	if currentDir ~= \\\"\\\" then\\\
		fills[1] = \\\"..\\\\\\\\\\\"\\\
	end\\\
\\\
	for f = 1, size do\\\
		if fs.isDir(fs.combine(currentDir, list[f])) then\\\
			fills[#fills + 1] = list[f]\\\
		end\\\
	end\\\
	return fills\\\
end\\\
\\\
resetCursor = function()\\\
	local x = 1\\\
	local y = selectorRow + 3\\\
	if selectorCoulum == false then\\\
		x = screen.sizeX / 2 - 1\\\
	end\\\
	screen.printToScreen(x,y,\\\"\\\")\\\
end\\\
\\\
normSTb = function(s)\\\
	local l = 7\\\
	if selectorCoulum then\\\
		l = 6\\\
	end\\\
\\\
	if s == 0 then\\\
		return 1\\\
	elseif s > l then\\\
		return s - 1\\\
	else\\\
		return s\\\
	end\\\
end\\\
\\\
drawMenu = function()\\\
	drawCursor()\\\
\\\
	--Draw titles\\\
	screen.printToScreen(1, 3, \\\"//Folders\\\")\\\
	screen.printToScreen(screen.sizeX / 2 - 1, 3, \\\"//Files\\\")\\\
\\\
	--Draw divider\\\
	for dl = 3, screen.maxDrawY do\\\
		screen.printToScreen(screen.sizeX / 2 - 2, dl, \\\"|\\\")\\\
	end\\\
	screen.printToScreen(screen.sizeX / 2 - 2, screen.maxDrawY, \\\"+\\\")\\\
	screen.printToScreen(screen.sizeX / 2 - 2, 2, \\\"+\\\")\\\
\\\
	--draw files/folders\\\
	files = getFiles()\\\
	maxRows[false] = table.getn(files)\\\
	dirs  = getDirs()\\\
	maxRows[true] = table.getn(dirs)\\\
\\\
	diroffset = 0\\\
	fileoffset = 0\\\
\\\
	if selectorCoulum then\\\
		diroffset = selectorOffset\\\
	else\\\
		fileoffset = selectorOffset\\\
	end\\\
\\\
	--Folders\\\
	for fl = 1, maxRows[true] do\\\
		screen.printToScreen(3, 3 + fl, dirs[fl + diroffset])\\\
	end\\\
	--Files\\\
	for fl = 1, maxRows[false] do\\\
		screen.printToScreen(screen.sizeX / 2 + 1, 3 + fl, files[fl + fileoffset])\\\
	end\\\
end\",\
    [ \"Software/Download\" ] = \"download = function(url)\\\
	local tmpf = http.get(url)\\\
	local pastecont = \\\"\\\"\\\
	local i = 1\\\
	while true do\\\
		local line = tmpf:readLine()\\\
		if line == nil then break end\\\
		if i == 1 then\\\
			pastecont = line\\\
		else\\\
			pastecont = pastecont..\\\"\\\\n\\\"..line\\\
		end\\\
		i = i+1\\\
	end\\\
	tmpf:close()\\\
	local file = io.open(\\\"Downloads/download_\\\"..getFilename(), \\\"w\\\")\\\
	file:write(pastecont)\\\
	file:close()\\\
	return \\\"pie!\\\"\\\
end\\\
 \\\
function getFilename()\\\
 local id = 1\\\
 while fs.exists(\\\"Downloads/download_\\\"..id) do\\\
  id = id + 1\\\
 end\\\
 \\\
 return id\\\
end\\\
\\\
screen.clear()\\\
\\\
if fs.exists(\\\"/Downloads/\\\") and not fs.isDir(\\\"/Downloads\\\") then\\\
 screen.displayMessage(\\\"Please rename the file \\\\\\\"Downloads\\\\\\\" to something else\\\", 3)\\\
end\\\
 \\\
\\\
if not fs.exists(\\\"/Downloads/\\\") then\\\
 fs.makeDir(\\\"/Downloads/\\\")\\\
end\\\
\\\
screen.border(false)\\\
\\\
for i = 4, screen.sizeX - 4 do\\\
 screen.printToScreen(i, screen.sizeY / 3 + 1 - 2, \\\"-\\\")\\\
 screen.printToScreen(i, screen.sizeY / 3 - 1 - 2, \\\"-\\\")\\\
end\\\
screen.printToScreen(4, screen.sizeY / 3 - 1 - 2, \\\"+\\\")\\\
screen.printToScreen(4, screen.sizeY / 3 - 2, \\\"|\\\")\\\
screen.printToScreen(screen.sizeX - 4, screen.sizeY / 3 - 1 - 2, \\\"+\\\")\\\
screen.printToScreen(screen.sizeX - 4, screen.sizeY / 3 - 2, \\\"|\\\")\\\
\\\
screen.printToScreen(5, screen.sizeY / 3 - 2, \\\"textdump or pastebin?\\\")\\\
\\\
screen.displaytext()\\\
 \\\
source = string.lower(screen.drawInputField())\\\
\\\
if source == \\\"pastebin\\\" or source == \\\"2\\\" then\\\
 screen.printToScreen(5, screen.sizeY / 3 - 2, \\\"Enter the pastebint paste ID\\\")\\\
\\\
 screen.displaytext()\\\
 \\\
 id = string.lower(screen.drawInputField())\\\
 if id == \\\"\\\" then \\\
  screen.clear()\\\
  screen.border(false)\\\
  screen.displayMessage(\\\"Aborting\\\", 3)  \\\
 end\\\
 \\\
 local r = download(\\\"http://pastebin.com/raw.php?i=\\\"..id)\\\
  if r == \\\"pie!\\\" then\\\
  screen.clear()\\\
  screen.displayMessage(\\\"saved to \\\\\\\"Downloads\\\\\\\\download_\\\"..(getFilename() - 1)..\\\"\\\\\\\"\\\", 3)\\\
 else\\\
  screen.clear()\\\
  screen.displayMessage(\\\"Something went wrong\\\", 3)\\\
 end\\\
elseif source == \\\"textdump\\\" or source == \\\"1\\\" then\\\
 screen.printToScreen(5, screen.sizeY / 3 - 2, \\\"Enter the textdump ID\\\")\\\
\\\
 screen.displaytext()\\\
 \\\
 id = string.lower(screen.drawInputField())\\\
 \\\
 if id == \\\"\\\" then \\\
  screen.clear()\\\
  screen.border(false)\\\
  screen.displayMessage(\\\"Aborting\\\", 3)\\\
\\\
 end\\\
 local url = \\\"http://textdump.net/raw.php?id=\\\"..id\\\
 r = download(url)\\\
 if r == \\\"pie!\\\" then\\\
  screen.clear()\\\
  screen.displayMessage(\\\"saved to \\\\\\\"Downloads\\\\\\\\download_\\\"..(getFilename() - 1)..\\\"\\\\\\\"\\\", 3)\\\
 else\\\
  screen.clear()\\\
  screen.border(false)\\\
  screen.displayMessage(\\\"Something went wrong\\\", 3)\\\
 end\\\
 \\\
else \\\
 screen.clear()\\\
 screen.border(false)\\\
 \\\
 screen.displayMessage(\\\"That is not a valid source\\\", 3)\\\
end\\\
 \",\
    [ \"help.lua\" ] = \"--vars\\\
currentScreen = 0\\\
keepalive = true\\\
screens = {}\\\
\\\
setTitle = function(s)\\\
	term.setCursorPos(3,2)\\\
	write(s)\\\
	term.setCursorPos(1,1)\\\
end\\\
\\\
render = function()\\\
	term.clear()\\\
	term.setCursorPos(1,1)\\\
	screen.border(true)\\\
	screen.clock()\\\
	screen.displaytext()\\\
	screen.clear()\\\
end\\\
\\\
start = function()\\\
	term.clear()\\\
	screen.clear()\\\
	os.startTimer(1/20)\\\
	while keepalive do\\\
		ignoref = false\\\
		delay = os.clock()\\\
		local e,k = os.pullEvent()\\\
		if e == \\\"timer\\\" then\\\
\\\
			viewScreen()\\\
\\\
			os.startTimer(1/20)\\\
		elseif e == \\\"key\\\" then\\\
			ignoref = true\\\
			screen.setKey(k)\\\
		end\\\
		delay = os.clock() - delay\\\
		if not ignoref then\\\
			screen.fps = math.floor(1/delay)\\\
		end\\\
	end\\\
end\\\
\\\
viewScreen = function()\\\
	screens[currentScreen]()\\\
end\\\
\\\
screen0 = function()\\\
	render()\\\
	screen.displayMessage(\\\"Thank you for downloading Blah OS\\\",3)\\\
	currentScreen = 1\\\
end\\\
\\\
screen1 = function()\\\
	-- menu\\\
	local k = screen.getKeyPressed()\\\
	p = {\\\
		\\\"Welcome to Blah OS V0.4,\\\",\\\
		\\\"\\\",\\\
		\\\"So it seems like you need some help. I can \\\",\\\
		\\\"give you that, but I need to know what you\\\",\\\
		\\\"want to know.\\\",\\\
		\\\"Press the keys in the [] to go to a subject.\\\",\\\
		\\\"[1] Controls\\\",\\\
		\\\"[2] Bugs\\\",\\\
		\\\"[3] Exit\\\"\\\
	}\\\
\\\
	if k ~= nil then\\\
		if k == 2 then\\\
			currentScreen = 2\\\
		elseif k == 3 then\\\
			currentScreen = 3\\\
		elseif k == 4 then\\\
			keepalive = false\\\
		end\\\
	end\\\
\\\
	for i = 1, table.getn(p) do\\\
		screen.printToScreen(2,2 + i,p[i])\\\
	end\\\
	render()\\\
	setTitle(\\\"Main menu\\\")\\\
end\\\
\\\
screen2 = function()\\\
 local k = screen.getKeyPressed()\\\
  p ={\\\
 \\\"The controls\\\",\\\
 \\\"\\\",\\\
 \\\"CRTL: Switch between the toolbar/navigator\\\",\\\
 \\\"Return: Select an option in the toolbat,\\\",\\\
 \\\"        open folder or run a program.\\\",\\\
 \\\"Arrow keys: Move the 'cursor' arround\\\",\\\
 \\\"F5: Refreshes the screen\\\",\\\
 \\\"\\\",\\\
 \\\"[1] Back to the Main menu\\\",\\\
 \\\"\\\"\\\
 }\\\
\\\
 if k ~= nil then\\\
  if      k == 2 then currentScreen = 1\\\
  end\\\
 end\\\
\\\
 for i = 1, table.getn(p) do screen.printToScreen(2,2 + i,p[i]) end\\\
 render()\\\
 setTitle(\\\"Controls\\\")\\\
end\\\
\\\
screen3 = function()\\\
 local k = screen.getKeyPressed()\\\
  p ={\\\
 \\\"A list of common/known bugs\\\",\\\
 \\\"- Messageboxes don't always show\\\",\\\
 \\\"- Flickering text\\\",\\\
 \\\"- Low FPS\\\",\\\
 \\\"- The program crashes when acces is denied \\\",\\\
 \\\"   to a folder\\\",\\\
 \\\"\\\",\\\
 \\\"\\\",\\\
 \\\"[1] Back to the Main menu\\\",\\\
 \\\"\\\"\\\
 }\\\
\\\
 if k ~= nil then\\\
  if      k == 2 then currentScreen = 1\\\
  end\\\
 end\\\
\\\
 for i = 1, table.getn(p) do screen.printToScreen(2,2 + i,p[i]) end\\\
 render()\\\
 setTitle(\\\"Bugs\\\")\\\
end\\\
\\\
screens[0] = screen0\\\
screens[1] = screen1\\\
screens[2] = screen2\\\
screens[3] = screen3\\\
\\\
start()\",\
    install = \"d = \\\"\\\"\\\
line = 6\\\
--try to find the root\\\
\\\
if     fs.exists(\\\"/BlahOS\\\") then d = \\\"\\\" \\\
elseif fs.exists(\\\"disk/BlahOS\\\") then d = \\\"disk\\\" \\\
elseif fs.exists(\\\"disk2/BlahOS\\\") then d = \\\"disk2\\\"\\\
elseif fs.exists(\\\"disk3/BlahOS\\\") then d = \\\"disk3\\\" \\\
elseif fs.exists(\\\"disk4/BlahOS\\\") then d = \\\"disk4\\\" \\\
elseif fs.exists(\\\"disk5/BlahOS\\\") then d = \\\"disk5\\\" \\\
elseif fs.exists(\\\"disk6/BlahOS\\\") then d = \\\"disk6\\\" \\\
end\\\
-------\\\
os.loadAPI(d..\\\"/BlahOS/screen\\\")\\\
\\\
title = {}\\\
title[1] = \\\" __         __  __                    \\\"\\\
title[2] = \\\"|__)| _ |_ /  \\\\\\\\(_   . _  _|_ _ || _ _ \\\"\\\
title[3] = \\\"|__)|(_|| )\\\\\\\\__/__)  || )_)|_(_|||(-|  \\\"\\\
\\\
writeLine = function(s)\\\
\\\
 term.setCursorPos(3, line)\\\
 line = line + 1\\\
 if line == screen.sizeY then line = screen.sizeY - 1 end\\\
 print(s)\\\
 \\\
 term.setCursorPos(3 + string.len(s), line - 1)\\\
 --screen.border(false)\\\
end\\\
\\\
\\\
term.clear()\\\
term.setCursorPos(1,1)\\\
screen.border(false)\\\
for i = 1, table.getn(title) do\\\
 term.setCursorPos(3, i + 1)\\\
 term.write(title[i])\\\
end\\\
\\\
writeLine(\\\"Press enter to install Blah OS \\\")\\\
writeLine(\\\"or hold ctrl + T to cancle.\\\")\\\
read()\\\
screen.border(false)\\\
line = 2\\\
writeLine(\\\"Finding/deleting older versions\\\")\\\
\\\
\\\
if not fs.exists(\\\"/BlahOS\\\") and not fs.exists(\\\"/Software\\\") and not fs.exists(\\\"startup\\\") then \\\
 writeLine(\\\" -Found none\\\")\\\
end\\\
\\\
if fs.exists(\\\"/BlahOS\\\") then \\\
 writeLine(\\\" -Deleting \\\\\\\"/BlahOS/\\\\\\\"\\\")\\\
 fs.delete(\\\"/BlahOS\\\") \\\
 write(\\\"[DONE]\\\")\\\
end\\\
if fs.exists(\\\"/Software\\\") then \\\
 writeLine(\\\" -Deleting \\\\\\\"/Software/\\\\\\\"\\\")\\\
 fs.delete(\\\"/Software\\\") \\\
 write(\\\"[DONE]\\\")\\\
end\\\
if fs.exists(\\\"startup\\\") then \\\
 writeLine(\\\" -Deleting \\\\\\\"startup\\\\\\\"\\\")\\\
 fs.delete(\\\"startup\\\") \\\
 write(\\\"[DONE]\\\")\\\
end\\\
if fs.exists(\\\"help\\\") then \\\
 writeLine(\\\" -Deleting \\\\\\\"help\\\\\\\"\\\")\\\
 fs.delete(\\\"help\\\") \\\
 write(\\\"[DONE]\\\")\\\
end\\\
writeLine(\\\"\\\")\\\
writeLine(\\\"Checking data source\\\")\\\
if     fs.exists(\\\"/BlahOS\\\") then d = \\\"\\\" \\\
elseif fs.exists(\\\"disk/BlahOS\\\") then d = \\\"disk\\\" \\\
elseif fs.exists(\\\"disk2/BlahOS\\\") then d = \\\"disk2\\\"\\\
elseif fs.exists(\\\"disk3/BlahOS\\\") then d = \\\"disk3\\\" \\\
elseif fs.exists(\\\"disk4/BlahOS\\\") then d = \\\"disk4\\\" \\\
elseif fs.exists(\\\"disk5/BlahOS\\\") then d = \\\"disk5\\\" \\\
elseif fs.exists(\\\"disk6/BlahOS\\\") then d = \\\"disk6\\\" \\\
end\\\
write(\\\"[DONE]\\\")\\\
\\\
writeLine(\\\"\\\")\\\
writeLine(\\\"Copying files\\\")\\\
fs.copy(d..\\\"/BlahOS/\\\", \\\"BlahOS\\\")\\\
fs.copy(d..\\\"/help\\\", \\\"help\\\")\\\
fs.copy(d..\\\"/startup\\\", \\\"startup\\\")\\\
fs.copy(d..\\\"/Software\\\", \\\"Software\\\")\\\
write(\\\"[DONE]\\\")\\\
\\\
writeLine(\\\"\\\")\\\
writeLine(\\\"Please remove the instalation disk\\\")\\\
while fs.exists(d..\\\"/BlahOS\\\") do sleep(1) end\\\
write(\\\"[DONE]\\\")\\\
\\\
writeLine(\\\"\\\")\\\
writeLine(\\\"Rebooting system in 5\\\")\\\
sleep(1)\\\
writeLine(\\\"Rebooting system in 4\\\")\\\
sleep(1)\\\
writeLine(\\\"Rebooting system in 3\\\")\\\
sleep(1)\\\
writeLine(\\\"Rebooting system in 2\\\")\\\
sleep(1)\\\
writeLine(\\\"Rebooting system in 1\\\")\\\
sleep(1)\\\
writeLine(\\\"Rebooting system in 0\\\")\\\
sleep(0.3)\\\
os.reboot()\\\
\",\
  },\
}")
if fs.isReadOnly(outputPath) then
	error("Output path is read-only.")
elseif fs.getFreeSpace(outputPath) <= #archive then
	error("Insufficient space.")
end
fs.delete(shell.getRunningProgram()) -- saves space
for name, contents in pairs(archive.data) do
	stc(colors.lightGray)
	write("'" .. name .. "'...")
	if contents == true then -- indicates empty directory
		fs.makeDir(fs.combine(outputPath, name))
	else
		file = fs.open(fs.combine(outputPath, name), "w")
		if file then
			file.write(contents)
			file.close()
		end
	end
	if file then
		stc(colors.green)
		print("good")
	else
		stc(colors.red)
		print("fail")
	end
end
stc(colors.white)
write("Unpacked to '")
stc(colors.yellow)
write(outputPath .. "/")
stc(colors.white)
print("'.")
