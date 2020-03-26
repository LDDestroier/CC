local tArg = {...}
local outputPath, file = tArg[1] and fs.combine(shell.dir(), tArg[1]) or "/"
local safeColorList = {[colors.white] = true,[colors.lightGray] = true,[colors.gray] = true,[colors.black] = true}
local stc = function(color) if (term.isColor() or safeColorList[color]) then term.setTextColor(color) end end
local archive = textutils.unserialize("{\
  mainFile = false,\
  compressed = false,\
  data = {\
    [ \"Programs/Quest.program/Views/main.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"Toolbar\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"InheritView\\\"]=\\\"toolbar\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=4,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Height\\\"]=\\\"100%,-3\\\",\\\
      [\\\"Width\\\"]=\\\"100%\\\",\\\
      [\\\"Name\\\"]=\\\"WebView\\\",\\\
      [\\\"Type\\\"]=\\\"WebView\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Height\\\"]=1,\\\
      [\\\"Width\\\"]=\\\"100%\\\",\\\
      [\\\"Name\\\"]=\\\"PageTitleLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Align\\\"]=\\\"Center\\\",\\\
      [\\\"TextColour\\\"]=128,\\\
    },\\\
  },\\\
  [\\\"BackgroundColour\\\"]=1,\\\
  [\\\"ToolBarColour\\\"]=256,\\\
  [\\\"ToolBarTextColour\\\"]=1\\\
}\",\
    [ \"Programs/Games/Maze3D.program/icon\" ] = \"e0 1 e 1 \\\
e0 1   \\\
e0   1 \",\
    [ \"Desktop/Programs.shortcut\" ] = \"/Programs/\",\
    [ \"Programs/Quest.program/Objects/HeadingView.lua\" ] = \"Inherit = 'View'\\\
Height = 3\\\
\\\
OnLoad = function(self)\\\
	self:OnUpdate('Text')\\\
end\\\
\\\
OnUpdate = function(self, value)\\\
	if value == 'Text' then\\\
		self:RemoveAllObjects()\\\
		self:AddObject({\\\
			Y = 1,\\\
			X = 1,\\\
			Width = \\\"100%\\\",\\\
			Align = \\\"Center\\\",\\\
			Type = \\\"Label\\\",\\\
			Text = self.Text,\\\
			TextColour = self.TextColour,\\\
			BackgroundColour = self.BackgroundColour\\\
		})\\\
\\\
		local underline = ''\\\
		for i = 1, #self.Text + 2 do\\\
			underline = underline .. '='\\\
		end\\\
		self:AddObject({\\\
			Y = 2,\\\
			X = 1,\\\
			Width = \\\"100%\\\",\\\
			Align = \\\"Center\\\",\\\
			Type = \\\"Label\\\",\\\
			Text = underline,\\\
			TextColour = self.TextColour,\\\
			BackgroundColour = self.BackgroundColour\\\
		})\\\
	end\\\
end\",\
    [ \"System/Programs/Desktop.program/Objects/FileView.lua\" ] = \"Inherit = 'View'\\\
\\\
BackgroundColour = colours.transparent\\\
Path = ''\\\
Width = 10\\\
Height = 4\\\
ClickTime = nil\\\
\\\
OnLoad = function(self)\\\
	self.Width = 10\\\
	self.Height = 4\\\
	local image = self:AddObject({\\\
		Type = 'ImageView',\\\
		X = 4,\\\
		Y = 1,\\\
		Width = 4,\\\
		Height = 3,\\\
		Image = OneOS.Helpers.IconForFile(self.Path),\\\
		Name = 'ImageView'..fs.getName(self.Path)\\\
	})\\\
	local label = self:AddObject({\\\
		Type = 'Label',\\\
		X = 1,\\\
		Y = 4,\\\
		Width = 10,\\\
		Text = self.Bedrock.Helpers.TruncateString(self.Bedrock.Helpers.RemoveExtension(fs.getName(self.Path)), 10),\\\
		Align = 'Center',\\\
		Name = 'Label'..fs.getName(self.Path)\\\
	})\\\
\\\
	if self.Bedrock.Helpers.Extension(self.Path) == 'shortcut' then\\\
		self:AddObject({\\\
			Type = 'Label',\\\
			X = 7,\\\
			Y = 3,\\\
			Width = 1,\\\
			Text = '>',\\\
			BackgroundColour=colours.white,\\\
			Name = 'ShortcutLabel'\\\
		})\\\
	end\\\
	local click = function(obj, event, side, x, y)\\\
		--local settings = OneOS.Settings or Settings\\\
		local setting = false\\\
		if OneOS then\\\
			setting = OneOS.Settings:GetValues()['DoubleClick']\\\
		else\\\
			setting = Settings:GetValues()['DoubleClick'] \\\
		end\\\
		--s:GetValues()['DoubleClick']\\\
		if side == 1 and setting and (not self.ClickTime or os.clock() - self.ClickTime <= 0.5) then\\\
			self.ClickTime = os.clock()\\\
		else\\\
			self:OnClick(event, side, x, y, obj)\\\
		end\\\
	end\\\
\\\
	label.OnClick = click\\\
	image.OnClick = click\\\
\\\
end\",\
    [ \"System/API/Peripheral.lua\" ] = \"GetPeripheral = function(_type)\\\
	for i, p in ipairs(GetPeripherals()) do\\\
		if p.Type == _type then\\\
			return p\\\
		end\\\
	end\\\
end\\\
\\\
Call = function(type, ...)\\\
	local tArgs = {...}\\\
	local p = GetPeripheral(type)\\\
	peripheral.call(p.Side, unpack(tArgs))\\\
end\\\
\\\
local getNames = peripheral.getNames or function()\\\
	local tResults = {}\\\
	for n,sSide in ipairs( rs.getSides() ) do\\\
		if peripheral.isPresent( sSide ) then\\\
			table.insert( tResults, sSide )\\\
			local isWireless = false\\\
			if pcall(function()isWireless = peripheral.call(sSide, 'isWireless') end) then\\\
				isWireless = true\\\
			end     \\\
			if peripheral.getType( sSide ) == \\\"modem\\\" and not isWireless then\\\
				local tRemote = peripheral.call( sSide, \\\"getNamesRemote\\\" )\\\
				for n,sName in ipairs( tRemote ) do\\\
					table.insert( tResults, sName )\\\
				end\\\
			end\\\
		end\\\
	end\\\
	return tResults\\\
end\\\
\\\
GetPeripherals = function(filterType)\\\
	local peripherals = {}\\\
	for i, side in ipairs(getNames()) do\\\
		local name = peripheral.getType(side):gsub(\\\"^%l\\\", string.upper)\\\
		local code = string.upper(side:sub(1,1))\\\
		if side:find('_') then\\\
			code = side:sub(side:find('_')+1)\\\
		end\\\
\\\
		local dupe = false\\\
		for i, v in ipairs(peripherals) do\\\
			if v[1] == name .. ' ' .. code then\\\
				dupe = true\\\
			end\\\
		end\\\
\\\
		if not dupe then\\\
			local _type = peripheral.getType(side)\\\
			local formattedType = _type:sub(1, 1):upper() .. _type:sub(2, -1)\\\
			local isWireless = false\\\
			if _type == 'modem' then\\\
				if not pcall(function()isWireless = peripheral.call(side, 'isWireless') end) then\\\
					isWireless = true\\\
				end     \\\
				if isWireless then\\\
					_type = 'wireless_modem'\\\
					formattedType = 'Wireless Modem'\\\
					name = 'W '..name\\\
				end\\\
			end\\\
			if not filterType or _type == filterType then\\\
				table.insert(peripherals, {Name = name:sub(1,8) .. ' '..code, Fullname = name .. ' ('..side:sub(1, 1):upper() .. side:sub(2, -1)..')', Side = side, Type = _type, Wireless = isWireless, FormattedType = formattedType})\\\
			end\\\
		end\\\
	end\\\
	return peripherals\\\
end\\\
\\\
GetSide = function(side)\\\
	for i, p in ipairs(GetPeripherals()) do\\\
		if p.Side == side then\\\
			return p\\\
		end\\\
	end\\\
end\\\
\\\
PresentNamed = function(name)\\\
	return peripheral.isPresent(name)\\\
end\\\
\\\
CallType = function(type, ...)\\\
	local tArgs = {...}\\\
	local p = GetPeripheral(type)\\\
	return peripheral.call(p.Side, unpack(tArgs))\\\
end\\\
\\\
CallNamed = function(name, ...)\\\
	local tArgs = {...}\\\
	return peripheral.call(name, unpack(tArgs))\\\
end\\\
\\\
GetInfo = function(p)\\\
	local info = {}\\\
	local buttons = {}\\\
	if p.Type == 'computer' then\\\
		local id = peripheral.call(p.Side:lower(),'getID')\\\
		if id then\\\
			info = {\\\
				ID = tostring(id)\\\
			}\\\
		else\\\
			info = {}\\\
		end\\\
	elseif p.Type == 'drive' then\\\
		local discType = 'No Disc'\\\
		local discID = nil\\\
		local mountPath = nil\\\
		local discLabel = nil\\\
		local songName = nil\\\
		if peripheral.call(p.Side:lower(), 'isDiskPresent') then\\\
			if peripheral.call(p.Side:lower(), 'hasData') then\\\
				discType = 'Data'\\\
				discID = peripheral.call(p.Side:lower(), 'getDiskID')\\\
				if discID then\\\
					discID = tostring(discID)\\\
				else\\\
					discID = 'None'\\\
				end\\\
				mountPath = '/'..peripheral.call(p.Side:lower(), 'getMountPath')..'/'\\\
				discLabel = peripheral.call(p.Side:lower(), 'getDiskLabel')\\\
			else\\\
				discType = 'Audio'\\\
				songName = peripheral.call(p.Side:lower(), 'getAudioTitle')\\\
			end\\\
		end\\\
		if mountPath then\\\
			table.insert(buttons, {Text = 'View Files', OnClick = function(self, event, side, x, y)GoToPath(mountPath)end})\\\
		elseif discType == 'Audio' then\\\
			table.insert(buttons, {Text = 'Play', OnClick = function(self, event, side, x, y)\\\
				if self.Text == 'Play' then\\\
					disk.playAudio(p.Side:lower())\\\
					self.Text = 'Stop'\\\
				else\\\
					disk.stopAudio(p.Side:lower())\\\
					self.Text = 'Play'\\\
				end\\\
			end})\\\
		else\\\
			diskOpenButton = nil\\\
		end\\\
		if discType ~= 'No Disc' then\\\
			table.insert(buttons, {Text = 'Eject', OnClick = function(self, event, side, x, y)disk.eject(p.Side:lower()) sleep(0) RefreshFiles() end})\\\
		end\\\
\\\
		info = {\\\
			['Disc Type'] = discType,\\\
			['Disc Label'] = discLabel,\\\
			['Song Title'] = songName,\\\
			['Disc ID'] = discID,\\\
			['Mount Path'] = mountPath\\\
		}\\\
	elseif p.Type == 'printer' then\\\
		local pageSize = 'No Loaded Page'\\\
		local _, err = pcall(function() return tostring(peripheral.call(p.Side:lower(), 'getPgaeSize')) end)\\\
		if not err then\\\
			pageSize = tostring(peripheral.call(p.Side:lower(), 'getPageSize'))\\\
		end\\\
		info = {\\\
			['Paper Level'] = tostring(peripheral.call(p.Side:lower(), 'getPaperLevel')),\\\
			['Paper Size'] = pageSize,\\\
			['Ink Level'] = tostring(peripheral.call(p.Side:lower(), 'getInkLevel'))\\\
		}\\\
	elseif p.Type == 'modem' then\\\
		info = {\\\
			['Connected Peripherals'] = tostring(#peripheral.call(p.Side:lower(), 'getNamesRemote'))\\\
		}\\\
	elseif p.Type == 'monitor' then\\\
		local w, h = peripheral.call(p.Side:lower(), 'getSize')\\\
		local screenType = 'Black and White'\\\
		if peripheral.call(p.Side:lower(), 'isColour') then\\\
			screenType = 'Colour'\\\
		end\\\
		local buttonTitle = 'Use as Screen'\\\
		if OneOS.Settings:GetValues()['Monitor'] == p.Side:lower() then\\\
			buttonTitle = 'Use Computer Screen'\\\
		end\\\
		table.insert(buttons, {Text = buttonTitle, OnClick = function(self, event, side, x, y)\\\
				self.Bedrock:DisplayAlertWindow('Reboot Required', \\\"To change screen you'll need to reboot your computer.\\\", {'Reboot', 'Cancel'}, function(value)\\\
					if value == 'Reboot' then\\\
						if buttonTitle == 'Use Computer Screen' then\\\
							OneOS.Settings:SetValue('Monitor', nil)\\\
						else\\\
							OneOS.Settings:SetValue('Monitor', p.Side:lower())\\\
						end\\\
						OneOS.Reboot()\\\
					end\\\
				end)\\\
			end\\\
		})\\\
		info = {\\\
			['Type'] = screenType,\\\
			['Width'] = tostring(w),\\\
			['Height'] = tostring(h),\\\
		}\\\
	end\\\
	info.Buttons = buttons\\\
	return info\\\
end\",\
    [ \"Programs/App Store.program/api\" ] = \"--[[\\\
\\\
ComputerCraft AppStore API by oeed\\\
For documentation on how to use it go to ccappstore.com/help/api/\\\
\\\
]]--\\\
\\\
local function contains(table, element)\\\
  for _, value in pairs(table) do\\\
    if value == element then\\\
      return true\\\
    end\\\
  end\\\
  return false\\\
end\\\
\\\
local apiURL = \\\"http://ccappstore.com/api/\\\"\\\
\\\
local function checkHTTP()\\\
	if http then\\\
		return true\\\
	else\\\
		return false\\\
	end\\\
end\\\
\\\
local function requireHTTP()\\\
	if checkHTTP() then\\\
		return true\\\
	else\\\
		error(\\\"The 'http' API is not enabled!\\\")\\\
	end\\\
end\\\
\\\
function doRequest(command, subcommand, values)\\\
	values = values or {}\\\
	requireHTTP()\\\
\\\
	local url = apiURL .. \\\"?command=\\\" .. command ..\\\"&subcommand=\\\" .. subcommand\\\
	for k, v in pairs(values) do\\\
		url = url .. \\\"&\\\" .. k .. \\\"=\\\" .. v\\\
	end\\\
	local request = http.get(url)\\\
	if request then\\\
		local response = request.readAll()\\\
		request.close()\\\
		if response == \\\"<h2>The server is too busy at the moment.</h2><p>Please reload this page few seconds later.</p>\\\" then\\\
			error(\\\"Server is too busy at the moment.\\\")\\\
		end\\\
		local t = textutils.unserialize(response)\\\
		if t then\\\
			return t\\\
		else\\\
			return response\\\
		end\\\
	end\\\
	return nil\\\
end\\\
\\\
function getAllApplications()\\\
	return doRequest('application', 'all')\\\
end\\\
\\\
function getTopCharts()\\\
	return doRequest('application', 'topcharts')\\\
end\\\
\\\
function getApplicationsInCategory(name)\\\
	return doRequest('application', 'category', {name = name})\\\
end\\\
\\\
function getFeaturedApplications()\\\
	return doRequest('application', 'featured')\\\
end\\\
\\\
function getApplication(id)\\\
	return doRequest('application', 'get', {id = id})\\\
end\\\
\\\
function getCategories(id)\\\
	return doRequest('application', 'categories')\\\
end\\\
\\\
function addApplication(username, password, serializeddata, name, description, sdescription, category)\\\
	return doRequest('application', 'add', {username = username, password = password, serializeddata = serializeddata, name = name, description = description, sdescription = sdescription, category = category})\\\
end\\\
--[[\\\
function deleteApplication(id, username, password)\\\
	return doRequest('application', 'delete', {id = id, username = username, password = password})\\\
end\\\
\\\
function updateApplication(id, username, password, serializeddata, name, description, sdescription, category)\\\
	return doRequest('application', 'update', {id = id, username = username, password = password, serializeddata = serializeddata, name = name, description = description, sdescription = sdescription, category = category})\\\
end\\\
]]--\\\
\\\
function addChangeLogToApplication(id, username, password, changelog, version)\\\
	return doRequest('application', 'addchangelog', {id = id, username = username, password = password, changelog = changelog, version = version})\\\
end\\\
\\\
function downloadApplication(id)\\\
	return doRequest('application', 'download', {id = id})\\\
end\\\
\\\
function searchApplications(name)\\\
	return doRequest('application', 'search', {name = name})\\\
end\\\
\\\
function getAllNews()\\\
	return doRequest('news', 'all')\\\
end\\\
\\\
function getNews(id)\\\
	return doRequest('news', 'get', {id = id})\\\
end\\\
\\\
function getInstalledApplications(id)\\\
	return doRequest('computer', 'get', {id = id})\\\
end\\\
\\\
local function resolve( _sPath )\\\
	local sStartChar = string.sub( _sPath, 1, 1 )\\\
	if sStartChar == \\\"/\\\" or sStartChar == \\\"\\\\\\\\\\\" then\\\
		return fs.combine( \\\"\\\", _sPath )\\\
	else\\\
		return fs.combine( sDir, _sPath )\\\
	end\\\
end\\\
\\\
function saveApplicationIcon(id, path)\\\
	local app = getApplication(id)\\\
	local icon = app.icon\\\
	local _fs = fs\\\
	if OneOS then\\\
		_fs = OneOS.FS\\\
	end\\\
	local h = _fs.open(path, 'w')\\\
	h.write(icon)\\\
	h.close()\\\
end\\\
--Downloads and installs an application\\\
--id = the id of the application\\\
--path = the path is the name of the folder/file it'll be copied too\\\
--removeSpaces = removes spaces from the name (useful if its being run from the shell)\\\
--alwaysFolder = be default if there is only one file it will save it as a single file, if true files will always be placed in a folder\\\
--fullPath = if true the given path will not be changed, if false the program name will be appended\\\
function installApplication(id, path, removeSpaces, alwaysFolder, fullPath)\\\
	local package = downloadApplication(id)\\\
	if type(package) ~= 'string' or #package == 0 then\\\
		error('The application did not download correctly or is empty. Try again.')\\\
	end\\\
	local pack = JSON.decode(package)\\\
	if pack then\\\
\\\
		local _fs = fs\\\
		if OneOS then\\\
			_fs = OneOS.FS\\\
		end\\\
		local function makeFile(_path,_content)\\\
			sleep(0)\\\
			local file=_fs.open(_path,\\\"w\\\")\\\
			file.write(_content)\\\
			file.close()\\\
		end\\\
		local function makeFolder(_path,_content)\\\
			_fs.makeDir(_path)\\\
				for k,v in pairs(_content) do\\\
					if type(v)==\\\"table\\\" then\\\
						makeFolder(_path..\\\"/\\\"..k,v)\\\
					else\\\
						makeFile(_path..\\\"/\\\"..k,v)\\\
					end\\\
				end\\\
		end\\\
\\\
		local app = getApplication(id)\\\
		local appName = app['name']\\\
		local keyCount = 0\\\
		for k, v in pairs(pack) do\\\
			keyCount = keyCount + 1\\\
		end\\\
		if removeSpaces then\\\
			appName = appName:gsub(\\\" \\\", \\\"\\\")\\\
		end\\\
		local location = path..'/'\\\
		if not fullPath then\\\
			location = location .. appName\\\
		end\\\
		if keyCount == 1 and not alwaysFolder then\\\
			makeFile(location, pack['startup'])\\\
		else\\\
			makeFolder(location, pack)\\\
			location = location .. '/startup'\\\
		end\\\
\\\
		return location\\\
	else\\\
		error('The application appears to be corrupt. Try downloading it again.')\\\
	end\\\
end\\\
\\\
function registerComputer(realid, username, password)\\\
	return doRequest('computer', 'register', {realid = realid, username = username, password = password})\\\
end\\\
\\\
function getAllComments(type, id)\\\
	return doRequest('comment', 'get', {ctype = type, ctypeid = id})\\\
end\\\
\\\
function getComment(id)\\\
	return doRequest('comment', 'get', {id = id})\\\
end\\\
\\\
function deleteComment(id, username, password)\\\
	return doRequest('comment', 'delete', {id = id, username = username, password = password})\\\
end\\\
\\\
function addComments()\\\
	return doRequest('comment', 'get', {id = id})\\\
end\\\
\\\
function getUser()\\\
	return doRequest('user', 'get', {id = id})\\\
end\\\
\\\
function registerUser(username, password, email, mcusername)\\\
	return doRequest('user', 'register', {username = username, password = password, email = email, mcusername = mcusername})\\\
end\\\
\\\
function testConnection()\\\
	local ok = false\\\
  	parallel.waitForAny(function()\\\
	    if http and http.get(apiURL) then\\\
			ok = true\\\
		end\\\
	end,function()\\\
	  	sleep(10)\\\
	end)\\\
	if not ok then\\\
		error('Network error')\\\
	end\\\
	return ok	\\\
end\",\
    [ \"Programs/Quest.program/Elements/Heading.lua\" ] = \"Align = \\\"Center\\\"\\\
\\\
OnInitialise = function(self, node)\\\
	local attr = self.Attributes\\\
	self.Text = self.Text or ''\\\
	if attr.align then\\\
		if attr.align:lower() == 'left' or attr.align:lower() == 'center' or attr.align:lower() == 'right' then\\\
			self.Align = attr.align:lower():gsub(\\\"^%l\\\", string.upper)\\\
		end\\\
	end\\\
end\\\
\\\
OnCreateObject = function(self, parentObject, y)\\\
	return {\\\
		Element = self,\\\
		Y = y,\\\
		X = 1,\\\
		Width = \\\"100%\\\",\\\
		Align = self.Align,\\\
		Type = \\\"HeadingView\\\",\\\
		Text = self.Text,\\\
		TextColour = self.TextColour,\\\
		BackgroundColour = self.BackgroundColour\\\
	}\\\
end\",\
    [ \"Programs/Quest.program/Elements/Select.lua\" ] = \"Width = 20\\\
InputName = ''\\\
\\\
OnInitialise = function(self, node)\\\
	if attr.value then\\\
		new.Text = attr.value\\\
	end\\\
\\\
	if attr.name then\\\
		new.InputName = attr.name\\\
	end\\\
end\\\
\\\
UpdateValue = function(self)\\\
	self.Value = self.Object.MenuItems[self.Object.Selected].Value\\\
end\\\
\\\
OnCreateObject = function(self, parentObject, y)\\\
	return {\\\
		Element = self,\\\
		Y = y,\\\
		X = 1,\\\
		Width = self.Width,\\\
		Type = \\\"SelectView\\\",\\\
		TextColour = self.TextColour,\\\
		BackgroundColour = self.BackgroundColour,\\\
		InputName = self.InputName,\\\
	}\\\
end\",\
    [ \"Desktop/Ink.shortcut\" ] = \"/Programs/Ink.program/\",\
    [ \"Programs/Ink.program/startup\" ] = \"tArgs={...}\\\
if OneOS then\\\
OneOS.ToolBarColour=colours.grey\\\
OneOS.ToolBarTextColour=colours.white\\\
end\\\
local e,e=term.getSize()\\\
local h=function(t,e)\\\
local e=10^(e or 0)\\\
return math.floor(t*e+.5)/e\\\
end\\\
UIColours={\\\
Toolbar=colours.grey,\\\
ToolbarText=colours.lightGrey,\\\
ToolbarSelected=colours.lightBlue,\\\
ControlText=colours.white,\\\
ToolbarItemTitle=colours.black,\\\
Background=colours.lightGrey,\\\
MenuBackground=colours.white,\\\
MenuText=colours.black,\\\
MenuSeparatorText=colours.grey,\\\
MenuDisabledText=colours.lightGrey,\\\
Shadow=colours.grey,\\\
TransparentBackgroundOne=colours.white,\\\
TransparentBackgroundTwo=colours.lightGrey,\\\
MenuBarActive=colours.white\\\
}\\\
local e=peripheral.getNames or function()\\\
local t={}\\\
for a,e in ipairs(rs.getSides())do\\\
if peripheral.isPresent(e)then\\\
table.insert(t,e)\\\
local a=false\\\
if not pcall(function()a=peripheral.call(e,'isWireless')end)then\\\
a=true\\\
end\\\
if peripheral.getType(e)==\\\"modem\\\"and not a then\\\
local e=peripheral.call(e,\\\"getNamesRemote\\\")\\\
for a,e in ipairs(e)do\\\
table.insert(t,e)\\\
end\\\
end\\\
end\\\
end\\\
return t\\\
end\\\
OneOS.LoadAPI('System/API/Peripheral.lua')\\\
TextLine={\\\
Text=\\\"\\\",\\\
Alignment=AlignmentLeft,\\\
Initialise=function(o,t,a)\\\
local e={}\\\
setmetatable(e,{__index=o})\\\
e.Text=t\\\
e.Alignment=a or AlignmentLeft\\\
return e\\\
end\\\
}\\\
local s=function(e)\\\
return e:gsub('['..string.char(14)..'-'..string.char(29)..']','')\\\
end\\\
Printer = {\\\
Name = nil,\\\
PeripheralType = 'printer',\\\
paperLevel = function(self)\\\
return Peripheral.CallNamed(self.Name, 'getPaperLevel')\\\
end,\\\
newPage = function(self)\\\
return Peripheral.CallNamed(self.Name, 'newPage')\\\
end,\\\
endPage = function(self)\\\
return Peripheral.CallNamed(self.Name, 'endPage')\\\
end,\\\
pageWrite = function(self, text)\\\
return Peripheral.CallNamed(self.Name, 'write', text)\\\
end,\\\
setPageTitle = function(self, title)\\\
return Peripheral.CallNamed(self.Name, 'setPageTitle', title)\\\
end,\\\
inkLevel = function(self)\\\
return Peripheral.CallNamed(self.Name, 'getInkLevel')\\\
end,\\\
getCursorPos = function(self)\\\
return Peripheral.CallNamed(self.Name, 'getCursorPos')\\\
end,\\\
setCursorPos = function(self, x, y)\\\
return Peripheral.CallNamed(self.Name, 'setCursorPos', x, y)\\\
end,\\\
pageSize = function(self)\\\
return Peripheral.CallNamed(self.Name, 'getPageSize')\\\
end,\\\
Present = function()\\\
if Peripheral.GetPeripheral(Printer.PeripheralType) == nil then\\\
return false\\\
else\\\
return true\\\
end\\\
end,\\\
PrintLines = function(self, lines, title, copies)\\\
local pages = {}\\\
local pageLines = {}\\\
for i, line in ipairs(lines) do\\\
table.insert(pageLines, TextLine:Initialise(s(line)))\\\
if i % 25 == 0 then\\\
table.insert(pages, pageLines)\\\
pageLines = {}\\\
end\\\
end\\\
if #pageLines ~= 0 then\\\
table.insert(pages, pageLines)\\\
end\\\
return self:PrintPages(pages, title, copies)\\\
end,\\\
PrintPages = function(self, pages, title, copies)\\\
copies = copies or 1\\\
for c = 1, copies do\\\
for p, page in ipairs(pages) do\\\
if self:paperLevel() < #pages * copies then\\\
return 'Add more paper to the printer'\\\
end\\\
if self:inkLevel() < #pages * copies then\\\
return 'Add more ink to the printer'\\\
end\\\
self:newPage()\\\
for i, line in ipairs(page) do\\\
self:setCursorPos(1, i)\\\
self:pageWrite(s(line.Text))\\\
end\\\
if title then\\\
self:setPageTitle(title)\\\
end\\\
self:endPage()\\\
end\\\
end\\\
end,\\\
Initialise = function(self, name)\\\
if Printer.Present() then --fix\\\
local new = {}    -- the new instance\\\
setmetatable( new, {__index = self} )\\\
if name and Peripheral.PresentNamed(name) then\\\
new.Name = name\\\
else\\\
new.Name = Peripheral.GetPeripheral(Printer.PeripheralType).Side\\\
end\\\
return new\\\
end\\\
end\\\
}\\\
Clipboard=OneOS.Clipboard\\\
OneOS.LoadAPI('System/API/LegacyDrawing.lua')\\\
local Drawing = LegacyDrawing\\\
Current={\\\
Document=nil,\\\
TextInput=nil,\\\
CursorPos={1,1},\\\
CursorColour=colours.black,\\\
Selection={8,36},\\\
Window=nil,\\\
Modified=false,\\\
}\\\
local c=false\\\
function OrderSelection()\\\
if Current.Selection then\\\
if Current.Selection[1]<=Current.Selection[2]then\\\
return Current.Selection\\\
else\\\
return{Current.Selection[2],Current.Selection[1]}\\\
end\\\
end\\\
end\\\
function s(e)\\\
return e:gsub('['..string.char(14)..'-'..string.char(29)..']','')\\\
end\\\
function FindColours(e)\\\
local t,e=e:gsub('['..string.char(14)..'-'..string.char(29)..']','')\\\
return e\\\
end\\\
ColourFromCharacter=function(e)\\\
local e=e:byte()-14\\\
if e>16 then\\\
return nil\\\
else\\\
return 2^e\\\
end\\\
end\\\
CharacterFromColour=function(e)\\\
return string.char(math.floor(math.log(e)/math.log(2))+14)\\\
end\\\
Events={}\\\
Button={\\\
X=1,\\\
Y=1,\\\
Width=0,\\\
Height=0,\\\
BackgroundColour=colours.lightGrey,\\\
TextColour=colours.white,\\\
ActiveBackgroundColour=colours.lightGrey,\\\
Text=\\\"\\\",\\\
Parent=nil,\\\
_Click=nil,\\\
Toggle=nil,\\\
AbsolutePosition=function(e)\\\
return e.Parent:AbsolutePosition()\\\
end,\\\
Draw=function(e)\\\
local t=e.BackgroundColour\\\
local o=e.TextColour\\\
if type(t)=='function'then\\\
t=t()\\\
end\\\
if e.Toggle then\\\
o=UIColours.MenuBarActive\\\
t=e.ActiveBackgroundColour\\\
end\\\
local a=GetAbsolutePosition(e)\\\
Drawing.DrawBlankArea(a.X,a.Y,e.Width,e.Height,t)\\\
Drawing.DrawCharactersCenter(a.X,a.Y,e.Width,e.Height,e.Text,o,t)\\\
end,\\\
Initialise=function(d,l,c,u,t,h,n,r,a,i,o,s)\\\
local e={}\\\
setmetatable(e,{__index=d})\\\
t=t or 1\\\
e.Width=u or#a+2\\\
e.Height=t\\\
e.Y=c\\\
e.X=l\\\
e.Text=a or\\\"\\\"\\\
e.BackgroundColour=h or colours.lightGrey\\\
e.TextColour=i or colours.white\\\
e.ActiveBackgroundColour=s or colours.lightGrey\\\
e.Parent=n\\\
e._Click=r\\\
e.Toggle=o\\\
return e\\\
end,\\\
Click=function(e,o,a,t)\\\
if e._Click then\\\
if e:_Click(o,a,t,not e.Toggle)~=false and e.Toggle~=nil then\\\
e.Toggle=not e.Toggle\\\
Draw()\\\
end\\\
return true\\\
else\\\
return false\\\
end\\\
end\\\
}\\\
TextBox={\\\
X=1,\\\
Y=1,\\\
Width=0,\\\
Height=0,\\\
BackgroundColour=colours.lightGrey,\\\
TextColour=colours.black,\\\
Parent=nil,\\\
TextInput=nil,\\\
Placeholder='',\\\
AbsolutePosition=function(e)\\\
return e.Parent:AbsolutePosition()\\\
end,\\\
Draw=function(e)\\\
local t=GetAbsolutePosition(e)\\\
Drawing.DrawBlankArea(t.X,t.Y,e.Width,e.Height,e.BackgroundColour)\\\
local a=e.TextInput.Value\\\
if#tostring(a)>(e.Width-2)then\\\
a=a:sub(#a-(e.Width-3))\\\
if Current.TextInput==e.TextInput then\\\
Current.CursorPos={t.X+1+e.Width-2,t.Y}\\\
end\\\
else\\\
if Current.TextInput==e.TextInput then\\\
Current.CursorPos={t.X+1+e.TextInput.CursorPos,t.Y}\\\
end\\\
end\\\
if#tostring(a)==0 then\\\
Drawing.DrawCharacters(t.X+1,t.Y,e.Placeholder,colours.lightGrey,e.BackgroundColour)\\\
else\\\
Drawing.DrawCharacters(t.X+1,t.Y,a,e.TextColour,e.BackgroundColour)\\\
end\\\
term.setCursorBlink(true)\\\
Current.CursorColour=e.TextColour\\\
end,\\\
Initialise=function(h,r,s,i,t,n,o,d,u,a,l)\\\
local e={}\\\
setmetatable(e,{__index=h})\\\
t=t or 1\\\
e.Width=i or#o+2\\\
e.Height=t\\\
e.Y=s\\\
e.X=r\\\
e.TextInput=TextInput:Initialise(o or'',function(e)\\\
if a then\\\
a(e)\\\
end\\\
Draw()\\\
end,l)\\\
e.BackgroundColour=d or colours.lightGrey\\\
e.TextColour=u or colours.black\\\
e.Parent=n\\\
return e\\\
end,\\\
Click=function(e,t,t,t)\\\
Current.Input=e.TextInput\\\
e:Draw()\\\
end\\\
}\\\
TextInput={\\\
Value=\\\"\\\",\\\
Change=nil,\\\
CursorPos=nil,\\\
Numerical=false,\\\
IsDocument=nil,\\\
Initialise=function(n,t,i,o,a)\\\
local e={}\\\
setmetatable(e,{__index=n})\\\
e.Value=tostring(t)\\\
e.Change=i\\\
e.CursorPos=#tostring(t)\\\
e.Numerical=o\\\
e.IsDocument=a or false\\\
return e\\\
end,\\\
Insert=function(e,t)\\\
if e.Numerical then\\\
t=tostring(tonumber(t))\\\
end\\\
local a=OrderSelection()\\\
if e.IsDocument and a then\\\
e.Value=string.sub(e.Value,1,a[1]-1)..t..string.sub(e.Value,a[2]+2)\\\
e.CursorPos=a[1]\\\
Current.Selection=nil\\\
else\\\
local o,a=string.gsub(e.Value:sub(1,e.CursorPos),'\\\\n','')\\\
e.Value=string.sub(e.Value,1,e.CursorPos+a)..t..string.sub(e.Value,e.CursorPos+1+a)\\\
e.CursorPos=e.CursorPos+1\\\
end\\\
e.Change(key)\\\
end,\\\
Extract=function(t,i)\\\
local e=OrderSelection()\\\
if t.IsDocument and e then\\\
local o,a=string.gsub(t.Value:sub(e[1],e[2]),'\\\\n','')\\\
local o=string.sub(t.Value,e[1],e[2]+1+a)\\\
if i then\\\
t.Value=string.sub(t.Value,1,e[1]-1)..string.sub(t.Value,e[2]+2+a)\\\
t.CursorPos=e[1]-1\\\
Current.Selection=nil\\\
end\\\
return o\\\
end\\\
end,\\\
Char=function(t,e)\\\
if e=='nil'then\\\
return\\\
end\\\
t:Insert(e)\\\
end,\\\
Key=function(e,t)\\\
if t==keys.enter then\\\
if e.IsDocument then\\\
e.Value=string.sub(e.Value,1,e.CursorPos)..'\\\\n'..string.sub(e.Value,e.CursorPos+1)\\\
e.CursorPos=e.CursorPos+1\\\
end\\\
e.Change(t)\\\
elseif t==keys.left then\\\
if e.CursorPos>0 then\\\
local a=FindColours(string.sub(e.Value,e.CursorPos,e.CursorPos))\\\
e.CursorPos=e.CursorPos-1-a\\\
e.Change(t)\\\
end\\\
elseif t==keys.right then\\\
if e.CursorPos<string.len(e.Value)then\\\
local a=FindColours(string.sub(e.Value,e.CursorPos+1,e.CursorPos+1))\\\
e.CursorPos=e.CursorPos+1+a\\\
e.Change(t)\\\
end\\\
elseif t==keys.backspace then\\\
if e.IsDocument and Current.Selection then\\\
e:Extract(true)\\\
e.Change(t)\\\
elseif e.CursorPos>0 then\\\
local a=FindColours(string.sub(e.Value,e.CursorPos,e.CursorPos))\\\
local i,o=string.gsub(e.Value:sub(1,e.CursorPos),'\\\\n','')\\\
e.Value=string.sub(e.Value,1,e.CursorPos-1-a+o)..string.sub(e.Value,e.CursorPos+1-a+o)\\\
e.CursorPos=e.CursorPos-1-a\\\
e.Change(t)\\\
end\\\
elseif t==keys.home then\\\
e.CursorPos=0\\\
e.Change(t)\\\
elseif t==keys.delete then\\\
if e.IsDocument and Current.Selection then\\\
e:Extract(true)\\\
e.Change(t)\\\
elseif e.CursorPos<string.len(e.Value)then\\\
e.Value=string.sub(e.Value,1,e.CursorPos)..string.sub(e.Value,e.CursorPos+2)\\\
e.Change(t)\\\
end\\\
elseif t==keys[\\\"end\\\"]then\\\
e.CursorPos=string.len(e.Value)\\\
e.Change(t)\\\
elseif t==keys.up and e.IsDocument then\\\
if Current.Document.CursorPos then\\\
local a=Current.Document.Pages[Current.Document.CursorPos.Page]\\\
e.CursorPos=a:GetCursorPosFromPoint(Current.Document.CursorPos.Collum+a.MarginX,Current.Document.CursorPos.Line-a.MarginY-1+Current.Document.ScrollBar.Scroll,true)\\\
e.Change(t)\\\
end\\\
elseif t==keys.down and e.IsDocument then\\\
if Current.Document.CursorPos then\\\
local a=Current.Document.Pages[Current.Document.CursorPos.Page]\\\
e.CursorPos=a:GetCursorPosFromPoint(Current.Document.CursorPos.Collum+a.MarginX,Current.Document.CursorPos.Line-a.MarginY+1+Current.Document.ScrollBar.Scroll,true)\\\
e.Change(t)\\\
end\\\
end\\\
end\\\
}\\\
Menu={\\\
X=0,\\\
Y=0,\\\
Width=0,\\\
Height=0,\\\
Owner=nil,\\\
Items={},\\\
RemoveTop=false,\\\
Draw=function(e)\\\
Drawing.DrawBlankArea(e.X+1,e.Y+1,e.Width,e.Height,UIColours.Shadow)\\\
if not e.RemoveTop then\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,e.Height,UIColours.MenuBackground)\\\
for a,t in ipairs(e.Items)do\\\
if t.Separator then\\\
Drawing.DrawArea(e.X,e.Y+a,e.Width,1,'-',colours.grey,UIColours.MenuBackground)\\\
else\\\
local o=t.Colour or UIColours.MenuText\\\
if(t.Enabled and type(t.Enabled)=='function'and t.Enabled()==false)or t.Enabled==false then\\\
o=UIColours.MenuDisabledText\\\
end\\\
Drawing.DrawCharacters(e.X+1,e.Y+a,t.Title,o,UIColours.MenuBackground)\\\
end\\\
end\\\
else\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,e.Height,UIColours.MenuBackground)\\\
for a,t in ipairs(e.Items)do\\\
if t.Separator then\\\
Drawing.DrawArea(e.X,e.Y+a-1,e.Width,1,'-',colours.grey,UIColours.MenuBackground)\\\
else\\\
local o=t.Colour or UIColours.MenuText\\\
if(t.Enabled and type(t.Enabled)=='function'and t.Enabled()==false)or t.Enabled==false then\\\
o=UIColours.MenuDisabledText\\\
end\\\
Drawing.DrawCharacters(e.X+1,e.Y+a-1,t.Title,o,UIColours.MenuBackground)\\\
Drawing.DrawCharacters(e.X-1+e.Width-#t.KeyName,e.Y+a-1,t.KeyName,o,UIColours.MenuBackground)\\\
end\\\
end\\\
end\\\
end,\\\
NameForKey=function(t,e)\\\
if e==keys.leftCtrl then\\\
return'^'\\\
elseif e==keys.tab then\\\
return'Tab'\\\
elseif e==keys.delete then\\\
return'Delete'\\\
elseif e==keys.n then\\\
return'N'\\\
elseif e==keys.a then\\\
return'A'\\\
elseif e==keys.s then\\\
return'S'\\\
elseif e==keys.o then\\\
return'O'\\\
elseif e==keys.z then\\\
return'Z'\\\
elseif e==keys.y then\\\
return'Y'\\\
elseif e==keys.c then\\\
return'C'\\\
elseif e==keys.x then\\\
return'X'\\\
elseif e==keys.v then\\\
return'V'\\\
elseif e==keys.r then\\\
return'R'\\\
elseif e==keys.l then\\\
return'L'\\\
elseif e==keys.t then\\\
return'T'\\\
elseif e==keys.h then\\\
return'H'\\\
elseif e==keys.e then\\\
return'E'\\\
elseif e==keys.p then\\\
return'P'\\\
elseif e==keys.f then\\\
return'F'\\\
elseif e==keys.m then\\\
return'M'\\\
elseif e==keys.q then\\\
return'Q'\\\
else\\\
return'?'\\\
end\\\
end,\\\
Initialise=function(i,a,o,t,n,s)\\\
local e={}\\\
setmetatable(e,{__index=i})\\\
if not n then\\\
return\\\
end\\\
local h={}\\\
for e,a in ipairs(t)do\\\
t[e].KeyName=''\\\
if a.Keys then\\\
for o,a in ipairs(a.Keys)do\\\
t[e].KeyName=t[e].KeyName..i:NameForKey(a)\\\
end\\\
end\\\
if t[e].KeyName~=''then\\\
table.insert(h,t[e].KeyName)\\\
end\\\
end\\\
local i=LongestString(h)\\\
if i>0 then\\\
i=i+2\\\
end\\\
e.Width=LongestString(t,'Title')+2+i\\\
if e.Width<10 then\\\
e.Width=10\\\
end\\\
e.Height=#t+2\\\
e.RemoveTop=s or false\\\
if s then\\\
e.Height=e.Height-1\\\
end\\\
if o<1 then\\\
o=1\\\
end\\\
if a<1 then\\\
a=1\\\
end\\\
if o+e.Height>Drawing.Screen.Height+1 then\\\
o=Drawing.Screen.Height-e.Height\\\
end\\\
if a+e.Width>Drawing.Screen.Width+1 then\\\
a=Drawing.Screen.Width-e.Width\\\
end\\\
e.Y=o\\\
e.X=a\\\
e.Items=t\\\
e.Owner=n\\\
return e\\\
end,\\\
New=function(t,a,o,n,e,i)\\\
if Current.Menu and Current.Menu.Owner==e then\\\
Current.Menu=nil\\\
return\\\
end\\\
local e=t:Initialise(a,o,n,e,i)\\\
Current.Menu=e\\\
return e\\\
end,\\\
Click=function(e,t,t,a)\\\
local t=a-1\\\
if e.RemoveTop then\\\
t=a\\\
end\\\
if t>=1 and a<e.Height then\\\
if not((e.Items[t].Enabled and type(e.Items[t].Enabled)=='function'and e.Items[t].Enabled()==false)or e.Items[t].Enabled==false)and e.Items[t].Click then\\\
e.Items[t]:Click()\\\
if Current.Menu.Owner and Current.Menu.Owner.Toggle then\\\
Current.Menu.Owner.Toggle=false\\\
end\\\
Current.Menu=nil\\\
e=nil\\\
end\\\
return true\\\
end\\\
end\\\
}\\\
MenuBar={\\\
X=1,\\\
Y=1,\\\
Width=Drawing.Screen.Width,\\\
Height=1,\\\
MenuBarItems={},\\\
AbsolutePosition=function(e)\\\
return{X=e.X,Y=e.Y}\\\
end,\\\
Draw=function(e)\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,e.Height,colours.grey)\\\
for t,e in ipairs(e.MenuBarItems)do\\\
e:Draw()\\\
end\\\
end,\\\
Initialise=function(t,a)\\\
local e={}\\\
setmetatable(e,{__index=t})\\\
e.X=1\\\
e.Y=1\\\
e.MenuBarItems=a\\\
return e\\\
end,\\\
AddToolbarItem=function(e,t)\\\
table.insert(e.ToolbarItems,t)\\\
e:CalculateToolbarItemPositions()\\\
end,\\\
CalculateToolbarItemPositions=function(t)\\\
local e=1\\\
for a,t in ipairs(t.ToolbarItems)do\\\
t.Y=e\\\
e=e+t.Height\\\
end\\\
end,\\\
Click=function(e,a,t,o)\\\
for o,e in ipairs(e.MenuBarItems)do\\\
if e.X<=t and e.X+e.Width>t then\\\
if e:Click(e,a,t-e.X+1,1)then\\\
return true\\\
end\\\
end\\\
end\\\
return false\\\
end\\\
}\\\
TextFormatPlainText=1\\\
TextFormatInkText=2\\\
Document={\\\
X=1,\\\
Y=1,\\\
PageSize={Width=25,Height=21},\\\
TextInput=nil,\\\
Pages={},\\\
Format=TextFormatPlainText,\\\
Title='',\\\
Path=nil,\\\
ScrollBar=nil,\\\
Lines={},\\\
CursorPos=nil,\\\
CalculateLineWrapping=function(e)\\\
local a=e.PageSize.Width\\\
local t=e.TextInput.Value\\\
local e={''}\\\
local o={}\\\
for t,n in t:gmatch('(%S+)(%s*)')do\\\
for e=1,math.ceil(#t/a)do\\\
local i=''\\\
if e==math.ceil(#t/a)then\\\
i=n\\\
end\\\
table.insert(o,{t:sub(1+a*(e-1),a*e),i})\\\
end\\\
end\\\
for o,t in ipairs(o)do\\\
local o=t[1]\\\
local t=t[2]\\\
local i=e[#e]..o..t:gsub('\\\\n','')\\\
if#i>a then\\\
table.insert(e,'')\\\
end\\\
if t:find('\\\\n')then\\\
e[#e]=e[#e]..o\\\
t=t:gsub('\\\\n',function()\\\
table.insert(e,'')\\\
return''\\\
end)\\\
else\\\
e[#e]=e[#e]..o..t\\\
end\\\
end\\\
return e\\\
end,\\\
CalculateCursorPos=function(e)\\\
local t=0\\\
Current.CursorPos=nil\\\
for h,a in ipairs(e.Pages)do\\\
a:Draw()\\\
if not Current.CursorPos then\\\
for i,n in ipairs(a.Lines)do\\\
local o=e.TextInput.CursorPos-FindColours(e.TextInput.Value:sub(1,e.TextInput.CursorPos))\\\
if t+#s(n.Text:gsub('\\\\n',''))>=o then\\\
Current.CursorPos={e.X+a.MarginX+(o-t),a.Y+1+i}\\\
e.CursorPos={Page=h,Line=i,Collum=o-t-FindColours(e.TextInput.Value:sub(1,e.TextInput.CursorPos-1))}\\\
break\\\
end\\\
t=t+#s(n.Text:gsub('\\\\n',''))\\\
end\\\
end\\\
end\\\
end,\\\
Draw=function(e)\\\
e:CalculatePages()\\\
e:CalculateCursorPos()\\\
e.ScrollBar:Draw()\\\
end,\\\
CalculatePages=function(e)\\\
e.Pages={}\\\
local o=e:CalculateLineWrapping()\\\
e.Lines=o\\\
local t={}\\\
local a=(3+e.PageSize.Height+2*Page.MarginY)\\\
for o,i in ipairs(o)do\\\
table.insert(t,TextLine:Initialise(i))\\\
if o%e.PageSize.Height==0 then\\\
table.insert(e.Pages,Page:Initialise(e,t,3-e.ScrollBar.Scroll+a*(#e.Pages)))\\\
t={}\\\
end\\\
end\\\
if#t~=0 then\\\
table.insert(e.Pages,Page:Initialise(e,t,3-e.ScrollBar.Scroll+a*(#e.Pages)))\\\
end\\\
e.ScrollBar.MaxScroll=a*(#e.Pages)-Drawing.Screen.Height+1\\\
end,\\\
ScrollToCursor=function(e)\\\
e:CalculateCursorPos()\\\
if Current.CursorPos and\\\
(Current.CursorPos[2]>Drawing.Screen.Height\\\
or Current.CursorPos[2]<2)then\\\
e.ScrollBar:DoScroll(Current.CursorPos[2]-Drawing.Screen.Height)\\\
end\\\
end,\\\
SetSelectionColour=function(e,t)\\\
local a=OrderSelection()\\\
local i=e.TextInput:Extract(true)\\\
local o=CharacterFromColour(t)\\\
local t=''\\\
if FindColours(e.TextInput.Value:sub(e.TextInput.CursorPos+1,e.TextInput.CursorPos+1))==0 then\\\
for a=1,e.TextInput.CursorPos do\\\
local e=e.TextInput.Value:sub(e.TextInput.CursorPos-a,e.TextInput.CursorPos-a)\\\
if FindColours(e)==1 then\\\
t=e\\\
break\\\
end\\\
end\\\
if t==''then\\\
t=CharacterFromColour(colours.black)\\\
end\\\
end\\\
e.TextInput:Insert(o..s(i)..t)\\\
end,\\\
Initialise=function(t,a,o,i)\\\
local e={}\\\
setmetatable(e,{__index=t})\\\
e.Title=o or'New Document'\\\
e.Path=i\\\
e.X=(Drawing.Screen.Width-(e.PageSize.Width+2*(Page.MarginX)))/2\\\
e.Y=2\\\
e.TextInput=TextInput:Initialise(a,function()\\\
e:ScrollToCursor()\\\
Current.Modified=true\\\
Draw()\\\
end,false,true)\\\
e.ScrollBar=ScrollBar:Initialise(Drawing.Screen.Width,e.Y,Drawing.Screen.Height-1,0,nil,nil,nil,function()end)\\\
Current.TextInput=e.TextInput\\\
Current.ScrollBar=e.ScrollBar\\\
return e\\\
end\\\
}\\\
ScrollBar={\\\
X=1,\\\
Y=1,\\\
Width=1,\\\
Height=1,\\\
BackgroundColour=colours.grey,\\\
BarColour=colours.lightBlue,\\\
Parent=nil,\\\
Change=nil,\\\
Scroll=0,\\\
MaxScroll=0,\\\
ClickPoint=nil,\\\
AbsolutePosition=function(e)\\\
return e.Parent:AbsolutePosition()\\\
end,\\\
Draw=function(e)\\\
local a=GetAbsolutePosition(e)\\\
local t=e.Height-e.MaxScroll\\\
if t<3 then\\\
t=3\\\
end\\\
local o=(e.Scroll/e.MaxScroll)\\\
Drawing.DrawBlankArea(a.X,a.Y,e.Width,e.Height,e.BackgroundColour)\\\
Drawing.DrawBlankArea(a.X,a.Y+h(e.Height*o-t*o),e.Width,t,e.BarColour)\\\
end,\\\
Initialise=function(d,h,r,s,n,o,i,a,t)\\\
local e={}\\\
setmetatable(e,{__index=d})\\\
e.Width=1\\\
e.Height=s\\\
e.Y=r\\\
e.X=h\\\
e.BackgroundColour=o or colours.grey\\\
e.BarColour=i or colours.lightBlue\\\
e.Parent=a\\\
e.Change=t or function()end\\\
e.MaxScroll=n\\\
e.Scroll=0\\\
return e\\\
end,\\\
DoScroll=function(e,t)\\\
t=h(t)\\\
if e.Scroll<0 or e.Scroll>e.MaxScroll then\\\
return false\\\
end\\\
e.Scroll=e.Scroll+t\\\
if e.Scroll<0 then\\\
e.Scroll=0\\\
elseif e.Scroll>e.MaxScroll then\\\
e.Scroll=e.MaxScroll\\\
end\\\
e.Change()\\\
return true\\\
end,\\\
Click=function(e,t,t,i,a)\\\
local o=(e.Scroll/e.MaxScroll)\\\
local t=(e.Height-e.MaxScroll)\\\
if t<3 then\\\
t=3\\\
end\\\
local t=(e.MaxScroll*(i+t*o)/e.Height)\\\
if not a then\\\
e.ClickPoint=e.Scroll-t+1\\\
end\\\
if e.Scroll-1~=t then\\\
e:DoScroll(t-e.Scroll-1+e.ClickPoint)\\\
end\\\
return true\\\
end\\\
}\\\
AlignmentLeft=1\\\
AlignmentCentre=2\\\
AlignmentRight=3\\\
TextLine={\\\
Text=\\\"\\\",\\\
Alignment=AlignmentLeft,\\\
Initialise=function(o,a,t)\\\
local e={}\\\
setmetatable(e,{__index=o})\\\
e.Text=a\\\
e.Alignment=t or AlignmentLeft\\\
return e\\\
end\\\
}\\\
local i=1\\\
Page={\\\
X=1,\\\
Y=1,\\\
Width=1,\\\
Height=1,\\\
MarginX=3,\\\
MarginY=2,\\\
BackgroundColour=colours.white,\\\
TextColour=colours.white,\\\
ActiveBackgroundColour=colours.lightGrey,\\\
Lines={},\\\
Parent=nil,\\\
AbsolutePosition=function(e)\\\
return e.Parent:AbsolutePosition()\\\
end,\\\
Draw=function(e)\\\
local t=GetAbsolutePosition(e)\\\
if t.Y>Drawing.Screen.Height or t.Y+e.Height<1 then\\\
return\\\
end\\\
Drawing.DrawBlankArea(t.X+e.Width,t.Y-1+1,1,e.Height,UIColours.Shadow)\\\
Drawing.DrawBlankArea(t.X+1,t.Y-1+e.Height,e.Width,1,UIColours.Shadow)\\\
Drawing.DrawBlankArea(t.X,t.Y-1,e.Width,e.Height,e.BackgroundColour)\\\
local s=e.TextColour\\\
if not Current.Selection then\\\
for h,o in ipairs(e.Lines)do\\\
local i=1\\\
for a=1,#o.Text do\\\
local n=ColourFromCharacter(o.Text:sub(a,a))\\\
if n then\\\
s=n\\\
else\\\
Drawing.WriteToBuffer(t.X+e.MarginX-1+i,t.Y-2+h+e.MarginY,o.Text:sub(a,a),s,e.BackgroundColour)\\\
i=i+1\\\
end\\\
end\\\
end\\\
else\\\
local h=OrderSelection()\\\
local o=1\\\
local s=e.TextColour\\\
for d,n in ipairs(e.Lines)do\\\
local i=1\\\
for a=1,#n.Text do\\\
local r=ColourFromCharacter(n.Text:sub(a,a))\\\
if r then\\\
s=r\\\
else\\\
local s=s\\\
local r=colours.white\\\
if o>=h[1]and o<=h[2]then\\\
r=colours.lightBlue\\\
s=colours.white\\\
end\\\
Drawing.WriteToBuffer(t.X+e.MarginX-1+i,t.Y-2+d+e.MarginY,n.Text:sub(a,a),s,r)\\\
i=i+1\\\
end\\\
o=o+1\\\
end\\\
end\\\
end\\\
end,\\\
Initialise=function(t,a,o,i)\\\
local e={}\\\
setmetatable(e,{__index=t})\\\
e.Height=a.PageSize.Height+2*t.MarginY\\\
e.Width=a.PageSize.Width+2*t.MarginX\\\
e.X=1\\\
e.Y=i or 1\\\
e.Lines=o or{}\\\
e.BackgroundColour=colours.white\\\
e.TextColour=colours.black\\\
e.Parent=a\\\
e.ClickPos=1\\\
return e\\\
end,\\\
GetCursorPosFromPoint=function(a,t,i,o)\\\
local e=GetAbsolutePosition(a)\\\
if o then\\\
e={Y=0,X=0}\\\
end\\\
local i=i-e.Y+a.MarginY-a.Parent.ScrollBar.Scroll\\\
local t=t-a.MarginX-e.X+1\\\
local e=0\\\
if i<=0 or t<=0 then\\\
return 0\\\
end\\\
if i>#a.Lines then\\\
for a,t in ipairs(a.Lines)do\\\
e=e+#t.Text\\\
end\\\
return e\\\
end\\\
local o=0\\\
for n,a in ipairs(a.Lines)do\\\
if n==i then\\\
if t>#a.Text then\\\
t=#a.Text\\\
else\\\
t=t+FindColours(a.Text:sub(1,t))\\\
end\\\
e=e+t+2-n-o\\\
break\\\
else\\\
o=FindColours(a.Text)\\\
if o~=0 then\\\
o=o\\\
end\\\
e=e+#a.Text+2-n+FindColours(a.Text)\\\
end\\\
end\\\
return e-2\\\
end,\\\
Click=function(e,n,t,a,o)\\\
local a=e:GetCursorPosFromPoint(t,a)\\\
e.Parent.TextInput.CursorPos=a\\\
if o==nil then\\\
Current.Selection=nil\\\
i=t\\\
else\\\
local a=a\\\
if not Current.Selection then\\\
local e=1\\\
if i and i<t then\\\
e=0\\\
end\\\
Current.Selection={a+e,a+1+e}\\\
else\\\
Current.Selection[2]=a+1\\\
end\\\
end\\\
Draw()\\\
return true\\\
end\\\
}\\\
function GetAbsolutePosition(e)\\\
local e=e\\\
local t=0\\\
local a=1\\\
local o=1\\\
while true do\\\
a=a+e.X-1\\\
o=o+e.Y-1\\\
if not e.Parent then\\\
return{X=a,Y=o}\\\
end\\\
e=e.Parent\\\
if t>32 then\\\
return{X=1,Y=1}\\\
end\\\
t=t+1\\\
end\\\
end\\\
function Draw()\\\
if not Current.Window then\\\
Drawing.Clear(colours.lightGrey)\\\
else\\\
Drawing.DrawArea(1,2,Drawing.Screen.Width,Drawing.Screen.Height,'|',colours.black,colours.lightGrey)\\\
end\\\
if Current.Document then\\\
Current.Document:Draw()\\\
end\\\
Current.MenuBar:Draw()\\\
if Current.Window then\\\
Current.Window:Draw()\\\
end\\\
if Current.Menu then\\\
Current.Menu:Draw()\\\
end\\\
Drawing.DrawBuffer()\\\
if Current.TextInput and Current.CursorPos and not Current.Menu and not(Current.Window and Current.Document and Current.TextInput==Current.Document.TextInput)and Current.CursorPos[2]>1 then\\\
term.setCursorPos(Current.CursorPos[1],Current.CursorPos[2])\\\
term.setCursorBlink(true)\\\
term.setTextColour(Current.CursorColour)\\\
else\\\
term.setCursorBlink(false)\\\
end\\\
end\\\
MainDraw=Draw\\\
LongestString=function(e,t)\\\
local a=0\\\
for o=1,#e do\\\
local e=e[o]\\\
if t then\\\
if e[t]then\\\
e=e[t]\\\
else\\\
e=''\\\
end\\\
end\\\
local e=string.len(e)\\\
if e>a then\\\
a=e\\\
end\\\
end\\\
return a\\\
end\\\
function LoadMenuBar()\\\
Current.MenuBar=MenuBar:Initialise({\\\
Button:Initialise(1,1,nil,nil,colours.grey,Current.MenuBar,function(t,a,a,a,e)\\\
if e then\\\
Menu:New(1,2,{\\\
{\\\
Title=\\\"New...\\\",\\\
Click=function()\\\
Current.Document=Document:Initialise('')\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.n\\\
}\\\
},\\\
{\\\
Title='Open...',\\\
Click=function()\\\
DisplayOpenDocumentWindow()\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.o\\\
}\\\
},\\\
{\\\
Separator=true\\\
},\\\
{\\\
Title='Save...',\\\
Click=function()\\\
SaveDocument()\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.s\\\
},\\\
Enabled=function()\\\
return true\\\
end\\\
},\\\
{\\\
Separator=true\\\
},\\\
{\\\
Title='Print...',\\\
Click=function()\\\
PrintDocument()\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.p\\\
},\\\
Enabled=function()\\\
return true\\\
end\\\
},\\\
{\\\
Separator=true\\\
},\\\
{\\\
Title='Quit',\\\
Click=function()\\\
Close()\\\
end\\\
},\\\
},t,true)\\\
else\\\
Current.Menu=nil\\\
end\\\
return true\\\
end,'File',colours.lightGrey,false),\\\
Button:Initialise(7,1,nil,nil,colours.grey,Current.MenuBar,function(t,e,e,e,e)\\\
if not t.Toggle then\\\
Menu:New(7,2,{\\\
{\\\
Title='Cut',\\\
Click=function()\\\
Clipboard.Cut(Current.Document.TextInput:Extract(true),'text')\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.x\\\
},\\\
Enabled=function()\\\
return Current.Document~=nil and Current.Selection and Current.Selection[1]and Current.Selection[2]~=nil\\\
end\\\
},\\\
{\\\
Title='Copy',\\\
Click=function()\\\
Clipboard.Copy(Current.Document.TextInput:Extract(),'text')\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.c\\\
},\\\
Enabled=function()\\\
return Current.Document~=nil and Current.Selection and Current.Selection[1]and Current.Selection[2]~=nil\\\
end\\\
},\\\
{\\\
Title='Paste',\\\
Click=function()\\\
local e=Clipboard.Paste()\\\
Current.Document.TextInput:Insert(e)\\\
Current.Document.TextInput.CursorPos=Current.Document.TextInput.CursorPos+#e-1\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.v\\\
},\\\
Enabled=function()\\\
return Current.Document~=nil and(not Clipboard.isEmpty())and Clipboard.Type=='text'\\\
end\\\
},\\\
{\\\
Separator=true,\\\
},\\\
{\\\
Title='Select All',\\\
Click=function()\\\
Current.Selection={1,#Current.Document.TextInput.Value:gsub('\\\\n','')}\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.a\\\
},\\\
Enabled=function()\\\
return Current.Document~=nil\\\
end\\\
}\\\
},t,true)\\\
else\\\
Current.Menu=nil\\\
end\\\
return true\\\
end,'Edit',colours.lightGrey,false)\\\
})\\\
end\\\
function LoadMenuBar()\\\
Current.MenuBar=MenuBar:Initialise({\\\
Button:Initialise(1,1,nil,nil,colours.grey,Current.MenuBar,function(t,a,a,a,e)\\\
if e then\\\
Menu:New(1,2,{\\\
{\\\
Title=\\\"New...\\\",\\\
Click=function()\\\
Current.Document=Document:Initialise('')\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.n\\\
}\\\
},\\\
{\\\
Title='Open...',\\\
Click=function()\\\
DisplayOpenDocumentWindow()\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.o\\\
}\\\
},\\\
{\\\
Separator=true\\\
},\\\
{\\\
Title='Save...',\\\
Click=function()\\\
SaveDocument()\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.s\\\
},\\\
Enabled=function()\\\
return Current.Document~=nil\\\
end\\\
},\\\
{\\\
Separator=true\\\
},\\\
{\\\
Title='Print...',\\\
Click=function()\\\
PrintDocument()\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.p\\\
},\\\
Enabled=function()\\\
return true\\\
end\\\
},\\\
{\\\
Separator=true\\\
},\\\
{\\\
Title='Quit',\\\
Click=function()\\\
if Close()and OneOS then\\\
OneOS.Close()\\\
end\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.q\\\
}\\\
},\\\
},t,true)\\\
else\\\
Current.Menu=nil\\\
end\\\
return true\\\
end,'File',colours.lightGrey,false),\\\
Button:Initialise(7,1,nil,nil,colours.grey,Current.MenuBar,function(e,t,t,t,t)\\\
if not e.Toggle then\\\
Menu:New(7,2,{\\\
{\\\
Title='Cut',\\\
Click=function()\\\
Clipboard.Cut(Current.Document.TextInput:Extract(true),'text')\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.x\\\
},\\\
Enabled=function()\\\
return Current.Document~=nil and Current.Selection and Current.Selection[1]and Current.Selection[2]~=nil\\\
end\\\
},\\\
{\\\
Title='Copy',\\\
Click=function()\\\
Clipboard.Copy(Current.Document.TextInput:Extract(),'text')\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.c\\\
},\\\
Enabled=function()\\\
return Current.Document~=nil and Current.Selection and Current.Selection[1]and Current.Selection[2]~=nil\\\
end\\\
},\\\
{\\\
Title='Paste',\\\
Click=function()\\\
local e=Clipboard.Paste()\\\
Current.Document.TextInput:Insert(e)\\\
Current.Document.TextInput.CursorPos=Current.Document.TextInput.CursorPos+#e-1\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.v\\\
},\\\
Enabled=function()\\\
return Current.Document~=nil and(not Clipboard.isEmpty())and Clipboard.Type=='text'\\\
end\\\
},\\\
{\\\
Separator=true,\\\
},\\\
{\\\
Title='Select All',\\\
Click=function()\\\
Current.Selection={1,#Current.Document.TextInput.Value:gsub('\\\\n','')}\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.a\\\
},\\\
Enabled=function()\\\
return Current.Document~=nil\\\
end\\\
}\\\
},e,true)\\\
else\\\
Current.Menu=nil\\\
end\\\
return true\\\
end,'Edit',colours.lightGrey,false),\\\
Button:Initialise(13,1,nil,nil,colours.grey,Current.MenuBar,function(e,t,t,t,t)\\\
if not e.Toggle then\\\
Menu:New(13,2,{\\\
{\\\
Title='Red',\\\
Click=function(e)\\\
Current.Document:SetSelectionColour(e.Colour)\\\
end,\\\
Colour=colours.red,\\\
Enabled=function()\\\
return(Current.Document~=nil and Current.Selection~=nil and Current.Selection[1]~=nil and Current.Selection[2]~=nil)\\\
end\\\
},\\\
{\\\
Title='Orange',\\\
Click=function(e)\\\
Current.Document:SetSelectionColour(e.Colour)\\\
end,\\\
Colour=colours.orange,\\\
Enabled=function()\\\
return(Current.Document~=nil and Current.Selection~=nil and Current.Selection[1]~=nil and Current.Selection[2]~=nil)\\\
end\\\
},\\\
{\\\
Title='Yellow',\\\
Click=function(e)\\\
Current.Document:SetSelectionColour(e.Colour)\\\
end,\\\
Colour=colours.yellow,\\\
Enabled=function()\\\
return(Current.Document~=nil and Current.Selection~=nil and Current.Selection[1]~=nil and Current.Selection[2]~=nil)\\\
end\\\
},\\\
{\\\
Title='Pink',\\\
Click=function(e)\\\
Current.Document:SetSelectionColour(e.Colour)\\\
end,\\\
Colour=colours.pink,\\\
Enabled=function()\\\
return(Current.Document~=nil and Current.Selection~=nil and Current.Selection[1]~=nil and Current.Selection[2]~=nil)\\\
end\\\
},\\\
{\\\
Title='Magenta',\\\
Click=function(e)\\\
Current.Document:SetSelectionColour(e.Colour)\\\
end,\\\
Colour=colours.magenta,\\\
Enabled=function()\\\
return(Current.Document~=nil and Current.Selection~=nil and Current.Selection[1]~=nil and Current.Selection[2]~=nil)\\\
end\\\
},\\\
{\\\
Title='Purple',\\\
Click=function(e)\\\
Current.Document:SetSelectionColour(e.Colour)\\\
end,\\\
Colour=colours.purple,\\\
Enabled=function()\\\
return(Current.Document~=nil and Current.Selection~=nil and Current.Selection[1]~=nil and Current.Selection[2]~=nil)\\\
end\\\
},\\\
{\\\
Title='Light Blue',\\\
Click=function(e)\\\
Current.Document:SetSelectionColour(e.Colour)\\\
end,\\\
Colour=colours.lightBlue,\\\
Enabled=function()\\\
return(Current.Document~=nil and Current.Selection~=nil and Current.Selection[1]~=nil and Current.Selection[2]~=nil)\\\
end\\\
},\\\
{\\\
Title='Cyan',\\\
Click=function(e)\\\
Current.Document:SetSelectionColour(e.Colour)\\\
end,\\\
Colour=colours.cyan,\\\
Enabled=function()\\\
return(Current.Document~=nil and Current.Selection~=nil and Current.Selection[1]~=nil and Current.Selection[2]~=nil)\\\
end\\\
},\\\
{\\\
Title='Blue',\\\
Click=function(e)\\\
Current.Document:SetSelectionColour(e.Colour)\\\
end,\\\
Colour=colours.blue,\\\
Enabled=function()\\\
return(Current.Document~=nil and Current.Selection~=nil and Current.Selection[1]~=nil and Current.Selection[2]~=nil)\\\
end\\\
},\\\
{\\\
Title='Green',\\\
Click=function(e)\\\
Current.Document:SetSelectionColour(e.Colour)\\\
end,\\\
Colour=colours.green,\\\
Enabled=function()\\\
return(Current.Document~=nil and Current.Selection~=nil and Current.Selection[1]~=nil and Current.Selection[2]~=nil)\\\
end\\\
},\\\
{\\\
Title='Light Grey',\\\
Click=function(e)\\\
Current.Document:SetSelectionColour(e.Colour)\\\
end,\\\
Colour=colours.lightGrey,\\\
Enabled=function()\\\
return(Current.Document~=nil and Current.Selection~=nil and Current.Selection[1]~=nil and Current.Selection[2]~=nil)\\\
end\\\
},\\\
{\\\
Title='Grey',\\\
Click=function(e)\\\
Current.Document:SetSelectionColour(e.Colour)\\\
end,\\\
Colour=colours.grey,\\\
Enabled=function()\\\
return(Current.Document~=nil and Current.Selection~=nil and Current.Selection[1]~=nil and Current.Selection[2]~=nil)\\\
end\\\
},\\\
{\\\
Title='Black',\\\
Click=function(e)\\\
Current.Document:SetSelectionColour(e.Colour)\\\
end,\\\
Colour=colours.black,\\\
Enabled=function()\\\
return(Current.Document~=nil and Current.Selection~=nil and Current.Selection[1]~=nil and Current.Selection[2]~=nil)\\\
end\\\
},\\\
{\\\
Title='Brown',\\\
Click=function(e)\\\
Current.Document:SetSelectionColour(e.Colour)\\\
end,\\\
Colour=colours.brown,\\\
Enabled=function()\\\
return(Current.Document~=nil and Current.Selection~=nil and Current.Selection[1]~=nil and Current.Selection[2]~=nil)\\\
end\\\
}\\\
},e,true)\\\
else\\\
Current.Menu=nil\\\
end\\\
return true\\\
end,'Colour',colours.lightGrey,false)\\\
})\\\
end\\\
function SplashScreen()\\\
local e=colours.white\\\
local a=colours.black\\\
local t=colours.blue\\\
local o=colours.lightBlue\\\
local e={{e,e,e,a,e,e,e,a,e,e,e,},{e,e,e,a,e,e,e,a,e,e,e,},{e,e,e,a,t,t,t,a,e,e,e,},{e,a,a,t,t,t,t,t,a,a,e,},{a,t,t,o,o,t,t,t,t,t,a,},{a,t,o,o,t,t,t,t,t,t,a,},{a,t,o,o,t,t,t,t,t,t,a,},{a,t,t,t,t,t,t,t,t,t,a,},{e,a,a,a,a,a,a,a,a,a,e,},\\\
[\\\"text\\\"]={{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\"I\\\",\\\"n\\\",\\\"k\\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},{\\\" \\\",\\\" \\\",\\\"b\\\",\\\"y\\\",\\\" \\\",\\\"o\\\",\\\"e\\\",\\\"e\\\",\\\"d\\\",\\\" \\\",\\\" \\\"},{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},},\\\
[\\\"textcol\\\"]={{e,e,e,e,e,e,e,e,e,e,e,},{e,e,e,e,e,e,e,e,e,e,e,},{e,e,e,e,e,e,e,e,e,e,e,},{e,e,e,e,e,e,e,e,e,e,e,},{e,e,e,e,e,e,e,e,e,e,e,},{e,e,e,e,e,e,e,e,e,e,e,},{e,e,e,e,e,e,e,e,e,e,e,},{o,o,o,o,o,o,o,o,o,o,o,},{e,e,e,e,e,e,e,e,e,e,e,},},}\\\
Drawing.Clear(colours.white)\\\
Drawing.DrawImage((Drawing.Screen.Width-11)/2,(Drawing.Screen.Height-9)/2,e,11,9)\\\
Drawing.DrawBuffer()\\\
Drawing.Clear(colours.black)\\\
parallel.waitForAny(function()sleep(1)end,function()os.pullEvent('mouse_click')end)\\\
end\\\
function Initialise(e)\\\
if OneOS then\\\
fs=OneOS.FS\\\
end\\\
if not OneOS then\\\
SplashScreen()\\\
end\\\
EventRegister('mouse_click',TryClick)\\\
EventRegister('mouse_drag',function(a,o,t,e)TryClick(a,o,t,e,true)end)\\\
EventRegister('mouse_scroll',Scroll)\\\
EventRegister('key',HandleKey)\\\
EventRegister('char',HandleKey)\\\
EventRegister('timer',Timer)\\\
EventRegister('terminate',function(e)if Close()then error(\\\"Terminated\\\",0)end end)\\\
LoadMenuBar()\\\
if tArgs[1]then\\\
if fs.exists(tArgs[1])then\\\
OpenDocument(tArgs[1])\\\
else\\\
end\\\
else\\\
Current.Document=Document:Initialise('')\\\
end\\\
Draw()\\\
EventHandler()\\\
end\\\
local t=false\\\
controlPushedTimer=nil\\\
closeWindowTimer=nil\\\
function Timer(a,e)\\\
if e==closeWindowTimer then\\\
if Current.Window then\\\
Current.Window:Close()\\\
end\\\
Draw()\\\
elseif e==controlPushedTimer then\\\
t=false\\\
end\\\
end\\\
local o=false\\\
function HandleKey(...)\\\
local e={...}\\\
local a=e[1]\\\
local e=e[2]\\\
if a=='key'and e==keys.leftCtrl or e==keys.rightCtrl or e==219 then\\\
t=true\\\
controlPushedTimer=os.startTimer(.5)\\\
elseif t then\\\
if a=='key'then\\\
if CheckKeyboardShortcut(e)then\\\
t=false\\\
o=true\\\
end\\\
end\\\
elseif o then\\\
o=false\\\
elseif Current.TextInput then\\\
if a=='char'then\\\
Current.TextInput:Char(e)\\\
elseif a=='key'then\\\
Current.TextInput:Key(e)\\\
end\\\
end\\\
end\\\
function CheckKeyboardShortcut(t)\\\
local e={}\\\
e[keys.n]=function()Current.Document=Document:Initialise('')end\\\
e[keys.o]=function()DisplayOpenDocumentWindow()end\\\
e[keys.s]=function()if Current.Document~=nil then SaveDocument()end end\\\
e[keys.left]=function()if Current.TextInput then Current.TextInput:Key(keys.home)end end\\\
e[keys.right]=function()if Current.TextInput then Current.TextInput:Key(keys[\\\"end\\\"])end end\\\
if Current.Document~=nil then\\\
e[keys.s]=function()SaveDocument()end\\\
e[keys.p]=function()PrintDocument()end\\\
if Current.Selection and Current.Selection[1]and Current.Selection[2]~=nil then\\\
e[keys.x]=function()Clipboard.Cut(Current.Document.TextInput:Extract(true),'text')end\\\
e[keys.c]=function()Clipboard.Copy(Current.Document.TextInput:Extract(),'text')end\\\
end\\\
if(not Clipboard.isEmpty())and Clipboard.Type=='text'then\\\
e[keys.v]=function()local e=Clipboard.Paste()\\\
Current.Document.TextInput:Insert(e)\\\
Current.Document.TextInput.CursorPos=Current.Document.TextInput.CursorPos+#e-1\\\
end\\\
end\\\
e[keys.a]=function()Current.Selection={1,#Current.Document.TextInput.Value:gsub('\\\\n','')}end\\\
end\\\
if e[t]then\\\
e[t]()\\\
Draw()\\\
return true\\\
else\\\
return false\\\
end\\\
end\\\
function CheckClick(e,a,t)\\\
if e.X<=a and e.Y<=t and e.X+e.Width>a and e.Y+e.Height>t then\\\
return true\\\
end\\\
end\\\
function DoClick(e,n,a,o,i)\\\
local t=GetAbsolutePosition(e)\\\
t.Width=e.Width\\\
t.Height=e.Height\\\
if e and CheckClick(t,a,o)then\\\
return e:Click(n,a-e.X+1,o-e.Y+1,i)\\\
end\\\
end\\\
function TryClick(e,t,i,a,o)\\\
if Current.Menu then\\\
if DoClick(Current.Menu,t,i,a,o)then\\\
Draw()\\\
return\\\
else\\\
if Current.Menu.Owner and Current.Menu.Owner.Toggle then\\\
Current.Menu.Owner.Toggle=false\\\
end\\\
Current.Menu=nil\\\
Draw()\\\
return\\\
end\\\
elseif Current.Window then\\\
if DoClick(Current.Window,t,i,a,o)then\\\
Draw()\\\
return\\\
else\\\
Current.Window:Flash()\\\
return\\\
end\\\
end\\\
local e={}\\\
table.insert(e,Current.MenuBar)\\\
table.insert(e,Current.ScrollBar)\\\
for a,t in ipairs(Current.Document.Pages)do\\\
table.insert(e,t)\\\
end\\\
for n,e in ipairs(e)do\\\
if DoClick(e,t,i,a,o)then\\\
Draw()\\\
return\\\
end\\\
end\\\
Draw()\\\
end\\\
function Scroll(t,e,t,t)\\\
if Current.Window and Current.Window.OpenButton then\\\
Current.Document.Scroll=Current.Document.Scroll+e\\\
if Current.Window.Scroll<0 then\\\
Current.Window.Scroll=0\\\
elseif Current.Window.Scroll>Current.Window.MaxScroll then\\\
Current.Window.Scroll=Current.Window.MaxScroll\\\
end\\\
Draw()\\\
elseif Current.ScrollBar then\\\
if Current.ScrollBar:DoScroll(e*2)then\\\
Draw()\\\
end\\\
end\\\
end\\\
function EventRegister(e,t)\\\
if not Events[e]then\\\
Events[e]={}\\\
end\\\
table.insert(Events[e],t)\\\
end\\\
function EventHandler()\\\
while true do\\\
local e,a,t,n,i=os.pullEventRaw()\\\
if Events[e]then\\\
for s,o in ipairs(Events[e])do\\\
o(e,a,t,n,i)\\\
end\\\
end\\\
end\\\
end\\\
local function o(e,t)\\\
if not e then\\\
return nil\\\
elseif not string.find(fs.getName(e),'%.')then\\\
if not t then\\\
return fs.getName(e)\\\
else\\\
return''\\\
end\\\
else\\\
local a=e\\\
if e:sub(#e)=='/'then\\\
a=e:sub(1,#e-1)\\\
end\\\
local e=a:gmatch('%.[0-9a-z]+$')()\\\
if e then\\\
e=e:sub(2)\\\
else\\\
return''\\\
end\\\
if t then\\\
e='.'..e\\\
end\\\
return e:lower()\\\
end\\\
end\\\
local o=function(e)\\\
if e:sub(1,1)=='.'then\\\
return e\\\
end\\\
local t=o(e)\\\
if t==e then\\\
return fs.getName(e)\\\
end\\\
return string.gsub(e,t,''):sub(1,-2)\\\
end\\\
local t=false\\\
function PrintDocument()\\\
if OneOS then\\\
OneOS.LoadAPI('/System/API/Helpers.lua')\\\
OneOS.LoadAPI('/System/API/Peripheral.lua')\\\
OneOS.LoadAPI('/System/API/Printer.lua')\\\
end\\\
local e=function()\\\
local e=PrintDocumentWindow:Initialise():Show()\\\
end\\\
if Peripheral.GetPeripheral('printer')==nil then\\\
ButtonDialougeWindow:Initialise('No Printer Found','Please place a printer next to your computer. Ensure you also insert dye (left slot) and paper (top slots)','Ok',nil,function(e,t)\\\
e:Close()\\\
end):Show()\\\
elseif not t and FindColours(Current.Document.TextInput.Value)~=0 then\\\
ButtonDialougeWindow:Initialise('Important','Due to the way printers work, you can\\\\'t print in more than one colour. The dye you use will be the colour of the text.','Ok',nil,function(a,o)\\\
t=true\\\
a:Close()\\\
e()\\\
end):Show()\\\
else\\\
e()\\\
end\\\
end\\\
function SaveDocument()\\\
local function a()\\\
local e=fs.open(Current.Document.Path,'w')\\\
if e then\\\
if Current.Document.Format==TextFormatPlainText then\\\
e.write(Current.Document.TextInput.Value)\\\
else\\\
local t={}\\\
for o,a in ipairs(Current.Document.Pages)do\\\
for a,e in ipairs(a.Lines)do\\\
table.insert(t,e)\\\
end\\\
end\\\
e.write(textutils.serialize(t))\\\
end\\\
Current.Modified=false\\\
else\\\
ButtonDialougeWindow:Initialise('Error','An error occured while saving the file, try again.','Ok',nil,function(e,t)\\\
e:Close()\\\
end):Show()\\\
end\\\
e.close()\\\
end\\\
if not Current.Document.Path then\\\
SaveDocumentWindow:Initialise(function(o,t,e)\\\
o:Close()\\\
if t then\\\
local t=''\\\
if Current.Document.Format==TextFormatPlainText then\\\
t='.txt'\\\
elseif Current.Document.Format==TextFormatInkText then\\\
t='.ink'\\\
end\\\
if e:sub(-4)~=t then\\\
e=e..t\\\
end\\\
Current.Document.Path=e\\\
Current.Document.Title=fs.getName(e)\\\
a()\\\
end\\\
if Current.Document then\\\
Current.TextInput=Current.Document.TextInput\\\
end\\\
end):Show()\\\
else\\\
a()\\\
end\\\
end\\\
function DisplayOpenDocumentWindow()\\\
OpenDocumentWindow:Initialise(function(a,t,e)\\\
a:Close()\\\
if t then\\\
OpenDocument(e)\\\
end\\\
end):Show()\\\
end\\\
function OpenDocument(e)\\\
Current.Selection=nil\\\
local t=fs.open(e,'r')\\\
if t then\\\
Current.Document=Document:Initialise(t.readAll(),o(fs.getName(e)),e)\\\
else\\\
ButtonDialougeWindow:Initialise('Error','An error occured while opening the file, try again.','Ok',nil,function(e,t)\\\
e:Close()\\\
if Current.Document then\\\
Current.TextInput=Current.Document.TextInput\\\
end\\\
end):Show()\\\
end\\\
t.close()\\\
end\\\
local a=function(e)\\\
e='/'..e\\\
local t=fs\\\
if OneOS then\\\
t=OneOS.FS\\\
end\\\
if t.isDir(e)then\\\
e=e..'/'\\\
end\\\
e,n=e:gsub(\\\"//\\\",\\\"/\\\")\\\
while n>0 do\\\
e,n=e:gsub(\\\"//\\\",\\\"/\\\")\\\
end\\\
return e\\\
end\\\
OpenDocumentWindow={\\\
X=1,\\\
Y=1,\\\
Width=0,\\\
Height=0,\\\
CursorPos=1,\\\
Visible=true,\\\
Return=nil,\\\
OpenButton=nil,\\\
PathTextBox=nil,\\\
CurrentDirectory='/',\\\
Scroll=0,\\\
MaxScroll=0,\\\
GoUpButton=nil,\\\
SelectedFile='',\\\
Files={},\\\
Typed=false,\\\
AbsolutePosition=function(e)\\\
return{X=e.X,Y=e.Y}\\\
end,\\\
Draw=function(e)\\\
if not e.Visible then\\\
return\\\
end\\\
Drawing.DrawBlankArea(e.X+1,e.Y+1,e.Width,e.Height,colours.grey)\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,3,colours.lightGrey)\\\
Drawing.DrawBlankArea(e.X,e.Y+1,e.Width,e.Height-6,colours.white)\\\
Drawing.DrawCharactersCenter(e.X,e.Y,e.Width,1,e.Title,colours.black,colours.lightGrey)\\\
Drawing.DrawBlankArea(e.X,e.Y+e.Height-5,e.Width,5,colours.lightGrey)\\\
e:DrawFiles()\\\
if(fs.exists(e.PathTextBox.TextInput.Value))or(e.SelectedFile and#e.SelectedFile>0 and fs.exists(e.CurrentDirectory..e.SelectedFile))then\\\
e.OpenButton.TextColour=colours.black\\\
else\\\
e.OpenButton.TextColour=colours.lightGrey\\\
end\\\
e.PathTextBox:Draw()\\\
e.OpenButton:Draw()\\\
e.CancelButton:Draw()\\\
e.GoUpButton:Draw()\\\
end,\\\
DrawFiles=function(e)\\\
for a,t in ipairs(e.Files)do\\\
if a>e.Scroll and a-e.Scroll<=11 then\\\
if t==e.SelectedFile then\\\
Drawing.DrawCharacters(e.X+1,e.Y+a-e.Scroll,t,colours.white,colours.lightBlue)\\\
elseif string.find(t,'%.txt')or string.find(t,'%.text')or string.find(t,'%.ink')or fs.isDir(e.CurrentDirectory..t)then\\\
Drawing.DrawCharacters(e.X+1,e.Y+a-e.Scroll,t,colours.black,colours.white)\\\
else\\\
Drawing.DrawCharacters(e.X+1,e.Y+a-e.Scroll,t,colours.grey,colours.white)\\\
end\\\
end\\\
end\\\
e.MaxScroll=#e.Files-11\\\
if e.MaxScroll<0 then\\\
e.MaxScroll=0\\\
end\\\
end,\\\
Initialise=function(o,t)\\\
local e={}\\\
setmetatable(e,{__index=o})\\\
e.Width=32\\\
e.Height=17\\\
e.Return=t\\\
e.X=math.ceil((Drawing.Screen.Width-e.Width)/2)\\\
e.Y=math.ceil((Drawing.Screen.Height-e.Height)/2)\\\
e.Title='Open Document'\\\
e.Visible=true\\\
e.CurrentDirectory='/'\\\
e.SelectedFile=nil\\\
if OneOS and fs.exists('/Desktop/Documents/')then\\\
e.CurrentDirectory='/Desktop/Documents/'\\\
end\\\
e.OpenButton=Button:Initialise(e.Width-6,e.Height-1,nil,nil,colours.white,e,function(o,i,i,i,i)\\\
if fs.exists(e.PathTextBox.TextInput.Value)and o.TextColour==colours.black and not fs.isDir(e.PathTextBox.TextInput.Value)then\\\
t(e,true,a(e.PathTextBox.TextInput.Value))\\\
elseif e.SelectedFile and o.TextColour==colours.black and fs.isDir(e.CurrentDirectory..e.SelectedFile)then\\\
e:GoToDirectory(e.CurrentDirectory..e.SelectedFile)\\\
elseif e.SelectedFile and o.TextColour==colours.black then\\\
t(e,true,a(e.CurrentDirectory..'/'..e.SelectedFile))\\\
end\\\
end,'Open',colours.black)\\\
e.CancelButton=Button:Initialise(e.Width-15,e.Height-1,nil,nil,colours.white,e,function(a,a,a,a,a)\\\
t(e,false)\\\
end,'Cancel',colours.black)\\\
e.GoUpButton=Button:Initialise(2,e.Height-1,nil,nil,colours.white,e,function(t,t,t,t,t)\\\
local t=fs.getName(e.CurrentDirectory)\\\
local t=e.CurrentDirectory:sub(1,#e.CurrentDirectory-#t-1)\\\
e:GoToDirectory(t)\\\
end,'Go Up',colours.black)\\\
e.PathTextBox=TextBox:Initialise(2,e.Height-3,e.Width-2,1,e,e.CurrentDirectory,colours.white,colours.black)\\\
e:GoToDirectory(e.CurrentDirectory)\\\
return e\\\
end,\\\
Show=function(e)\\\
Current.Window=e\\\
return e\\\
end,\\\
Close=function(e)\\\
Current.Input=nil\\\
Current.Window=nil\\\
e=nil\\\
end,\\\
GoToDirectory=function(e,t)\\\
t=a(t)\\\
e.CurrentDirectory=t\\\
e.Scroll=0\\\
e.SelectedFile=nil\\\
e.Typed=false\\\
e.PathTextBox.TextInput.Value=t\\\
local t=fs\\\
if OneOS then\\\
t=OneOS.FS\\\
end\\\
e.Files=t.list(e.CurrentDirectory)\\\
Draw()\\\
end,\\\
Flash=function(e)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
sleep(.15)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
end,\\\
Click=function(e,s,i,t)\\\
local n={e.OpenButton,e.CancelButton,e.PathTextBox,e.GoUpButton}\\\
local o=false\\\
for a,e in ipairs(n)do\\\
if CheckClick(e,i,t)then\\\
e:Click(s,i,t)\\\
o=true\\\
end\\\
end\\\
if not o then\\\
if t<=12 then\\\
local o=fs\\\
if OneOS then\\\
o=OneOS.FS\\\
end\\\
e.SelectedFile=o.list(e.CurrentDirectory)[t-1]\\\
e.PathTextBox.TextInput.Value=a(e.CurrentDirectory..'/'..e.SelectedFile)\\\
Draw()\\\
end\\\
end\\\
return true\\\
end\\\
}\\\
PrintDocumentWindow={\\\
X=1,\\\
Y=1,\\\
Width=0,\\\
Height=0,\\\
CursorPos=1,\\\
Visible=true,\\\
Return=nil,\\\
PrintButton=nil,\\\
CopiesTextBox=nil,\\\
Scroll=0,\\\
MaxScroll=0,\\\
PrinterSelectButton=nil,\\\
Title='',\\\
Status=0,\\\
StatusText='',\\\
SelectedPrinter=nil,\\\
AbsolutePosition=function(e)\\\
return{X=e.X,Y=e.Y}\\\
end,\\\
Draw=function(e)\\\
if not e.Visible then\\\
return\\\
end\\\
Drawing.DrawBlankArea(e.X+1,e.Y+1,e.Width,e.Height,colours.grey)\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,1,colours.lightGrey)\\\
Drawing.DrawBlankArea(e.X,e.Y+1,e.Width,e.Height-1,colours.white)\\\
Drawing.DrawCharactersCenter(e.X,e.Y,e.Width,1,e.Title,colours.black,colours.lightGrey)\\\
e.PrinterSelectButton:Draw()\\\
Drawing.DrawCharactersCenter(e.X,e.Y+e.PrinterSelectButton.Y-2,e.Width,1,'Printer',colours.black,colours.white)\\\
Drawing.DrawCharacters(e.X+e.Width-3,e.Y+e.PrinterSelectButton.Y-1,'\\\\\\\\/',colours.black,colours.lightGrey)\\\
Drawing.DrawCharacters(e.X+1,e.Y+e.CopiesTextBox.Y-1,'Copies',colours.black,colours.white)\\\
local t=colours.grey\\\
if e.Status==-1 then\\\
t=colours.red\\\
elseif e.Status==1 then\\\
t=colours.green\\\
end\\\
Drawing.DrawCharacters(e.X+1,e.Y+e.CopiesTextBox.Y+1,e.StatusText,t,colours.white)\\\
e.CopiesTextBox:Draw()\\\
e.PrintButton:Draw()\\\
e.CancelButton:Draw()\\\
end,\\\
Initialise=function(t)\\\
local e={}\\\
setmetatable(e,{__index=t})\\\
e.Width=32\\\
e.Height=11\\\
e.Return=returnFunc\\\
e.X=math.ceil((Drawing.Screen.Width-e.Width)/2)\\\
e.Y=math.ceil((Drawing.Screen.Height-e.Height)/2)\\\
e.Title='Print Document'\\\
e.Visible=true\\\
e.PrintButton=Button:Initialise(e.Width-7,e.Height-1,nil,nil,colours.lightGrey,e,function(t,t,t,t,t)\\\
local a=true\\\
if e.SelectedPrinter==nil then\\\
local t=Peripheral.GetPeripheral('printer')\\\
if t then\\\
e.SelectedPrinter=t.Side\\\
e.PrinterSelectButton.Text=t.Fullname\\\
else\\\
e.StatusText='No Connected Printer'\\\
e.Status=-1\\\
a=false\\\
end\\\
end\\\
if a then\\\
local t=Printer:Initialise(e.SelectedPrinter)\\\
local t=t:PrintLines(Current.Document.Lines,Current.Document.Title,tonumber(e.CopiesTextBox.TextInput.Value))\\\
if not t then\\\
e.StatusText='Document Printed!'\\\
e.Status=1\\\
closeWindowTimer=os.startTimer(1)\\\
else\\\
e.StatusText=t\\\
e.Status=-1\\\
end\\\
end\\\
end,'Print',colours.black)\\\
e.CancelButton=Button:Initialise(e.Width-15,e.Height-1,nil,nil,colours.lightGrey,e,function(t,t,t,t,t)\\\
e:Close()\\\
Draw()\\\
end,'Close',colours.black)\\\
e.PrinterSelectButton=Button:Initialise(2,4,e.Width-2,nil,colours.lightGrey,e,function(o,t,n,i,t)\\\
local a={\\\
{\\\
Title=\\\"Automatic\\\",\\\
Click=function()\\\
e.SelectedPrinter=nil\\\
e.PrinterSelectButton.Text='Automatic'\\\
end\\\
},\\\
{\\\
Separator=true\\\
}\\\
}\\\
for o,t in ipairs(Peripheral.GetPeripherals('printer'))do\\\
table.insert(a,{\\\
Title=t.Fullname,\\\
Click=function(a)\\\
e.SelectedPrinter=t.Side\\\
e.PrinterSelectButton.Text=t.Fullname\\\
end\\\
})\\\
end\\\
Current.Menu=Menu:New(n,i+4,a,o,true)\\\
end,'Automatic',colours.black)\\\
e.CopiesTextBox=TextBox:Initialise(9,6,4,1,e,1,colours.lightGrey,colours.black,nil,true)\\\
Current.TextInput=e.CopiesTextBox.TextInput\\\
e.StatusText='Waiting...'\\\
e.Status=0\\\
return e\\\
end,\\\
Show=function(e)\\\
Current.Window=e\\\
return e\\\
end,\\\
Close=function(e)\\\
Current.Input=nil\\\
Current.Window=nil\\\
e=nil\\\
end,\\\
Flash=function(e)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
sleep(.15)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
end,\\\
Click=function(e,o,t,a)\\\
local e={e.PrintButton,e.CancelButton,e.CopiesTextBox,e.PrinterSelectButton}\\\
for i,e in ipairs(e)do\\\
if CheckClick(e,t,a)then\\\
e:Click(o,t,a)\\\
end\\\
end\\\
return true\\\
end\\\
}\\\
SaveDocumentWindow={\\\
X=1,\\\
Y=1,\\\
Width=0,\\\
Height=0,\\\
CursorPos=1,\\\
Visible=true,\\\
Return=nil,\\\
SaveButton=nil,\\\
PathTextBox=nil,\\\
CurrentDirectory='/',\\\
Scroll=0,\\\
MaxScroll=0,\\\
ScrollBar=nil,\\\
GoUpButton=nil,\\\
Files={},\\\
Typed=false,\\\
AbsolutePosition=function(e)\\\
return{X=e.X,Y=e.Y}\\\
end,\\\
Draw=function(e)\\\
if not e.Visible then\\\
return\\\
end\\\
Drawing.DrawBlankArea(e.X+1,e.Y+1,e.Width,e.Height,colours.grey)\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,3,colours.lightGrey)\\\
Drawing.DrawBlankArea(e.X,e.Y+1,e.Width,e.Height-6,colours.white)\\\
Drawing.DrawCharactersCenter(e.X,e.Y,e.Width,1,e.Title,colours.black,colours.lightGrey)\\\
Drawing.DrawBlankArea(e.X,e.Y+e.Height-5,e.Width,5,colours.lightGrey)\\\
Drawing.DrawCharacters(e.X+1,e.Y+e.Height-5,e.CurrentDirectory,colours.grey,colours.lightGrey)\\\
e:DrawFiles()\\\
if(e.PathTextBox.TextInput.Value)then\\\
e.SaveButton.TextColour=colours.black\\\
else\\\
e.SaveButton.TextColour=colours.lightGrey\\\
end\\\
e.PathTextBox:Draw()\\\
e.SaveButton:Draw()\\\
e.CancelButton:Draw()\\\
e.GoUpButton:Draw()\\\
end,\\\
DrawFiles=function(e)\\\
for t,a in ipairs(e.Files)do\\\
if t>e.Scroll and t-e.Scroll<=10 then\\\
if a==e.SelectedFile then\\\
Drawing.DrawCharacters(e.X+1,e.Y+t-e.Scroll,a,colours.white,colours.lightBlue)\\\
elseif fs.isDir(e.CurrentDirectory..a)then\\\
Drawing.DrawCharacters(e.X+1,e.Y+t-e.Scroll,a,colours.black,colours.white)\\\
else\\\
Drawing.DrawCharacters(e.X+1,e.Y+t-e.Scroll,a,colours.lightGrey,colours.white)\\\
end\\\
end\\\
end\\\
e.MaxScroll=#e.Files-11\\\
if e.MaxScroll<0 then\\\
e.MaxScroll=0\\\
end\\\
end,\\\
Initialise=function(o,t)\\\
local e={}\\\
setmetatable(e,{__index=o})\\\
e.Width=32\\\
e.Height=16\\\
e.Return=t\\\
e.X=math.ceil((Drawing.Screen.Width-e.Width)/2)\\\
e.Y=math.ceil((Drawing.Screen.Height-e.Height)/2)\\\
e.Title='Save Document'\\\
e.Visible=true\\\
e.CurrentDirectory='/'\\\
if OneOS and fs.exists('/Desktop/Documents/')then\\\
e.CurrentDirectory='/Desktop/Documents/'\\\
end\\\
e.SaveButton=Button:Initialise(e.Width-6,e.Height-1,nil,nil,colours.white,e,function(o,i,i,i,i)\\\
if o.TextColour==colours.black and not fs.isDir(e.CurrentDirectory..'/'..e.PathTextBox.TextInput.Value)then\\\
t(e,true,a(e.CurrentDirectory..'/'..e.PathTextBox.TextInput.Value))\\\
elseif e.SelectedFile and o.TextColour==colours.black and fs.isDir(e.CurrentDirectory..e.SelectedFile)then\\\
e:GoToDirectory(e.CurrentDirectory..e.SelectedFile)\\\
end\\\
end,'Save',colours.black)\\\
e.CancelButton=Button:Initialise(e.Width-15,e.Height-1,nil,nil,colours.white,e,function(a,a,a,a,a)\\\
t(e,false)\\\
end,'Cancel',colours.black)\\\
e.GoUpButton=Button:Initialise(2,e.Height-1,nil,nil,colours.white,e,function(t,t,t,t,t)\\\
local t=fs.getName(e.CurrentDirectory)\\\
local t=e.CurrentDirectory:sub(1,#e.CurrentDirectory-#t-1)\\\
e:GoToDirectory(t)\\\
end,'Go Up',colours.black)\\\
e.PathTextBox=TextBox:Initialise(2,e.Height-3,e.Width-2,1,e,'',colours.white,colours.black,function(t)\\\
if t==keys.enter then\\\
e.SaveButton:Click()\\\
end\\\
end)\\\
e.PathTextBox.Placeholder='Document Name'\\\
Current.TextInput=e.PathTextBox.TextInput\\\
e:GoToDirectory(e.CurrentDirectory)\\\
return e\\\
end,\\\
Show=function(e)\\\
Current.Window=e\\\
return e\\\
end,\\\
Close=function(e)\\\
Current.Input=nil\\\
Current.Window=nil\\\
e=nil\\\
end,\\\
GoToDirectory=function(e,t)\\\
t=a(t)\\\
e.CurrentDirectory=t\\\
e.Scroll=0\\\
e.Typed=false\\\
local t=fs\\\
if OneOS then\\\
t=OneOS.FS\\\
end\\\
e.Files=t.list(e.CurrentDirectory)\\\
Draw()\\\
end,\\\
Flash=function(e)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
sleep(.15)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
end,\\\
Click=function(e,n,o,t)\\\
local i={e.SaveButton,e.CancelButton,e.PathTextBox,e.GoUpButton}\\\
local a=false\\\
for i,e in ipairs(i)do\\\
if CheckClick(e,o,t)then\\\
e:Click(n,o,t)\\\
a=true\\\
end\\\
end\\\
if not a then\\\
if t<=11 then\\\
local a=fs.list(e.CurrentDirectory)\\\
if a[t-1]then\\\
e:GoToDirectory(e.CurrentDirectory..a[t-1])\\\
Draw()\\\
end\\\
end\\\
end\\\
return true\\\
end\\\
}\\\
local i=function(t,i)\\\
local e={''}\\\
for a,t in t:gmatch('(%S+)(%s*)')do\\\
local o=e[#e]..a..t:gsub('\\\\n','')\\\
if#o>i then\\\
table.insert(e,'')\\\
end\\\
if t:find('\\\\n')then\\\
e[#e]=e[#e]..a\\\
t=t:gsub('\\\\n',function()\\\
table.insert(e,'')\\\
return''\\\
end)\\\
else\\\
e[#e]=e[#e]..a..t\\\
end\\\
end\\\
return e\\\
end\\\
ButtonDialougeWindow={\\\
X=1,\\\
Y=1,\\\
Width=0,\\\
Height=0,\\\
CursorPos=1,\\\
Visible=true,\\\
CancelButton=nil,\\\
OkButton=nil,\\\
Lines={},\\\
AbsolutePosition=function(e)\\\
return{X=e.X,Y=e.Y}\\\
end,\\\
Draw=function(e)\\\
if not e.Visible then\\\
return\\\
end\\\
Drawing.DrawBlankArea(e.X+1,e.Y+1,e.Width,e.Height,colours.grey)\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,1,colours.lightGrey)\\\
Drawing.DrawBlankArea(e.X,e.Y+1,e.Width,e.Height-1,colours.white)\\\
Drawing.DrawCharactersCenter(e.X,e.Y,e.Width,1,e.Title,colours.black,colours.lightGrey)\\\
for t,a in ipairs(e.Lines)do\\\
Drawing.DrawCharacters(e.X+1,e.Y+1+t,a,colours.black,colours.white)\\\
end\\\
e.OkButton:Draw()\\\
if e.CancelButton then\\\
e.CancelButton:Draw()\\\
end\\\
end,\\\
Initialise=function(h,s,n,t,a,o)\\\
local e={}\\\
setmetatable(e,{__index=h})\\\
e.Width=28\\\
e.Lines=i(n,e.Width-2)\\\
e.Height=5+#e.Lines\\\
e.Return=o\\\
e.X=math.ceil((Drawing.Screen.Width-e.Width)/2)\\\
e.Y=math.ceil((Drawing.Screen.Height-e.Height)/2)\\\
e.Title=s\\\
e.Visible=true\\\
e.Visible=true\\\
e.OkButton=Button:Initialise(e.Width-#t-2,e.Height-1,nil,1,nil,e,function()\\\
o(e,true)\\\
end,t)\\\
if a then\\\
e.CancelButton=Button:Initialise(e.Width-#t-2-1-#a-2,e.Height-1,nil,1,nil,e,function()\\\
o(e,false)\\\
end,a)\\\
end\\\
return e\\\
end,\\\
Show=function(e)\\\
Current.Window=e\\\
return e\\\
end,\\\
Close=function(e)\\\
Current.Window=nil\\\
e=nil\\\
end,\\\
Flash=function(e)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
sleep(.15)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
end,\\\
Click=function(e,o,t,a)\\\
local e={e.OkButton,e.CancelButton}\\\
local i=false\\\
for n,e in ipairs(e)do\\\
if CheckClick(e,t,a)then\\\
e:Click(o,t,a)\\\
i=true\\\
end\\\
end\\\
return true\\\
end\\\
}\\\
TextDialougeWindow={\\\
X=1,\\\
Y=1,\\\
Width=0,\\\
Height=0,\\\
CursorPos=1,\\\
Visible=true,\\\
CancelButton=nil,\\\
OkButton=nil,\\\
Lines={},\\\
TextInput=nil,\\\
AbsolutePosition=function(e)\\\
return{X=e.X,Y=e.Y}\\\
end,\\\
Draw=function(e)\\\
if not e.Visible then\\\
return\\\
end\\\
Drawing.DrawBlankArea(e.X+1,e.Y+1,e.Width,e.Height,colours.grey)\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,1,colours.lightGrey)\\\
Drawing.DrawBlankArea(e.X,e.Y+1,e.Width,e.Height-1,colours.white)\\\
Drawing.DrawCharactersCenter(e.X,e.Y,e.Width,1,e.Title,colours.black,colours.lightGrey)\\\
for t,a in ipairs(e.Lines)do\\\
Drawing.DrawCharacters(e.X+1,e.Y+1+t,a,colours.black,colours.white)\\\
end\\\
Drawing.DrawBlankArea(e.X+1,e.Y+e.Height-4,e.Width-2,1,colours.lightGrey)\\\
Drawing.DrawCharacters(e.X+2,e.Y+e.Height-4,e.TextInput.Value,colours.black,colours.lightGrey)\\\
Current.CursorPos={e.X+2+e.TextInput.CursorPos,e.Y+e.Height-4}\\\
Current.CursorColour=colours.black\\\
e.OkButton:Draw()\\\
if e.CancelButton then\\\
e.CancelButton:Draw()\\\
end\\\
end,\\\
Initialise=function(r,h,s,t,a,o,n)\\\
local e={}\\\
setmetatable(e,{__index=r})\\\
e.Width=28\\\
e.Lines=i(s,e.Width-2)\\\
e.Height=7+#e.Lines\\\
e.Return=o\\\
e.X=math.ceil((Drawing.Screen.Width-e.Width)/2)\\\
e.Y=math.ceil((Drawing.Screen.Height-e.Height)/2)\\\
e.Title=h\\\
e.Visible=true\\\
e.Visible=true\\\
e.OkButton=Button:Initialise(e.Width-#t-2,e.Height-1,nil,1,nil,e,function()\\\
if#e.TextInput.Value>0 then\\\
o(e,true,e.TextInput.Value)\\\
end\\\
end,t)\\\
if a then\\\
e.CancelButton=Button:Initialise(e.Width-#t-2-1-#a-2,e.Height-1,nil,1,nil,e,function()\\\
o(e,false)\\\
end,a)\\\
end\\\
e.TextInput=TextInput:Initialise('',function(t)\\\
if t then\\\
e.OkButton:Click()\\\
end\\\
Draw()\\\
end,n)\\\
Current.Input=e.TextInput\\\
return e\\\
end,\\\
Show=function(e)\\\
Current.Window=e\\\
return e\\\
end,\\\
Close=function(e)\\\
Current.Window=nil\\\
Current.Input=nil\\\
e=nil\\\
end,\\\
Flash=function(e)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
sleep(.15)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
end,\\\
Click=function(a,o,e,t)\\\
local a={a.OkButton,a.CancelButton}\\\
local i=false\\\
for n,a in ipairs(a)do\\\
if CheckClick(a,e,t)then\\\
a:Click(o,e,t)\\\
i=true\\\
end\\\
end\\\
return true\\\
end\\\
}\\\
function PrintCentered(e,t)\\\
local a,o=term.getSize()\\\
x=math.ceil(math.ceil((a/2)-(#e/2)),0)+1\\\
term.setCursorPos(x,t)\\\
print(e)\\\
end\\\
function DoVanillaClose()\\\
term.setBackgroundColour(colours.black)\\\
term.setTextColour(colours.white)\\\
term.clear()\\\
term.setCursorPos(1,1)\\\
PrintCentered(\\\"Thanks for using Ink!\\\",(Drawing.Screen.Height/2)-1)\\\
term.setTextColour(colours.lightGrey)\\\
PrintCentered(\\\"Word Proccessor for ComputerCraft\\\",(Drawing.Screen.Height/2))\\\
term.setTextColour(colours.white)\\\
PrintCentered(\\\"(c) oeed 2014\\\",(Drawing.Screen.Height/2)+3)\\\
term.setCursorPos(1,Drawing.Screen.Height)\\\
error('',0)\\\
end\\\
function Close()\\\
if c or not Current.Document or not Current.Modified then\\\
if not OneOS then\\\
DoVanillaClose()\\\
end\\\
return true\\\
else\\\
local e=ButtonDialougeWindow:Initialise('Quit Ink?','You have unsaved changes, do you want to quit anyway?','Quit','Cancel',function(t,e)\\\
if e then\\\
if OneOS then\\\
OneOS.Close(true)\\\
else\\\
DoVanillaClose()\\\
end\\\
end\\\
t:Close()\\\
Draw()\\\
end):Show()\\\
os.queueEvent('mouse_click',1,e.X,e.Y)\\\
return false\\\
end\\\
end\\\
if OneOS then\\\
OneOS.CanClose=function()\\\
return Close()\\\
end\\\
end\\\
Initialise()\",\
    [ \"Desktop/Documents/Welcome!.txt\" ] = \"Hello and welcome to OneOS! If you have any problems, find a bug or have a suggestion let me (oeed) know on the ComputerCraft forums!\\\
\\\
Thanks for using OneOS!\",\
    [ \"System/Views/overlay.view\" ] = \"{\\\
  [\\\"Width\\\"]=\\\"100%\\\",\\\
  [\\\"Height\\\"]=1,\\\
  [\\\"X\\\"]=1,\\\
  [\\\"Y\\\"]=1,\\\
  [\\\"Type\\\"]=\\\"View\\\",\\\
  [\\\"BackgroundColour\\\"] = 1,\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"OneButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"One\\\",\\\
      [\\\"Toggle\\\"]=false,\\\
      [\\\"BackgroundColour\\\"]=0\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=\\\"100%,-2\\\",\\\
      [\\\"Name\\\"]=\\\"SearchButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"@\\\",\\\
      [\\\"Toggle\\\"]=false,\\\
      [\\\"BackgroundColour\\\"]=0 \\\
    },\\\
  },\\\
}\",\
    [ \"Programs/LuaIDE.program/Icons/lua\" ] = \"0blua7 \\\
07----\\\
07----\",\
    [ \"Programs/Games/Maze3D.program/Views/toolbar.view\" ] = \"{\\\
  [\\\"Width\\\"]=\\\"100%\\\",\\\
  [\\\"Height\\\"]=3,\\\
  [\\\"Type\\\"]=\\\"View\\\",\\\
  [\\\"BackgroundColour\\\"] = 128,\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=2,\\\
      [\\\"Name\\\"]=\\\"InstallLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Install\\\",\\\
      [\\\"TextColour\\\"]=1\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=10,\\\
      [\\\"Name\\\"]=\\\"ProgramNameLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Maze3D\\\",\\\
      [\\\"TextColour\\\"]=256\\\
    },\\\
  },\\\
}\",\
    [ \"System/API/AppRedirect.lua\" ] = \"\\\
--buffer item: text, text colour, background colour\\\
\\\
Buffer = {}\\\
TextColour = colours.white\\\
BackgroundColour = colours.black\\\
CursorPos = {1, 1}\\\
Size = {1, 1}\\\
CursorBlink = false\\\
\\\
Initialise = function(self, program)\\\
	local new = {}    -- the new instance\\\
	setmetatable( new, {__index = self} )\\\
	new.Size = {Current.ProgramView.Width, Current.ProgramView.Height}\\\
	new.CursorPos = {1, 1}\\\
	new.Buffer = {}\\\
	new.TextColour = colours.white\\\
	new.BackgroundColour = colours.black\\\
	new.CursorBlink = false\\\
	new.Term = _term(new)\\\
	new:ResizeBuffer()\\\
	new.Program = program\\\
	return new\\\
end\\\
\\\
ResizeBuffer = function(self)\\\
	if #self.Buffer ~= self.Size[2] then\\\
		while #self.Buffer < self.Size[2] do\\\
			table.insert(self.Buffer, {})\\\
		end\\\
\\\
		while #self.Buffer > self.Size[2] do\\\
			table.remove(self.Buffer, #self.Buffer)\\\
		end\\\
	end\\\
\\\
	for i, row in ipairs(self.Buffer) do\\\
		while #row < self.Size[1] do\\\
			table.insert(row, {' ', self.TextColour, self.BackgroundColour})\\\
		end\\\
\\\
		while #row > self.Size[1] do\\\
			table.remove(row, #row)\\\
		end\\\
	end\\\
end\\\
\\\
local count = 1\\\
\\\
ClearLine = function(self, y, backgroundColour)\\\
	if y > self.Size[2] or y < 1 then\\\
		return\\\
	end\\\
\\\
	if not Current.Window and not Current.Menu and Current.Program == self.Program then\\\
		Current.ProgramView:ForceDraw()\\\
	end\\\
	self.Buffer[y] = self.Buffer[y] or {}\\\
	for x = 1, self.Size[1] do\\\
		self.Buffer[y][x] = {' ', self.TextColour, backgroundColour}\\\
	end\\\
end\\\
\\\
WriteToBuffer = function(self, character, textColour, backgroundColour)\\\
	local x = math.floor(self.CursorPos[1])\\\
	local y = math.floor(self.CursorPos[2])\\\
	if x > self.Size[1] or y > self.Size[2] or x < 1 or y < 1 then\\\
		return\\\
	end\\\
\\\
	if Current.Program == self.Program and (not self.Buffer[y] or (self.Buffer[y][x][1] ~= character or self.Buffer[y][x][2] ~= textColour or self.Buffer[y][x][3] ~= backgroundColour)) then\\\
		Current.ProgramView:ForceDraw()\\\
	end\\\
	self.Buffer[y] = self.Buffer[y] or {}\\\
	self.Buffer[y][x] = {character, textColour, backgroundColour}\\\
end\\\
\\\
-- 'term' methods\\\
-- This is based upon 1.56, programs designed for 1.6 might not work correctly\\\
_term = function(self)\\\
	local _term = {}\\\
	_term.native = _term\\\
\\\
	_term.write = function(characters)\\\
		if type(characters) == 'number' then\\\
			characters = tostring(characters)\\\
		elseif type(characters) ~= 'string' then\\\
			return\\\
		end\\\
		self.CursorPos[1] = self.CursorPos[1] - 1\\\
		for i = 1, #characters do\\\
			local character = characters:sub(i,i)\\\
			self.CursorPos[1] = self.CursorPos[1] + 1\\\
			self:WriteToBuffer(character, self.TextColour, self.BackgroundColour)\\\
		end\\\
\\\
		self.CursorPos[1] = self.CursorPos[1] + 1\\\
	end\\\
\\\
	_term.blit = function(char, text, back)\\\
		if type(char) == 'number' then\\\
			char = tostring(char)\\\
		end\\\
		if type(text) == 'number' then\\\
			text = tostring(text)\\\
		end\\\
		if type(back) == 'number' then\\\
			back = tostring(back)\\\
		end\\\
		if #char ~= #text or #text ~= #back or #back ~= #char then\\\
			error(\\\"Arguments must be the same length\\\", 2)\\\
		end\\\
		local to_colors = {}\\\
		for i = 1, 16 do\\\
			to_colors[(\\\"0123456789abcdef\\\"):sub(i, i)] = 2 ^ (i - 1)\\\
		end\\\
		for i = 1, #char do\\\
			self:WriteToBuffer(char:sub(i,i), to_colors[text:sub(i,i)], to_colors[back:sub(i,i)])\\\
			self.CursorPos[1] = self.CursorPos[1] + 1\\\
		end\\\
	end\\\
\\\
	_term.clear = function()\\\
		local cursorPosX, cursorPosY = self.CursorPos[1], self.CursorPos[2]\\\
		for y = 1, self.Size[2] do\\\
			self:ClearLine(y, self.BackgroundColour)\\\
		end\\\
		self.CursorPos = {cursorPosX, cursorPosY}\\\
	end\\\
\\\
	_term.clearLine = function()\\\
		local cursorPosX, cursorPosY = self.CursorPos[1], self.CursorPos[2]\\\
		self:ClearLine(cursorPosY, self.BackgroundColour)\\\
		self.CursorPos = {cursorPosX, cursorPosY}\\\
	end\\\
\\\
	_term.getCursorPos = function()\\\
		return self.CursorPos[1], self.CursorPos[2]\\\
	end\\\
\\\
	_term.setCursorPos = function(x, y)\\\
		self.CursorPos[1] = math.floor( tonumber(x) ) or self.CursorPos[1]\\\
		self.CursorPos[2] = math.floor( tonumber(y) ) or self.CursorPos[2]\\\
	end\\\
\\\
	_term.setCursorBlink = function(blink)\\\
		self.CursorBlink = blink\\\
	end\\\
\\\
	_term.isColour = function()\\\
		return true\\\
	end\\\
\\\
	_term.isColor = _term.isColour\\\
\\\
	_term.setTextColour = function(colour)\\\
		if colour and colour <= 32768 and colour >= 1 then\\\
			self.TextColour = colour\\\
			Current.CursorColour = self.TextColour\\\
		end\\\
	end\\\
\\\
	_term.setTextColor = _term.setTextColour\\\
\\\
	_term.setBackgroundColour = function(colour)\\\
		if colour and colour <= 32768 and colour >= 1 then\\\
			self.BackgroundColour = colour\\\
		end\\\
	end\\\
\\\
	_term.setBackgroundColor = _term.setBackgroundColour\\\
\\\
	_term.getTextColour = function(colour)\\\
		return self.TextColour\\\
	end\\\
\\\
	_term.getTextColor = _term.getTextColour\\\
\\\
	_term.getBackgroundColour = function(colour)\\\
		return self.BackgroundColour\\\
	end\\\
\\\
	_term.getBackgroundColor = _term.getBackgroundColour\\\
\\\
	_term.getSize = function()\\\
		return self.Size[1], self.Size[2]\\\
	end\\\
\\\
	_term.scroll = function(amount)\\\
		if amount == nil then\\\
			error(\\\"Expected number\\\", 2)\\\
		end\\\
		local lines = {}\\\
		if amount > 0 then\\\
			for _ = 1, amount do\\\
				table.remove(self.Buffer, 1)\\\
				table.insert(lines, #self.Buffer+1)\\\
			end\\\
		elseif amount < 0 then\\\
			for _ = 1, amount do\\\
				table.remove(self.Buffer, #self.Buffer)\\\
				local row = {}\\\
				for i = 1, self.Size[1] do\\\
					table.insert(row, {' ', self.TextColour, self.BackgroundColour})\\\
				end\\\
				table.insert(self.Buffer, 1, row)\\\
				table.insert(lines, _)\\\
			end\\\
		end\\\
		self:ResizeBuffer()\\\
		for i, v in ipairs(lines) do\\\
			self:ClearLine(v, self.BackgroundColour)\\\
		end\\\
	end\\\
\\\
	return _term\\\
end\",\
    [ \"Programs/Sketch.program/Icons/skch\" ] = \"3bskch\\\
3f  d  \\\
df    \",\
    [ \"Programs/Quest.program/Objects/WebView.lua\" ] = \"Inherit = 'ScrollView'\\\
URL = nil\\\
FakeURL = nil\\\
LoadingURL = nil\\\
Tree = nil\\\
BackgroundColour = colours.white\\\
ScriptEnvironment = nil\\\
Timers = nil\\\
Download = nil\\\
\\\
-- TODO: strip this down to remove positioning stuff\\\
UpdateLayout = function(self)\\\
	self:RemoveAllObjects()\\\
	self.BackgroundColour = colours.white\\\
	local body = self.Tree:GetElement('body')\\\
\\\
	--TODO: check that body exists, if not redirect to an error page\\\
\\\
	if body.BackgroundColour then\\\
		self.BackgroundColour = body.BackgroundColour\\\
	end\\\
\\\
	local node = true\\\
	node = function(children, parentObject)\\\
		local currentY = 1\\\
		for i, v in ipairs(children) do\\\
			local object = v:CreateObject(parentObject, currentY)\\\
			if object then\\\
				v.Object = object\\\
				if v.Children and #v.Children > 0 and object.Children then\\\
					local usedY = node(v.Children, object)\\\
					if not v.Attributes.height then\\\
						object.Height = usedY\\\
					end\\\
					object:OnUpdate('Children')\\\
				end\\\
				-- if not object.Height then\\\
				-- 	for k, v in pairs(object) do\\\
				-- 		error(v)\\\
				-- 	end	\\\
				-- 	error('Nope')\\\
				-- end\\\
				currentY = currentY + object.Height\\\
			end\\\
		end\\\
		return currentY - 1\\\
	end\\\
	node(body.Children, self)\\\
	\\\
	self:RepositionLayout()\\\
\\\
	local head = self.Tree:GetElement('head')\\\
	if head then\\\
		for i, child in ipairs(head.Children) do\\\
			if child.Tag == 'script' then\\\
				child:InsertScript(self)\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
RepositionLayout = function(self)\\\
	local node = true\\\
	node = function(children, isFloat, parent)\\\
		if parent.OnRecalculateStart then\\\
			parent:OnRecalculateStart()\\\
		end\\\
\\\
		local currentY = 1\\\
		local currentX = 1\\\
		local tallestChild = 1\\\
		for i, child in ipairs(children) do\\\
			if child.Type ~= 'ScrollBar' then\\\
				if isFloat then\\\
					if currentX ~= 1 and parent.Width - currentX + 1 < child.Width then\\\
						currentX = 1\\\
						currentY = currentY + tallestChild\\\
						tallestChild = 1\\\
					end\\\
\\\
					if parent.Align == \\\"Left\\\" then\\\
						child.X = currentX\\\
					elseif parent.Align == \\\"Right\\\" then\\\
						child.X = parent.Width - currentX - child.Width + 2\\\
					end\\\
				end\\\
				child.Y = currentY\\\
\\\
				if child.Children and #child.Children > 0 then\\\
					local usedY = node(child.Children, child.IsFloat, child)\\\
					child:OnUpdate('Children')\\\
					if not child.Element.Attributes.height then\\\
						child.Height = usedY\\\
					end\\\
				end\\\
\\\
				if child.Height > tallestChild then\\\
					tallestChild = child.Height\\\
				end\\\
\\\
				if isFloat then\\\
					currentX = currentX + child.Width\\\
				else\\\
					currentY = currentY + child.Height\\\
				end\\\
			end\\\
		end\\\
		if isFloat then\\\
			currentY = currentY + tallestChild\\\
		end\\\
		if parent.OnRecalculateEnd then\\\
			currentY = parent:OnRecalculateEnd(currentY)\\\
		end\\\
		return currentY - 1\\\
	end\\\
	node(self.Children, self.IsFloat, self)\\\
\\\
	self:UpdateScroll()\\\
end\\\
\\\
GoToURL = function(self, url, nonVerbose, noHistory, post)\\\
	self.BackgroundColour = colours.white\\\
	self:RemoveAllObjects()\\\
	if self.OnPageLoadStart and not nonVerbose then\\\
		self:OnPageLoadStart(url, noHistory)\\\
	end\\\
	self.LoadingURL = url\\\
	if not nonVerbose then\\\
		self.FakeURL = url\\\
	end\\\
	self:InitialiseScriptEnvironment()\\\
\\\
	if not http and url:find('http://') then\\\
		if self.OnPageLoadFailed then\\\
			self:OnPageLoadFailed(url, 4, noHistory)\\\
		end\\\
		return\\\
	end\\\
\\\
	-- error(fs.getName(url))\\\
	local parts = urlComponents(url)\\\
	-- if url:sub(#url) ~= '/' and url:find('?') then\\\
	-- 	fileName = fs.getName(url:sub(1, url:find('?') - 1))\\\
	-- else\\\
	-- 	fileName = fs.getName(url)\\\
	-- end\\\
\\\
	local fileName = parts.filename\\\
	local extension\\\
	if fileName == '' or url:sub(#url) == '/' then\\\
		extension = true\\\
	else\\\
		extension = fileName:match('%.[0-9a-z%?%%]+$')\\\
		if extension then\\\
			extension = extension:sub(2)\\\
		end\\\
	end\\\
\\\
	-- local nonDownloadExtensions = {}\\\
	-- local shouldDownload =  not extension or (extension ~= true and extension ~= '' and extension ~= 'ccml' and extension ~= 'html' and extension ~= 'php' and extension ~= 'asp' and extension ~= 'aspx' and extension ~= 'jsp' and extension ~= 'qst' and extension ~= 'com' and extension ~= 'me' and extension ~= 'net' and extension ~= 'info' and extension ~= 'au' and extension ~= 'nz' and extension ~= 'de') \\\
\\\
	if not url:find('quest://download.ccml') and not url:find('quest://downloaded.ccml') then\\\
		self.Download = nil\\\
	end\\\
\\\
	fetchHTTPAsync(url, function(ok, event, response)\\\
		self.LoadingURL = nil\\\
		if ok then\\\
			if response.getResponseCode then\\\
				local code = response.getResponseCode()\\\
				if code ~= 200 then\\\
					if self.OnPageLoadFailed then\\\
						self:OnPageLoadFailed(url, code, noHistory)\\\
					end\\\
					response.close()\\\
					return\\\
				end\\\
			end\\\
\\\
			local html = response.readAll()\\\
			response.close()\\\
			if html:sub(1,9):lower() == '<!doctype' then\\\
				--web page\\\
				self.Tree, err = ElementTree:Initialise(html)\\\
				if not err then\\\
					self.URL = url\\\
					self:UpdateLayout()\\\
					if self.OnPageLoadEnd and not nonVerbose then\\\
						self:OnPageLoadEnd(url, noHistory)\\\
					end\\\
				else\\\
					if self.OnPageLoadFailed then\\\
						self:OnPageLoadFailed(url, err, noHistory)\\\
					end\\\
				end\\\
			else\\\
				--download\\\
				local downloadsFolder = '/Downloads/'\\\
				local _fs = fs\\\
				if OneOS then\\\
					downloadsFolder = '/Desktop/Documents/Downloads/'\\\
					_fs = OneOS.FS\\\
				end\\\
				if not _fs.exists(downloadsFolder) then\\\
					_fs.makeDir(downloadsFolder)\\\
				end\\\
\\\
				local downloadPath = downloadsFolder..fileName\\\
				local i = 1\\\
				local name = Bedrock.Helpers.RemoveExtension(fileName)\\\
				local ext = Bedrock.Helpers.Extension(fileName, true)\\\
				while _fs.exists(downloadPath) do\\\
					i = i + 1\\\
					downloadPath = downloadsFolder..name .. ' (' .. i .. ')' .. ext\\\
				end\\\
				local f = _fs.open(downloadPath, 'w')\\\
				if f then\\\
					f.write(html)\\\
					f.close()\\\
					self:GoToURL('quest://downloaded.ccml?path='..textutils.urlEncode(downloadPath), true, true)\\\
					self:OnPageLoadEnd(url, noHistory)\\\
				else\\\
					self:OnPageLoadFailed(url, 6, noHistory)\\\
				end\\\
			end\\\
		elseif self.OnPageLoadFailed and not nonVerbose then\\\
			self:OnPageLoadFailed(url, event, noHistory)\\\
		end\\\
	end, post)\\\
end\\\
\\\
Stop = function(self)\\\
	cancelHTTPAsync(self.LoadingURL)\\\
	if self.OnPageLoadFailed then\\\
		self:OnPageLoadFailed(url, Errors.TimeoutStop)\\\
	end\\\
end\\\
\\\
ResolveElements = function(self, selector)\\\
	local elements = {}\\\
	local node = true\\\
	local isClass = false\\\
	if selector:sub(1,1) == '.' then\\\
		isClass = true\\\
	end\\\
\\\
	node = function(tbl)\\\
		for i,v in ipairs(tbl) do\\\
			if type(v) == 'table' and v.Tag then\\\
				if not isClass and v.Tag:lower() == selector:lower() then\\\
					table.insert(elements, v.Object)\\\
				elseif isClass and v.Attributes.class and v.Attributes.class:lower() == selector:lower():sub(2) then\\\
					table.insert(elements, v.Object)\\\
				end\\\
				if v.Children then\\\
					local r = node(v.Children)\\\
				end\\\
			end\\\
		end\\\
	end\\\
	node(self.Tree.Tree)\\\
	return elements\\\
end\\\
\\\
InitialiseScriptEnvironment = function(self)\\\
	lQuery.webView = self\\\
	if self.Timers then\\\
		for i, timer in ipairs(self.Timers) do\\\
			-- error('clear '..timer)\\\
			self.Bedrock.Timers[timer] = nil\\\
		end\\\
	end\\\
	self.Timers = {}\\\
\\\
	local getValues = urlComponents(self.LoadingURL).get\\\
\\\
	self.ScriptEnvironment = {\\\
		keys = keys,\\\
		printError = printError, -- maybe don't have this\\\
		assert = assert,\\\
		getfenv = getfenv,\\\
		bit = bit,\\\
		rawset = rawset,\\\
		tonumber = tonumber,\\\
		loadstring = loadstring,\\\
		error = error, -- maybe don't have this\\\
		tostring = tostring,\\\
		type = type,\\\
		coroutine = coroutine,\\\
		next = next,\\\
		unpack = unpack,\\\
		colours = colours,\\\
		pcall = pcall,\\\
		math = math,\\\
		pairs = pairs,\\\
		rawget = rawget,\\\
		_G = _G,\\\
		__inext = __inext,\\\
		read = read,\\\
		ipairs = ipairs,\\\
		xpcall = xpcall,\\\
		rawequal = rawequal,\\\
		setfenv = setfenv,\\\
		http = http, --create an ajax thing to replace this\\\
		string = string,\\\
		setmetatable = setmetatable,\\\
		getmetatable = getmetatable,\\\
		table = table,\\\
		parallel = parallel, -- this mightn't work properly\\\
		textutils = textutils,\\\
		colors = colors,\\\
		vector = vector,\\\
		select = select,\\\
		os = {\\\
			version = os.version,\\\
			getComputerID = os.getComputerID,\\\
			getComputerLabel = os.getComputerLabel,\\\
			clock = os.clock,\\\
			time = os.time,\\\
			day = os.day,\\\
		},\\\
		lQuery = lQuery.fn,\\\
		l = lQuery.fn,\\\
		setTimeout = function(func, delay)\\\
			if type(func) == 'function' and type(delay) == 'number' then\\\
				local t = self.Bedrock:StartTimer(func, delay)\\\
				table.insert(self.Timers, t)\\\
				return t\\\
			end\\\
		end,\\\
		setInterval = function(func, interval)\\\
			if type(func) == 'function' and type(interval) == 'number' then\\\
				local t = self.Bedrock:StartRepeatingTimer(function(timer)\\\
					table.insert(self.Timers, timer)\\\
					func()\\\
				end, interval)\\\
				table.insert(self.Timers, t)\\\
				return t\\\
			end\\\
		end,\\\
		clearTimeout = function(timer)\\\
			self.Bedrock.Timers[timer] = nil\\\
		end,\\\
		clearInterval = function(timer)\\\
			self.Bedrock.Timers[timer] = nil\\\
		end,\\\
		window = {\\\
			location = self.URL,\\\
			realLocation = self.LoadingURL,\\\
			get = getValues,\\\
			version = QuestVersion\\\
		}\\\
	}\\\
end\\\
\\\
LoadScript = function(self, script)\\\
	local fn, err = loadstring(script, 'Script Tag Error: '..self.URL)\\\
	if fn then\\\
		setfenv(fn, self.ScriptEnvironment)\\\
		fn()\\\
	else\\\
		local start = err:find(': ')\\\
		self:OnPageLoadFailed(url, err:sub(start + 2), noHistory)\\\
	end\\\
end\\\
\\\
RemoveElement = function(self, elem)\\\
	local elements = {}\\\
	local node = true\\\
	node = function(tbl)\\\
		for i,v in ipairs(tbl) do\\\
			if type(v) == 'table' then\\\
				if v == elem.Element then\\\
					elem.Parent:RemoveObject(elem)\\\
					v = nil\\\
					return\\\
				end\\\
				if v.Children then\\\
					local r = node(v.Children)\\\
				end\\\
			end\\\
		end\\\
	end\\\
	node(self.Tree.Tree)\\\
end\",\
    [ \"Programs/Quest.program/icon\" ] = \"e3    \\\
d3 b  4 \\\
d3  4  \",\
    [ \"Programs/LuaIDE.program/Icons/log\" ] = \"01log7 \\\
07----\\\
07----\",\
    [ \"Programs/Transmit.program/Objects/DiscoverView.lua\" ] = \"Inherit = 'View'\\\
\\\
BackgroundColour = colours.transparent\\\
Computers = false\\\
\\\
local function AddComputer(self, computer, angle, radius)\\\
	--sohcahtoa\\\
	local vertexX, vertexY = Drawing.Screen.Width/2, Drawing.Screen.Height - 2\\\
	width = (radius * math.sin(-angle/90)) * 1.5 -- to fix the pixel ratio\\\
	height = radius * math.cos(-angle/90)\\\
\\\
	local centerX = 1 + (Drawing.Screen.Width/2) - width\\\
	local centerY = vertexY - height\\\
\\\
	local imageView = self:AddObject({\\\
		[\\\"Type\\\"] = 'ImageView',\\\
		[\\\"Width\\\"] = 5,\\\
		[\\\"Height\\\"] = 4,\\\
		[\\\"X\\\"] = centerX - 3,\\\
		[\\\"Y\\\"] = centerY - 2,\\\
		[\\\"Path\\\"] = '/Images/computer'\\\
	})\\\
\\\
	local name = Helpers.TruncateString(computer.Name,13)\\\
	local label = self:AddObject({\\\
		[\\\"Type\\\"] = 'Label',\\\
		[\\\"X\\\"] = math.floor(centerX - (#name / 2)),\\\
		[\\\"Y\\\"] = centerY + 3,\\\
		[\\\"Text\\\"] = name\\\
	})\\\
\\\
	label.OnClick = function()\\\
		SendToComputer(computer)\\\
	end\\\
	imageView.OnClick = label.OnClick\\\
end\\\
\\\
OnUpdate = function(self, value)\\\
	if value == 'Computers' and self.Computers then\\\
		self:RemoveAllObjects()\\\
\\\
		while #self.Computers > 4 do\\\
			table.remove(self.Computers, #self.Computers)\\\
		end\\\
\\\
		local max = #self.Computers\\\
		local separationAngle = 75\\\
		for i, computer in ipairs(self.Computers) do\\\
			local angle = 0\\\
			if max % 2 == 0 then\\\
				if max/2 == i then\\\
					angle = separationAngle/2\\\
				elseif max/2 == i - 1 then\\\
					angle = -separationAngle/2\\\
				else\\\
					angle = separationAngle * (i - max/2) - separationAngle/2\\\
				end\\\
			else\\\
				if math.ceil(max/2) == i then\\\
					angle = 0\\\
				else\\\
					angle = separationAngle * (i - math.ceil(max/2))\\\
				end\\\
			end\\\
			AddComputer(self, computer, angle, 12)\\\
		end\\\
	end\\\
end\",\
    [ \"Programs/App Store.program/startup\" ] = \"OneOS.LoadAPI('System/JSON')\\\
local t={...}\\\
Settings={\\\
InstallLocation='/Programs/',\\\
AlwaysFolder=true,\\\
}\\\
local s=false\\\
local i=''\\\
local o={}\\\
local w=true\\\
local p=0\\\
local a=nil\\\
local y=nil\\\
Values={\\\
ToolbarHeight=2,\\\
}\\\
Current={\\\
CursorBlink=false,\\\
CursorPos={},\\\
CursorColour=colours.black,\\\
ScrollBar=nil\\\
}\\\
local function h(a,e)\\\
local t,e=e or\\\":\\\",{}\\\
local t=string.format(\\\"([^%s]+)\\\",t)\\\
a:gsub(t,function(t)e[#e+1]=t end)\\\
return e\\\
end\\\
OneOS.LoadAPI('System/API/LegacyDrawing.lua')\\\
local Drawing = LegacyDrawing\\\
Drawing.Offset={\\\
X=0,\\\
Y=0\\\
}\\\
Drawing.SetOffset=function(t,e)\\\
Drawing.Offset.X=t\\\
Drawing.Offset.Y=e\\\
end\\\
Drawing.ClearOffset=function()\\\
Drawing.Offset={\\\
X=0,\\\
Y=0\\\
}\\\
end\\\
Drawing.WriteToBuffer=function(t,e,o,i,a)\\\
t=t+Drawing.Offset.X\\\
e=e+Drawing.Offset.Y\\\
Drawing.Buffer[e]=Drawing.Buffer[e]or{}\\\
Drawing.Buffer[e][t]={o,i,a}\\\
end\\\
Drawing.LoadImage=function(e)\\\
local t={\\\
text={},\\\
textcol={}\\\
}\\\
local e=h(e,'\\\\n')\\\
for e,a in ipairs(e)do\\\
table.insert(t,e,{})\\\
table.insert(t.text,e,{})\\\
table.insert(t.textcol,e,{})\\\
local o=1\\\
local n,s=false,false\\\
local r,i=nil,nil\\\
for h=1,#a do\\\
local a=string.sub(a,h,h)\\\
if a:byte()==30 then\\\
n=true\\\
elseif a:byte()==31 then\\\
s=true\\\
elseif n then\\\
r=Drawing.GetColour(a)\\\
n=false\\\
elseif s then\\\
i=Drawing.GetColour(a)\\\
s=false\\\
else\\\
if a~=\\\" \\\"and i==nil then\\\
i=colours.white\\\
end\\\
t[e][o]=r\\\
t.textcol[e][o]=i\\\
t.text[e][o]=a\\\
o=o+1\\\
end\\\
end\\\
e=e+1\\\
end\\\
return t\\\
end\\\
SearchPage={\\\
X=0,\\\
Y=0,\\\
Width=0,\\\
Height=3,\\\
Text=\\\"\\\",\\\
Placeholder=\\\"Search...\\\",\\\
CursorPos=1,\\\
Draw=function(e)\\\
Drawing.DrawBlankArea(e.X+1,e.Y+1,e.Width-6,e.Height,colours.grey)\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width-6,e.Height,colours.white)\\\
Drawing.DrawBlankArea(e.X+e.Width-5+1,e.Y+1,6,e.Height,colours.grey)\\\
Drawing.DrawBlankArea(e.X+e.Width-5,e.Y,6,e.Height,colours.blue)\\\
Drawing.DrawCharacters(e.X+e.Width-3,e.Y+1,\\\"GO\\\",colours.white,colours.blue)\\\
RegisterClick(e.X+e.Width-5,e.Y+2,6,e.Height,function()\\\
ChangePage('Search Results',e.Text)\\\
end)\\\
if e.Text==\\\"\\\"then\\\
Drawing.DrawCharacters(e.X+1,e.Y+1,e.Placeholder,colours.lightGrey,colours.white)\\\
else\\\
Drawing.DrawCharacters(e.X+1,e.Y+1,e.Text,colours.black,colours.white)\\\
end\\\
Current.CursorBlink=true\\\
Current.CursorPos={e.X+e.CursorPos,e.Y+3}\\\
Current.CursorColour=colours.black\\\
end,\\\
Initialise=function(t)\\\
local e={}\\\
setmetatable(e,{__index=t})\\\
e.Y=math.floor((Drawing.Screen.Height-1-e.Height)/2)\\\
e.X=2\\\
e.Width=Drawing.Screen.Width-4\\\
return e\\\
end\\\
}\\\
ListItem={\\\
X=0,\\\
Y=0,\\\
XMargin=1,\\\
YMargin=1,\\\
Width=0,\\\
Height=6,\\\
AppID=0,\\\
Title='',\\\
Author='',\\\
Rating=0,\\\
Description={},\\\
Icon={},\\\
Downloads=0,\\\
Category='?',\\\
Version=1,\\\
Type=0,\\\
CalculateWrapping=function(e,t)\\\
local o=false\\\
if e.Type==0 then\\\
o=2\\\
end\\\
local i=e.Width-8\\\
local e={''}\\\
for a,t in t:gmatch('(%S+)(%s*)')do\\\
local o=e[#e]..a..t:gsub('\\\\n','')\\\
if#o>i then\\\
table.insert(e,'')\\\
end\\\
if t:find('\\\\n')then\\\
e[#e]=e[#e]..a\\\
t=t:gsub('\\\\n',function()\\\
table.insert(e,'')\\\
return''\\\
end)\\\
else\\\
e[#e]=e[#e]..a..t\\\
end\\\
end\\\
if not o then\\\
return e\\\
else\\\
local t={}\\\
for e,a in ipairs(e)do\\\
t[e]=a\\\
if e>=o then\\\
return t\\\
end\\\
end\\\
return t\\\
end\\\
end,\\\
Draw=function(e)\\\
if e.Y+Drawing.Offset.Y>=Drawing.Screen.Height+1 or e.Y+Drawing.Offset.Y+e.Height<=1 then\\\
return\\\
end\\\
local t=1\\\
if e.Type==1 then\\\
t=2\\\
end\\\
RegisterClick(e.Width-7,e.Y+Drawing.Offset.Y+t-1,9,1,function()\\\
Load(\\\"Installing App\\\",function()\\\
api.installApplication(tonumber(e.AppID),Settings.InstallLocation..'/'..e.Title..\\\".program/\\\",false,Settings.AlwaysFolder,true)\\\
api.saveApplicationIcon(tonumber(e.AppID),Settings.InstallLocation..'/'..e.Title..\\\".program/icon\\\")\\\
end)\\\
Load(\\\"Application Installed!\\\",function()\\\
sleep(1)\\\
end)\\\
end)\\\
if e.Type==0 then\\\
RegisterClick(e.X,e.Y+Drawing.Offset.Y,e.Width,e.Height,function()\\\
ChangePage('more-info',e.AppID)\\\
end)\\\
elseif e.Type==2 then\\\
RegisterClick(e.X,e.Y+Drawing.Offset.Y,e.Width,e.Height,function()\\\
ChangePage('Category Items',e.Title)\\\
end)\\\
end\\\
Drawing.DrawBlankArea(e.X+1,e.Y+1,e.Width,e.Height,colours.grey)\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,e.Height,colours.white)\\\
Drawing.DrawCharacters(e.X+8,e.Y+1,tostring(e.Title),colours.black,colours.white)\\\
if e.Type~=2 then\\\
Drawing.DrawCharacters(e.X+8,e.Y+2,\\\"by \\\"..e.Author,colours.grey,colours.white)\\\
Drawing.DrawCharacters(e.Width-8,e.Y+t-1,\\\" Install \\\",colours.white,colours.green)\\\
end\\\
Drawing.DrawImage(e.X+1,e.Y+1,e.Icon,4,3)\\\
if e.Type==1 then\\\
Drawing.DrawCharacters(e.X,e.Y+6,\\\"Category\\\",colours.grey,colours.white)\\\
Drawing.DrawCharacters(math.ceil(e.X+(8-#e.Category)/2),e.Y+7,e.Category,colours.grey,colours.white)\\\
Drawing.DrawCharacters(e.X+1,e.Y+9,\\\"Dwnlds\\\",colours.grey,colours.white)\\\
Drawing.DrawCharacters(math.ceil(e.X+(8-#tostring(e.Downloads))/2),e.Y+10,tostring(e.Downloads),colours.grey,colours.white)\\\
Drawing.DrawCharacters(e.X+1,e.Y+12,\\\"Version\\\",colours.grey,colours.white)\\\
Drawing.DrawCharacters(math.ceil(e.X+(8-#tostring(e.Version))/2),e.Y+13,tostring(e.Version),colours.grey,colours.white)\\\
end\\\
if e.Type~=2 and e.Rating~=0 then\\\
local t=colours.yellow\\\
local i=colours.lightGrey\\\
local a=colours.lightGrey\\\
local n=e.X+8+#(\\\"by \\\"..e.Author)+1\\\
local o=e.Y+2\\\
local u=a\\\
local h=\\\" \\\"\\\
local s=a\\\
local r=\\\" \\\"\\\
local d=a\\\
local l=\\\" \\\"\\\
local c=a\\\
local m=\\\" \\\"\\\
local a=a\\\
local f=\\\" \\\"\\\
if e.Rating>=.5 then\\\
u=i\\\
h=\\\"#\\\"\\\
end\\\
if e.Rating>=1 then\\\
u=t\\\
h=\\\" \\\"\\\
end\\\
if e.Rating>=1.5 then\\\
s=i\\\
r=\\\"#\\\"\\\
end\\\
if e.Rating>=2 then\\\
s=t\\\
r=\\\" \\\"\\\
end\\\
if e.Rating>=2.5 then\\\
d=i\\\
l=\\\"#\\\"\\\
end\\\
if e.Rating>=3 then\\\
d=t\\\
l=\\\" \\\"\\\
end\\\
if e.Rating>=3.5 then\\\
c=i\\\
m=\\\"#\\\"\\\
end\\\
if e.Rating>=4 then\\\
c=t\\\
m=\\\" \\\"\\\
end\\\
if e.Rating>=4.5 then\\\
a=i\\\
f=\\\"#\\\"\\\
end\\\
if e.Rating==5 then\\\
a=t\\\
f=\\\" \\\"\\\
end\\\
Drawing.DrawCharacters(n,o,h,t,u)\\\
Drawing.DrawCharacters(n+2,o,r,t,s)\\\
Drawing.DrawCharacters(n+4,o,l,t,d)\\\
Drawing.DrawCharacters(n+6,o,m,t,c)\\\
Drawing.DrawCharacters(n+8,o,f,t,a)\\\
end\\\
local t=2\\\
if e.Type==1 then\\\
t=3\\\
elseif e.Type==2 then\\\
t=1\\\
end\\\
for o,a in ipairs(e.Description)do\\\
Drawing.DrawCharacters(e.X+8,e.Y+t+o,tostring(a),colours.lightGrey,colours.white)\\\
end\\\
end,\\\
Initialise=function(o,i,r,n,c,l,u,d,s,h,a,t)\\\
t=t or 0\\\
local e={}\\\
setmetatable(e,{__index=o})\\\
e.Y=i\\\
e:UpdateSize()\\\
e.Type=t\\\
e.AppID=r\\\
e.Title=n\\\
e.Icon=Drawing.LoadImage(c)\\\
e.Icon[5]=nil\\\
e.Description=e:CalculateWrapping(l)\\\
e:UpdateSize()\\\
e.Author=u\\\
e.Rating=d\\\
e.Version=s\\\
e.Category=h\\\
e.Downloads=a\\\
return e\\\
end,\\\
UpdateSize=function(e)\\\
e.X=e.XMargin+1\\\
e.Width=Drawing.Screen.Width-2*e.XMargin-2\\\
if e.Type==1 then\\\
e.Height=15\\\
if#e.Description+5>e.Height then\\\
e.Height=#e.Description+5\\\
end\\\
end\\\
end,\\\
}\\\
ScrollBar={\\\
X=1,\\\
Y=1,\\\
Width=1,\\\
Height=1,\\\
BackgroundColour=colours.grey,\\\
BarColour=colours.lightBlue,\\\
Parent=nil,\\\
Change=nil,\\\
Scroll=0,\\\
MaxScroll=0,\\\
ClickPoint=nil,\\\
AbsolutePosition=function(e)\\\
return e.Parent:AbsolutePosition()\\\
end,\\\
Draw=function(e)\\\
local t=math.floor(e.Height/e.MaxScroll)*10\\\
if t<3 then\\\
t=3\\\
end\\\
local a=(e.Scroll/e.MaxScroll)\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,e.Height,e.BackgroundColour)\\\
Drawing.DrawBlankArea(e.X,e.Y+math.floor(e.Height*a-t*a),e.Width,t,e.BarColour)\\\
RegisterClick(e.X,e.Y,e.Width,e.Height,function(n,n,t,a,i,o)\\\
e:Click(t,a,i,o)\\\
end)\\\
end,\\\
Initialise=function(h,s,r,d,o,t,a,n,i)\\\
local e={}\\\
setmetatable(e,{__index=h})\\\
e.Width=1\\\
e.Height=d\\\
e.Y=r\\\
e.X=s\\\
e.BackgroundColour=t or colours.grey\\\
e.BarColour=a or colours.lightBlue\\\
e.Parent=n\\\
e.Change=i or function()end\\\
e.MaxScroll=o\\\
e.Scroll=0\\\
return e\\\
end,\\\
DoScroll=function(e,t)\\\
t=math.ceil(t)\\\
if e.Scroll<0 or e.Scroll>e.MaxScroll then\\\
return false\\\
end\\\
e.Scroll=e.Scroll+t\\\
if e.Scroll<0 then\\\
e.Scroll=0\\\
elseif e.Scroll>e.MaxScroll then\\\
e.Scroll=e.MaxScroll\\\
end\\\
e.Change()\\\
return true\\\
end,\\\
Click=function(e,t,t,i,o)\\\
local a=(e.Scroll/e.MaxScroll)\\\
local t=(e.Height-e.MaxScroll)\\\
if t<3 then\\\
t=3\\\
end\\\
local t=(e.MaxScroll*(i+t*a)/e.Height)\\\
if not o then\\\
e.ClickPoint=e.Scroll-t+1\\\
end\\\
if e.Scroll-1~=t then\\\
e:DoScroll(t-e.Scroll-1+e.ClickPoint)\\\
end\\\
return true\\\
end\\\
}\\\
Clicks={\\\
}\\\
function RegisterClick(o,i,t,a,e)\\\
table.insert(Clicks,{\\\
X=o,\\\
Y=i,\\\
Width=t,\\\
Height=a,\\\
Action=e\\\
})\\\
end\\\
function Load(t,e)\\\
Drawing.DrawBlankArea(1,1,Drawing.Screen.Width+1,Drawing.Screen.Height+1,colours.lightGrey)\\\
Drawing.DrawCharactersCenter(nil,nil,nil,nil,t,colours.white,colours.lightGrey)\\\
isLoading=true\\\
parallel.waitForAny(function()\\\
e()\\\
isLoading=false\\\
end,DisplayLoader)\\\
end\\\
function DisplayLoader()\\\
local i=200\\\
local o=0\\\
local e=0\\\
while isLoading do\\\
local t=Drawing.Screen.Height/2+2\\\
local a=Drawing.Screen.Width/2\\\
Drawing.DrawCharacters(a-3,t,' ',colours.black,colours.grey)\\\
Drawing.DrawCharacters(a-1,t,' ',colours.black,colours.grey)\\\
Drawing.DrawCharacters(a+1,t,' ',colours.black,colours.grey)\\\
Drawing.DrawCharacters(a+3,t,' ',colours.black,colours.grey)\\\
if e~=-1 then\\\
Drawing.DrawCharacters(a-3+(e*2),t,' ',colours.black,colours.white)\\\
end\\\
e=e+1\\\
if e>=4 then\\\
e=-1\\\
end\\\
o=o+1\\\
if o>=i then\\\
isLoading=false\\\
error('Load timeout. Check your internet connection and try again. The server may also be down, try again in 10 minutes.')\\\
end\\\
Drawing.DrawBuffer()\\\
sleep(.15)\\\
end\\\
end\\\
function ChangePage(e,t)\\\
ClearCurrentPage()\\\
if e=='Top Charts'then\\\
LoadList(api.getTopCharts)\\\
elseif e=='Search Results'then\\\
LoadList(function()return api.searchApplications(t)end)\\\
elseif e==\\\"Featured\\\"then\\\
LoadFeatured()\\\
elseif e==\\\"Categories\\\"then\\\
LoadCategories()\\\
elseif e==\\\"more-info\\\"then\\\
LoadAboutApp(t)\\\
elseif e==\\\"Search\\\"then\\\
LoadSearch()\\\
elseif e==\\\"Category Items\\\"then\\\
LoadList(function()return api.getApplicationsInCategory(t)end)\\\
end\\\
i=e\\\
Current.ScrollBar.MaxScroll=getMaxScroll()\\\
end\\\
function LoadAboutApp(e)\\\
Load(\\\"Loading Application\\\",function()\\\
local e=api.getApplication(e)\\\
local e=ListItem:Initialise(1,e.id,e.name,e.icon,e.description,e.user.username,e.stars,e.version,e.category,e.downloads,1)\\\
table.insert(o,e)\\\
end)\\\
end\\\
function LoadFeatured()\\\
Load(\\\"Loading\\\",function()\\\
local e=api.getFeaturedApplications()\\\
for t,e in ipairs(e)do\\\
local e=ListItem:Initialise(1+(t-1)*(ListItem.Height+2),\\\
e.id,e.name,e.icon,e.description,\\\
e.user.username,e.stars,e.version,\\\
e.category,e.downloads)\\\
table.insert(o,e)\\\
end\\\
end)\\\
end\\\
function LoadCategories()\\\
Load(\\\"Loading\\\",function()\\\
local t=api.getCategories()\\\
local e=1\\\
for a,t in pairs(t)do\\\
local t=ListItem:Initialise(1+(e-1)*(ListItem.Height+2),\\\
0,a,t.icon,t.description,nil,nil,nil,nil,nil,2)\\\
table.insert(o,t)\\\
e=e+1\\\
end\\\
end)\\\
end\\\
function LoadSearch(e)\\\
local e=SearchPage:Initialise()\\\
a=e\\\
table.insert(o,e)\\\
end\\\
function ClearCurrentPage()\\\
for e,t in ipairs(o)do o[e]=nil end\\\
Current.ScrollBar.Scroll=0\\\
a=nil\\\
y=nil\\\
Current.CursorBlink=false\\\
Draw()\\\
end\\\
function LoadList(e)\\\
Load(\\\"Loading\\\",function()\\\
local e=e()\\\
if e==nil then\\\
error('Can not connect to the App Store server.')\\\
elseif type(e)~='table'then\\\
error('The server is too busy. Try again in a few minutes.')\\\
end\\\
for t,e in ipairs(e)do\\\
local e=ListItem:Initialise(1+(t-1)*(ListItem.Height+2),\\\
e.id,e.name,e.icon,e.description,\\\
e.user.username,e.stars,e.version,\\\
e.category,e.downloads)\\\
table.insert(o,e)\\\
end\\\
end)\\\
end\\\
function Draw()\\\
Clicks={}\\\
Drawing.Clear(colours.lightGrey)\\\
DrawList()\\\
DrawToolbar()\\\
Drawing.DrawBuffer()\\\
if Current.CursorPos and Current.CursorPos[1]and Current.CursorPos[2]then\\\
term.setCursorPos(unpack(Current.CursorPos))\\\
end\\\
term.setTextColour(Current.CursorColour)\\\
term.setCursorBlink(Current.CursorBlink)\\\
end\\\
function DrawList()\\\
Drawing.SetOffset(0,-Current.ScrollBar.Scroll+2)\\\
for t,e in ipairs(o)do\\\
e:Draw()\\\
end\\\
Drawing.ClearOffset()\\\
if getMaxScroll()~=0 then\\\
Current.ScrollBar:Draw()\\\
end\\\
end\\\
local r=false\\\
function DrawToolbar()\\\
if not r then\\\
return\\\
end\\\
Drawing.DrawBlankArea(1,1,Drawing.Screen.Width,1,colours.white)\\\
local o={\\\
{\\\
active=false,\\\
title=\\\"Featured\\\"\\\
},\\\
{\\\
active=false,\\\
title=\\\"Top Charts\\\"\\\
},\\\
{\\\
active=false,\\\
title=\\\"Categories\\\"\\\
},\\\
{\\\
active=false,\\\
title=\\\"Search\\\"\\\
}\\\
}\\\
local e=0\\\
local t=\\\"\\\"\\\
for o,a in ipairs(o)do\\\
e=e+#a.title+3\\\
t=t..a.title..\\\" | \\\"\\\
end\\\
e=e-3\\\
local t=(Drawing.Screen.Width-e)/2\\\
for n,e in ipairs(o)do\\\
local a=\\\" | \\\"\\\
if n==#o then\\\
a=\\\"\\\"\\\
end\\\
local o=colours.blue\\\
if i==e.title then\\\
o=colours.lightBlue\\\
end\\\
Drawing.DrawCharacters(t,1,e.title,o,colours.white)\\\
Drawing.DrawCharacters(t+#e.title,1,a,colours.blue,colours.white)\\\
RegisterClick(t-1,1,#e.title+2,1,function()\\\
ChangePage(e.title)\\\
end)\\\
t=t+#(e.title..a)\\\
end\\\
if not OneOS then\\\
Drawing.DrawCharacters(Drawing.Screen.Width,1,\\\"X\\\",colours.white,colours.red)\\\
RegisterClick(Drawing.Screen.Width,1,1,1,function()\\\
w=false\\\
term.setBackgroundColour(colours.black)\\\
term.setTextColour(colours.white)\\\
term.clear()\\\
term.setCursorPos(1,1)\\\
print=_print\\\
print('Thanks for using the App Store!')\\\
print('(c) oeed 2013 - 2014')\\\
end)\\\
end\\\
end\\\
function getMaxScroll()\\\
local e=0\\\
for a,t in ipairs(o)do\\\
e=e+t.Height+2\\\
end\\\
local t=e-Drawing.Screen.Height+2\\\
if t<0 then\\\
t=0\\\
end\\\
p=e\\\
return t\\\
end\\\
function EventHandler()\\\
while w do\\\
local t,e,h,n=os.pullEvent()\\\
if t==\\\"mouse_scroll\\\"then\\\
Current.ScrollBar:DoScroll(e*3)\\\
Draw()\\\
elseif t==\\\"timer\\\"then\\\
if e==y and i=='Featured'then\\\
o[1]:NextPage()\\\
Draw()\\\
end\\\
elseif t==\\\"char\\\"then\\\
if i=='Search'then\\\
a.Text=a.Text..e\\\
a.CursorPos=a.CursorPos+1\\\
Draw()\\\
end\\\
elseif t==\\\"key\\\"then\\\
if e==keys.down then\\\
Current.ScrollBar:DoScroll(3)\\\
Draw()\\\
elseif e==keys.up then\\\
Current.ScrollBar:DoScroll(-3)\\\
Draw()\\\
end\\\
if e==keys.backspace and i=='Search'then\\\
a.Text=string.sub(a.Text,0,#a.Text-1)\\\
a.CursorPos=a.CursorPos-1\\\
if a.CursorPos<1 then\\\
a.CursorPos=1\\\
end\\\
Draw()\\\
elseif e==keys.enter and i=='Search'then\\\
ChangePage('Search Results',a.Text)\\\
Draw()\\\
end\\\
elseif t==\\\"mouse_click\\\"or t==\\\"mouse_drag\\\"then\\\
local o=false\\\
for a=1,#Clicks do\\\
local a=Clicks[(#Clicks-a)+1]\\\
if not o and h>=a.X and(a.X+a.Width)>h and n>=a.Y and(a.Y+a.Height)>n then\\\
o=true\\\
local o=s\\\
a:Action(t,e,h,n,t==\\\"mouse_drag\\\")\\\
if o==s then\\\
s=false\\\
end\\\
Draw()\\\
end\\\
end\\\
if not o then\\\
s=false\\\
Draw()\\\
end\\\
end\\\
end\\\
end\\\
function TidyPath(e)\\\
if fs.exists(e)and fs.isDir(e)then\\\
e=e..'/'\\\
end\\\
e,n=e:gsub(\\\"//\\\",\\\"/\\\")\\\
while n>0 do\\\
e,n=e:gsub(\\\"//\\\",\\\"/\\\")\\\
end\\\
return e\\\
end\\\
function ConnectionError()\\\
print=_print\\\
term.setBackgroundColor(colours.grey)\\\
term.setTextColor(colours.white)\\\
term.clear()\\\
term.setCursorPos(2,2)\\\
print(\\\"Failed to connect to the server!\\\\n\\\\n\\\")\\\
term.setTextColour(colours.lightGrey)\\\
term.setCursorPos(2,4)\\\
print(\\\"An error occured while trying to\\\")\\\
term.setCursorPos(2,5)\\\
print(\\\"connect to the server.\\\")\\\
term.setCursorPos(2,6)\\\
print(\\\"Check the following things then try again:\\\")\\\
term.setTextColour(colours.white)\\\
term.setCursorPos(1,8)\\\
print(\\\" - Check that your internet is online and working\\\")\\\
print(\\\" - Ensure that the HTTP API is on\\\")\\\
print(\\\" - Ensure that ccappstore.com is whitelisted\\\")\\\
print(\\\" - Try accesing ccappstore.com in your browser\\\")\\\
term.setCursorPos(2,Drawing.Screen.Height-1)\\\
term.setTextColour(colours.white)\\\
print(\\\" Click anywhere to exit...\\\")\\\
os.pullEvent(\\\"mouse_click\\\")\\\
if OneOS then\\\
OneOS.Close()\\\
end\\\
term.setTextColour(colours.white)\\\
term.setBackgroundColour(colours.black)\\\
term.clear()\\\
term.setCursorPos(1,1)\\\
end\\\
function Initialise()\\\
os.loadAPI('api')\\\
if t and t[1]then\\\
if t[1]=='install'and t[2]and tonumber(t[2])then\\\
if OneOS then\\\
Load('Connecting',api.testConnection)\\\
Load(\\\"Installing App\\\",function()\\\
local a=t[3]or''\\\
local e=api.getApplication(tonumber(t[2]))\\\
if not e then\\\
error('Network error')\\\
end\\\
api.installApplication(tonumber(t[2]),Settings.InstallLocation..'/'..a..'/'..e.name..\\\".program/\\\",false,Settings.AlwaysFolder,true)\\\
api.saveApplicationIcon(tonumber(t[2]),Settings.InstallLocation..'/'..a..'/'..e.name..\\\".program/icon\\\")\\\
if t[4]then\\\
OneOS.OpenFile(Settings.InstallLocation..'/'..a..'/'..e.name..\\\".program/\\\")\\\
end\\\
end)\\\
OneOS.Close()\\\
end\\\
print('Connecting...')\\\
if api.testConnection()then\\\
print('Downloading program...')\\\
local e=t[3]or shell.dir()\\\
local e=api.installApplication(tonumber(t[2]),e,true)\\\
if e then\\\
print('Program installed!')\\\
print(\\\"Type '\\\"..TidyPath(e)..\\\"' to run it.\\\")\\\
else\\\
printError('Download failed. Check the ID and try again.')\\\
end\\\
else\\\
printError('Could not connect to the App Store.')\\\
printError('Check your connection and try again.')\\\
end\\\
elseif t[1]=='submit'and t[2]and fs.exists(shell.resolve(t[2]))then\\\
print('Packaging...')\\\
local e=Package(shell.resolve(t[2]))\\\
if e then\\\
print('Connecting...')\\\
if api.testConnection()then\\\
print('Uploading...')\\\
local e=JSON.encode(e)\\\
e=e:gsub(\\\"\\\\\\\\'\\\",\\\"'\\\")\\\
local e=http.post('http://ccappstore.com/submitPreupload.php',\\\
\\\"file=\\\"..textutils.urlEncode(e));\\\
if e then\\\
local t=e.readAll()\\\
if t:sub(1,2)=='OK'then\\\
print('Your program has been uploaded.')\\\
print('It\\\\'s unique ID is: '..t:sub(3))\\\
print('Go to ccappstore.com/submit/ and select \\\"In Game\\\" as the upload option and enter the above code.')\\\
else\\\
printError('The server rejected the file. Try again or PM oeed. ('..e.getResponseCode()..' error)')\\\
end\\\
else\\\
printError('Could not submit file.')\\\
end\\\
else\\\
printError('Could not connect to the App Store.')\\\
printError('Check your connection and try again.')\\\
end\\\
end\\\
else\\\
print('Useage: appstore install <app id> <path (optional)>')\\\
print('Or: appstore submit <path>')\\\
end\\\
else\\\
Load('Connecting',api.testConnection)\\\
Current.ScrollBar=ScrollBar:Initialise(Drawing.Screen.Width,2,Drawing.Screen.Height-1,0,colours.white,colours.blue,nil,function()end)\\\
ChangePage('Featured')\\\
r=true\\\
Draw()\\\
EventHandler()\\\
end\\\
end\\\
function addFile(e,t,o)\\\
if o=='.DS_Store'or shell.resolve(t)==shell.resolve(shell.getRunningProgram())then\\\
return e\\\
end\\\
local a=fs.open(t,'r')\\\
if not a then\\\
error('Failed reading file: '..t)\\\
end\\\
e[o]=a.readAll()\\\
a.close()\\\
return e\\\
end\\\
function addFolder(o,t,i)\\\
local e={}\\\
if t:sub(1,4)=='/rom'then\\\
return o\\\
end\\\
for o,a in ipairs(fs.list(t))do\\\
if fs.isDir(t..'/'..a)then\\\
e=addFolder(e,t..'/'..a)\\\
else\\\
e=addFile(e,t..'/'..a,a)\\\
end\\\
end\\\
if i then\\\
o=e\\\
else\\\
o[fs.getName(t)]=e\\\
end\\\
return o\\\
end\\\
function Package(t)\\\
local e={}\\\
if fs.isDir(t)then\\\
e=addFolder(e,t,true)\\\
else\\\
e=addFile(e,t,'startup')\\\
end\\\
if not e['startup']then\\\
print('You must have a file named startup in your program. This is the file used to start the program.')\\\
else\\\
return e\\\
end\\\
end\\\
if term.isColor and term.isColor()then\\\
local e=nil\\\
if http then\\\
e=true\\\
end\\\
if e==nil then\\\
print=_print\\\
term.setBackgroundColor(colours.grey)\\\
term.setTextColor(colours.white)\\\
term.clear()\\\
term.setCursorPos(3,3)\\\
print(\\\"Could not connect to the App Store server!\\\\n\\\\n\\\")\\\
term.setTextColor(colours.white)\\\
print(\\\"Try the following steps:\\\")\\\
term.setTextColor(colours.lightGrey)\\\
print(' - Ensure you have enabled the HTTP API')\\\
print(' - Check your internet connection is working')\\\
print(' - Retrying again in 10 minutes')\\\
print(' - Get assistance on the forum page')\\\
print()\\\
print()\\\
print()\\\
term.setTextColor(colours.white)\\\
print(\\\" Click anywhere to exit...\\\")\\\
os.pullEvent(\\\"mouse_click\\\")\\\
OneOS.Close()\\\
else\\\
local t,e=pcall(Initialise)\\\
if e then\\\
if string.find(e,'Network error')then\\\
ConnectionError()\\\
else\\\
print=_print\\\
term.setBackgroundColor(colours.lightGrey)\\\
term.setTextColor(colours.white)\\\
term.clear()\\\
term.setBackgroundColor(colours.grey)\\\
term.setCursorPos(1,2)\\\
term.clearLine()\\\
term.setCursorPos(1,3)\\\
term.clearLine()\\\
term.setCursorPos(1,4)\\\
term.clearLine()\\\
term.setCursorPos(3,3)\\\
print(\\\"The ComputerCraft App Store has crashed!\\\\n\\\\n\\\")\\\
term.setBackgroundColour(colours.lightGrey)\\\
print(\\\"Try repeating what you just did, if this is the second time you've seen this message go to\\\")\\\
term.setTextColour(colours.black)\\\
print(\\\"http://ccappstore.com/help#crash/\\\\n\\\")\\\
term.setTextColour(colours.white)\\\
if OneOS then\\\
OneOS.Log.e(tostring(e))\\\
end\\\
print(\\\"The error was:\\\")\\\
term.setTextColour(colours.black)\\\
print(\\\" \\\"..tostring(e)..\\\"\\\\n\\\\n\\\")\\\
term.setTextColour(colours.white)\\\
print(\\\" Click anywhere to exit...\\\")\\\
os.pullEvent(\\\"mouse_click\\\")\\\
if OneOS then\\\
OneOS.Close()\\\
end\\\
term.setTextColour(colours.white)\\\
term.setBackgroundColour(colours.black)\\\
term.clear()\\\
term.setCursorPos(1,1)\\\
end\\\
end\\\
end\\\
else\\\
print('The App Store requires an Advanced (gold) Computer!')\\\
end\",\
    [ \"Programs/Quest Server.program/icon\" ] = \"78--  \\\
0dQst_\\\
0bServ\",\
    [ \"System/Programs/About OneOS.program/logo\" ] = \"0f b    0 \\\
bf      \\\
bf      \\\
0f b    0 \",\
    [ \"System/Images/Icons/settings\" ] = \"08007180\\\
08071180\\\
07180071\",\
    [ \"Desktop/Shell.shortcut\" ] = \"/Programs/Shell.program/\",\
    [ \"Desktop/App Store.shortcut\" ] = \"/Programs/App Store.program/\",\
    [ \"Programs/Quest.program/Objects/FloatView.lua\" ] = \"Inherit = 'View'\\\
IsFloat = true\\\
Align = \\\"Left\\\"\",\
    [ \"System/Images/Icons/program\" ] = \"f4>_   \\\
f4prog\\\
f    \",\
    [ \"System/Objects/ProgramView.lua\" ] = \"UpdateDrawBlacklist = {['CachedProgram']=true, ['CachedIndex']=true}\\\
CachedProgram = false\\\
CachedIndex = false\\\
Animation = false\\\
Ready = false\\\
\\\
OnUpdate = function(self, value)\\\
	--TODO: resize the buffer\\\
	if value == 'Width' then\\\
	end\\\
end\\\
\\\
local function getProgramIndex(program)\\\
	for i, _program in ipairs(Current.Programs) do\\\
		if program == _program then\\\
			return i\\\
		end\\\
	end\\\
	return 1\\\
end\\\
\\\
OnDraw = function(self, x, y)\\\
	local currentIndex = getProgramIndex(Current.Program)\\\
\\\
	if Current.Program == nil and #Current.Programs > 1 then\\\
		if Current.Programs[self.CachedIndex] then\\\
			Current.Program = Current.Programs[self.CachedIndex]\\\
		elseif Current.Programs[self.CachedIndex-1] then\\\
			Current.Program = Current.Programs[self.CachedIndex-1]\\\
		end\\\
	end\\\
\\\
	if not self.Ready and #Current.Programs > 0 then\\\
		self.Ready = true\\\
	end\\\
\\\
	if not self.Animation then\\\
		self.Bedrock.DrawSpeed = self.Bedrock.DefaultDrawSpeed\\\
	end\\\
\\\
	if self.Animation then\\\
		self:DrawAnimation()\\\
	elseif (#Current.Programs == 1 or (Current.Program and Current.Program.Hidden)) and self.CachedProgram and not self.CachedProgram.Hidden then\\\
		--closing a program\\\
		UpdateOverlay()\\\
		local centerX = math.ceil(self.Width / 2)\\\
		local centerY = math.ceil(self.Height / 2)\\\
\\\
		local w = self.Width\\\
		local h = self.Height\\\
		local deltaW = w / 5\\\
		local deltaH = h / 5\\\
\\\
		local colour = colours.white\\\
		if self.CachedProgram.Environment.OneOS.ToolBarColor ~= colours.white then\\\
			colour = self.CachedProgram.Environment.OneOS.ToolBarColor\\\
		elseif self.CachedProgram.Environment.OneOS.ToolBarColour then\\\
			colour = self.CachedProgram.Environment.OneOS.ToolBarColour\\\
		end\\\
\\\
		self.Animation = {\\\
			Count = 5,\\\
			Function = function(i)\\\
				self:DrawProgram(Current.Desktop, x, y)\\\
				self:DrawPreview(self.CachedProgram, x + centerX - (w / 2) - 2, y + centerY - (h / 2), w, h, colour)\\\
				w = w - deltaW\\\
				h = h - deltaH\\\
			end\\\
		}\\\
		self:DrawAnimation()\\\
\\\
		Current.Desktop:SwitchTo()\\\
	elseif Current.Program and not Current.Program.Hidden and self.CachedProgram and self.CachedProgram.Hidden then\\\
		--opening a program\\\
		UpdateOverlay()\\\
		local centerX = math.ceil(self.Width / 2)\\\
		local centerY = math.ceil(self.Height / 2)\\\
\\\
		local deltaW = self.Width / 5\\\
		local deltaH = self.Height / 5\\\
		local w = 0\\\
		local h = 0\\\
		local colour = colours.white\\\
		if Current.Program.Environment.OneOS.ToolBarColor ~= colours.white then\\\
			colour = Current.Program.Environment.OneOS.ToolBarColor\\\
		elseif Current.Program.Environment.OneOS.ToolBarColour then\\\
			colour = Current.Program.Environment.OneOS.ToolBarColour\\\
		end\\\
\\\
		self.Animation = {\\\
			Count = 5,\\\
			Function = function(i)\\\
				self:DrawProgram(Current.Desktop, x, y)\\\
				w = w + deltaW\\\
				h = h + deltaH\\\
				self:DrawPreview(Current.Program, x + centerX - (w / 2) - 2, y + centerY - (h / 2), w, h, colour)\\\
			end\\\
		}\\\
		self:DrawAnimation()\\\
	elseif Current.Program and self.CachedProgram and Current.Program ~= self.CachedProgram and not Current.Program.Hidden and not self.CachedProgram.Hidden then\\\
		--switching program\\\
		UpdateOverlay()\\\
		local direction = 1\\\
		local isPos = 0\\\
		local isNeg = 1\\\
		if getProgramIndex(Current.Program) >= self.CachedIndex then\\\
			direction = -1\\\
			isPos = 1\\\
			isNeg = 0\\\
		end\\\
		local delta = (self.Width + 4) / 5\\\
		self.Animation = {\\\
			Count = 5,\\\
			Function = function(i)\\\
				local offset = x + ((5-i) * delta * direction)\\\
				self:DrawProgram(self.CachedProgram, x + offset - 1, y)\\\
				Drawing.DrawBlankArea(x + offset + isPos * (self.Width) - isNeg * 4 - 1, y, 4, self.Height, colours.black)\\\
				self:DrawProgram(Current.Program, x + offset - isNeg * 2 - direction * (3 + self.Width), y)\\\
			end\\\
		}\\\
		self:DrawAnimation()\\\
	elseif Current.Program then\\\
		if Current.Overlay and self.CachedProgram and self.CachedProgram.Environment and (Current.Program.Environment.OneOS.ToolBarColor ~= Current.Overlay.BackgroundColour or Current.Program.Environment.OneOS.ToolBarColour ~= Current.Overlay.BackgroundColour  or Current.Program.Environment.OneOS.ToolBarTextColor ~= Current.Overlay.TextColour  or Current.Program.Environment.OneOS.ToolBarTextColour ~= Current.Overlay.TextColour) then\\\
			UpdateOverlay()\\\
		end\\\
		self:DrawProgram(Current.Program, x, y)\\\
		self.CachedProgram = Current.Program\\\
		self.CachedIndex = currentIndex\\\
		if self.Bedrock:GetActiveObject() == self then\\\
			if Current.Program.AppRedirect.CursorBlink then\\\
				self.Bedrock.CursorPos = {x + Current.Program.AppRedirect.CursorPos[1] - 1, y + Current.Program.AppRedirect.CursorPos[2] - 1}\\\
				self.Bedrock.CursorColour = Current.Program.AppRedirect.TextColour\\\
			else\\\
				self.Bedrock.CursorPos = nil\\\
			end\\\
		end\\\
	elseif self.Ready then\\\
		Drawing.DrawBlankArea(x, y, self.Width, self.Height, colours.grey)\\\
		Drawing.DrawCharactersCenter(nil,-1,nil,nil, 'Something went wrong :(', colours.white, colours.transparent)\\\
		Drawing.DrawCharactersCenter(nil,1,nil,nil, 'The desktop crashed or something bugged out.', colours.lightGrey, colours.transparent)\\\
		Drawing.DrawCharactersCenter(nil,2,nil,nil, 'Try restarting.', colours.lightGrey, colours.transparent)\\\
	else\\\
		Drawing.DrawBlankArea(x, y, self.Width, self.Height, Settings:GetValues()['DesktopColour'])\\\
	end\\\
end\\\
\\\
DrawAnimation = function(self)\\\
	if Settings:GetValues()['UseAnimations'] then\\\
		self.Animation.Function(self.Animation.Count)\\\
		self.Animation.Count = self.Animation.Count - 1\\\
		if self.Animation.Count <= 0 then\\\
			self.Animation = nil\\\
			self.CachedProgram = Current.Program\\\
			self.CachedIndex = currentIndex\\\
		end\\\
		self:ForceDraw()\\\
	else\\\
		self.Animation = nil\\\
		self.CachedProgram = Current.Program\\\
		self.CachedIndex = currentIndex\\\
		self:ForceDraw()\\\
		self.Bedrock:Draw()\\\
	end\\\
end\\\
\\\
DrawProgram = function(self, program, x, y)\\\
	if program then\\\
		for _y, row in ipairs(program.AppRedirect.Buffer) do\\\
			for _x, pixel in pairs(row) do\\\
				Drawing.WriteToBuffer(x+_x-1, y+_y-1, pixel[1], pixel[2], pixel[3])\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
DrawPreview = function(self, program, x, y, w, h, _colour)\\\
	if program then\\\
		local preview = program:RenderPreview(w, h)\\\
		for _x, col in pairs(preview) do\\\
			for _y, colour in ipairs(col) do\\\
				local char = '-'\\\
				if colour[1] == ' ' then\\\
					char = ' '\\\
				end\\\
				Drawing.WriteToBuffer(x+_x, y+_y-1, char, colour[2], colour[3])\\\
			end\\\
		end\\\
	else\\\
		Drawing.DrawBlankArea(x, y, w, h, colours.red)\\\
	end\\\
end\\\
\\\
OnClick = function(self, event, side, x, y)\\\
	if not self.Bedrock:GetActiveObject() then\\\
		self.Bedrock:SetActiveObject(self)\\\
	end\\\
	\\\
	if Current.Program then\\\
		Current.Program:Click(event, side, x, y)\\\
	end\\\
end\\\
\\\
OnKeyChar = function(self, event, keychar)\\\
	if Current.Program then\\\
		Current.Program:QueueEvent(event, keychar)\\\
	end\\\
end\\\
\\\
OnDrag = OnClick\\\
OnScroll = OnClick\",\
    [ \"System/API/Search.lua\" ] = \"function Open()\\\
	Log.i('Opening search')\\\
	Current.SearchActive = true\\\
	Current.Bedrock:GetObject('ClickCatcherView').Z = 999\\\
	Current.Bedrock:GetObject('ClickCatcherView').Visible = true\\\
	Current.Bedrock:GetObject('SearchTextBox').Text = ''\\\
	Current.Bedrock:GetObject('SearchButton').Toggle = true\\\
	Current.Bedrock:SetActiveObject(Current.Bedrock:GetObject('SearchTextBox'))\\\
	Current.Bedrock:GetObject('SearchView'):UpdateSearch()\\\
	AnimateOpenClose()\\\
end\\\
\\\
function Close()\\\
	Log.i('Closing search')\\\
	Current.SearchActive = false\\\
	Current.Bedrock:GetObject('ClickCatcherView').Z = 1\\\
	Current.Bedrock:GetObject('ClickCatcherView').Visible = false\\\
	Current.Bedrock:GetObject('SearchButton').Toggle = false\\\
	Current.Bedrock:SetActiveObject(Current.ProgramView)\\\
	AnimateOpenClose()\\\
end\\\
\\\
function SetOffset(offset)\\\
	for i, v in ipairs(Current.Bedrock.View.Children) do\\\
		if v.Name ~= 'SearchView' then\\\
			v.X = offset\\\
		end\\\
	end\\\
end\\\
\\\
function AnimateOpenClose()\\\
	local openX = -Current.Bedrock:GetObject('SearchView').Width + 1\\\
	if Settings:GetValues()['UseAnimations'] then\\\
		for i = 1, 5 do\\\
			SetOffset((Current.SearchActive and i * (openX / 5) or 1 + openX - i * (openX / 5)))\\\
			Current.Bedrock:Draw()\\\
			sleep(0.05)\\\
		end\\\
	end\\\
\\\
	if Current.SearchActive then\\\
		SetOffset(openX)\\\
	else\\\
		SetOffset(1)\\\
	end\\\
end\",\
    [ \"System/Programs/Unpackager.program/Icons/pkg\" ] = \"1f cp|f \\\
1f ck|f \\\
1f cg|f \",\
    [ \"System/Images/Boot/boot8\" ] = \"         8888          \\\
        888888         \\\
        888888         \\\
         8888          \\\
                       \\\
                       \\\
                       \\\
77777777777777777777777\",\
    [ \"Programs/Quest.program/Elements/Float.lua\" ] = \"Align = \\\"Left\\\"\\\
\\\
OnInitialise = function(self, node)\\\
	local attr = self.Attributes\\\
	if attr.align then\\\
		if attr.align:lower() == 'left' or attr.align:lower() == 'right' then\\\
			self.Align = attr.align:lower():gsub(\\\"^%l\\\", string.upper)\\\
		end\\\
	end\\\
end\\\
\\\
OnCreateObject = function(self, parentObject, y)\\\
	return {\\\
		Element = self,\\\
		Y = y,\\\
		X = 1,\\\
		Width = self.Width,\\\
		Height = self.Height,\\\
		Align = self.Align,\\\
		BackgroundColour = self.BackgroundColour,\\\
		Type = \\\"FloatView\\\"\\\
	}\\\
end\",\
    [ \"Programs/Quest Server.program/Objects/SettingsView.lua\" ] = \"Inherit = 'View'\",\
    [ \"System/Programs/Desktop.program/Views/main.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
  },\\\
  [\\\"BackgroundColour\\\"]=512\\\
}\",\
    [ \"System/API/Helpers.lua\" ] = \"local IconCache = {}\\\
\\\
function LaunchProgram(path, args, title)\\\
	return Program:Initialise(shell, path, title, args)\\\
end\\\
\\\
OpenFile = function(path, args)\\\
	args = args or {}\\\
	if fs.exists(path) then\\\
		if Current.Bedrock then\\\
			local centrePoint = Current.Bedrock:GetObject('CentrePoint')\\\
			if centrePoint and centrePoint.Visible then\\\
				centrePoint:Hide()\\\
			end\\\
		end\\\
\\\
		local extension = Helpers.Extension(path)\\\
		if extension == 'shortcut' then\\\
			h = fs.open(path, 'r')\\\
			local shortcutPointer = h.readLine()\\\
			local sArgs = h.readLine()\\\
			local tArgs = {}\\\
			if sArgs then\\\
				for match in string.gmatch( sArgs, \\\"[^ \\\\t]+\\\" ) do\\\
					table.insert(tArgs, match)\\\
				end\\\
			end\\\
			h.close()\\\
\\\
			Helpers.OpenFile(shortcutPointer, tArgs)\\\
		elseif extension == 'program' and fs.isDir(path) and fs.exists(path..'/startup') then\\\
			return LaunchProgram(path..'/startup', args, Helpers.RemoveExtension(fs.getName(path)))\\\
		elseif extension == 'program' and not fs.isDir(path) then\\\
			return LaunchProgram(path, args, Helpers.RemoveExtension(fs.getName(path)))\\\
		elseif fs.isDir(path) then\\\
			LaunchProgram('/System/Programs/Files.program/startup', {path}, 'Files')\\\
		elseif extension then\\\
			local _path = Indexer.FindFileInFolder(extension, 'Icons')\\\
			if _path and not _path:find('System/Images/Icons/') then\\\
				Helpers.OpenFile(Helpers.ParentFolder(Helpers.ParentFolder(_path)), {path})\\\
			else\\\
				OpenFileWith(path)\\\
			end\\\
		else\\\
			OpenFileWith(path)\\\
		end\\\
	end\\\
end\\\
\\\
ParentFolder = function(path)\\\
	local folderName = fs.getName(path)\\\
	return path:sub(1, #path-#folderName-1)\\\
end\\\
\\\
ListPrograms = function()\\\
	local programs = {}\\\
\\\
	for i, v in ipairs(fs.list('Programs/')) do\\\
		if string.sub( v, 1, 1 ) ~= '.' then\\\
			table.insert(programs, v)\\\
		end\\\
	end\\\
\\\
	return programs\\\
end\\\
\\\
ReadIcon = function(path, cacheName)\\\
	cacheName = cacheName or path\\\
	if not IconCache[cacheName] then\\\
		IconCache[cacheName] = Drawing.LoadImage(path, true)\\\
	end\\\
	return IconCache[cacheName]\\\
end\\\
\\\
Split = function(str,sep)\\\
    sep=sep or'/'\\\
    return str:match(\\\"(.*\\\"..sep..\\\")\\\")\\\
end\\\
\\\
Extension = function(path, addDot)\\\
	if not path then\\\
		return nil\\\
	elseif not string.find(fs.getName(path), '%.') then\\\
		if not addDot then\\\
			return fs.getName(path)\\\
		else\\\
			return ''\\\
		end\\\
	else\\\
		local _path = path\\\
		if path:sub(#path) == '/' then\\\
			_path = path:sub(1,#path-1)\\\
		end\\\
		local extension = _path:gmatch('%.[0-9a-z]+$')()\\\
		if extension then\\\
			extension = extension:sub(2)\\\
		else\\\
			--extension = nil\\\
			return ''\\\
		end\\\
		if addDot then\\\
			extension = '.'..extension\\\
		end\\\
		return extension:lower()\\\
	end\\\
end\\\
\\\
RemoveExtension = function(path)\\\
	--local name = string.match(fs.getName(path), '(%a+)%.?.-')\\\
	if path:sub(1,1) == '.' then\\\
		return path\\\
	end\\\
	local extension = Helpers.Extension(path)\\\
	if extension == path then\\\
		return fs.getName(path)\\\
	end\\\
	return string.gsub(path, extension, ''):sub(1, -2)\\\
end\\\
\\\
RemoveFileName = function(path)\\\
	if string.sub(path, -1) == '/' then\\\
		path = string.sub(path, 1, -2)\\\
	end\\\
	local v = string.match(path, \\\"(.-)([^\\\\\\\\/]-%.?([^%.\\\\\\\\/]*))$\\\")\\\
	if type(v) == 'string' then\\\
		return v\\\
	end\\\
	return v[1]\\\
end\\\
\\\
IsDirectory = function(path)\\\
	return fs.isDir(path) and Helpers.Extension(path) ~= 'program'\\\
end\\\
\\\
IconForFile = function(path)\\\
	path = TidyPath(path)\\\
	local extension = Helpers.Extension(path)\\\
	if extension and IconCache[extension] then\\\
		return IconCache[extension]\\\
	elseif extension and extension == 'shortcut' then\\\
		h = fs.open(path, 'r')\\\
		if h then\\\
			local shortcutPointer = h.readLine()\\\
			h.close()\\\
			return Helpers.IconForFile(shortcutPointer)\\\
		end\\\
		return ReadIcon('System/Images/Icons/unknown')\\\
	elseif extension and extension == 'program' then\\\
		if fs.isDir(path) and fs.exists(path..'/startup') and fs.exists(path..'/icon') then\\\
			return ReadIcon(path..'/icon')\\\
		elseif not fs.isDir(path) or (fs.isDir(path) and fs.exists(path..'/startup') and not fs.exists(path..'/icon')) then\\\
			return ReadIcon('System/Images/Icons/program')\\\
		else\\\
			return ReadIcon('System/Images/Icons/folder')\\\
		end\\\
	elseif fs.isDir(path) then\\\
		return ReadIcon('System/Images/Icons/folder')\\\
	elseif extension and fs.exists('System/Images/Icons/'..extension) and not fs.isDir('System/Images/Icons/'..extension) then\\\
		return ReadIcon('System/Images/Icons/'..extension)\\\
	elseif extension then\\\
		local _path = Indexer.FindFileInFolder(extension, 'Icons')\\\
		if _path then\\\
			return ReadIcon(_path, extension)\\\
		else\\\
			return ReadIcon('System/Images/Icons/unknown')\\\
		end\\\
	else\\\
		return ReadIcon('System/Images/Icons/unknown')\\\
	end\\\
end\\\
\\\
TruncateString = function(sString, maxLength)\\\
	if #sString > maxLength then\\\
		sString = sString:sub(1,maxLength-3)\\\
		if sString:sub(-1) == ' ' then\\\
			sString = sString:sub(1,maxLength-4)\\\
		end\\\
		sString = sString  .. '...'\\\
	end\\\
	return sString\\\
end\\\
\\\
TruncateStringStart = function(sString, maxLength)\\\
	local len = #sString\\\
	if #sString > maxLength then\\\
		sString = sString:sub(len - maxLength, len - 3)\\\
		if sString:sub(-1) == ' ' then\\\
			sString = sString:sub(len - maxLength, len - 4)\\\
		end\\\
		sString = '...' .. sString\\\
	end\\\
	return sString\\\
end\\\
\\\
WrapText = function(text, maxWidth)\\\
	local lines = {''}\\\
    for word, space in text:gmatch('(%S+)(%s*)') do\\\
            local temp = lines[#lines] .. word .. space:gsub('\\\\n','')\\\
            if #temp > maxWidth then\\\
                    table.insert(lines, '')\\\
            end\\\
            if space:find('\\\\n') then\\\
                    lines[#lines] = lines[#lines] .. word\\\
                    \\\
                    space = space:gsub('\\\\n', function()\\\
                            table.insert(lines, '')\\\
                            return ''\\\
                    end)\\\
            else\\\
                    lines[#lines] = lines[#lines] .. word .. space\\\
            end\\\
    end\\\
	return lines\\\
end\\\
\\\
MakeShortcut = function(path)\\\
	path = TidyPath(path)\\\
	local name = Helpers.RemoveExtension(fs.getName(path))\\\
	local f = fs.open('Desktop/'..name..'.shortcut', 'w')\\\
	f.write(path)\\\
	f.close()\\\
end\\\
\\\
TidyPath = function(path)\\\
	path = '/'..path\\\
	if fs.exists(path) and fs.isDir(path) then\\\
		path = path .. '/'\\\
	end\\\
\\\
	path, n = path:gsub(\\\"//\\\", \\\"/\\\")\\\
	while n > 0 do\\\
		path, n = path:gsub(\\\"//\\\", \\\"/\\\")\\\
	end\\\
	return path\\\
end\\\
\\\
Capitalise = function(str)\\\
	return str:sub(1, 1):upper() .. str:sub(2, -1)\\\
end\\\
\\\
RenameFile = function(path, done, bedrock)\\\
	bedrock = bedrock or Current.Bedrock\\\
	path = TidyPath(path)\\\
	local function showRename()\\\
		local ext = ''\\\
		if fs.getName(path):find('%.') then\\\
			ext = '.'..Extension(path)\\\
		end\\\
		bedrock:DisplayTextBoxWindow('Rename '..fs.getName(path), \\\"Enter the new file name.\\\", function(success, value)\\\
			if success and #value ~= 0 then\\\
				Indexer.RefreshIndex()\\\
				local _, err = pcall(function()fs.move(path, RemoveFileName(path)..value) if done then done() end end)\\\
				if err then\\\
					bedrock:DisplayAlertWindow('Rename Failed!', 'Error: '..err, {'Ok'})\\\
				end\\\
			end\\\
		end, ext, true)\\\
	end\\\
	\\\
	if path == '/startup' or path:find('/System/') or path == '/Desktop/Documents/' or path == '/Desktop/' then\\\
		bedrock:DisplayAlertWindow('Important File!', 'Renaming this file might cause your computer to stop working. Are you sure you want to rename it?', {'Rename', 'Cancel'}, function(text)\\\
			if text == 'Rename' then\\\
				showRename()\\\
			end\\\
		end)\\\
	else\\\
		showRename()\\\
	end\\\
end\\\
\\\
DeleteFile = function(path, done, bedrock)\\\
	bedrock = bedrock or Current.Bedrock\\\
	path = TidyPath(path)\\\
	local function doDelete()\\\
		local _, err = pcall(function()fs.delete(path) Indexer.RefreshIndex() if done then done() end end)\\\
		if err then\\\
			bedrock:DisplayAlertWindow('Delete Failed!', 'Error: '..err, {'Ok'})\\\
		end\\\
	end\\\
	\\\
	if path == '/startup' or path:find('/System/') or path == '/Desktop/Documents/' or path == '/Desktop/' then\\\
		bedrock:DisplayAlertWindow('Important File!', 'Deleting this file might cause your computer to stop working. Are you sure you want to delete it?', {'Delete', 'Cancel'}, function(text)\\\
			if text == 'Delete' then\\\
				doDelete()\\\
			end\\\
		end)\\\
	else\\\
		bedrock:DisplayAlertWindow('Delete File?', 'Are you sure you want to permanently delete this file?', {'Delete', 'Cancel'}, function(text)\\\
			if text == 'Delete' then\\\
				doDelete()\\\
			end\\\
		end)\\\
	end\\\
end\\\
\\\
NewFile = function(basePath, done, bedrock)\\\
	bedrock = bedrock or Current.Bedrock\\\
	basePath = TidyPath(basePath)\\\
	bedrock:DisplayTextBoxWindow('Create New File', \\\"Enter the new file name.\\\", function(success, value)\\\
		if success and #value ~= 0 then\\\
			Indexer.RefreshIndex()\\\
			local _, err = pcall(function()\\\
				local h = fs.open(basePath..value, 'w')\\\
				h.close()\\\
				if done then done() end\\\
			end)\\\
			if err then\\\
				bedrock:DisplayAlertWindow('File Creation Failed!', 'Error: '..err, {'Ok'})\\\
			end\\\
		end\\\
	end)\\\
end\\\
\\\
NewFolder = function(basePath, done, bedrock)\\\
	bedrock = bedrock or Current.Bedrock\\\
	basePath = TidyPath(basePath)\\\
	bedrock:DisplayTextBoxWindow('Create New Folder', \\\"Enter the new folder name.\\\", function(success, value)\\\
		if success and #value ~= 0 then\\\
			Indexer.RefreshIndex()\\\
			local _, err = pcall(function()\\\
				fs.makeDir(basePath..value)\\\
				if done then done() end\\\
			end)\\\
			if err then\\\
				bedrock:DisplayAlertWindow('File Creation Failed!', 'Error: '..err, {'Ok'})\\\
			end\\\
		end\\\
	end)\\\
end\\\
\\\
OpenFileWith = function(path, bedrock)\\\
	bedrock = bedrock or Current.Bedrock\\\
	path = TidyPath(path)\\\
	local text = 'Choose the program you want to open this file with.'\\\
	local height = #Helpers.WrapText(text, 26)\\\
\\\
	local items = {}\\\
\\\
	for i, v in ipairs(fs.list('Programs/')) do\\\
		if string.sub( v, 1, 1 ) ~= '.' then\\\
			table.insert(items, v)\\\
		end\\\
	end\\\
\\\
	local children = {\\\
		{\\\
			[\\\"Y\\\"]=\\\"100%,-1\\\",\\\
			[\\\"X\\\"]=\\\"100%,-5\\\",\\\
			[\\\"Name\\\"]=\\\"OpenButton\\\",\\\
			[\\\"Type\\\"]=\\\"Button\\\",\\\
			[\\\"Text\\\"]=\\\"Open\\\",\\\
			OnClick = function()\\\
				local selected = bedrock.Window:GetObject('ListView').Selected\\\
				if selected then\\\
					OpenFile('Programs/' .. selected.Text, {path})\\\
					bedrock.Window:Close()\\\
				end\\\
			end\\\
		},\\\
		{\\\
			[\\\"Y\\\"]=\\\"100%,-1\\\",\\\
			[\\\"X\\\"]=\\\"100%,-14\\\",\\\
			[\\\"Name\\\"]=\\\"CancelButton\\\",\\\
			[\\\"Type\\\"]=\\\"Button\\\",\\\
			[\\\"Text\\\"]=\\\"Cancel\\\",\\\
			OnClick = function()\\\
				bedrock.Window:Close()\\\
			end\\\
		},\\\
	    {\\\
			[\\\"Y\\\"]=6,\\\
			[\\\"X\\\"]=2,\\\
			[\\\"Height\\\"]=\\\"100%,-8\\\",\\\
			[\\\"Width\\\"]=\\\"100%,-2\\\",\\\
			[\\\"Name\\\"]=\\\"ListView\\\",\\\
			[\\\"Type\\\"]=\\\"ListView\\\",\\\
			[\\\"TextColour\\\"]=128,\\\
			[\\\"BackgroundColour\\\"]=0,\\\
			[\\\"CanSelect\\\"]=true,\\\
			[\\\"Items\\\"]=items,\\\
	    },\\\
	    {\\\
			[\\\"Y\\\"]=2,\\\
			[\\\"X\\\"]=2,\\\
			[\\\"Width\\\"]=\\\"100%,-2\\\",\\\
			[\\\"Height\\\"]=height,\\\
			[\\\"Name\\\"]=\\\"Label\\\",\\\
			[\\\"Type\\\"]=\\\"Label\\\",\\\
			[\\\"Text\\\"]=text\\\
		}\\\
	}\\\
\\\
	local view = {\\\
		Children=children,\\\
		Width=28,\\\
		Height=10+height\\\
	}\\\
	bedrock:DisplayWindow(view, 'Open With')\\\
\\\
end\\\
\\\
LongestString = function(input, key, isKey)\\\
	local length = 0\\\
	if isKey then\\\
		for k, v in pairs(input) do\\\
			local titleLength = string.len(k)\\\
			if titleLength > length then\\\
				length = titleLength\\\
			end\\\
		end\\\
	else\\\
		for i = 1, #input do\\\
			local value = input[i]\\\
			if key then\\\
				if value[key] then\\\
					value = value[key]\\\
				else\\\
					value = ''\\\
				end\\\
			end\\\
			local titleLength = string.len(value)\\\
			if titleLength > length then\\\
				length = titleLength\\\
			end\\\
		end\\\
	end\\\
	return length\\\
end\\\
\\\
Round = function(num, idp)\\\
	local mult = 10^(idp or 0)\\\
	return math.floor(num * mult + 0.5) / mult\\\
end\",\
    [ \"System/Objects/Overlay.lua\" ] = \"Inherit = 'View'\\\
\\\
TextColour = colours.white\\\
BackgroundColour = colours.grey\\\
CenterPointMode = false\\\
\\\
OnDraw = function(self, x, y)\\\
	if self.BackgroundColour then\\\
		Drawing.DrawBlankArea(x, y, self.Width, self.Height, self.BackgroundColour)\\\
	end\\\
end\\\
\\\
OnLoad = function(self)\\\
	self:GetObject('OneButton').OnClick = function(btn)\\\
		-- if btn:ToggleMenu('onemenu') then\\\
\\\
		-- 	self.Bedrock:GetObject('DesktopMenuItem').OnClick = function(itm)\\\
		-- 		Current.Desktop:SwitchTo()\\\
		-- 	end\\\
\\\
		-- 	self.Bedrock:GetObject('AboutMenuItem').OnClick = function(itm)\\\
		-- 		Helpers.OpenFile('System/Programs/About OneOS.program')\\\
		-- 	end\\\
\\\
		-- 	self.Bedrock:GetObject('SettingsMenuItem').OnClick = function(itm)\\\
		-- 		Helpers.OpenFile('System/Programs/Settings.program')\\\
		-- 	end\\\
\\\
		-- 	self.Bedrock:GetObject('UpdateMenuItem').OnClick = function(itm)\\\
		-- 		CheckAutoUpdate(true)\\\
		-- 	end\\\
\\\
		-- 	self.Bedrock:GetObject('RestartMenuItem').OnClick = function(itm)\\\
		-- 		Restart()\\\
		-- 	end\\\
\\\
		-- 	self.Bedrock:GetObject('ShutdownMenuItem').OnClick = function(itm)\\\
		-- 		Shutdown()\\\
		-- 	end\\\
		-- end\\\
		if btn.Toggle then\\\
			self.Bedrock:GetObject('CentrePoint'):Show()\\\
		else\\\
			self.Bedrock:GetObject('CentrePoint'):Hide()\\\
		end\\\
	end\\\
\\\
	self:GetObject('SearchButton').OnClick = function(btn, event, side, x, y, toggle)\\\
		if toggle then\\\
			Search.Open()\\\
		end\\\
	end\\\
\\\
	self:UpdateButtons()\\\
end\\\
\\\
UpdateButtons = function(self, backgroundColour, textColour)\\\
	if self.CenterPointMode then\\\
		self.BackgroundColour = colours.grey\\\
		self.TextColour = colours.white\\\
	elseif Current.Program then\\\
		if Current.Program.Environment.OneOS.ToolBarColor ~= colours.white then\\\
			self.BackgroundColour = Current.Program.Environment.OneOS.ToolBarColor\\\
			Current.Program.Environment.OneOS.ToolBarColour = Current.Program.Environment.OneOS.ToolBarColor\\\
		else\\\
			self.BackgroundColour = Current.Program.Environment.OneOS.ToolBarColour\\\
			Current.Program.Environment.OneOS.ToolBarColor = Current.Program.Environment.OneOS.ToolBarColour\\\
		end\\\
		\\\
		if Current.Program.Environment.OneOS.ToolBarTextColor ~= colours.black then\\\
			self.TextColour = Current.Program.Environment.OneOS.ToolBarTextColor\\\
			Current.Program.Environment.OneOS.ToolBarTextColour = Current.Program.Environment.OneOS.ToolBarTextColor\\\
		else\\\
			self.TextColour = Current.Program.Environment.OneOS.ToolBarTextColour\\\
			Current.Program.Environment.OneOS.ToolBarTextColor = Current.Program.Environment.OneOS.ToolBarTextColour\\\
		end\\\
	else\\\
		self.BackgroundColour = colours.white\\\
		self.TextColour = colours.black\\\
	end\\\
\\\
	for i, v in ipairs(self.Children) do\\\
		if v.TextColour then\\\
			v.TextColour = self.TextColour\\\
		end\\\
	end\\\
\\\
	--TODO: make this more efficient\\\
	self:RemoveObjects('ProgramButton')\\\
\\\
	local x = 6\\\
	for i, program in ipairs(Current.Programs) do\\\
		if program and not program.Hidden then\\\
			local bg = self.BackgroundColour\\\
			local tc = self.TextColour\\\
			local button = ''\\\
			if not self.CenterPointMode and Current.Program and Current.Program == program then\\\
				bg = colours.lightBlue\\\
				tc = colours.white\\\
				button = 'x '\\\
			end\\\
\\\
			local object = self:AddObject({\\\
		      [\\\"Y\\\"]=1,\\\
		      [\\\"X\\\"]=x,\\\
		      [\\\"Name\\\"]=\\\"ProgramButton\\\",\\\
		      [\\\"Type\\\"]=\\\"Button\\\",\\\
		      [\\\"Text\\\"]=button..program.Title,\\\
		      [\\\"TextColour\\\"]=tc,\\\
		      [\\\"BackgroundColour\\\"]=bg\\\
		    })\\\
		    x = x + object.Width\\\
\\\
			object.Program = program\\\
\\\
		    object.OnClick = function(obj, event, side, x, y)\\\
		    	if side == 3 then\\\
		    		obj.Program:Close()\\\
		    	elseif button == 'x ' then\\\
		    		if x == 2 then\\\
		    			obj.Program:Close()\\\
		    		end\\\
		    	else\\\
		    		if self.CenterPointMode then\\\
						self.Bedrock:GetObject('CentrePoint'):Hide()\\\
					end\\\
		    		obj.Program:SwitchTo()\\\
		    	end\\\
				self:UpdateButtons()\\\
		   	end\\\
		end\\\
	end\\\
	if not self.Bedrock.IsDrawing then\\\
		self:ForceDraw()\\\
	end\\\
end\",\
    [ \"Programs/Games/Lasers.program/icon\" ] = \"00  7 0 \\\
70 e   \\\
00  e 0 \",\
    [ \"Programs/Transmit.program/icon\" ] = \"77    \\\
0c\\\\7  c/\\\
0f 14  0f \",\
    [ \"System/Programs/Files.program/images/Monitor\" ] = \"43     \\\
43 f   4 \\\
43 f   4 \\\
43     \",\
    [ \"System/Programs/Desktop.program/Views/filemenu.view\" ] = \"{\\\
  [\\\"Type\\\"]=\\\"Menu\\\",\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Name\\\"]=\\\"OpenMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Open\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Name\\\"]=\\\"Separator\\\",\\\
      [\\\"Type\\\"]=\\\"Separator\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Name\\\"]=\\\"RenameMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Rename...\\\"\\\
    },\\\
    [4]={\\\
      [\\\"Name\\\"]=\\\"DeleteMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Delete...\\\"\\\
    },\\\
    [5]={\\\
      [\\\"Name\\\"]=\\\"Separator\\\",\\\
      [\\\"Type\\\"]=\\\"Separator\\\"\\\
    },\\\
    [6]={\\\
      [\\\"Name\\\"]=\\\"NewFolderMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"New Folder...\\\"\\\
    },\\\
    [7]={\\\
      [\\\"Name\\\"]=\\\"NewFileMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"New File...\\\"\\\
    },\\\
    [8]={\\\
      [\\\"Name\\\"]=\\\"Separator\\\",\\\
      [\\\"Type\\\"]=\\\"Separator\\\"\\\
    },\\\
    [8]={\\\
      [\\\"Name\\\"]=\\\"RefreshMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Refresh\\\"\\\
    },\\\
  },\\\
}\",\
    [ \"Programs/Ink.program/Icons/text\" ] = \"07text\\\
07----\\\
07----\",\
    [ \"Programs/Sketch.program/Icons/nft\" ] = \"4f 3bnft\\\
3f  d  \\\
df    \",\
    [ \"Programs/Quest.program/Elements/Paragraph.lua\" ] = \"Align = \\\"Left\\\"\\\
\\\
OnInitialise = function(self, node)\\\
	local attr = self.Attributes\\\
	self.Text = self.Text or ''\\\
	if attr.align then\\\
		if attr.align:lower() == 'left' or attr.align:lower() == 'center' or attr.align:lower() == 'right' then\\\
			self.Align = attr.align:lower():gsub(\\\"^%l\\\", string.upper)\\\
		end\\\
	end\\\
end\\\
\\\
OnCreateObject = function(self, parentObject, y)\\\
	return {\\\
		Element = self,\\\
		Y = y,\\\
		X = 1,\\\
		Width = self.Width,\\\
		Height = self.Height,\\\
		Align = self.Align,\\\
		Type = \\\"Label\\\",\\\
		Text = self.Text,\\\
		TextColour = self.TextColour,\\\
		BackgroundColour = self.BackgroundColour,\\\
		OnUpdate = function(_self, value)\\\
		    if value == 'Text' then\\\
		        if not self.Attributes.height then\\\
            		_self.Height = #_self.Bedrock.Helpers.WrapText(_self.Text, _self.Width)\\\
					_self.Bedrock:GetObject('WebView'):RepositionLayout()\\\
		        end\\\
		    end\\\
		end\\\
	}\\\
end\",\
    [ \"Programs/Quest.program/Elements/Center.lua\" ] = \"OnCreateObject = function(self, parentObject, y)\\\
	return {\\\
		Element = self,\\\
		Y = y,\\\
		X = 1,\\\
		Width = \\\"100%\\\",\\\
		Height = self.Height,\\\
		BackgroundColour = self.BackgroundColour,\\\
		Type = \\\"CenterView\\\"\\\
	}\\\
end\",\
    [ \"System/Programs/First Setup.program/Views/toolbar.view\" ] = \"{\\\
  [\\\"Width\\\"]=\\\"100%\\\",\\\
  [\\\"Height\\\"]=3,\\\
  [\\\"Type\\\"]=\\\"View\\\",\\\
  [\\\"BackgroundColour\\\"] = 128,\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=2,\\\
      [\\\"Name\\\"]=\\\"OneOSLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"OneOS\\\",\\\
      [\\\"TextColour\\\"]=1\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=8,\\\
      [\\\"Name\\\"]=\\\"SetupLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Setup\\\",\\\
      [\\\"TextColour\\\"]=256\\\
    },\\\
  },\\\
}\",\
    [ \"Programs/Transmit.program/Images/disabled\" ] = \"ef  7      e  \\\
 f 7 e     e  7   \\\
7f    7 e  7    7 \\\
 f  e     e     \\\
ef     7     e  \",\
    [ \"Programs/Quest.program/lQuery\" ] = \"function fn(selector)\\\
	if not selector then\\\
	else\\\
		local elements = lQuery.webView:ResolveElements(selector)\\\
		local function relayout()\\\
			lQuery.webView:RepositionLayout()\\\
		end\\\
		if elements and #elements > 0 then\\\
			local each = function(func)\\\
				for i, v in ipairs(elements) do\\\
					func(v, i)\\\
				end\\\
			end\\\
\\\
			local response = {\\\
				text = function(text)\\\
					each(function(elem)\\\
						if elem.Text then\\\
							elem.Text = tostring(text)\\\
						end\\\
					end)\\\
				end,\\\
\\\
				width = function(width)\\\
					if type(width) == 'number' then\\\
						each(function(elem)\\\
							elem.Width = width\\\
						end)\\\
						relayout()\\\
					end\\\
				end,\\\
\\\
				height = function(height)\\\
					if type(height) == 'number' then\\\
						each(function(elem)\\\
							elem.Height = height\\\
						end)\\\
						relayout()\\\
					end\\\
				end,\\\
\\\
				colour = function(colour)\\\
					if type(colour) == 'number' then\\\
						each(function(elem)\\\
							if elem.TextColour then\\\
								elem.TextColour = colour\\\
							end\\\
						end)\\\
					end\\\
				end,\\\
\\\
				bgcolour = function(bgcolour)\\\
					if type(bgcolour) == 'number' then\\\
						each(function(elem)\\\
							if elem.BackgroundColour then\\\
								elem.BackgroundColour = bgcolour\\\
							end\\\
						end)\\\
					end\\\
				end,\\\
\\\
				align = function(align)\\\
					if type(align) == 'string' and align:lower() == 'left' or align:lower() == 'center' or align:lower() == 'right'  then\\\
						each(function(elem)\\\
							if elem.Align then\\\
								elem.Align = align:lower():gsub(\\\"^%l\\\", string.upper)\\\
							end\\\
						end)\\\
					end\\\
				end,\\\
\\\
				attr = function(name)\\\
					local values = {}\\\
					each(function(elem)\\\
						if elem.Element.Attributes and elem.Element.Attributes[name] then\\\
							table.insert(values, elem.Element.Attributes[name])\\\
						end\\\
					end)\\\
					return values\\\
				end,\\\
\\\
				remove = function()\\\
					each(function(elem)\\\
						lQuery.webView:RemoveElement(elem)\\\
						relayout()\\\
					end)\\\
				end,\\\
\\\
				focus = function()\\\
					each(function(elem)\\\
						elem.Bedrock:SetActiveObject(elem)\\\
					end)\\\
				end\\\
			}\\\
			response.color = response.colour\\\
			response.bgcolor = response.bgcolour\\\
\\\
			return response\\\
		end\\\
	end\\\
end\",\
    [ \"Programs/Quest.program/Elements/Image.lua\" ] = \"URL = nil\\\
Format = nil\\\
\\\
OnInitialise = function(self, node)\\\
	local attr = self.Attributes\\\
	if attr.src then\\\
		self.URL = attr.src\\\
	end\\\
\\\
	if attr.type then\\\
		self.Format = attr.type\\\
	end\\\
\\\
	if attr.height then\\\
		self.Height = attr.height\\\
	end\\\
\\\
	if attr.width then\\\
		self.Width = attr.width\\\
	end\\\
end\\\
\\\
OnCreateObject = function(self, parentObject, y)\\\
	return {\\\
		Element = self,\\\
		Y = y,\\\
		X = 1,\\\
		Width = self.Width,\\\
		Height = self.Height,\\\
		URL = self.URL,\\\
		Format = self.Format,\\\
		Type = \\\"WebImageView\\\"\\\
	}\\\
end\",\
    [ \"Programs/Quest.program/Elements/Link.lua\" ] = \"Align = 'Left'\\\
Width = \\\"100%\\\"\\\
TextColour = colours.blue\\\
UnderlineColour = nil\\\
UnderlineVisible = true\\\
URL = nil\\\
\\\
OnInitialise = function(self, node)\\\
	local attr = self.Attributes\\\
	if attr.href then\\\
		self.URL = attr.href\\\
	end\\\
	\\\
	if attr.ulcolour then\\\
		if attr.ulcolour == 'none' then\\\
			self.UnderlineVisible = false\\\
		else\\\
			self.UnderlineColour = self:ParseColour(attr.ulcolour)\\\
		end\\\
	elseif attr.ulcolor then\\\
		if attr.ulcolor == 'none' then\\\
			self.UnderlineVisible = false\\\
		else\\\
			self.UnderlineColour = self:ParseColour(attr.ulcolor)\\\
		end\\\
	end\\\
\\\
	if attr.align then\\\
		if attr.align:lower() == 'left' or attr.align:lower() == 'center' or attr.align:lower() == 'right' then\\\
			self.Align = attr.align:lower():gsub(\\\"^%l\\\", string.upper)\\\
		end\\\
	end\\\
end\\\
\\\
OnCreateObject = function(self, parentObject, y)\\\
	return {\\\
		Element = self,\\\
		Y = y,\\\
		X = 1,\\\
		Width = self.Width,\\\
		Align = self.Align,\\\
		Type = \\\"LinkView\\\",\\\
		Text = self.Text,\\\
		TextColour = self.TextColour,\\\
		UnderlineColour = self.UnderlineColour,\\\
		BackgroundColour = self.BackgroundColour,\\\
		URL = resolveFullUrl(self.URL),\\\
		UnderlineVisible = self.UnderlineVisible\\\
	}\\\
end\",\
    [ \"Programs/Quest.program/Views/optionsmenu.view\" ] = \"{\\\
  [\\\"Type\\\"]=\\\"Menu\\\",\\\
  [\\\"Owner\\\"]=\\\"OptionsButton\\\",\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Name\\\"]=\\\"StopMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Stop\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Name\\\"]=\\\"ReloadMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Reload\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Name\\\"]=\\\"GoHomeMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Go Home\\\"\\\
    },\\\
    [4]={\\\
      [\\\"Name\\\"]=\\\"SetHomeMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Set Home\\\"\\\
    },\\\
    [5]={\\\
      [\\\"Name\\\"]=\\\"Separator\\\",\\\
      [\\\"Type\\\"]=\\\"Separator\\\"\\\
    },\\\
    [6]={\\\
      [\\\"Name\\\"]=\\\"QuitMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Quit\\\"\\\
    }\\\
  },\\\
}\",\
    [ \"Programs/Quest.program/Objects/WebImageView.lua\" ] = \"URL = false\\\
Image = false\\\
\\\
OnDraw = function(self, x, y)\\\
	if not self.Image then\\\
		Drawing.DrawBlankArea(x, y, self.Width, self.Height, colours.lightGrey)\\\
	elseif self.Format == 'nft' then\\\
		Drawing.DrawImage(x, y, self.Image, self.Width, self.Height)\\\
	elseif self.Format == 'nfp' or self.Format == 'paint' then\\\
		for _x, col in ipairs(self.Image) do\\\
			for _y, colour in ipairs(col) do\\\
	            Drawing.WriteToBuffer(x+_x-1, y+_y-1, ' ', colours.white, colour)\\\
			end\\\
		end\\\
	elseif self.Format == 'skch' or self.Format == 'sketch' then\\\
		Drawing.DrawImage(x, y, self.Image, self.Width, self.Height)\\\
	end\\\
end\\\
\\\
OnUpdate = function(self, value)\\\
	if value == 'URL' and self.URL then\\\
		fetchHTTPAsync(resolveFullUrl(self.URL), function(ok, event, response)\\\
			if ok then\\\
				local width, height = self.Width, self.Height\\\
\\\
				local lines = {}\\\
				for line in response.readLine do\\\
					table.insert(lines, line)\\\
				end\\\
				response.close()\\\
				local content = table.concat(lines, '\\\\n')\\\
\\\
				if not self.Format then\\\
					self.Format = self:DetermineFormat(content)\\\
				end\\\
\\\
				if self.Format == 'nft' then\\\
					self.Image, self.Width, self.Height = self:ReadNFT(lines)\\\
				elseif self.Format == 'nfp' or self.Format == 'paint' then\\\
					self.Image, self.Width, self.Height = self:ReadNFP(lines)\\\
				elseif self.Format == 'skch' or self.Format == 'sketch' then\\\
					self.Image, self.Width, self.Height = self:ReadSKCH(content)\\\
				end\\\
				if (width ~= self.Width or height ~= self.Height) then\\\
					self.Bedrock:GetObject('WebView'):RepositionLayout()\\\
				end\\\
			end\\\
		end)\\\
	end\\\
end\\\
\\\
DetermineFormat = function(self, content)\\\
	if type(textutils.unserialize(content)) == 'table' then\\\
		-- It's a serlized table, asume sketch\\\
		return 'skch'\\\
	elseif string.find(content, string.char(30)) or string.find(content, string.char(31)) then\\\
		-- Contains the characters that set colours, asume nft\\\
		return 'nft'\\\
	else\\\
		-- Otherwise asume nfp\\\
		return 'nfp'\\\
	end\\\
end\\\
\\\
ReadSKCH = function(self, content)\\\
	local _layers = textutils.unserialize(content)\\\
	local layers = {}\\\
\\\
	local width, height = 1, 1\\\
\\\
	for i, layer in ipairs(_layers) do\\\
		if layer.Visible then\\\
			local nft, w, h = self:ReadNFT(layer.Pixels)\\\
			if w > width then\\\
				width = w\\\
			end\\\
			if h > height then\\\
				height = h\\\
			end\\\
			table.insert(layers, nft)\\\
		end\\\
	end\\\
\\\
	--flatten the layers\\\
	local image = {\\\
		text = {},\\\
		textcol = {}\\\
	}\\\
\\\
	for i, layer in ipairs(layers) do\\\
		for y, row in ipairs(layer) do\\\
			if not image[y] then\\\
				image[y] = {}\\\
			end\\\
			for x, pixel in ipairs(row) do\\\
				if not image[y][x] or pixel ~= colours.transparent then\\\
					image[y][x] = pixel\\\
				end\\\
			end\\\
		end\\\
		for y, row in ipairs(layer.text) do\\\
			if not image.text[y] then\\\
				image.text[y] = {}\\\
			end\\\
			for x, pixel in ipairs(row) do\\\
				if not image.text[y][x] or pixel ~= ' ' then\\\
					image.text[y][x] = pixel\\\
				end\\\
			end\\\
		end\\\
		for y, row in ipairs(layer.textcol) do\\\
			if not image.textcol[y] then\\\
				image.textcol[y] = {}\\\
			end\\\
			for x, pixel in ipairs(row) do\\\
				if not image.textcol[y][x] or layer.text[y][x] ~= ' ' then\\\
					image.textcol[y][x] = pixel\\\
				end\\\
			end\\\
		end\\\
	end\\\
\\\
	return image, width, height\\\
end\\\
\\\
local function getColourOf(hex)\\\
	if hex == ' ' then\\\
		return colours.transparent\\\
	end\\\
    local value = tonumber(hex, 16)\\\
    if not value then return nil end\\\
    value = math.pow(2,value)\\\
    return value\\\
end\\\
\\\
ReadNFP = function(self, lines)\\\
	local image = {}\\\
	local y = 1\\\
	for y, line in ipairs(lines) do\\\
		for x = 1, #line do\\\
			if not image[x] then\\\
				image[x] = {}\\\
			end\\\
			image[x][y] = getColourOf(line:sub(x,x))\\\
		end\\\
		line = file.readLine()\\\
	end\\\
	file.close()\\\
 	return image, #image, #image[1]\\\
end\\\
\\\
ReadNFT = function(self, lines)\\\
	local image = {\\\
		text = {},\\\
		textcol = {}\\\
	}\\\
	for num, sLine in ipairs(lines) do\\\
        table.insert(image, num, {})\\\
        table.insert(image.text, num, {})\\\
        table.insert(image.textcol, num, {})\\\
        local writeIndex = 1\\\
        local bgNext, fgNext = false, false\\\
        local currBG, currFG = nil,nil\\\
        for i=1,#sLine do\\\
                local nextChar = string.sub(sLine, i, i)\\\
                if nextChar:byte() == 30 then\\\
                        bgNext = true\\\
                elseif nextChar:byte() == 31 then\\\
                        fgNext = true\\\
                elseif bgNext then\\\
                        currBG = Drawing.GetColour(nextChar)\\\
	                    if currBG == nil then\\\
	                    	currBG = colours.transparent\\\
	                    end\\\
                        bgNext = false\\\
                elseif fgNext then\\\
                        currFG = Drawing.GetColour(nextChar)\\\
	                    if currFG == nil or currFG == colours.transparent then\\\
	                    	currFG = colours.white\\\
	                    end\\\
                        fgNext = false\\\
                else\\\
                        if nextChar ~= \\\" \\\" and currFG == nil then\\\
                                currFG = colours.white\\\
                        end\\\
                        image[num][writeIndex] = currBG\\\
                        image.textcol[num][writeIndex] = currFG\\\
                        image.text[num][writeIndex] = nextChar\\\
                        writeIndex = writeIndex + 1\\\
                end\\\
        end\\\
    end\\\
 	return image, #image[1], #image\\\
end\",\
    [ \"Programs/Quest.program/Pages/1.ccml\" ] = \"<!DOCTYPE ccml>\\\
<html>\\\
	<head>\\\
	  <title>Failed to Download Page</title>\\\
	</head>\\\
	<body>\\\
		<br/>\\\
		<br/>\\\
		<h colour=\\\"red\\\">Failed to Download Page</h>\\\
		<br/>\\\
		<center>\\\
			<br>\\\
			<p width=\\\"38\\\" align=\\\"center\\\">The page you requested failed to download. The page may not exist, the server may be experiencing problems or you have connection issues.</p>\\\
		</center>\\\
	</body>\\\
</html>\",\
    [ \"Programs/Quest.program/Elements/Divider.lua\" ] = \"Char = nil\\\
\\\
OnInitialise = function(self, node)\\\
	local attr = self.Attributes\\\
	self.Text = self.Text or ''\\\
	if attr.char then\\\
		if #attr.char == 1 then\\\
			self.Char = attr.char\\\
		end\\\
	end\\\
end\\\
\\\
OnCreateObject = function(self, parentObject, y)\\\
	return {\\\
		Element = self,\\\
		Y = y,\\\
		X = 1,\\\
		Width = self.Width,\\\
		Height = self.Height,\\\
		BackgroundColour = self.BackgroundColour,\\\
		TextColour = self.TextColour,\\\
		Type = \\\"DividerView\\\",\\\
		Char = self.Char\\\
	}\\\
end\",\
    [ \"Programs/Quest.program/parser\" ] = \"--[[\\\
    This API was not created by myself, it was copied from https://github.com/voidfiles/webscript-lua-modules/tree/master/html\\\
\\\
    It has been modified slightly to be more suitable for CCML (removed unused tags, cleaned up returned table a little, etc)\\\
\\\
    Original License:\\\
\\\
    Copyright (c) 2007 T. Kobayashi\\\
\\\
    Permission is hereby granted, free of charge, to any person obtaining a \\\
    copy of this software and associated documentation files (the \\\
    \\\"Software\\\"), to deal in the Software without restriction, including \\\
    without limitation the rights to use, copy, modify, merge, publish, \\\
    distribute, sublicense, and/or sell copies of the Software, and to \\\
    permit persons to whom the Software is furnished to do so, subject to \\\
    the following conditions: \\\
\\\
    The above copyright notice and this permission notice shall be included \\\
    in all copies or substantial portions of the Software. \\\
\\\
    THE SOFTWARE IS PROVIDED \\\"AS IS\\\", WITHOUT WARRANTY OF ANY KIND, EXPRESS \\\
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF \\\
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. \\\
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY \\\
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, \\\
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE \\\
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. \\\
\\\
]]\\\
\\\
entity = {\\\
  nbsp = \\\" \\\",\\\
  lt = \\\"<\\\",\\\
  gt = \\\">\\\",\\\
  quot = \\\"\\\\\\\"\\\",\\\
  amp = \\\"&\\\",\\\
}\\\
\\\
-- keep unknown entity as is\\\
setmetatable(entity, {\\\
  __index = function (t, key)\\\
    return \\\"&\\\" .. key .. \\\";\\\"\\\
  end\\\
})\\\
\\\
block = {\\\
  \\\"address\\\",\\\
  \\\"blockquote\\\",\\\
  \\\"center\\\",\\\
  \\\"dir\\\", \\\"div\\\", \\\"dl\\\",\\\
  \\\"fieldset\\\", \\\"form\\\",\\\
  \\\"h\\\", \\\"h1\\\", \\\"h2\\\", \\\"h3\\\", \\\"h4\\\", \\\"h5\\\", \\\"h6\\\", \\\"hr\\\", \\\
  \\\"isindex\\\",\\\
  \\\"menu\\\",\\\
  \\\"noframes\\\",\\\
  \\\"ol\\\",\\\
  \\\"p\\\",\\\
  \\\"pre\\\",\\\
  \\\"table\\\",\\\
  \\\"ul\\\",\\\
}\\\
\\\
inline = {\\\
  \\\"a\\\", \\\"abbr\\\", \\\"acronym\\\", \\\"applet\\\",\\\
  \\\"b\\\", \\\"basefont\\\", \\\"bdo\\\", \\\"big\\\", \\\"br\\\", \\\"button\\\",\\\
  \\\"cite\\\", \\\"code\\\",\\\
  \\\"dfn\\\",\\\
  \\\"em\\\",\\\
  \\\"font\\\",\\\
  \\\"i\\\", \\\"iframe\\\", \\\"img\\\", \\\"input\\\",\\\
  \\\"kbd\\\",\\\
  \\\"label\\\",\\\
  \\\"map\\\",\\\
  \\\"object\\\",\\\
  \\\"q\\\",\\\
  \\\"s\\\", \\\"samp\\\", \\\"select\\\", \\\"small\\\", \\\"span\\\", \\\"strike\\\", \\\"strong\\\", \\\"sub\\\", \\\"sup\\\",\\\
  \\\"textarea\\\", \\\"tt\\\",\\\
  \\\"u\\\",\\\
  \\\"var\\\",\\\
}\\\
\\\
tags = {\\\
  a = { empty = false },\\\
  abbr = {empty = false} ,\\\
  acronym = {empty = false} ,\\\
  address = {empty = false} ,\\\
  applet = {empty = false} ,\\\
  area = {empty = true} ,\\\
  b = {empty = false} ,\\\
  base = {empty = true} ,\\\
  basefont = {empty = true} ,\\\
  bdo = {empty = false} ,\\\
  big = {empty = false} ,\\\
  blockquote = {empty = false} ,\\\
  body = { empty = false, },\\\
  br = {empty = true} ,\\\
  button = {empty = false} ,\\\
  caption = {empty = false} ,\\\
  center = {empty = false} ,\\\
  cite = {empty = false} ,\\\
  code = {empty = false} ,\\\
  col = {empty = true} ,\\\
  colgroup = {\\\
    empty = false,\\\
    optional_end = true,\\\
    child = {\\\"col\\\",},\\\
  },\\\
  dd = {empty = false} ,\\\
  del = {empty = false} ,\\\
  dfn = {empty = false} ,\\\
  dir = {empty = false} ,\\\
  div = {empty = false} ,\\\
  dl = {empty = false} ,\\\
  dt = {\\\
    empty = false,\\\
    optional_end = true,\\\
    child = {\\\
      inline,\\\
      \\\"del\\\",\\\
      \\\"ins\\\",\\\
      \\\"noscript\\\",\\\
      \\\"script\\\",\\\
    },\\\
  },\\\
  em = {empty = false} ,\\\
  fieldset = {empty = false} ,\\\
  font = {empty = false} ,\\\
  form = {empty = false} ,\\\
  frame = {empty = true} ,\\\
  frameset = {empty = false} ,\\\
  h1 = {empty = false} ,\\\
  h2 = {empty = false} ,\\\
  h3 = {empty = false} ,\\\
  h4 = {empty = false} ,\\\
  h5 = {empty = false} ,\\\
  h6 = {empty = false} ,\\\
  head = {empty = false} ,\\\
  hr = {empty = true} ,\\\
  html = {empty = false} ,\\\
  i = {empty = false} ,\\\
  iframe = {empty = false} ,\\\
  img = {empty = true} ,\\\
  input = {empty = true} ,\\\
  ins = {empty = false} ,\\\
  isindex = {empty = true} ,\\\
  kbd = {empty = false} ,\\\
  label = {empty = false} ,\\\
  legend = {empty = false} ,\\\
  li = {\\\
    empty = false,\\\
    optional_end = true,\\\
    child = {\\\
      inline,\\\
      block,\\\
      \\\"del\\\",\\\
      \\\"ins\\\",\\\
      \\\"noscript\\\",\\\
      \\\"script\\\",\\\
    },\\\
  },\\\
  link = {empty = true} ,\\\
  map = {empty = false} ,\\\
  menu = {empty = false} ,\\\
  meta = {empty = true} ,\\\
  noframes = {empty = false} ,\\\
  noscript = {empty = false} ,\\\
  object = {empty = false} ,\\\
  ol = {empty = false} ,\\\
  optgroup = {empty = false} ,\\\
  option = {\\\
    empty = false,\\\
    optional_end = true,\\\
    child = {},\\\
  },\\\
  p = {\\\
    empty = false,\\\
    optional_end = true,\\\
    child = {\\\
      inline,\\\
      \\\"del\\\",\\\
      \\\"ins\\\",\\\
      \\\"noscript\\\",\\\
      \\\"script\\\",\\\
    },\\\
  } ,\\\
  param = {empty = true} ,\\\
  pre = {empty = false} ,\\\
  q = {empty = false} ,\\\
  s =  {empty = false} ,\\\
  samp = {empty = false} ,\\\
  script = {empty = false} ,\\\
  select = {empty = false} ,\\\
  small = {empty = false} ,\\\
  span = {empty = false} ,\\\
  strike = {empty = false} ,\\\
  strong = {empty = false} ,\\\
  style = {empty = false} ,\\\
  sub = {empty = false} ,\\\
  sup = {empty = false} ,\\\
  table = {empty = false} ,\\\
  tbody = {empty = false} ,\\\
  td = {\\\
    empty = false,\\\
    optional_end = true,\\\
    child = {\\\
      inline,\\\
      block,\\\
      \\\"del\\\",\\\
      \\\"ins\\\",\\\
      \\\"noscript\\\",\\\
      \\\"script\\\",\\\
    },\\\
  },\\\
  textarea = {empty = false} ,\\\
  tfoot = {\\\
    empty = false,\\\
    optional_end = true,\\\
    child = {\\\"tr\\\",},\\\
  },\\\
  th = {\\\
    empty = false,\\\
    optional_end = true,\\\
    child = {\\\
      inline,\\\
      block,\\\
      \\\"del\\\",\\\
      \\\"ins\\\",\\\
      \\\"noscript\\\",\\\
      \\\"script\\\",\\\
    },\\\
  },\\\
  thead = {\\\
    empty = false,\\\
    optional_end = true,\\\
    child = {\\\"tr\\\",},\\\
  },\\\
  title = {empty = false} ,\\\
  tr = {\\\
    empty = false,\\\
    optional_end = true,\\\
    child = {\\\
      \\\"td\\\", \\\"th\\\",\\\
    },\\\
  },\\\
  tt = {empty = false} ,\\\
  u = {empty = false} ,\\\
  ul = {empty = false} ,\\\
  var = {empty = false} ,\\\
}\\\
\\\
setmetatable(tags, {\\\
  __index = function (t, key)\\\
    return {empty = false}\\\
  end\\\
})\\\
\\\
-- string buffer implementation\\\
function newbuf ()\\\
  local buf = {\\\
    _buf = {},\\\
    clear =   function (self) self._buf = {}; return self end,\\\
    content = function (self) return table.concat(self._buf) end,\\\
    append =  function (self, s)\\\
      self._buf[#(self._buf) + 1] = s\\\
      return self\\\
    end,\\\
    set =     function (self, s) self._buf = {s}; return self end,\\\
  }\\\
  return buf\\\
end\\\
\\\
-- unescape character entities\\\
function unescape (s)\\\
  function entity2string (e)\\\
    return entity[e]\\\
  end\\\
  return s.gsub(s, \\\"&(#?%w+);\\\", entity2string)\\\
end\\\
\\\
-- iterator factory\\\
function makeiter (f)\\\
  local co = coroutine.create(f)\\\
  return function ()\\\
    local code, res = coroutine.resume(co)\\\
    return res\\\
  end\\\
end\\\
\\\
-- constructors for token\\\
function Tag (s) \\\
  return string.find(s, \\\"^</\\\") and\\\
    {type = \\\"End\\\",   value = s} or\\\
    {type = \\\"Start\\\", value = s}\\\
end\\\
\\\
function Text (s)\\\
  local unescaped = unescape(s) \\\
  return {type = \\\"Text\\\", value = unescaped} \\\
end\\\
\\\
-- lexer: text mode\\\
function text (f, buf)\\\
  local c = f:read(1)\\\
  if c == \\\"<\\\" then\\\
    if buf:content() ~= \\\"\\\" then coroutine.yield(Text(buf:content())) end\\\
    buf:set(c)\\\
    return tag(f, buf)\\\
  elseif c then\\\
    buf:append(c)\\\
    return text(f, buf)\\\
  else\\\
    if buf:content() ~= \\\"\\\" then coroutine.yield(Text(buf:content())) end\\\
  end\\\
end\\\
\\\
-- lexer: tag mode\\\
function tag (f, buf)\\\
  local c = f:read(1)\\\
  if c == \\\">\\\" then\\\
    coroutine.yield(Tag(buf:append(c):content()))\\\
    buf:clear()\\\
    return text(f, buf)\\\
  elseif c then\\\
    buf:append(c)\\\
    return tag(f, buf)\\\
  else\\\
    if buf:content() ~= \\\"\\\" then coroutine.yield(Tag(buf:content())) end\\\
  end\\\
end\\\
\\\
function parse_starttag(tag)\\\
  local tagname = string.match(tag, \\\"<%s*(%w+)\\\")\\\
  local elem = {_attr = {}}\\\
  elem._tag = tagname\\\
  for key, _, val in string.gmatch(tag, \\\"(%w+)%s*=%s*([\\\\\\\"'])(.-)%2\\\", i) do\\\
    local unescaped = unescape(val)\\\
    elem._attr[key] = unescaped\\\
  end\\\
  return elem\\\
end\\\
\\\
function parse_endtag(tag)\\\
  local tagname = string.match(tag, \\\"<%s*/%s*(%w+)\\\")\\\
  return tagname\\\
end\\\
\\\
-- find last element that satisfies given predicate\\\
function rfind(t, pred)\\\
  local length = #t\\\
  for i=length,1,-1 do\\\
    if pred(t[i]) then\\\
      return i, t[i]\\\
    end\\\
  end\\\
end\\\
\\\
function flatten(t, acc)\\\
  acc = acc or {}\\\
  for i,v in ipairs(t) do\\\
    if type(v) == \\\"table\\\" then\\\
      flatten(v, acc)\\\
    else\\\
      acc[#acc + 1] = v\\\
    end\\\
  end\\\
  return acc\\\
end\\\
\\\
function optional_end_p(elem)\\\
  if tags[elem._tag].optional_end then\\\
    return true\\\
  else\\\
    return false\\\
  end\\\
end\\\
\\\
function valid_child_p(child, parent)\\\
  local schema = tags[parent._tag].child\\\
  if not schema then return true end\\\
\\\
  for i,v in ipairs(flatten(schema)) do\\\
    if v == child._tag then\\\
      return true\\\
    end\\\
  end\\\
\\\
  return false\\\
end\\\
\\\
-- tree builder\\\
function parse(f)\\\
  local root = {_tag = \\\"#document\\\", _attr = {}}\\\
  local stack = {root}\\\
  for i in makeiter(function () return text(f, newbuf()) end) do\\\
    if i.type == \\\"Start\\\" then\\\
      local new = parse_starttag(i.value)\\\
      local top = stack[#stack]\\\
\\\
      while\\\
        top._tag ~= \\\"#document\\\" and \\\
        optional_end_p(top) and\\\
        not valid_child_p(new, top)\\\
      do\\\
        stack[#stack] = nil \\\
        top = stack[#stack]\\\
      end\\\
\\\
      top[#top+1] = new -- appendchild\\\
      if not tags[new._tag].empty then \\\
        stack[#stack+1] = new -- push\\\
      end\\\
    elseif i.type == \\\"End\\\" then\\\
      local tag = parse_endtag(i.value)\\\
      local openingpos = rfind(stack, function(v) \\\
          if v._tag == tag then\\\
            return true\\\
          else\\\
            return false\\\
          end\\\
        end)\\\
      if openingpos then\\\
        local length = #stack\\\
        for j=length,openingpos,-1 do\\\
          table.remove(stack, j)\\\
        end\\\
      end\\\
    else -- Text\\\
        if #string.gsub(string.gsub(i.value, \\\"%s+\\\", \\\"\\\"), '\\\\n', '') ~= 0 then\\\
            local top = stack[#stack]\\\
            top[#top+1] = i.value\\\
        end\\\
    end\\\
  end\\\
  return root\\\
end\\\
\\\
function parsestr(s)\\\
  local handle = {\\\
    _content = s,\\\
    _pos = 1,\\\
    read = function (self, length)\\\
      if self._pos > string.len(self._content) then return end\\\
      local ret = string.sub(self._content, self._pos, self._pos + length - 1)\\\
      self._pos = self._pos + length\\\
      return ret\\\
    end\\\
  }\\\
  return parse(handle)\\\
end\",\
    [ \"Programs/Quest.program/Objects/LinkView.lua\" ] = \"Inherit = 'View'\\\
Height = 2\\\
UnderlineColour = colours.blue\\\
UnderlineVisible = true\\\
\\\
OnLoad = function(self)\\\
	if self.Text and #self.Text > 0 then\\\
		self:AddObject({\\\
			Y = 1,\\\
			X = 1,\\\
			Width = self.Width,\\\
			Align = self.Align,\\\
			Type = \\\"Label\\\",\\\
			Text = self.Text,\\\
			TextColour = self.TextColour,\\\
			BackgroundColour = self.BackgroundColour\\\
		})\\\
	end\\\
end\\\
\\\
OnRecalculateStart = function(self)\\\
	self:RemoveObject('UnderlineLabel')\\\
end\\\
\\\
OnRecalculateEnd = function(self, currentY)\\\
	if self.UnderlineVisible then\\\
		local underline = ''\\\
		local len = self.Width\\\
		if self.Text then\\\
			len = #self.Text\\\
		end\\\
\\\
		for i = 1, len do\\\
			underline = underline .. '-'\\\
		end\\\
		local col = self.UnderlineColour\\\
		if self.UnderlineColour == nil then\\\
			col = self.TextColour\\\
		end\\\
\\\
		local ul = self:AddObject({\\\
			Y = currentY,\\\
			X = 1,\\\
			Width = self.Width,\\\
			Align = self.Align,\\\
			Type = \\\"Label\\\",\\\
			Name = \\\"UnderlineLabel\\\",\\\
			Text = underline,\\\
			TextColour = col,\\\
			BackgroundColour = self.BackgroundColour\\\
		})	\\\
		return currentY + 1\\\
	else\\\
		return currentY\\\
	end\\\
end\\\
\\\
OnClick = function(self)\\\
	self.Bedrock:GetObject('WebView'):GoToURL(self.URL)\\\
end\",\
    [ \"Programs/Quest.program/Objects/DividerView.lua\" ] = \"Inherit = 'View'\\\
Char = nil\\\
\\\
OnDraw = function(self, x, y)\\\
	if self.BackgroundColour then\\\
		if self.Char then\\\
			Drawing.DrawArea (x, y, self.Width, self.Height, self.Char, self.TextColour, self.BackgroundColour)\\\
		else\\\
			Drawing.DrawBlankArea(x, y, self.Width, self.Height, self.BackgroundColour)\\\
		end\\\
	end\\\
end\",\
    [ \"System/OneOS.log\" ] = \"-- OneOS Log --\\\
[0 Info] Starting OneOS\\\
[0 Info] CraftOS 1.8\\\
[0 Info] Free space: 1368046\\\
[0 Info] OneOS Version: r1.3.4\\\
[0 Info] Loading: System/API/Settings.lua\\\
[0.15000000000000 Info] Boot Key: 56\\\
[0.30000000000000 Info] Loading image: System/Images/Boot/boot0\\\
[0.35000000000000 Info] Loading: System/API/AppRedirect.lua\\\
[0.35000000000000 Info] Loading image: System/Images/Boot/boot1\\\
[0.40000000000000 Info] Loading: System/API/Bedrock.lua\\\
[0.40000000000000 Info] Loading: System/API/CRC32.lua\\\
[0.40000000000000 Info] Loading image: System/Images/Boot/boot2\\\
[0.45000000000000 Info] Loading: System/API/Clipboard.lua\\\
[0.45000000000000 Info] Loading: System/API/Environment.lua\\\
[0.45000000000000 Info] Loading image: System/Images/Boot/boot3\\\
[0.50000000000000 Info] Loading: System/API/Hash.lua\\\
[0.50000000000000 Info] Loading: System/API/Helpers.lua\\\
[0.50000000000000 Info] Loading image: System/Images/Boot/boot4\\\
[0.55000000000000 Info] Loading: System/API/Indexer.lua\\\
[0.55000000000000 Info] Loading: System/API/LegacyDrawing.lua\\\
[0.55000000000000 Info] Loading image: System/Images/Boot/boot5\\\
[0.60000000000000 Info] Loading: System/API/Peripheral.lua\\\
[0.60000000000000 Info] Loading image: System/Images/Boot/boot6\\\
[0.65000000000000 Info] Loading: System/API/Program.lua\\\
[0.65000000000000 Info] Loading: System/API/Search.lua\\\
[0.65000000000000 Info] Loading image: System/Images/Boot/boot7\\\
[0.70000000000000 Info] Loading image: System/Images/Boot/boot8\\\
[0.75000000000000 Info] Loading: System/API/Wireless.lua\\\
[1.0500000000000 Info] Entered Boot Menu\",\
    [ \"Programs/Games/Lasers.program/Views/main.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"Toolbar\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"InheritView\\\"]=\\\"toolbar\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=3,\\\
      [\\\"Width\\\"]=\\\"100%,-4\\\",\\\
      [\\\"Height\\\"]=3,\\\
      [\\\"Name\\\"]=\\\"Label\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"To save disc space, OneOS does not come with Lasers downloaded by default. Do you want to download it now?\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"100%,-6\\\",\\\
      [\\\"Name\\\"]=\\\"YesButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Yes\\\",\\\
      [\\\"BackgroundColour\\\"]=8192,\\\
      [\\\"TextColour\\\"]=1\\\
    },\\\
    [4]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"100%,-11\\\",\\\
      [\\\"Name\\\"]=\\\"NoButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"No\\\",\\\
      [\\\"BackgroundColour\\\"]=16384,\\\
      [\\\"TextColour\\\"]=1\\\
    },\\\
  },\\\
  [\\\"BackgroundColour\\\"]=1,\\\
  [\\\"ToolBarColour\\\"] = 128,\\\
  [\\\"ToolBarTextColour\\\"] = 1\\\
}\",\
    startup = \"_G.package = {\\\
	config = {\\\"/\\\", \\\";\\\", \\\"?\\\", \\\"!\\\", \\\"-\\\"},\\\
	loaded = _G,\\\
	preload = {},\\\
	path = \\\"/rom/apis/?;/rom/apis/?.lua;/rom/apis/?/init.lua;/rom/modules/main/?;rom/modules/main/?.lua;/rom/modules/main/?/init.lua\\\"\\\
}\\\
cleanEnvironment = {}\\\
for k, v in pairs(_G) do\\\
	cleanEnvironment[k] = v\\\
end\\\
\\\
isDebug = false\\\
\\\
oldTerm = term\\\
\\\
--[[\\\
term.setBackgroundColour(colours.white)\\\
term.setTextColour(colours.black)\\\
term.clear()\\\
]]--\\\
\\\
--local _, err = pcall(function()\\\
\\\
\\\
local doLog = false\\\
\\\
local function log(...)\\\
	if Log then\\\
		Log.i(...)\\\
	end\\\
	if isDebug or doLog then\\\
		print(...)\\\
	end\\\
end\\\
\\\
local tAPIsLoading = {}\\\
\\\
local Extension = function(path, addDot)\\\
	if not path then\\\
		return nil\\\
	elseif not string.find(fs.getName(path), '%.') then\\\
		if not addDot then\\\
			return fs.getName(path)\\\
		else\\\
			return ''\\\
		end\\\
	else\\\
		local _path = path\\\
		if path:sub(#path) == '/' then\\\
			_path = path:sub(1,#path-1)\\\
		end\\\
		local extension = _path:gmatch('%.[0-9a-z]+$')()\\\
		if extension then\\\
			extension = extension:sub(2)\\\
		else\\\
			--extension = nil\\\
			return ''\\\
		end\\\
		if addDot then\\\
			extension = '.'..extension\\\
		end\\\
		return extension:lower()\\\
	end\\\
end\\\
\\\
local RemoveExtension = function(path)\\\
	if path:sub(1,1) == '.' then\\\
		return path\\\
	end\\\
	local extension = Extension(path)\\\
	if extension == path then\\\
		return fs.getName(path)\\\
	end\\\
	return string.gsub(path, extension, ''):sub(1, -2)\\\
end\\\
\\\
function LoadAPI(_sPath)\\\
	local sName = RemoveExtension(fs.getName( _sPath ))\\\
	if tAPIsLoading[sName] == true then\\\
		return true\\\
	end\\\
	log('Loading: '.._sPath)\\\
	tAPIsLoading[sName] = true\\\
\\\
	local tEnv = {isStartup = true }\\\
	setmetatable( tEnv, { __index = getfenv()} )\\\
	local fnAPI, err = loadfile( _sPath )\\\
	if fnAPI then\\\
		setfenv( fnAPI, tEnv )\\\
		fnAPI()\\\
	else\\\
		printError( err )\\\
		log('Error: '..err)\\\
        tAPIsLoading[sName] = nil\\\
		return false\\\
	end\\\
\\\
	local tAPI = {}\\\
	for k,v in pairs( tEnv ) do\\\
		tAPI[k] =  v\\\
	end\\\
\\\
	if not tAPI then\\\
		log('Could not find API: '..sName)\\\
		error('Could not find API: '..sName)\\\
	-- elseif _sPath:find('Objects') then\\\
	-- 	tAPI.__index = Object\\\
	-- 	if tAPI.Inherit then\\\
	-- 		if not getfenv()[tAPI.Inherit] then\\\
	-- 			LoadAPI('System/Objects/'..tAPI.Inherit..'.lua')\\\
	-- 		end\\\
	-- 		tAPI.__index = getfenv()[tAPI.Inherit]\\\
	-- 	end\\\
	-- 	setmetatable(tAPI, tAPI)\\\
	end\\\
\\\
	getfenv()[sName] = tAPI\\\
\\\
	--tAPIsLoading[sName] = nil\\\
	return true\\\
end\\\
\\\
term.setCursorPos(1,1)\\\
root = ''\\\
\\\
function PrintCentered(text, y)\\\
    local w, h = term.getSize()\\\
    x = math.ceil(math.ceil((w / 2) - (#text / 2)), 0)+1\\\
    term.setCursorPos(x, y)\\\
    write(text)\\\
end\\\
\\\
LoadAPI('System/API/Log.lua')\\\
Log.Initialise()\\\
Log.i('Starting OneOS')\\\
Log.i(os.version())\\\
Log.i('Free space: '..fs.getFreeSpace('/'))\\\
\\\
local h = fs.open('/System/.version', 'r')\\\
local version = '?'\\\
if h then\\\
	version = h.readAll()\\\
	h.close()\\\
else\\\
	version = 'Not set'\\\
end\\\
Log.i('OneOS Version: '..version)\\\
\\\
LoadAPI('System/API/Settings.lua')\\\
-- LoadAPI('System/API/Object.lua')\\\
local _side = Settings:GetValues()['Monitor']\\\
if not term.setTextScale and _side then\\\
	if peripheral.isPresent(_side) and peripheral.getType(_side) == 'monitor' and peripheral.call(_side, 'isColour') == true then\\\
		term.setBackgroundColor(colours.grey)\\\
		term.clear()\\\
		term.setTextColor(colours.white)\\\
		PrintCentered('OneOS is being run off a monitor', 6)\\\
		term.setTextColor(colours.lightGrey)\\\
		PrintCentered('To stop it from running off a monitor try:', 8)\\\
		term.setTextColor(colours.white)\\\
		PrintCentered('- Save you files, then find the monitor in Files', 10)\\\
		PrintCentered(\\\"and click: 'Use Computer Screen'\\\", 11)\\\
\\\
		PrintCentered('- Break the monitor next to the computer', 13)\\\
		PrintCentered('This method will NOT save your files.', 14)\\\
		Log.i(\\\"Using a monitor on side: \\\".._side)\\\
		term.redirect(peripheral.wrap(Settings:GetValues()['Monitor']))\\\
	else\\\
		Settings:SetValue('Monitor', nil)\\\
	end\\\
end\\\
\\\
\\\
function LoadingScreen()\\\
	if fs.getFreeSpace and fs.getFreeSpace('/') < 51200 then\\\
		if not isDebug then\\\
			term.setBackgroundColor(colours.grey)\\\
			term.setTextColor(colours.white)\\\
			term.clear()\\\
\\\
			PrintCentered('You have less than 50KB of free space remaining!', 6)\\\
			PrintCentered('You may encounter crashes due to this.' , 7)\\\
			term.setTextColor(colours.lightGrey)\\\
\\\
			PrintCentered('Try to free up some space, open \\\\'About OneOS\\\\'' , 9)\\\
			PrintCentered('in the One menu for more information.' , 10)\\\
			term.setTextColor(colours.white)\\\
\\\
			PrintCentered('Click anywhere to continue.', 12)\\\
\\\
			os.pullEvent('mouse_click')\\\
		end\\\
		Log.w('Less than 50KB disk space available.')\\\
	end\\\
\\\
	local x, y = nil\\\
\\\
	if not isDebug then\\\
		term.setBackgroundColour(colours.black)\\\
		term.clear()\\\
		sleep(0.1)\\\
		term.setBackgroundColour(colours.grey)\\\
		term.clear()\\\
		sleep(0.1)\\\
		term.setBackgroundColour(colours.lightGrey)\\\
		term.clear()\\\
		sleep(0.1)\\\
\\\
		local screenWidth, screenHeight = term.getSize()\\\
		term.setBackgroundColour(colours.white)\\\
		term.clear()\\\
		x = math.ceil((screenWidth - 23) / 2) + 1\\\
		y = (screenHeight - 8) / 2 + 1\\\
\\\
		local text = 'OneOS by oeed'\\\
		term.setCursorPos(math.ceil((screenWidth - #text) / 2) + 1, y + 5)\\\
		term.setTextColour(colours.grey)\\\
		term.write(text)\\\
\\\
		term.setTextColour(colours.lightGrey)\\\
		PrintCentered('Hold ALT for boot options', screenHeight)\\\
\\\
	end\\\
\\\
	local currentImage = -1\\\
	local totalAPIs = #fs.list(root .. 'System/API/')-- + #fs.list(root .. 'System/Objects/')\\\
	local apis = {}\\\
	for _, file in pairs(fs.list(root .. 'System/API/')) do\\\
		if string.sub(file,1,1) ~= \\\".\\\" then\\\
			table.insert(apis, 'System/API/' .. file)\\\
		end\\\
	end\\\
	-- for _, file in pairs(fs.list(root .. 'System/Objects/')) do\\\
	-- 	if string.sub(file,1,1) ~= \\\".\\\" then\\\
	-- 		table.insert(apis, 'System/Objects/' .. file)\\\
	-- 	end\\\
	-- end\\\
\\\
	for _, file in pairs(apis) do\\\
		if not isDebug then\\\
			if math.floor(_*(8/#apis)) ~= currentImage then\\\
				currentImage = math.floor(_*(8/#apis))\\\
				Log.i('Loading image: System/Images/Boot/boot'..currentImage)\\\
				local image = paintutils.loadImage('System/Images/Boot/boot'..currentImage)\\\
				paintutils.drawImage(image, x, y)\\\
				sleep(0)\\\
			end\\\
		end\\\
\\\
		if not LoadAPI(root .. file) then\\\
			return false\\\
		end\\\
	end\\\
	sleep(0.3)\\\
	return true\\\
end\\\
\\\
function RecieveStartupKey()\\\
	while true do\\\
	  local event, arg = os.pullEvent()\\\
	  if event=='onesos_bootdone' then\\\
	  	log('No boot modifier, starting normally.')\\\
	  	return nil\\\
	  elseif event == \\\"key\\\" then\\\
	  	log('Boot Key: '..arg)\\\
	  	return arg\\\
	  end\\\
\\\
	end\\\
end\\\
\\\
function PastebinPut(file)\\\
	if not fs.exists(file) then\\\
		return 'NOT EXIST'\\\
	end\\\
    -- Read in the file\\\
    local sName = fs.getName( file )\\\
    local file = fs.open( file, \\\"r\\\" )\\\
    local sText = file.readAll()\\\
    file.close()\\\
\\\
    local key = \\\"0ec2eb25b6166c0c27a394ae118ad829\\\"\\\
    local response = http.post(\\\
        \\\"http://pastebin.com/api/api_post.php\\\",\\\
        \\\"api_option=paste&\\\"..\\\
        \\\"api_dev_key=\\\"..key..\\\"&\\\"..\\\
        \\\"api_paste_format=lua&\\\"..\\\
        \\\"api_paste_name=\\\"..textutils.urlEncode(sName)..\\\"&\\\"..\\\
        \\\"api_paste_code=\\\"..textutils.urlEncode(sText)\\\
    )\\\
\\\
    if response then\\\
        local sResponse = response.readAll()\\\
        response.close()\\\
\\\
        local sCode = string.match( sResponse, \\\"[^/]+$\\\" )\\\
        return sCode\\\
    end\\\
    return 'FAILED'\\\
end\\\
\\\
function BootMenu()\\\
	Log.i('Entered Boot Menu')\\\
	os.loadAPI('/System/API/LegacyDrawing.lua')\\\
	local Drawing = LegacyDrawing\\\
	Drawing.Clear(colours.white)\\\
	Drawing.DrawCharactersCenter(nil, (-Drawing.Screen.Height/2) + 2, nil, nil, 'OneOS', colours.blue, colours.white)\\\
	Drawing.DrawCharactersCenter(nil, (-Drawing.Screen.Height/2) + 3, nil, nil, 'Boot Options', colours.grey, colours.white)\\\
	Drawing.DrawCharactersCenter(1, (Drawing.Screen.Height/2), nil, nil, 'Use arrow keys to select, enter to accept', colours.grey, colours.white)\\\
	local continue = false\\\
	local options = {\\\
		{'Boot Normally', function() continue = true end},\\\
		{'Reset Settings', function() if fs.exists('/System/.OneOS.settings') then fs.delete('/System/.OneOS.settings') end continue = true end},\\\
		{'Wipe Computer', function()\\\
			term.setCursorPos(1,1)\\\
			term.setBackgroundColor(colours.black)\\\
			term.setTextColor(colours.white)\\\
			term.clear()\\\
			local function removeFolder(path)\\\
				if path == '/rom' then\\\
					return\\\
				end\\\
				for i, v in ipairs(fs.list(path)) do\\\
					if fs.isDir(path..'/'..v) then\\\
						removeFolder(path..'/'..v)\\\
					else\\\
						fs.delete(path..'/'..v)\\\
						print('Removed: '..path..'/'..v)\\\
						sleep(0)\\\
					end\\\
				end\\\
				if path ~= '' then\\\
					fs.delete(path)\\\
				end\\\
			end\\\
			removeFolder('')\\\
\\\
		end},\\\
		{'Use CraftOS', function()end}\\\
	}\\\
\\\
	local selected = 1\\\
	local function draw()\\\
		for i, v in ipairs(options) do\\\
			local bg = colours.white\\\
			local tc = colours.blue\\\
			if i == selected then\\\
				bg = colours.blue\\\
				tc = colours.white\\\
			end\\\
			Drawing.DrawCharactersCenter(nil, math.floor(-#options/2) + i, nil, nil, ' '..v[1]..' ', tc, bg)\\\
		end\\\
		Drawing.DrawBuffer()\\\
	end\\\
	local wait = true\\\
	draw()\\\
	while wait do\\\
		local event, key = os.pullEvent('key')\\\
		if key == keys.up then\\\
			selected = selected - 1\\\
			if selected < 1 then\\\
				selected = 1\\\
			end\\\
		elseif key == keys.down then\\\
			selected = selected + 1\\\
			if selected > #options then\\\
				selected = #options\\\
			end\\\
		elseif key == keys.enter then\\\
			if options[selected][1] == 'Wipe Computer' then\\\
				Drawing.Clear(colours.white)\\\
				Drawing.DrawCharactersCenter(nil, (-Drawing.Screen.Height/2) + 2, nil, nil, 'OneOS', colours.blue, colours.white)\\\
				Drawing.DrawCharactersCenter(nil, (-Drawing.Screen.Height/2) + 3, nil, nil, 'Boot Options', colours.grey, colours.white)\\\
				Drawing.DrawCharactersCenter(1, (Drawing.Screen.Height/2), nil, nil, 'Use arrow keys to select, enter to accept', colours.grey, colours.white)\\\
				Drawing.DrawCharactersCenter(nil, nil, nil, nil, 'Are you sure? Press Y or N', colours.red, colours.white)\\\
				Drawing.DrawBuffer()\\\
				local _ = true\\\
				while _ do\\\
					local ev, k = os.pullEvent('char')\\\
					if k == 'y' then\\\
						options[selected][2]()\\\
						sleep(2)\\\
						os.reboot()\\\
					elseif k == 'n' then\\\
						_ = false\\\
					end\\\
				end\\\
				Drawing.DrawCharactersCenter(nil, nil, nil, nil, '                          ', colours.red, colours.white)\\\
			else\\\
				options[selected][2]()\\\
				wait = false\\\
			end\\\
		end\\\
		draw()\\\
	end\\\
	return continue\\\
end\\\
\\\
local function addFile(path, input)\\\
	local h = fs.open(path, 'r')\\\
	if h then\\\
		input = input .. '\\\\0' .. h.readAll()\\\
		h.close()\\\
	end\\\
	return input\\\
end\\\
\\\
local function addFolder(path, input)\\\
	for i, file in ipairs(fs.list(path)) do\\\
		local _path = path .. '/' .. file\\\
		if fs.isDir(_path) then\\\
			input = addFolder(_path, input)\\\
		elseif file:sub(1,1) ~= '.' and not file:find('.log') then\\\
			input = addFile(_path, input)\\\
		end\\\
	end\\\
	return input\\\
end\\\
\\\
function GetHash()\\\
	local toCheck = {'/System/', 'startup'}\\\
	local raw = addFile('startup', '')\\\
	raw = addFolder('/System/', raw)\\\
	local hash = CRC32.Hash(raw)\\\
	return hash\\\
end\\\
\\\
function IsSystemModified()\\\
	local h = fs.open('/System/.hash', 'r')\\\
	if h then\\\
		local correctHash = tonumber(h.readLine())\\\
		h.close()\\\
		local hash = GetHash()\\\
		if hash == correctHash then\\\
			log('System is not modified.')\\\
			return false\\\
		end\\\
	end\\\
	log('System is modified, not submitting report.')\\\
	return true\\\
end\\\
\\\
local oldFiles = {\\\
	'/System/API/Animation.lua',\\\
	'/System/API/Button.lua',\\\
	'/System/API/ButtonDialogueWindow.lua',\\\
	'/System/API/Desktop.lua',\\\
	'/System/API/ListView.lua',\\\
	'/System/API/Menu.lua',\\\
	'/System/API/OpenWithDialougeWindow.lua',\\\
	'/System/API/Overlay.lua',\\\
	'/System/API/Printer.lua',\\\
	'/System/API/ProgressBar.lua',\\\
	'/System/API/ScrollBar.lua',\\\
	'/System/API/TextBox.lua',\\\
	'/System/API/TextDialogueWindow.lua',\\\
	'/System/API/TextInput.lua',\\\
	'/System/API/Turtle.lua',\\\
	'/System/API/Window.lua',\\\
	'/System/Images/Icons/ink',\\\
	'/System/Images/Icons/lua',\\\
	'/System/Images/Icons/nfp',\\\
	'/System/Images/Icons/nft',\\\
	'/System/Images/Icons/skch',\\\
	'/System/Images/Icons/pkg',\\\
	'/System/Images/Icons/startup',\\\
	'/System/Images/Icons/text',\\\
	'/System/Images/Icons/txt',\\\
	'/System/Programs/Setup.program',\\\
	'/System/Programs/About OneOS',\\\
	'/System/Programs/Settings',\\\
	'/System/Programs/Update OneOS',\\\
	'/System/API/Object.lua',\\\
	'/System/Objects/Button.lua',\\\
	'/System/Objects/CollectionView.lua',\\\
	'/System/Objects/ImageView.lua',\\\
	'/System/Objects/Label.lua',\\\
	'/System/Objects/ListView.lua',\\\
	'/System/Objects/Menu.lua',\\\
	'/System/Objects/ProgressBar.lua',\\\
	'/System/Objects/ScrollBar.lua',\\\
	'/System/Objects/ScrollView.lua',\\\
	'/System/Objects/Separator.lua',\\\
	'/System/Objects/TextBox.lua',\\\
	'/System/Objects/View.lua',\\\
	'/System/Objects/Window.lua',\\\
	'/System/API/Drawing.lua',\\\
}\\\
\\\
function RemoveOldFiles()\\\
	local found = false\\\
	for i, v in ipairs(oldFiles) do\\\
		if fs.exists(v) then\\\
			found = true\\\
		end\\\
	end\\\
	if not found then\\\
		return\\\
	end\\\
	doLog = true\\\
	log('OneOS has detected old files which may cause conflict.')\\\
	log('If you want to keep these files then shutdown now.')\\\
	print('---------------------------------------------------')\\\
	log(\\\"If you can, you should do a fresh install. There might be lots of trash files not deleted that could cause issues.\\\")\\\
	log(\\\"To do this, press enter, reboot and hold ALT then select 'Wipe Computer' and reinstall.\\\")\\\
	print('---------------------------------------------------')\\\
	log('Press enter to delete these files.')\\\
	read()\\\
	fs.delete('/System/.OneOS.settings')\\\
	for i, v in ipairs(oldFiles) do\\\
		log('Deleting: '..v)\\\
		if fs.exists(v) then\\\
			fs.delete(v)\\\
			sleep(0)\\\
		end\\\
	end\\\
	doLog = false\\\
	log('Clean complete!')\\\
	log('Rebooting now...')\\\
	sleep(1)\\\
	os.reboot()\\\
end\\\
\\\
function Start()\\\
	RemoveOldFiles()\\\
	local key = nil\\\
	local success = false\\\
	parallel.waitForAll(function()success = LoadingScreen() os.queueEvent('onesos_bootdone') end, function() key = RecieveStartupKey() end)\\\
	if success and key == keys.leftAlt or key == keys.rightAlt then\\\
		success = BootMenu()\\\
	end\\\
	return success\\\
end\\\
\\\
if not term.isColour() then\\\
	term.setBackgroundColor(colours.black)\\\
	term.setTextColor(colours.white)\\\
	term.clear()\\\
\\\
	PrintCentered('OneOS requires an advanced (gold) computer.', 8)\\\
\\\
	PrintCentered('Press any key to return to the shell.', 10)\\\
\\\
	os.pullEvent('key')\\\
	term.clear()\\\
	term.setCursorPos(1,1)\\\
\\\
elseif Start() then\\\
	os.run(getfenv(), '/System/main.lua')\\\
\\\
	local ok = nil\\\
	if not fs.exists('/System/.version') or not fs.exists('/System/.OneOS.settings') then\\\
		log('No .version or .OneOS.settings! Running First Setup')\\\
		if fs.exists('/System/.OneOS.settings') then\\\
			fs.delete('/System/.OneOS.settings')\\\
		end\\\
		xpcall(FirstSetup, function(err)\\\
			Log.e('[> First Setup] '..err)\\\
			ok = {false, err}\\\
		end)\\\
	else\\\
		if isDebug then\\\
			Initialise()\\\
		else\\\
			xpcall(Initialise, function(err)\\\
				ok = {false, err}\\\
			end)\\\
		end\\\
	end\\\
\\\
	if not isDebug and not ok[1] then\\\
\\\
		xpcall(function()loadfile('/System/main.lua')end, function(err)\\\
			log('Syntaxt error (probably): '..err)\\\
			table.insert(ok, err)\\\
		end)\\\
\\\
		for i, v in ipairs(ok) do\\\
			Log.e(v)\\\
		end\\\
		--if the crash is a too long without yeilding error then there's nothing we can really do, restart\\\
		if ok[2]:sub(-25) == 'Too long without yielding' then\\\
			term.setBackgroundColor(colours.grey)\\\
			term.setTextColor(colours.white)\\\
			term.clear()\\\
			local w,h = term.getSize()\\\
			if fs.exists('System/Images/crash') then\\\
				Log.i('Loading image: System/Images/crash')\\\
				paintutils.drawImage(paintutils.loadImage('System/Images/crash'), (w-7)/2 + 1, 3)\\\
			end\\\
			term.setBackgroundColor(colours.grey)\\\
			term.setTextColor(colours.white)\\\
\\\
			PrintCentered('OneOS has been forced to reboot', 8)\\\
\\\
			PrintCentered('You likely let your (real) computer go to sleep', 10)\\\
			PrintCentered('or there was some huge amount of lag.', 11)\\\
			PrintCentered('Unfortunately, there\\\\'s no way to recover from this.', 13)\\\
\\\
			PrintCentered('Click anywhere to reboot.', 15)\\\
\\\
			os.pullEvent('mouse_click')\\\
			os.reboot()\\\
		end\\\
			term.setBackgroundColor(colours.grey)\\\
		term.setTextColor(colours.white)\\\
		term.clear()\\\
		local w,h = term.getSize()\\\
		if fs.exists('/System/Images/crash') then\\\
			Log.i('Loading image: System/Images/crash')\\\
			local img = paintutils.loadImage('/System/Images/crash')\\\
			if img and w then\\\
				paintutils.drawImage(img, (w-7)/2 + 1, 3)\\\
			end\\\
		else\\\
			table.insert(ok, 'Crash image nonexistent!')\\\
		end\\\
		term.setBackgroundColor(colours.grey)\\\
		term.setTextColor(colours.white)\\\
\\\
		PrintCentered('OneOS has crashed!', 8)\\\
\\\
		PrintCentered('OneOS has encountered a serious error,', 10)\\\
		PrintCentered('click anywhere to reboot.', 11)\\\
\\\
		term.setTextColor(colours.lightGrey)\\\
		table.remove(ok, 1)\\\
		for i, v in ipairs(ok) do\\\
			local w, h = term.getSize()\\\
		    x = math.ceil(math.ceil((w / 2) - (#v / 2)), 0)+1\\\
		    if x < 1 then\\\
		    	x = 1\\\
		    end\\\
		    term.setCursorPos(x, i+12)\\\
		    print(v)\\\
		end\\\
\\\
		PrintCentered('Checking for file modifications...', Drawing.Screen.Height-3)\\\
		local modified = IsSystemModified()\\\
		term.clearLine()\\\
		if not modified then\\\
			PrintCentered('Please report this on the forum.', Drawing.Screen.Height)\\\
		end\\\
		term.setTextColor(colours.white)\\\
		if http then\\\
			if modified then\\\
				PrintCentered('Modified file system detected.', Drawing.Screen.Height-3)\\\
				PrintCentered('Not sending report.', Drawing.Screen.Height-2)\\\
			else\\\
				log('Sending error report...')\\\
				PrintCentered('Sending error report, please wait.', Drawing.Screen.Height-3)\\\
				local success = false\\\
				parallel.waitForAny(function()sleep(7) end, function()\\\
					local s = ok[#ok]\\\
					local pastebin = 'Not1.6'\\\
					if fs.find then\\\
						local f = fs.find('*/'..s:sub(1, s:find(':')-1))[1]\\\
						if not f then\\\
							pastebin = PastebinPut(s)\\\
						else\\\
							pastebin = PastebinPut(f)\\\
						end\\\
					end\\\
					local detail = {message='Crashed Before Main Initialise', time = os.clock(), errors = ok, pastebin = pastebin}\\\
					if Current and Current.Programs then\\\
						detail.message = 'Crashed After Main Initialise'\\\
						detail.programs = {}\\\
						for i, v in ipairs(Current.Programs) do\\\
							table.insert(detail.programs, v.Name)\\\
						end\\\
					end\\\
					local version = '?'\\\
\\\
					local h = fs.open('/System/.version', 'r')\\\
					if h then\\\
						version = h.readAll()\\\
						h.close()\\\
					else\\\
						version = 'N/E'\\\
					end\\\
\\\
					local detailString = textutils.serialize(detail) ..'\\\\n\\\\n'\\\
\\\
					local h = fs.open('/System/OneOS.log', 'r')\\\
					if h then\\\
						detailString = detailString .. 'Log:\\\\n'..h.readAll()\\\
						h.close()\\\
					else\\\
						detailString = detailString .. 'No Log'\\\
					end\\\
\\\
					if not isDebug then\\\
						local _ = http.post('http://olivercooper.me/errorSubmit.php',\\\
		                                \\\"product=\\\"..textutils.urlEncode(tostring('OneOS'))..\\\"&\\\"..\\\
		                                \\\"version=\\\"..textutils.urlEncode(tostring(version))..\\\"&\\\"..\\\
		                                \\\"error=\\\"..textutils.urlEncode(ok[#ok])..\\\"&\\\"..\\\
		                                \\\"detail=\\\"..textutils.urlEncode(detailString));\\\
						if _ then\\\
							success = true\\\
						end\\\
					end\\\
				end)\\\
				local message = 'Error report failed!'\\\
				if success then\\\
					message = 'Error report sent!'\\\
				end\\\
				log(message)\\\
				term.setCursorPos(1, Drawing.Screen.Height-3)\\\
				term.clearLine()\\\
				PrintCentered(message..' Click to reboot.', Drawing.Screen.Height-3)\\\
			end\\\
		end\\\
\\\
		os.pullEvent('mouse_click')\\\
		os.reboot()\\\
	end\\\
end\\\
\\\
term.setBackgroundColor(colours.black)\\\
term.setCursorPos(1,1)\\\
term.clear()\",\
    LICENSE = \"OneOS is under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0) license.\\\
\\\
Which essentially allows you:\\\
	Share - copy and redistribute the material in any medium or format\\\
\\\
Under these terms:\\\
	Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.\\\
	Non-Commercial - You may not use the material for commercial purposes.\\\
	NoDerivatives - If you remix, transform, or build upon the material, you may not distribute the modified material.\\\
\\\
If you would like to publicly release anything derived from OneOS please let me know via PM on the ComputerCraft forums.\\\
\\\
For more information: http://creativecommons.org/licenses/by-nc-nd/4.0/\\\
\\\
If you want to get your lawyers involved for some reason, give them this :P\\\
\\\
Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International Public License\\\
\\\
By exercising the Licensed Rights (defined below), You accept and agree to be bound by the terms and conditions of this Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International Public License (\\\"Public License\\\"). To the extent this Public License may be interpreted as a contract, You are granted the Licensed Rights in consideration of Your acceptance of these terms and conditions, and the Licensor grants You such rights in consideration of benefits the Licensor receives from making the Licensed Material available under these terms and conditions.\\\
\\\
Section 1 ??? Definitions.\\\
\\\
Adapted Material means material subject to Copyright and Similar Rights that is derived from or based upon the Licensed Material and in which the Licensed Material is translated, altered, arranged, transformed, or otherwise modified in a manner requiring permission under the Copyright and Similar Rights held by the Licensor. For purposes of this Public License, where the Licensed Material is a musical work, performance, or sound recording, Adapted Material is always produced where the Licensed Material is synched in timed relation with a moving image.\\\
Copyright and Similar Rights means copyright and/or similar rights closely related to copyright including, without limitation, performance, broadcast, sound recording, and Sui Generis Database Rights, without regard to how the rights are labeled or categorized. For purposes of this Public License, the rights specified in Section 2(b)(1)-(2) are not Copyright and Similar Rights.\\\
Effective Technological Measures means those measures that, in the absence of proper authority, may not be circumvented under laws fulfilling obligations under Article 11 of the WIPO Copyright Treaty adopted on December 20, 1996, and/or similar international agreements.\\\
Exceptions and Limitations means fair use, fair dealing, and/or any other exception or limitation to Copyright and Similar Rights that applies to Your use of the Licensed Material.\\\
Licensed Material means the artistic or literary work, database, or other material to which the Licensor applied this Public License.\\\
Licensed Rights means the rights granted to You subject to the terms and conditions of this Public License, which are limited to all Copyright and Similar Rights that apply to Your use of the Licensed Material and that the Licensor has authority to license.\\\
Licensor means the individual(s) or entity(ies) granting rights under this Public License.\\\
NonCommercial means not primarily intended for or directed towards commercial advantage or monetary compensation. For purposes of this Public License, the exchange of the Licensed Material for other material subject to Copyright and Similar Rights by digital file-sharing or similar means is NonCommercial provided there is no payment of monetary compensation in connection with the exchange.\\\
Share means to provide material to the public by any means or process that requires permission under the Licensed Rights, such as reproduction, public display, public performance, distribution, dissemination, communication, or importation, and to make material available to the public including in ways that members of the public may access the material from a place and at a time individually chosen by them.\\\
Sui Generis Database Rights means rights other than copyright resulting from Directive 96/9/EC of the European Parliament and of the Council of 11 March 1996 on the legal protection of databases, as amended and/or succeeded, as well as other essentially equivalent rights anywhere in the world.\\\
You means the individual or entity exercising the Licensed Rights under this Public License. Your has a corresponding meaning.\\\
Section 2 ??? Scope.\\\
\\\
License grant.\\\
Subject to the terms and conditions of this Public License, the Licensor hereby grants You a worldwide, royalty-free, non-sublicensable, non-exclusive, irrevocable license to exercise the Licensed Rights in the Licensed Material to:\\\
reproduce and Share the Licensed Material, in whole or in part, for NonCommercial purposes only; and\\\
produce and reproduce, but not Share, Adapted Material for NonCommercial purposes only.\\\
Exceptions and Limitations. For the avoidance of doubt, where Exceptions and Limitations apply to Your use, this Public License does not apply, and You do not need to comply with its terms and conditions.\\\
Term. The term of this Public License is specified in Section 6(a).\\\
Media and formats; technical modifications allowed. The Licensor authorizes You to exercise the Licensed Rights in all media and formats whether now known or hereafter created, and to make technical modifications necessary to do so. The Licensor waives and/or agrees not to assert any right or authority to forbid You from making technical modifications necessary to exercise the Licensed Rights, including technical modifications necessary to circumvent Effective Technological Measures. For purposes of this Public License, simply making modifications authorized by this Section 2(a)(4) never produces Adapted Material.\\\
Downstream recipients.\\\
Offer from the Licensor ??? Licensed Material. Every recipient of the Licensed Material automatically receives an offer from the Licensor to exercise the Licensed Rights under the terms and conditions of this Public License.\\\
No downstream restrictions. You may not offer or impose any additional or different terms or conditions on, or apply any Effective Technological Measures to, the Licensed Material if doing so restricts exercise of the Licensed Rights by any recipient of the Licensed Material.\\\
No endorsement. Nothing in this Public License constitutes or may be construed as permission to assert or imply that You are, or that Your use of the Licensed Material is, connected with, or sponsored, endorsed, or granted official status by, the Licensor or others designated to receive attribution as provided in Section 3(a)(1)(A)(i).\\\
Other rights.\\\
\\\
Moral rights, such as the right of integrity, are not licensed under this Public License, nor are publicity, privacy, and/or other similar personality rights; however, to the extent possible, the Licensor waives and/or agrees not to assert any such rights held by the Licensor to the limited extent necessary to allow You to exercise the Licensed Rights, but not otherwise.\\\
Patent and trademark rights are not licensed under this Public License.\\\
To the extent possible, the Licensor waives any right to collect royalties from You for the exercise of the Licensed Rights, whether directly or through a collecting society under any voluntary or waivable statutory or compulsory licensing scheme. In all other cases the Licensor expressly reserves any right to collect such royalties, including when the Licensed Material is used other than for NonCommercial purposes.\\\
Section 3 ??? License Conditions.\\\
\\\
Your exercise of the Licensed Rights is expressly made subject to the following conditions.\\\
\\\
Attribution.\\\
\\\
If You Share the Licensed Material, You must:\\\
\\\
retain the following if it is supplied by the Licensor with the Licensed Material:\\\
identification of the creator(s) of the Licensed Material and any others designated to receive attribution, in any reasonable manner requested by the Licensor (including by pseudonym if designated);\\\
a copyright notice;\\\
a notice that refers to this Public License;\\\
a notice that refers to the disclaimer of warranties;\\\
a URI or hyperlink to the Licensed Material to the extent reasonably practicable;\\\
indicate if You modified the Licensed Material and retain an indication of any previous modifications; and\\\
indicate the Licensed Material is licensed under this Public License, and include the text of, or the URI or hyperlink to, this Public License.\\\
For the avoidance of doubt, You do not have permission under this Public License to Share Adapted Material.\\\
You may satisfy the conditions in Section 3(a)(1) in any reasonable manner based on the medium, means, and context in which You Share the Licensed Material. For example, it may be reasonable to satisfy the conditions by providing a URI or hyperlink to a resource that includes the required information.\\\
If requested by the Licensor, You must remove any of the information required by Section 3(a)(1)(A) to the extent reasonably practicable.\\\
Section 4 ??? Sui Generis Database Rights.\\\
\\\
Where the Licensed Rights include Sui Generis Database Rights that apply to Your use of the Licensed Material:\\\
\\\
for the avoidance of doubt, Section 2(a)(1) grants You the right to extract, reuse, reproduce, and Share all or a substantial portion of the contents of the database for NonCommercial purposes only and provided You do not Share Adapted Material;\\\
if You include all or a substantial portion of the database contents in a database in which You have Sui Generis Database Rights, then the database in which You have Sui Generis Database Rights (but not its individual contents) is Adapted Material; and\\\
You must comply with the conditions in Section 3(a) if You Share all or a substantial portion of the contents of the database.\\\
For the avoidance of doubt, this Section 4 supplements and does not replace Your obligations under this Public License where the Licensed Rights include other Copyright and Similar Rights.\\\
Section 5 ??? Disclaimer of Warranties and Limitation of Liability.\\\
\\\
Unless otherwise separately undertaken by the Licensor, to the extent possible, the Licensor offers the Licensed Material as-is and as-available, and makes no representations or warranties of any kind concerning the Licensed Material, whether express, implied, statutory, or other. This includes, without limitation, warranties of title, merchantability, fitness for a particular purpose, non-infringement, absence of latent or other defects, accuracy, or the presence or absence of errors, whether or not known or discoverable. Where disclaimers of warranties are not allowed in full or in part, this disclaimer may not apply to You.\\\
To the extent possible, in no event will the Licensor be liable to You on any legal theory (including, without limitation, negligence) or otherwise for any direct, special, indirect, incidental, consequential, punitive, exemplary, or other losses, costs, expenses, or damages arising out of this Public License or use of the Licensed Material, even if the Licensor has been advised of the possibility of such losses, costs, expenses, or damages. Where a limitation of liability is not allowed in full or in part, this limitation may not apply to You.\\\
The disclaimer of warranties and limitation of liability provided above shall be interpreted in a manner that, to the extent possible, most closely approximates an absolute disclaimer and waiver of all liability.\\\
Section 6 ??? Term and Termination.\\\
\\\
This Public License applies for the term of the Copyright and Similar Rights licensed here. However, if You fail to comply with this Public License, then Your rights under this Public License terminate automatically.\\\
Where Your right to use the Licensed Material has terminated under Section 6(a), it reinstates:\\\
\\\
automatically as of the date the violation is cured, provided it is cured within 30 days of Your discovery of the violation; or\\\
upon express reinstatement by the Licensor.\\\
For the avoidance of doubt, this Section 6(b) does not affect any right the Licensor may have to seek remedies for Your violations of this Public License.\\\
For the avoidance of doubt, the Licensor may also offer the Licensed Material under separate terms or conditions or stop distributing the Licensed Material at any time; however, doing so will not terminate this Public License.\\\
Sections 1, 5, 6, 7, and 8 survive termination of this Public License.\\\
Section 7 ??? Other Terms and Conditions.\\\
\\\
The Licensor shall not be bound by any additional or different terms or conditions communicated by You unless expressly agreed.\\\
Any arrangements, understandings, or agreements regarding the Licensed Material not stated herein are separate from and independent of the terms and conditions of this Public License.\\\
Section 8 ??? Interpretation.\\\
\\\
For the avoidance of doubt, this Public License does not, and shall not be interpreted to, reduce, limit, restrict, or impose conditions on any use of the Licensed Material that could lawfully be made without permission under this Public License.\\\
To the extent possible, if any provision of this Public License is deemed unenforceable, it shall be automatically reformed to the minimum extent necessary to make it enforceable. If the provision cannot be reformed, it shall be severed from this Public License without affecting the enforceability of the remaining terms and conditions.\\\
No term or condition of this Public License will be waived and no failure to comply consented to unless expressly agreed to by the Licensor.\\\
Nothing in this Public License constitutes or may be interpreted as a limitation upon, or waiver of, any privileges and immunities that apply to the Licensor or You, including from the legal processes of any jurisdiction or authority.\\\
Creative Commons is not a party to its public licenses. Notwithstanding, Creative Commons may elect to apply one of its public licenses to material it publishes and in those instances will be considered the ???Licensor.??? Except for the limited purpose of indicating that material is shared under a Creative Commons public license or as otherwise permitted by the Creative Commons policies published at creativecommons.org/policies, Creative Commons does not authorize the use of the trademark ???Creative Commons??? or any other trademark or logo of Creative Commons without its prior written consent including, without limitation, in connection with any unauthorized modifications to any of its public licenses or any other arrangements, understandings, or agreements concerning use of licensed material. For the avoidance of doubt, this paragraph does not form part of the public licenses.\\\
\\\
Creative Commons may be contacted at creativecommons.org.\",\
    [ \"Programs/LuaIDE.program/icon\" ] = \"73Lua  \\\
7eIDE  \\\
7    \",\
    [ \"System/Images/Boot/boot2\" ] = \"         8888          \\\
        888888         \\\
        888888         \\\
         8888          \\\
                       \\\
                       \\\
                       \\\
77777788888888888888888\",\
    [ \"Programs/App Store.program/icon\" ] = \"3f    \\\
3f 0ASf \\\
3f    \",\
    [ \"Programs/Games/Maze3D.program/Views/main.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"Toolbar\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"InheritView\\\"]=\\\"toolbar\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=3,\\\
      [\\\"Width\\\"]=\\\"100%,-4\\\",\\\
      [\\\"Height\\\"]=3,\\\
      [\\\"Name\\\"]=\\\"Label\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"To save disc space, OneOS does not come with Maze3D downloaded by default. Do you want to download it now?\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"100%,-6\\\",\\\
      [\\\"Name\\\"]=\\\"YesButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Yes\\\",\\\
      [\\\"BackgroundColour\\\"]=8192,\\\
      [\\\"TextColour\\\"]=1\\\
    },\\\
    [4]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"100%,-11\\\",\\\
      [\\\"Name\\\"]=\\\"NoButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"No\\\",\\\
      [\\\"BackgroundColour\\\"]=16384,\\\
      [\\\"TextColour\\\"]=1\\\
    },\\\
  },\\\
  [\\\"BackgroundColour\\\"]=1,\\\
  [\\\"ToolBarColour\\\"] = 128,\\\
  [\\\"ToolBarTextColour\\\"] = 1\\\
}\",\
    [ \"Desktop/Sketch.shortcut\" ] = \"/Programs/Sketch.program/\",\
    [ \"Programs/Games/Lasers.program/startup\" ] = \"OneOS.LoadAPI('/System/API/Bedrock.lua', false)\\\
\\\
local program = Bedrock:Initialise()\\\
\\\
program:ObjectClick('YesButton', function(self, event, side, x, y)\\\
	OneOS.Run('/Programs/App Store.program/', 'install', 58, 'Games', true)\\\
	OneOS.Close()\\\
end)\\\
\\\
program:ObjectClick('NoButton', function(self, event, side, x, y)\\\
	OneOS.Close()\\\
end)\\\
\\\
program:Run(function()\\\
	program:LoadView('main')\\\
end)\",\
    [ \"Programs/Quest.program/Objects/CenterView.lua\" ] = \"Inherit = 'View'\\\
\\\
OnUpdate = function(self, value)\\\
	if value == 'Children' or value == 'Width' then\\\
		local y = 1\\\
		for i, v in ipairs(self.Children) do\\\
			v.Y = y\\\
			y = y + v.Height\\\
			v.X = math.floor((self.Width - v.Width) / 2) + 1\\\
		end\\\
		self.Height = y - 1\\\
	end\\\
end\",\
    [ \"System/Images/Icons/unknown\" ] = \"08----\\\
08----\\\
08----\",\
    [ \"Programs/Transmit.program/Images/computer\" ] = \"4f     \\\
4f f4>0_f 4 \\\
4f f   4 \\\
4f   - \",\
    [ \"Programs/Quest.program/Elements/SecureTextInput.lua\" ] = \"Inherit = 'TextInput'\\\
\\\
UpdateValue = function(self)\\\
	self.Value = hash.sha256(self.Object.Text)\\\
end\\\
\\\
OnCreateObject = function(self, parentObject, y)\\\
	return {\\\
		Element = self,\\\
		Y = y,\\\
		X = 1,\\\
		Width = self.Width,\\\
		Type = \\\"SecureTextBox\\\",\\\
		Text = self.Value,\\\
		TextColour = self.TextColour,\\\
		BackgroundColour = self.BackgroundColour,\\\
		SelectedBackgroundColour = self.SelectedBackgroundColour,\\\
		SelectedTextColour = self.SelectedTextColour,\\\
		PlaceholderTextColour = self.PlaceholderTextColour,\\\
		Placeholder = self.Placeholder,\\\
		InputName = self.InputName,\\\
		OnChange = function(_self, event, keychar)\\\
			if keychar == keys.tab or keychar == keys.enter then\\\
				local form = self\\\
				local step = 0\\\
				while form.Tag ~= 'form' and step < 50 do\\\
					form = form.Parent\\\
				end\\\
				if keychar == keys.tab then\\\
					if form and form.Object and form.Object.OnTab then\\\
						form.Object:OnTab()\\\
					end\\\
				else\\\
					if form and form.Submit then\\\
						form:Submit(true)\\\
					end\\\
				end\\\
			end\\\
		end\\\
	}\\\
end\",\
    [ \"Programs/Quest.program/Objects/SelectView.lua\" ] = \"Inherit = 'Button'\\\
MenuItems = nil\\\
Children = {}\\\
Selected = nil\\\
\\\
OnUpdate = function(self, value)\\\
	if value == 'Height' and self.Height ~= 1 then\\\
		self.Height = 1\\\
	end\\\
end\\\
\\\
Select = function(self, index)\\\
	if self.MenuItems[index] then\\\
		local text = self.MenuItems[index].Text\\\
		for i = 1, self.Width - 3 - #text do\\\
			text = text .. ' '\\\
		end\\\
		text = text .. 'V'\\\
		self.Text = text\\\
		self.Selected = index\\\
	end\\\
end\\\
\\\
OnInitialise = function(self)\\\
	self:ClearMenuItems()\\\
end\\\
\\\
ClearMenuItems = function(self)\\\
	self.MenuItems = {}\\\
end\\\
\\\
AddMenuItem = function(self, item)\\\
	table.insert(self.MenuItems, item)\\\
	if not self.Selected then\\\
		if #self.MenuItems ~= 0 then\\\
			self:Select(1)\\\
		end\\\
	end\\\
end\\\
\\\
OnClick = function(self, event, side, x, y)\\\
	if self:ToggleMenu({\\\
		Type = \\\"Menu\\\",\\\
		HideTop = true,\\\
		Children = self.MenuItems\\\
	}, x, 1) then\\\
		for i, child in ipairs(self.Bedrock.Menu.Children) do\\\
			child.OnClick = function(_self, event, side, x, y)\\\
				self:Select(i)\\\
			end\\\
		end\\\
	end\\\
end\",\
    [ \"System/Programs/Settings.program/Views/main.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"Toolbar\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"InheritView\\\"]=\\\"toolbar\\\"\\\
    },\\\
  },\\\
  [\\\"BackgroundColour\\\"]=1,\\\
  [\\\"ToolBarColour\\\"]=128,\\\
  [\\\"ToolBarTextColour\\\"]=1\\\
}\",\
    [ \"System/Views/password.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Y\\\"]=\\\"50%,-4\\\",\\\
      [\\\"Width\\\"]=\\\"100%\\\",\\\
      [\\\"Height\\\"]=8,\\\
      [\\\"BackgroundColour\\\"]=8,\\\
    },\\\
    [2]={\\\
      [\\\"Type\\\"]=\\\"SecureTextBox\\\",\\\
      [\\\"X\\\"]=\\\"50%,-9\\\",\\\
      [\\\"Y\\\"]=\\\"50%\\\",\\\
      [\\\"Placeholder\\\"]=\\\"Password...\\\",\\\
      [\\\"Width\\\"]=18,\\\
      [\\\"BackgroundColour\\\"]=1\\\
    },\\\
    [3]={\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"X\\\"]=\\\"50%,-6\\\",\\\
      [\\\"Y\\\"]=\\\"50%, -2\\\",\\\
      [\\\"Text\\\"]=\\\"Please Login\\\",\\\
      [\\\"TextColour\\\"]=1\\\
    },\\\
    [4]={\\\
      [\\\"Name\\\"]=\\\"ExitButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"X\\\"]=\\\"100%\\\",\\\
      [\\\"Y\\\"]=\\\"50%,-4\\\",\\\
      [\\\"Width\\\"]=1,\\\
      [\\\"Text\\\"]=\\\"x\\\",\\\
      [\\\"TextColour\\\"]=2048,\\\
      [\\\"BackgroundColour\\\"]=0,\\\
    },\\\
  }\\\
}\",\
    [ \"System/Programs/Settings.program/startup\" ] = \"OneOS.LoadAPI('/System/API/Bedrock.lua', false)\\\
OneOS.LoadAPI('/System/API/Hash.lua')\\\
\\\
local program = Bedrock:Initialise()\\\
\\\
--TODO: monitor side setting\\\
\\\
function changePassword(callback)\\\
	program:DisplayTextBoxWindow('Enter Password', 'Please enter your new password.', function(success, password)\\\
		if success then\\\
			OneOS.Settings:SetValue('Password', Hash.sha256(password))\\\
		end\\\
		if callback then\\\
			callback(success)\\\
		end\\\
	end)\\\
end\\\
\\\
program:Run(function()\\\
	program:LoadView('main')\\\
	local startX = 2\\\
	local startY = 5\\\
	local controlX = startX + 16\\\
	local settings = OneOS.Settings.Defaults\\\
\\\
	local values = OneOS.Settings:GetValues()\\\
	for k, v in pairs(settings) do\\\
		if k ~= 'Monitor' then\\\
			program:AddObject({\\\
				Type = 'Label',\\\
				X = startX,\\\
				Y = startY,\\\
				Text = v.Label\\\
			})\\\
			local value = values[k]\\\
			if v.Type == 'Bool' then\\\
				settings[k].Control = program:AddObject({\\\
					Type = 'Button',\\\
					X = controlX,\\\
					Y = startY,\\\
					Width = (value and 5 or 4),\\\
					BackgroundColour = colours.red,\\\
					ActiveBackgroundColour = colours.green,\\\
					TextColour = colours.white,\\\
					Text = (value and 'Yes' or 'No'),\\\
					Toggle = value,\\\
					OnClick = function(self)\\\
						if self.Toggle then\\\
							self.Text = 'Yes'\\\
							self.Width = 5\\\
						else\\\
							self.Text = 'No'\\\
							self.Width = 4\\\
						end\\\
						OneOS.Settings:SetValue(k, self.Toggle)\\\
					end\\\
				})\\\
			elseif v.Type == 'Password' then\\\
				settings[k].Controls = {\\\
\\\
					program:AddObject({\\\
						Type = 'Button',\\\
						X = controlX,\\\
						Y = startY,\\\
						Width = ((value ~= nil) and 5 or 4),\\\
						BackgroundColour = colours.red,\\\
						ActiveBackgroundColour = colours.green,\\\
						TextColour = colours.white,\\\
						Text = ((value ~= nil) and 'Yes' or 'No'),\\\
						Toggle = (value ~= nil),\\\
						OnClick = function(self)\\\
							if self.Toggle then\\\
								self.Text = 'Yes'\\\
								self.Width = 5\\\
								changePassword(function(success)\\\
									if not success then\\\
										self.Toggle = false\\\
										self:OnClick()\\\
									end\\\
								end)\\\
							else\\\
								self.Text = 'No'\\\
								self.Width = 4\\\
								OneOS.Settings:SetValue('Password', nil)\\\
							end\\\
							settings[k].Controls[2].Visible = self.Toggle\\\
						end\\\
					}),\\\
\\\
					program:AddObject({\\\
						Type = 'Button',\\\
						X = controlX +  6,\\\
						Y = startY,\\\
						Text = 'Change',\\\
						Visible = (value ~= nil),\\\
						OnClick = function(self)\\\
							changePassword()\\\
						end\\\
					}),\\\
\\\
				}\\\
			elseif v.Type == 'Colour' then\\\
				local x = controlX\\\
				_colours = {\\\
					colours.brown,\\\
					colours.yellow,\\\
					colours.orange,\\\
					colours.red,\\\
					colours.green,\\\
					colours.lime,\\\
					colours.magenta,\\\
					colours.pink,\\\
					colours.purple,\\\
					colours.blue,\\\
					colours.cyan,\\\
					colours.lightBlue,\\\
					colours.lightGrey,\\\
					colours.grey,\\\
					colours.black,\\\
					colours.white\\\
				}\\\
				for i, c in ipairs(_colours) do\\\
					local txt = ''\\\
					if c == colours.white then\\\
						txt = '##'\\\
					end\\\
					settings[k].Controls[i] = program:AddObject({\\\
						Type = 'Button',\\\
						X = x,\\\
						Y = startY,\\\
						Width = 2,\\\
						BackgroundColour = c,\\\
						TextColour = colours.lightGrey,\\\
						Text = txt,\\\
						OnClick = function(self)\\\
							OneOS.Settings:SetValue(k, c)\\\
						end\\\
					})\\\
					x = x + 2\\\
				end\\\
					\\\
\\\
			elseif v.Type == 'Text' then\\\
				settings[k].Control = program:AddObject({\\\
					Type = 'TextBox',\\\
					X = controlX,\\\
					Y = startY,\\\
					Width = 23,\\\
					Text = value,\\\
					OnChange = function(self)\\\
						OneOS.Settings:SetValue(k, settings[k].Control.Text)\\\
					end\\\
				})\\\
			elseif v.Type == 'Program' then\\\
				local txt = value\\\
				if not value then\\\
					txt = 'None'\\\
				else\\\
					txt = program.Helpers.RemoveExtension(txt)\\\
				end\\\
\\\
				settings[k].Control = program:AddObject({\\\
					Type = 'Button',\\\
					X = controlX,\\\
					Y = startY,\\\
					BackgroundColour = colours.grey,\\\
					TextColour = colours.white,\\\
					Text = txt,\\\
					Name = 'ProgramButton',\\\
					OnClick = function(self)\\\
						local items = {\\\
							{\\\
						    	[\\\"Name\\\"]=\\\"MenuItem\\\",\\\
						    	[\\\"Type\\\"]=\\\"Button\\\",\\\
						    	[\\\"Text\\\"]=\\\"None\\\",\\\
						    	OnClick = function()\\\
						    		OneOS.Settings:SetValue(k, nil)\\\
									self.Text = \\\"None\\\"\\\
						    	end\\\
						    }\\\
						}\\\
\\\
						for i, _v in ipairs(OneOS.FS.list('/Programs/')) do\\\
							if program.Helpers.Extension(_v) == 'program' then\\\
								table.insert(items, \\\
								{\\\
							    	[\\\"Name\\\"]=\\\"MenuItem\\\",\\\
							    	[\\\"Type\\\"]=\\\"Button\\\",\\\
							    	[\\\"Text\\\"]=program.Helpers.RemoveExtension(_v),\\\
									OnClick = function(btn)\\\
										OneOS.Settings:SetValue(k, _v)\\\
										self.Text = btn.Text\\\
									end\\\
								})\\\
							end\\\
						end\\\
						\\\
						self:ToggleMenu({\\\
							[\\\"Type\\\"]=\\\"Menu\\\",\\\
							[\\\"HideTop\\\"] = true,\\\
							[\\\"Owner\\\"]=\\\"OneButton\\\",\\\
							[\\\"Children\\\"]=items\\\
						})\\\
					end\\\
				})\\\
			end\\\
			startY = startY + 2\\\
		end\\\
	end\\\
end)\",\
    [ \"Programs/Ink.program/Icons/txt\" ] = \"07text\\\
07----\\\
07----\",\
    [ \"System/Views/onemenu.view\" ] = \"{\\\
  [\\\"Type\\\"]=\\\"Menu\\\",\\\
  [\\\"HideTop\\\"] = true,\\\
  [\\\"Owner\\\"]=\\\"OneButton\\\",\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Name\\\"]=\\\"DesktopMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Desktop\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Name\\\"]=\\\"AboutMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"About OneOS\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Name\\\"]=\\\"SettingsMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Settings\\\"\\\
    },\\\
    [4]={\\\
      [\\\"Name\\\"]=\\\"Separator\\\",\\\
      [\\\"Type\\\"]=\\\"Separator\\\"\\\
    },\\\
    [5]={\\\
      [\\\"Name\\\"]=\\\"UpdateMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Update OneOS\\\"\\\
    },\\\
    [6]={\\\
      [\\\"Name\\\"]=\\\"Separator\\\",\\\
      [\\\"Type\\\"]=\\\"Separator\\\"\\\
    },\\\
    [7]={\\\
      [\\\"Name\\\"]=\\\"RestartMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Restart\\\"\\\
    },\\\
    [8]={\\\
      [\\\"Name\\\"]=\\\"ShutdownMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Shutdown\\\"\\\
    },\\\
  },\\\
}\",\
    [ \"Programs/Quest Server.program/Views/nomodem.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=\\\"50%,-2\\\",\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Width\\\"]=\\\"100%\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"No Modem Attached!\\\",\\\
      [\\\"TextColour\\\"]=16384,\\\
      [\\\"Align\\\"]=\\\"Center\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=\\\"50%\\\",\\\
      [\\\"X\\\"]=\\\"10%\\\",\\\
      [\\\"Width\\\"]=\\\"80%\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Please attach a wireless modem to use Quest Server.\\\",\\\
      [\\\"Align\\\"]=\\\"Center\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"100%,-6\\\",\\\
      [\\\"Name\\\"]=\\\"QuitButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Quit\\\",\\\
    },\\\
  },\\\
  [\\\"BackgroundColour\\\"]=1,\\\
  [\\\"ToolBarColour\\\"]=1,\\\
  [\\\"ToolBarTextColour\\\"]=32768\\\
}\",\
    [ \"Programs/Games/Redirection.program/startup\" ] = \"OneOS.LoadAPI('/System/API/Bedrock.lua', false)\\\
\\\
local program = Bedrock:Initialise()\\\
\\\
program:ObjectClick('YesButton', function(self, event, side, x, y)\\\
	OneOS.Run('/Programs/App Store.program/', 'install', 76, 'Games', true)\\\
	OneOS.Close()\\\
end)\\\
\\\
program:ObjectClick('NoButton', function(self, event, side, x, y)\\\
	OneOS.Close()\\\
end)\\\
\\\
program:Run(function()\\\
	program:LoadView('main')\\\
end)\",\
    [ \"System/Views/main.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Name\\\"]=\\\"SearchView\\\",\\\
      [\\\"Type\\\"]=\\\"SearchView\\\",\\\
      [\\\"X\\\"]=\\\"100%,-19\\\",\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"Width\\\"]=20,\\\
      [\\\"Height\\\"]=\\\"100%\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Name\\\"]=\\\"ClickCatcherView\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"Width\\\"]=\\\"100%\\\",\\\
      [\\\"Height\\\"]=\\\"100%\\\",\\\
      [\\\"BackgroundColour\\\"]=0,\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Width\\\"]=\\\"100%\\\",\\\
      [\\\"Height\\\"]=\\\"100%,-1\\\",\\\
      [\\\"Name\\\"]=\\\"ProgramView\\\",\\\
      [\\\"Type\\\"]=\\\"ProgramView\\\",\\\
      [\\\"Active\\\"]=true,\\\
    },\\\
    [4]={\\\
      [\\\"Name\\\"]=\\\"CentrePoint\\\",\\\
      [\\\"Type\\\"]=\\\"CentrePoint\\\",\\\
      [\\\"InheritView\\\"]=\\\"centrepoint\\\",\\\
      [\\\"Visible\\\"]=false,\\\
    },\\\
    [5]={\\\
      [\\\"Name\\\"]=\\\"Overlay\\\",\\\
      [\\\"Type\\\"]=\\\"Overlay\\\",\\\
      [\\\"InheritView\\\"]=\\\"overlay\\\",\\\
    },\\\
    [6]={\\\
      [\\\"Name\\\"]=\\\"LoginView\\\",\\\
      [\\\"Type\\\"]=\\\"LoginView\\\",\\\
      [\\\"InheritView\\\"]=\\\"password\\\",\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"Width\\\"]=\\\"100%\\\",\\\
      [\\\"Height\\\"]=\\\"100%\\\",\\\
      [\\\"Visible\\\"]=false,\\\
    },\\\
  }\\\
}\",\
    [ \"System/Programs/Files.program/Views/toolbar.view\" ] = \"{\\\
  [\\\"Width\\\"]=\\\"100%\\\",\\\
  [\\\"Height\\\"]=3,\\\
  [\\\"Type\\\"]=\\\"View\\\",\\\
  [\\\"BackgroundColour\\\"]=256,\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=2,\\\
      [\\\"Name\\\"]=\\\"BackButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Enabled\\\"]=false,\\\
      [\\\"TextColour\\\"]=128,\\\
      [\\\"Text\\\"]=\\\"<\\\",\\\
      [\\\"BackgroundColour\\\"]=1\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=6,\\\
      [\\\"Name\\\"]=\\\"ForwardButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Enabled\\\"]=false,\\\
      [\\\"TextColour\\\"]=128,\\\
      [\\\"Text\\\"]=\\\">\\\",\\\
      [\\\"BackgroundColour\\\"]=1\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=11,\\\
      [\\\"Name\\\"]=\\\"GoUpButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"TextColour\\\"]=128,\\\
      [\\\"Text\\\"]=\\\"Up\\\",\\\
      [\\\"BackgroundColour\\\"]=1\\\
    },\\\
    [4]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=\\\"100%,-3\\\",\\\
      [\\\"Name\\\"]=\\\"OptionsButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"#\\\",\\\
      [\\\"TextColour\\\"]=128,\\\
      [\\\"BackgroundColour\\\"]=1\\\
    },\\\
  },\\\
}\",\
    [ \"Programs/Quest.program/Pages/7.ccml\" ] = \"<!DOCTYPE ccml>\\\
<html>\\\
	<head>\\\
	  <title>No Modem Connected</title>\\\
	</head>\\\
	<body>\\\
		<br/>\\\
		<br/>\\\
		<h colour=\\\"red\\\">No Modem Connected</h>\\\
		<br/>\\\
		<center>\\\
			<br>\\\
			<p width=\\\"38\\\" align=\\\"center\\\">Please attach a wirelss modem and restart Quest.</p>\\\
		</center>\\\
	</body>\\\
</html>\",\
    [ \"System/Programs/Files.program/Objects/FileView.lua\" ] = \"Inherit = 'View'\\\
\\\
BackgroundColour = colours.transparent\\\
Path = ''\\\
Width = 10\\\
Height = 4\\\
ClickTime = nil\\\
\\\
OnLoad = function(self)\\\
	self.Width = 10\\\
	self.Height = 4\\\
	local image = self:AddObject({\\\
		Type = 'ImageView',\\\
		X = 4,\\\
		Y = 1,\\\
		Width = 4,\\\
		Height = 3,\\\
		Image = OneOS.Helpers.IconForFile(self.Path),\\\
		Name = 'ImageView'..fs.getName(self.Path)\\\
	})\\\
	local label = self:AddObject({\\\
		Type = 'Label',\\\
		X = 1,\\\
		Y = 4,\\\
		Width = 10,\\\
		Text = self.Bedrock.Helpers.TruncateString(self.Bedrock.Helpers.RemoveExtension(fs.getName(self.Path)), 10),\\\
		Align = 'Center',\\\
		Name = 'Label'..fs.getName(self.Path)\\\
	})\\\
\\\
	if self.Bedrock.Helpers.Extension(self.Path) == 'shortcut' then\\\
		self:AddObject({\\\
			Type = 'Label',\\\
			X = 7,\\\
			Y = 3,\\\
			Width = 1,\\\
			Text = '>',\\\
			BackgroundColour=colours.white,\\\
			Name = 'ShortcutLabel'\\\
		})\\\
	end\\\
	local click = function(obj, event, side, x, y)\\\
		--local settings = OneOS.Settings or Settings\\\
		local setting = false\\\
		if OneOS then\\\
			setting = OneOS.Settings:GetValues()['DoubleClick']\\\
		else\\\
			setting = Settings:GetValues()['DoubleClick'] \\\
		end\\\
		--s:GetValues()['DoubleClick']\\\
		if side == 1 and setting and (not self.ClickTime or os.clock() - self.ClickTime <= 0.5) then\\\
			self.ClickTime = os.clock()\\\
		else\\\
			self:OnClick(event, side, x, y, obj)\\\
		end\\\
	end\\\
\\\
	label.OnClick = click\\\
	image.OnClick = click\\\
\\\
end\",\
    [ \"Programs/Quest.program/Elements/ButtonInput.lua\" ] = \"BackgroundColour = colours.lightGrey\\\
TextColour = colours.black\\\
Text = 'Submit'\\\
InputName = ''\\\
\\\
OnInitialise = function(self, node)\\\
	local attr = self.Attributes\\\
	if attr.value then\\\
		self.Text = attr.value\\\
	end\\\
\\\
	if attr.name then\\\
		self.InputName = attr.name\\\
	end\\\
\\\
	if not attr.width then\\\
		self.Width = #self.Text + 2\\\
	end\\\
end\\\
\\\
UpdateValue = function(self, force)\\\
	if force then\\\
		self.Value = self.Object.Text\\\
	end\\\
end\\\
\\\
CreateObject = function(self, parentObject, y)\\\
	return parentObject:AddObject({\\\
		Element = self,\\\
		Y = y,\\\
		X = 1,\\\
		Width = self.Width,\\\
		Type = \\\"Button\\\",\\\
		Text = self.Text,\\\
		TextColour = self.TextColour,\\\
		BackgroundColour = self.BackgroundColour,\\\
		InputName = self.InputName,\\\
		OnClick = function(_self, event, side, x, y)\\\
			local form = self\\\
			local step = 0\\\
			while form.Tag ~= 'form' and step < 50 do\\\
				form = form.Parent\\\
			end\\\
			self.Value = _self.Text\\\
			if form and form.Submit then\\\
				form:Submit()\\\
			end\\\
		end\\\
	})\\\
end\",\
    [ \"System/Programs/Update OneOS.program/startup\" ] = \"OneOS.Log.i('Starting update')\\\
local mainTitle = 'OneOS Updater'\\\
local subTitle = 'Please wait...'\\\
\\\
OneOS.CanClose = function()\\\
	return false\\\
end\\\
\\\
function Draw()\\\
	sleep(0)\\\
	term.setBackgroundColour(colours.white)\\\
	term.clear()\\\
	local w, h = term.getSize()\\\
	term.setTextColour(colours.lightBlue)\\\
	term.setCursorPos(math.ceil((w-#mainTitle)/2), 8)\\\
	term.write(mainTitle)\\\
	term.setTextColour(colours.blue)\\\
	term.setCursorPos(math.ceil((w-#subTitle)/2), 10)\\\
	term.write(subTitle)\\\
end\\\
\\\
tArgs = {...}\\\
\\\
Settings = {\\\
	InstallPath = '/', --Where the program's installed, don't always asume root (if it's run under something like OneOS)\\\
	Hidden = false, --Whether or not the update is hidden (doesn't write to the screen), useful for background updates\\\
	GitHubUsername = 'oeed', --Your GitHub username as it appears in the URL\\\
	GitHubRepoName = 'OneOS', --The repo name as it appears in the URL\\\
	DownloadReleases = true, --If true it will download the latest release, otherwise it will download the files as they currently appear\\\
	UpdateFunction = nil, --Sent when something happens (file downloaded etc.)\\\
	TotalBytes = 0, --Do not change this value (especially programatically)!\\\
	DownloadedBytes = 0, --Do not change this value (especially programatically)!\\\
	Status = '',\\\
	SecondaryStatus = '',\\\
}\\\
\\\
OneOS.LoadAPI('/System/JSON')\\\
if JSON then\\\
	OneOS.Log.i('Loaded JSON')\\\
else\\\
	error('Failed to load JSON API')\\\
end\\\
\\\
function downloadJSON(path)\\\
	local _json = http.get(path)\\\
	if not _json then\\\
		error('Could not download: '..path..' Check your connection.')\\\
	end\\\
	return JSON.decode(_json.readAll())\\\
end\\\
\\\
if http then\\\
	subTitle = 'HTTP enabled, attempting update...'\\\
	Draw()\\\
else\\\
	subTitle = 'HTTP is required to update.'\\\
	Draw()\\\
	error('')\\\
end\\\
\\\
subTitle = 'Determining Latest Version'\\\
Draw()\\\
local releases = downloadJSON('https://api.github.com/repos/'..Settings.GitHubUsername..'/'..Settings.GitHubRepoName..'/releases')\\\
local latestReleaseTag = nil\\\
for i, v in ipairs(releases) do\\\
	if not v.prerelease then\\\
		latestReleaseTag = v.tag_name\\\
		break\\\
	end\\\
end\\\
subTitle = 'Optaining Latest Version URL'\\\
Draw()\\\
local refs = downloadJSON('https://api.github.com/repos/'..Settings.GitHubUsername..'/'..Settings.GitHubRepoName..'/git/refs/tags/'..latestReleaseTag)\\\
local latestReleaseSha = refs.object.sha\\\
\\\
subTitle = 'Downloading File Listing'\\\
Draw()\\\
\\\
local tree = downloadJSON('https://api.github.com/repos/'..Settings.GitHubUsername..'/'..Settings.GitHubRepoName..'/git/trees/'..latestReleaseSha..'?recursive=1').tree\\\
\\\
local blacklist = {\\\
	'/.gitignore',\\\
	'/README.md',\\\
	'/TODO',\\\
	'/Desktop/.Desktop.settings',\\\
	'/.version'\\\
}\\\
\\\
function isBlacklisted(path)\\\
	for i, item in ipairs(blacklist) do\\\
		if item == path then\\\
			return true\\\
		end\\\
	end\\\
	return false\\\
end\\\
\\\
Settings.TotalFiles = 0\\\
Settings.TotalBytes = 0\\\
for i, v in ipairs(tree) do\\\
	if not isBlacklisted(Settings.InstallPath..v.path) and v.size then\\\
		Settings.TotalBytes = Settings.TotalBytes + v.size\\\
		Settings.TotalFiles = Settings.TotalFiles + 1\\\
	end\\\
end\\\
\\\
Settings.DownloadedBytes = 0\\\
Settings.DownloadedFiles = 0\\\
function downloadBlob(v)\\\
	if isBlacklisted(Settings.InstallPath..v.path) then\\\
		return\\\
	end\\\
	if v.type == 'tree' then\\\
		OneOS.Log.i('Making folder: '..'/'..Settings.InstallPath..v.path)\\\
		Draw()\\\
		OneOS.FS.makeDir('/'..Settings.InstallPath..v.path)\\\
	else\\\
		OneOS.Log.i('Starting download for: '..Settings.InstallPath..v.path)\\\
		Draw()\\\
\\\
        local tries, f = 0\\\
        repeat \\\
			f = http.get(('https://raw.github.com/'..Settings.GitHubUsername..'/'..Settings.GitHubRepoName..'/'..latestReleaseTag..Settings.InstallPath..v.path):gsub(' ','%%20'))\\\
                if not f then sleep(5) end\\\
                tries = tries + 1\\\
        until tries > 5 or f\\\
\\\
		if not f then\\\
			error('Downloading failed, try again. '..('https://raw.github.com/'..Settings.GitHubUsername..'/'..Settings.GitHubRepoName..'/'..latestReleaseTag..Settings.InstallPath..v.path):gsub(' ','%%20'))\\\
		end\\\
\\\
		local h = OneOS.FS.open('/'..Settings.InstallPath..v.path, 'w')\\\
		h.write(f.readAll())\\\
		h.close()\\\
		OneOS.Log.i('Downloaded File: '..'/'..Settings.InstallPath..v.path)\\\
		subTitle = 'Downloading: ' .. math.floor(100*(Settings.DownloadedFiles/Settings.TotalFiles))..'%' -- using the number of files over the number of bytes actually appears to be more accurate, the connection takes longer than sending the data\\\
		Draw()\\\
		if v.size then\\\
			Settings.DownloadedBytes = Settings.DownloadedBytes + v.size\\\
			Settings.DownloadedFiles = Settings.DownloadedFiles + 1\\\
		end\\\
	end\\\
end\\\
\\\
local connectionLimit = 5\\\
local downloads = {}\\\
for i, v in ipairs(tree) do\\\
	local queueNumber = math.ceil(i / connectionLimit)\\\
	if not downloads[queueNumber] then\\\
		downloads[queueNumber] = {}\\\
	end\\\
	table.insert(downloads[queueNumber], function()\\\
		downloadBlob(v)\\\
	end)\\\
end\\\
\\\
for i, queue in ipairs(downloads) do\\\
	parallel.waitForAll(unpack(queue))\\\
end\\\
\\\
local h = OneOS.FS.open('/System/.version', 'w')\\\
h.write(latestReleaseTag)\\\
h.close()\\\
\\\
mainTitle = 'Installation Complete!'\\\
subTitle = 'Rebooting in 1 second...'\\\
Draw()\\\
sleep(1)\\\
\\\
OneOS.Log.i('Done, rebooting now.')\\\
OneOS.KillSystem()\",\
    [ \"System/Programs/Unpackager.program/startup\" ] = \"tArgs = {...}\\\
\\\
if not tArgs[1] or not OneOS.FS.exists(tArgs[1]) then\\\
	OneOS.Close()\\\
end\\\
\\\
OneOS.LoadAPI('/System/API/LegacyDrawing.lua')\\\
local Drawing = LegacyDrawing\\\
Drawing.Clear(colours.white)\\\
Drawing.DrawCharactersCenter(nil, nil, nil, nil, 'Extracting Package...', colours.black, colours.white)\\\
Drawing.DrawBuffer()\\\
\\\
\\\
local packrun, err = OneOS.LoadFile(tArgs[1])\\\
local env = getfenv()\\\
env['installLocation'] = OneOS.Helpers.RemoveFileName(tArgs[1])..'/'\\\
setfenv( packrun, env)\\\
if packrun then\\\
	packrun()\\\
else\\\
	error(err)\\\
	error(tArgs[1])\\\
	error('The package appears to be corrupt.')\\\
end\\\
sleep(0.5)\\\
\\\
Drawing.Clear(colours.white)\\\
Drawing.DrawCharactersCenter(nil, nil, nil, nil, 'Package Extracted', colours.black, colours.white)\\\
Drawing.DrawBuffer()\\\
\\\
sleep(1)\\\
OneOS.Close()\",\
    [ \"Programs/Quest.program/Elements/Element.lua\" ] = \"HasChildren = true\\\
Children = nil\\\
Tag = nil\\\
TextColour = colours.black\\\
BackgroundColour = colours.transparent\\\
Text = nil\\\
Attributes = nil\\\
Width = \\\"100%\\\"\\\
\\\
Initialise = function(self, node)\\\
	local new = {}    -- the new instance\\\
	setmetatable( new, {__index = self} )\\\
	local attr = node._attr\\\
	new.Tag = node._tag\\\
	new.Attributes = attr\\\
	if new.HasChildren then\\\
		new.Children = {}\\\
	end\\\
\\\
	if type(node[1]) == 'string' then\\\
		new.Text = node[1]\\\
	end\\\
	\\\
	if attr.colour then\\\
		new.TextColour = self:ParseColour(attr.colour)\\\
	elseif attr.color then\\\
		new.TextColour = self:ParseColour(attr.color)\\\
	end\\\
\\\
	if attr.bgcolour then\\\
		new.BackgroundColour = self:ParseColour(attr.bgcolour)\\\
	elseif attr.bgcolor then\\\
		new.BackgroundColour = self:ParseColour(attr.bgcolor)\\\
	end\\\
\\\
	if attr.height then\\\
		new.Height = attr.height\\\
	end\\\
\\\
	if attr.width then\\\
		new.Width = attr.width\\\
	end\\\
\\\
	if new.OnInitialise then\\\
		new:OnInitialise(node)\\\
	end\\\
\\\
	return new\\\
end\\\
\\\
ParseColour = function(self, str)\\\
	if str and type(str) == 'string' then\\\
		if colours[str] and type(colours[str]) == 'number' then\\\
			return colours[str]\\\
		elseif colors[str] and type(colors[str]) == 'number' then\\\
			return colors[str]\\\
		end\\\
	end\\\
end\\\
\\\
CreateObject = function(self, parentObject, y)\\\
	local object\\\
	if self.OnCreateObject then\\\
		object = self:OnCreateObject()\\\
	else\\\
		object = {\\\
			Element = self,\\\
			Y = y,\\\
			X = 1,\\\
			Width = self.Width,\\\
			Height = self.Height,\\\
			BackgroundColour = self.BackgroundColour,\\\
			Type = \\\"View\\\"\\\
		}\\\
	end\\\
\\\
	if object then\\\
		return parentObject:AddObject(object, parentObject, y)\\\
	end\\\
end\",\
    [ \"System/Programs/Settings.program/logo\" ] = \"0f b    0 \\\
bf      \\\
bf      \\\
0f b    0 \",\
    [ \"System/Programs/Settings.program/Views/toolbar.view\" ] = \"{\\\
  [\\\"Width\\\"]=\\\"100%\\\",\\\
  [\\\"Height\\\"]=3,\\\
  [\\\"Type\\\"]=\\\"View\\\",\\\
  [\\\"BackgroundColour\\\"] = 128,\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=2,\\\
      [\\\"Name\\\"]=\\\"SettingsLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Settings\\\",\\\
      [\\\"TextColour\\\"]=1\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=11,\\\
      [\\\"Name\\\"]=\\\"OneOSLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"OneOS\\\",\\\
      [\\\"TextColour\\\"]=256\\\
    },\\\
  },\\\
}\",\
    [ \"Programs/Transmit.program/Images/anm3\" ] = \" f  7         \\\
 f 7        7   \\\
7f    7       7 \\\
 f  7      7    \\\
 f    7       \",\
    [ \"System/Images/Boot/boot4\" ] = \"         8888          \\\
        888888         \\\
        888888         \\\
         8888          \\\
                       \\\
                       \\\
                       \\\
77777777777788888888888\",\
    [ \"System/Programs/Files.program/Views/main.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"Toolbar\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"InheritView\\\"]=\\\"toolbar\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=4,\\\
      [\\\"X\\\"]=12,\\\
      [\\\"Height\\\"]=\\\"100%,-3\\\",\\\
      [\\\"Name\\\"]=\\\"Separator\\\",\\\
      [\\\"Type\\\"]=\\\"Separator\\\",\\\
      [\\\"Colour\\\"]=256\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=4,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Height\\\"]=\\\"100%,-3\\\",\\\
      [\\\"Width\\\"]=12,\\\
      [\\\"Name\\\"]=\\\"Sidebar\\\",\\\
      [\\\"Type\\\"]=\\\"ListView\\\",\\\
      [\\\"TextColour\\\"]=128,\\\
      [\\\"BackgroundColour\\\"]=0,\\\
      [\\\"TopMargin\\\"]=1,\\\
      [\\\"Items\\\"]={\\\
        [\\\"Places\\\"]={\\\
          {[\\\"Text\\\"] = 'Desktop', [\\\"Path\\\"] = '/Desktop/'},\\\
          {[\\\"Text\\\"] = 'Documents', [\\\"Path\\\"] = '/Desktop/Documents/'},\\\
          {[\\\"Text\\\"] = 'Programs', [\\\"Path\\\"] = '/Programs/'},\\\
          {[\\\"Text\\\"] = 'Computer', [\\\"Path\\\"] = '/'},\\\
        },\\\
        [\\\"Peripherals\\\"]={}\\\
      },\\\
    },\\\
    [4]={\\\
      [\\\"Y\\\"]=4,\\\
      [\\\"X\\\"]=14,\\\
      [\\\"Width\\\"]=\\\"100%,-12\\\",\\\
      [\\\"Name\\\"]=\\\"PathLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"TextColour\\\"]=256,\\\
      [\\\"Text\\\"]=\\\"\\\"\\\
    },\\\
    [5]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=13,\\\
      [\\\"Height\\\"]=\\\"100%,-4\\\",\\\
      [\\\"Width\\\"]=\\\"100%,-12\\\",\\\
      [\\\"Name\\\"]=\\\"FilesCollectionView\\\",\\\
      [\\\"Type\\\"]=\\\"CollectionView\\\",\\\
      [\\\"TextColour\\\"]=128,\\\
      [\\\"BackgroundColour\\\"]=0,\\\
      [\\\"Items\\\"]={}\\\
    },\\\
    [6]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=13,\\\
      [\\\"Height\\\"]=\\\"100%,-4\\\",\\\
      [\\\"Width\\\"]=\\\"100%,-12\\\",\\\
      [\\\"Name\\\"]=\\\"FilesListView\\\",\\\
      [\\\"Type\\\"]=\\\"ListView\\\",\\\
      [\\\"TextColour\\\"]=128,\\\
      [\\\"BackgroundColour\\\"]=0,\\\
      [\\\"Items\\\"]={}\\\
    },\\\
    [7]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=13,\\\
      [\\\"Height\\\"]=\\\"100%,-4\\\",\\\
      [\\\"Width\\\"]=\\\"100%,-12\\\",\\\
      [\\\"Name\\\"]=\\\"FilesPeripheralView\\\",\\\
      [\\\"Type\\\"]=\\\"PeripheralView\\\",\\\
      [\\\"TextColour\\\"]=128,\\\
      [\\\"BackgroundColour\\\"]=0,\\\
      [\\\"Items\\\"]={}\\\
    },\\\
  },\\\
  [\\\"BackgroundColour\\\"]=1,\\\
  [\\\"ToolBarColour\\\"]=256,\\\
  [\\\"ToolBarTextColour\\\"] = 1\\\
}\",\
    [ \"Programs/Sketch.program/Icons/nfp\" ] = \"4f 3bnfp\\\
3f  d  \\\
df    \",\
    [ \"System/Views/searchmenu.view\" ] = \"{\\\
  [\\\"Type\\\"]=\\\"Menu\\\",\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Name\\\"]=\\\"OpenMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Open\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Name\\\"]=\\\"ShowInFilesMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Show In Files\\\"\\\
    },\\\
  },\\\
}\",\
    [ \"Programs/Quest.program/Pages/2.ccml\" ] = \"<!DOCTYPE ccml>\\\
<html>\\\
	<head>\\\
	  <title>Doctype Incorrect</title>\\\
	</head>\\\
	<body>\\\
		<br/>\\\
		<br/>\\\
		<h colour=\\\"red\\\">Doctype Incorrect</h>\\\
		<br/>\\\
		<center>\\\
			<br>\\\
			<p width=\\\"38\\\" align=\\\"center\\\">This page has an incorrect doctype and can not be rendered. Quest can not view standard web pages.</p>\\\
			<br>\\\
			<p width=\\\"38\\\" align=\\\"center\\\" color=\\\"grey\\\">If you made this page make sure the file starts with \\\"&lt;!DOCTYPE ccml&gt;\\\"</p>\\\
		</center>\\\
	</body>\\\
</html>\",\
    [ \"System/Programs/First Setup.program/Views/page6.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"Toolbar\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"InheritView\\\"]=\\\"toolbar\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=3,\\\
      [\\\"Width\\\"]=\\\"100%,-6\\\",\\\
      [\\\"Name\\\"]=\\\"Label\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"All done! OneOS is now all setup and ready for you to use. Click 'Restart' to get going!\\\\n\\\\nIf the restart button does not work then hold Ctrl + R or break and replace your computer.\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"100%,-9\\\",\\\
      [\\\"Name\\\"]=\\\"RestartButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Restart\\\",\\\
      [\\\"BackgroundColour\\\"]=256\\\
    },\\\
    [4]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"3\\\",\\\
      [\\\"Name\\\"]=\\\"BackButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Back\\\",\\\
      [\\\"BackgroundColour\\\"]=256\\\
    },\\\
  },\\\
  [\\\"BackgroundColour\\\"]=1,\\\
  [\\\"ToolBarColour\\\"] = 128,\\\
  [\\\"ToolBarTextColour\\\"] = 1\\\
}\",\
    [ \"Desktop/Files.shortcut\" ] = \"/System/Programs/Files.program/\",\
    [ \".gitignore\" ] = \".DS_Store\\\
.Desktop.settings\\\
.OneOS.settings\\\
*.settings\\\
\\\
Desktop/.Desktop.settings\\\
\\\
.version\\\
\\\
*.settings\\\
\\\
Desktop/.Desktop.settings\\\
\\\
Programs/Quest\\\
\\\
System/.OneOS.settings\\\
\\\
System/.OneOS.settings\\\
\\\
Changes\\\
\\\
System/.fingerprint\\\
\\\
dorelease\\\
\\\
System/main-old.lua\\\
\\\
System/OneOS.log\",\
    [ \"Desktop/Quest.shortcut\" ] = \"/Programs/Quest.program/\",\
    [ \"Programs/Transmit.program/Images/anm0\" ] = \" f  7         \\\
 f 7        7   \\\
7f    7       7 \\\
 f  7      7    \\\
 f    e       \",\
    [ \"System/Programs/First Setup.program/Views/page5.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"Toolbar\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"InheritView\\\"]=\\\"toolbar\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=3,\\\
      [\\\"Width\\\"]=\\\"100%,-6\\\",\\\
      [\\\"Name\\\"]=\\\"Label\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"If you want a password enter it, otherwise leave the text box blank.\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=\\\"9\\\",\\\
      [\\\"X\\\"]=\\\"25%\\\",\\\
      [\\\"Width\\\"]=\\\"50%\\\",\\\
      [\\\"Name\\\"]=\\\"PasswordTextBox\\\",\\\
      [\\\"Type\\\"]=\\\"SecureTextBox\\\",\\\
      [\\\"Placeholder\\\"]=\\\"Password\\\",\\\
      [\\\"BackgroundColour\\\"]=256,\\\
      [\\\"Active\\\"]=true\\\
    },\\\
    [4]={\\\
      [\\\"Y\\\"]=\\\"11\\\",\\\
      [\\\"X\\\"]=\\\"25%\\\",\\\
      [\\\"Width\\\"]=\\\"50%\\\",\\\
      [\\\"Name\\\"]=\\\"ConfirmPasswordTextBox\\\",\\\
      [\\\"Type\\\"]=\\\"SecureTextBox\\\",\\\
      [\\\"Placeholder\\\"]=\\\"Confirm Password\\\",\\\
      [\\\"BackgroundColour\\\"]=256,\\\
    },\\\
    [5]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"100%,-7\\\",\\\
      [\\\"Name\\\"]=\\\"PasswordNextButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Next\\\",\\\
      [\\\"BackgroundColour\\\"]=256\\\
    },\\\
    [6]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"3\\\",\\\
      [\\\"Name\\\"]=\\\"BackButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Back\\\",\\\
      [\\\"BackgroundColour\\\"]=256\\\
    },\\\
    [7]={\\\
      [\\\"Y\\\"]=13,\\\
      [\\\"X\\\"]=3,\\\
      [\\\"Width\\\"]=\\\"100%,-6\\\",\\\
      [\\\"Name\\\"]=\\\"NoMatchLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"TextColour\\\"]=16384,\\\
      [\\\"Align\\\"]=\\\"Center\\\",\\\
      [\\\"Text\\\"]=\\\"Passwords do not match!\\\",\\\
      [\\\"Visible\\\"]=false\\\
    },\\\
  },\\\
  [\\\"BackgroundColour\\\"]=1,\\\
  [\\\"ToolBarColour\\\"] = 128,\\\
  [\\\"ToolBarTextColour\\\"] = 1\\\
}\",\
    [ \"System/Programs/First Setup.program/Views/page4.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"Toolbar\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"InheritView\\\"]=\\\"toolbar\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=3,\\\
      [\\\"Width\\\"]=\\\"100%,-6\\\",\\\
      [\\\"Name\\\"]=\\\"Label\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Do you want to use animations?\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=7,\\\
      [\\\"X\\\"]=3,\\\
      [\\\"Width\\\"]=\\\"100%,-6\\\",\\\
      [\\\"Name\\\"]=\\\"Label\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Not recommended for use on servers or slow computers.\\\",\\\
      [\\\"TextColour\\\"]=256\\\
    },\\\
    [4]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"100%,-6\\\",\\\
      [\\\"Name\\\"]=\\\"YesButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Yes\\\",\\\
      [\\\"BackgroundColour\\\"]=8192,\\\
      [\\\"TextColour\\\"]=1\\\
    },\\\
    [5]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"100%,-11\\\",\\\
      [\\\"Name\\\"]=\\\"NoButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"No\\\",\\\
      [\\\"BackgroundColour\\\"]=16384,\\\
      [\\\"TextColour\\\"]=1\\\
    },\\\
    [6]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"3\\\",\\\
      [\\\"Name\\\"]=\\\"BackButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Back\\\",\\\
      [\\\"BackgroundColour\\\"]=256\\\
    },\\\
  },\\\
  [\\\"BackgroundColour\\\"]=1,\\\
  [\\\"ToolBarColour\\\"] = 128,\\\
  [\\\"ToolBarTextColour\\\"] = 1\\\
}\",\
    [ \"System/Programs/First Setup.program/Views/page3.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"Toolbar\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"InheritView\\\"]=\\\"toolbar\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=3,\\\
      [\\\"Width\\\"]=\\\"100%,-6\\\",\\\
      [\\\"Name\\\"]=\\\"Label\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Pick a desktop background colour.\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"100%,-7\\\",\\\
      [\\\"Name\\\"]=\\\"NextButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Next\\\",\\\
      [\\\"BackgroundColour\\\"]=256\\\
    },\\\
    [4]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"3\\\",\\\
      [\\\"Name\\\"]=\\\"BackButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Back\\\",\\\
      [\\\"BackgroundColour\\\"]=256\\\
    },\\\
    [5]={\\\
      [\\\"Y\\\"]=7,\\\
      [\\\"X\\\"]=\\\"50%,-18\\\",\\\
      [\\\"Width\\\"] = 4,\\\
      [\\\"Height\\\"] = 3,\\\
      [\\\"Name\\\"]=\\\"ColourWell\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"BackgroundColour\\\"]=512\\\
    },\\\
    [6]={\\\
      [\\\"Y\\\"]=8,\\\
      [\\\"X\\\"]=\\\"50%,-13\\\",\\\
      [\\\"Width\\\"] = 2,\\\
      [\\\"Height\\\"] = 1,\\\
      [\\\"Name\\\"]=\\\"ColourButton\\\",\\\
      [\\\"Momentary\\\"]=false,\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"BackgroundColour\\\"]=4096\\\
    },\\\
    [7]={\\\
      [\\\"Y\\\"]=8,\\\
      [\\\"X\\\"]=\\\"50%,-11\\\",\\\
      [\\\"Width\\\"] = 2,\\\
      [\\\"Height\\\"] = 1,\\\
      [\\\"Name\\\"]=\\\"ColourButton\\\",\\\
      [\\\"Momentary\\\"]=false,\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"BackgroundColour\\\"]=16\\\
    },\\\
    [8]={\\\
      [\\\"Y\\\"]=8,\\\
      [\\\"X\\\"]=\\\"50%,-9\\\",\\\
      [\\\"Width\\\"] = 2,\\\
      [\\\"Height\\\"] = 1,\\\
      [\\\"Name\\\"]=\\\"ColourButton\\\",\\\
      [\\\"Momentary\\\"]=false,\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"BackgroundColour\\\"]=2\\\
    },\\\
    [9]={\\\
      [\\\"Y\\\"]=8,\\\
      [\\\"X\\\"]=\\\"50%,-7\\\",\\\
      [\\\"Width\\\"] = 2,\\\
      [\\\"Height\\\"] = 1,\\\
      [\\\"Name\\\"]=\\\"ColourButton\\\",\\\
      [\\\"Momentary\\\"]=false,\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"BackgroundColour\\\"]=16384\\\
    },\\\
    [10]={\\\
      [\\\"Y\\\"]=8,\\\
      [\\\"X\\\"]=\\\"50%,-5\\\",\\\
      [\\\"Width\\\"] = 2,\\\
      [\\\"Height\\\"] = 1,\\\
      [\\\"Name\\\"]=\\\"ColourButton\\\",\\\
      [\\\"Momentary\\\"]=false,\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"BackgroundColour\\\"]=8192\\\
    },\\\
    [11]={\\\
      [\\\"Y\\\"]=8,\\\
      [\\\"X\\\"]=\\\"50%,-3\\\",\\\
      [\\\"Width\\\"] = 2,\\\
      [\\\"Height\\\"] = 1,\\\
      [\\\"Name\\\"]=\\\"ColourButton\\\",\\\
      [\\\"Momentary\\\"]=false,\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"BackgroundColour\\\"]=32\\\
    },\\\
    [12]={\\\
      [\\\"Y\\\"]=8,\\\
      [\\\"X\\\"]=\\\"50%,-1\\\",\\\
      [\\\"Width\\\"] = 2,\\\
      [\\\"Height\\\"] = 1,\\\
      [\\\"Name\\\"]=\\\"ColourButton\\\",\\\
      [\\\"Momentary\\\"]=false,\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"BackgroundColour\\\"]=64\\\
    },\\\
    [13]={\\\
      [\\\"Y\\\"]=8,\\\
      [\\\"X\\\"]=\\\"50%,1\\\",\\\
      [\\\"Width\\\"] = 2,\\\
      [\\\"Height\\\"] = 1,\\\
      [\\\"Name\\\"]=\\\"ColourButton\\\",\\\
      [\\\"Momentary\\\"]=false,\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"BackgroundColour\\\"]=4\\\
    },\\\
    [14]={\\\
      [\\\"Y\\\"]=8,\\\
      [\\\"X\\\"]=\\\"50%,3\\\",\\\
      [\\\"Width\\\"] = 2,\\\
      [\\\"Height\\\"] = 1,\\\
      [\\\"Name\\\"]=\\\"ColourButton\\\",\\\
      [\\\"Momentary\\\"]=false,\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"BackgroundColour\\\"]=1024\\\
    },\\\
    [15]={\\\
      [\\\"Y\\\"]=8,\\\
      [\\\"X\\\"]=\\\"50%,5\\\",\\\
      [\\\"Width\\\"] = 2,\\\
      [\\\"Height\\\"] = 1,\\\
      [\\\"Name\\\"]=\\\"ColourButton\\\",\\\
      [\\\"Momentary\\\"]=false,\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"BackgroundColour\\\"]=2048\\\
    },\\\
    [16]={\\\
      [\\\"Y\\\"]=8,\\\
      [\\\"X\\\"]=\\\"50%,7\\\",\\\
      [\\\"Width\\\"] = 2,\\\
      [\\\"Height\\\"] = 1,\\\
      [\\\"Name\\\"]=\\\"ColourButton\\\",\\\
      [\\\"Momentary\\\"]=false,\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"BackgroundColour\\\"]=512\\\
    },\\\
    [17]={\\\
      [\\\"Y\\\"]=8,\\\
      [\\\"X\\\"]=\\\"50%,9\\\",\\\
      [\\\"Width\\\"] = 2,\\\
      [\\\"Height\\\"] = 1,\\\
      [\\\"Name\\\"]=\\\"ColourButton\\\",\\\
      [\\\"Momentary\\\"]=false,\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"BackgroundColour\\\"]=8\\\
    },\\\
    [18]={\\\
      [\\\"Y\\\"]=8,\\\
      [\\\"X\\\"]=\\\"50%,11\\\",\\\
      [\\\"Width\\\"] = 2,\\\
      [\\\"Height\\\"] = 1,\\\
      [\\\"Name\\\"]=\\\"ColourButton\\\",\\\
      [\\\"Momentary\\\"]=false,\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"##\\\",\\\
      [\\\"BackgroundColour\\\"]=1,\\\
      [\\\"TextColour\\\"]=256\\\
    },\\\
    [19]={\\\
      [\\\"Y\\\"]=8,\\\
      [\\\"X\\\"]=\\\"50%,13\\\",\\\
      [\\\"Width\\\"] = 2,\\\
      [\\\"Height\\\"] = 1,\\\
      [\\\"Name\\\"]=\\\"ColourButton\\\",\\\
      [\\\"Momentary\\\"]=false,\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"BackgroundColour\\\"]=256\\\
    },\\\
    [20]={\\\
      [\\\"Y\\\"]=8,\\\
      [\\\"X\\\"]=\\\"50%,15\\\",\\\
      [\\\"Width\\\"] = 2,\\\
      [\\\"Height\\\"] = 1,\\\
      [\\\"Name\\\"]=\\\"ColourButton\\\",\\\
      [\\\"Momentary\\\"]=false,\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"BackgroundColour\\\"]=128\\\
    },\\\
    [21]={\\\
      [\\\"Y\\\"]=8,\\\
      [\\\"X\\\"]=\\\"50%,17\\\",\\\
      [\\\"Width\\\"] = 2,\\\
      [\\\"Height\\\"] = 1,\\\
      [\\\"Name\\\"]=\\\"ColourButton\\\",\\\
      [\\\"Momentary\\\"]=false,\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"BackgroundColour\\\"]=32768\\\
    },\\\
  },\\\
  [\\\"BackgroundColour\\\"]=1,\\\
  [\\\"ToolBarColour\\\"] = 128,\\\
  [\\\"ToolBarTextColour\\\"] = 1\\\
}\",\
    [ \"System/.OneOS.settings\" ] = \"{\\\
  ComputerName = \\\"OneOS Computer\\\",\\\
  DesktopColour = 512,\\\
  UseAnimations = true,\\\
}\",\
    [ \"System/Programs/First Setup.program/Views/page2.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"Toolbar\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"InheritView\\\"]=\\\"toolbar\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=3,\\\
      [\\\"Width\\\"]=\\\"100%,-6\\\",\\\
      [\\\"Name\\\"]=\\\"Label\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Enter the name of this computer.\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=\\\"8\\\",\\\
      [\\\"X\\\"]=\\\"15%\\\",\\\
      [\\\"Width\\\"]=\\\"70%\\\",\\\
      [\\\"Name\\\"]=\\\"ComputerNameTextBox\\\",\\\
      [\\\"Type\\\"]=\\\"TextBox\\\",\\\
      [\\\"Text\\\"]=\\\"OneOS Computer\\\",\\\
      [\\\"BackgroundColour\\\"]=256,\\\
      [\\\"Active\\\"]=true\\\
    },\\\
    [4]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"100%,-7\\\",\\\
      [\\\"Name\\\"]=\\\"NextButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Next\\\",\\\
      [\\\"BackgroundColour\\\"]=256\\\
    },\\\
    [5]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"3\\\",\\\
      [\\\"Name\\\"]=\\\"BackButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Back\\\",\\\
      [\\\"BackgroundColour\\\"]=256\\\
    },\\\
  },\\\
  [\\\"BackgroundColour\\\"]=1,\\\
  [\\\"ToolBarColour\\\"] = 128,\\\
  [\\\"ToolBarTextColour\\\"] = 1\\\
}\",\
    [ \"System/Programs/Files.program/pkgmake\" ] = \"sPackage=[[local pkg=%@1\\\
local function makeFile(_path,_content)\\\
 local file=OneOS.FS.open(_path,\\\"w\\\")\\\
 file.write(_content)\\\
 file.close()\\\
end\\\
local function makeFolder(_path,_content)\\\
 OneOS.FS.makeDir(_path)\\\
 for k,v in pairs(_content) do\\\
  if type(v)==\\\"table\\\" then\\\
   makeFolder(_path..\\\"/\\\"..k,v)\\\
  else\\\
   makeFile(_path..\\\"/\\\"..k,v)\\\
  end\\\
 end\\\
end\\\
local sDest= installLocation or '/'\\\
if sDest==\\\"root\\\" then\\\
 sDest=\\\"/\\\"\\\
end\\\
sDest = sDest .. %@2\\\
local tPackage=pkg\\\
makeFolder(sDest,tPackage)\\\
]]function addFile(a,b)if OneOS.FS.getName(b)==\\\".DS_Store\\\"then return a end;local c,d=OneOS.FS.open(b,\\\"r\\\")local e=c.readAll()e=e:gsub(\\\"%%\\\",\\\"%%%%\\\")a[OneOS.FS.getName(b)]=e;c.close()return a end;function addFolder(a,b)if string.sub(b,1,string.len(\\\"rom\\\"))==\\\"rom\\\"or string.sub(b,1,string.len(\\\"/rom\\\"))==\\\"/rom\\\"then return end;a=a or{}for f,g in ipairs(OneOS.FS.list(b))do local h=b..\\\"/\\\"..g;if OneOS.FS.isDir(h)then a[OneOS.FS.getName(g)]=addFolder(a[OneOS.FS.getName(g)],h)else a=addFile(a,h)end end;return a end;local i={...}local j=OneOS.Shell.resolve(i[1])local k=OneOS.Shell.resolve(i[2])if OneOS.FS.exists(j)and OneOS.FS.isDir(j)then tPackage={}tPackage=addFolder(tPackage,j)fPackage=OneOS.FS.open(k,\\\"w\\\")if fPackage then sPackage=string.gsub(sPackage,\\\"%%@1\\\",textutils.serialize(tPackage))sPackage=string.gsub(sPackage,\\\"%%@2\\\",textutils.serialize(OneOS.FS.getName(i[1])))fPackage.write(sPackage)fPackage.close()else error(k)end else error(j)error(\\\"Source does not exist or is not a folder.\\\")end\",\
    [ \"Programs/Quest.program/Elements/Form.lua\" ] = \"Submit = function(self, onEnter)\\\
	local values = {}\\\
	\\\
	local node = false\\\
	node = function(elem)\\\
		if (elem.Tag == 'input' or elem.Tag == 'select') and elem.InputName then\\\
			local findSubmit = (onEnter and elem.Attributes and elem.Attributes.type == 'submit')\\\
			if elem.UpdateValue then\\\
				elem:UpdateValue(findSubmit)\\\
			end\\\
\\\
			if findSubmit then\\\
				onEnter = false\\\
			end\\\
\\\
			if elem.Value then\\\
				values[elem.InputName] = elem.Value\\\
			end\\\
		end\\\
\\\
		if elem.Children then\\\
			for i, child in ipairs(elem.Children) do\\\
				node(child)\\\
			end\\\
		end\\\
	end\\\
\\\
	node(self)\\\
\\\
	local url = false\\\
	if self.Attributes.action and #self.Attributes.action > 0 then\\\
		url = resolveFullUrl(self.Attributes.action) --TODO: this needs to show the fake url to the user\\\
	else\\\
		url = getCurrentFakeUrl()\\\
	end\\\
	local data = ''\\\
	for k, v in pairs(values) do\\\
		data = data .. textutils.urlEncode(k) .. '=' .. textutils.urlEncode(v) .. '&'\\\
	end\\\
	data = data:sub(1, #data - 1)\\\
\\\
	if self.Attributes.method and self.Attributes.method:lower() == 'post' then\\\
		goToUrl(url, data)\\\
	else\\\
		goToUrl(url .. '?' .. data)\\\
	end\\\
end\\\
\\\
OnCreateObject = function(self, parentObject, y)\\\
	return {\\\
		Element = self,\\\
		Y = y,\\\
		X = 1,\\\
		Width = \\\"100%\\\",\\\
		Height = self.Height,\\\
		Type = \\\"FormView\\\"\\\
	}\\\
end\",\
    [ \"Programs/Quest.program/Elements/HiddenInput.lua\" ] = \"InputName = ''\\\
\\\
OnInitialise = function(self, node)\\\
	local attr = self.Attributes\\\
	if attr.value then\\\
		self.Value = attr.value\\\
	end\\\
\\\
	if attr.name then\\\
		self.InputName = attr.name\\\
	end\\\
end\",\
    [ \"System/Programs/First Setup.program/Views/page1.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"Toolbar\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"InheritView\\\"]=\\\"toolbar\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=3,\\\
      [\\\"Width\\\"]=\\\"100%,-6\\\",\\\
      [\\\"Name\\\"]=\\\"Label\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Welcome to OneOS!\\\\n\\\\nBefore you get started follow these short steps to customise OneOS to your liking.\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"100%,-7\\\",\\\
      [\\\"Name\\\"]=\\\"NextButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Next\\\",\\\
      [\\\"BackgroundColour\\\"]=256\\\
    },\\\
  },\\\
  [\\\"BackgroundColour\\\"]=1,\\\
  [\\\"ToolBarColour\\\"] = 128,\\\
  [\\\"ToolBarTextColour\\\"] = 1\\\
}\",\
    [ \"Programs/Quest.program/Pages/text.ccml\" ] = \"<!DOCTYPE ccml>\\\
<html>\\\
	<head>\\\
		<title>An Error Occured</title>\\\
	    <script type=\\\"lua\\\">\\\
	    	if window.get.reason then\\\
	        	l('p').text(window.get.reason)\\\
	    	end\\\
	    </script>\\\
	</head>\\\
	<body>\\\
		<br/>\\\
		<br/>\\\
		<h colour=\\\"red\\\">An Error Occured</h>\\\
		<br/>\\\
		<center>\\\
			<br>\\\
			<p width=\\\"48\\\" align=\\\"center\\\">Unknown Reason</p>\\\
		</center>\\\
	</body>\\\
</html>\",\
    [ \"System/Objects/LoginView.lua\" ] = \"Inherit = 'View'\\\
IsSleepMode = false\\\
\\\
OnDraw = function(self, x, y)\\\
	for _y, row in ipairs(Drawing.Buffer) do\\\
		for _x, pixel in ipairs(row) do\\\
			Drawing.WriteToBuffer(_x, _y, pixel[1], Drawing.FilterColour(pixel[2], Drawing.Filters.Greyscale), Drawing.FilterColour(pixel[3], Drawing.Filters.Greyscale))\\\
		end\\\
	end\\\
end\\\
\\\
TryUnlock = function(self, password)\\\
	local secureTextBox = self:GetObject('SecureTextBox')\\\
	secureTextBox.Text = ''\\\
	if password ~= '' and Settings:CheckPassword(password) then\\\
		Log.i('Password correct, unlocking.')\\\
		self.Visible = false\\\
		self.Bedrock:SetActiveObject()\\\
		self:OnUnlock(self.IsSleepMode)\\\
	else\\\
		Log.i('Password incorrect.')\\\
		local label = self:GetObject('Label')\\\
		local secureStartX = secureTextBox.X\\\
		local labelStartX = label.X\\\
		local maxDelta = 4\\\
		local steps = {\\\
			-2,\\\
			-4,\\\
			-2,\\\
			0,\\\
			2,\\\
			4,\\\
			2,\\\
			0,\\\
			-1,\\\
			-2,\\\
			-1,\\\
			0,\\\
			1,\\\
			2,\\\
			1,\\\
			0\\\
		}\\\
		if Settings:GetValues()['UseAnimations'] then\\\
			self.Bedrock:SetActiveObject()\\\
			local i = 1\\\
			self.Bedrock:StartRepeatingTimer(function(newTimer)\\\
				secureTextBox.X = secureStartX + steps[i]\\\
				label.X = labelStartX + steps[i]\\\
				i = i + 1\\\
				if i > #steps then\\\
					self.Bedrock:StopTimer(newTimer)\\\
					self.Bedrock:SetActiveObject(secureTextBox)\\\
				end\\\
			end, 0.05)\\\
		end\\\
	end\\\
end\\\
\\\
Lock = function(self)\\\
	if Settings:GetValues()['Password'] == nil then\\\
		Log.i('No password, unlocking.')\\\
		self.Visible = false\\\
		if self.OnUnlock then\\\
			self:OnUnlock(self.IsSleepMode)\\\
		end\\\
		return\\\
	end\\\
	self.Visible = true\\\
\\\
	local secureTextBox = self:GetObject('SecureTextBox')\\\
	secureTextBox.OnChange = function(_self, event, keychar)\\\
		if keychar == keys.enter then\\\
			self:TryUnlock(secureTextBox.Text)\\\
		end\\\
	end\\\
	self.Bedrock:SetActiveObject(secureTextBox)\\\
\\\
	self:GetObject('ExitButton').OnClick = function(_self, event, side, x, y)\\\
		if self.IsSleepMode then\\\
		else\\\
			Shutdown(true)\\\
		end\\\
	end\\\
end\\\
\\\
OnClick = function(self, event, side, x, y)\\\
end\",\
    [ \"Programs/Games/Redirection.program/Views/main.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"Toolbar\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"InheritView\\\"]=\\\"toolbar\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=3,\\\
      [\\\"Width\\\"]=\\\"100%,-4\\\",\\\
      [\\\"Height\\\"]=3,\\\
      [\\\"Name\\\"]=\\\"Label\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"To save disc space, OneOS does not come with Redirection downloaded by default. Do you want to download it now?\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"100%,-6\\\",\\\
      [\\\"Name\\\"]=\\\"YesButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Yes\\\",\\\
      [\\\"BackgroundColour\\\"]=8192,\\\
      [\\\"TextColour\\\"]=1\\\
    },\\\
    [4]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"100%,-11\\\",\\\
      [\\\"Name\\\"]=\\\"NoButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"No\\\",\\\
      [\\\"BackgroundColour\\\"]=16384,\\\
      [\\\"TextColour\\\"]=1\\\
    },\\\
  },\\\
  [\\\"BackgroundColour\\\"]=1,\\\
  [\\\"ToolBarColour\\\"] = 128,\\\
  [\\\"ToolBarTextColour\\\"] = 1\\\
}\",\
    [ \"System/Programs/Files.program/icon\" ] = \"b 3. 3 b,\\\
b  3  \\\
b   3 \",\
    [ \"System/API/Hash.lua\" ] = \"--\\\
--  Thanks to GravityScore for this!\\\
--  http://www.computercraft.info/forums2/index.php?/topic/8169-sha-256-in-pure-lua/\\\
--\\\
\\\
--  \\\
--  Adaptation of the Secure Hashing Algorithm (SHA-244/256)\\\
--  Found Here: http://lua-users.org/wiki/SecureHashAlgorithm\\\
--  \\\
--  Using an adapted version of the bit library\\\
--  Found Here: https://bitbucket.org/Boolsheet/bslf/src/1ee664885805/bit.lua\\\
--  \\\
\\\
local MOD = 2^32\\\
local MODM = MOD-1\\\
\\\
local function memoize(f)\\\
	local mt = {}\\\
	local t = setmetatable({}, mt)\\\
	function mt:__index(k)\\\
		local v = f(k)\\\
		t[k] = v\\\
		return v\\\
	end\\\
	return t\\\
end\\\
\\\
local function make_bitop_uncached(t, m)\\\
	local function bitop(a, b)\\\
		local res,p = 0,1\\\
		while a ~= 0 and b ~= 0 do\\\
			local am, bm = a % m, b % m\\\
			res = res + t[am][bm] * p\\\
			a = (a - am) / m\\\
			b = (b - bm) / m\\\
			p = p*m\\\
		end\\\
		res = res + (a + b) * p\\\
		return res\\\
	end\\\
	return bitop\\\
end\\\
\\\
local function make_bitop(t)\\\
	local op1 = make_bitop_uncached(t,2^1)\\\
	local op2 = memoize(function(a) return memoize(function(b) return op1(a, b) end) end)\\\
	return make_bitop_uncached(op2, 2 ^ (t.n or 1))\\\
end\\\
\\\
local bxor1 = make_bitop({[0] = {[0] = 0,[1] = 1}, [1] = {[0] = 1, [1] = 0}, n = 4})\\\
\\\
local function bxor(a, b, c, ...)\\\
	local z = nil\\\
	if b then\\\
		a = a % MOD\\\
		b = b % MOD\\\
		z = bxor1(a, b)\\\
		if c then z = bxor(z, c, ...) end\\\
		return z\\\
	elseif a then return a % MOD\\\
	else return 0 end\\\
end\\\
\\\
local function band(a, b, c, ...)\\\
	local z\\\
	if b then\\\
		a = a % MOD\\\
		b = b % MOD\\\
		z = ((a + b) - bxor1(a,b)) / 2\\\
		if c then z = bit32_band(z, c, ...) end\\\
		return z\\\
	elseif a then return a % MOD\\\
	else return MODM end\\\
end\\\
\\\
local function bnot(x) return (-1 - x) % MOD end\\\
\\\
local function rshift1(a, disp)\\\
	if disp < 0 then return lshift(a,-disp) end\\\
	return math.floor(a % 2 ^ 32 / 2 ^ disp)\\\
end\\\
\\\
local function rshift(x, disp)\\\
	if disp > 31 or disp < -31 then return 0 end\\\
	return rshift1(x % MOD, disp)\\\
end\\\
\\\
local function lshift(a, disp)\\\
	if disp < 0 then return rshift(a,-disp) end \\\
	return (a * 2 ^ disp) % 2 ^ 32\\\
end\\\
\\\
local function rrotate(x, disp)\\\
    x = x % MOD\\\
    disp = disp % 32\\\
    local low = band(x, 2 ^ disp - 1)\\\
    return rshift(x, disp) + lshift(low, 32 - disp)\\\
end\\\
\\\
local k = {\\\
	0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,\\\
	0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,\\\
	0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,\\\
	0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,\\\
	0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,\\\
	0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,\\\
	0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,\\\
	0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,\\\
	0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,\\\
	0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,\\\
	0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,\\\
	0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,\\\
	0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,\\\
	0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,\\\
	0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,\\\
	0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,\\\
}\\\
\\\
local function str2hexa(s)\\\
	return (string.gsub(s, \\\".\\\", function(c) return string.format(\\\"%02x\\\", string.byte(c)) end))\\\
end\\\
\\\
local function num2s(l, n)\\\
	local s = \\\"\\\"\\\
	for i = 1, n do\\\
		local rem = l % 256\\\
		s = string.char(rem) .. s\\\
		l = (l - rem) / 256\\\
	end\\\
	return s\\\
end\\\
\\\
local function s232num(s, i)\\\
	local n = 0\\\
	for i = i, i + 3 do n = n*256 + string.byte(s, i) end\\\
	return n\\\
end\\\
\\\
local function preproc(msg, len)\\\
	local extra = 64 - ((len + 9) % 64)\\\
	len = num2s(8 * len, 8)\\\
	msg = msg .. \\\"\\\\128\\\" .. string.rep(\\\"\\\\0\\\", extra) .. len\\\
	assert(#msg % 64 == 0)\\\
	return msg\\\
end\\\
\\\
local function initH256(H)\\\
	H[1] = 0x6a09e667\\\
	H[2] = 0xbb67ae85\\\
	H[3] = 0x3c6ef372\\\
	H[4] = 0xa54ff53a\\\
	H[5] = 0x510e527f\\\
	H[6] = 0x9b05688c\\\
	H[7] = 0x1f83d9ab\\\
	H[8] = 0x5be0cd19\\\
	return H\\\
end\\\
\\\
local function digestblock(msg, i, H)\\\
	local w = {}\\\
	for j = 1, 16 do w[j] = s232num(msg, i + (j - 1)*4) end\\\
	for j = 17, 64 do\\\
		local v = w[j - 15]\\\
		local s0 = bxor(rrotate(v, 7), rrotate(v, 18), rshift(v, 3))\\\
		v = w[j - 2]\\\
		w[j] = w[j - 16] + s0 + w[j - 7] + bxor(rrotate(v, 17), rrotate(v, 19), rshift(v, 10))\\\
	end\\\
\\\
	local a, b, c, d, e, f, g, h = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]\\\
	for i = 1, 64 do\\\
		local s0 = bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22))\\\
		local maj = bxor(band(a, b), band(a, c), band(b, c))\\\
		local t2 = s0 + maj\\\
		local s1 = bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25))\\\
		local ch = bxor (band(e, f), band(bnot(e), g))\\\
		local t1 = h + s1 + ch + k[i] + w[i]\\\
		h, g, f, e, d, c, b, a = g, f, e, d + t1, c, b, a, t1 + t2\\\
	end\\\
\\\
	H[1] = band(H[1] + a)\\\
	H[2] = band(H[2] + b)\\\
	H[3] = band(H[3] + c)\\\
	H[4] = band(H[4] + d)\\\
	H[5] = band(H[5] + e)\\\
	H[6] = band(H[6] + f)\\\
	H[7] = band(H[7] + g)\\\
	H[8] = band(H[8] + h)\\\
end\\\
\\\
function sha256(msg)\\\
	msg = preproc(msg, #msg)\\\
	local H = initH256({})\\\
	for i = 1, #msg, 64 do digestblock(msg, i, H) end\\\
	return str2hexa(num2s(H[1], 4) .. num2s(H[2], 4) .. num2s(H[3], 4) .. num2s(H[4], 4) ..\\\
		num2s(H[5], 4) .. num2s(H[6], 4) .. num2s(H[7], 4) .. num2s(H[8], 4))\\\
end\",\
    [ \"Programs/Quest Server.program/APIs/Peripheral\" ] = \"GetPeripheral = function(_type)\\\
	for i, p in ipairs(GetPeripherals()) do\\\
		if p.Type == _type then\\\
			return p\\\
		end\\\
	end\\\
end\\\
\\\
Call = function(type, ...)\\\
	local tArgs = {...}\\\
	local p = GetPeripheral(type)\\\
	peripheral.call(p.Side, unpack(tArgs))\\\
end\\\
\\\
local getNames = peripheral.getNames or function()\\\
	local tResults = {}\\\
	for n,sSide in ipairs( rs.getSides() ) do\\\
		if peripheral.isPresent( sSide ) then\\\
			table.insert( tResults, sSide )\\\
			local isWireless = false\\\
			if pcall(function()isWireless = peripheral.call(sSide, 'isWireless') end) then\\\
				isWireless = true\\\
			end     \\\
			if peripheral.getType( sSide ) == \\\"modem\\\" and not isWireless then\\\
				local tRemote = peripheral.call( sSide, \\\"getNamesRemote\\\" )\\\
				for n,sName in ipairs( tRemote ) do\\\
					table.insert( tResults, sName )\\\
				end\\\
			end\\\
		end\\\
	end\\\
	return tResults\\\
end\\\
\\\
GetPeripherals = function(filterType)\\\
	local peripherals = {}\\\
	for i, side in ipairs(getNames()) do\\\
		local name = peripheral.getType(side):gsub(\\\"^%l\\\", string.upper)\\\
		local code = string.upper(side:sub(1,1))\\\
		if side:find('_') then\\\
			code = side:sub(side:find('_')+1)\\\
		end\\\
\\\
		local dupe = false\\\
		for i, v in ipairs(peripherals) do\\\
			if v[1] == name .. ' ' .. code then\\\
				dupe = true\\\
			end\\\
		end\\\
\\\
		if not dupe then\\\
			local _type = peripheral.getType(side)\\\
			local formattedType = _type:sub(1, 1):upper() .. _type:sub(2, -1)\\\
			local isWireless = false\\\
			if _type == 'modem' then\\\
				if not pcall(function()isWireless = peripheral.call(side, 'isWireless') end) then\\\
					isWireless = true\\\
				end     \\\
				if isWireless then\\\
					_type = 'wireless_modem'\\\
					formattedType = 'Wireless Modem'\\\
					name = 'W '..name\\\
				end\\\
			end\\\
			if not filterType or _type == filterType then\\\
				table.insert(peripherals, {Name = name:sub(1,8) .. ' '..code, Fullname = name .. ' ('..side:sub(1, 1):upper() .. side:sub(2, -1)..')', Side = side, Type = _type, Wireless = isWireless, FormattedType = formattedType})\\\
			end\\\
		end\\\
	end\\\
	return peripherals\\\
end\\\
\\\
GetSide = function(side)\\\
	for i, p in ipairs(GetPeripherals()) do\\\
		if p.Side == side then\\\
			return p\\\
		end\\\
	end\\\
end\\\
\\\
PresentNamed = function(name)\\\
	return peripheral.isPresent(name)\\\
end\\\
\\\
CallType = function(type, ...)\\\
	local tArgs = {...}\\\
	local p = GetPeripheral(type)\\\
	return peripheral.call(p.Side, unpack(tArgs))\\\
end\\\
\\\
CallNamed = function(name, ...)\\\
	local tArgs = {...}\\\
	return peripheral.call(name, unpack(tArgs))\\\
end\\\
\\\
GetInfo = function(p)\\\
	local info = {}\\\
	local buttons = {}\\\
	if p.Type == 'computer' then\\\
		local id = peripheral.call(p.Side:lower(),'getID')\\\
		if id then\\\
			info = {\\\
				ID = tostring(id)\\\
			}\\\
		else\\\
			info = {}\\\
		end\\\
	elseif p.Type == 'drive' then\\\
		local discType = 'No Disc'\\\
		local discID = nil\\\
		local mountPath = nil\\\
		local discLabel = nil\\\
		local songName = nil\\\
		if peripheral.call(p.Side:lower(), 'isDiskPresent') then\\\
			if peripheral.call(p.Side:lower(), 'hasData') then\\\
				discType = 'Data'\\\
				discID = peripheral.call(p.Side:lower(), 'getDiskID')\\\
				if discID then\\\
					discID = tostring(discID)\\\
				else\\\
					discID = 'None'\\\
				end\\\
				mountPath = '/'..peripheral.call(p.Side:lower(), 'getMountPath')..'/'\\\
				discLabel = peripheral.call(p.Side:lower(), 'getDiskLabel')\\\
			else\\\
				discType = 'Audio'\\\
				songName = peripheral.call(p.Side:lower(), 'getAudioTitle')\\\
			end\\\
		end\\\
		if mountPath then\\\
			table.insert(buttons, {Text = 'View Files', OnClick = function(self, event, side, x, y)GoToPath(mountPath)end})\\\
		elseif discType == 'Audio' then\\\
			table.insert(buttons, {Text = 'Play', OnClick = function(self, event, side, x, y)\\\
				if self.Text == 'Play' then\\\
					disk.playAudio(p.Side:lower())\\\
					self.Text = 'Stop'\\\
				else\\\
					disk.stopAudio(p.Side:lower())\\\
					self.Text = 'Play'\\\
				end\\\
			end})\\\
		else\\\
			diskOpenButton = nil\\\
		end\\\
		if discType ~= 'No Disc' then\\\
			table.insert(buttons, {Text = 'Eject', OnClick = function(self, event, side, x, y)disk.eject(p.Side:lower()) sleep(0) RefreshFiles() end})\\\
		end\\\
\\\
		info = {\\\
			['Disc Type'] = discType,\\\
			['Disc Label'] = discLabel,\\\
			['Song Title'] = songName,\\\
			['Disc ID'] = discID,\\\
			['Mount Path'] = mountPath\\\
		}\\\
	elseif p.Type == 'printer' then\\\
		local pageSize = 'No Loaded Page'\\\
		local _, err = pcall(function() return tostring(peripheral.call(p.Side:lower(), 'getPgaeSize')) end)\\\
		if not err then\\\
			pageSize = tostring(peripheral.call(p.Side:lower(), 'getPageSize'))\\\
		end\\\
		info = {\\\
			['Paper Level'] = tostring(peripheral.call(p.Side:lower(), 'getPaperLevel')),\\\
			['Paper Size'] = pageSize,\\\
			['Ink Level'] = tostring(peripheral.call(p.Side:lower(), 'getInkLevel'))\\\
		}\\\
	elseif p.Type == 'modem' then\\\
		info = {\\\
			['Connected Peripherals'] = tostring(#peripheral.call(p.Side:lower(), 'getNamesRemote'))\\\
		}\\\
	elseif p.Type == 'monitor' then\\\
		local w, h = peripheral.call(p.Side:lower(), 'getSize')\\\
		local screenType = 'Black and White'\\\
		if peripheral.call(p.Side:lower(), 'isColour') then\\\
			screenType = 'Colour'\\\
		end\\\
		local buttonTitle = 'Use as Screen'\\\
		if OneOS.Settings:GetValues()['Monitor'] == p.Side:lower() then\\\
			buttonTitle = 'Use Computer Screen'\\\
		end\\\
		table.insert(buttons, {Text = buttonTitle, OnClick = function(self, event, side, x, y)\\\
				self.Bedrock:DisplayAlertWindow('Reboot Required', \\\"To change screen you'll need to reboot your computer.\\\", {'Reboot', 'Cancel'}, function(value)\\\
					if value == 'Reboot' then\\\
						if buttonTitle == 'Use Computer Screen' then\\\
							OneOS.Settings:SetValue('Monitor', nil)\\\
						else\\\
							OneOS.Settings:SetValue('Monitor', p.Side:lower())\\\
						end\\\
						OneOS.Reboot()\\\
					end\\\
				end)\\\
			end\\\
		})\\\
		info = {\\\
			['Type'] = screenType,\\\
			['Width'] = tostring(w),\\\
			['Height'] = tostring(h),\\\
		}\\\
	end\\\
	info.Buttons = buttons\\\
	return info\\\
end\",\
    [ \"Programs/Ink.program/Icons/ink\" ] = \"0bink7 \\\
07----\\\
07----\",\
    [ \"System/JSON\" ] = \"local a=_G;local decode_scanArray;local decode_scanComment;local decode_scanConstant;local decode_scanNumber;local decode_scanObject;local decode_scanString;local decode_scanWhitespace;local encodeString;local isArray;local isEncodable;function encode(b)if b==nil then return\\\"null\\\"end;local c=a.type(b)if c=='string'then return'\\\"'..encodeString(b)..'\\\"'end;if c=='number'or c=='boolean'then return a.tostring(b)end;if c=='table'then local d={}local e,f=isArray(b)if e then for g=1,f do table.insert(d,encode(b[g]))end else for g,h in a.pairs(b)do if isEncodable(g)and isEncodable(h)then table.insert(d,'\\\"'..encodeString(g)..'\\\":'..encode(h))end end end;if e then return'['..table.concat(d,',')..']'else return'{'..table.concat(d,',')..'}'end end;if c=='function'and b==null then return'null'end;a.assert(false,'encode attempt to encode unsupported type '..c..':'..a.tostring(b))end;function decode(i,j)j=j and j or 1;j=decode_scanWhitespace(i,j)a.assert(j<=string.len(i),'Unterminated JSON encoded object found at position in ['..i..']')local k=string.sub(i,j,j)if k=='{'then return decode_scanObject(i,j)end;if k=='['then return decode_scanArray(i,j)end;if string.find(\\\"+-0123456789.e\\\",k,1,true)then return decode_scanNumber(i,j)end;if k==[[\\\"]]or k==[[']]then return decode_scanString(i,j)end;if string.sub(i,j,j+1)=='/*'then return decode(i,decode_scanComment(i,j))end;return decode_scanConstant(i,j)end;function null()return null end;function decode_scanArray(i,j)local l={}local m=string.len(i)a.assert(string.sub(i,j,j)=='[','decode_scanArray called but array does not start at position '..j..' in string:\\\\n'..i)j=j+1;repeat j=decode_scanWhitespace(i,j)a.assert(j<=m,'JSON String ended unexpectedly scanning array.')local k=string.sub(i,j,j)if k==']'then return l,j+1 end;if k==','then j=decode_scanWhitespace(i,j+1)end;a.assert(j<=m,'JSON String ended unexpectedly scanning array.')object,j=decode(i,j)table.insert(l,object)until false end;function decode_scanComment(i,j)a.assert(string.sub(i,j,j+1)=='/*',\\\"decode_scanComment called but comment does not start at position \\\"..j)local n=string.find(i,'*/',j+2)a.assert(n~=nil,\\\"Unterminated comment in string at \\\"..j)return n+2 end;function decode_scanConstant(i,j)local o={[\\\"true\\\"]=true,[\\\"false\\\"]=false,[\\\"null\\\"]=nil}local p={\\\"true\\\",\\\"false\\\",\\\"null\\\"}for g,q in a.pairs(p)do if string.sub(i,j,j+string.len(q)-1)==q then return o[q],j+string.len(q)end end;a.assert(nil,'Failed to scan constant from string '..i..' at starting position '..j)end;function decode_scanNumber(i,j)local n=j+1;local m=string.len(i)local r=\\\"+-0123456789.e\\\"while string.find(r,string.sub(i,n,n),1,true)and n<=m do n=n+1 end;local s='return '..string.sub(i,j,n-1)local t=a.loadstring(s)a.assert(t,'Failed to scan number [ '..s..'] in JSON string at position '..j..' : '..n)return t(),n end;function decode_scanObject(i,j)local object={}local m=string.len(i)local u,v;a.assert(string.sub(i,j,j)=='{','decode_scanObject called but object does not start at position '..j..' in string:\\\\n'..i)j=j+1;repeat j=decode_scanWhitespace(i,j)a.assert(j<=m,'JSON string ended unexpectedly while scanning object.')local k=string.sub(i,j,j)if k=='}'then return object,j+1 end;if k==','then j=decode_scanWhitespace(i,j+1)end;a.assert(j<=m,'JSON string ended unexpectedly scanning object.')u,j=decode(i,j)a.assert(j<=m,'JSON string ended unexpectedly searching for value of key '..u)j=decode_scanWhitespace(i,j)a.assert(j<=m,'JSON string ended unexpectedly searching for value of key '..u)a.assert(string.sub(i,j,j)==':','JSON object key-value assignment mal-formed at '..j)j=decode_scanWhitespace(i,j+1)a.assert(j<=m,'JSON string ended unexpectedly searching for value of key '..u)v,j=decode(i,j)object[u]=v until false end;function decode_scanString(i,j)a.assert(j,'decode_scanString(..) called without start position')local w=string.sub(i,j,j)a.assert(w==[[']]or w==[[\\\"]],'decode_scanString called for a non-string')local x=false;local n=j+1;local y=false;local m=string.len(i)repeat local k=string.sub(i,n,n)if not x then if k==[[\\\\]]then x=true else y=k==w end else x=false end;n=n+1;a.assert(n<=m+1,\\\"String decoding failed: unterminated string at position \\\"..n)until y;local s='return '..string.sub(i,j,n-1)local t=a.loadstring(s)a.assert(t,'Failed to load string [ '..s..'] in JSON4Lua.decode_scanString at position '..j..' : '..n)return t(),n end;function decode_scanWhitespace(i,j)local z=\\\" \\\\n\\\\r\\\\t\\\"local m=string.len(i)while string.find(z,string.sub(i,j,j),1,true)and j<=m do j=j+1 end;return j end;function encodeString(i)i=string.gsub(i,'\\\\\\\\','\\\\\\\\\\\\\\\\')i=string.gsub(i,'\\\"','\\\\\\\\\\\"')i=string.gsub(i,\\\"'\\\",\\\"\\\\\\\\'\\\")i=string.gsub(i,'\\\\n','\\\\\\\\n')i=string.gsub(i,'\\\\t','\\\\\\\\t')return i end;function isArray(A)local B=0;for q,b in a.pairs(A)do if a.type(q)=='number'and math.floor(q)==q and 1<=q then if not isEncodable(b)then return false end;B=math.max(B,q)else if q=='n'then if b~=table.getn(A)then return false end else if isEncodable(b)then return false end end end end;return true,B end;function isEncodable(C)local A=a.type(C)return A=='string'or A=='boolean'or A=='number'or A=='nil'or A=='table'or A=='function'and C==null end\",\
    [ \"System/Images/Boot/boot0\" ] = \"         8888          \\\
        888888         \\\
        888888         \\\
         8888          \\\
                       \\\
                       \\\
                       \\\
88888888888888888888888\",\
    [ \"Programs/Transmit.program/Images/logo\" ] = \" f  e         \\\
 f e        e   \\\
ef    e       e \\\
 f  e      e    \\\
 f    e       \",\
    [ \"Programs/Transmit.program/Images/anm2\" ] = \" f  e         \\\
 f e        e   \\\
ef    7     7 f e \\\
 f 7 7f      7    \\\
 f    7       \",\
    [ \"System/Objects/ProgramPreview.lua\" ] = \"Inherit = 'View'\\\
Width = 13\\\
Height = 8\\\
PreviewWidth = 12\\\
PreviewHeight = 5\\\
Program = nil\\\
Preview = nil\\\
Icon = nil\\\
Minimal = false\\\
\\\
OnLoad = function(self)\\\
	if self.Program then\\\
		self:UpdatePreview()\\\
		local path = Helpers.ParentFolder(self.Program.Path)..'/icon'\\\
		self.Icon = Drawing.LoadImage(path)\\\
	end\\\
end\\\
\\\
UpdatePreview = function(self)\\\
	if self.Program then\\\
		if self.Minimal then\\\
			self.PreviewWidth = self.Width\\\
			self.PreviewHeight = self.Height\\\
		end\\\
		self.Preview = self.Program:RenderPreview(self.PreviewWidth, self.PreviewHeight)\\\
		self:ForceDraw()\\\
	end\\\
end\\\
\\\
OnDraw = function(self, x, y)\\\
	if self.Program then\\\
		if not self.Minimal then\\\
			Drawing.DrawBlankArea(x + 1, y + 2, self.PreviewWidth, self.PreviewHeight, colours.grey)\\\
		end\\\
\\\
		local startY = 0\\\
		if self.Minimal then\\\
			startY = -1\\\
		end\\\
		for _x, col in pairs(self.Preview) do\\\
			for _y, colour in ipairs(col) do\\\
				local char = '-'\\\
				if colour[1] == ' ' then\\\
					char = ' '\\\
				end\\\
				Drawing.WriteToBuffer(x+_x-1, y+_y+startY, char, colour[2], colour[3])--' ', colours.black, colour)\\\
			end\\\
		end\\\
		\\\
		if not self.Minimal then\\\
			Drawing.DrawCharactersCenter(x + 1, y, self.PreviewWidth - 1, 1, Helpers.TruncateString(self.Program.Title, self.Width - 2), colours.white, colours.transparent)\\\
			if self.Icon then\\\
				Drawing.DrawImage(x + self.PreviewWidth - 4, y + self.PreviewHeight - 2, self.Icon, 4, 3)\\\
			end\\\
\\\
			if not self.Program.Hidden then\\\
				Drawing.DrawCharacters(x, y, 'x', colours.red, colours.transparent)\\\
			end\\\
		end\\\
	end\\\
end\",\
    [ \"System/Programs/Files.program/images/Printer\" ] = \"7f ___ \\\
7f --- \\\
8f 7===8 \\\
8f    -\",\
    [ \"System/Programs/Desktop.program/Views/testwindow.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"Toolbar\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"InheritView\\\"]=\\\"toolbar\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=3,\\\
      [\\\"Width\\\"]=\\\"100%,-6\\\",\\\
      [\\\"Name\\\"]=\\\"Label\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Welcome to OneOS!\\\\n\\\\nBefore you get started follow these short steps to customise OneOS to your liking.\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"100%,-7\\\",\\\
      [\\\"Name\\\"]=\\\"NextButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Next\\\",\\\
      [\\\"BackgroundColour\\\"]=256\\\
    },\\\
  },\\\
  [\\\"BackgroundColour\\\"]=1,\\\
  [\\\"Width\\\"]=20,\\\
  [\\\"Height\\\"]=5\\\
}\",\
    [ \"Programs/LuaIDE.program/startup\" ] = \"if OneOS then\\\
OneOS.ToolBarColour=colours.grey\\\
OneOS.ToolBarTextColour=colours.white\\\
end\\\
local l=io\\\
if OneOS then\\\
l=OneOS.IO\\\
end\\\
local c=fs\\\
if OneOS then\\\
c=OneOS.FS\\\
end\\\
local F=\\\"1.0\\\"\\\
local G={...}\\\
local n,T=term.getSize()\\\
local e=2\\\
local B=20\\\
local E=true\\\
local m=.4\\\
local u=nil\\\
local t={}\\\
local s={}\\\
local d={}\\\
local S=\\\"luaide_distractionEvent\\\"\\\
local M=\\\"https://raw.github.com/GravityScore/LuaIDE/master/luaide.lua\\\"\\\
local C=\\\"/\\\"..shell.getRunningProgram()\\\
local z=\\\"/.LuaIDE-Theme\\\"\\\
local function b()return term.isColor and term.isColor()end\\\
local function p(e)\\\
local a,t=term.getSize()\\\
local t={replaceChar=nil,history=nil,visibleLength=nil,textLength=nil,\\\
liveUpdates=nil,exitOnKey=nil}\\\
if not e then e={}end\\\
for t,a in pairs(t)do if not e[t]then e[t]=a end end\\\
if e.replaceChar then e.replaceChar=e.replaceChar:sub(1,1)end\\\
if not e.visibleLength then e.visibleLength=a end\\\
local s,h=term.getCursorPos()\\\
local a=\\\"\\\"\\\
local t=0\\\
local i=nil\\\
local function n(i)\\\
local o=0\\\
if e.visibleLength and s+t>e.visibleLength+1 then\\\
o=(s+t)-(e.visibleLength+1)\\\
end\\\
term.setCursorPos(s,h)\\\
local e=i or e.replaceChar\\\
if e then term.write(string.rep(e,a:len()-o))\\\
else term.write(a:sub(o+1,-1))end\\\
term.setCursorPos(s+t-o,h)\\\
end\\\
local function s(t,...)\\\
if type(e.liveUpdates)==\\\"function\\\"then\\\
local i,o=term.getCursorPos()\\\
local t,e=e.liveUpdates(a,t,...)\\\
if t==true and e==nil then\\\
term.setCursorBlink(false)\\\
return a\\\
elseif t==true and e~=nil then\\\
term.setCursorBlink(false)\\\
return e\\\
end\\\
term.setCursorPos(i,o)\\\
end\\\
end\\\
term.setCursorBlink(true)\\\
while true do\\\
local h,o,r,l,d,u=os.pullEvent()\\\
if h==\\\"char\\\"then\\\
local s=false\\\
if e.textLength and a:len()<e.textLength then s=true\\\
elseif not e.textLength then s=true end\\\
local i=true\\\
if not e.grantPrint and e.refusePrint then\\\
local t={}\\\
if type(e.refusePrint)==\\\"table\\\"then\\\
for a,e in pairs(e.refusePrint)do\\\
table.insert(t,tostring(e):sub(1,1))\\\
end\\\
elseif type(e.refusePrint)==\\\"string\\\"then\\\
for e in e.refusePrint:gmatch(\\\".\\\")do\\\
table.insert(t,e)\\\
end\\\
end\\\
for t,e in pairs(t)do if o==e then i=false end end\\\
elseif e.grantPrint then\\\
i=false\\\
local t={}\\\
if type(e.grantPrint)==\\\"table\\\"then\\\
for a,e in pairs(e.grantPrint)do\\\
table.insert(t,tostring(e):sub(1,1))\\\
end\\\
elseif type(e.grantPrint)==\\\"string\\\"then\\\
for e in e.grantPrint:gmatch(\\\".\\\")do\\\
table.insert(t,e)\\\
end\\\
end\\\
for t,e in pairs(t)do if o==e then i=true end end\\\
end\\\
if s and i then\\\
a=a:sub(1,t)..o..a:sub(t+1,-1)\\\
t=t+1\\\
n()\\\
end\\\
elseif h==\\\"key\\\"then\\\
if o==keys.enter then break\\\
elseif o==keys.left then if t>0 then t=t-1 n()end\\\
elseif o==keys.right then if t<a:len()then t=t+1 n()end\\\
elseif(o==keys.up or o==keys.down)and e.history then\\\
n(\\\" \\\")\\\
if o==keys.up then\\\
if i==nil and#e.history>0 then\\\
i=#e.history\\\
elseif i>1 then\\\
i=i-1\\\
end\\\
elseif o==keys.down then\\\
if i==#e.history then i=nil\\\
elseif i~=nil then i=i+1 end\\\
end\\\
if e.history and i then\\\
a=e.history[i]\\\
t=a:len()\\\
else\\\
a=\\\"\\\"\\\
t=0\\\
end\\\
n()\\\
local e=s(\\\"history\\\")\\\
if e then return e end\\\
elseif o==keys.backspace and t>0 then\\\
n(\\\" \\\")\\\
a=a:sub(1,t-1)..a:sub(t+1,-1)\\\
t=t-1\\\
n()\\\
local e=s(\\\"delete\\\")\\\
if e then return e end\\\
elseif o==keys.home then\\\
t=0\\\
n()\\\
elseif o==keys.delete and t<a:len()then\\\
n(\\\" \\\")\\\
a=a:sub(1,t)..a:sub(t+2,-1)\\\
n()\\\
local e=s(\\\"delete\\\")\\\
if e then return e end\\\
elseif o==keys[\\\"end\\\"]then\\\
t=a:len()\\\
n()\\\
elseif e.exitOnKey then\\\
if o==e.exitOnKey or(e.exitOnKey==\\\"control\\\"and\\\
(o==29 or o==157))then\\\
term.setCursorBlink(false)\\\
return nil\\\
end\\\
end\\\
end\\\
local e=s(h,o,r,l,d,u)\\\
if e then return e end\\\
end\\\
term.setCursorBlink(false)\\\
if a~=nil then a=a:gsub(\\\"^%s*(.-)%s*$\\\",\\\"%1\\\")end\\\
return a\\\
end\\\
local N={\\\
background=\\\"gray\\\",\\\
backgroundHighlight=\\\"lightGray\\\",\\\
prompt=\\\"cyan\\\",\\\
promptHighlight=\\\"lightBlue\\\",\\\
err=\\\"red\\\",\\\
errHighlight=\\\"pink\\\",\\\
editorBackground=\\\"gray\\\",\\\
editorLineHightlight=\\\"lightBlue\\\",\\\
editorLineNumbers=\\\"gray\\\",\\\
editorLineNumbersHighlight=\\\"lightGray\\\",\\\
editorError=\\\"pink\\\",\\\
editorErrorHighlight=\\\"red\\\",\\\
textColor=\\\"white\\\",\\\
conditional=\\\"yellow\\\",\\\
constant=\\\"orange\\\",\\\
[\\\"function\\\"]=\\\"magenta\\\",\\\
string=\\\"red\\\",\\\
comment=\\\"lime\\\"\\\
}\\\
local U={\\\
background=\\\"black\\\",\\\
backgroundHighlight=\\\"black\\\",\\\
prompt=\\\"black\\\",\\\
promptHighlight=\\\"black\\\",\\\
err=\\\"black\\\",\\\
errHighlight=\\\"black\\\",\\\
editorBackground=\\\"black\\\",\\\
editorLineHightlight=\\\"black\\\",\\\
editorLineNumbers=\\\"black\\\",\\\
editorLineNumbersHighlight=\\\"white\\\",\\\
editorError=\\\"black\\\",\\\
editorErrorHighlight=\\\"black\\\",\\\
textColor=\\\"white\\\",\\\
conditional=\\\"white\\\",\\\
constant=\\\"white\\\",\\\
[\\\"function\\\"]=\\\"white\\\",\\\
string=\\\"white\\\",\\\
comment=\\\"white\\\"\\\
}\\\
local D={\\\
{\\\"Water (Default)\\\",\\\"https://raw.github.com/GravityScore/LuaIDE/master/themes/default.txt\\\"},\\\
{\\\"Fire\\\",\\\"https://raw.github.com/GravityScore/LuaIDE/master/themes/fire.txt\\\"},\\\
{\\\"Sublime Text 2\\\",\\\"https://raw.github.com/GravityScore/LuaIDE/master/themes/st2.txt\\\"},\\\
{\\\"Midnight\\\",\\\"https://raw.github.com/GravityScore/LuaIDE/master/themes/midnight.txt\\\"},\\\
{\\\"TheOriginalBIT\\\",\\\"https://raw.github.com/GravityScore/LuaIDE/master/themes/bit.txt\\\"},\\\
{\\\"Superaxander\\\",\\\"https://raw.github.com/GravityScore/LuaIDE/master/themes/superaxander.txt\\\"},\\\
{\\\"Forest\\\",\\\"https://raw.github.com/GravityScore/LuaIDE/master/themes/forest.txt\\\"},\\\
{\\\"Night\\\",\\\"https://raw.github.com/GravityScore/LuaIDE/master/themes/night.txt\\\"},\\\
{\\\"Original\\\",\\\"https://raw.github.com/GravityScore/LuaIDE/master/themes/original.txt\\\"},\\\
}\\\
local function L(e)\\\
local t=io.open(e)\\\
local e=t:read(\\\"*l\\\")\\\
local a={}\\\
while e~=nil do\\\
local i,o=string.match(e,\\\"^(%a+)=(%a+)\\\")\\\
if i and o then a[i]=o end\\\
e=t:read(\\\"*l\\\")\\\
end\\\
t:close()\\\
return a\\\
end\\\
if b()then t=N\\\
else t=U end\\\
local function f(e,t)\\\
if type(e)==\\\"table\\\"then for t,e in pairs(e)do f(e)end\\\
else\\\
local o,a=term.getCursorPos()\\\
local o,i=term.getSize()\\\
term.setCursorPos(o/2-e:len()/2+(#e%2==0 and 1 or 0),t or a)\\\
print(e)\\\
end\\\
end\\\
local function w(e)\\\
term.setTextColor(colors[t.textColor])\\\
term.setBackgroundColor(colors[t.background])\\\
term.clear()\\\
term.setBackgroundColor(colors[t.backgroundHighlight])\\\
for e=2,4 do term.setCursorPos(1,e)term.clearLine()end\\\
term.setCursorPos(3,3)\\\
term.write(e)\\\
end\\\
local function I(e,a)\\\
local function i(i,o,i,t,a,i,i)\\\
if b()and o==\\\"mouse_click\\\"and t>=n/2-e/2 and t<=n/2-e/2+10\\\
and a>=13 and a<=15 then\\\
return true,\\\"\\\"\\\
end\\\
end\\\
if not a then a=\\\"\\\"end\\\
term.setTextColor(colors[t.textColor])\\\
term.setBackgroundColor(colors[t.promptHighlight])\\\
for t=8,10 do\\\
term.setCursorPos(n/2-e/2,t)\\\
term.write(string.rep(\\\" \\\",e))\\\
end\\\
if b()then\\\
term.setBackgroundColor(colors[t.errHighlight])\\\
for t=13,15 do\\\
term.setCursorPos(n/2-e/2+1,t)\\\
term.write(string.rep(\\\" \\\",10))\\\
end\\\
term.setCursorPos(n/2-e/2+2,14)\\\
term.write(\\\"> Cancel\\\")\\\
end\\\
term.setBackgroundColor(colors[t.promptHighlight])\\\
term.setCursorPos(n/2-e/2+1,9)\\\
term.write(\\\"> \\\"..a)\\\
return p({visibleLength=n/2+e/2,liveUpdates=i})\\\
end\\\
local function q(a,i,h)\\\
local function o(o)\\\
for a,e in ipairs(a)do\\\
if a==o then term.setBackgroundColor(e.highlight or colors[t.promptHighlight])\\\
else term.setBackgroundColor(e.bg or colors[t.prompt])end\\\
term.setTextColor(e.tc or colors[t.textColor])\\\
for t=-1,1 do\\\
term.setCursorPos(e[2],e[3]+t)\\\
term.write(string.rep(\\\" \\\",e[1]:len()+4))\\\
end\\\
term.setCursorPos(e[2],e[3])\\\
if a==o then\\\
term.setBackgroundColor(e.highlight or colors[t.promptHighlight])\\\
term.write(\\\" > \\\")\\\
else term.write(\\\" - \\\")end\\\
term.write(e[1]..\\\" \\\")\\\
end\\\
end\\\
local r=i==\\\"horizontal\\\"and 203 or 200\\\
local d=i==\\\"horizontal\\\"and 205 or 208\\\
local e=1\\\
o(e)\\\
while true do\\\
local t,i,n,s=os.pullEvent()\\\
if t==\\\"key\\\"and i==28 then\\\
return a[e][1]\\\
elseif t==\\\"key\\\"and i==r and e>1 then\\\
e=e-1\\\
o(e)\\\
elseif t==\\\"key\\\"and i==d and((err==true and e<#a-1)or(e<#a))then\\\
e=e+1\\\
o(e)\\\
elseif h and t==\\\"key\\\"and i==203 and e>2 then\\\
e=e-2\\\
o(e)\\\
elseif h and t==\\\"key\\\"and i==205 and e<3 then\\\
e=e+2\\\
o(e)\\\
elseif t==\\\"mouse_click\\\"then\\\
for t,e in ipairs(a)do\\\
if n>=e[2]-1 and n<=e[2]+e[1]:len()+3 and s>=e[3]-1 and s<=e[3]+1 then\\\
return a[t][1]\\\
end\\\
end\\\
end\\\
end\\\
end\\\
local function Y(r)\\\
local function i(e,s,a)\\\
for e,a in ipairs(e)do\\\
local i=colors[t.prompt]\\\
local o=colors[t.promptHighlight]\\\
if a:find(\\\"Back\\\")or a:find(\\\"Return\\\")then\\\
i=colors[t.err]\\\
o=colors[t.errHighlight]\\\
end\\\
if e==s then term.setBackgroundColor(o)\\\
else term.setBackgroundColor(i)end\\\
term.setTextColor(colors[t.textColor])\\\
for t=-1,1 do\\\
term.setCursorPos(3,(e*4)+t+4)\\\
term.write(string.rep(\\\" \\\",n-13))\\\
end\\\
term.setCursorPos(3,e*4+4)\\\
if e==s then\\\
term.setBackgroundColor(o)\\\
term.write(\\\" > \\\")\\\
else term.write(\\\" - \\\")end\\\
term.write(a..\\\" \\\")\\\
end\\\
end\\\
local function d(t,a,o)\\\
local e={}\\\
for o=1,o do\\\
local t=t[o+a-1]\\\
if t then table.insert(e,t)end\\\
end\\\
return e\\\
end\\\
local t=1\\\
local e=1\\\
local o=3\\\
local a=d(r,e,o)\\\
i(a,t,e)\\\
while true do\\\
local s,h,l,u=os.pullEvent()\\\
if s==\\\"mouse_click\\\"then\\\
for e,t in ipairs(a)do\\\
if l>=3 and l<=n-11 and u>=e*4+3 and u<=e*4+5 then return t end\\\
end\\\
elseif s==\\\"key\\\"and h==200 then\\\
if t>1 then\\\
t=t-1\\\
i(a,t,e)\\\
elseif e>1 then\\\
e=e-1\\\
a=d(r,e,o)\\\
i(a,t,e)\\\
end\\\
elseif s==\\\"key\\\"and h==208 then\\\
if t<o then\\\
t=t+1\\\
i(a,t,e)\\\
elseif e+o-1<#r then\\\
e=e+1\\\
a=d(r,e,o)\\\
i(a,t,e)\\\
end\\\
elseif s==\\\"mouse_scroll\\\"then\\\
os.queueEvent(\\\"key\\\",h==-1 and 200 or 208)\\\
elseif s==\\\"key\\\"and h==28 then\\\
return a[t]\\\
end\\\
end\\\
end\\\
function monitorKeyboardShortcuts()\\\
local n,i=nil,nil\\\
local o=false\\\
local a=false\\\
while true do\\\
local t,e=os.pullEvent()\\\
if t==\\\"key\\\"and(e==42 or e==52)then\\\
a=true\\\
i=os.startTimer(m)\\\
elseif t==\\\"key\\\"and(e==29 or e==157 or e==219 or e==220)then\\\
E=false\\\
o=true\\\
n=os.startTimer(m)\\\
elseif t==\\\"key\\\"and o then\\\
local t=nil\\\
for t,o in pairs(keys)do\\\
if o==e then\\\
if a then os.queueEvent(\\\"shortcut\\\",\\\"ctrl shift\\\",t:lower())\\\
else os.queueEvent(\\\"shortcut\\\",\\\"ctrl\\\",t:lower())end\\\
sleep(.005)\\\
E=true\\\
end\\\
end\\\
if a then os.queueEvent(\\\"shortcut\\\",\\\"ctrl shift\\\",e)\\\
else os.queueEvent(\\\"shortcut\\\",\\\"ctrl\\\",e)end\\\
elseif t==\\\"timer\\\"and e==n then\\\
E=true\\\
o=false\\\
elseif t==\\\"timer\\\"and e==i then\\\
a=false\\\
end\\\
end\\\
end\\\
local function P(e,t)\\\
for a=1,3 do\\\
local e=http.get(e)\\\
if e then\\\
local a=e.readAll()\\\
e.close()\\\
if t then\\\
local e=io.open(t,\\\"w\\\")\\\
e:write(a)\\\
e:close()\\\
end\\\
return true\\\
end\\\
end\\\
return false\\\
end\\\
local function y(e,a)\\\
local t=e:sub(1,e:len()-c.getName(e):len())\\\
if not c.exists(t)then c.makeDir(t)end\\\
if not c.isDir(e)and not c.isReadOnly(e)then\\\
local t=\\\"\\\"\\\
for a,e in pairs(a)do t=t..e..\\\"\\\\n\\\"end\\\
local e=l.open(e,\\\"w\\\")\\\
e:write(t)\\\
e:close()\\\
return true\\\
else return false end\\\
end\\\
local function J(e)\\\
if not c.exists(e)then\\\
local t=e:sub(1,e:len()-c.getName(e):len())\\\
if not c.exists(t)then c.makeDir(t)end\\\
local e=l.open(e,\\\"w\\\")\\\
e:write(\\\"\\\")\\\
e:close()\\\
end\\\
local t={}\\\
if c.exists(e)and not c.isDir(e)then\\\
local e=l.open(e,\\\"r\\\")\\\
if e then\\\
local a=e:read(\\\"*l\\\")\\\
while a do\\\
table.insert(t,a)\\\
a=e:read(\\\"*l\\\")\\\
end\\\
e:close()\\\
end\\\
else return nil end\\\
if#t<1 then table.insert(t,\\\"\\\")end\\\
return t\\\
end\\\
s.lua={}\\\
s.brainfuck={}\\\
s.none={}\\\
s.lua.helpTips={\\\
\\\"A function you tried to call doesn't exist.\\\",\\\
\\\"You made a typo.\\\",\\\
\\\"The index of an array is nil.\\\",\\\
\\\"The wrong variable type was passed.\\\",\\\
\\\"A function/variable doesn't exist.\\\",\\\
\\\"You missed an 'end'.\\\",\\\
\\\"You missed a 'then'.\\\",\\\
\\\"You declared a variable incorrectly.\\\",\\\
\\\"One of your variables is mysteriously nil.\\\"\\\
}\\\
s.lua.defaultHelpTips={\\\
2,5\\\
}\\\
s.lua.errors={\\\
[\\\"Attempt to call nil.\\\"]={1,2},\\\
[\\\"Attempt to index nil.\\\"]={3,2},\\\
[\\\".+ expected, got .+\\\"]={4,2,9},\\\
[\\\"'end' expected\\\"]={6,2},\\\
[\\\"'then' expected\\\"]={7,2},\\\
[\\\"'=' expected\\\"]={8,2}\\\
}\\\
s.lua.keywords={\\\
[\\\"and\\\"]=\\\"conditional\\\",\\\
[\\\"break\\\"]=\\\"conditional\\\",\\\
[\\\"do\\\"]=\\\"conditional\\\",\\\
[\\\"else\\\"]=\\\"conditional\\\",\\\
[\\\"elseif\\\"]=\\\"conditional\\\",\\\
[\\\"end\\\"]=\\\"conditional\\\",\\\
[\\\"for\\\"]=\\\"conditional\\\",\\\
[\\\"function\\\"]=\\\"conditional\\\",\\\
[\\\"if\\\"]=\\\"conditional\\\",\\\
[\\\"in\\\"]=\\\"conditional\\\",\\\
[\\\"local\\\"]=\\\"conditional\\\",\\\
[\\\"not\\\"]=\\\"conditional\\\",\\\
[\\\"or\\\"]=\\\"conditional\\\",\\\
[\\\"repeat\\\"]=\\\"conditional\\\",\\\
[\\\"return\\\"]=\\\"conditional\\\",\\\
[\\\"then\\\"]=\\\"conditional\\\",\\\
[\\\"until\\\"]=\\\"conditional\\\",\\\
[\\\"while\\\"]=\\\"conditional\\\",\\\
[\\\"true\\\"]=\\\"constant\\\",\\\
[\\\"false\\\"]=\\\"constant\\\",\\\
[\\\"nil\\\"]=\\\"constant\\\",\\\
[\\\"print\\\"]=\\\"function\\\",\\\
[\\\"write\\\"]=\\\"function\\\",\\\
[\\\"sleep\\\"]=\\\"function\\\",\\\
[\\\"pairs\\\"]=\\\"function\\\",\\\
[\\\"ipairs\\\"]=\\\"function\\\",\\\
[\\\"loadstring\\\"]=\\\"function\\\",\\\
[\\\"loadfile\\\"]=\\\"function\\\",\\\
[\\\"dofile\\\"]=\\\"function\\\",\\\
[\\\"rawset\\\"]=\\\"function\\\",\\\
[\\\"rawget\\\"]=\\\"function\\\",\\\
[\\\"setfenv\\\"]=\\\"function\\\",\\\
[\\\"getfenv\\\"]=\\\"function\\\",\\\
}\\\
s.lua.parseError=function(e)\\\
local t={filename=\\\"unknown\\\",line=-1,display=\\\"Unknown!\\\",err=\\\"\\\"}\\\
if e and e~=\\\"\\\"then\\\
t.err=e\\\
if e:find(\\\":\\\")then\\\
t.filename=e:sub(1,e:find(\\\":\\\")-1):gsub(\\\"^%s*(.-)%s*$\\\",\\\"%1\\\")\\\
e=(e:sub(e:find(\\\":\\\")+1)..\\\"\\\"):gsub(\\\"^%s*(.-)%s*$\\\",\\\"%1\\\")\\\
if e:find(\\\":\\\")then\\\
t.line=e:sub(1,e:find(\\\":\\\")-1)\\\
e=e:sub(e:find(\\\":\\\")+2):gsub(\\\"^%s*(.-)%s*$\\\",\\\"%1\\\")..\\\"\\\"\\\
end\\\
end\\\
t.display=e:sub(1,1):upper()..e:sub(2,-1)..\\\".\\\"\\\
end\\\
return t\\\
end\\\
s.lua.getCompilerErrors=function(e)\\\
e=\\\"local function ee65da6af1cb6f63fee9a081246f2fd92b36ef2(...)\\\\n\\\\n\\\"..e..\\\"\\\\n\\\\nend\\\"\\\
local t,e=loadstring(e)\\\
if not e then\\\
local a,t=pcall(t)\\\
if t then e=t end\\\
end\\\
if e then\\\
local t=e:find(\\\"]\\\",1,true)\\\
if t then e=\\\"string\\\"..e:sub(t+1,-1)end\\\
local e=s.lua.parseError(e)\\\
if tonumber(e.line)then e.line=tonumber(e.line)end\\\
return e\\\
else return s.lua.parseError(nil)end\\\
end\\\
s.lua.run=function(e,a)\\\
local t,e=OneOS.LoadFile(e)\\\
setfenv(t,getfenv())\\\
if not e then\\\
_,e=pcall(function()t(unpack(a))end)\\\
end\\\
return e\\\
end\\\
s.brainfuck.helpTips={\\\
\\\"Well idk...\\\",\\\
\\\"Isn't this the whole point of the language?\\\",\\\
\\\"Ya know... Not being able to debug it?\\\",\\\
\\\"You made a typo.\\\"\\\
}\\\
s.brainfuck.defaultHelpTips={\\\
1,2,3\\\
}\\\
s.brainfuck.errors={\\\
[\\\"No matching '['\\\"]={1,2,3,4}\\\
}\\\
s.brainfuck.keywords={}\\\
s.brainfuck.parseError=function(e)\\\
local t={filename=\\\"unknown\\\",line=-1,display=\\\"Unknown!\\\",err=\\\"\\\"}\\\
if e and e~=\\\"\\\"then\\\
t.err=e\\\
t.line=e:sub(1,e:find(\\\":\\\")-1)\\\
e=e:sub(e:find(\\\":\\\")+2):gsub(\\\"^%s*(.-)%s*$\\\",\\\"%1\\\")..\\\"\\\"\\\
t.display=e:sub(1,1):upper()..e:sub(2,-1)..\\\".\\\"\\\
end\\\
return t\\\
end\\\
s.brainfuck.mapLoops=function(o)\\\
local t={}\\\
local e=1\\\
local a=1\\\
for o in string.gmatch(o,\\\".\\\")do\\\
if o==\\\"[\\\"then\\\
t[e]=true\\\
elseif o==\\\"]\\\"then\\\
local o=false\\\
for a=e,1,-1 do\\\
if t[a]==true then\\\
t[a]=e\\\
o=true\\\
end\\\
end\\\
if not o then\\\
return a..\\\": No matching '['\\\"\\\
end\\\
end\\\
if o==\\\"\\\\n\\\"then a=a+1 end\\\
e=e+1\\\
end\\\
return t\\\
end\\\
s.brainfuck.getCompilerErrors=function(e)\\\
local e=s.brainfuck.mapLoops(e)\\\
if type(e)==\\\"string\\\"then return s.brainfuck.parseError(e)\\\
else return s.brainfuck.parseError(nil)end\\\
end\\\
s.brainfuck.run=function(e)\\\
local e=OneOS.IO.open(e,\\\"r\\\")\\\
local h=e:read(\\\"*a\\\")\\\
e:close()\\\
local t={}\\\
local e=1\\\
local a=1\\\
local i=s.brainfuck.mapLoops(h)\\\
if type(i)==\\\"string\\\"then return i end\\\
while true do\\\
local o=h:sub(a,a)\\\
if o==\\\">\\\"then\\\
e=e+1\\\
if not t[tostring(e)]then t[tostring(e)]=0 end\\\
elseif o==\\\"<\\\"then\\\
if not t[tostring(e)]then t[tostring(e)]=0 end\\\
e=e-1\\\
if not t[tostring(e)]then t[tostring(e)]=0 end\\\
elseif o==\\\"+\\\"then\\\
if not t[tostring(e)]then t[tostring(e)]=0 end\\\
t[tostring(e)]=t[tostring(e)]+1\\\
elseif o==\\\"-\\\"then\\\
if not t[tostring(e)]then t[tostring(e)]=0 end\\\
t[tostring(e)]=t[tostring(e)]-1\\\
elseif o==\\\".\\\"then\\\
if not t[tostring(e)]then t[tostring(e)]=0 end\\\
if term.getCursorPos()>=n then print(\\\"\\\")end\\\
write(string.char(math.max(1,t[tostring(e)])))\\\
elseif o==\\\",\\\"then\\\
if not t[tostring(e)]then t[tostring(e)]=0 end\\\
term.setCursorBlink(true)\\\
local o,a=os.pullEvent(\\\"char\\\")\\\
term.setCursorBlink(false)\\\
t[tostring(e)]=string.byte(a)\\\
if term.getCursorPos()>=n then print(\\\"\\\")end\\\
write(a)\\\
elseif o==\\\"/\\\"then\\\
if not t[tostring(e)]then t[tostring(e)]=0 end\\\
if term.getCursorPos()>=n then print(\\\"\\\")end\\\
write(t[tostring(e)])\\\
elseif o==\\\"[\\\"then\\\
if t[tostring(e)]==0 then\\\
for e,t in pairs(i)do\\\
if e==a then a=t end\\\
end\\\
end\\\
elseif o==\\\"]\\\"then\\\
for e,t in pairs(i)do\\\
if t==a then a=e-1 end\\\
end\\\
end\\\
a=a+1\\\
if a>h:len()then print(\\\"\\\")break end\\\
end\\\
end\\\
s.none.helpTips={}\\\
s.none.defaultHelpTips={}\\\
s.none.errors={}\\\
s.none.keywords={}\\\
s.none.parseError=function(e)\\\
return{filename=\\\"\\\",line=-1,display=\\\"\\\",err=\\\"\\\"}\\\
end\\\
s.none.getCompilerErrors=function(e)\\\
return s.none.parseError(nil)\\\
end\\\
s.none.run=function(e)end\\\
d=s.lua\\\
local function h(a)\\\
w(\\\"LuaIDE - Error Help\\\")\\\
local e=nil\\\
for o,t in pairs(d.errors)do\\\
if a.display:find(o)then e=t break end\\\
end\\\
term.setBackgroundColor(colors[t.err])\\\
for e=6,8 do\\\
term.setCursorPos(5,e)\\\
term.write(string.rep(\\\" \\\",35))\\\
end\\\
term.setBackgroundColor(colors[t.prompt])\\\
for e=10,18 do\\\
term.setCursorPos(5,e)\\\
term.write(string.rep(\\\" \\\",46))\\\
end\\\
if e then\\\
term.setBackgroundColor(colors[t.err])\\\
term.setCursorPos(6,7)\\\
term.write(\\\"Error Help\\\")\\\
term.setBackgroundColor(colors[t.prompt])\\\
for t,e in ipairs(e)do\\\
term.setCursorPos(7,t+10)\\\
term.write(\\\"- \\\"..d.helpTips[e])\\\
end\\\
else\\\
term.setBackgroundColor(colors[t.err])\\\
term.setCursorPos(6,7)\\\
term.write(\\\"No Error Tips Available!\\\")\\\
term.setBackgroundColor(colors[t.prompt])\\\
term.setCursorPos(6,11)\\\
term.write(\\\"There are no error tips available, but\\\")\\\
term.setCursorPos(6,12)\\\
term.write(\\\"you could see if it was any of these:\\\")\\\
for t,e in ipairs(d.defaultHelpTips)do\\\
term.setCursorPos(7,t+12)\\\
term.write(\\\"- \\\"..d.helpTips[e])\\\
end\\\
end\\\
q({{\\\"Back\\\",n-8,7}},\\\"horizontal\\\")\\\
end\\\
local function m(a,i,o)\\\
local e={}\\\
if o then\\\
w(\\\"LuaIDE - Run \\\"..fs.getName(a))\\\
local t=I(n-13,fs.getName(a)..\\\" \\\")\\\
for t in string.gmatch(t,\\\"[^ \\\\t]+\\\")do e[#e+1]=t:gsub(\\\"^%s*(.-)%s*$\\\",\\\"%1\\\")end\\\
end\\\
y(a,i)\\\
term.setCursorBlink(false)\\\
term.setBackgroundColor(colors.black)\\\
term.setTextColor(colors.white)\\\
term.clear()\\\
term.setCursorPos(1,1)\\\
local e=d.run(a,e)\\\
term.setBackgroundColor(colors.black)\\\
print(\\\"\\\\n\\\")\\\
if e then\\\
if b()then term.setTextColor(colors.red)end\\\
f(\\\"The program has crashed!\\\")\\\
end\\\
term.setTextColor(colors.white)\\\
f(\\\"Press any key to return to LuaIDE...\\\")\\\
while true do\\\
local e=os.pullEvent()\\\
if e==\\\"key\\\"then break end\\\
end\\\
os.queueEvent(S)\\\
os.pullEvent()\\\
if e then\\\
if d==s.lua and e:find(\\\"]\\\")then\\\
e=fs.getName(a)..e:sub(e:find(\\\"]\\\",1,true)+1,-1)\\\
end\\\
while true do\\\
w(\\\"LuaIDE - Error!\\\")\\\
term.setBackgroundColor(colors[t.err])\\\
for e=6,8 do\\\
term.setCursorPos(3,e)\\\
term.write(string.rep(\\\" \\\",n-5))\\\
end\\\
term.setCursorPos(4,7)\\\
term.write(\\\"The program has crashed!\\\")\\\
term.setBackgroundColor(colors[t.prompt])\\\
for e=10,14 do\\\
term.setCursorPos(3,e)\\\
term.write(string.rep(\\\" \\\",n-5))\\\
end\\\
local a=d.parseError(e)\\\
term.setCursorPos(4,11)\\\
term.write(\\\"Line: \\\"..a.line)\\\
term.setCursorPos(4,12)\\\
term.write(\\\"Error:\\\")\\\
term.setCursorPos(5,13)\\\
local e=a.display\\\
local o=nil\\\
if e:len()>n-8 then\\\
for t=e:len(),1,-1 do\\\
if e:sub(t,t)==\\\" \\\"then\\\
o=e:sub(t+1,-1)\\\
e=e:sub(1,t)\\\
break\\\
end\\\
end\\\
end\\\
term.write(e)\\\
if o then\\\
term.setCursorPos(5,14)\\\
term.write(o)\\\
end\\\
local e=q({{\\\"Error Help\\\",n/2-15,17},{\\\"Go To Line\\\",n/2+2,17}},\\\
\\\"horizontal\\\")\\\
if e==\\\"Error Help\\\"then\\\
h(a)\\\
elseif e==\\\"Go To Line\\\"then\\\
os.queueEvent(S)\\\
os.pullEvent()\\\
return\\\"go to\\\",tonumber(a.line)\\\
end\\\
end\\\
end\\\
end\\\
local function j()\\\
term.setBackgroundColor(colors[t.backgroundHighlight])\\\
term.setCursorPos(2,1)\\\
term.clearLine()\\\
term.write(\\\"Line: \\\")\\\
local e=p({visibleLength=n-2})\\\
local e=tonumber(e)\\\
if e and e>0 then return e\\\
else\\\
term.setCursorPos(2,1)\\\
term.clearLine()\\\
term.write(\\\"Not a line number!\\\")\\\
sleep(1.6)\\\
return nil\\\
end\\\
end\\\
local function k()\\\
local a={\\\
\\\"[Lua]   Brainfuck    None \\\",\\\
\\\" Lua   [Brainfuck]   None \\\",\\\
\\\" Lua    Brainfuck   [None]\\\"\\\
}\\\
local e=1\\\
term.setCursorBlink(false)\\\
term.setBackgroundColor(colors[t.backgroundHighlight])\\\
term.setCursorPos(2,1)\\\
term.clearLine()\\\
term.write(a[e])\\\
while true do\\\
local o,t,o,o=os.pullEvent(\\\"key\\\")\\\
if t==203 then\\\
e=math.max(1,e-1)\\\
term.setCursorPos(2,1)\\\
term.clearLine()\\\
term.write(a[e])\\\
elseif t==205 then\\\
e=math.min(#a,e+1)\\\
term.setCursorPos(2,1)\\\
term.clearLine()\\\
term.write(a[e])\\\
elseif t==28 then\\\
if e==1 then d=s.lua\\\
elseif e==2 then d=s.brainfuck\\\
elseif e==3 then d=s.none end\\\
term.setCursorBlink(true)\\\
return\\\
end\\\
end\\\
end\\\
local W=2\\\
local o={}\\\
local a={}\\\
local g={\\\
\\\"if%s+.+%s+then%s*$\\\",\\\
\\\"for%s+.+%s+do%s*$\\\",\\\
\\\"while%s+.+%s+do%s*$\\\",\\\
\\\"repeat%s*$\\\",\\\
\\\"function%s+[a-zA-Z_0-9]\\\\(.*\\\\)%s*$\\\"\\\
}\\\
local v={\\\
\\\"end\\\",\\\
\\\"until%s+.+\\\"\\\
}\\\
local p={\\\
\\\"else%s*$\\\",\\\
\\\"elseif%s+.+%s+then%s*$\\\"\\\
}\\\
local function i(e)\\\
for t,e in pairs(e)do\\\
local t=e[\\\"lineStart\\\"]\\\
local a=e[\\\"lineEnd\\\"]\\\
local o=e[\\\"charStart\\\"]\\\
local e=e[\\\"charEnd\\\"]\\\
if line>=t and line<=a then\\\
if line==t then return o<charNumb\\\
elseif line==a then return e>charNumb\\\
else return true end\\\
end\\\
end\\\
end\\\
local function r(e,e)\\\
if i(o)then return true end\\\
if i(a)then return true end\\\
return false\\\
end\\\
local function l(i,t,e,a)\\\
o[#o+1]={}\\\
o[#o].lineStart=i\\\
o[#o].lineEnd=t\\\
o[#o].charStart=e\\\
o[#o].charEnd=a\\\
end\\\
local function h(e,t,o,i)\\\
a[#a+1]={}\\\
a[#a].lineStart=e\\\
a[#a].lineEnd=t\\\
a[#a].charStart=o\\\
a[#a].charEnd=i\\\
end\\\
local function e(e)\\\
local i=false\\\
local t=false\\\
for e=1,#e do\\\
if content[e]:find(\\\"%-%-%[%[\\\")and not t and not i then\\\
local t=content[e]:find(\\\"%-%-%[%[\\\")\\\
l(e,nil,t,nil)\\\
i=true\\\
elseif content[e]:find(\\\"%-%-%[=%[\\\")and not t and not i then\\\
local t=content[e]:find(\\\"%-%-%[=%[\\\")\\\
l(e,nil,t,nil)\\\
i=true\\\
elseif content[e]:find(\\\"%[%[\\\")and not t and not i then\\\
local a=content[e]:find(\\\"%[%[\\\")\\\
h(e,nil,a,nil)\\\
t=true\\\
elseif content[e]:find(\\\"%[=%[\\\")and not t and not i then\\\
local a=content[e]:find(\\\"%[=%[\\\")\\\
h(e,nil,a,nil)\\\
t=true\\\
end\\\
if content[e]:find(\\\"%]%]\\\")and t and not i then\\\
local i,o=content[e]:find(\\\"%]%]\\\")\\\
a[#a].lineEnd=e\\\
a[#a].charEnd=o\\\
t=false\\\
elseif content[e]:find(\\\"%]=%]\\\")and t and not i then\\\
local i,o=content[e]:find(\\\"%]=%]\\\")\\\
a[#a].lineEnd=e\\\
a[#a].charEnd=o\\\
t=false\\\
end\\\
if content[e]:find(\\\"%]%]\\\")and not t and i then\\\
local a,t=content[e]:find(\\\"%]%]\\\")\\\
o[#o].lineEnd=e\\\
o[#o].charEnd=t\\\
i=false\\\
elseif content[e]:find(\\\"%]=%]\\\")and not t and i then\\\
local a,t=content[e]:find(\\\"%]=%]\\\")\\\
o[#o].lineEnd=e\\\
o[#o].charEnd=t\\\
i=false\\\
end\\\
if content[e]:find(\\\"%-%-\\\")and not t and not i then\\\
local t=content[e]:find(\\\"%-%-\\\")\\\
l(e,e,t,-1)\\\
elseif content[e]:find(\\\"'\\\")and not t and not i then\\\
local a,t=content[e]:find(\\\"'\\\")\\\
local t=content[e]:sub(t+1,string.len(content[e]))\\\
local o,t=t:find(\\\"'\\\")\\\
h(e,e,a,t)\\\
elseif content[e]:find('\\\"')and not t and not i then\\\
local a,t=content[e]:find('\\\"')\\\
local t=content[e]:sub(t+1,string.len(content[e]))\\\
local o,t=t:find('\\\"')\\\
h(e,e,a,t)\\\
end\\\
end\\\
end\\\
local function h(a)\\\
local e=nil\\\
if d~=s.lua then\\\
e=\\\"Cannot indent languages other than Lua!\\\"\\\
elseif d.getCompilerErrors(table.concat(a,\\\"\\\\n\\\")).line~=-1 then\\\
e=\\\"Cannot indent a program with errors!\\\"\\\
end\\\
if e then\\\
term.setCursorBlink(false)\\\
term.setCursorPos(2,1)\\\
term.setBackgroundColor(colors[t.backgroundHighlight])\\\
term.clearLine()\\\
term.write(e)\\\
sleep(1.6)\\\
return a\\\
end\\\
local s={}\\\
local t=0\\\
for a,e in pairs(a)do\\\
local o=false\\\
local i=false\\\
for n,t in pairs(g)do\\\
if e:find(t)and not r(a,e:find(t))then\\\
o=true\\\
end\\\
if e:find(t:sub(1,-2))and not r(a,e:find(t))then\\\
i=true\\\
end\\\
end\\\
local n=false\\\
if not o then\\\
for s,o in pairs(v)do\\\
if e:find(o)and not r(a,e:find(o))and not i then\\\
t=math.max(0,t-1)\\\
n=true\\\
end\\\
end\\\
end\\\
if not n then\\\
for n,i in pairs(p)do\\\
if e:find(i)and not r(a,e:find(i))then\\\
o=true\\\
t=math.max(0,t-1)\\\
end\\\
end\\\
end\\\
s[a]=string.rep(\\\" \\\",t*W)..e\\\
if o then t=t+1 end\\\
end\\\
return s\\\
end\\\
local _={\\\
[1]={\\\"File\\\",\\\
\\\"New File  ^+N\\\",\\\
\\\"Open File ^+O\\\",\\\
\\\"Save File ^+S\\\",\\\
\\\"Close     ^+W\\\",\\\
\\\"Print     ^+P\\\",\\\
\\\"Quit      ^+Q\\\"\\\
},[2]={\\\"Edit\\\",\\\
\\\"Cut Line   ^+X\\\",\\\
\\\"Copy Line  ^+C\\\",\\\
\\\"Paste Line ^+V\\\",\\\
\\\"Delete Line\\\",\\\
\\\"Clear Line\\\"\\\
},[3]={\\\"Functions\\\",\\\
\\\"Go To Line    ^+G\\\",\\\
\\\"Re-Indent     ^+I\\\",\\\
\\\"Set Syntax    ^+E\\\",\\\
\\\"Start of Line ^+<\\\",\\\
\\\"End of Line   ^+>\\\"\\\
},[4]={\\\"Run\\\",\\\
\\\"Run Program       ^+R\\\",\\\
\\\"Run w/ Args ^+Shift+R\\\"\\\
}\\\
}\\\
local K={\\\
[\\\"ctrl n\\\"]=\\\"New File  ^+N\\\",\\\
[\\\"ctrl o\\\"]=\\\"Open File ^+O\\\",\\\
[\\\"ctrl s\\\"]=\\\"Save File ^+S\\\",\\\
[\\\"ctrl w\\\"]=\\\"Close     ^+W\\\",\\\
[\\\"ctrl p\\\"]=\\\"Print     ^+P\\\",\\\
[\\\"ctrl q\\\"]=\\\"Quit      ^+Q\\\",\\\
[\\\"ctrl x\\\"]=\\\"Cut Line   ^+X\\\",\\\
[\\\"ctrl c\\\"]=\\\"Copy Line  ^+C\\\",\\\
[\\\"ctrl v\\\"]=\\\"Paste Line ^+V\\\",\\\
[\\\"ctrl g\\\"]=\\\"Go To Line    ^+G\\\",\\\
[\\\"ctrl i\\\"]=\\\"Re-Indent     ^+I\\\",\\\
[\\\"ctrl e\\\"]=\\\"Set Syntax    ^+E\\\",\\\
[\\\"ctrl 203\\\"]=\\\"Start of Line ^+<\\\",\\\
[\\\"ctrl 205\\\"]=\\\"End of Line   ^+>\\\",\\\
[\\\"ctrl r\\\"]=\\\"Run Program       ^+R\\\",\\\
[\\\"ctrl shift r\\\"]=\\\"Run w/ Args ^+Shift+R\\\"\\\
}\\\
local H={\\\
[\\\"New File  ^+N\\\"]=function(t,e)y(t,e)return\\\"new\\\"end,\\\
[\\\"Open File ^+O\\\"]=function(e,t)y(e,t)return\\\"open\\\"end,\\\
[\\\"Save File ^+S\\\"]=function(e,t)y(e,t)end,\\\
[\\\"Close     ^+W\\\"]=function(e,t)y(e,t)return\\\"menu\\\"end,\\\
[\\\"Print     ^+P\\\"]=function(e,t)y(e,t)return nil end,\\\
[\\\"Quit      ^+Q\\\"]=function(e,t)y(e,t)return\\\"exit\\\"end,\\\
[\\\"Cut Line   ^+X\\\"]=function(a,e,t)\\\
u=e[t]table.remove(e,t)return nil,e end,\\\
[\\\"Copy Line  ^+C\\\"]=function(a,t,e)u=t[e]end,\\\
[\\\"Paste Line ^+V\\\"]=function(a,e,t)\\\
if u then table.insert(e,t,u)end return nil,e end,\\\
[\\\"Delete Line\\\"]=function(a,e,t)table.remove(e,t)return nil,e end,\\\
[\\\"Clear Line\\\"]=function(a,e,t)e[t]=\\\"\\\"return nil,e,\\\"cursor\\\"end,\\\
[\\\"Go To Line    ^+G\\\"]=function()return nil,\\\"go to\\\",j()end,\\\
[\\\"Re-Indent     ^+I\\\"]=function(t,e)\\\
local a=h(e)y(t,e)return nil,a\\\
end,\\\
[\\\"Set Syntax    ^+E\\\"]=function(t,e)\\\
k()\\\
if d==s.brainfuck and e[1]~=\\\"-- Syntax: Brainfuck\\\"then\\\
table.insert(e,1,\\\"-- Syntax: Brainfuck\\\")\\\
return nil,e\\\
end\\\
end,\\\
[\\\"Start of Line ^+<\\\"]=function()os.queueEvent(\\\"key\\\",199)end,\\\
[\\\"End of Line   ^+>\\\"]=function()os.queueEvent(\\\"key\\\",207)end,\\\
[\\\"Run Program       ^+R\\\"]=function(t,e)\\\
y(t,e)\\\
return nil,m(t,e,false)\\\
end,\\\
[\\\"Run w/ Args ^+Shift+R\\\"]=function(t,e)\\\
y(t,e)\\\
return nil,m(t,e,true)\\\
end,\\\
}\\\
local function A(a)\\\
term.setCursorPos(1,1)\\\
term.setTextColor(colors[t.textColor])\\\
term.setBackgroundColor(colors[t.backgroundHighlight])\\\
term.clearLine()\\\
local e=0\\\
for a,t in pairs(_)do\\\
term.setCursorPos(3+e,1)\\\
term.write(t[1])\\\
e=e+t[1]:len()+3\\\
end\\\
if a then\\\
local o={}\\\
local e=1\\\
for i,t in pairs(_)do\\\
if a==t[1]then\\\
o=t\\\
break\\\
end\\\
e=e+t[1]:len()+3\\\
end\\\
e=e+1\\\
local a={}\\\
for e=2,#o do\\\
table.insert(a,o[e])\\\
end\\\
local t=1\\\
for a,e in pairs(a)do if e:len()+2>t then t=e:len()+2 end end\\\
for a,o in ipairs(a)do\\\
term.setCursorPos(e,a+1)\\\
term.write(string.rep(\\\" \\\",t))\\\
term.setCursorPos(e+1,a+1)\\\
term.write(o)\\\
end\\\
term.setCursorPos(e,#a+2)\\\
term.write(string.rep(\\\" \\\",t))\\\
return a,t\\\
end\\\
end\\\
local function Q(o,e)\\\
local e=0\\\
local a=nil\\\
for i,t in pairs(_)do\\\
if o>=e+3 and o<=e+t[1]:len()+2 then\\\
a=t[1]\\\
break\\\
end\\\
e=e+t[1]:len()+3\\\
end\\\
local e=e+2\\\
if not a then return false end\\\
term.setCursorBlink(false)\\\
term.setCursorPos(e,1)\\\
term.setBackgroundColor(colors[t.background])\\\
term.write(string.rep(\\\" \\\",a:len()+2))\\\
term.setCursorPos(e+1,1)\\\
term.write(a)\\\
sleep(.1)\\\
local h,s=A(a)\\\
local n=true\\\
local l,d=term.getCursorPos()\\\
while type(n)~=\\\"string\\\"do\\\
local r,d,i,o=os.pullEvent()\\\
if r==\\\"mouse_click\\\"then\\\
if i<e-1 or i>e+s-1 then break\\\
elseif o>#h+2 then break\\\
elseif o==1 then break end\\\
for r,h in ipairs(h)do\\\
if o==r+1 and i>=e and i<=e+s-2 then\\\
term.setCursorPos(e,o)\\\
term.setBackgroundColor(colors[t.background])\\\
term.write(string.rep(\\\" \\\",s))\\\
term.setCursorPos(e+1,o)\\\
term.write(h)\\\
sleep(.1)\\\
A(a)\\\
n=h\\\
break\\\
end\\\
end\\\
end\\\
end\\\
term.setCursorPos(l,d)\\\
term.setCursorBlink(true)\\\
return n\\\
end\\\
local V={\\\
\\\"if%s+.+%s+then%s*$\\\",\\\
\\\"for%s+.+%s+do%s*$\\\",\\\
\\\"while%s+.+%s+do%s*$\\\",\\\
\\\"repeat%s*$\\\",\\\
\\\"function%s+[a-zA-Z_0-9]?\\\\(.*\\\\)%s*$\\\",\\\
\\\"=%s*function%s*\\\\(.*\\\\)%s*$\\\",\\\
\\\"else%s*$\\\",\\\
\\\"elseif%s+.+%s+then%s*$\\\"\\\
}\\\
local O={\\\
[\\\"(\\\"]=\\\")\\\",\\\
[\\\"{\\\"]=\\\"}\\\",\\\
[\\\"[\\\"]=\\\"]\\\",\\\
[\\\"\\\\\\\"\\\"]=\\\"\\\\\\\"\\\",\\\
[\\\"'\\\"]=\\\"'\\\",\\\
}\\\
local a,e=0,0\\\
local x,g=0,T-1\\\
local l,h=0,1\\\
local m,i=0,0\\\
local o={}\\\
local r=d.parseError(nil)\\\
local v=true\\\
local j=os.clock()\\\
local function u(o,e,a)\\\
local e=string.match(o,e)\\\
if e then\\\
if type(a)==\\\"number\\\"then term.setTextColor(a)\\\
elseif type(a)==\\\"function\\\"then term.setTextColor(a(e))end\\\
term.write(e)\\\
term.setTextColor(colors[t.textColor])\\\
return o:sub(e:len()+1,-1)\\\
end\\\
return nil\\\
end\\\
local function R(e)\\\
if d==s.lua then\\\
while e:len()>0 do\\\
e=u(e,\\\"^%-%-%[%[.-%]%]\\\",colors[t.comment])or\\\
u(e,\\\"^%-%-.*\\\",colors[t.comment])or\\\
u(e,\\\"^\\\\\\\".*[^\\\\\\\\]\\\\\\\"\\\",colors[t.string])or\\\
u(e,\\\"^\\\\'.*[^\\\\\\\\]\\\\'\\\",colors[t.string])or\\\
u(e,\\\"^%[%[.-%]%]\\\",colors[t.string])or\\\
u(e,\\\"^[%w_]+\\\",function(e)\\\
if d.keywords[e]then\\\
return colors[t[d.keywords[e]]]\\\
end\\\
return colors[t.textColor]\\\
end)or\\\
u(e,\\\"^[^%w_]\\\",colors[t.textColor])\\\
end\\\
else term.write(e)end\\\
end\\\
local function k()\\\
term.setTextColor(colors[t.textColor])\\\
term.setBackgroundColor(colors[t.editorBackground])\\\
term.clear()\\\
A()\\\
l,h=tostring(#o):len()+1,1\\\
x,g=n-l,T-1\\\
for a=1,g do\\\
local n=o[i+a]\\\
if n then\\\
local o=string.rep(\\\" \\\",l-1-tostring(i+a):len())..tostring(i+a)\\\
local s=n:sub(m+1,x+m+1)\\\
o=o..\\\":\\\"\\\
if r.line==i+a then o=string.rep(\\\" \\\",l-2)..\\\"!:\\\"end\\\
term.setCursorPos(1,a+h)\\\
term.setBackgroundColor(colors[t.editorBackground])\\\
if i+a==e then\\\
if i+a==r.line and os.clock()-j>3 then\\\
term.setBackgroundColor(colors[t.editorErrorHighlight])\\\
else term.setBackgroundColor(colors[t.editorLineHightlight])end\\\
term.clearLine()\\\
elseif i+a==r.line then\\\
term.setBackgroundColor(colors[t.editorError])\\\
term.clearLine()\\\
end\\\
term.setCursorPos(1-m+l,a+h)\\\
if i+a==e then\\\
if i+a==r.line and os.clock()-j>3 then\\\
term.setBackgroundColor(colors[t.editorErrorHighlight])\\\
else term.setBackgroundColor(colors[t.editorLineHightlight])end\\\
elseif i+a==r.line then term.setBackgroundColor(colors[t.editorError])\\\
else term.setBackgroundColor(colors[t.editorBackground])end\\\
if i+a==r.line then\\\
if v then term.write(n)\\\
else term.write(r.display)end\\\
else R(n)end\\\
term.setCursorPos(1,a+h)\\\
if i+a==e then\\\
if i+a==r.line and os.clock()-j>3 then\\\
term.setBackgroundColor(colors[t.editorError])\\\
else term.setBackgroundColor(colors[t.editorLineNumbersHighlight])end\\\
elseif i+a==r.line then\\\
term.setBackgroundColor(colors[t.editorErrorHighlight])\\\
else term.setBackgroundColor(colors[t.editorLineNumbers])end\\\
term.write(o)\\\
end\\\
end\\\
term.setCursorPos(a-m+l,e-i+h)\\\
end\\\
local function p(...)\\\
local n={...}\\\
l=tostring(#o):len()+1\\\
for n,a in pairs(n)do\\\
local o=o[a]\\\
if o then\\\
local n=string.rep(\\\" \\\",l-1-tostring(a):len())..tostring(a)\\\
local s=o:sub(m+1,x+m+1)\\\
n=n..\\\":\\\"\\\
if r.line==a then n=string.rep(\\\" \\\",l-2)..\\\"!:\\\"end\\\
term.setCursorPos(1,(a-i)+h)\\\
term.setBackgroundColor(colors[t.editorBackground])\\\
if a==e then\\\
if a==r.line and os.clock()-j>3 then\\\
term.setBackgroundColor(colors[t.editorErrorHighlight])\\\
else term.setBackgroundColor(colors[t.editorLineHightlight])end\\\
elseif a==r.line then\\\
term.setBackgroundColor(colors[t.editorError])\\\
end\\\
term.clearLine()\\\
term.setCursorPos(1-m+l,(a-i)+h)\\\
if a==e then\\\
if a==r.line and os.clock()-j>3 then\\\
term.setBackgroundColor(colors[t.editorErrorHighlight])\\\
else term.setBackgroundColor(colors[t.editorLineHightlight])end\\\
elseif a==r.line then term.setBackgroundColor(colors[t.editorError])\\\
else term.setBackgroundColor(colors[t.editorBackground])end\\\
if a==r.line then\\\
if v then term.write(o)\\\
else term.write(r.display)end\\\
else R(o)end\\\
term.setCursorPos(1,(a-i)+h)\\\
if a==e then\\\
if a==r.line and os.clock()-j>3 then\\\
term.setBackgroundColor(colors[t.editorError])\\\
else term.setBackgroundColor(colors[t.editorLineNumbersHighlight])end\\\
elseif a==r.line then\\\
term.setBackgroundColor(colors[t.editorErrorHighlight])\\\
else term.setBackgroundColor(colors[t.editorLineNumbers])end\\\
term.write(n)\\\
end\\\
end\\\
term.setCursorPos(a-m+l,e-i+h)\\\
end\\\
local function u(n,o,s)\\\
local a,t=n-m,o-i\\\
local e=false\\\
if a<1 then\\\
m=n-1\\\
a=1\\\
e=true\\\
elseif a>x then\\\
m=n-x\\\
a=x\\\
e=true\\\
end if t<1 then\\\
i=o-1\\\
t=1\\\
e=true\\\
elseif t>g then\\\
i=o-g\\\
t=g\\\
e=true\\\
end if e or s then k()end\\\
term.setCursorPos(a+l,t+h)\\\
end\\\
local function R(t,n)\\\
if type(t)==\\\"string\\\"and H[t]then\\\
local n,t,i=H[t](n,o,e)\\\
if type(n)==\\\"string\\\"then term.setCursorBlink(false)return n end\\\
if type(t)==\\\"table\\\"then\\\
if#o<1 then table.insert(o,\\\"\\\")end\\\
e=math.min(e,#o)\\\
a=math.min(a,o[e]:len()+1)\\\
o=t\\\
elseif type(t)==\\\"string\\\"then\\\
if t==\\\"go to\\\"and i then\\\
a,e=1,math.min(#o,i)\\\
u(a,e)\\\
end\\\
end\\\
end\\\
term.setCursorBlink(true)\\\
k()\\\
term.setCursorPos(a-m+l,e-i+h)\\\
end\\\
local function H(q)\\\
a,e=1,1\\\
l,h=0,1\\\
m,i=0,0\\\
o=J(q)\\\
if not o then return\\\"menu\\\"end\\\
if o[1]==\\\"-- Syntax: Brainfuck\\\"then\\\
d=s.brainfuck\\\
end\\\
local z=os.clock()\\\
local c=os.clock()\\\
local x=os.clock()\\\
local b=false\\\
k()\\\
term.setCursorPos(a+l,e+h)\\\
term.setCursorBlink(true)\\\
local j=os.startTimer(3)\\\
while true do\\\
local s,n,f,w=os.pullEvent()\\\
if s==\\\"key\\\"and E then\\\
if n==200 and e>1 then\\\
a,e=math.min(a,o[e-1]:len()+1),e-1\\\
p(e,e+1)\\\
u(a,e)\\\
elseif n==208 and e<#o then\\\
a,e=math.min(a,o[e+1]:len()+1),e+1\\\
p(e,e-1)\\\
u(a,e)\\\
elseif n==203 and a>1 then\\\
a=a-1\\\
local t=false\\\
if e-i+h<h+1 then t=true end\\\
u(a,e,t)\\\
elseif n==205 and a<o[e]:len()+1 then\\\
a=a+1\\\
local t=false\\\
if e-i+h<h+1 then t=true end\\\
u(a,e,t)\\\
elseif(n==28 or n==156)and(v and true or e+i-1==\\\
r.line)then\\\
local i=nil\\\
for a,t in pairs(V)do\\\
if o[e]:find(t)then i=t end\\\
end\\\
local n,t=o[e]:find(\\\"^[ ]+\\\")\\\
if not t then t=0 end\\\
if i then\\\
table.insert(o,e+1,string.rep(\\\" \\\",t+2))\\\
if not i:find(\\\"else\\\",1,true)and not i:find(\\\"elseif\\\",1,true)then\\\
table.insert(o,e+2,string.rep(\\\" \\\",t)..\\\
(i:find(\\\"repeat\\\",1,true)and\\\"until \\\"or i:find(\\\"{\\\",1,true)and\\\"}\\\"or\\\
\\\"end\\\"))\\\
end\\\
a,e=t+3,e+1\\\
u(a,e,true)\\\
else\\\
local i=o[e]\\\
o[e]=o[e]:sub(1,a-1)\\\
table.insert(o,e+1,string.rep(\\\" \\\",t)..i:sub(a,-1))\\\
a,e=t+1,e+1\\\
u(a,e,true)\\\
end\\\
elseif n==14 and(v and true or e+i-1==r.line)then\\\
if a>1 then\\\
local t=false\\\
for i,n in pairs(O)do\\\
if o[e]:sub(a-1,a-1)==i then t=true end\\\
end\\\
o[e]=o[e]:sub(1,a-2)..o[e]:sub(a+(t and 1 or 0),-1)\\\
p(e)\\\
a=a-1\\\
u(a,e)\\\
elseif e>1 then\\\
local t=o[e-1]:len()+1\\\
o[e-1]=o[e-1]..o[e]\\\
table.remove(o,e)\\\
a,e=t,e-1\\\
u(a,e,true)\\\
end\\\
elseif n==199 then\\\
a=1\\\
local t=false\\\
if e-i+h<h+1 then t=true end\\\
u(a,e,t)\\\
elseif n==207 then\\\
a=o[e]:len()+1\\\
local t=false\\\
if e-i+h<h+1 then t=true end\\\
u(a,e,t)\\\
elseif n==211 and(v and true or e+i-1==r.line)then\\\
if a<o[e]:len()+1 then\\\
o[e]=o[e]:sub(1,a-1)..o[e]:sub(a+1)\\\
local t=false\\\
if e-i+h<h+1 then t=true end\\\
p(e)\\\
u(a,e,t)\\\
elseif e<#o then\\\
o[e]=o[e]..o[e+1]\\\
table.remove(o,e+1)\\\
k()\\\
u(a,e)\\\
end\\\
elseif n==15 and(v and true or e+i-1==r.line)then\\\
o[e]=string.rep(\\\" \\\",W)..o[e]\\\
a=a+2\\\
local t=false\\\
if e-i+h<h+1 then t=true end\\\
p(e)\\\
u(a,e,t)\\\
elseif n==201 then\\\
e=math.min(math.max(e-g,1),#o)\\\
a=math.min(o[e]:len()+1,a)\\\
u(a,e,true)\\\
elseif n==209 then\\\
e=math.min(math.max(e+g,1),#o)\\\
a=math.min(o[e]:len()+1,a)\\\
u(a,e,true)\\\
end\\\
elseif s==\\\"char\\\"and E and(v and true or\\\
e+i-1==r.line)then\\\
local t=false\\\
for s,i in pairs(O)do\\\
if n==i and o[e]:find(s,1,true)and o[e]:sub(a,a)==i then\\\
t=true\\\
end\\\
end\\\
local s=false\\\
if not t then\\\
for t,i in pairs(O)do\\\
if n==t and o[e]:sub(a,a)~=t then n=n..i s=true end\\\
end\\\
o[e]=o[e]:sub(1,a-1)..n..o[e]:sub(a,-1)\\\
end\\\
a=a+(s and 1 or n:len())\\\
local t=false\\\
if e-i+h<h+1 then t=true end\\\
p(e)\\\
u(a,e,t)\\\
elseif s==\\\"mouse_click\\\"and n==1 then\\\
if w>1 then\\\
if f<=l and w-h==r.line-i then\\\
v=not v\\\
p(r.line)\\\
else\\\
local t=e\\\
e=math.min(math.max(i+w-h,1),#o)\\\
a=math.min(math.max(m+f-l,1),o[e]:len()+1)\\\
if t~=e then p(t,e)end\\\
u(a,e)\\\
end\\\
else\\\
local e=Q(f,w)\\\
if e then\\\
local e=R(e,q)\\\
if e then return e end\\\
end\\\
end\\\
elseif s==\\\"shortcut\\\"then\\\
local a=K[n..\\\" \\\"..f]\\\
if a then\\\
local e=nil\\\
local o=0\\\
for i,t in ipairs(_)do\\\
for o,t in pairs(t)do\\\
if t==a then\\\
e=_[i][1]\\\
break\\\
end\\\
end\\\
if e then break end\\\
o=o+t[1]:len()+3\\\
end\\\
local o=o+2\\\
term.setCursorBlink(false)\\\
term.setCursorPos(o,1)\\\
term.setBackgroundColor(colors[t.background])\\\
term.write(string.rep(\\\" \\\",e:len()+2))\\\
term.setCursorPos(o+1,1)\\\
term.write(e)\\\
sleep(.1)\\\
A()\\\
local e=R(a,q)\\\
if e then return e end\\\
end\\\
elseif s==\\\"mouse_scroll\\\"then\\\
if n==-1 and i>0 then\\\
i=i-1\\\
if os.clock()-c>5e-4 then\\\
k()\\\
term.setCursorPos(a-m+l,e-i+h)\\\
end\\\
c=os.clock()\\\
b=true\\\
elseif n==1 and i<#o-g then\\\
i=i+1\\\
if os.clock()-c>5e-4 then\\\
k()\\\
term.setCursorPos(a-m+l,e-i+h)\\\
end\\\
c=os.clock()\\\
b=true\\\
end\\\
elseif s==\\\"timer\\\"and n==j then\\\
p(e)\\\
j=os.startTimer(3)\\\
end\\\
if b and os.clock()-c>.1 then\\\
k()\\\
term.setCursorPos(a-m+l,e-i+h)\\\
b=false\\\
end\\\
if os.clock()-z>B then\\\
y(q,o)\\\
z=os.clock()\\\
end\\\
if os.clock()-x>1 then\\\
local a=r\\\
r=d.parseError(nil)\\\
local e=\\\"\\\"\\\
for a,t in pairs(o)do e=e..t..\\\"\\\\n\\\"end\\\
r=d.getCompilerErrors(e)\\\
r.line=math.min(r.line-2,#o)\\\
if r~=a then k()end\\\
x=os.clock()\\\
end\\\
end\\\
return\\\"menu\\\"\\\
end\\\
local function r()\\\
local a=n-13\\\
w(\\\"Lua IDE - New File\\\")\\\
local e=I(a,\\\"/\\\")\\\
if not e or e==\\\"\\\"then return\\\"menu\\\"end\\\
e=\\\"/\\\"..e\\\
w(\\\"Lua IDE - New File\\\")\\\
term.setTextColor(colors[t.textColor])\\\
term.setBackgroundColor(colors[t.promptHighlight])\\\
for e=8,10 do\\\
term.setCursorPos(n/2-a/2,e)\\\
term.write(string.rep(\\\" \\\",a))\\\
end\\\
term.setCursorPos(1,9)\\\
if c.isDir(e)then\\\
f(\\\"Cannot Edit a Directory!\\\")\\\
sleep(1.6)\\\
return\\\"menu\\\"\\\
elseif c.exists(e)then\\\
f(\\\"File Already Exists!\\\")\\\
local t=q({{\\\"Open\\\",n/2-9,14},{\\\"Cancel\\\",n/2+2,14}},\\\"horizontal\\\")\\\
if t==\\\"Open\\\"then return\\\"edit\\\",e\\\
elseif t==\\\"Cancel\\\"then return\\\"menu\\\"end\\\
else return\\\"edit\\\",e end\\\
end\\\
local function h()\\\
local a=n-13\\\
w(\\\"Lua IDE - Open File\\\")\\\
local e=I(a,\\\"/\\\")\\\
if not e or e==\\\"\\\"then return\\\"menu\\\"end\\\
e=\\\"/\\\"..e\\\
w(\\\"Lua IDE - New File\\\")\\\
term.setTextColor(colors[t.textColor])\\\
term.setBackgroundColor(colors[t.promptHighlight])\\\
for e=8,10 do\\\
term.setCursorPos(n/2-a/2,e)\\\
term.write(string.rep(\\\" \\\",a))\\\
end\\\
term.setCursorPos(1,9)\\\
if c.isDir(e)then\\\
f(\\\"Cannot Open a Directory!\\\")\\\
sleep(1.6)\\\
return\\\"menu\\\"\\\
elseif not c.exists(e)then\\\
f(\\\"File Doesn't Exist!\\\")\\\
local t=q({{\\\"Create\\\",n/2-11,14},{\\\"Cancel\\\",n/2+2,14}},\\\"horizontal\\\")\\\
if t==\\\"Create\\\"then return\\\"edit\\\",e\\\
elseif t==\\\"Cancel\\\"then return\\\"menu\\\"end\\\
else return\\\"edit\\\",e end\\\
end\\\
local function e()\\\
local function e(e)\\\
w(\\\"LuaIDE - Update\\\")\\\
term.setBackgroundColor(colors[t.prompt])\\\
term.setTextColor(colors[t.textColor])\\\
for t=8,10 do\\\
term.setCursorPos(n/2-(e:len()+4),t)\\\
write(string.rep(\\\" \\\",e:len()+4))\\\
end\\\
term.setCursorPos(n/2-(e:len()+4),9)\\\
term.write(\\\" - \\\"..e..\\\" \\\")\\\
term.setBackgroundColor(colors[t.errHighlight])\\\
for e=8,10 do\\\
term.setCursorPos(n/2+2,e)\\\
term.write(string.rep(\\\" \\\",10))\\\
end\\\
term.setCursorPos(n/2+2,9)\\\
term.write(\\\" > Cancel \\\")\\\
end\\\
if not http then\\\
e(\\\"HTTP API Disabled!\\\")\\\
sleep(1.6)\\\
return\\\"settings\\\"\\\
end\\\
e(\\\"Updating...\\\")\\\
local i=os.startTimer(10)\\\
http.request(M)\\\
while true do\\\
local t,o,a,s=os.pullEvent()\\\
if(t==\\\"key\\\"and o==28)or\\\
(t==\\\"mouse_click\\\"and a>=n/2+2 and a<=n/2+12 and s==9)then\\\
e(\\\"Cancelled\\\")\\\
sleep(1.6)\\\
break\\\
elseif t==\\\"http_success\\\"and o==M then\\\
local a=a.readAll()\\\
local t=io.open(C,\\\"r\\\")\\\
local o=t:read(\\\"*a\\\")\\\
t:close()\\\
if o~=a then\\\
e(\\\"Update Found\\\")\\\
sleep(1.6)\\\
local t=io.open(C,\\\"w\\\")\\\
t:write(a)\\\
t:close()\\\
e(\\\"Click to Exit\\\")\\\
while true do\\\
local e=os.pullEvent()\\\
if e==\\\"mouse_click\\\"or(not b()and e==\\\"key\\\")then break end\\\
end\\\
return\\\"exit\\\"\\\
else\\\
e(\\\"No Updates Found!\\\")\\\
sleep(1.6)\\\
break\\\
end\\\
elseif t==\\\"http_failure\\\"or(t==\\\"timer\\\"and o==i)then\\\
e(\\\"Update Failed!\\\")\\\
sleep(1.6)\\\
break\\\
end\\\
end\\\
return\\\"settings\\\"\\\
end\\\
local function o()\\\
w(\\\"LuaIDE - Theme\\\")\\\
if b()then\\\
local e={\\\"Back\\\"}\\\
for a,t in pairs(D)do table.insert(e,t[1])end\\\
local a=Y(e)\\\
local e=nil\\\
for o,t in pairs(D)do if t[1]==a then e=t[2]end end\\\
if not e then return\\\"settings\\\"end\\\
if a==\\\"Dawn (Default)\\\"then\\\
term.setBackgroundColor(colors[t.backgroundHighlight])\\\
term.setCursorPos(3,3)\\\
term.clearLine()\\\
term.write(\\\"LuaIDE - Loaded Theme!\\\")\\\
sleep(1.6)\\\
fs.delete(z)\\\
t=N\\\
return\\\"menu\\\"\\\
end\\\
term.setBackgroundColor(colors[t.backgroundHighlight])\\\
term.setCursorPos(3,3)\\\
term.clearLine()\\\
term.write(\\\"LuaIDE - Downloading...\\\")\\\
fs.delete(\\\"/.LuaIDE_temp_theme_file\\\")\\\
P(e,\\\"/.LuaIDE_temp_theme_file\\\")\\\
local e=L(\\\"/.LuaIDE_temp_theme_file\\\")\\\
term.setCursorPos(3,3)\\\
term.clearLine()\\\
if e then\\\
term.write(\\\"LuaIDE - Loaded Theme!\\\")\\\
fs.delete(z)\\\
fs.move(\\\"/.LuaIDE_temp_theme_file\\\",z)\\\
t=e\\\
sleep(1.6)\\\
return\\\"menu\\\"\\\
end\\\
term.write(\\\"LuaIDE - Could Not Load Theme!\\\")\\\
fs.delete(\\\"/.LuaIDE_temp_theme_file\\\")\\\
sleep(1.6)\\\
return\\\"settings\\\"\\\
else\\\
term.setCursorPos(1,8)\\\
f(\\\"Themes are not available on\\\")\\\
f(\\\"normal computers!\\\")\\\
end\\\
end\\\
local function s()\\\
w(\\\"LuaIDE - Settings\\\")\\\
local e=q({{\\\"Change Theme\\\",n/2-17,8},{\\\"Return to Menu\\\",n/2-22,13},\\\
{\\\"Exit IDE\\\",n/2+2,13,bg=colors[t.err],\\\
highlight=colors[t.errHighlight]}},\\\"vertical\\\",true)\\\
if e==\\\"Change Theme\\\"then return o()\\\
elseif e==\\\"Return to Menu\\\"then return\\\"menu\\\"\\\
elseif e==\\\"Exit IDE\\\"then return\\\"exit\\\"end\\\
end\\\
local function i()\\\
w(\\\"Welcome to LuaIDE \\\"..F)\\\
local e=q({{\\\"New File\\\",n/2-13,8},{\\\"Open File\\\",n/2-14,13},\\\
{\\\"Settings\\\",n/2+2,8},{\\\"Exit IDE\\\",n/2+2,13,bg=colors[t.err],\\\
highlight=colors[t.errHighlight]}},\\\"vertical\\\",true)\\\
if e==\\\"New File\\\"then return\\\"new\\\"\\\
elseif e==\\\"Open File\\\"then return\\\"open\\\"\\\
elseif e==\\\"Settings\\\"then return\\\"settings\\\"\\\
elseif e==\\\"Exit IDE\\\"then return\\\"exit\\\"end\\\
end\\\
local function o(a)\\\
local e,t=\\\"menu\\\",nil\\\
if type(a)==\\\"table\\\"and#a>0 then\\\
local a=\\\"/\\\"..shell.resolve(a[1])\\\
if c.isDir(a)then print(\\\"Cannot edit a directory.\\\")end\\\
e,t=\\\"edit\\\",a\\\
end\\\
while true do\\\
if e==\\\"menu\\\"then e=i()end\\\
if e==\\\"new\\\"then e,t=r()\\\
elseif e==\\\"open\\\"then e,t=h()\\\
elseif e==\\\"settings\\\"then e=s()\\\
end if e==\\\"exit\\\"then break end\\\
if e==\\\"edit\\\"and t then e=H(t)end\\\
end\\\
end\\\
if fs.exists(z)then t=L(z)end\\\
if not t and b()then t=N\\\
elseif not t then t=U end\\\
local a,e=pcall(function()\\\
parallel.waitForAny(function()o(G)end,monitorKeyboardShortcuts)\\\
end)\\\
if e and not e:find(\\\"Terminated\\\")then\\\
term.setCursorBlink(false)\\\
w(\\\"LuaIDE - Crash! D:\\\")\\\
term.setBackgroundColor(colors[t.err])\\\
for e=6,8 do\\\
term.setCursorPos(5,e)\\\
term.write(string.rep(\\\" \\\",36))\\\
end\\\
term.setCursorPos(6,7)\\\
term.write(\\\"LuaIDE Has Crashed! D:\\\")\\\
term.setBackgroundColor(colors[t.background])\\\
term.setCursorPos(2,10)\\\
print(e)\\\
term.setBackgroundColor(colors[t.prompt])\\\
local a,e=term.getCursorPos()\\\
for e=e+1,e+4 do\\\
term.setCursorPos(5,e)\\\
term.write(string.rep(\\\" \\\",36))\\\
end\\\
term.setCursorPos(6,e+2)\\\
term.write(\\\"Please report this error to\\\")\\\
term.setCursorPos(6,e+3)\\\
term.write(\\\"GravityScore! \\\")\\\
term.setBackgroundColor(colors[t.background])\\\
if b()then f(\\\"Click to Exit...\\\",T-1)\\\
else f(\\\"Press Any Key to Exit...\\\",T-1)end\\\
while true do\\\
local e=os.pullEvent()\\\
if e==\\\"mouse_click\\\"or(not b()and e==\\\"key\\\")then break end\\\
end\\\
os.queueEvent(S)\\\
os.pullEvent()\\\
end\\\
term.setBackgroundColor(colors.black)\\\
term.setTextColor(colors.white)\\\
term.clear()\\\
term.setCursorPos(1,1)\\\
f(\\\"Thank You for Using Lua IDE \\\"..F)\\\
f(\\\"Made by GravityScore\\\")\",\
    [ \"System/Programs/Files.program/images/Computer\" ] = \"4f     \\\
4f f4>0_f 4 \\\
4f f   4 \\\
4f   - \",\
    [ \"Desktop/Games.shortcut\" ] = \"/Programs/Games/\",\
    [ \"System/Programs/Files.program/Views/optionsmenu.view\" ] = \"{\\\
  [\\\"Type\\\"]=\\\"Menu\\\",\\\
  [\\\"Owner\\\"]=\\\"OptionsButton\\\",\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Name\\\"]=\\\"ViewModeMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"List View\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Name\\\"]=\\\"HiddenFilesMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Show Hidden\\\"\\\
    }\\\
  },\\\
}\",\
    [ \"System/Images/Icons/folder\" ] = \"4     \\\
4    \\\
41Fldr\",\
    [ \"Programs/Quest.program/Pages/downloaded.ccml\" ] = \"<!DOCTYPE ccml>\\\
<html>\\\
	<head>\\\
		<title>Download Complete</title>\\\
	    <script type=\\\"lua\\\">\\\
	    	if window.get.path then\\\
	        	l('p').text('Your file has been saved to ' .. window.get.path .. '. You can now leave this page (use the back button).')\\\
	    	end\\\
	    </script>\\\
	</head>\\\
	<body>\\\
		<br/>\\\
		<br/>\\\
		<h colour=\\\"blue\\\">Download Complete</h>\\\
\\\
		<center>\\\
			<br>\\\
			<p width=\\\"48\\\" align=\\\"center\\\"></p>\\\
		</center>\\\
	</body>\\\
</html>\",\
    [ \"System/Programs/About OneOS.program/Views/storage.view\" ] = \"{\\\
  [\\\"Width\\\"]=\\\"100%\\\",\\\
  [\\\"Height\\\"]=5,\\\
  [\\\"Type\\\"]=\\\"View\\\",\\\
  [\\\"BackgroundColour\\\"]=0,\\\
  [\\\"Children\\\"]={\\\
	[1]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=2,\\\
      [\\\"Width\\\"]=13,\\\
      [\\\"Name\\\"]=\\\"StorageLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Storage Usage\\\",\\\
      [\\\"TextColour\\\"]=128,\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=17,\\\
      [\\\"Width\\\"]=\\\"100%,-15\\\",\\\
      [\\\"Name\\\"]=\\\"StorageInfoLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Loading...\\\",\\\
      [\\\"TextColour\\\"]=256,\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=3,\\\
      [\\\"X\\\"]=2,\\\
      [\\\"Width\\\"]=\\\"100%,-2\\\",\\\
      [\\\"Name\\\"]=\\\"StorageProgressBar\\\",\\\
      [\\\"Type\\\"]=\\\"ProgressBar\\\",\\\
      [\\\"BarColour\\\"]={16384, 2048, 8192, 16},\\\
    },\\\
    [4]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=2,\\\
      [\\\"Name\\\"]=\\\"SystemKeyView\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"BackgroundColour\\\"]=16384,\\\
    },\\\
    [5]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=4,\\\
      [\\\"Width\\\"]=6,\\\
      [\\\"Name\\\"]=\\\"SystemKeyLabel\\\",\\\
      [\\\"Text\\\"]=\\\"System\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"TextColour\\\"]=128,\\\
    },\\\
    [6]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=12,\\\
      [\\\"Name\\\"]=\\\"ProgramsKeyView\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"BackgroundColour\\\"]=2048,\\\
    },\\\
    [7]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=14,\\\
      [\\\"Width\\\"]=8,\\\
      [\\\"Name\\\"]=\\\"ProgramsKeyLabel\\\",\\\
      [\\\"Text\\\"]=\\\"Programs\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"TextColour\\\"]=128,\\\
    },\\\
    [8]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=24,\\\
      [\\\"Name\\\"]=\\\"DesktopKeyView\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"BackgroundColour\\\"]=8192,\\\
    },\\\
    [9]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=26,\\\
      [\\\"Width\\\"]=8,\\\
      [\\\"Name\\\"]=\\\"DesktopKeyLabel\\\",\\\
      [\\\"Text\\\"]=\\\"Desktop\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"TextColour\\\"]=128,\\\
    },\\\
    [10]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=35,\\\
      [\\\"Name\\\"]=\\\"OtherKeyView\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"BackgroundColour\\\"]=16,\\\
    },\\\
    [11]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=37,\\\
      [\\\"Width\\\"]=8,\\\
      [\\\"Name\\\"]=\\\"OtherKeyLabel\\\",\\\
      [\\\"Text\\\"]=\\\"Other\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"TextColour\\\"]=128,\\\
    },\\\
    [12]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=44,\\\
      [\\\"Name\\\"]=\\\"FreeKeyView\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"BackgroundColour\\\"]=256,\\\
    },\\\
    [13]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=46,\\\
      [\\\"Width\\\"]=8,\\\
      [\\\"Name\\\"]=\\\"FreeKeyLabel\\\",\\\
      [\\\"Text\\\"]=\\\"Free\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"TextColour\\\"]=128,\\\
    },\\\
  }\\\
}\",\
    [ \"System/Programs/Files.program/Views/filemenu.view\" ] = \"{\\\
  [\\\"Type\\\"]=\\\"Menu\\\",\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Name\\\"]=\\\"OpenMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Open\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Name\\\"]=\\\"ViewProgramContentMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"View Program Content\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Name\\\"]=\\\"OpenWithArgsMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Open With Arguments...\\\"\\\
    },\\\
    [4]={\\\
      [\\\"Name\\\"]=\\\"OpenWithMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Open With...\\\"\\\
    },\\\
    [5]={\\\
      [\\\"Name\\\"]=\\\"Separator\\\",\\\
      [\\\"Type\\\"]=\\\"Separator\\\"\\\
    },\\\
    [6]={\\\
      [\\\"Name\\\"]=\\\"TransmitMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Transmit\\\"\\\
    },\\\
    [7]={\\\
      [\\\"Name\\\"]=\\\"CreatePackageMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Create Package\\\"\\\
    },\\\
    [8]={\\\
      [\\\"Name\\\"]=\\\"Separator\\\",\\\
      [\\\"Type\\\"]=\\\"Separator\\\"\\\
    },\\\
    [9]={\\\
      [\\\"Name\\\"]=\\\"RenameMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Rename...\\\"\\\
    },\\\
    [10]={\\\
      [\\\"Name\\\"]=\\\"DeleteMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Delete...\\\"\\\
    },\\\
    [11]={\\\
      [\\\"Name\\\"]=\\\"AddToDesktopMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Add To Desktop\\\"\\\
    },\\\
    [12]={\\\
      [\\\"Name\\\"]=\\\"Separator\\\",\\\
      [\\\"Type\\\"]=\\\"Separator\\\"\\\
    },\\\
    [13]={\\\
      [\\\"Name\\\"]=\\\"CopyMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Copy\\\"\\\
    },\\\
    [14]={\\\
      [\\\"Name\\\"]=\\\"CutMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Cut\\\"\\\
    },\\\
    [15]={\\\
      [\\\"Name\\\"]=\\\"PasteMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Paste\\\",\\\
      [\\\"Enabled\\\"]=false\\\
    },\\\
    [16]={\\\
      [\\\"Name\\\"]=\\\"Separator\\\",\\\
      [\\\"Type\\\"]=\\\"Separator\\\"\\\
    },\\\
    [17]={\\\
      [\\\"Name\\\"]=\\\"NewFolderMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"New Folder...\\\"\\\
    },\\\
    [18]={\\\
      [\\\"Name\\\"]=\\\"NewFileMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"New File...\\\"\\\
    },\\\
  },\\\
}\",\
    [ \"System/Programs/Files.program/Objects/PeripheralView.lua\" ] = \"Inherit = 'View'\\\
\\\
BackgroundColour = colours.transparent\\\
Side = false\\\
\\\
OnUpdate = function(self, value)\\\
	if value == 'Side' then\\\
		self:RemoveAllObjects()\\\
		if self.Side and #self.Side ~= 0 then\\\
			local p = Peripheral.GetSide(self.Side)\\\
			local path = 'Images/'..p.Type\\\
			if not fs.exists(path) then\\\
				path = 'Images/unknown'\\\
			end\\\
			self:AddObject({\\\
				Type = 'ImageView',\\\
				X = 3,\\\
				Y = 2,\\\
				Width = 5,\\\
				Height = 4,\\\
				Path = path,\\\
				Name = 'PeripheralImageView'\\\
			})\\\
			self:AddObject({\\\
				Type = 'Label',\\\
				X = 10,\\\
				Y = 2,\\\
				Text = p.FormattedType,\\\
				Name = 'NameLabel'\\\
			})\\\
			self:AddObject({\\\
				Type = 'Label',\\\
				X = 10,\\\
				Y = 3,\\\
				Text = self.Bedrock.Helpers.Capitalise(p.Side),\\\
				Name = 'SideLabel',\\\
				TextColour = colours.grey\\\
			})\\\
			local info = Peripheral.GetInfo(p)\\\
\\\
			local btnX = 10\\\
			for i, v in ipairs(info.Buttons) do\\\
				self:AddObject({\\\
					Type = 'Button',\\\
					X = btnX,\\\
					Y = 5,\\\
					Text = v.Text,\\\
					Name = 'InfoButton',\\\
					OnClick = v.OnClick\\\
				})\\\
				btnX = btnX + #v.Text + 3\\\
			end\\\
\\\
\\\
			local x = self.Bedrock.Helpers.LongestString(info, nil, true) + 5\\\
			local y = 7\\\
			for k, v in pairs(info) do\\\
				if k ~= 'Buttons' then\\\
					self:AddObject({\\\
						Type = 'Label',\\\
						X = 3,\\\
						Y = y,\\\
						Text = k,\\\
						Name = 'InfoKeyLabel'..k,\\\
						TextColour = colours.grey\\\
					})\\\
					self:AddObject({\\\
						Type = 'Label',\\\
						X = x,\\\
						Y = y,\\\
						Text = v,\\\
						Name = 'InfoValueLabel'..k,\\\
					})\\\
					y = y + 1\\\
				end\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
\\\
	-- Drawing.DrawCharacters(Current.SidebarWidth+10, 6, Current.Peripheral.Type, colours.black, colours.white)\\\
	-- Drawing.DrawCharacters(Current.SidebarWidth+10, 7, Current.Peripheral.Side, colours.grey, colours.white)\\\
	-- Drawing.DrawImage(Current.SidebarWidth+3, 6, Current.Peripheral.Image, 5, 4)\\\
	-- local y = 11\\\
	-- local x = Helpers.LongestString(Current.Peripheral.Info, nil, true) + 5\\\
	-- for k, v in pairs(Current.Peripheral.Info) do\\\
	-- 	Drawing.DrawCharacters(Current.SidebarWidth+3, y, k, colours.grey, colours.white)\\\
	-- 	Drawing.DrawCharacters(Current.SidebarWidth+x, y, v, colours.black, colours.white)\\\
	-- 	y = y + 1\\\
	-- end\\\
	-- if diskOpenButton then\\\
	-- 	diskOpenButton:Draw()\\\
	-- end\",\
    [ \"System/Programs/Files.program/Images/wireless_modem\" ] = \"8f     \\\
8f((@))\\\
8f((@))\\\
8f     \",\
    [ \"System/Programs/Files.program/.Files.settings\" ] = \"{\\\
  ListMode = false,\\\
  ShowHidden = false,\\\
}\",\
    [ \"System/Programs/Desktop.program/startup\" ] = \"OneOS.LoadAPI('/System/API/Bedrock.lua', false)\\\
--do return end\\\
program = Bedrock:Initialise()\\\
\\\
local files = {}\\\
local offset = 0\\\
local dragRelPos = nil\\\
local currentPage = 1\\\
local totalPages = 1\\\
local dragLock = false\\\
local dragTimer = nil\\\
\\\
local function FilesHaveChanged()\\\
	local list = OneOS.FS.list('Desktop/')\\\
\\\
	local count = 0\\\
	for k, v in pairs(files) do\\\
		count = count + 1\\\
	end\\\
	\\\
	if #list ~= count then\\\
		return true\\\
	else\\\
		for i, v in ipairs(list) do\\\
			if not files[v] then\\\
				return true\\\
			end\\\
		end\\\
	end\\\
	return false\\\
end\\\
\\\
local function MaxIcons()\\\
	local slotHeight = 5\\\
	local slotWidth = 11\\\
	local maxX = math.floor((Drawing.Screen.Width - 2) / slotWidth)\\\
	local maxY = math.floor((Drawing.Screen.Height - 2) / slotHeight)\\\
	local y, x = 2, math.floor(((Drawing.Screen.Width - (maxX * slotWidth))) / 2)\\\
	return x, y, maxX, maxY, maxX * maxY\\\
end\\\
\\\
local function IconLocation(i)\\\
	local slotHeight = 5\\\
	local slotWidth = 11\\\
	local x, y, maxX, maxY, maxPage = MaxIcons()\\\
	local _i = ((i-1) % maxPage) + 1\\\
	local rowPos = ((_i - 1) % maxX)\\\
	local colPos = math.ceil(_i / maxX) - 1\\\
	local page = math.ceil(i/maxPage)\\\
	x = x + (slotWidth * rowPos) + offset + 2 + Drawing.Screen.Width * (page - 1)\\\
	y = y + colPos * slotHeight\\\
	return x, y\\\
end\\\
\\\
local function AddOffset()\\\
	for k, v in pairs(files) do\\\
		v.X = v.BaseX + offset\\\
	end\\\
	program:Draw()\\\
end\\\
\\\
function ReloadIndicators()\\\
	local indicatorWidth = (totalPages * 2) - 2\\\
	local indicatorPos = math.ceil((Drawing.Screen.Width/2)) - totalPages\\\
	program:RemoveObjects('IndicatorButton')\\\
	for i = 1, totalPages do\\\
		local col = colours.grey\\\
		if currentPage == i then\\\
			col = colours.white\\\
		end\\\
		program:AddObject({\\\
			Type = 'Button',\\\
			X = indicatorPos + i * 2,\\\
			Y = Drawing.Screen.Height - 1,\\\
			Text = ' ',\\\
			Width = 1,\\\
			Name = 'IndicatorButton',\\\
			BackgroundColour = col,\\\
			OnClick = function(self)\\\
				GoToPage(i)\\\
			end\\\
		})\\\
	end\\\
end\\\
\\\
function ReloadFiles()\\\
	program:RemoveObjects('FileView')\\\
\\\
	local list = OneOS.FS.list('Desktop/')\\\
	files = {}\\\
	local count = 0\\\
	for i, v in ipairs(list) do\\\
		local x, y = IconLocation(i)\\\
		files[v] = program:AddObject({\\\
			Type = 'FileView',\\\
			X = x,\\\
			BaseX = x,\\\
			Y = y,\\\
			Name = 'FileView',\\\
			Path = 'Desktop/'..v,\\\
			OnClick = FileClick\\\
		})\\\
		count = i\\\
	end\\\
\\\
	local x, y, maxX, maxY, maxPage = MaxIcons()\\\
	totalPages = math.ceil(count/maxPage)\\\
\\\
	ReloadIndicators()\\\
end\\\
\\\
function FileClick(self, event, side, x, y, obj)\\\
	if side == 1 then\\\
		OneOS.Helpers.OpenFile(self.Path)\\\
	elseif side == 2 then\\\
		obj = obj or self\\\
		if obj:ToggleMenu('filemenu', x, y) then\\\
			self.Bedrock:GetObject('OpenMenuItem').OnClick = function(itm)\\\
				OneOS.Helpers.OpenFile(self.Path)\\\
			end\\\
\\\
			self.Bedrock:GetObject('RenameMenuItem').OnClick = function(itm)\\\
				OneOS.Helpers.RenameFile(self.Path, ReloadFiles, self.Bedrock)\\\
			end\\\
\\\
			self.Bedrock:GetObject('DeleteMenuItem').OnClick = function(itm)\\\
				OneOS.Helpers.DeleteFile(self.Path, ReloadFiles, self.Bedrock)\\\
			end\\\
\\\
			self.Bedrock:GetObject('NewFolderMenuItem').OnClick = function(itm)\\\
				OneOS.Helpers.NewFolder(OneOS.Helpers.ParentFolder(self.Path)..'/', ReloadFiles, self.Bedrock)\\\
			end\\\
\\\
			self.Bedrock:GetObject('NewFileMenuItem').OnClick = function(itm)\\\
				OneOS.Helpers.NewFile(OneOS.Helpers.ParentFolder(self.Path)..'/', ReloadFiles, self.Bedrock)\\\
			end\\\
\\\
			self.Bedrock:GetObject('RefreshMenuItem').OnClick = function(itm)\\\
				ReloadFiles()\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
function GoToPage(i)\\\
	if i > 0 and i <= totalPages then\\\
		selectedFile = nil\\\
		local old = currentPage\\\
		currentPage = i\\\
		AnimatePageChange(old, currentPage)\\\
	end\\\
end\\\
\\\
function DragTimeout()\\\
	AnimatePageChange(currentPage, currentPage)\\\
end\\\
\\\
function AnimatePageChange(from, to)\\\
	dragLock = true\\\
	dragRelPos = nil\\\
	local max = -1*Drawing.Screen.Width * (to - 1)\\\
	local relOffset = (offset + Drawing.Screen.Width * (to - 1))\\\
	local direction = -1\\\
	if relOffset < 0 then\\\
		direction = 1\\\
	end\\\
	if OneOS.Settings:GetValues()['UseAnimations'] then\\\
		if relOffset < 0 then\\\
			relOffset = relOffset * -1\\\
		end\\\
		local speed = math.floor(Drawing.Screen.Width / 6)--4--math.ceil(relOffset / Drawing.Screen.Width * 5)\\\
		while ((max < offset) and direction == -1) or ((max > offset) and direction == 1) do\\\
			offset = offset + direction * speed\\\
			relOffset = (offset + Drawing.Screen.Width * (to - 1))\\\
			if speed > relOffset and relOffset > -1*speed then\\\
				offset = max\\\
			end\\\
			AddOffset()			\\\
			sleep(0.05)\\\
		end\\\
	end\\\
	offset = max\\\
	ReloadIndicators()\\\
	AddOffset()\\\
	dragLock = false\\\
end\\\
\\\
local function viewClick(self, event, side, x, y)\\\
	if side == 1 then\\\
		dragRelPos = x\\\
	elseif side == 2 then\\\
		if program.View:ToggleMenu('desktopmenu', x, y) then\\\
			program:GetObject('NewFolderMenuItem').OnClick = function(itm)\\\
				OneOS.Helpers.NewFolder('/Desktop/', ReloadFiles, self.Bedrock)\\\
			end\\\
\\\
			program:GetObject('NewFileMenuItem').OnClick = function(itm)\\\
				OneOS.Helpers.NewFile('/Desktop/', ReloadFiles, self.Bedrock)\\\
			end\\\
\\\
			program:GetObject('RefreshMenuItem').OnClick = function(itm)\\\
				ReloadFiles()\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
local function viewDrag(self, event, side, x, y)\\\
	if dragRelPos then\\\
		offset = (x - dragRelPos) - Drawing.Screen.Width * (currentPage - 1)\\\
		AddOffset()\\\
	end\\\
	if not dragLock then\\\
		program:StopTimer(dragTimer)\\\
		dragTimer = program:StartTimer(DragTimeout, 1)\\\
		local relOffset = (offset + Drawing.Screen.Width * (currentPage - 1))\\\
		if relOffset < 0 and relOffset < -1*Drawing.Screen.Width/4 then\\\
			GoToPage(currentPage + 1)\\\
		elseif relOffset > 0 and relOffset > Drawing.Screen.Width/4 then\\\
			GoToPage(currentPage - 1)\\\
		end\\\
	end\\\
end\\\
\\\
function UpdateBackground()\\\
	local colour = OneOS.Settings:GetValues()['DesktopColour']\\\
	if colour then\\\
		program.View.BackgroundColour = colour\\\
	end\\\
end\\\
\\\
program.OnKeyChar = function(self, event, key)\\\
	if not program:GetActiveObject() then\\\
		if key == keys.right then\\\
			GoToPage(currentPage + 1)\\\
		elseif key == keys.left then\\\
			GoToPage(currentPage - 1)\\\
		end\\\
	end\\\
end\\\
\\\
program:Run(function()\\\
	program:LoadView('main')\\\
	UpdateBackground()\\\
	OneOS.Settings.SetDesktopColourChange(UpdateBackground)\\\
	ReloadFiles()\\\
	-- program:StartRepeatingTimer(function()\\\
	-- 	if FilesHaveChanged() then\\\
	-- 		ReloadFiles()\\\
	-- 		GoToPage(1)\\\
	-- 	end\\\
	-- end, 5)\\\
\\\
	program.View.OnClick = viewClick\\\
	program.View.OnDrag = viewDrag\\\
end)\",\
    [ \"System/Programs/Files.program/images/Modem\" ] = \"8f     \\\
8f f   8 \\\
8f f   8 \\\
8f     \",\
    [ \"System/Programs/Desktop.program/Views/desktopmenu.view\" ] = \"{\\\
  [\\\"Type\\\"]=\\\"Menu\\\",\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Name\\\"]=\\\"NewFolderMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"New Folder...\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Name\\\"]=\\\"NewFileMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"New File...\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Name\\\"]=\\\"Separator\\\",\\\
      [\\\"Type\\\"]=\\\"Separator\\\"\\\
    },\\\
    [4]={\\\
      [\\\"Name\\\"]=\\\"RefreshMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Refresh\\\"\\\
    },\\\
  },\\\
}\",\
    [ \"Desktop/LuaIDE.shortcut\" ] = \"/Programs/LuaIDE.program/\",\
    [ \"Programs/Games/Gold Runner.program/startup\" ] = \"OneOS.LoadAPI('/System/API/Bedrock.lua', false)\\\
\\\
local program = Bedrock:Initialise()\\\
\\\
program:ObjectClick('YesButton', function(self, event, side, x, y)\\\
	OneOS.Run('/Programs/App Store.program/', 'install', 57, 'Games', true)\\\
	OneOS.Close()\\\
end)\\\
\\\
program:ObjectClick('NoButton', function(self, event, side, x, y)\\\
	OneOS.Close()\\\
end)\\\
\\\
program:Run(function()\\\
	program:LoadView('main')\\\
end)\",\
    [ \"System/main.lua\" ] = \"-- Bedrock.Helpers = Helpers\\\
local bedrock = Bedrock:Initialise('/System')\\\
bedrock.ViewPath ='/System/Views/'\\\
-- _G.Helpers = Helpers\\\
-- error(Helpers.IconForFile)\\\
bedrock.AllowTerminate = false\\\
\\\
if type(term.native) == 'function' then\\\
	local cur = term.current()\\\
	restoreTerm = function()term.redirect(cur)end\\\
else\\\
	restoreTerm = function()term.restore()end\\\
end\\\
\\\
Current = {\\\
	ProgramView = nil,\\\
	Overlay = nil,\\\
	Programs = {},\\\
	Program = nil,\\\
	Desktop = nil,\\\
	Bedrock = bedrock,\\\
	SearchActive = true\\\
}\\\
\\\
function UpdateOverlay()\\\
	bedrock:GetObject('Overlay'):UpdateButtons()\\\
end\\\
\\\
bedrock.OnKeyChar = function(self, event, keychar)\\\
	if isDebug and keychar == '\\\\\\\\' then\\\
		--Restart()\\\
		AnimateShutdown(true)\\\
	end\\\
end\\\
\\\
bedrock.OnTimer = function(self, event, timer)\\\
	for i, program in ipairs(Current.Programs) do\\\
		for i2, _timer in ipairs(program.Timers) do\\\
			if _timer == timer then\\\
				program:QueueEvent('timer', timer)\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
bedrock:RegisterEvent('modem_message', function(self, event, side, channel, replyChannel, message, distance)\\\
	if pocket and channel == Wireless.Channels.UltimateDoorlockPing then\\\
		message = textutils.unserialize(message)\\\
		if message then\\\
			message.content = textutils.unserialize(message.content)\\\
			if message.content then\\\
				Wireless.SendMessage(Wireless.Channels.UltimateDoorlockRequest, fingerprint, Wireless.Channels.UltimateDoorlockRequestReply, nil, message.senderID)\\\
				return true\\\
			end\\\
		end\\\
	end\\\
	Current.Program:QueueEvent(event, side, channel, replyChannel, message, distance)\\\
end)\\\
\\\
bedrock.EventHandler = function(self)\\\
	for i, program in ipairs(Current.Programs) do\\\
		for i, event in ipairs(program.EventQueue) do\\\
			program:Resume(unpack(event))\\\
		end\\\
		program.EventQueue = {}\\\
	end\\\
	local event = { os.pullEventRaw() }\\\
\\\
	local s = 'Event: '\\\
	for i, v in ipairs(event) do\\\
		s = s..tostring(v)..', '\\\
	end\\\
	Log.i(s)\\\
\\\
	if self.EventHandlers[event[1]] then\\\
		for i, e in ipairs(self.EventHandlers[event[1]]) do\\\
			e(self, unpack(event))\\\
		end\\\
	elseif Current.Program then\\\
		Current.Program:QueueEvent(unpack(event))\\\
	end\\\
end\\\
\\\
function Shutdown(force, restart, animate)\\\
	Log.i(bedrock.View.Name)\\\
	if bedrock.View.Name == 'firstsetup' then\\\
		os.reboot()\\\
	end\\\
	Log.i('Trying to shutdown/restart. Restart: '..tostring(restart))\\\
	local success = true\\\
	if not force then\\\
		for i, program in ipairs(Current.Programs) do\\\
			if not program.Hidden and not program:Close() then\\\
				success = false\\\
			end\\\
		end\\\
	end\\\
\\\
	if success then\\\
		AnimateShutdown(restart, animate)\\\
	else\\\
		Log.w('Shutdown/restart aborted')\\\
		Current.Desktop:SwitchTo()\\\
		local shutdownLabel = (restart and 'restart' or 'shutdown')\\\
		local shutdownLabelCaptital = (restart and 'Restart' or 'Shutdown')\\\
\\\
		bedrock:DisplayAlertWindow(\\\"Programs Still Open\\\", \\\"You have unsaved work. Save your work and close the program or click 'Force \\\"..shutdownLabelCaptital..\\\"'.\\\", {'Force '..shutdownLabelCaptital, 'Cancel'}, function(value)\\\
			if value ~= 'Cancel' then\\\
				AnimateShutdown(restart, animate)\\\
			end\\\
		end)\\\
	end\\\
end\\\
\\\
function AnimateShutdown(restart, animate)\\\
	Log.w('System safely stopping.')\\\
	if Settings:GetValues()['UseAnimations'] and animate then\\\
		Log.i('Animating')\\\
		Drawing.Clear(colours.white)\\\
		Drawing.DrawBuffer()\\\
		sleep(0)\\\
		local x = 0\\\
		local y = 0\\\
		local w = 0\\\
		local h = 0\\\
		for i = 1, 8 do\\\
			local percent = (i * 0.05)\\\
			Drawing.Clear(colours.black)\\\
			x = Drawing.Screen.Width * (i * 0.01)\\\
			y = math.floor(Drawing.Screen.Height * (i * 0.05)) + 3\\\
			w = Drawing.Screen.Width - (2 * x) + 1\\\
			h = Drawing.Screen.Height - (2 * y) + 1\\\
\\\
			if h < 1 then\\\
				h = 1\\\
			end\\\
\\\
			Drawing.DrawBlankArea(x + 1, y, w, h, colours.white)\\\
			Drawing.DrawBuffer()\\\
			sleep(0)\\\
		end\\\
\\\
		Drawing.DrawBlankArea(x + 1, y, w, h, colours.lightGrey)\\\
		Drawing.DrawBuffer()\\\
		sleep(0)\\\
\\\
		Drawing.DrawBlankArea(x + 1, y, w, h, colours.grey)\\\
		Drawing.DrawBuffer()\\\
		sleep(0)\\\
		Log.i('Done animation')\\\
	end\\\
\\\
	term.setBackgroundColour(colours.black)\\\
	term.clear()\\\
	if restart then\\\
		sleep(0.2)\\\
		Log.i('Rebooting now.')\\\
		os.reboot()\\\
	else\\\
		Log.i('Shutting down now.')\\\
		os.shutdown()\\\
	end\\\
end\\\
\\\
function Restart(force, animate)\\\
	Shutdown(force, true, animate)\\\
end\\\
\\\
function StartDoorWireless()\\\
	if pocket and Wireless.Present() then\\\
		Wireless.Open(Wireless.Channels.UltimateDoorlockPing)\\\
		Wireless.Open(Wireless.Channels.UltimateDoorlockRequest)\\\
		if fs.exists('/System/.fingerprint') then\\\
			local h = fs.open('/System/.fingerprint', 'r')\\\
			if h then\\\
				fingerprint = h.readAll()\\\
				h.close()\\\
			end\\\
		else\\\
			local function GenerateFingerprint()\\\
			    local str = \\\"\\\"\\\
			    for _ = 1, 256 do\\\
			        local char = math.random(32, 126)\\\
			        str = str .. string.char(char)\\\
			    end\\\
			    return str\\\
			end\\\
			fingerprint = GenerateFingerprint()\\\
			local h = fs.open('/System/.fingerprint', 'w')\\\
			if h then\\\
				h.write(fingerprint)\\\
				h.close()\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
local checkAutoUpdateArg = nil\\\
\\\
function CheckAutoUpdate(arg)\\\
	Log.i('Checking for updates...')\\\
	checkAutoUpdateArg = arg\\\
	if http then\\\
		if checkAutoUpdateArg then\\\
			bedrock:DisplayAlertWindow(\\\"Update OneOS\\\", \\\"Checking for updates, this may take a moment.\\\", {'Ok'})\\\
		end\\\
		http.request('https://api.github.com/repos/oeed/OneOS/releases#')\\\
	elseif arg then\\\
		Log.e('Update failed. HTTP is not enabled.')\\\
		bedrock:DisplayAlertWindow(\\\"HTTP Not Enabled!\\\", \\\"Turn on the HTTP API to update.\\\", {'Ok'})\\\
	else\\\
		Log.e('Update failed. HTTP is not enabled.')\\\
	end\\\
end\\\
\\\
function split(str, sep)\\\
        local sep, fields = sep or \\\":\\\", {}\\\
        local pattern = string.format(\\\"([^%s]+)\\\", sep)\\\
        str:gsub(pattern, function(c) fields[#fields+1] = c end)\\\
        return fields\\\
end\\\
\\\
function GetSematicVersion(tag)\\\
	tag = tag:sub(2)\\\
	return split(tag, '.')\\\
end\\\
\\\
--Returns true if the FIRST version is NEWER\\\
function SematicVersionIsNewer(version, otherVersion)\\\
	if version[1] > otherVersion[1] then\\\
		return true\\\
	elseif version[2] > otherVersion[2] then\\\
		return true\\\
	elseif version[3] > otherVersion[3] then\\\
		return true\\\
	end\\\
	return false\\\
end\\\
\\\
function AutoUpdateFail(self, event, url, data)\\\
	if url == 'https://api.github.com/repos/oeed/OneOS/releases#' then\\\
		Log.w('Auto update failed. (http_failure)')\\\
		if checkAutoUpdateArg then\\\
			if bedrock.Window then\\\
				bedrock.Window:Close()\\\
			end\\\
			bedrock:DisplayAlertWindow(\\\"Update Check Failed\\\", \\\"Check your connection and try again.\\\", {'Ok'})\\\
		end\\\
	else\\\
		Current.Program:QueueEvent(event, url, data)\\\
	end\\\
end\\\
\\\
function AutoUpdateResponse(self, event, url, data)\\\
	if url == 'https://api.github.com/repos/oeed/OneOS/releases#' then\\\
		os.loadAPI('/System/JSON')\\\
		if not data then\\\
			Log.w('Auto update failed. (no)')\\\
			return\\\
		end\\\
		local releases = JSON.decode(data.readAll())\\\
		os.unloadAPI('JSON')\\\
		if not releases or not releases[1] or not releases[1].tag_name then\\\
			Log.w('Auto update failed. (misformatted)')\\\
			if checkAutoUpdateArg then\\\
				if bedrock.Window then\\\
					bedrock.Window:Close()\\\
				end\\\
				bedrock:DisplayAlertWindow(\\\"Update Check Failed\\\", \\\"Check your connection and try again.\\\", {'Ok'})\\\
			end\\\
			return\\\
		end\\\
		local latestReleaseTag = releases[1].tag_name\\\
\\\
		if not Settings:GetValues()['DownloadPrereleases'] then\\\
			Log.i('Not downloading prereleases')\\\
			for i, v in ipairs(releases) do\\\
				if not v.prerelease then\\\
					latestReleaseTag = v.tag_name\\\
					break\\\
				end\\\
			end\\\
		end\\\
		Log.i('Latest tag: '..latestReleaseTag)\\\
\\\
		local h = fs.open('/System/.version', 'r')\\\
		local version = h.readAll()\\\
		h.close()\\\
\\\
		if version == latestReleaseTag then\\\
			--using latest version\\\
			Log.i('OneOS is up to date.')\\\
			if checkAutoUpdateArg then\\\
				if bedrock.Window then\\\
					bedrock.Window:Close()\\\
				end\\\
				bedrock:DisplayAlertWindow(\\\"Up to date!\\\", \\\"OneOS is up to date!\\\", {'Ok'})\\\
			end\\\
			return\\\
		elseif SematicVersionIsNewer(GetSematicVersion(latestReleaseTag), GetSematicVersion(version)) then\\\
			Log.i('New version of OneOS available. (from '..version..' to '..latestReleaseTag..')')\\\
			if bedrock.Window then\\\
				bedrock.Window:Close()\\\
			end\\\
			bedrock:DisplayAlertWindow(\\\"Update OneOS\\\", \\\"There is a new version of OneOS available, do you want to update?\\\", {'Yes', 'No'}, function(value)\\\
				if value == 'Yes' then\\\
					Helpers.OpenFile('System/Programs/Update OneOS.program')\\\
				end\\\
			end)\\\
		else\\\
			Log.i('OneOS is neither up to date or behind. (.version probably edited)')\\\
		end\\\
	else\\\
		Current.Program:QueueEvent(event, url, data)\\\
	end\\\
end\\\
\\\
bedrock:RegisterEvent('http_success', AutoUpdateResponse)\\\
bedrock:RegisterEvent('http_failure', AutoUpdateFail)\\\
\\\
function FirstSetup()\\\
	bedrock:Run(function()\\\
		Log.i('Reached First Setup GUI')\\\
		bedrock:LoadView('firstsetup', false)\\\
		Log.i('First Setup GUI Loaded')\\\
\\\
		Current.ProgramView = bedrock:GetObject('ProgramView')\\\
		Helpers.OpenFile('System/Programs/First Setup.program', {isHidden = true})\\\
	end)\\\
end\\\
\\\
function Initialise()\\\
	bedrock:Run(function()\\\
		Log.i('Reached GUI')\\\
		bedrock:LoadView('main', false)\\\
		Log.i('GUI Loaded')\\\
\\\
		Current.ProgramView = bedrock:GetObject('ProgramView')\\\
		Current.LoginView = bedrock:GetObject('LoginView')\\\
		Current.Overlay = bedrock:GetObject('Overlay')\\\
		Indexer.RefreshIndex()\\\
\\\
		bedrock:GetObject('ClickCatcherView').OnClick = function()\\\
			if Current.SearchActive then\\\
				Search.Close()\\\
			end\\\
		end\\\
\\\
		Current.Desktop = Helpers.OpenFile('System/Programs/Desktop.program', {isHidden = true})\\\
\\\
		Current.LoginView.OnUnlock = function(self, sleepMode)\\\
			if not sleepMode then\\\
				if Settings:GetValues()['StartupProgram'] then\\\
					Helpers.OpenFile('Programs/'..Settings:GetValues()['StartupProgram'])\\\
					UpdateOverlay()\\\
				end\\\
				UpdateOverlay()\\\
				StartDoorWireless()\\\
				CheckAutoUpdate()\\\
			end\\\
		end\\\
		Current.LoginView:Lock()\\\
	end)\\\
end\",\
    [ \"System/Programs/Files.program/Views/nofilemenu.view\" ] = \"{\\\
  [\\\"Type\\\"]=\\\"Menu\\\",\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Name\\\"]=\\\"PasteMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Paste\\\",\\\
      [\\\"Enabled\\\"]=false\\\
    },\\\
    [2]={\\\
      [\\\"Name\\\"]=\\\"Separator\\\",\\\
      [\\\"Type\\\"]=\\\"Separator\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Name\\\"]=\\\"NewFolderMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"New Folder...\\\"\\\
    },\\\
    [4]={\\\
      [\\\"Name\\\"]=\\\"NewFileMenuItem\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"New File...\\\"\\\
    },\\\
  },\\\
}\",\
    [ \"System/Programs/About OneOS.program/Views/main.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=2,\\\
      [\\\"Width\\\"]=6,\\\
      [\\\"Height\\\"]=4,\\\
      [\\\"Name\\\"]=\\\"LogoImageView\\\",\\\
      [\\\"Type\\\"]=\\\"ImageView\\\",\\\
      [\\\"Path\\\"]=\\\"logo\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=10,\\\
      [\\\"Width\\\"]=13,\\\
      [\\\"Name\\\"]=\\\"VersionLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"OneOS (Unknown Version)\\\",\\\
      [\\\"TextColour\\\"]=128,\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=3,\\\
      [\\\"X\\\"]=10,\\\
      [\\\"Width\\\"]=32,\\\
      [\\\"Name\\\"]=\\\"CopyrightLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"(c) Oliver 'oeed' Cooper 2013-14\\\",\\\
      [\\\"TextColour\\\"]=256,\\\
    },\\\
    [4]={\\\
      [\\\"Y\\\"]=4,\\\
      [\\\"X\\\"]=10,\\\
      [\\\"Width\\\"]=29,\\\
      [\\\"Name\\\"]=\\\"LicenseLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Under CC BY-NC-ND 4.0 License\\\",\\\
      [\\\"TextColour\\\"]=256,\\\
    },\\\
    [5]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=10,\\\
      [\\\"Width\\\"]=40,\\\
      [\\\"Name\\\"]=\\\"LicenseInfoLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Read the forum post for license details.\\\",\\\
      [\\\"TextColour\\\"]=256,\\\
    },\\\
    [6]={\\\
      [\\\"Y\\\"]=7,\\\
      [\\\"X\\\"]=2,\\\
      [\\\"Width\\\"]=\\\"100%,-2\\\",\\\
      [\\\"Height\\\"]=\\\"100%,-13\\\",\\\
      [\\\"Name\\\"]=\\\"ThanksLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Thanks to GravityScore, NitrogenFingers, Symmetryc, superaxander, Jesusthekiller, RamiLego4Game and Vilsol for their programs or help. Most of all, thank you using OneOS!\\\",\\\
      [\\\"TextColour\\\"]=128,\\\
    },\\\
    [7]={\\\
      [\\\"Y\\\"]=\\\"100%,-5\\\",\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"StorageView\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"InheritView\\\"]=\\\"storage\\\"\\\
    },\\\
  },\\\
  [\\\"BackgroundColour\\\"]=1\\\
}\",\
    [ \"System/Objects/SearchView.lua\" ] = \"Inherit = 'View'\\\
\\\
BackgroundColour = colours.grey\\\
\\\
OnLoad = function(self)\\\
	local searchBox = self:AddObject({\\\
		[\\\"X\\\"]=2,\\\
		[\\\"Y\\\"]=2,\\\
		[\\\"Width\\\"]=\\\"100%,-2\\\",\\\
		[\\\"Type\\\"]=\\\"TextBox\\\",\\\
		[\\\"Name\\\"]=\\\"SearchTextBox\\\",\\\
		[\\\"Placeholder\\\"]=\\\"Search...\\\",\\\
	})\\\
\\\
	self:AddObject({\\\
		[\\\"X\\\"]=1,\\\
		[\\\"Y\\\"]=4,\\\
		[\\\"Width\\\"]=\\\"100%\\\",\\\
		[\\\"Height\\\"]=\\\"100%,-3\\\",\\\
		[\\\"BackgroundColour\\\"]=0,\\\
		[\\\"Type\\\"]=\\\"ListView\\\",\\\
		[\\\"Name\\\"]=\\\"SearchListView\\\",\\\
		[\\\"TextColour\\\"]=colours.white,\\\
		[\\\"HeadingMargin\\\"]=1,\\\
		[\\\"CanSelect\\\"]=true\\\
	})\\\
\\\
	searchBox.OnChange = function(box, event, keychar)\\\
		if keychar == keys.up or keychar == keys.down or keychar == keys.enter then\\\
			self:GetObject('SearchListView'):OnKeyChar('key', keychar)\\\
		else\\\
			self:UpdateSearch()\\\
		end\\\
	end\\\
end\\\
\\\
local function safePairs( _t )\\\
  local tKeys = {}\\\
  for key in pairs(_t) do\\\
    table.insert(tKeys, key)\\\
  end\\\
  local currentIndex = 0\\\
  return function()\\\
    currentIndex = currentIndex + 1\\\
    local key = tKeys[currentIndex]\\\
    return key, _t[key]\\\
  end\\\
end\\\
\\\
function ItemClick(self, event, side, x, y)\\\
	if side == 1 then\\\
		Search.Close()\\\
		Helpers.OpenFile(self.Path)\\\
	elseif self:ToggleMenu('searchmenu', x, y) then\\\
		self.Bedrock:GetObject('OpenMenuItem').OnClick = function()Search.Close() Helpers.OpenFile(self.Path)end\\\
		self.Bedrock:GetObject('ShowInFilesMenuItem').OnClick = function()Search.Close() Helpers.OpenFile('/System/Programs/Files.program', {self.Path, true})end\\\
	end\\\
end\\\
\\\
function UpdateSearch(self)\\\
	local searchItems = {\\\
		Folders = {},\\\
		Documents = {},\\\
		Images = {},\\\
		Programs = {},\\\
		['System Files'] = {},\\\
		Other = {}\\\
	}\\\
	local paths = Indexer.Search(self:GetObject('SearchTextBox').Text)\\\
	local foundSelected = false\\\
	local selected = nil\\\
	if self:GetObject('SearchListView').Selected then\\\
		selected = self:GetObject('SearchListView').Selected.Path\\\
	end\\\
\\\
	for i, path in ipairs(paths) do\\\
		local extension = self.Bedrock.Helpers.Extension(path):lower()\\\
		if extension ~= 'shortcut' then\\\
			path = self.Bedrock.Helpers.TidyPath(path)\\\
			local fileType = 'Other'\\\
			if extension == 'txt' or extension == 'text' or extension == 'license' or extension == 'md' then\\\
				fileType = 'Documents'\\\
			elseif extension == 'nft' or extension == 'nfp' or extension == 'skch' then\\\
				fileType = 'Images'\\\
			elseif extension == 'program' then\\\
				fileType = 'Programs'\\\
			elseif extension == 'lua' or extension == 'log' or extension == 'settings' or extension == 'version' or extension == 'hash' or extension == 'fingerprint' then\\\
				fileType = 'System Files'\\\
			elseif fs.isDir(path) then\\\
				fileType = 'Folders'\\\
			end\\\
			if path == selected then\\\
				Log.i('found')\\\
				foundSelected = true\\\
			end\\\
			table.insert(searchItems[fileType], {Path = path, Text = self.Bedrock.Helpers.RemoveExtension(fs.getName(path)), Selected = (path == selected), OnClick = ItemClick})\\\
		end\\\
	end\\\
\\\
	for k, v in safePairs(searchItems) do\\\
		if #v == 0 then\\\
			searchItems[k] = nil\\\
		end\\\
	end\\\
\\\
	self:GetObject('SearchListView').Items = searchItems\\\
	self:GetObject('SearchListView'):UpdateItems()\\\
	if not foundSelected then\\\
		local first = self:GetObject('SearchListView'):GetNth(1)\\\
		Log.i(first)\\\
		if first then\\\
			self:GetObject('SearchListView'):SelectItem(first)\\\
		end\\\
	end\\\
	\\\
	--ListScrollBar.Scroll = 0\\\
\\\
	--Draw()\\\
end\",\
    [ \"System/Programs/Files.program/startup\" ] = \"tArgs = {...}\\\
\\\
OneOS.LoadAPI('/System/API/Bedrock.lua', false)\\\
OneOS.LoadAPI('/System/API/Peripheral.lua')\\\
\\\
local program = Bedrock:Initialise()\\\
\\\
Current = {\\\
	History = {},\\\
	HistoryItem = 0,\\\
	FileList = {},\\\
	Path = tArgs[1] or '/Desktop/'\\\
}\\\
\\\
Settings = {\\\
	ShowHidden = false,\\\
	ListMode = false,\\\
}\\\
\\\
function WriteSettings()\\\
	local h = fs.open('.Files.settings', 'w')\\\
	h.write(textutils.serialize(Settings))\\\
	h.close()\\\
end\\\
\\\
function ReadSettings()\\\
	local h = fs.open('.Files.settings', 'r')\\\
	if h then\\\
		Settings = textutils.unserialize(h.readAll())\\\
		h.close()\\\
	else\\\
		WriteSettings()\\\
	end\\\
end\\\
\\\
function OptionsButtonClick(self, event, side, x, y)\\\
	if self:ToggleMenu('optionsmenu') then\\\
		if Settings.ListMode then\\\
			program:GetObject('ViewModeMenuItem').Text = 'Icon View'\\\
		end\\\
\\\
		if Settings.ShowHidden then\\\
			program:GetObject('HiddenFilesMenuItem').Text = 'Hide Hidden Files'\\\
		end\\\
\\\
		program:GetObject('ViewModeMenuItem').Click = function()\\\
			Settings.ListMode = not Settings.ListMode\\\
			RefreshFiles()\\\
			WriteSettings()\\\
		end\\\
\\\
		program:GetObject('HiddenFilesMenuItem').Click = function()\\\
			Settings.ShowHidden = not Settings.ShowHidden\\\
			RefreshFiles()\\\
			WriteSettings()\\\
		end\\\
	end\\\
end\\\
\\\
function SidebarClick(self, item, event, side, x, y)\\\
	term.setTextColour(colours.black)\\\
	GoToPath(item.Path)	\\\
end\\\
\\\
function FileClick(item, event, side, x, y)\\\
	if side == 1 then\\\
		if OneOS.Helpers.IsDirectory(item.Path) then\\\
			GoToPath(item.Path)\\\
		else\\\
			OneOS.Helpers.OpenFile(item.Path)\\\
			program:StartTimer(RefreshFiles, 1)\\\
		end\\\
	elseif side == 2 then\\\
		if item:ToggleMenu('filemenu', x, y) then\\\
			program:GetObject('OpenMenuItem').OnClick = function(_item)\\\
				FileClick(item, event, 1, x, y)\\\
			end\\\
\\\
			program:GetObject('ViewProgramContentMenuItem').OnClick = function(_item)\\\
				GoToPath(item.Path)\\\
			end\\\
\\\
			program:GetObject('OpenWithArgsMenuItem').OnClick = function(_item)\\\
				program:DisplayTextBoxWindow(\\\"Program Arguments\\\", 'Enter the arguments for the program separated by a space.', function(success, value)\\\
					if success and #value ~= 0 then\\\
						local tWords = {}\\\
						for match in string.gmatch( value, \\\"[^ \\\\t]+\\\" ) do\\\
							table.insert( tWords, match )\\\
						end\\\
						OneOS.Run(item.Path, unpack(tWords))\\\
					end\\\
				end)\\\
			end\\\
\\\
			program:GetObject('OpenWithMenuItem').OnClick = function(_item)\\\
				OneOS.Helpers.OpenFileWith(item.Path, program)\\\
			end\\\
\\\
			program:GetObject('TransmitMenuItem').OnClick = function(_item)\\\
				OneOS.Run('/Programs/Transmit.program/', item.Path)\\\
			end\\\
\\\
			program:GetObject('CreatePackageMenuItem').OnClick = function(_item)\\\
				local packrun = loadfile('pkgmake')\\\
				local env = getfenv()\\\
				setfenv( packrun, env)\\\
				local path = item.Path:sub(1,#item.Path-1)\\\
				packrun(item.Path, OneOS.Helpers.RemoveFileName(path)..OneOS.Helpers.RemoveExtension(OneOS.FS.getName(path))..'.pkg')\\\
				RefreshFiles()\\\
			end\\\
\\\
			program:GetObject('RenameMenuItem').OnClick = function(_item)\\\
				OneOS.Helpers.RenameFile(item.Path, RefreshFiles, program)\\\
			end\\\
\\\
			program:GetObject('DeleteMenuItem').OnClick = function(_item)\\\
				OneOS.Helpers.DeleteFile(item.Path, RefreshFiles, program)\\\
			end\\\
\\\
			program:GetObject('AddToDesktopMenuItem').OnClick = function(_item)\\\
				OneOS.Helpers.MakeShortcut(item.Path)\\\
			end\\\
\\\
			program:GetObject('CopyMenuItem').OnClick = function(_item)\\\
				OneOS.Clipboard.Copy(item.Path, 'filepath')\\\
			end\\\
\\\
			program:GetObject('CutMenuItem').OnClick = function(_item)\\\
				OneOS.Clipboard.Cut(item.Path, 'filepath')\\\
			end\\\
\\\
			if OneOS.Clipboard.Content and OneOS.Clipboard.Type == 'filepath' then\\\
				program:GetObject('PasteMenuItem').Enabled = true\\\
				program:GetObject('PasteMenuItem').OnClick = function(btn, event, side, x, y)\\\
					PasteFile()\\\
				end\\\
			end\\\
\\\
			program:GetObject('NewFolderMenuItem').OnClick = function(_item)\\\
				OneOS.Helpers.NewFolder(OneOS.Helpers.ParentFolder(item.Path)..'/', RefreshFiles, program)\\\
			end\\\
\\\
			program:GetObject('NewFileMenuItem').OnClick = function(_item)\\\
				OneOS.Helpers.NewFile(OneOS.Helpers.ParentFolder(item.Path)..'/', RefreshFiles, program)\\\
			end\\\
			\\\
			if OneOS.FS.isDir(item.Path) then\\\
				program:RemoveObject('TransmitMenuItem')\\\
			else\\\
				program:RemoveObject('CreatePackageMenuItem')\\\
			end\\\
\\\
			if not OneOS.Helpers.Extension(item.Path) == 'program' or not OneOS.FS.isDir(item.Path) then\\\
				program:RemoveObject('ViewProgramContentMenuItem')\\\
				program:RemoveObject('OpenWithArgsMenuItem')\\\
			else\\\
				program:RemoveObject('OpenWithMenuItem')\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
function NoFileClick(self, event, side, x, y)\\\
	if self:ToggleMenu('nofilemenu', x, y) then\\\
		if OneOS.Clipboard.Content and OneOS.Clipboard.Type == 'filepath' then\\\
			program:GetObject('PasteMenuItem').Enabled = true\\\
			program:GetObject('PasteMenuItem').OnClick = function(btn, event, side, x, y)\\\
				PasteFile()\\\
			end\\\
		end\\\
\\\
		program:GetObject('NewFolderMenuItem').OnClick = function(_item)\\\
			OneOS.Helpers.NewFolder(Current.Path, RefreshFiles, program)\\\
		end\\\
\\\
		program:GetObject('NewFileMenuItem').OnClick = function(_item)\\\
			OneOS.Helpers.NewFile(Current.Path, RefreshFiles, program)\\\
		end\\\
			\\\
	end\\\
end\\\
\\\
function PasteFile()				\\\
	local destName = OneOS.FS.getName(OneOS.Clipboard.Content)\\\
	local copyNumber = 1\\\
	while OneOS.FS.exists(Current.Path..'/'..destName) do\\\
		destName = program.Helpers.RemoveExtension(OneOS.FS.getName(OneOS.Clipboard.Content)).. ' ' .. copyNumber .. program.Helpers.Extension(OneOS.FS.getName(OneOS.Clipboard.Content), true)\\\
		copyNumber = copyNumber + 1\\\
	end\\\
	local destPath = program.Helpers.TidyPath(Current.Path..'/'..destName)\\\
\\\
	if not OneOS.Clipboard.IsCut then\\\
		OneOS.FS.copy(OneOS.Clipboard.Content, destPath)\\\
		RefreshFiles()\\\
	elseif OneOS.Clipboard.IsCut then\\\
		local content = OneOS.Clipboard.Paste()\\\
		OneOS.FS.move(content, destPath)\\\
		RefreshFiles()\\\
	end\\\
end\\\
\\\
function RefreshFiles()\\\
	diskOpenButton = nil\\\
	if Current.Path:sub(1,12) == '/Peripheral/' and peripheral.isPresent(Current.Path:sub(13)) then\\\
		program:GetObject('FilesPeripheralView').Side = nil\\\
		program:GetObject('FilesPeripheralView').Side = Current.Path:sub(13)\\\
		program:GetObject('FilesPeripheralView').Visible = true\\\
		program:GetObject('FilesListView').Visible = false\\\
		program:GetObject('FilesCollectionView').Visible = false\\\
	else\\\
		if Current.Path:sub(1,12) == '/Peripheral/' then\\\
			GoToPath('/Desktop/')\\\
			return\\\
		end\\\
		if Settings.ListMode then\\\
			program:GetObject('FilesListView').Items = {}\\\
			program:GetObject('FilesListView').Visible = true\\\
			program:GetObject('FilesCollectionView').Visible = false\\\
			program:GetObject('FilesPeripheralView').Visible = false\\\
		else\\\
			program:GetObject('FilesCollectionView').Items = {}\\\
			program:GetObject('FilesCollectionView').Visible = true\\\
			program:GetObject('FilesListView').Visible = false\\\
			program:GetObject('FilesPeripheralView').Visible = false\\\
		end\\\
\\\
		for i, v in ipairs(OneOS.FS.list(Current.Path)) do\\\
			if Settings.ShowHidden or string.sub( v, 1, 1 ) ~= '.' then\\\
				local path = OneOS.Helpers.TidyPath(Current.Path .. '/' .. v)\\\
				if path == '/rom/' then\\\
					break\\\
				end\\\
\\\
				if Settings.ListMode then\\\
					table.insert(program:GetObject('FilesListView').Items, {[\\\"Text\\\"] = OneOS.FS.getName(path), [\\\"Path\\\"] = path, [\\\"TextColour\\\"] = OneOS.Helpers.IsDirectory(path) and colours.grey or colours.black, OnClick = FileClick})\\\
				else\\\
					table.insert(program:GetObject('FilesCollectionView').Items, {[\\\"Type\\\"] = 'FileView', [\\\"Path\\\"] = path, OnClick = FileClick, [\\\"Height\\\"]=FileView.Height, [\\\"Width\\\"]=FileView.Width})\\\
				end\\\
			end\\\
		end\\\
	end\\\
	--Current.SidebarList.Peripherals = Peripheral.GetPeripherals()\\\
end\\\
\\\
function RefreshPeripherals(self, event)\\\
	local items = {}\\\
	for i, p in ipairs(Peripheral.GetPeripherals()) do\\\
        table.insert(items, {[\\\"Text\\\"] = p.Name, [\\\"Path\\\"] = '/Peripheral/'..p.Side})\\\
	end\\\
	program:GetObject('Sidebar').Items.Peripherals = items\\\
	program:GetObject('Sidebar'):UpdateItems()\\\
	RefreshFiles()\\\
end\\\
\\\
function GoToPath(path, history)\\\
	history = history or false\\\
	local path = OneOS.Helpers.TidyPath(path)\\\
	program:GetObject('PathLabel').Text = path\\\
	if not history then\\\
		for i, v in ipairs(Current.History) do\\\
			if i >= Current.HistoryItem then\\\
				Current.History[i] = nil\\\
 			end\\\
		end\\\
		table.insert(Current.History, Current.Path)\\\
		Current.HistoryItem = #Current.History + 1\\\
	end\\\
	Current.FileScroll = 0\\\
	Current.Path = path\\\
	if Current.History[Current.HistoryItem-1] then\\\
		program:GetObject('BackButton').Enabled = true\\\
	else\\\
		program:GetObject('BackButton').Enabled = false\\\
	end\\\
\\\
	if Current.History[Current.HistoryItem+1] then\\\
		program:GetObject('ForwardButton').Enabled = true\\\
	else\\\
		program:GetObject('ForwardButton').Enabled = false\\\
	end\\\
	RefreshFiles()\\\
end\\\
\\\
program:RegisterEvent('disk', RefreshPeripherals)\\\
program:RegisterEvent('disk_eject', RefreshPeripherals)\\\
program:RegisterEvent('peripheral', RefreshPeripherals)\\\
program:RegisterEvent('peripheral_detach', RefreshPeripherals)\\\
\\\
program:Run(function()\\\
	program:LoadView('main')\\\
	ReadSettings()\\\
	GoToPath(Current.Path, true)\\\
	program:GetObject('OptionsButton').OnClick = OptionsButtonClick\\\
	program:GetObject('Sidebar').OnChildClick = SidebarClick\\\
\\\
	program:GetObject('FilesListView').OnClick = NoFileClick\\\
	program:GetObject('FilesCollectionView').OnClick = NoFileClick\\\
\\\
	program:GetObject('BackButton').OnClick = function(self)\\\
		if Current.History[Current.HistoryItem-1] then\\\
			table.insert(Current.History, Current.Path)\\\
			Current.HistoryItem = Current.HistoryItem - 1\\\
			GoToPath(Current.History[Current.HistoryItem], true)\\\
		end\\\
	end\\\
\\\
	program:GetObject('GoUpButton').OnClick = function(self)\\\
		if Current.Path:sub(1,12) ~= '/Peripheral/' then\\\
			GoToPath(OneOS.Helpers.ParentFolder(Current.Path))\\\
		end\\\
	end\\\
\\\
	program:GetObject('ForwardButton').OnClick = function(self)\\\
		if Current.History[Current.HistoryItem+1] then\\\
			Current.HistoryItem = Current.HistoryItem + 1\\\
			GoToPath(Current.History[Current.HistoryItem], true)\\\
		end\\\
	end\\\
\\\
	RefreshPeripherals()\\\
end)\\\
\",\
    [ \"Programs/Games/Gold Runner.program/Views/toolbar.view\" ] = \"{\\\
  [\\\"Width\\\"]=\\\"100%\\\",\\\
  [\\\"Height\\\"]=3,\\\
  [\\\"Type\\\"]=\\\"View\\\",\\\
  [\\\"BackgroundColour\\\"] = 128,\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=2,\\\
      [\\\"Name\\\"]=\\\"InstallLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Install\\\",\\\
      [\\\"TextColour\\\"]=1\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=10,\\\
      [\\\"Name\\\"]=\\\"ProgramNameLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Gold Runner\\\",\\\
      [\\\"TextColour\\\"]=256\\\
    },\\\
  },\\\
}\",\
    [ \"Programs/LuaIDE.program/.LuaIDE-Theme\" ] = \"background=gray\\\
backgroundHighlight=lightGray\\\
prompt=cyan\\\
promptHighlight=lightBlue\\\
err=red\\\
errHighlight=pink\\\
\\\
editorBackground=gray\\\
editorLineHightlight=lightBlue\\\
editorLineNumbers=gray\\\
editorLineNumbersHighlight=lightGray\\\
editorError=pink\\\
editorErrorHighlight=red\\\
\\\
textColor=white\\\
conditional=yellow\\\
constant=orange\\\
function=magenta\\\
string=red\\\
comment=lime\",\
    [ \"Programs/Quest.program/Elements/FileInput.lua\" ] = \"BackgroundColour = colours.lightGrey\\\
TextColour = colours.black\\\
Text = 'Choose File...'\\\
InputName = ''\\\
FilePath = 'test'\\\
\\\
OnInitialise = function(self, node)\\\
	local attr = self.Attributes\\\
	if attr.value then\\\
		self.Text = attr.value\\\
	end\\\
\\\
	if attr.name then\\\
		self.InputName = attr.name\\\
	end\\\
\\\
	if not attr.width then\\\
		self.Width = #self.Text + 2\\\
	end\\\
end\\\
\\\
UpdateValue = function(self, force)\\\
	if self.FilePath then\\\
		local f = fs.open(self.FilePath, 'r')\\\
		if f then\\\
			local content = f.readAll()\\\
			self.Value = '{\\\"name\\\": \\\"' .. fs.getName(self.FilePath):gsub('\\\"', '\\\\\\\\\\\"') .. '\\\", \\\"content\\\": \\\"' .. content:gsub('\\\"', '\\\\\\\\\\\"') .. '\\\"}'\\\
			f.close()\\\
		end\\\
	end\\\
end\\\
\\\
CreateObject = function(self, parentObject, y)\\\
	return parentObject:AddObject({\\\
		Element = self,\\\
		Y = y,\\\
		X = 1,\\\
		Width = self.Width,\\\
		Type = \\\"Button\\\",\\\
		Text = self.Text,\\\
		TextColour = self.TextColour,\\\
		BackgroundColour = self.BackgroundColour,\\\
		InputName = self.InputName,\\\
		OnClick = function(_self, event, side, x, y)\\\
			_self.Bedrock:DisplayOpenFileWindow(nil, function(success, path)\\\
				if success then\\\
					self.FilePath = path\\\
					_self.Text = 'File: '..fs.getName(path)\\\
					_self.Align = 'Left'\\\
				end\\\
			end)\\\
		end\\\
	})\\\
end\",\
    [ \"Programs/Quest Server.program/Views/settings.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=3,\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Server Address\\\",\\\
      [\\\"TextColour\\\"]=128\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=19,\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"wifi://\\\",\\\
      [\\\"TextColour\\\"]=256\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=26,\\\
      [\\\"Width\\\"]=20,\\\
      [\\\"Name\\\"]=\\\"AddressTextBox\\\",\\\
      [\\\"Type\\\"]=\\\"TextBox\\\",\\\
      [\\\"Placeholder\\\"]=\\\"e.g. basesite\\\",\\\
    },\\\
    [4]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=3,\\\
      [\\\"Width\\\"]=\\\"100%,-4\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Ok... so maybe there aren't that many settings. But hey, at least it's easy to use.\\\",\\\
      [\\\"TextColour\\\"]=256\\\
    },\\\
    [5]={\\\
      [\\\"Y\\\"]=9,\\\
      [\\\"X\\\"]=3,\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Quest Server v1.0.0\\\",\\\
    },\\\
    [6]={\\\
      [\\\"Y\\\"]=11,\\\
      [\\\"X\\\"]=3,\\\
      [\\\"Width\\\"]=\\\"100%,-4\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Quest and Quest Server were made by oeed using Bedrock, the source of all awesomeness. If you find a bug or have any questions give me a PM or post on the forum topic.\\\",\\\
      [\\\"TextColour\\\"]=128\\\
    },\\\
  },\\\
}\",\
    [ \"Programs/Quest.program/Elements/SelectOption.lua\" ] = \"Value = nil\\\
\\\
OnInitialise = function(self, node)\\\
	if attr.value then\\\
		new.Value = attr.value\\\
	end\\\
end\\\
\\\
OnCreateObject = function(self, parentObject, y)\\\
	if parentObject.AddMenuItem then\\\
		parentObject:AddMenuItem({\\\
			Value = self.Value,\\\
			Text = self.Text,\\\
			Type = \\\"Button\\\"\\\
		})\\\
	end\\\
end\",\
    [ \"Programs/Transmit.program/Views/message.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=\\\"50%,-4\\\",\\\
      [\\\"X\\\"]=\\\"50%,-5\\\",\\\
      [\\\"Name\\\"]=\\\"StatusImageView\\\",\\\
      [\\\"Type\\\"]=\\\"ImageView\\\",\\\
      [\\\"Width\\\"]=10,\\\
      [\\\"Height\\\"]=5,\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=\\\"50%,3\\\",\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"StatusLabel\\\",\\\
      [\\\"Width\\\"]=\\\"100%\\\",\\\
      [\\\"Height\\\"]=2,\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Align\\\"]=\\\"Center\\\",\\\
      [\\\"Text\\\"]=\\\"\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=\\\"50%,5\\\",\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"SecondaryStatusLabel\\\",\\\
      [\\\"Width\\\"]=\\\"100%\\\",\\\
      [\\\"Height\\\"]=2,\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Align\\\"]=\\\"Center\\\",\\\
      [\\\"Text\\\"]=\\\"\\\"\\\
    },\\\
    [4]={\\\
      [\\\"Y\\\"]=\\\"100%\\\",\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"ComputerLabel\\\",\\\
      [\\\"Width\\\"]=\\\"100%\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Align\\\"]=\\\"Center\\\",\\\
      [\\\"TextColour\\\"]=256,\\\
      [\\\"Text\\\"]=\\\"\\\"\\\
    },\\\
    [5]={\\\
      [\\\"Y\\\"]=\\\"50%,7\\\",\\\
      [\\\"X\\\"]=\\\"50%,-5\\\",\\\
      [\\\"Name\\\"]=\\\"YesButton\\\",\\\
      [\\\"Height\\\"]=1,\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Yes\\\",\\\
      [\\\"Visible\\\"]=false\\\
    },\\\
    [6]={\\\
      [\\\"Y\\\"]=\\\"50%,7\\\",\\\
      [\\\"X\\\"]=\\\"50%,2\\\",\\\
      [\\\"Name\\\"]=\\\"NoButton\\\",\\\
      [\\\"Height\\\"]=1,\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"No\\\",\\\
      [\\\"Visible\\\"]=false\\\
    },\\\
  },\\\
  [\\\"BackgroundColour\\\"]=1\\\
}\",\
    [ \"System/Images/crash\" ] = \" 0   0 \\\
       \\\
 00000 \\\
0     0\",\
    [ \"System/Programs/About OneOS.program/startup\" ] = \"OneOS.LoadAPI('/System/API/Bedrock.lua', false)\\\
\\\
local program = Bedrock:Initialise()\\\
\\\
function FormatBytes(bytes)\\\
	if bytes < 1024 then\\\
		return \\\"< 1KB\\\"\\\
	elseif bytes < 1024 * 1024 then\\\
		return math.ceil(bytes / 1024) .. 'KB'\\\
	elseif bytes < 1024 * 1024 * 1024 then\\\
		--string.format('%.2f', ...) wasn't working for some reason\\\
		local b = math.ceil((bytes / 1024 / 1024)*100)\\\
		return b/100 .. 'MB'\\\
	else\\\
		return '> 1GB'\\\
	end\\\
end\\\
\\\
function FolderSize(path)\\\
	if path == '//.git' then\\\
		return 0\\\
	end\\\
	local totalSize = 0\\\
	for i, v in ipairs(OneOS.FS.list(path)) do\\\
		if OneOS.FS.isDir(path..'/'..v) and path..'/'..v ~= '//rom' then\\\
			totalSize = totalSize + FolderSize(path..'/'..v)\\\
		else\\\
			totalSize = totalSize + OneOS.FS.getSize(path..'/'..v)\\\
		end\\\
	end\\\
	return totalSize\\\
end\\\
\\\
program:Run(function()\\\
	program:LoadView('main')\\\
	program:GetObject('VersionLabel').Text = 'OneOS '..OneOS.Version\\\
\\\
	if fs.getFreeSpace and fs.getSize then\\\
		local systemSize = FolderSize('/System/') + OneOS.FS.getSize('startup')\\\
		local desktopSize = FolderSize('/Desktop/')\\\
		local programsSize = FolderSize('/Programs/')\\\
		local totalSize = FolderSize('/')\\\
		local maxSpace = OneOS.FS.getFreeSpace('/') + totalSize\\\
		program:GetObject('StorageInfoLabel').Text = FormatBytes(totalSize)..' Used, '..FormatBytes(maxSpace - totalSize)..' Available'\\\
		program:GetObject('StorageProgressBar').Maximum = maxSpace\\\
		program:GetObject('StorageProgressBar').Value = {systemSize, programsSize, desktopSize, totalSize-systemSize-programsSize-desktopSize}\\\
		program:GetObject('StorageProgressBar'):ForceDraw()\\\
		program:Draw()\\\
	else\\\
		program:RemoveObject('StorageView')\\\
	end\\\
\\\
end)\",\
    [ \"System/Images/Boot/boot7\" ] = \"         8888          \\\
        888888         \\\
        888888         \\\
         8888          \\\
                       \\\
                       \\\
                       \\\
77777777777777777777788\",\
    [ \"System/Images/Boot/boot6\" ] = \"         8888          \\\
        888888         \\\
        888888         \\\
         8888          \\\
                       \\\
                       \\\
                       \\\
77777777777777777788888\",\
    [ \"Programs/Transmit.program/startup\" ] = \"OneOS.LoadAPI('/System/API/Bedrock.lua', false)\\\
OneOS.LoadAPI('/System/API/Peripheral.lua', true)\\\
OneOS.LoadAPI('/System/API/Wireless.lua', true)\\\
\\\
tArgs = {...}\\\
\\\
local program = Bedrock:Initialise()\\\
local animate = false\\\
\\\
function SetStatus(label1, label2, image, yesFunc, noFunc)\\\
	label2 = label2 or ''\\\
	if not program.View or program.View.Name ~= 'message' then\\\
		program:LoadView('message')\\\
	end\\\
	program:GetObject('StatusLabel').Text = label1\\\
	program:GetObject('StatusLabel').TextColour = colours.black\\\
	program:GetObject('SecondaryStatusLabel').Text = label2\\\
	program:GetObject('SecondaryStatusLabel').TextColour = colours.lightGrey\\\
	animate = false\\\
	if image then\\\
		if image == 'anm' then\\\
			animate = true\\\
			UpdateAnimation()\\\
		else\\\
			program:GetObject('StatusImageView').Path = 'Images/'..image\\\
		end\\\
	else\\\
		program:GetObject('StatusImageView').Visible = false\\\
	end\\\
\\\
	if yesFunc and noFunc then\\\
		program:GetObject('YesButton').Visible = true\\\
		program:GetObject('YesButton').OnClick = yesFunc\\\
		program:GetObject('NoButton').Visible = true\\\
		program:GetObject('NoButton').OnClick = noFunc\\\
	else\\\
		program:GetObject('YesButton').Visible = false\\\
		program:GetObject('NoButton').Visible = false\\\
	end\\\
end\\\
\\\
function UpdateStatus(id, replyChannel, message, savedFile)\\\
	if id == 0 then\\\
		SetStatus('No Wireless Modem', 'Attach a wireless modem and reopen Transmit', 'disabled')\\\
	elseif id == 1 then\\\
		SetStatus('Waiting For File', 'Waiting for another computer to send a file', 'anm')\\\
	elseif id == 2 then\\\
		SetStatus('Waiting For Reciever To Accept', 'The reciever needs to accept the file', 'anm')\\\
	elseif id == 3 then\\\
		if savedFile then\\\
			SetStatus('Complete!', 'The file was saved to: '..savedFile, 'anm4')\\\
		else\\\
			SetStatus('Complete!', 'The file transfer completed successfully', 'anm4')\\\
		end\\\
	elseif id == 4 then\\\
		SetStatus('Rejected', 'The reciever did not accept the file', 'anm4')\\\
	elseif id == 5 then\\\
		SetStatus('Accept File?', message.content.senderName..' would like to send you the file \\\"'..message.content.fileName..'\\\" Do you want to accept it?', 'anm1', function()\\\
			Wireless.SendMessage(replyChannel, {accept = true}, nil, message.messageID, message.senderID)\\\
		end, function()\\\
			Wireless.SendMessage(replyChannel, {accept = false}, nil, message.messageID, message.senderID)\\\
			UpdateStatus(1)\\\
		end)\\\
	elseif id == 6 then\\\
		SetStatus('Waiting For File', 'Waiting for another computer to send a file', 'anm')\\\
	end\\\
end\\\
\\\
function UpdateAnimation()\\\
	if animate then\\\
		local path = program:GetObject('StatusImageView').Path\\\
		if path == 'Images/anm0' then\\\
			program:GetObject('StatusImageView').Path = 'Images/'..'anm1'\\\
		elseif path == 'Images/anm1' then\\\
			program:GetObject('StatusImageView').Path = 'Images/'..'anm2'\\\
		elseif path == 'Images/anm2' then\\\
			program:GetObject('StatusImageView').Path = 'Images/'..'anm3'\\\
		else\\\
			program:GetObject('StatusImageView').Path = 'Images/'..'anm0'\\\
		end\\\
	end\\\
	program:Draw()\\\
end\\\
\\\
function RecieveFile()\\\
	Wireless.Responder = function(event, side, channel, replyChannel, message, distance)\\\
		if channel == Wireless.Channels.TransmitDiscovery then\\\
			if replyChannel and message.content == 'Discover' then\\\
				Wireless.SendMessage(replyChannel, {id = os.getComputerID(), name = os.getComputerLabel()}, nil, message.messageID, message.senderID)\\\
			end\\\
		elseif channel == Wireless.Channels.TransmitRequest then\\\
			if replyChannel and message.content.senderName and message.content.fileName then\\\
				UpdateStatus(5, replyChannel, message)\\\
			end\\\
		elseif channel == Wireless.Channels.TransmitSend then\\\
			if replyChannel and message.content.fileName and message.content.data then\\\
				local h = OneOS.FS.open('/Desktop/Documents/'..message.content.fileName, 'w')\\\
				h.write(message.content.data)\\\
				h.close()\\\
				UpdateStatus(3, nil, nil, '/Desktop/Documents/'..message.content.fileName)\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
function DiscoverComputers()\\\
	Wireless.Responder = function(event, side, channel, replyChannel, message, distance)\\\
		if channel == Wireless.Channels.TransmitDiscoveryReply then\\\
			local computers = program:GetObject('DiscoverView').Computers\\\
			local duplicate = false\\\
			for i, v in ipairs(computers) do\\\
				if v.ID == message.content.id then\\\
					duplicate = true\\\
					break\\\
				end\\\
			end\\\
\\\
			if not duplicate then\\\
				table.insert(computers, {\\\
					ID = message.content.id,\\\
					Name = message.content.name\\\
				})\\\
			end\\\
			program:GetObject('DiscoverView').Computers = computers\\\
			program:GetObject('DiscoverView'):OnUpdate('Computers')\\\
		end\\\
	end\\\
end\\\
\\\
function SendToComputer(computer)\\\
	UpdateStatus(2)\\\
	program:Draw()\\\
	local h = OneOS.FS.open(tArgs[1], 'r')\\\
	local f = h.readAll()\\\
	h.close()\\\
\\\
	Wireless.Responder = nil\\\
	local _m = Wireless.SendMessage(Wireless.Channels.TransmitRequest, {senderName = os.getComputerLabel(), fileName = fs.getName(tArgs[1])}, Wireless.Channels.TransmitRequestReply, nil, computer.ID)\\\
	local event, side, channel, replyChannel, message = Wireless.RecieveMessage(Wireless.Channels.TransmitRequestReply, _m.messageID, 20)\\\
	if message and message.content and message.content.accept == true then\\\
		Wireless.SendMessage(Wireless.Channels.TransmitSend, {data = f, fileName = fs.getName(tArgs[1])}, Wireless.Channels.TransmitRequestReply, nil, computer.ID)\\\
		UpdateStatus(3)\\\
	else\\\
		UpdateStatus(2)\\\
	end\\\
end\\\
\\\
program:RegisterEvent('modem_message', function(self, ...)Wireless.HandleMessage(...) end)\\\
\\\
program:Run(function()\\\
\\\
	if not Wireless.Present() then\\\
		UpdateStatus(0)\\\
	else\\\
		Wireless.Initialise()\\\
		local channels = {\\\
			Wireless.Channels.TransmitDiscovery,\\\
			Wireless.Channels.TransmitDiscoveryReply,\\\
			Wireless.Channels.TransmitRequest,\\\
			Wireless.Channels.TransmitRequestReply,\\\
			Wireless.Channels.TransmitSend,\\\
		}\\\
		for i, v in ipairs(channels) do\\\
			Wireless.Open(v)\\\
		end\\\
\\\
		if not os.getComputerLabel() then\\\
			os.setComputerLabel('OneOS Computer')\\\
		end\\\
\\\
		if tArgs[1] then\\\
			program:LoadView('discover')\\\
			program:GetObject('DiscoverView').Computers = {}\\\
			program:StartRepeatingTimer(function()Wireless.SendMessage(Wireless.Channels.TransmitDiscovery, 'Discover')end, 1)\\\
		else\\\
			UpdateStatus(1)\\\
		end\\\
		program:GetObject('ComputerLabel').Text = 'This computer is: '..os.getComputerLabel()\\\
		program:StartRepeatingTimer(UpdateAnimation, 0.25)\\\
		program:Draw()\\\
\\\
		if program.View.Name == 'discover' then\\\
			DiscoverComputers()\\\
		else\\\
			RecieveFile()\\\
		end\\\
\\\
\\\
	end\\\
end)\",\
    [ \"Programs/Quest.program/Elements/ElementTree.lua\" ] = \"Tree = nil\\\
FailHandler = nil\\\
\\\
Initialise = function(self, html)\\\
	local new = {}    -- the new instance\\\
	setmetatable( new, {__index = self} )\\\
	local err = nil\\\
	if html:sub(1,15):lower() ~= '<!doctype ccml>' then\\\
		err = Errors.InvalidDoctype\\\
	end\\\
\\\
	html = html:gsub(\\\"<!%-%-*.-%-%->\\\",\\\"\\\")\\\
\\\
	local rawTree\\\
	if not err then\\\
		rawTree = parser.parsestr(html)[1]\\\
	end\\\
\\\
	if not err then\\\
		_, notok = pcall(function() new:LoadTree(rawTree) end)\\\
		if notok then\\\
			error(notok)\\\
			err = Errors.ParseFailed\\\
		end\\\
	end\\\
\\\
	if err then\\\
		return nil, err\\\
	end\\\
	return new\\\
end\\\
\\\
LoadTree = function(self, rawTree)\\\
	local tree = {}\\\
	local node = true\\\
	node = function (tbl, tr, parent)\\\
		for i, v in ipairs(tbl) do\\\
			if type(v) == 'table' and v._tag then\\\
				local class = self:GetElementClass(v._tag, v._attr)\\\
				if not class or not class.Initialise then\\\
					error('Unknown class: '..v._attr.type)\\\
				end\\\
				local element = class:Initialise(v)\\\
				element.Parent = parent\\\
				table.insert(tr, element)\\\
				if element.Children then\\\
					node(v, element.Children, element)\\\
				end\\\
			end\\\
		end\\\
	end\\\
\\\
	node(rawTree, tree)\\\
	self.Tree = tree\\\
end\\\
\\\
GetElement = function(self, tag)\\\
	local node = true\\\
	node = function(tbl)\\\
		for i,v in ipairs(tbl) do\\\
			if type(v) == 'table' and v.Tag then\\\
				if v.Tag == tag then\\\
					return v\\\
				end\\\
				if v.Children then\\\
					local r = node(v.Children)\\\
					if r then\\\
						return r\\\
					end\\\
				end\\\
			end\\\
		end\\\
	end\\\
	return node(self.Tree)\\\
end\\\
\\\
GetElementClass = function(self, tag, attr)\\\
	if tag == 'h' then\\\
		return Heading\\\
	elseif tag == 'div' then\\\
		return Divider\\\
	elseif tag == 'p' then\\\
		return Paragraph\\\
	elseif tag == 'center' then\\\
		return Center\\\
	elseif tag == 'img' then\\\
		return Image\\\
	elseif tag == 'a' then\\\
		return Link\\\
	elseif tag == 'float' then\\\
		return Float\\\
	elseif tag == 'br' then\\\
		return Element\\\
	elseif tag == 'input' then\\\
		if attr.type == 'text' then\\\
			return TextInput\\\
		elseif attr.type == 'password' then\\\
			return SecureTextInput\\\
		elseif attr.type == 'submit' or attr.type == 'button' then\\\
			return ButtonInput\\\
		elseif attr.type == 'file' then\\\
			return FileInput\\\
		elseif attr.type == 'hidden' then\\\
			return HiddenInput\\\
		else\\\
			return Element\\\
		end\\\
	elseif tag == 'select' then\\\
		return Select\\\
	elseif tag == 'option' then\\\
		return SelectOption\\\
	elseif tag == 'form' then\\\
		return Form\\\
	elseif tag == 'script' then\\\
		return Script\\\
	else\\\
		return Element\\\
	end\\\
end\",\
    [ \"System/Images/Boot/boot3\" ] = \"         8888          \\\
        888888         \\\
        888888         \\\
         8888          \\\
                       \\\
                       \\\
                       \\\
77777777788888888888888\",\
    [ \"Programs/Shell.program/startup\" ] = \"OneOS.ToolBarColour=colours.black;OneOS.ToolBarTextColour=colours.white;local a={}local b={}local function c(d,...)local e=OneOS.Shell.resolveProgram(d)if e~=nil then b[#b+1]=e;local f=shell;f.programs=OneOS.Shell.programs;local g=OneOS.OSRun({fs=OneOS.FS,shell=f,io=OneOS.IO,loadfile=OneOS.LoadFile,os=os,sleep=os.sleep},e,...)b[#b]=nil;return g else printError(\\\"No such program\\\")return false end end;local function h(i)local j={}for k in string.gmatch(i,\\\"[^ \\\\t]+\\\")do table.insert(j,k)end;local l=j[1]if l then return c(l,unpack(j,2))end;return false end;local m={['rom/programs/cd']={'path'},['rom/programs/copy']={'source','destination'},['rom/programs/delete']={'path'},['rom/programs/edit']={'path'},['rom/programs/eject']={'side'},['rom/programs/gps']={'locate'},['rom/programs/help']={'topic'},['rom/programs/label']={'set','text'},['rom/programs/mkdir']={'path'},['rom/programs/monitor']={'side','program','arguments'},['rom/programs/move']={'source','destination'},['rom/programs/color/paint']={'path'},['rom/programs/http/pastebin']={'get','code','filename'},['rom/programs/redpulse']={'side','count','period'},['rom/programs/redset']={'side','true/false'},['rom/programs/redstone']={'side','true/false'},['rom/programs/rename']={'source','destination'},['rom/programs/type']={'path'},['rom/programs/bg']={'program'},['rom/programs/fg']={'program'},['rom/programs/rednet/chat']={'join','hostname','username'},['rom/programs/turtle/craft']={'amount'},['rom/programs/turtle/equip']={'slot','side'},['rom/programs/turtle/excavate']={'diameter'},['rom/programs/turtle/go']={'direction','distance'},['rom/programs/turtle/refuel']={'amount'},['rom/programs/turtle/tunnel']={'length'},['rom/programs/turtle/turn']={'direction','turns'},['rom/programs/turtle/unequip']={'side'}}local n,o,p,q;if term.isColour()then n=colours.yellow;o=colours.white;q=colours.grey;p=colours.black else n=colours.white;o=colours.white;q=colours.black;p=colours.black end;term.setCursorPos(1,2)term.setBackgroundColor(p)term.setTextColour(n)term.write(os.version())term.setTextColour(o)term.write(' Quick Shell')print()term.setTextColour(o)local function r(s)local t=0;local u=0;repeat u=string.find(s,\\\"/\\\",t)if u~=nil then t=u+1 end until u==nil;return string.gsub(s,string.sub(s,t),\\\"\\\")end;local function k(s,v)if#s==0 then return''end;local w={}local function x(y)if y and type(y)=='table'then for z,A in ipairs(y)do local B=true;for C,D in ipairs(w)do if D==A then B=false;break end end;if B then table.insert(w,A)end end elseif y then table.insert(w,y)end end;if v=='program'then x(OneOS.Shell.resolveProgram(s))x(OneOS.Shell.aliases())x(OneOS.Shell.programs())elseif v=='side'then x({'left','right','top','bottom','front','back'})x(peripheral.getNames())elseif v=='direction'then x({'left','right','forward','back','down','up'})elseif v=='true/false'then x({'true','false'})elseif v=='set'then x({'get','set','clear'})elseif v=='locate'then x({'locate','host'})elseif v=='set'then x({'get','set','clear'})elseif v=='get'then x({'get','put','run'})elseif v=='topic'then x(help.topics())x('index')elseif v=='path'or v=='source'then local E=r(s)local F,G=r(E)if not OneOS.FS.isDir(F)then return''end;local w=OneOS.FS.list(F)for z,H in ipairs(w)do if string.lower(OneOS.FS.getName(string.sub(OneOS.FS.getName(H),1,string.len(OneOS.FS.getName(s)))))==string.lower(OneOS.FS.getName(s))then return F..H end end;return''end;for z,H in ipairs(w)do if string.lower(string.sub(H,1,string.len(s)))==string.lower(s)then return H end end;return''end;local function I(J,K)term.setCursorBlink(true)local L=\\\"\\\"local M=nil;local N=0;if J then J=string.sub(J,1,1)end;local O,P=term.getSize()local Q,R=term.getCursorPos()local S=''local T=false;local function U(V,W)local X=0;if Q+N>=O then X=Q+N-O end;term.setCursorPos(1,R)term.clearLine()term.setBackgroundColor(p)term.setTextColour(n)term.write(shell.dir()..\\\"> \\\")if not T and not W then term.setCursorPos(Q,R)term.setTextColour(q)S=k(L,'program')term.write(S)elseif not W and T and N>=#S+1 then local Y=m[OneOS.Shell.resolveProgram(S)]previousArgs=''if Y then term.setCursorPos(Q+#L,R)if L:sub(-1)~=' 'then term.write(' ')term.setCursorPos(Q+#L+1,R)end;term.setTextColour(q)local j={}for Z in string.gmatch(L,\\\"[^ \\\\t]+\\\")do table.insert(j,Z)end;table.remove(j,1)for z,v in ipairs(Y)do if#j<z then term.write(v..' ')elseif z==#j and L:sub(-1)~=' 'then term.setCursorPos(Q+#L-#j[z],R)local _=k(j[z],v)if#_~=0 then term.write(_..' ')else term.write(j[z]..' ')end end end end end;term.setTextColour(o)term.setCursorPos(Q,R)local a0=V or J;if a0 then term.write(string.rep(a0,string.len(L)-X))else term.write(string.sub(L,X+1))end;term.setCursorPos(Q+N-X,R)end;while true do local a1,a2=os.pullEvent()if a1==\\\"char\\\" or a1==\\\"paste\\\"then L=string.sub(L,1,N)..a2 ..string.sub(L,N+1)if T and N<=#S or not T and a2==' 'then local t,len=L:find(\\\"[^ \\\\t]+\\\")if t and len then S=L:sub(t,len)T=true end end;term.setCursorPos(1,2)N=N+#a2;U()elseif a1==\\\"key\\\"then if a2==keys.enter then U(nil,true)break elseif a2==keys.tab then if N>=#S+1 and N==#L then local Y=m[OneOS.Shell.resolveProgram(S)]local a3=''local j={}for k in string.gmatch(L,\\\"[^ \\\\t]+\\\")do table.insert(j,k)end;if#j==0 then return end;if Y then k(j[#j],Y[#j-1])end;if#a3~=0 then L=''j[#j]=a3;for z,A in ipairs(j)do L=L..A..' 'end;N=#L;U()else L=L..' 'N=#L;U()end else local a3=k(L,'program')if#a3~=0 then N=#a3+1;L=a3 ..' 'T=true;S=a3;U()end end elseif a2==keys.left then if N>0 then N=N-1;U()end elseif a2==keys.right then if N<string.len(L)then U(\\\" \\\")N=N+1;U()end elseif a2==keys.up or a2==keys.down then if K then U(\\\" \\\")if a2==keys.up then if M==nil then if#K>0 then M=#K end elseif M>1 then M=M-1 end else if M==#K then M=nil elseif M~=nil then M=M+1 end end;if M then L=K[M]N=string.len(L)else L=\\\"\\\"N=0 end;U()end elseif a2==keys.backspace then if N==#L and string.sub(L,N,N)==' 'then local j={}for k in string.gmatch(L,\\\"[^ \\\\t]+\\\")do table.insert(j,k)end;table.remove(j,#j)L=''for z,A in ipairs(j)do L=L..A..' 'end;N=#L;if#j==0 then S=''T=false end;U()elseif N>0 then U(\\\" \\\")L=string.sub(L,1,N-1)..string.sub(L,N+1)if T and N<=#S then local t,len=L:find(\\\"[^ \\\\t]+\\\")if t and len then S=L:sub(t,len)end end;N=N-1;U()end elseif a2==keys.home then U(\\\" \\\")N=0;U()elseif a2==keys.delete then if N<string.len(L)then U(\\\" \\\")L=string.sub(L,1,N)..string.sub(L,N+2)U()end elseif a2==keys[\\\"end\\\"]then U(\\\" \\\")N=string.len(L)U()end end end;term.setCursorBlink(false)term.setCursorPos(O+1,R)print()return L end;local a4={}while not bExit do term.setBackgroundColor(p)term.setTextColour(n)term.write(shell.dir()..\\\"> \\\")term.setTextColour(o)local a5=I(nil,a4)if a5 then local Y={}for v in a5:gmatch('%S+')do table.insert(Y,v)end;if not Y[1]or Y[1]==''then elseif Y[1]=='shutdown'then term.setTextColour(n)print('See ya!')sleep(1)OneOS.Shutdown()elseif Y[1]=='reboot'then term.setTextColour(n)print('See ya!')sleep(1)OneOS.Reboot()elseif Y[1]=='exit'then OneOS.Close()else local E=OneOS.Shell.resolveProgram(shell.dir()..'/'..Y[1])if E==nil then E=OneOS.Shell.resolveProgram(Y[1])end;if E~=nil then Y[1]=E;if E:sub(1,3)=='rom'then h(table.concat(Y,\\\" \\\"))else h(table.concat(Y,\\\" \\\"))end else printError(\\\"The file '\\\"..Y[1]..\\\"' does not exist\\\")end end;table.insert(a4,a5)end end\",\
    [ \"System/API/Wireless.lua\" ] = \"--OneOS uses channels between 4200 and 4300, avoid use where possible\\\
\\\
Channels = {\\\
	Ignored = 4299,\\\
	Ping = 4200,\\\
	PingReply = 4201,\\\
	TurtleRemote = 4202,\\\
	TurtleRemoteReply = 4203,\\\
	TransmitDiscovery = 4204,\\\
	TransmitDiscoveryReply = 4205,\\\
	TransmitRequest = 4206,\\\
	TransmitRequestReply = 4207,\\\
	TransmitSend = 4208,\\\
	UltimateDoorlockPing = 4210,\\\
	UltimateDoorlockRequest = 4211,\\\
	UltimateDoorlockRequestReply = 4212,\\\
}\\\
\\\
local function isOpen(channel)\\\
	return Peripheral.CallType('wireless_modem', 'isOpen', channel)\\\
end\\\
\\\
local function open(channel)\\\
	if not isOpen(channel) then\\\
		Peripheral.CallType('wireless_modem', 'open', channel)\\\
	end\\\
end\\\
\\\
Open = open\\\
\\\
local function close(channel)\\\
	Peripheral.CallType('wireless_modem', 'close', channel)\\\
end\\\
\\\
local function closeAll()\\\
	Peripheral.CallType('wireless_modem', 'closeAll')\\\
end\\\
\\\
local function transmit(channel, replyChannel, message)\\\
	Peripheral.CallType('wireless_modem', 'transmit', channel, replyChannel, textutils.serialize(message))\\\
end\\\
\\\
function Present()\\\
	if Peripheral.GetPeripheral('wireless_modem') == nil then\\\
		return false\\\
	else\\\
		return true\\\
	end\\\
end\\\
\\\
local function FormatMessage(message, messageID, destinationID)\\\
	return {\\\
		content = textutils.serialize(message),\\\
		senderID = os.getComputerID(),\\\
		senderName = os.getComputerLabel(),\\\
		channel = channel,\\\
		replyChannel = reply,\\\
		messageID = messageID or math.random(10000),\\\
		destinationID = destinationID\\\
	}\\\
end\\\
\\\
local Timeout = function(func, time)\\\
	time = time or 1\\\
	parallel.waitForAny(func, function()\\\
		sleep(time)\\\
		--log('Timeout!'..time)\\\
	end)\\\
end\\\
\\\
RecieveMessage = function(_channel, messageID, timeout)\\\
	open(_channel)\\\
	local done = false\\\
	local event, side, channel, replyChannel, message = nil\\\
	Timeout(function()\\\
		while not done do\\\
			event, side, channel, replyChannel, message = os.pullEvent('modem_message')\\\
			if channel ~= _channel then\\\
				event, side, channel, replyChannel, message = nil\\\
			else\\\
				message = textutils.unserialize(message)\\\
				message.content = textutils.unserialize(message.content)\\\
				if messageID and messageID ~= message.messageID or (message.destinationID ~= nil and message.destinationID ~= os.getComputerID()) then\\\
					event, side, channel, replyChannel, message = nil\\\
				else\\\
					done = true\\\
				end\\\
			end\\\
		end\\\
	end,\\\
	timeout)\\\
	return event, side, channel, replyChannel, message\\\
end\\\
\\\
Initialise = function()\\\
	if Present() then\\\
		for i, c in pairs(Channels) do\\\
			open(c)\\\
		end\\\
	end\\\
end\\\
\\\
HandleMessage = function(event, side, channel, replyChannel, message, distance)\\\
	message = textutils.unserialize(message)\\\
	message.content = textutils.unserialize(message.content)\\\
\\\
	if channel == Channels.Ping then\\\
		if message.content == 'Ping!' then\\\
			SendMessage(replyChannel, 'Pong!', nil, message.messageID)\\\
		end\\\
	elseif message.destinationID ~= nil and message.destinationID ~= os.getComputerID() then\\\
	elseif Wireless.Responder then\\\
		Wireless.Responder(event, side, channel, replyChannel, message, distance)\\\
	end\\\
end\\\
\\\
SendMessage = function(channel, message, reply, messageID, destinationID)\\\
	reply = reply or channel + 1\\\
	open(channel)\\\
	open(reply)\\\
	local _message = FormatMessage(message, messageID, destinationID)\\\
	transmit(channel, reply, _message)\\\
	return _message\\\
end\\\
\\\
Ping = function()\\\
	local message = SendMessage(Channels.Ping, 'Ping!', Channels.PingReply)\\\
	RecieveMessage(Channels.PingReply, message.messageID)\\\
end\",\
    [ \"System/API/Settings.lua\" ] = \"Defaults = {\\\
	ComputerName = {\\\
		Type = 'Text',\\\
		Label = 'Computer Name',\\\
		Default = 'OneOS Computer'\\\
	},\\\
	DesktopColour = {\\\
		Type = 'Colour',\\\
		Label = 'Desktop Colour',\\\
		Default = colours.cyan,\\\
		Controls = {}\\\
	},\\\
	UseAnimations = {\\\
		Type = 'Bool',\\\
		Label = 'Use Animations',\\\
		Default = true,\\\
	},\\\
	DownloadPrereleases = {\\\
		Type = 'Bool',\\\
		Label = 'Download Betas',\\\
		Default = false,\\\
	},\\\
	StartupProgram = {\\\
		Type = 'Program',\\\
		Label = 'Startup Program',\\\
		Default = nil,\\\
	},\\\
	DoubleClick = {\\\
		Type = 'Bool',\\\
		Label = 'Double Click',\\\
		Default = false,\\\
	},\\\
	Monitor = {\\\
		Type = 'Side',\\\
		Label = 'Monitor Side',\\\
		Default = nil\\\
	},\\\
	Password = {\\\
		Type = 'Password',\\\
		Label = 'Password',\\\
		Default = nil\\\
	}\\\
}\\\
--[[\\\
\\\
function WriteDefaults(self)\\\
	local file = fs.open('/System/.OneOS.settings', 'w')\\\
	local defaults = {}\\\
	for k, v in pairs(self.Defaults) do\\\
		defaults[k] = v.Default\\\
		UpdateInterfaceForKey(k, v)\\\
	end\\\
	file.write(textutils.serialize(defaults))\\\
	file.close()\\\
end\\\
\\\
]]--\\\
function GetValues(self)\\\
	if not fs.exists('/System/.OneOS.settings') then\\\
		local defaults = {}\\\
		for k, v in pairs(self.Defaults) do\\\
			defaults[k] = v.Default\\\
		end\\\
		return defaults\\\
	end\\\
\\\
	local file = fs.open('/System/.OneOS.settings','r')\\\
	local values = textutils.unserialize(file.readAll())\\\
	if not values then\\\
		local defaults = {}\\\
		for k, v in pairs(self.Defaults) do\\\
			defaults[k] = v.Default\\\
		end\\\
		return defaults\\\
	end\\\
	\\\
	for k, v in pairs(self.Defaults) do\\\
		if values[k] == nil then\\\
			values[k] = v.Default\\\
		end\\\
	end\\\
	file.close()\\\
	return values\\\
end\\\
\\\
function CheckPassword(self, password)\\\
	return Hash.sha256(password) == self:GetValues()['Password']\\\
end\\\
\\\
DesktopColourChange = false\\\
function SetDesktopColourChange(func)\\\
	DesktopColourChange = func\\\
end\\\
\\\
function UpdateInterfaceForKey(key, value)\\\
	if key == 'DesktopColour' then\\\
		if DesktopColourChange then\\\
			DesktopColourChange(value)\\\
		end\\\
	elseif key == 'ComputerName' then\\\
		os.setComputerLabel(value)\\\
	end\\\
end\\\
\\\
function SetValue(self, key, value)\\\
	local currentValues = self:GetValues()\\\
	currentValues[key] = value\\\
	local file = fs.open('/System/.OneOS.settings', 'w')\\\
	file.write(textutils.serialize(currentValues))\\\
	file.close()\\\
	UpdateInterfaceForKey(key, value)\\\
end\",\
    [ \"Programs/Transmit.program/Views/discover.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"DiscoverView\\\",\\\
      [\\\"Type\\\"]=\\\"DiscoverView\\\",\\\
      [\\\"Width\\\"]=\\\"100%\\\",\\\
      [\\\"Height\\\"]=\\\"100%\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=\\\"100%,-2\\\",\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"HelpLabel\\\",\\\
      [\\\"Width\\\"]=\\\"100%\\\",\\\
      [\\\"Height\\\"]=2,\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Align\\\"]=\\\"Center\\\",\\\
      [\\\"TextColour\\\"]=128,\\\
      [\\\"Text\\\"]=\\\"Open Transmit on another computer then select it.\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=\\\"100%\\\",\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"ComputerLabel\\\",\\\
      [\\\"Width\\\"]=\\\"100%\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Align\\\"]=\\\"Center\\\",\\\
      [\\\"TextColour\\\"]=256,\\\
      [\\\"Text\\\"]=\\\"\\\"\\\
    },\\\
    [4]={\\\
      [\\\"Y\\\"]=\\\"100%,-8\\\",\\\
      [\\\"X\\\"]=\\\"50%,-5\\\",\\\
      [\\\"Name\\\"]=\\\"StatusImageView\\\",\\\
      [\\\"Type\\\"]=\\\"ImageView\\\",\\\
      [\\\"Width\\\"]=10,\\\
      [\\\"Height\\\"]=5,\\\
      [\\\"Path\\\"]='/Images/anm1'\\\
    },\\\
  },\\\
  [\\\"BackgroundColour\\\"]=1\\\
}\",\
    [ \"Programs/Quest Server.program/startup\" ] = \"local bedrockPath='' if OneOS then OneOS.LoadAPI('/System/API/Bedrock.lua', false)elseif fs.exists(bedrockPath..'/Bedrock')then os.loadAPI(bedrockPath..'/Bedrock')else if http then print('Downloading Bedrock...')local h=http.get('http://pastebin.com/raw.php?i=0MgKNqpN')if h then local f=fs.open(bedrockPath..'/Bedrock','w')f.write(h.readAll())f.close()h.close()os.loadAPI(bedrockPath..'/Bedrock')else error('Failed to download Bedrock. Is your internet working?') end else error('This program needs to download Bedrock to work. Please enable HTTP.') end end if Bedrock then Bedrock.BasePath = bedrockPath Bedrock.ProgramPath = shell.getRunningProgram() end\\\
\\\
local program = Bedrock:Initialise()\\\
\\\
os.loadAPI(program.ProgramPath .. '/APIs/Peripheral')\\\
os.loadAPI(program.ProgramPath .. '/APIs/Wireless')\\\
\\\
local serverRunning = false\\\
\\\
local messageLevel = {\\\
	Info 	= 'Info',\\\
	Success	= 'Success',\\\
	Warning = 'Warning',\\\
	Error 	= 'Error',\\\
}\\\
\\\
local function logMsg(msg, level)\\\
	level = level or messageLevel.Info\\\
	program:GetObject('LogView'):AddItem('[' .. level .. '] '..msg, level)\\\
end\\\
\\\
local defaultSettings = {\\\
	address = nil\\\
}\\\
\\\
local settings = {}\\\
\\\
local function saveSettings()\\\
	logMsg('Saving settings.')\\\
	local f = fs.open('.QuestServer.settings', 'w')\\\
	settings.address = program:GetObject('AddressTextBox').Text\\\
	if f then\\\
		f.write(textutils.serialize(settings))\\\
		f.close()\\\
	end\\\
end\\\
\\\
local function loadSettings()\\\
	logMsg('Loading settings.')\\\
	local f = fs.open('.QuestServer.settings', 'r')\\\
	if f then\\\
		settings = textutils.unserialize(f.readAll())\\\
		f.close()\\\
	else\\\
		logMsg('No settings file, using default.', messageLevel.Warning)\\\
		settings = defaultSettings\\\
		saveSettings()\\\
	end\\\
\\\
	program:GetObject('AddressTextBox').Text = settings.address or ''\\\
end\\\
\\\
local function switchView(name)\\\
	local viewNames = {\\\
		'Settings',\\\
		'Log',\\\
	}\\\
\\\
	for i, v in ipairs(viewNames) do\\\
		if name == v then\\\
			program:GetObject(v .. 'View').Visible = true\\\
			program:GetObject(v .. 'Button').Toggle = true\\\
		else\\\
			program:GetObject(v .. 'View').Visible = false\\\
			program:GetObject(v .. 'Button').Toggle = false\\\
		end\\\
	end\\\
\\\
	program:SetActiveObject()\\\
end\\\
\\\
local availableTimer = nil\\\
\\\
local startServer = nil\\\
local stopServer = nil\\\
\\\
local function checkNameAvailable(name)\\\
	logMsg('Checking address clashes: '..name)\\\
	if name:match(\\\"%W\\\") then\\\
		logMsg('Invalid address!', messageLevel.Error)\\\
		stopServer('Invalid Address')\\\
		switchView('Settings')\\\
	else\\\
		Wireless.SendMessage(Wireless.Channels.QuestServerNameAvailable, name)\\\
		availableTimer = program:StartTimer(function()\\\
			if availableTimer and name == settings.address then\\\
				logMsg('No address clashes found!', messageLevel.Success)\\\
				availableTimer = nil\\\
				startServer(true)\\\
			end\\\
		end, 1)\\\
	end\\\
end\\\
\\\
function stopServer(reason)\\\
	logMsg('Stopping server: ' .. reason or 'Stopped', messageLevel.Warning)\\\
	serverRunning = false\\\
	program:GetObject('GoStopButton').Text = '>'\\\
	program:GetObject('StatusLabel').Text = reason or 'Stopped'\\\
end\\\
\\\
function startServer(available)\\\
	logMsg('Starting server...')\\\
	if settings.address and #settings.address > 0 then\\\
		if available then\\\
			logMsg('Server started!', messageLevel.Success)\\\
			serverRunning = true\\\
			program:GetObject('GoStopButton').Text = 'x'\\\
			program:GetObject('StatusLabel').Text = 'Running'\\\
		else\\\
			program:GetObject('StatusLabel').Text = 'Checking Name'\\\
			checkNameAvailable(settings.address)\\\
		end\\\
	else\\\
		logMsg('Server could not start, address not set!', messageLevel.Error)\\\
		stopServer('Address Not Set')\\\
		switchView('Settings')\\\
	end\\\
end\\\
\\\
program.OnKeyChar = function(self, event, keychar)\\\
	if keychar == '\\\\\\\\' then\\\
		os.reboot()\\\
	end\\\
end\\\
\\\
program:RegisterEvent('modem_message', function(self, event, side, channel, replyChannel, message, distance)\\\
	Wireless.HandleMessage(event, side, channel, replyChannel, message, distance)\\\
end)\\\
\\\
local function split(str, pat)\\\
   local t = {}\\\
   local fpat = \\\"(.-)\\\" .. pat\\\
   local last_end = 1\\\
   local s, e, cap = str:find(fpat, 1)\\\
   while s do\\\
      if s ~= 1 or cap ~= \\\"\\\" then\\\
	 table.insert(t,cap)\\\
      end\\\
      last_end = e+1\\\
      s, e, cap = str:find(fpat, last_end)\\\
   end\\\
   if last_end <= #str then\\\
      cap = str:sub(last_end)\\\
      table.insert(t, cap)\\\
   end\\\
   return t\\\
end\\\
\\\
local function findLast(haystack, needle)\\\
    local i=haystack:match(\\\".*\\\"..needle..\\\"()\\\")\\\
    if i==nil then return nil else return i-1 end\\\
end\\\
\\\
local hex_to_char = function(x)\\\
  return string.char(tonumber(x, 16))\\\
end\\\
\\\
local function urlUnencode( str )\\\
	-- essentially reverses textutils.urlDecode\\\
    if str then\\\
        str = string.gsub(str, \\\"+\\\", \\\" \\\")\\\
        str = string.gsub(str, \\\"\\\\r\\\\n\\\", \\\"\\\\n\\\")\\\
        term.setTextColor(colors.black)\\\
        str = str:gsub(\\\"%%(%x%x)\\\", hex_to_char)\\\
    end\\\
    return str    \\\
end\\\
\\\
local function urlComponents(url)\\\
	if url then\\\
		urlUnencode(textutils.urlEncode(url))\\\
		local components = {}\\\
		local parts = split(url, '[\\\\\\\\/]+')\\\
		if url:find('://') and parts[1]:sub(#parts[1]) == ':' then\\\
			components.protocol = parts[1]:sub(1, #parts[1]-1)\\\
			components.sansprotocol = url:sub(#components.protocol + 4)\\\
			components.host = parts[2]\\\
			components.fullhost = components.protocol .. '://' .. parts[2] .. '/'\\\
			components.filename = fs.getName(url)\\\
			components.filepath = url:sub(#components.fullhost)\\\
			if components.filename == components.host then\\\
				components.filename = ''\\\
			end\\\
			components.base = url:sub(1, findLast(url, '/'))\\\
			components.get = {}\\\
			components.filepathsansget = components.sansprotocol\\\
			if url:find('?') then\\\
				local start = url:find('?')\\\
				components.filepathsansget = url:sub(#components.protocol + 4, start - 1)\\\
				local getString = url:sub(start + 1)\\\
				local values = split(getString, '&')\\\
				for i, v in ipairs(values) do\\\
					local keyvalue = split(v, '=')\\\
					components.get[keyvalue[1]] =  urlUnencode(keyvalue[2])\\\
				end\\\
			end\\\
			return components\\\
		end\\\
	end\\\
end\\\
\\\
local function resolveFile(path)\\\
	local parts = split(path, '[\\\\\\\\/]+')\\\
	local realPath = '/Server Files'\\\
	if #parts == 0 then\\\
		parts = {''}\\\
	end\\\
	for i, v in ipairs(parts) do\\\
		local tmpPath\\\
		if #v == 0 then\\\
		 	tmpPath = realPath\\\
		else\\\
		 	tmpPath = realPath .. '/' ..v\\\
		end\\\
		if fs.exists(tmpPath) then\\\
			if fs.isDir(tmpPath) and i == #parts then\\\
				local attempts = {\\\
					tmpPath .. '/index.ccml',\\\
					tmpPath .. '/index.html',\\\
				}\\\
\\\
				for i2, v2 in ipairs(attempts) do\\\
					if fs.exists(v2) then\\\
						return v2\\\
					end\\\
				end\\\
				return nil\\\
			end\\\
			realPath = tmpPath\\\
		else\\\
			return nil\\\
		end\\\
	end\\\
	return realPath\\\
end\\\
\\\
Wireless.Responder = function(event, side, channel, replyChannel, message, distance)\\\
	if channel == Wireless.Channels.QuestServerRequest and serverRunning then\\\
		if message.content:find('wifi://') == 1 then\\\
			local parts = urlComponents(message.content)\\\
			if parts.host and parts.host == settings.address then\\\
				local path = resolveFile(parts.filepath)\\\
				local content\\\
				if path then\\\
					local f = fs.open(path, 'r')\\\
					if f then\\\
						content = f.readAll()\\\
						logMsg('File request successful: '..message.content, messageLevel.Success)\\\
					end\\\
				end\\\
				if not content then\\\
					logMsg('File request failed: '..message.content, messageLevel.Warning)\\\
				end\\\
				Wireless.SendMessage(replyChannel, {url = message.content, content = content}, nil, message.messageID)\\\
			end\\\
		end\\\
	elseif channel == Wireless.Channels.QuestServerNameAvailable then\\\
		if message.content == settings.address then\\\
			logMsg('External address clash request clashed with this server: '..message.content, messageLevel.Warning)\\\
			Wireless.SendMessage(replyChannel, 'IN_USE', nil, message.messageID)\\\
		end\\\
	elseif channel == Wireless.Channels.QuestServerNameAvailableReply and running then\\\
		availableTimer = nil\\\
		logMsg('Address clash request failed, address in use: '..message.content, messageLevel.Error)\\\
		stopServer('Address In Use')\\\
		switchView('Settings')\\\
	end\\\
end\\\
\\\
local debounce = nil\\\
\\\
program.OnTimer = function(self, event, timer)\\\
	if timer == debounce then\\\
		saveSettings()\\\
	end\\\
end\\\
\\\
program:Run(function()\\\
	if Wireless.Present() then\\\
		program:LoadView('main')\\\
\\\
		if not fs.exists('/Server Files/') then\\\
			fs.makeDir('/Server Files/')\\\
			local f = fs.open('/Server Files/index.ccml', 'w')\\\
			if f then\\\
				f.write([[<!DOCTYPE ccml>\\\
<html>\\\
    <head>\\\
        <title>Welcome to your Quest Server Website!</title>\\\
    </head>\\\
\\\
    <body>\\\
        <br>\\\
        <h colour=\\\"green\\\">Welcome to your Quest Server Website!</h>\\\
        <br>\\\
        <center>\\\
	        <p width=\\\"46\\\" align=\\\"center\\\">\\\
	            The files for this website are stored in the /Server Files/ folder on the server.\\\
	        </p>\\\
	        <br>\\\
	        <p width=\\\"46\\\" align=\\\"center\\\">\\\
	            If you haven't made a Quest web page before you should look for the CCML tutorial on the ComputerCraft forums.\\\
	        </p>\\\
        </center>\\\
    </body>\\\
</html>]])\\\
				f.close()\\\
			end\\\
		end\\\
\\\
		loadSettings()\\\
		Wireless.Initialise()\\\
\\\
		switchView('Log')\\\
		startServer()\\\
\\\
		program:GetObject('SettingsButton').OnClick = function(self, event, side, x, y)\\\
			switchView('Settings')\\\
		end\\\
\\\
		program:GetObject('LogButton').OnClick = function(self, event, side, x, y)\\\
			switchView('Log')\\\
		end\\\
\\\
		program:GetObject('GoStopButton').OnClick = function(self, event, side, x, y)\\\
			if serverRunning then\\\
				stopServer()\\\
			else\\\
				startServer()\\\
			end\\\
		end\\\
\\\
		program:GetObject('AddressTextBox').OnChange = function(self, event, keychar)\\\
			if settings.address ~= program:GetObject('AddressTextBox').Text then\\\
				stopServer('Address Changed')\\\
				debounce = os.startTimer(1)\\\
			end\\\
		end\\\
\\\
	else\\\
		program:LoadView('nomodem')\\\
	end\\\
\\\
	program:GetObject('QuitButton').OnClick = function(self, event, side, x, y)\\\
		term.setBackgroundColour(colours.black)\\\
		term.setTextColor(colours.white)\\\
		term.clear()\\\
		term.setCursorPos(1, 1)\\\
		print('Thanks for using Quest Server by oeed')\\\
		program:Quit()\\\
	end\\\
end)\",\
    [ \"Programs/Ink.program/Icons/license\" ] = \"0bblah\\\
07blah\\\
08blah\",\
    [ \"Programs/Quest.program/Views/toolbar.view\" ] = \"{\\\
  [\\\"Width\\\"]=\\\"100%\\\",\\\
  [\\\"Height\\\"]=3,\\\
  [\\\"Type\\\"]=\\\"View\\\",\\\
  [\\\"BackgroundColour\\\"]=256,\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=2,\\\
      [\\\"Name\\\"]=\\\"BackButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Enabled\\\"]=false,\\\
      [\\\"TextColour\\\"]=128,\\\
      [\\\"Text\\\"]=\\\"<\\\",\\\
      [\\\"BackgroundColour\\\"]=1\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=6,\\\
      [\\\"Name\\\"]=\\\"ForwardButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Enabled\\\"]=false,\\\
      [\\\"TextColour\\\"]=128,\\\
      [\\\"Text\\\"]=\\\">\\\",\\\
      [\\\"BackgroundColour\\\"]=1\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=10,\\\
      [\\\"Width\\\"]=\\\"100%,-14\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"BackgroundColour\\\"]=1\\\
    },\\\
    [4]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=10,\\\
      [\\\"Width\\\"]=\\\"100%,-14\\\",\\\
      [\\\"Name\\\"]=\\\"URLTextBox\\\",\\\
      [\\\"Type\\\"]=\\\"TextBox\\\",\\\
      [\\\"TextColour\\\"]=128,\\\
      [\\\"Placeholder\\\"]=\\\"Website URL...\\\",\\\
      [\\\"PlaceholderTextColour\\\"]=256,\\\
      [\\\"BackgroundColour\\\"]=0,\\\
      [\\\"SelectOnClick\\\"]=true\\\
    },\\\
    [5]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=10,\\\
      [\\\"Width\\\"]=\\\"100%,-14\\\",\\\
      [\\\"Name\\\"]=\\\"LoadingLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"TextColour\\\"]=256,\\\
      [\\\"Text\\\"]=\\\"Loading...\\\",\\\
      [\\\"BackgroundColour\\\"]=1,\\\
      [\\\"Align\\\"]=\\\"Center\\\",\\\
      [\\\"Visible\\\"]=false\\\
    },\\\
    [6]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=\\\"100%,-3\\\",\\\
      [\\\"Name\\\"]=\\\"OptionsButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"V\\\",\\\
      [\\\"TextColour\\\"]=128,\\\
      [\\\"BackgroundColour\\\"]=1\\\
    },\\\
  },\\\
}\",\
    [ \"System/Views/centrepoint.view\" ] = \"{\\\
  [\\\"Width\\\"]=\\\"100%\\\",\\\
  [\\\"Height\\\"]=\\\"100%,-1\\\",\\\
  [\\\"Visible\\\"]=true,\\\
  [\\\"X\\\"]=1,\\\
  [\\\"Y\\\"]=2,\\\
  [\\\"BackgroundColour\\\"]=32768,\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
	  [\\\"Width\\\"]=\\\"100%\\\",\\\
	  [\\\"Height\\\"]=3,\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"BackgroundColour\\\"]=128\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=2,\\\
	  [\\\"Width\\\"]=49,\\\
      [\\\"X\\\"]=\\\"50%,-24\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"Children\\\"]={\\\
	    [1]={\\\
	      [\\\"Y\\\"]=1,\\\
	      [\\\"X\\\"]=1,\\\
	      [\\\"Type\\\"]=\\\"Button\\\",\\\
      	  [\\\"Text\\\"]=\\\"About\\\",\\\
      	  [\\\"Name\\\"]=\\\"AboutButton\\\",\\\
	      [\\\"BackgroundColour\\\"]=1,\\\
	      [\\\"TextColour\\\"]=128\\\
	    },\\\
	    [2]={\\\
	      [\\\"Y\\\"]=1,\\\
	      [\\\"X\\\"]=9,\\\
	      [\\\"Type\\\"]=\\\"Button\\\",\\\
      	  [\\\"Text\\\"]=\\\"Update\\\",\\\
      	  [\\\"Name\\\"]=\\\"UpdateButton\\\",\\\
	      [\\\"BackgroundColour\\\"]=1,\\\
	      [\\\"TextColour\\\"]=128\\\
	    },\\\
	    [3]={\\\
	      [\\\"Y\\\"]=1,\\\
	      [\\\"X\\\"]=18,\\\
	      [\\\"Type\\\"]=\\\"Button\\\",\\\
      	  [\\\"Text\\\"]=\\\"Settings\\\",\\\
      	  [\\\"Name\\\"]=\\\"SettingsButton\\\",\\\
	      [\\\"BackgroundColour\\\"]=1,\\\
	      [\\\"TextColour\\\"]=128\\\
	    },\\\
	    [4]={\\\
	      [\\\"Y\\\"]=1,\\\
	      [\\\"X\\\"]=29,\\\
	      [\\\"Type\\\"]=\\\"Button\\\",\\\
      	  [\\\"Text\\\"]=\\\"Restart\\\",\\\
      	  [\\\"Name\\\"]=\\\"RestartButton\\\",\\\
	      [\\\"BackgroundColour\\\"]=1,\\\
	      [\\\"TextColour\\\"]=128\\\
	    },\\\
	    [5]={\\\
	      [\\\"Y\\\"]=1,\\\
	      [\\\"X\\\"]=39,\\\
	      [\\\"Type\\\"]=\\\"Button\\\",\\\
      	  [\\\"Text\\\"]=\\\"Shutdown\\\",\\\
		  [\\\"Name\\\"]=\\\"ShutdownButton\\\",\\\
	      [\\\"BackgroundColour\\\"]=1,\\\
	      [\\\"TextColour\\\"]=128\\\
	    },\\\
  	  }\\\
    },\\\
    [3]={\\\
	  [\\\"Width\\\"]=\\\"100%\\\",\\\
	  [\\\"Height\\\"]=\\\"100%,-3\\\",\\\
      [\\\"Y\\\"]=4,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Type\\\"]=\\\"ScrollView\\\",\\\
      [\\\"BackgroundColour\\\"]=0,\\\
      [\\\"ScrollBarBackgroundColour\\\"]=0,\\\
      [\\\"ScrollBarColour\\\"]=8,\\\
    },\\\
    [4]={\\\
	  [\\\"Width\\\"]=\\\"100%\\\",\\\
	  [\\\"Height\\\"]=\\\"100%\\\",\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"AnimateProgramPreview\\\",\\\
      [\\\"Type\\\"]=\\\"ProgramPreview\\\",\\\
      [\\\"Minimal\\\"]=true,\\\
    },\\\
  },\\\
}\",\
    [ \"System/API/Log.lua\" ] = \"Initialise = function()\\\
	local h = fs.open('/System/OneOS.log', 'w')\\\
	h.write('-- OneOS Log --\\\\n')\\\
	h.close()\\\
end\\\
\\\
log = function(msg, state)\\\
	state = state or ''\\\
	if state ~= '' then\\\
		state = ' '..state\\\
	end\\\
	local h = fs.open('/System/OneOS.log', 'a')\\\
	h.write('['..os.clock()..state..'] '..tostring(msg)..'\\\\n')\\\
	h.close()	\\\
end\\\
\\\
e = function(msg)\\\
	log(msg, 'Error')\\\
end\\\
\\\
i = function(msg)\\\
	log(msg, 'Info')\\\
end\\\
\\\
w = function(msg)\\\
	log(msg, 'Warning')\\\
end\",\
    [ \"System/API/LegacyDrawing.lua\" ] = \"local round = function(num, idp)\\\
	local mult = 10^(idp or 0)\\\
	return math.floor(num * mult + 0.5) / mult\\\
end\\\
\\\
local _w, _h = term.getSize()\\\
\\\
Screen = {\\\
	Width = _w,\\\
	Height = _h\\\
}\\\
\\\
colours.transparent = 0\\\
colors.transparent = 0\\\
\\\
DrawCharacters = function (x, y, characters, textColour, bgColour)\\\
	WriteStringToBuffer(x, y, characters, textColour, bgColour)\\\
end\\\
\\\
DrawBlankArea = function (x, y, w, h, colour)\\\
	DrawArea (x, y, w, h, \\\" \\\", 1, colour)\\\
end\\\
\\\
DrawArea = function (x, y, w, h, character, textColour, bgColour)\\\
	--width must be greater than 1, otherwise we get a stack overflow\\\
	if w < 0 then\\\
		w = w * -1\\\
	elseif w == 0 then\\\
		w = 1\\\
	end\\\
\\\
	for ix = 1, w do\\\
		local currX = x + ix - 1\\\
		for iy = 1, h do\\\
			local currY = y + iy - 1\\\
			WriteToBuffer(currX, currY, character, textColour, bgColour)\\\
		end\\\
	end\\\
end\\\
\\\
DrawImage = function(_x,_y,tImage, w, h)\\\
	if tImage then\\\
		for y = 1, h do\\\
			if not tImage[y] then\\\
				break\\\
			end\\\
			for x = 1, w do\\\
				if not tImage[y][x] then\\\
					break\\\
				end\\\
				local bgColour = tImage[y][x]\\\
	            local textColour = tImage.textcol[y][x] or colours.white\\\
	            local char = tImage.text[y][x]\\\
	            WriteToBuffer(x+_x-1, y+_y-1, char, textColour, bgColour)\\\
			end\\\
		end\\\
	elseif w and h then\\\
		DrawBlankArea(_x, _y, w, h, colours.lightGrey)\\\
	end\\\
end\\\
\\\
--using .nft\\\
LoadImage = function(path, global)\\\
	local image = {\\\
		text = {},\\\
		textcol = {}\\\
	}\\\
	if fs.exists(path) then\\\
		local _io = io\\\
		if OneOS then\\\
			_io = OneOS.IO\\\
		end\\\
        local file = _io.open(path, \\\"r\\\")\\\
        local sLine = file:read()\\\
        local num = 1\\\
        while sLine do  \\\
            table.insert(image, num, {})\\\
            table.insert(image.text, num, {})\\\
            table.insert(image.textcol, num, {})\\\
                                        \\\
            --As we're no longer 1-1, we keep track of what index to write to\\\
            local writeIndex = 1\\\
            --Tells us if we've hit a 30 or 31 (BG and FG respectively)- next char specifies the curr colour\\\
            local bgNext, fgNext = false, false\\\
            --The current background and foreground colours\\\
            local currBG, currFG = nil,nil\\\
            for i=1,#sLine do\\\
                    local nextChar = string.sub(sLine, i, i)\\\
                    if nextChar:byte() == 30 then\\\
                            bgNext = true\\\
                    elseif nextChar:byte() == 31 then\\\
                            fgNext = true\\\
                    elseif bgNext then\\\
                            currBG = GetColour(nextChar)\\\
		                    if currBG == nil then\\\
		                    	currBG = colours.transparent\\\
		                    end\\\
                            bgNext = false\\\
                    elseif fgNext then\\\
                            currFG = GetColour(nextChar)\\\
		                    if currFG == nil or currFG == colours.transparent then\\\
		                    	currFG = colours.white\\\
		                    end\\\
                            fgNext = false\\\
                    else\\\
                            if nextChar ~= \\\" \\\" and currFG == nil then\\\
                                    currFG = colours.white\\\
                            end\\\
                            image[num][writeIndex] = currBG\\\
                            image.textcol[num][writeIndex] = currFG\\\
                            image.text[num][writeIndex] = nextChar\\\
                            writeIndex = writeIndex + 1\\\
                    end\\\
            end\\\
            num = num+1\\\
            sLine = file:read()\\\
        end\\\
        file:close()\\\
    else\\\
    	return nil\\\
	end\\\
 	return image\\\
end\\\
\\\
DrawCharactersCenter = function(x, y, w, h, characters, textColour,bgColour)\\\
	w = w or Screen.Width\\\
	h = h or Screen.Height\\\
	x = x or 0\\\
	y = y or 0\\\
	x = math.floor((w - #characters) / 2) + x\\\
	y = math.floor(h / 2) + y\\\
\\\
	DrawCharacters(x, y, characters, textColour, bgColour)\\\
end\\\
\\\
GetColour = function(hex)\\\
	if hex == ' ' then\\\
		return colours.transparent\\\
	end\\\
    local value = tonumber(hex, 16)\\\
    if not value then return nil end\\\
    value = math.pow(2,value)\\\
    return value\\\
end\\\
\\\
Clear = function (_colour)\\\
	_colour = _colour or colours.black\\\
	--[[\\\
ClearBuffer()\\\
]]--\\\
	DrawBlankArea(1, 1, Screen.Width, Screen.Height, _colour)\\\
end\\\
\\\
Buffer = {}\\\
BackBuffer = {}\\\
\\\
DrawBuffer = function()\\\
	for y,row in pairs(Buffer) do\\\
		for x,pixel in pairs(row) do\\\
			local shouldDraw = true\\\
			local hasBackBuffer = true\\\
			if BackBuffer[y] == nil or BackBuffer[y][x] == nil or #BackBuffer[y][x] ~= 3 then\\\
				hasBackBuffer = false\\\
			end\\\
			if hasBackBuffer and BackBuffer[y][x][1] == Buffer[y][x][1] and BackBuffer[y][x][2] == Buffer[y][x][2] and BackBuffer[y][x][3] == Buffer[y][x][3] then\\\
				shouldDraw = false\\\
			end\\\
			if shouldDraw then\\\
				term.setBackgroundColour(pixel[3])\\\
				term.setTextColour(pixel[2])\\\
				term.setCursorPos(x, y)\\\
				term.write(pixel[1])\\\
			end\\\
		end\\\
	end\\\
	BackBuffer = Buffer\\\
	Buffer = {}\\\
end\\\
\\\
ClearBuffer = function()\\\
	Buffer = {}\\\
end\\\
\\\
WriteStringToBuffer = function (x, y, characters, textColour,bgColour)\\\
	for i = 1, #characters do\\\
			local character = characters:sub(i,i)\\\
			WriteToBuffer(x + i - 1, y, character, textColour, bgColour)\\\
	end\\\
end\\\
\\\
WriteToBuffer = function(x, y, character, textColour,bgColour)\\\
	x = round(x)\\\
	y = round(y)\\\
	if bgColour == colours.transparent then\\\
		Buffer[y] = Buffer[y] or {}\\\
		Buffer[y][x] = Buffer[y][x] or {\\\"\\\", colours.white, colours.black}\\\
		Buffer[y][x][1] = character\\\
		Buffer[y][x][2] = textColour\\\
	else\\\
		Buffer[y] = Buffer[y] or {}\\\
		Buffer[y][x] = {character, textColour, bgColour}\\\
	end\\\
end\",\
    [ \"Programs/Sketch.program/icon\" ] = \"b0Skch\\\
b3 by \\\
b0oeed\",\
    [ \"System/API/Indexer.lua\" ] = \"--how often the computer is indexed\\\
IndexRate = 60\\\
\\\
--fs api calls will cause an index 3 seconds after they are run\\\
FSIndexRate = 3\\\
\\\
Index = {}\\\
\\\
function AddToIndex(path, index)\\\
	if string.sub(fs.getName(path),1,1) == '.' or string.sub(path,1,string.len(\\\"rom\\\"))==\\\"rom\\\" or string.sub(path,1,string.len(\\\"/rom\\\"))==\\\"/rom\\\" then\\\
		if fs.getName(path) == '.DS_Store' then\\\
			fs.delete(path)\\\
		end\\\
		return index\\\
	elseif fs.isDir(path) then\\\
		index[fs.getName(path)] = {}\\\
		for i, fileName in ipairs(fs.list(path)) do\\\
			index[fs.getName(path)] = AddToIndex(path .. '/' .. fileName, index[fs.getName(path)])\\\
		end\\\
	else\\\
		index[fs.getName(path)] = true\\\
	end\\\
	return index\\\
end\\\
\\\
function RefreshIndex()\\\
	Log.i('Refreshing Index...')\\\
	local index = AddToIndex('', {})\\\
	if index['root'] then\\\
		Index = index['root']\\\
	end\\\
	Log.i('Index refresh complete!')\\\
end\\\
\\\
function Search(filter, items, index, indexName)\\\
	if filter == '' then\\\
		return {}\\\
	end\\\
	items = items or {}\\\
	index = index or Index\\\
	indexName = indexName or ''\\\
	for name, _file in pairs(index) do\\\
		if not (name == 'rom' and indexName == '') and not (name == 'System' and indexName == '') and not (name == 'startup' and indexName == '') then\\\
			local _path = indexName..'/'..name\\\
			if name == 'root' then\\\
				_path = '/'\\\
			end\\\
			if type(_file) == 'table' and Helpers.Extension(name) ~= 'program' then\\\
				items = Search(filter, items, index[name], _path)\\\
			end\\\
			if string.find(name:lower(), filter:lower()) ~= nil then\\\
				table.insert(items, _path)\\\
			end\\\
		end\\\
	end\\\
	return items\\\
end\\\
\\\
--finds a file with the given name in a folder with the given name\\\
--used to find icon files\\\
function FindFileInFolder(file, folder, index, indexName)\\\
	index = index or Index\\\
	for name, _file in pairs(index) do\\\
		if type(_file) == 'table' then\\\
			local _name = FindFileInFolder(file, folder, index[name], name)\\\
			if _name and name ~= 'root' then\\\
				return name .. '/' .. _name\\\
			elseif _name then\\\
				return _name\\\
			end\\\
		elseif name == file and indexName == folder then\\\
			return name\\\
		end\\\
	end\\\
end\",\
    [ \"Programs/Sketch.program/startup\" ] = \"if OneOS then\\\
OneOS.ToolBarColour=colours.grey\\\
OneOS.ToolBarTextColour=colours.white\\\
end\\\
colours.transparent=-1\\\
colors.transparent=-1\\\
local e,e=term.getSize()\\\
local e=function(t,e)\\\
local e=10^(e or 0)\\\
return math.floor(t*e+.5)/e\\\
end\\\
Clipboard=OneOS.Clipboard\\\
OneOS.LoadAPI('System/API/LegacyDrawing.lua')\\\
local Drawing = LegacyDrawing\\\
UIColours={\\\
Toolbar=colours.grey,\\\
ToolbarText=colours.lightGrey,\\\
ToolbarSelected=colours.lightBlue,\\\
ControlText=colours.white,\\\
ToolbarItemTitle=colours.black,\\\
Background=colours.lightGrey,\\\
MenuBackground=colours.white,\\\
MenuText=colours.black,\\\
MenuSeparatorText=colours.grey,\\\
MenuDisabledText=colours.lightGrey,\\\
Shadow=colours.grey,\\\
TransparentBackgroundOne=colours.white,\\\
TransparentBackgroundTwo=colours.lightGrey,\\\
MenuBarActive=colours.white\\\
}\\\
Current={\\\
Artboard=nil,\\\
Layer=nil,\\\
Tool=nil,\\\
ToolSize=1,\\\
Toolbar=nil,\\\
Colour=colours.lightBlue,\\\
Menu=nil,\\\
MenuBar=nil,\\\
Window=nil,\\\
Input=nil,\\\
CursorPos={1,1},\\\
CursorColour=colours.black,\\\
InterfaceVisible=true,\\\
Selection={},\\\
SelectionDrawTimer=nil,\\\
HandDragStart={},\\\
Modified=false,\\\
}\\\
local t=false\\\
function PrintCentered(e,t)\\\
local a,o=term.getSize()\\\
x=math.ceil(math.ceil((a/2)-(#e/2)),0)+1\\\
term.setCursorPos(x,t)\\\
print(e)\\\
end\\\
function DoVanillaClose()\\\
term.setBackgroundColour(colours.black)\\\
term.setTextColour(colours.white)\\\
term.clear()\\\
term.setCursorPos(1,1)\\\
PrintCentered(\\\"Thanks for using Sketch!\\\",(Drawing.Screen.Height/2)-1)\\\
term.setTextColour(colours.lightGrey)\\\
PrintCentered(\\\"Photoshop Inspired Image Editor for ComputerCraft\\\",(Drawing.Screen.Height/2))\\\
term.setTextColour(colours.white)\\\
PrintCentered(\\\"(c) oeed 2013 - 2014\\\",(Drawing.Screen.Height/2)+3)\\\
term.setCursorPos(1,Drawing.Screen.Height)\\\
error('',0)\\\
end\\\
function Close()\\\
if t or not Current.Artboard or not Current.Modified then\\\
if not OneOS then\\\
DoVanillaClose()\\\
end\\\
return true\\\
else\\\
local e=ButtonDialougeWindow:Initialise('Quit Sketch?','You have unsaved changes, do you want to quit anyway?','Quit','Cancel',function(e,t)\\\
if t then\\\
if OneOS then\\\
OneOS.Close(true)\\\
else\\\
DoVanillaClose()\\\
end\\\
end\\\
e:Close()\\\
Draw()\\\
end):Show()\\\
os.queueEvent('mouse_click',1,e.X,e.Y)\\\
return false\\\
end\\\
end\\\
if OneOS then\\\
OneOS.CanClose=function()\\\
return Close()\\\
end\\\
end\\\
Lists={\\\
Artboards={},\\\
Interface={\\\
Toolbars={}\\\
}\\\
}\\\
Events={\\\
}\\\
function SetColour(e)\\\
Current.Colour=e\\\
Draw()\\\
end\\\
function SetTool(e)\\\
if e and e.Select and e:Select()then\\\
Current.Input=nil\\\
Current.Tool=e\\\
return true\\\
end\\\
return false\\\
end\\\
function GetAbsolutePosition(e)\\\
local e=e\\\
local a=0\\\
local o=1\\\
local t=1\\\
while true do\\\
o=o+e.X-1\\\
t=t+e.Y-1\\\
if not e.Parent then\\\
return{X=o,Y=t}\\\
end\\\
e=e.Parent\\\
if a>32 then\\\
return{X=1,Y=1}\\\
end\\\
a=a+1\\\
end\\\
end\\\
Pixel={\\\
TextColour=colours.black,\\\
BackgroundColour=colours.white,\\\
Character=\\\" \\\",\\\
Layer=nil,\\\
Draw=function(e,a,t)\\\
if e.BackgroundColour~=colours.transparent or e.Character~=' 'then\\\
Drawing.WriteToBuffer(e.Layer.Artboard.X+a-1,e.Layer.Artboard.Y+t-1,e.Character,e.TextColour,e.BackgroundColour)\\\
end\\\
end,\\\
Initialise=function(t,n,i,o,a)\\\
local e={}\\\
setmetatable(e,{__index=t})\\\
e.TextColour=n or t.TextColour\\\
e.BackgroundColour=i or t.BackgroundColour\\\
e.Character=o or t.Character\\\
e.Layer=a\\\
return e\\\
end,\\\
Set=function(e,t,a,o)\\\
e.TextColour=t or e.TextColour\\\
e.BackgroundColour=a or e.BackgroundColour\\\
e.Character=o or e.Character\\\
end\\\
}\\\
Layer={\\\
Name=\\\"\\\",\\\
Pixels={\\\
},\\\
Artboard=nil,\\\
BackgroundColour=colours.white,\\\
Visible=true,\\\
Index=1,\\\
Draw=function(e)\\\
if e.Visible then\\\
for a=1,e.Artboard.Width do\\\
for t=1,e.Artboard.Height do\\\
e.Pixels[a][t]:Draw(a,t)\\\
end\\\
end\\\
end\\\
end,\\\
Remove=function(e)\\\
for t,e in ipairs(e.Artboard.Layers)do\\\
if e==Current.Layer then\\\
Current.Artboard.Layers[t]=nil\\\
Current.Layer=Current.Artboard.Layers[1]\\\
ModuleNamed('Layers'):Update()\\\
end\\\
end\\\
end,\\\
Initialise=function(o,i,n,t,s,a)\\\
local e={}\\\
setmetatable(e,{__index=o})\\\
e.Name=i\\\
e.Pixels={}\\\
e.BackgroundColour=n\\\
e.Artboard=t\\\
e.Index=s or#t.Layers+1\\\
if not a then\\\
e:MakeAllBlankPixels()\\\
else\\\
e:MakeAllBlankPixels()\\\
for a,t in ipairs(a)do\\\
for o,t in ipairs(t)do\\\
e:SetPixel(a,o,t.TextColour,t.BackgroundColour,t.Character)\\\
end\\\
end\\\
end\\\
return e\\\
end,\\\
SetPixel=function(a,e,t,n,o,i)\\\
n=n or Current.Colour\\\
o=o or Current.Colour\\\
i=i or\\\" \\\"\\\
if e<1 or t<1 or e>a.Artboard.Width or t>a.Artboard.Height then\\\
return\\\
end\\\
if a.Pixels[e][t]then\\\
a.Pixels[e][t]:Set(n,o,i)\\\
a.Pixels[e][t]:Draw(e,t)\\\
end\\\
end,\\\
MakePixel=function(e,a,o,t)\\\
t=t or e.BackgroundColour\\\
e.Pixels[a][o]=Pixel:Initialise(nil,t,nil,e)\\\
end,\\\
MakeColumn=function(e,t)\\\
e.Pixels[t]={}\\\
end,\\\
MakeAllBlankPixels=function(e)\\\
for t=1,e.Artboard.Width do\\\
if not e.Pixels[t]then\\\
e:MakeColumn(t)\\\
end\\\
for a=1,e.Artboard.Height do\\\
if not e.Pixels[t][a]then\\\
e:MakePixel(t,a)\\\
end\\\
end\\\
end\\\
end,\\\
PixelsInSelection=function(i,s)\\\
local t={}\\\
if Current.Selection and Current.Selection[1]and Current.Selection[2]~=nil then\\\
local e=Current.Selection[1]\\\
local a=Current.Selection[2]\\\
local o=a-e\\\
local a=e.x\\\
local n=e.y\\\
for e=1,o.x+1 do\\\
for o=1,o.y+1 do\\\
if not t[e]then\\\
t[e]={}\\\
end\\\
if not i.Pixels[a+e-1]or not i.Pixels[a+e-1][n+o-1]then\\\
break\\\
end\\\
local i=i.Pixels[a+e-1][n+o-1]\\\
t[e][o]=Pixel:Initialise(i.TextColour,i.BackgroundColour,i.Character,Current.Layer)\\\
if s then\\\
Current.Layer:SetPixel(a+e-1,n+o-1,nil,Current.Layer.BackgroundColour,nil)\\\
end\\\
end\\\
end\\\
end\\\
return t\\\
end,\\\
EraseSelection=function(e)\\\
if Current.Selection and Current.Selection[1]and Current.Selection[2]~=nil then\\\
local e=Current.Selection[1]\\\
local t=Current.Selection[2]\\\
local t=t-e\\\
local o=e.x\\\
local i=e.y\\\
for a=1,t.x+1 do\\\
for e=1,t.y+1 do\\\
Current.Layer:SetPixel(o+a-1,i+e-1,nil,Current.Layer.BackgroundColour,nil)\\\
end\\\
end\\\
end\\\
end,\\\
InsertPixels=function(t,e)\\\
local o=Current.Selection[1].x\\\
local t=Current.Selection[1].y\\\
for a,e in ipairs(e)do\\\
for i,e in ipairs(e)do\\\
Current.Layer:SetPixel(o+a-1,t+i-1,e.TextColour,e.BackgroundColour,e.Character)\\\
end\\\
end\\\
end\\\
}\\\
Artboard={\\\
X=0,\\\
Y=0,\\\
Name=\\\"\\\",\\\
Path=\\\"\\\",\\\
Width=1,\\\
Height=1,\\\
Layers={},\\\
Format=nil,\\\
SelectionIsBlack=true,\\\
Draw=function(e)\\\
Drawing.DrawBlankArea(e.X+1,e.Y+1,e.Width,e.Height,UIColours.Shadow)\\\
local t\\\
for a=1,e.Width do\\\
t=a%2\\\
if t==1 then\\\
t=true\\\
else\\\
t=false\\\
end\\\
for o=1,e.Height do\\\
if t then\\\
Drawing.WriteToBuffer(e.X+a-1,e.Y+o-1,\\\":\\\",UIColours.TransparentBackgroundTwo,UIColours.TransparentBackgroundOne)\\\
else\\\
Drawing.WriteToBuffer(e.X+a-1,e.Y+o-1,\\\":\\\",UIColours.TransparentBackgroundOne,UIColours.TransparentBackgroundTwo)\\\
end\\\
t=not t\\\
end\\\
end\\\
for t,e in ipairs(e.Layers)do\\\
e:Draw()\\\
end\\\
if Current.Selection and Current.Selection[1]and Current.Selection[2]~=nil then\\\
local t=Current.Selection[1]\\\
local a=Current.Selection[2]\\\
local a=a-t\\\
local i=e.SelectionIsBlack\\\
local function o()\\\
local e=colours.white\\\
if i then\\\
e=colours.black\\\
end\\\
i=not i\\\
return e\\\
end\\\
function horizontal(i)\\\
Drawing.WriteToBuffer(e.X-1+t.x,e.Y-1+i,'+',o(),colours.transparent)\\\
if a.x>0 then\\\
for a=1,a.x-1 do\\\
Drawing.WriteToBuffer(e.X-1+t.x+a,e.Y-1+i,'-',o(),colours.transparent)\\\
end\\\
else\\\
for a=1,(-1*a.x)-1 do\\\
Drawing.WriteToBuffer(e.X-1+t.x-a,e.Y-1+i,'-',o(),colours.transparent)\\\
end\\\
end\\\
Drawing.WriteToBuffer(e.X-1+t.x+a.x,e.Y-1+i,'+',o(),colours.transparent)\\\
end\\\
function vertical(i)\\\
if a.y<0 then\\\
for a=1,(-1*a.y)-1 do\\\
Drawing.WriteToBuffer(e.X-1+i,e.Y-1+t.y-a,'|',o(),colours.transparent)\\\
end\\\
else\\\
for a=1,a.y-1 do\\\
Drawing.WriteToBuffer(e.X-1+i,e.Y-1+t.y+a,'|',o(),colours.transparent)\\\
end\\\
end\\\
end\\\
horizontal(t.y)\\\
vertical(t.x)\\\
horizontal(t.y+a.y)\\\
vertical(t.x+a.x)\\\
end\\\
end,\\\
Initialise=function(r,n,i,a,o,s,h,t)\\\
local e={}\\\
setmetatable(e,{__index=r})\\\
e.Y=3\\\
e.X=2\\\
e.Name=n\\\
e.Path=i\\\
e.Width=a\\\
e.Height=o\\\
e.Format=s\\\
e.Layers={}\\\
if not t then\\\
e:MakeLayer('Background',h)\\\
else\\\
for a,t in ipairs(t)do\\\
e:MakeLayer(t.Name,t.BackgroundColour,t.Index,t.Pixels)\\\
e.Layers[a].Visible=t.Visible\\\
end\\\
Current.Layer=e.Layers[#e.Layers]\\\
end\\\
return e\\\
end,\\\
Resize=function(t,i,n,a,o)\\\
t.Height=t.Height+i+n\\\
t.Width=t.Width+a+o\\\
for s,e in ipairs(t.Layers)do\\\
if a<0 then\\\
for t=1,-a do\\\
table.remove(e.Pixels,1)\\\
end\\\
end\\\
if o<0 then\\\
for t=1,-o do\\\
table.remove(e.Pixels,#e.Pixels)\\\
end\\\
end\\\
for a=1,a do\\\
table.insert(e.Pixels,1,{})\\\
for t=1,t.Height do\\\
e:MakePixel(1,t)\\\
end\\\
end\\\
for a=1,o do\\\
table.insert(e.Pixels,{})\\\
for t=1,t.Height do\\\
e:MakePixel(#e.Pixels,t)\\\
end\\\
end\\\
for a=1,i do\\\
for t=1,t.Width do\\\
table.insert(e.Pixels[t],1,{})\\\
e:MakePixel(t,1)\\\
end\\\
end\\\
for a=1,n do\\\
for t=1,t.Width do\\\
table.insert(e.Pixels[t],{})\\\
e:MakePixel(t,#e.Pixels[t])\\\
end\\\
end\\\
if i<0 then\\\
for a=1,-i do\\\
for t=1,t.Width do\\\
table.remove(e.Pixels[t],1)\\\
end\\\
end\\\
end\\\
if n<0 then\\\
for a=1,-n do\\\
for t=1,t.Width do\\\
table.remove(e.Pixels[t],#e.Pixels[t])\\\
end\\\
end\\\
end\\\
end\\\
end,\\\
MakeLayer=function(a,e,t,i,o)\\\
t=t or colours.white\\\
e=e or\\\"Layer\\\"\\\
local e=Layer:Initialise(e,t,a,i,o)\\\
table.insert(a.Layers,e)\\\
Current.Layer=e\\\
ModuleNamed('Layers'):Update()\\\
return e\\\
end,\\\
New=function(o,a,e,t,i,s,n,h)\\\
local e=o:Initialise(a,e,t,i,s,n,h)\\\
table.insert(Lists.Artboards,e)\\\
Current.Artboard=e\\\
return e\\\
end,\\\
Save=function(e,t)\\\
Current.Artboard=e\\\
t=t or e.Path\\\
local a=io.open\\\
if OneOS then\\\
a=OneOS.IO.open\\\
end\\\
local a=a(t,\\\"w\\\",true)\\\
if e.Format=='.skch'then\\\
a:write(textutils.serialize(SaveSKCH()))\\\
else\\\
local t={}\\\
if e.Format=='.nfp'then\\\
t=SaveNFP()\\\
elseif e.Format=='.nft'then\\\
t=SaveNFT()\\\
end\\\
for t,e in ipairs(t)do\\\
a:write(e..\\\"\\\\n\\\")\\\
end\\\
end\\\
a:close()\\\
Current.Modified=false\\\
end,\\\
Click=function(i,e,t,o,a)\\\
if Current.Tool and Current.Layer and Current.Layer.Visible then\\\
Current.Tool:Use(t,o,e,a)\\\
Current.Modified=true\\\
return true\\\
end\\\
end\\\
}\\\
Toolbar={\\\
X=0,\\\
Y=0,\\\
Width=0,\\\
ExpandedWidth=14,\\\
ClosedWidth=2,\\\
Height=0,\\\
Expanded=true,\\\
ToolbarItems={},\\\
AbsolutePosition=function(e)\\\
return{X=e.X,Y=e.Y}\\\
end,\\\
Draw=function(e)\\\
e:CalculateToolbarItemPositions()\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,e.Height,UIColours.Toolbar)\\\
for t,e in ipairs(e.ToolbarItems)do\\\
e:Draw()\\\
end\\\
end,\\\
Initialise=function(o,t,a)\\\
local e={}\\\
setmetatable(e,{__index=o})\\\
e.Expanded=a\\\
if a then\\\
e.Width=e.ExpandedWidth\\\
else\\\
e.Width=e.ClosedWidth\\\
end\\\
if t=='right'then\\\
e.X=Drawing.Screen.Width-e.Width+1\\\
end\\\
if t=='right'or t=='left'then\\\
e.Height=Drawing.Screen.Width\\\
end\\\
e.Y=1\\\
return e\\\
end,\\\
AddToolbarItem=function(e,t)\\\
table.insert(e.ToolbarItems,t)\\\
e:CalculateToolbarItemPositions()\\\
end,\\\
CalculateToolbarItemPositions=function(t)\\\
local e=1\\\
for a,t in ipairs(t.ToolbarItems)do\\\
t.Y=e\\\
e=e+t.Height\\\
end\\\
end,\\\
Update=function(e)\\\
for t,e in ipairs(e.ToolbarItems)do\\\
if e.Module.Update then\\\
e.Module:Update(e)\\\
end\\\
end\\\
end,\\\
New=function(t,e,a)\\\
local e=t:Initialise(e,a)\\\
table.insert(Lists.Interface.Toolbars,e)\\\
return e\\\
end,\\\
Click=function(e,e,e,e)\\\
return false\\\
end\\\
}\\\
ToolbarItem={\\\
X=0,\\\
Y=0,\\\
Width=0,\\\
Height=0,\\\
ExpandedHeight=5,\\\
Expanded=true,\\\
Toolbar=nil,\\\
Title=\\\"\\\",\\\
MenuIcon=\\\"=\\\",\\\
ExpandedIcon=\\\"+\\\",\\\
ContractIcon=\\\"-\\\",\\\
ContentView=nil,\\\
Module=nil,\\\
MenuItems=nil,\\\
Draw=function(e)\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,1,UIColours.ToolbarItemTitle)\\\
Drawing.DrawCharacters(e.X+1,e.Y,e.Title,UIColours.ToolbarText,UIColours.ToolbarItemTitle)\\\
Drawing.DrawCharacters(e.X+e.Width-1,e.Y,e.MenuIcon,UIColours.ToolbarText,UIColours.ToolbarItemTitle)\\\
local t=e.ContractIcon\\\
if not e.Expanded then\\\
t=e.ExpandedIcon\\\
end\\\
if e.Expanded and e.ContentView then\\\
e.ContentView:Draw()\\\
end\\\
Drawing.DrawCharacters(e.X+e.Width-2,e.Y,t,UIColours.ToolbarText,UIColours.ToolbarItemTitle)\\\
end,\\\
Initialise=function(n,a,o,s,t,i)\\\
local e={}\\\
setmetatable(e,{__index=n})\\\
e.Expanded=s\\\
e.Title=a.Title\\\
e.Width=t.Width\\\
e.Height=o or 5\\\
e.Module=a\\\
e.MenuItems=i or{}\\\
table.insert(e.MenuItems,\\\
{\\\
Title='Shrink',\\\
Click=function()\\\
e:ToggleExpanded()\\\
end\\\
})\\\
e.ExpandedHeight=o or 5\\\
e.Y=1\\\
e.X=t.X\\\
e.ContentView=ContentView:Initialise(1,2,e.Width,e.Height-1,nil,e)\\\
e.Toolbar=t\\\
return e\\\
end,\\\
ToggleExpanded=function(e)\\\
e.Expanded=not e.Expanded\\\
if e.Expanded then\\\
e.Height=e.ExpandedHeight\\\
else\\\
e.Height=1\\\
end\\\
end,\\\
Click=function(e,n,a,t)\\\
local o=GetAbsolutePosition(e)\\\
if a==e.Width and t==1 then\\\
local i=\\\"Shrink\\\"\\\
if not e.Expanded then\\\
i=\\\"Expand\\\"\\\
end\\\
e.MenuItems[#e.MenuItems].Title=i\\\
Menu:New(o.X+a,o.Y+t,e.MenuItems,e)\\\
return true\\\
elseif a==e.Width-1 and t==1 then\\\
e:ToggleExpanded()\\\
return true\\\
elseif t~=1 then\\\
return e.ContentView:Click(n,a-e.ContentView.X+1,t-e.ContentView.Y+1)\\\
end\\\
return false\\\
end\\\
}\\\
ContentView={\\\
X=1,\\\
Y=1,\\\
Width=0,\\\
Height=0,\\\
Parent=nil,\\\
Views={},\\\
AbsolutePosition=function(e)\\\
return e.Parent:AbsolutePosition()\\\
end,\\\
Draw=function(e)\\\
for t,e in ipairs(e.Views)do\\\
e:Draw()\\\
end\\\
end,\\\
Initialise=function(t,a,i,h,s,n,o)\\\
local e={}\\\
setmetatable(e,{__index=t})\\\
e.Width=h\\\
e.Height=s\\\
e.Y=i\\\
e.X=a\\\
e.Views=n or{}\\\
e.Parent=o\\\
return e\\\
end,\\\
Click=function(e,t,a,o)\\\
for i,e in pairs(e.Views)do\\\
if DoClick(e,t,a,o)then\\\
return true\\\
end\\\
end\\\
end\\\
}\\\
Button={\\\
X=1,\\\
Y=1,\\\
Width=0,\\\
Height=0,\\\
BackgroundColour=colours.lightGrey,\\\
TextColour=colours.white,\\\
ActiveBackgroundColour=colours.lightGrey,\\\
Text=\\\"\\\",\\\
Parent=nil,\\\
_Click=nil,\\\
Toggle=nil,\\\
AbsolutePosition=function(e)\\\
return e.Parent:AbsolutePosition()\\\
end,\\\
Draw=function(e)\\\
local t=e.BackgroundColour\\\
local o=e.TextColour\\\
if type(t)=='function'then\\\
t=t()\\\
end\\\
if e.Toggle then\\\
o=UIColours.MenuBarActive\\\
t=e.ActiveBackgroundColour\\\
end\\\
local a=GetAbsolutePosition(e)\\\
Drawing.DrawBlankArea(a.X,a.Y,e.Width,e.Height,t)\\\
Drawing.DrawCharactersCenter(a.X,a.Y,e.Width,e.Height,e.Text,o,t)\\\
end,\\\
Initialise=function(h,r,l,d,t,u,s,o,a,i,n,c)\\\
local e={}\\\
setmetatable(e,{__index=h})\\\
t=t or 1\\\
e.Width=d or#a+2\\\
e.Height=t\\\
e.Y=l\\\
e.X=r\\\
e.Text=a or\\\"\\\"\\\
e.BackgroundColour=u or colours.lightGrey\\\
e.TextColour=i or colours.white\\\
e.ActiveBackgroundColour=c or colours.lightGrey\\\
e.Parent=s\\\
e._Click=o\\\
e.Toggle=n\\\
return e\\\
end,\\\
Click=function(e,a,t,o)\\\
if e._Click then\\\
if e:_Click(a,t,o,not e.Toggle)~=false and e.Toggle~=nil then\\\
e.Toggle=not e.Toggle\\\
Draw()\\\
end\\\
return true\\\
else\\\
return false\\\
end\\\
end\\\
}\\\
TextBox={\\\
X=1,\\\
Y=1,\\\
Width=0,\\\
Height=0,\\\
BackgroundColour=colours.lightGrey,\\\
TextColour=colours.black,\\\
Parent=nil,\\\
TextInput=nil,\\\
AbsolutePosition=function(e)\\\
return e.Parent:AbsolutePosition()\\\
end,\\\
Draw=function(e)\\\
local t=GetAbsolutePosition(e)\\\
Drawing.DrawBlankArea(t.X,t.Y,e.Width,e.Height,e.BackgroundColour)\\\
local a=e.TextInput.Value\\\
if#a>(e.Width-2)then\\\
a=a:sub(#a-(e.Width-3))\\\
if Current.Input==e.TextInput then\\\
Current.CursorPos={t.X+1+e.Width-2,t.Y}\\\
end\\\
else\\\
if Current.Input==e.TextInput then\\\
Current.CursorPos={t.X+1+e.TextInput.CursorPos,t.Y}\\\
end\\\
end\\\
Drawing.DrawCharacters(t.X+1,t.Y,a,e.TextColour,e.BackgroundColour)\\\
term.setCursorBlink(true)\\\
Current.CursorColour=e.TextColour\\\
end,\\\
Initialise=function(r,h,u,d,t,l,o,n,s,a,i)\\\
local e={}\\\
setmetatable(e,{__index=r})\\\
t=t or 1\\\
e.Width=d or#o+2\\\
e.Height=t\\\
e.Y=u\\\
e.X=h\\\
e.TextInput=TextInput:Initialise(o or'',function(e)\\\
if a then\\\
a(e)\\\
end\\\
Draw()\\\
end,i)\\\
e.BackgroundColour=n or colours.lightGrey\\\
e.TextColour=s or colours.black\\\
e.Parent=l\\\
return e\\\
end,\\\
Click=function(e,t,t,t)\\\
Current.Input=e.TextInput\\\
e:Draw()\\\
end\\\
}\\\
TextInput={\\\
Value=\\\"\\\",\\\
Change=nil,\\\
CursorPos=nil,\\\
Numerical=false,\\\
Initialise=function(o,t,a,i)\\\
local e={}\\\
setmetatable(e,{__index=o})\\\
e.Value=t\\\
e.Change=a\\\
e.CursorPos=#t\\\
e.Numerical=i\\\
return e\\\
end,\\\
Char=function(e,t)\\\
if e.Numerical then\\\
t=tostring(tonumber(t))\\\
end\\\
if t=='nil'then\\\
return\\\
end\\\
e.Value=string.sub(e.Value,1,e.CursorPos)..t..string.sub(e.Value,e.CursorPos+1)\\\
e.CursorPos=e.CursorPos+1\\\
e.Change(key)\\\
end,\\\
Key=function(e,t)\\\
if t==keys.enter then\\\
e.Change(t)\\\
elseif t==keys.left then\\\
if e.CursorPos>0 then\\\
e.CursorPos=e.CursorPos-1\\\
e.Change(t)\\\
end\\\
elseif t==keys.right then\\\
if e.CursorPos<string.len(e.Value)then\\\
e.CursorPos=e.CursorPos+1\\\
e.Change(t)\\\
end\\\
elseif t==keys.backspace then\\\
if e.CursorPos>0 then\\\
e.Value=string.sub(e.Value,1,e.CursorPos-1)..string.sub(e.Value,e.CursorPos+1)\\\
e.CursorPos=e.CursorPos-1\\\
end\\\
e.Change(t)\\\
elseif t==keys.home then\\\
e.CursorPos=0\\\
e.Change(t)\\\
elseif t==keys.delete then\\\
if e.CursorPos<string.len(e.Value)then\\\
e.Value=string.sub(e.Value,1,e.CursorPos)..string.sub(e.Value,e.CursorPos+2)\\\
e.Change(t)\\\
end\\\
elseif t==keys[\\\"end\\\"]then\\\
e.CursorPos=string.len(e.Value)\\\
e.Change(t)\\\
end\\\
end\\\
}\\\
LayerItem={\\\
X=1,\\\
Y=1,\\\
Parent=nil,\\\
Layer=nil,\\\
Draw=function(e)\\\
e.Y=e.Layer.Index\\\
local t=GetAbsolutePosition(e)\\\
local a=colours.lightGrey\\\
if Current.Layer==e.Layer then\\\
a=colours.white\\\
end\\\
Drawing.DrawBlankArea(t.X,t.Y,e.Width,e.Height,UIColours.Toolbar)\\\
Drawing.DrawCharacters(t.X+3,t.Y,e.Layer.Name,a,UIColours.Toolbar)\\\
if e.Layer.Visible then\\\
Drawing.DrawCharacters(t.X+1,t.Y,\\\"@\\\",a,UIColours.Toolbar)\\\
else\\\
Drawing.DrawCharacters(t.X+1,t.Y,\\\"X\\\",a,UIColours.Toolbar)\\\
end\\\
end,\\\
Initialise=function(o,a,t)\\\
local e={}\\\
setmetatable(e,{__index=o})\\\
e.Width=t.Width\\\
e.Height=1\\\
e.Y=1\\\
e.X=1\\\
e.Layer=a\\\
e.Parent=t\\\
return e\\\
end,\\\
Click=function(e,a,t,a)\\\
if t==2 then\\\
e.Layer.Visible=not e.Layer.Visible\\\
else\\\
Current.Layer=e.Layer\\\
end\\\
return true\\\
end\\\
}\\\
Menu={\\\
X=0,\\\
Y=0,\\\
Width=0,\\\
Height=0,\\\
Owner=nil,\\\
Items={},\\\
RemoveTop=false,\\\
Draw=function(e)\\\
Drawing.DrawBlankArea(e.X+1,e.Y+1,e.Width,e.Height,UIColours.Shadow)\\\
if not e.RemoveTop then\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,e.Height,UIColours.MenuBackground)\\\
for a,t in ipairs(e.Items)do\\\
if t.Separator then\\\
Drawing.DrawArea(e.X,e.Y+a,e.Width,1,'-',colours.grey,UIColours.MenuBackground)\\\
else\\\
local o=UIColours.MenuText\\\
if(t.Enabled and type(t.Enabled)=='function'and t.Enabled()==false)or t.Enabled==false then\\\
o=UIColours.MenuDisabledText\\\
end\\\
Drawing.DrawCharacters(e.X+1,e.Y+a,t.Title,o,UIColours.MenuBackground)\\\
end\\\
end\\\
else\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,e.Height,UIColours.MenuBackground)\\\
for o,t in ipairs(e.Items)do\\\
if t.Separator then\\\
Drawing.DrawArea(e.X,e.Y+o-1,e.Width,1,'-',colours.grey,UIColours.MenuBackground)\\\
else\\\
local a=UIColours.MenuText\\\
if(t.Enabled and type(t.Enabled)=='function'and t.Enabled()==false)or t.Enabled==false then\\\
a=UIColours.MenuDisabledText\\\
end\\\
Drawing.DrawCharacters(e.X+1,e.Y+o-1,t.Title,a,UIColours.MenuBackground)\\\
Drawing.DrawCharacters(e.X-1+e.Width-#t.KeyName,e.Y+o-1,t.KeyName,a,UIColours.MenuBackground)\\\
end\\\
end\\\
end\\\
end,\\\
NameForKey=function(t,e)\\\
if e==keys.leftCtrl then\\\
return'^'\\\
elseif e==keys.tab then\\\
return'Tab'\\\
elseif e==keys.delete then\\\
return'Delete'\\\
elseif e==keys.n then\\\
return'N'\\\
elseif e==keys.s then\\\
return'S'\\\
elseif e==keys.o then\\\
return'O'\\\
elseif e==keys.z then\\\
return'Z'\\\
elseif e==keys.y then\\\
return'Y'\\\
elseif e==keys.c then\\\
return'C'\\\
elseif e==keys.x then\\\
return'X'\\\
elseif e==keys.v then\\\
return'V'\\\
elseif e==keys.r then\\\
return'R'\\\
elseif e==keys.l then\\\
return'L'\\\
elseif e==keys.t then\\\
return'T'\\\
elseif e==keys.h then\\\
return'H'\\\
elseif e==keys.e then\\\
return'E'\\\
elseif e==keys.p then\\\
return'P'\\\
elseif e==keys.f then\\\
return'F'\\\
elseif e==keys.m then\\\
return'M'\\\
else\\\
return'?'\\\
end\\\
end,\\\
Initialise=function(h,o,a,t,n,s)\\\
local e={}\\\
setmetatable(e,{__index=h})\\\
if not n then\\\
return\\\
end\\\
local i={}\\\
for e,a in ipairs(t)do\\\
t[e].KeyName=''\\\
if a.Keys then\\\
for o,a in ipairs(a.Keys)do\\\
t[e].KeyName=t[e].KeyName..h:NameForKey(a)\\\
end\\\
end\\\
if t[e].KeyName~=''then\\\
table.insert(i,t[e].KeyName)\\\
end\\\
end\\\
local i=LongestString(i)\\\
if i>0 then\\\
i=i+2\\\
end\\\
e.Width=LongestString(t,'Title')+2+i\\\
if e.Width<10 then\\\
e.Width=10\\\
end\\\
e.Height=#t+2\\\
e.RemoveTop=s or false\\\
if s then\\\
e.Height=e.Height-1\\\
end\\\
if a<1 then\\\
a=1\\\
end\\\
if o<1 then\\\
o=1\\\
end\\\
if a+e.Height>Drawing.Screen.Height+1 then\\\
a=Drawing.Screen.Height-e.Height\\\
end\\\
if o+e.Width>Drawing.Screen.Width+1 then\\\
o=Drawing.Screen.Width-e.Width\\\
end\\\
e.Y=a\\\
e.X=o\\\
e.Items=t\\\
e.Owner=n\\\
return e\\\
end,\\\
New=function(n,o,a,t,e,i)\\\
if Current.Menu and Current.Menu.Owner==e then\\\
Current.Menu=nil\\\
return\\\
end\\\
local e=n:Initialise(o,a,t,e,i)\\\
Current.Menu=e\\\
return e\\\
end,\\\
Click=function(e,t,t,a)\\\
local t=a-1\\\
if e.RemoveTop then\\\
t=a\\\
end\\\
if t>=1 and a<e.Height then\\\
if not((e.Items[t].Enabled and type(e.Items[t].Enabled)=='function'and e.Items[t].Enabled()==false)or e.Items[t].Enabled==false)and e.Items[t].Click then\\\
e.Items[t]:Click()\\\
if Current.Menu.Owner and Current.Menu.Owner.Toggle then\\\
Current.Menu.Owner.Toggle=false\\\
end\\\
Current.Menu=nil\\\
e=nil\\\
end\\\
return true\\\
end\\\
end\\\
}\\\
MenuBar={\\\
X=1,\\\
Y=1,\\\
Width=Drawing.Screen.Width,\\\
Height=1,\\\
MenuBarItems={},\\\
AbsolutePosition=function(e)\\\
return{X=e.X,Y=e.Y}\\\
end,\\\
Draw=function(e)\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,e.Height,UIColours.Toolbar)\\\
for t,e in ipairs(e.MenuBarItems)do\\\
e:Draw()\\\
end\\\
end,\\\
Initialise=function(a,t)\\\
local e={}\\\
setmetatable(e,{__index=a})\\\
e.X=1\\\
e.Y=1\\\
e.MenuBarItems=t\\\
return e\\\
end,\\\
AddToolbarItem=function(e,t)\\\
table.insert(e.ToolbarItems,t)\\\
e:CalculateToolbarItemPositions()\\\
end,\\\
CalculateToolbarItemPositions=function(t)\\\
local e=1\\\
for a,t in ipairs(t.ToolbarItems)do\\\
t.Y=e\\\
e=e+t.Height\\\
end\\\
end,\\\
Click=function(e,a,t,o)\\\
for o,e in ipairs(e.MenuBarItems)do\\\
if e.X<=t and e.X+e.Width>t then\\\
if e:Click(e,a,t-e.X+1,1)then\\\
break\\\
end\\\
end\\\
end\\\
return false\\\
end\\\
}\\\
Modules={\\\
{\\\
Title=\\\"Colours\\\",\\\
ToolbarItem=nil,\\\
Initialise=function(e)\\\
e.ToolbarItem=ToolbarItem:Initialise(e,nil,true,Current.Toolbar)\\\
local n={}\\\
local a=0\\\
local t=8\\\
local o={\\\
colours.brown,\\\
colours.yellow,\\\
colours.orange,\\\
colours.red,\\\
colours.green,\\\
colours.lime,\\\
colours.magenta,\\\
colours.pink,\\\
colours.purple,\\\
colours.blue,\\\
colours.cyan,\\\
colours.lightBlue,\\\
colours.lightGrey,\\\
colours.grey,\\\
colours.black,\\\
colours.white\\\
}\\\
for o,i in pairs(o)do\\\
if type(i)=='number'and i~=-1 then\\\
a=a+1\\\
local o=math.floor(a/(t/2))\\\
local a=(a%(t/2))\\\
if a==0 then\\\
a=(t/2)\\\
o=o-1\\\
end\\\
table.insert(n,\\\
{\\\
X=a*2-2+e.ToolbarItem.Width-t,\\\
Y=o+1,\\\
Width=2,\\\
Height=1,\\\
BackgroundColour=i,\\\
Click=function(e,t,t,t)\\\
SetColour(e.BackgroundColour)\\\
end\\\
}\\\
)\\\
end\\\
end\\\
for a,t in ipairs(n)do\\\
table.insert(e.ToolbarItem.ContentView.Views,\\\
Button:Initialise(t.X,t.Y,t.Width,t.Height,t.BackgroundColour,e.ToolbarItem.ContentView,t.Click))\\\
end\\\
table.insert(e.ToolbarItem.ContentView.Views,\\\
Button:Initialise(1,1,4,3,function()return Current.Colour end,e.ToolbarItem.ContentView,nil))\\\
Current.Toolbar:AddToolbarItem(e.ToolbarItem)\\\
end\\\
},\\\
{\\\
Title=\\\"Tools\\\",\\\
ToolbarItem=nil,\\\
Update=function(t)\\\
for a,e in ipairs(t.ToolbarItem.ContentView.Views)do\\\
if(Current.Tool and Current.Tool.Name==e.Text)then\\\
e.TextColour=colours.white\\\
else\\\
e.TextColour=colours.lightGrey\\\
end\\\
end\\\
t.ToolbarItem.ContentView.Views[1].Text='Size: '..Current.ToolSize\\\
end,\\\
Initialise=function(e)\\\
e.ToolbarItem=ToolbarItem:Initialise(e,#Tools+2,true,Current.Toolbar,\\\
{{\\\
Title=\\\"Change Tool Size\\\",\\\
Click=function()\\\
DisplayToolSizeWindow()\\\
end,\\\
}})\\\
table.insert(e.ToolbarItem.ContentView.Views,Button:Initialise(1,1,e.ToolbarItem.Width,1,UIColours.Toolbar,e.ToolbarItem.ContentView,DisplayToolSizeWindow,'Size: '..Current.ToolSize))\\\
local t=2\\\
for o,a in ipairs(Tools)do\\\
table.insert(e.ToolbarItem.ContentView.Views,Button:Initialise(1,t,e.ToolbarItem.Width,1,UIColours.Toolbar,e.ToolbarItem.ContentView,function()SetTool(a)e:Update(e.ToolbarItem)end,a.Name))\\\
t=t+1\\\
end\\\
e:Update(e.ToolbarItem)\\\
Current.Toolbar:AddToolbarItem(e.ToolbarItem)\\\
end\\\
},\\\
{\\\
Title=\\\"Layers\\\",\\\
ToolbarItem=nil,\\\
Update=function(e)\\\
if Current.Artboard then\\\
e.ToolbarItem.ContentView.Views={}\\\
for t=1,#Current.Artboard.Layers do\\\
table.insert(e.ToolbarItem.ContentView.Views,LayerItem:Initialise(Current.Artboard.Layers[#Current.Artboard.Layers-t+1],e.ToolbarItem.ContentView))\\\
end\\\
end\\\
end,\\\
Initialise=function(e)\\\
e.ToolbarItem=ToolbarItem:Initialise(e,nil,true,Current.Toolbar,\\\
{{\\\
Title=\\\"New Layer\\\",\\\
Click=function()\\\
MakeNewLayer()\\\
end,\\\
Enabled=function()\\\
return CheckOpenArtboard()\\\
end\\\
},\\\
{\\\
Title='Delete Layer',\\\
Click=function()\\\
DeleteLayer()\\\
end,\\\
Enabled=function()\\\
return CheckSelectedLayer()\\\
end\\\
},\\\
{\\\
Title='Rename Layer...',\\\
Click=function()\\\
RenameLayer()\\\
end,\\\
Enabled=function()\\\
return CheckSelectedLayer()\\\
end\\\
}})\\\
e:Update()\\\
Current.Toolbar:AddToolbarItem(e.ToolbarItem)\\\
end\\\
}\\\
}\\\
function ModuleNamed(t)\\\
for a,e in ipairs(Modules)do\\\
if e.Title==t then\\\
return e\\\
end\\\
end\\\
end\\\
function ToolAffectedPixels(e,t)\\\
if not CheckSelectedLayer()then\\\
return{}\\\
end\\\
if Current.ToolSize==1 then\\\
if Current.Layer.Pixels[e]and Current.Layer.Pixels[e][t]then\\\
return{{Current.Layer.Pixels[e][t],e,t}}\\\
end\\\
else\\\
local i={}\\\
local a=e-math.ceil(Current.ToolSize/2)\\\
local o=t-math.ceil(Current.ToolSize/2)\\\
for e=1,Current.ToolSize do\\\
for t=1,Current.ToolSize do\\\
if Current.Layer.Pixels[a+e]and Current.Layer.Pixels[a+e][o+t]then\\\
table.insert(i,{Current.Layer.Pixels[a+e][o+t],a+e,o+t})\\\
end\\\
end\\\
end\\\
return i\\\
end\\\
end\\\
local a={}\\\
Tools={\\\
{\\\
Name=\\\"Hand\\\",\\\
Use=function(o,e,t,o,a)\\\
Current.Input=nil\\\
if a and Current.HandDragStart and Current.HandDragStart[1]and Current.HandDragStart[2]then\\\
local e=e-Current.HandDragStart[1]\\\
local t=t-Current.HandDragStart[2]\\\
Current.Artboard.X=Current.Artboard.X+e\\\
Current.Artboard.Y=Current.Artboard.Y+t\\\
else\\\
Current.HandDragStart={e,t}\\\
end\\\
sleep(0)\\\
end,\\\
Select=function(e)\\\
return true\\\
end\\\
},\\\
{\\\
Name=\\\"Pencil\\\",\\\
Use=function(o,a,e,t,o)\\\
Current.Input=nil\\\
for a,e in ipairs(ToolAffectedPixels(a,e))do\\\
if t==1 then\\\
e[1].BackgroundColour=Current.Colour\\\
elseif t==2 then\\\
e[1].TextColour=Current.Colour\\\
end\\\
e[1]:Draw(e[2],e[3])\\\
end\\\
end,\\\
Select=function(e)\\\
return true\\\
end\\\
},\\\
{\\\
Name=\\\"Eraser\\\",\\\
Use=function(a,t,e,a)\\\
Current.Input=nil\\\
Current.Layer:SetPixel(t,e,nil,Current.Layer.BackgroundColour,nil)\\\
for t,e in ipairs(ToolAffectedPixels(t,e))do\\\
Current.Layer:SetPixel(e[2],e[3],nil,Current.Layer.BackgroundColour,nil)\\\
end\\\
end,\\\
Select=function(e)\\\
return true\\\
end\\\
},\\\
{\\\
Name=\\\"Fill Bucket\\\",\\\
Use=function(e,a,o,i)\\\
local s=Current.Layer.Pixels[a][o].BackgroundColour\\\
if i==2 then\\\
s=Current.Layer.Pixels[a][o].TextColour\\\
end\\\
local t={{X=a,Y=o}}\\\
while#t>0 do\\\
local e=t[1]\\\
if Current.Layer.Pixels[e.X]and Current.Layer.Pixels[e.X][e.Y]then\\\
local n=Current.Layer.Pixels[e.X][e.Y].BackgroundColour\\\
if i==2 then\\\
n=Current.Layer.Pixels[e.X][e.Y].TextColour\\\
end\\\
if n==s and n~=Current.Colour then\\\
if i==1 then\\\
Current.Layer.Pixels[e.X][e.Y].BackgroundColour=Current.Colour\\\
elseif i==2 then\\\
Current.Layer.Pixels[e.X][e.Y].TextColour=Current.Colour\\\
end\\\
table.insert(t,{X=e.X,Y=e.Y+1})\\\
table.insert(t,{X=e.X+1,Y=e.Y})\\\
if a>1 then\\\
table.insert(t,{X=e.X-1,Y=e.Y})\\\
end\\\
if o>1 then\\\
table.insert(t,{X=e.X,Y=e.Y-1})\\\
end\\\
end\\\
end\\\
table.remove(t,1)\\\
end\\\
Draw()\\\
end,\\\
Select=function(e)\\\
return true\\\
end\\\
},\\\
{\\\
Name=\\\"Select\\\",\\\
Use=function(o,e,t,o,a)\\\
Current.Input=nil\\\
if not a then\\\
Current.Selection[1]=vector.new(e,t,0)\\\
Current.Selection[2]=nil\\\
else\\\
Current.Selection[2]=vector.new(e,t,0)\\\
end\\\
end,\\\
Select=function(e)\\\
return true\\\
end\\\
},\\\
{\\\
Name=\\\"Move\\\",\\\
Use=function(i,e,t,i,o)\\\
Current.Input=nil\\\
if Current.Selection and Current.Selection[1]and Current.Selection[2]~=nil then\\\
if o and a then\\\
local i=Current.Layer:PixelsInSelection(true)\\\
local o=Current.Selection[1]-Current.Selection[2]\\\
Current.Selection[1]=vector.new(e-a[1],t-a[2],0)\\\
Current.Selection[2]=vector.new(e-a[1]-o.x,t-a[2]-o.y,0)\\\
Current.Layer:InsertPixels(i)\\\
else\\\
a={e-Current.Selection[1].x,t-Current.Selection[1].y}\\\
end\\\
end\\\
end,\\\
Select=function(e)\\\
return true\\\
end\\\
},\\\
{\\\
Name=\\\"Text\\\",\\\
Use=function(a,e,t)\\\
Current.Input=TextInput:Initialise('',function(a)\\\
if a==keys.delete or a==keys.backspace then\\\
if#Current.Input.Value==0 then\\\
if Current.Layer.Pixels[e]and Current.Layer.Pixels[e][t]then\\\
Current.Layer.Pixels[e][t]:Set(nil,nil,' ')\\\
local e=Current.CursorPos[1]-Current.Artboard.X\\\
if e<Current.Artboard.X-1 then\\\
e=Current.Artboard.X-1\\\
end\\\
Current.Tool:Use(e,Current.CursorPos[2]-Current.Artboard.Y+1)\\\
Draw()\\\
end\\\
return\\\
else\\\
if Current.Layer.Pixels[e+#Current.Input.Value]and Current.Layer.Pixels[e+#Current.Input.Value][t]then\\\
Current.Layer.Pixels[e+#Current.Input.Value][t]:Set(nil,nil,' ')\\\
end\\\
end\\\
else\\\
local a=#Current.Input.Value\\\
if Current.Layer.Pixels[e+a-1]then\\\
Current.Layer.Pixels[e+a-1][t]:Set(Current.Colour,nil,Current.Input.Value:sub(a,a))\\\
Current.Layer.Pixels[e+a-1][t]:Draw(e+a-1,t)\\\
end\\\
end\\\
local a=e+Current.Input.CursorPos\\\
if a>Current.Artboard.Width then\\\
Current.Input.CursorPos=Current.Input.CursorPos-1\\\
end\\\
Current.CursorPos={e+Current.Input.CursorPos+Current.Artboard.X-1,t+Current.Artboard.Y-1}\\\
Current.CursorColour=Current.Colour\\\
Draw()\\\
end)\\\
Current.CursorPos={e+Current.Artboard.X-1,t+Current.Artboard.Y-1}\\\
Current.CursorColour=Current.Colour\\\
end,\\\
Select=function(e)\\\
if Current.Artboard.Format=='.nfp'then\\\
ButtonDialougeWindow:Initialise('NFP does not support text!','The format you are using, NFP, does not support text. Use NFT or SKCH to use text.','Ok',nil,function(e)\\\
e:Close()\\\
end):Show()\\\
return false\\\
else\\\
return true\\\
end\\\
end\\\
}\\\
}\\\
function ToolNamed(t)\\\
for a,e in ipairs(Tools)do\\\
if e.Name==t then\\\
return e\\\
end\\\
end\\\
end\\\
NewDocumentWindow={\\\
X=1,\\\
Y=1,\\\
Width=0,\\\
Height=0,\\\
CursorPos=1,\\\
Visible=true,\\\
Return=nil,\\\
OkButton=nil,\\\
Format='.skch',\\\
ImageBackgroundColour=colours.white,\\\
NameLabelHighlight=false,\\\
SizeLabelHighlight=false,\\\
AbsolutePosition=function(e)\\\
return{X=e.X,Y=e.Y}\\\
end,\\\
Draw=function(e)\\\
if not e.Visible then\\\
return\\\
end\\\
Drawing.DrawBlankArea(e.X+1,e.Y+1,e.Width,e.Height,colours.grey)\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,1,colours.lightGrey)\\\
Drawing.DrawBlankArea(e.X,e.Y+1,e.Width,e.Height-1,colours.white)\\\
Drawing.DrawCharactersCenter(e.X,e.Y,e.Width,1,e.Title,colours.black,colours.lightGrey)\\\
local t=colours.black\\\
if e.NameLabelHighlight then\\\
t=colours.red\\\
end\\\
Drawing.DrawCharacters(e.X+1,e.Y+2,\\\"Name\\\",t,colours.white)\\\
Drawing.DrawCharacters(e.X+1,e.Y+4,\\\"Type\\\",colours.black,colours.white)\\\
local t=colours.black\\\
if e.SizeLabelHighlight then\\\
t=colours.red\\\
end\\\
Drawing.DrawCharacters(e.X+1,e.Y+6,\\\"Size\\\",t,colours.white)\\\
Drawing.DrawCharacters(e.X+11,e.Y+6,\\\"x\\\",colours.black,colours.white)\\\
Drawing.DrawCharacters(e.X+1,e.Y+8,\\\"Background\\\",colours.black,colours.white)\\\
e.OkButton:Draw()\\\
e.CancelButton:Draw()\\\
e.SKCHButton:Draw()\\\
e.NFTButton:Draw()\\\
e.NFPButton:Draw()\\\
e.PathTextBox:Draw()\\\
e.WidthTextBox:Draw()\\\
e.HeightTextBox:Draw()\\\
e.WhiteButton:Draw()\\\
e.BlackButton:Draw()\\\
e.TransparentButton:Draw()\\\
end,\\\
Initialise=function(t,o)\\\
local e={}\\\
setmetatable(e,{__index=t})\\\
e.Width=32\\\
e.Height=13\\\
e.Return=o\\\
e.X=math.ceil((Drawing.Screen.Width-e.Width)/2)\\\
e.Y=math.ceil((Drawing.Screen.Height-e.Height)/2)\\\
e.Title='New Document'\\\
e.Visible=true\\\
e.NameLabelHighlight=false\\\
e.SizeLabelHighlight=false\\\
e.Format='.skch'\\\
e.OkButton=Button:Initialise(e.Width-4,e.Height-1,nil,nil,colours.lightGrey,e,function(t,t,t,t,t)\\\
local t=e.PathTextBox.TextInput.Value\\\
local a=true\\\
e.NameLabelHighlight=false\\\
e.SizeLabelHighlight=false\\\
local i=fs\\\
if OneOS then\\\
i=OneOS.FS\\\
end\\\
if t:sub(-1)=='/'or i.isDir(t)or#t==0 then\\\
a=false\\\
e.NameLabelHighlight=true\\\
end\\\
if#e.WidthTextBox.TextInput.Value==0 or tonumber(e.WidthTextBox.TextInput.Value)<=0 then\\\
a=false\\\
e.SizeLabelHighlight=true\\\
end\\\
if#e.HeightTextBox.TextInput.Value==0 or tonumber(e.HeightTextBox.TextInput.Value)<=0 then\\\
a=false\\\
e.SizeLabelHighlight=true\\\
end\\\
if a then\\\
o(e,true,t,tonumber(e.WidthTextBox.TextInput.Value),tonumber(e.HeightTextBox.TextInput.Value),e.Format,e.ImageBackgroundColour)\\\
else\\\
Draw()\\\
end\\\
end,'Ok',colours.black)\\\
e.CancelButton=Button:Initialise(e.Width-13,e.Height-1,nil,nil,colours.lightGrey,e,function(t,t,t,t,t)o(e,false)end,'Cancel',colours.black)\\\
e.SKCHButton=Button:Initialise(7,5,nil,nil,colours.lightGrey,e,function(t,a,a,a,a)\\\
e.NFTButton.Toggle=false\\\
e.NFPButton.Toggle=false\\\
t.Toggle=false\\\
e.Format='.skch'\\\
end,'.skch',colours.black,true,colours.lightBlue)\\\
e.NFTButton=Button:Initialise(15,5,nil,nil,colours.lightGrey,e,function(t,a,a,a,a)\\\
e.SKCHButton.Toggle=false\\\
e.NFPButton.Toggle=false\\\
t.Toggle=false\\\
e.Format='.nft'\\\
end,'.nft',colours.black,false,colours.lightBlue)\\\
e.NFPButton=Button:Initialise(22,5,nil,nil,colours.lightGrey,e,function(t,a,a,a,a)\\\
e.SKCHButton.Toggle=false\\\
e.NFTButton.Toggle=false\\\
t.Toggle=false\\\
e.Format='.nfp'\\\
end,'.nfp',colours.black,false,colours.lightBlue)\\\
local t=''\\\
if OneOS then\\\
t='/Desktop/'\\\
end\\\
e.PathTextBox=TextBox:Initialise(7,3,e.Width-7,1,e,t,nil,nil,function(t)\\\
if t==keys.enter or t==keys.tab then\\\
Current.Input=e.WidthTextBox.TextInput\\\
end\\\
end)\\\
e.WidthTextBox=TextBox:Initialise(7,7,4,1,e,tostring(15),nil,nil,function()\\\
if key==keys.enter or key==keys.tab then\\\
Current.Input=e.HeightTextBox.TextInput\\\
end\\\
end,true)\\\
e.HeightTextBox=TextBox:Initialise(14,7,4,1,e,tostring(10),nil,nil,function()\\\
if key==keys.enter or key==keys.tab then\\\
Current.Input=e.PathTextBox.TextInput\\\
end\\\
end,true)\\\
Current.Input=e.PathTextBox.TextInput\\\
e.WhiteButton=Button:Initialise(2,10,nil,nil,colours.lightGrey,e,function(t,a,a,a,a)\\\
e.TransparentButton.Toggle=false\\\
e.BlackButton.Toggle=false\\\
t.Toggle=false\\\
e.ImageBackgroundColour=colours.white\\\
end,'White',colours.black,true,colours.lightBlue)\\\
e.BlackButton=Button:Initialise(10,10,nil,nil,colours.lightGrey,e,function(t,a,a,a,a)\\\
e.TransparentButton.Toggle=false\\\
e.WhiteButton.Toggle=false\\\
t.Toggle=false\\\
e.ImageBackgroundColour=colours.black\\\
end,'Black',colours.black,false,colours.lightBlue)\\\
e.TransparentButton=Button:Initialise(18,10,nil,nil,colours.lightGrey,e,function(t,a,a,a,a)\\\
e.WhiteButton.Toggle=false\\\
e.BlackButton.Toggle=false\\\
t.Toggle=false\\\
e.ImageBackgroundColour=colours.transparent\\\
end,'Transparent',colours.black,false,colours.lightBlue)\\\
return e\\\
end,\\\
Show=function(e)\\\
Current.Window=e\\\
return e\\\
end,\\\
Close=function(e)\\\
Current.Input=nil\\\
Current.Window=nil\\\
e=nil\\\
end,\\\
Flash=function(e)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
sleep(.15)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
end,\\\
ButtonClick=function(o,e,t,a)\\\
if e.X<=t and e.Y<=a and e.X+e.Width>t and e.Y+e.Height>a then\\\
e:Click()\\\
end\\\
end,\\\
Click=function(e,o,a,t)\\\
local e={e.OkButton,e.CancelButton,e.SKCHButton,e.NFTButton,e.NFPButton,e.PathTextBox,e.WidthTextBox,e.HeightTextBox,e.WhiteButton,e.BlackButton,e.TransparentButton}\\\
for i,e in ipairs(e)do\\\
if CheckClick(e,a,t)then\\\
e:Click(o,a,t)\\\
end\\\
end\\\
return true\\\
end\\\
}\\\
local o=function(e)\\\
e='/'..e\\\
local t=fs\\\
if OneOS then\\\
t=OneOS.FS\\\
end\\\
if t.isDir(e)then\\\
e=e..'/'\\\
end\\\
e,n=e:gsub(\\\"//\\\",\\\"/\\\")\\\
while n>0 do\\\
e,n=e:gsub(\\\"//\\\",\\\"/\\\")\\\
end\\\
return e\\\
end\\\
local n=function(t,o)\\\
local e={''}\\\
for a,t in t:gmatch('(%S+)(%s*)')do\\\
local i=e[#e]..a..t:gsub('\\\\n','')\\\
if#i>o then\\\
table.insert(e,'')\\\
end\\\
if t:find('\\\\n')then\\\
e[#e]=e[#e]..a\\\
t=t:gsub('\\\\n',function()\\\
table.insert(e,'')\\\
return''\\\
end)\\\
else\\\
e[#e]=e[#e]..a..t\\\
end\\\
end\\\
return e\\\
end\\\
OpenDocumentWindow={\\\
X=1,\\\
Y=1,\\\
Width=0,\\\
Height=0,\\\
CursorPos=1,\\\
Visible=true,\\\
Return=nil,\\\
OpenButton=nil,\\\
PathTextBox=nil,\\\
CurrentDirectory='/',\\\
Scroll=0,\\\
MaxScroll=0,\\\
GoUpButton=nil,\\\
SelectedFile='',\\\
Files={},\\\
Typed=false,\\\
AbsolutePosition=function(e)\\\
return{X=e.X,Y=e.Y}\\\
end,\\\
Draw=function(e)\\\
if not e.Visible then\\\
return\\\
end\\\
Drawing.DrawBlankArea(e.X+1,e.Y+1,e.Width,e.Height,colours.grey)\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,3,colours.lightGrey)\\\
Drawing.DrawBlankArea(e.X,e.Y+1,e.Width,e.Height-6,colours.white)\\\
Drawing.DrawCharactersCenter(e.X,e.Y,e.Width,1,e.Title,colours.black,colours.lightGrey)\\\
Drawing.DrawBlankArea(e.X,e.Y+e.Height-5,e.Width,5,colours.lightGrey)\\\
e:DrawFiles()\\\
local t=fs\\\
if OneOS then\\\
t=OneOS.FS\\\
end\\\
if(t.exists(e.PathTextBox.TextInput.Value))or(e.SelectedFile and#e.SelectedFile>0 and t.exists(e.CurrentDirectory..e.SelectedFile))then\\\
e.OpenButton.TextColour=colours.black\\\
else\\\
e.OpenButton.TextColour=colours.lightGrey\\\
end\\\
e.PathTextBox:Draw()\\\
e.OpenButton:Draw()\\\
e.CancelButton:Draw()\\\
e.GoUpButton:Draw()\\\
end,\\\
DrawFiles=function(e)\\\
local o=fs\\\
if OneOS then\\\
o=OneOS.FS\\\
end\\\
for a,t in ipairs(e.Files)do\\\
if a>e.Scroll and a-e.Scroll<=11 then\\\
if t==e.SelectedFile then\\\
Drawing.DrawCharacters(e.X+1,e.Y+a-e.Scroll,t,colours.white,colours.lightBlue)\\\
elseif string.find(t,'%.skch')or string.find(t,'%.nft')or string.find(t,'%.nfp')or o.isDir(e.CurrentDirectory..t)then\\\
Drawing.DrawCharacters(e.X+1,e.Y+a-e.Scroll,t,colours.black,colours.white)\\\
else\\\
Drawing.DrawCharacters(e.X+1,e.Y+a-e.Scroll,t,colours.grey,colours.white)\\\
end\\\
end\\\
end\\\
e.MaxScroll=#e.Files-11\\\
if e.MaxScroll<0 then\\\
e.MaxScroll=0\\\
end\\\
end,\\\
Initialise=function(t,a)\\\
local e={}\\\
setmetatable(e,{__index=t})\\\
e.Width=32\\\
e.Height=17\\\
e.Return=a\\\
e.X=math.ceil((Drawing.Screen.Width-e.Width)/2)\\\
e.Y=math.ceil((Drawing.Screen.Height-e.Height)/2)\\\
e.Title='Open Document'\\\
e.Visible=true\\\
e.CurrentDirectory='/'\\\
e.SelectedFile=nil\\\
if OneOS then\\\
e.CurrentDirectory='/Desktop/'\\\
end\\\
local t=fs\\\
if OneOS then\\\
t=OneOS.FS\\\
end\\\
e.OpenButton=Button:Initialise(e.Width-6,e.Height-1,nil,nil,colours.white,e,function(i,n,n,n,n)\\\
if t.exists(e.PathTextBox.TextInput.Value)and i.TextColour==colours.black and not t.isDir(e.PathTextBox.TextInput.Value)then\\\
a(e,true,o(e.PathTextBox.TextInput.Value))\\\
elseif e.SelectedFile and i.TextColour==colours.black and t.isDir(e.CurrentDirectory..e.SelectedFile)then\\\
e:GoToDirectory(e.CurrentDirectory..e.SelectedFile)\\\
elseif e.SelectedFile and i.TextColour==colours.black then\\\
a(e,true,o(e.CurrentDirectory..'/'..e.SelectedFile))\\\
end\\\
end,'Open',colours.black)\\\
e.CancelButton=Button:Initialise(e.Width-15,e.Height-1,nil,nil,colours.white,e,function(t,t,t,t,t)\\\
a(e,false)\\\
end,'Cancel',colours.black)\\\
e.GoUpButton=Button:Initialise(2,e.Height-1,nil,nil,colours.white,e,function(a,a,a,a,a)\\\
local t=t.getName(e.CurrentDirectory)\\\
local t=e.CurrentDirectory:sub(1,#e.CurrentDirectory-#t-1)\\\
e:GoToDirectory(t)\\\
end,'Go Up',colours.black)\\\
e.PathTextBox=TextBox:Initialise(2,e.Height-3,e.Width-2,1,e,e.CurrentDirectory,colours.white,colours.black)\\\
e:GoToDirectory(e.CurrentDirectory)\\\
return e\\\
end,\\\
Show=function(e)\\\
Current.Window=e\\\
return e\\\
end,\\\
Close=function(e)\\\
Current.Input=nil\\\
Current.Window=nil\\\
e=nil\\\
end,\\\
GoToDirectory=function(e,t)\\\
t=o(t)\\\
e.CurrentDirectory=t\\\
e.Scroll=0\\\
e.SelectedFile=nil\\\
e.Typed=false\\\
e.PathTextBox.TextInput.Value=t\\\
local t=fs\\\
if OneOS then\\\
t=OneOS.FS\\\
end\\\
e.Files=t.list(e.CurrentDirectory)\\\
Draw()\\\
end,\\\
Flash=function(e)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
sleep(.15)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
end,\\\
Click=function(e,n,i,t)\\\
local s={e.OpenButton,e.CancelButton,e.PathTextBox,e.GoUpButton}\\\
local a=false\\\
for o,e in ipairs(s)do\\\
if CheckClick(e,i,t)then\\\
e:Click(n,i,t)\\\
a=true\\\
end\\\
end\\\
if not a then\\\
if t<=12 then\\\
local a=fs\\\
if OneOS then\\\
a=OneOS.FS\\\
end\\\
e.SelectedFile=a.list(e.CurrentDirectory)[t-1]\\\
e.PathTextBox.TextInput.Value=o(e.CurrentDirectory..'/'..e.SelectedFile)\\\
Draw()\\\
end\\\
end\\\
return true\\\
end\\\
}\\\
ButtonDialougeWindow={\\\
X=1,\\\
Y=1,\\\
Width=0,\\\
Height=0,\\\
CursorPos=1,\\\
Visible=true,\\\
CancelButton=nil,\\\
OkButton=nil,\\\
Lines={},\\\
AbsolutePosition=function(e)\\\
return{X=e.X,Y=e.Y}\\\
end,\\\
Draw=function(e)\\\
if not e.Visible then\\\
return\\\
end\\\
Drawing.DrawBlankArea(e.X+1,e.Y+1,e.Width,e.Height,colours.grey)\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,1,colours.lightGrey)\\\
Drawing.DrawBlankArea(e.X,e.Y+1,e.Width,e.Height-1,colours.white)\\\
Drawing.DrawCharactersCenter(e.X,e.Y,e.Width,1,e.Title,colours.black,colours.lightGrey)\\\
for t,a in ipairs(e.Lines)do\\\
Drawing.DrawCharacters(e.X+1,e.Y+1+t,a,colours.black,colours.white)\\\
end\\\
e.OkButton:Draw()\\\
if e.CancelButton then\\\
e.CancelButton:Draw()\\\
end\\\
end,\\\
Initialise=function(s,i,h,t,o,a)\\\
local e={}\\\
setmetatable(e,{__index=s})\\\
e.Width=28\\\
e.Lines=n(h,e.Width-2)\\\
e.Height=5+#e.Lines\\\
e.Return=a\\\
e.X=math.ceil((Drawing.Screen.Width-e.Width)/2)\\\
e.Y=math.ceil((Drawing.Screen.Height-e.Height)/2)\\\
e.Title=i\\\
e.Visible=true\\\
e.Visible=true\\\
e.OkButton=Button:Initialise(e.Width-#t-2,e.Height-1,nil,1,nil,e,function()\\\
a(e,true)\\\
end,t)\\\
if o then\\\
e.CancelButton=Button:Initialise(e.Width-#t-2-1-#o-2,e.Height-1,nil,1,nil,e,function()\\\
a(e,false)\\\
end,o)\\\
end\\\
return e\\\
end,\\\
Show=function(e)\\\
Current.Window=e\\\
return e\\\
end,\\\
Close=function(e)\\\
Current.Window=nil\\\
e=nil\\\
end,\\\
Flash=function(e)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
sleep(.15)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
end,\\\
Click=function(e,o,a,t)\\\
local e={e.OkButton,e.CancelButton}\\\
local i=false\\\
for n,e in ipairs(e)do\\\
if CheckClick(e,a,t)then\\\
e:Click(o,a,t)\\\
i=true\\\
end\\\
end\\\
return true\\\
end\\\
}\\\
TextDialougeWindow={\\\
X=1,\\\
Y=1,\\\
Width=0,\\\
Height=0,\\\
CursorPos=1,\\\
Visible=true,\\\
CancelButton=nil,\\\
OkButton=nil,\\\
Lines={},\\\
TextInput=nil,\\\
AbsolutePosition=function(e)\\\
return{X=e.X,Y=e.Y}\\\
end,\\\
Draw=function(e)\\\
if not e.Visible then\\\
return\\\
end\\\
Drawing.DrawBlankArea(e.X+1,e.Y+1,e.Width,e.Height,colours.grey)\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,1,colours.lightGrey)\\\
Drawing.DrawBlankArea(e.X,e.Y+1,e.Width,e.Height-1,colours.white)\\\
Drawing.DrawCharactersCenter(e.X,e.Y,e.Width,1,e.Title,colours.black,colours.lightGrey)\\\
for a,t in ipairs(e.Lines)do\\\
Drawing.DrawCharacters(e.X+1,e.Y+1+a,t,colours.black,colours.white)\\\
end\\\
Drawing.DrawBlankArea(e.X+1,e.Y+e.Height-4,e.Width-2,1,colours.lightGrey)\\\
Drawing.DrawCharacters(e.X+2,e.Y+e.Height-4,e.TextInput.Value,colours.black,colours.lightGrey)\\\
Current.CursorPos={e.X+2+e.TextInput.CursorPos,e.Y+e.Height-4}\\\
Current.CursorColour=colours.black\\\
e.OkButton:Draw()\\\
if e.CancelButton then\\\
e.CancelButton:Draw()\\\
end\\\
end,\\\
Initialise=function(r,h,s,a,o,t,i)\\\
local e={}\\\
setmetatable(e,{__index=r})\\\
e.Width=28\\\
e.Lines=n(s,e.Width-2)\\\
e.Height=7+#e.Lines\\\
e.Return=t\\\
e.X=math.ceil((Drawing.Screen.Width-e.Width)/2)\\\
e.Y=math.ceil((Drawing.Screen.Height-e.Height)/2)\\\
e.Title=h\\\
e.Visible=true\\\
e.Visible=true\\\
e.OkButton=Button:Initialise(e.Width-#a-2,e.Height-1,nil,1,nil,e,function()\\\
if#e.TextInput.Value>0 then\\\
t(e,true,e.TextInput.Value)\\\
end\\\
end,a)\\\
if o then\\\
e.CancelButton=Button:Initialise(e.Width-#a-2-1-#o-2,e.Height-1,nil,1,nil,e,function()\\\
t(e,false)\\\
end,o)\\\
end\\\
e.TextInput=TextInput:Initialise('',function(t)\\\
if t then\\\
e.OkButton:Click()\\\
end\\\
Draw()\\\
end,i)\\\
Current.Input=e.TextInput\\\
return e\\\
end,\\\
Show=function(e)\\\
Current.Window=e\\\
return e\\\
end,\\\
Close=function(e)\\\
Current.Window=nil\\\
Current.Input=nil\\\
e=nil\\\
end,\\\
Flash=function(e)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
sleep(.15)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
end,\\\
Click=function(e,o,t,a)\\\
local e={e.OkButton,e.CancelButton}\\\
local i=false\\\
for n,e in ipairs(e)do\\\
if CheckClick(e,t,a)then\\\
e:Click(o,t,a)\\\
i=true\\\
end\\\
end\\\
return true\\\
end\\\
}\\\
ResizeDocumentWindow={\\\
X=1,\\\
Y=1,\\\
Width=0,\\\
Height=0,\\\
CursorPos=1,\\\
Visible=true,\\\
Return=nil,\\\
OkButton=nil,\\\
AnchorPosition=5,\\\
WidthLabelHighlight=false,\\\
HeightLabelHighlight=false,\\\
AbsolutePosition=function(e)\\\
return{X=e.X,Y=e.Y}\\\
end,\\\
Draw=function(e)\\\
if not e.Visible then\\\
return\\\
end\\\
Drawing.DrawBlankArea(e.X+1,e.Y+1,e.Width,e.Height,colours.grey)\\\
Drawing.DrawBlankArea(e.X,e.Y,e.Width,1,colours.lightGrey)\\\
Drawing.DrawBlankArea(e.X,e.Y+1,e.Width,e.Height-1,colours.white)\\\
Drawing.DrawCharactersCenter(e.X,e.Y,e.Width,1,e.Title,colours.black,colours.lightGrey)\\\
Drawing.DrawCharacters(e.X+1,e.Y+2,\\\"New Size\\\",colours.lightGrey,colours.white)\\\
if(#e.WidthTextBox.TextInput.Value>0 and tonumber(e.WidthTextBox.TextInput.Value)<Current.Artboard.Width)or(#e.HeightTextBox.TextInput.Value>0 and tonumber(e.HeightTextBox.TextInput.Value)<Current.Artboard.Height)then\\\
Drawing.DrawCharacters(e.X+1,e.Y+8,\\\"Clipping will occur!\\\",colours.red,colours.white)\\\
end\\\
local t=colours.black\\\
if e.WidthLabelHighlight then\\\
t=colours.red\\\
end\\\
local a=colours.black\\\
if e.HeightLabelHighlight then\\\
a=colours.red\\\
end\\\
Drawing.DrawCharacters(e.X+1,e.Y+4,\\\"Width\\\",t,colours.white)\\\
Drawing.DrawCharacters(e.X+1,e.Y+6,\\\"Height\\\",a,colours.white)\\\
Drawing.DrawCharacters(e.X+14,e.Y+2,\\\"Anchor\\\",colours.lightGrey,colours.white)\\\
e.WidthTextBox:Draw()\\\
e.HeightTextBox:Draw()\\\
e.OkButton:Draw()\\\
e.Anchor1:Draw()\\\
e.Anchor2:Draw()\\\
e.Anchor3:Draw()\\\
e.Anchor4:Draw()\\\
e.Anchor5:Draw()\\\
e.Anchor6:Draw()\\\
e.Anchor7:Draw()\\\
e.Anchor8:Draw()\\\
e.Anchor9:Draw()\\\
end,\\\
Initialise=function(t,a)\\\
local e={}\\\
setmetatable(e,{__index=t})\\\
e.Width=27\\\
e.Height=10\\\
e.Return=a\\\
e.X=math.ceil((Drawing.Screen.Width-e.Width)/2)\\\
e.Y=math.ceil((Drawing.Screen.Height-e.Height)/2)\\\
e.Title='Resize Document'\\\
e.Visible=true\\\
e.WidthTextBox=TextBox:Initialise(9,5,4,1,e,tostring(Current.Artboard.Width),nil,nil,function()\\\
e:UpdateAnchorButtons()\\\
end,true)\\\
e.HeightTextBox=TextBox:Initialise(9,7,4,1,e,tostring(Current.Artboard.Height),nil,nil,function()\\\
e:UpdateAnchorButtons()\\\
end,true)\\\
e.OkButton=Button:Initialise(e.Width-4,e.Height-1,nil,nil,colours.lightGrey,e,function(t,t,t,t,t)\\\
local t=true\\\
e.WidthLabelHighlight=false\\\
e.HeightLabelHighlight=false\\\
if#e.WidthTextBox.TextInput.Value==0 or tonumber(e.WidthTextBox.TextInput.Value)<=0 then\\\
t=false\\\
e.WidthLabelHighlight=true\\\
end\\\
if#e.HeightTextBox.TextInput.Value==0 or tonumber(e.HeightTextBox.TextInput.Value)<=0 then\\\
t=false\\\
e.HeightLabelHighlight=true\\\
end\\\
if t then\\\
a(e,tonumber(e.WidthTextBox.TextInput.Value),tonumber(e.HeightTextBox.TextInput.Value),e.AnchorPosition)\\\
else\\\
Draw()\\\
end\\\
end,'Ok',colours.black)\\\
local a=15\\\
local t=5\\\
e.Anchor1=Button:Initialise(a,t,1,1,colours.lightGrey,e,function(t,t,t,t,t)e.AnchorPosition=1 e:UpdateAnchorButtons()end,' ',colours.black)\\\
e.Anchor2=Button:Initialise(a+1,t,1,1,colours.lightGrey,e,function(t,t,t,t,t)e.AnchorPosition=2 e:UpdateAnchorButtons()end,'^',colours.black)\\\
e.Anchor3=Button:Initialise(a+2,t,1,1,colours.lightGrey,e,function(t,t,t,t,t)e.AnchorPosition=3 e:UpdateAnchorButtons()end,' ',colours.black)\\\
e.Anchor4=Button:Initialise(a,t+1,1,1,colours.lightGrey,e,function(t,t,t,t,t)e.AnchorPosition=4 e:UpdateAnchorButtons()end,'<',colours.black)\\\
e.Anchor5=Button:Initialise(a+1,t+1,1,1,colours.lightGrey,e,function(t,t,t,t,t)e.AnchorPosition=5 e:UpdateAnchorButtons()end,'#',colours.black)\\\
e.Anchor6=Button:Initialise(a+2,t+1,1,1,colours.lightGrey,e,function(t,t,t,t,t)e.AnchorPosition=6 e:UpdateAnchorButtons()end,'>',colours.black)\\\
e.Anchor7=Button:Initialise(a,t+2,1,1,colours.lightGrey,e,function(t,t,t,t,t)e.AnchorPosition=7 e:UpdateAnchorButtons()end,' ',colours.black)\\\
e.Anchor8=Button:Initialise(a+1,t+2,1,1,colours.lightGrey,e,function(t,t,t,t,t)e.AnchorPosition=8 e:UpdateAnchorButtons()end,'v',colours.black)\\\
e.Anchor9=Button:Initialise(a+2,t+2,1,1,colours.lightGrey,e,function(t,t,t,t,t)e.AnchorPosition=9 e:UpdateAnchorButtons()end,' ',colours.black)\\\
return e\\\
end,\\\
UpdateAnchorButtons=function(e)\\\
local r=' '\\\
local n=' '\\\
local d=' '\\\
local a=' '\\\
local t=' '\\\
local o=' '\\\
local h=' '\\\
local i=' '\\\
local s=' '\\\
e.AnchorPosition=e.AnchorPosition or 5\\\
if e.AnchorPosition==1 then\\\
r='#'\\\
n='>'\\\
a='v'\\\
elseif e.AnchorPosition==2 then\\\
r='<'\\\
n='#'\\\
d='>'\\\
t='v'\\\
elseif e.AnchorPosition==3 then\\\
n='<'\\\
d='#'\\\
o='v'\\\
elseif e.AnchorPosition==4 then\\\
r='^'\\\
a='#'\\\
t='>'\\\
h='v'\\\
elseif e.AnchorPosition==5 then\\\
n='^'\\\
a='<'\\\
t='#'\\\
o='>'\\\
i='v'\\\
elseif e.AnchorPosition==6 then\\\
d='^'\\\
o='#'\\\
t='<'\\\
s='v'\\\
elseif e.AnchorPosition==7 then\\\
a='^'\\\
h='#'\\\
i='>'\\\
elseif e.AnchorPosition==8 then\\\
t='^'\\\
i='#'\\\
h='<'\\\
s='>'\\\
elseif e.AnchorPosition==9 then\\\
o='^'\\\
s='#'\\\
i='<'\\\
end\\\
if#e.HeightTextBox.TextInput.Value>0 and Current.Artboard.Height>tonumber(e.HeightTextBox.TextInput.Value)then\\\
local e=function(e)\\\
if string.find(e,\\\"%^\\\")then\\\
e=e:gsub('%^','v')\\\
elseif string.find(e,\\\"v\\\")then\\\
e=e:gsub('v','%^')\\\
end\\\
return e\\\
end\\\
r=e(r)\\\
n=e(n)\\\
d=e(d)\\\
a=e(a)\\\
t=e(t)\\\
o=e(o)\\\
h=e(h)\\\
i=e(i)\\\
s=e(s)\\\
end\\\
if#e.WidthTextBox.TextInput.Value>0 and Current.Artboard.Width>tonumber(e.WidthTextBox.TextInput.Value)then\\\
local e=function(e)\\\
if string.find(e,\\\">\\\")then\\\
e=e:gsub('>','<')\\\
elseif string.find(e,\\\"<\\\")then\\\
e=e:gsub('<','>')\\\
end\\\
return e\\\
end\\\
r=e(r)\\\
n=e(n)\\\
d=e(d)\\\
a=e(a)\\\
t=e(t)\\\
o=e(o)\\\
h=e(h)\\\
i=e(i)\\\
s=e(s)\\\
end\\\
e.Anchor1.Text=r\\\
e.Anchor2.Text=n\\\
e.Anchor3.Text=d\\\
e.Anchor4.Text=a\\\
e.Anchor5.Text=t\\\
e.Anchor6.Text=o\\\
e.Anchor7.Text=h\\\
e.Anchor8.Text=i\\\
e.Anchor9.Text=s\\\
end,\\\
Show=function(e)\\\
Current.Window=e\\\
return e\\\
end,\\\
Close=function(e)\\\
Current.Input=nil\\\
Current.Window=nil\\\
e=nil\\\
end,\\\
Flash=function(e)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
sleep(.15)\\\
e.Visible=false\\\
Draw()\\\
sleep(.15)\\\
e.Visible=true\\\
Draw()\\\
end,\\\
ButtonClick=function(o,e,t,a)\\\
if e.X<=t and e.Y<=a and e.X+e.Width>t and e.Y+e.Height>a then\\\
e:Click()\\\
end\\\
end,\\\
Click=function(e,o,t,a)\\\
local e={e.OkButton,e.WidthTextBox,e.HeightTextBox,e.Anchor1,e.Anchor2,e.Anchor3,e.Anchor4,e.Anchor5,e.Anchor6,e.Anchor7,e.Anchor8,e.Anchor9}\\\
for i,e in ipairs(e)do\\\
if CheckClick(e,t,a)then\\\
e:Click(o,t,a)\\\
end\\\
end\\\
return true\\\
end\\\
}\\\
function CheckOpenArtboard()\\\
if Current.Artboard then\\\
return true\\\
else\\\
return false\\\
end\\\
end\\\
function CheckSelectedLayer()\\\
if Current.Artboard and Current.Layer then\\\
return true\\\
else\\\
return false\\\
end\\\
end\\\
function DisplayNewDocumentWindow()\\\
NewDocumentWindow:Initialise(function(i,a,e,n,o,t,s)\\\
if a then\\\
if e:sub(-4)~=t then\\\
e=e..t\\\
end\\\
local a=i\\\
Current.Input=nil\\\
Current.Window=nil\\\
makeDocument=function()a:Close()NewDocument(e,n,o,t,s)end\\\
local o=fs\\\
if OneOS then\\\
o=OneOS.FS\\\
end\\\
if o.exists(e)then\\\
ButtonDialougeWindow:Initialise('File Exists',e..' already exists! Use a different name and try again.','Ok',nil,function(e,t)\\\
e:Close()\\\
a:Show()\\\
end):Show()\\\
elseif t=='.nfp'then\\\
Current.Window=nil\\\
ButtonDialougeWindow:Initialise('Use NFP?','The NFT format does not support text or layers, if you use it you will only be able to use 1 layer and not have any text.','Use NFP','Cancel',function(t,e)\\\
t:Close()\\\
if e then\\\
makeDocument()\\\
else\\\
a:Show()\\\
end\\\
end):Show()\\\
elseif t=='.nft'then\\\
ButtonDialougeWindow:Initialise('Use NFT?','The NFT format does not support layers, if you use it you will only be able to use 1 layer.','Use NFT','Cancel',function(t,e)\\\
t:Close()\\\
if e then\\\
makeDocument()\\\
else\\\
a:Show()\\\
end\\\
end):Show()\\\
else\\\
makeDocument()\\\
end\\\
else\\\
i:Close()\\\
end\\\
end):Show()\\\
end\\\
function NewDocument(e,o,i,a,n)\\\
local t=fs\\\
if OneOS then\\\
t=OneOS.FS\\\
end\\\
ab=Artboard:New(t.getName(e),e,o,i,a,n)\\\
Current.Tool=Tools[2]\\\
Current.Toolbar:Update()\\\
Current.Modified=false\\\
Draw()\\\
end\\\
function DisplayToolSizeWindow()\\\
if not CheckOpenArtboard()then\\\
return\\\
end\\\
TextDialougeWindow:Initialise('Change Tool Size','Enter the new tool size you\\\\'d like to use.','Ok','Cancel',function(a,e,t)\\\
if e then\\\
Current.ToolSize=math.ceil(tonumber(t))\\\
if Current.ToolSize<1 then\\\
Current.ToolSize=1\\\
elseif Current.ToolSize>50 then\\\
Current.ToolSize=50\\\
end\\\
ModuleNamed('Tools'):Update()\\\
end\\\
a:Close()\\\
end,true):Show()\\\
end\\\
function GetFormat(t)\\\
local e=fs\\\
if OneOS then\\\
e=OneOS.FS\\\
end\\\
local t=e.open(t,'r')\\\
local e=t.readAll()\\\
t.close()\\\
if type(textutils.unserialize(e))=='table'then\\\
return'.skch'\\\
elseif string.find(e,string.char(30))or string.find(e,string.char(31))then\\\
return'.nft'\\\
else\\\
return'.nfp'\\\
end\\\
end\\\
function DisplayOpenDocumentWindow()\\\
OpenDocumentWindow:Initialise(function(a,t,e)\\\
a:Close()\\\
if t then\\\
OpenDocument(e)\\\
end\\\
end):Show()\\\
end\\\
local function o(e,t)\\\
if not e then\\\
return nil\\\
elseif not string.find(fs.getName(e),'%.')then\\\
if not t then\\\
return fs.getName(e)\\\
else\\\
return''\\\
end\\\
else\\\
local a=e\\\
if e:sub(#e)=='/'then\\\
a=e:sub(1,#e-1)\\\
end\\\
local e=a:gmatch('%.[0-9a-z]+$')()\\\
if e then\\\
e=e:sub(2)\\\
else\\\
return''\\\
end\\\
if t then\\\
e='.'..e\\\
end\\\
return e:lower()\\\
end\\\
end\\\
local e=function(e)\\\
if e:sub(1,1)=='.'then\\\
return e\\\
end\\\
local t=o(e)\\\
if t==e then\\\
return fs.getName(e)\\\
end\\\
return string.gsub(e,t,''):sub(1,-2)\\\
end\\\
function OpenDocument(a)\\\
local e=fs\\\
if OneOS then\\\
e=OneOS.FS\\\
end\\\
if e.exists(a)and not e.isDir(a)then\\\
local e=o(a,true)\\\
if(not e or e=='')and(e~='.nfp'and e~='.nft'and e~='.skch')then\\\
e=GetFormat(a)\\\
end\\\
local t={}\\\
if e=='.nfp'then\\\
t=ReadNFP(a)\\\
elseif e=='.nft'then\\\
t=ReadNFT(a)\\\
elseif e=='.skch'then\\\
t=ReadSKCH(a)\\\
end\\\
for t,e in ipairs(t)do\\\
if e.Visible==nil then\\\
e.Visible=true\\\
end\\\
if e.Index==nil then\\\
e.Index=1\\\
end\\\
if e.Name==nil then\\\
if e.Index==1 then\\\
e.Name='Background'\\\
else\\\
e.Name='Layer'\\\
end\\\
end\\\
if e.BackgroundColour==nil then\\\
e.BackgroundColour=colours.white\\\
end\\\
end\\\
if not t[1]then\\\
return\\\
end\\\
local i=#t[1].Pixels\\\
local n=#t[1].Pixels[1]\\\
Current.Artboard=nil\\\
local o=fs\\\
if OneOS then\\\
o=OneOS.FS\\\
end\\\
ab=Artboard:New(o.getName('Image'),a,i,n,e,nil,t)\\\
Current.Tool=Tools[2]\\\
Current.Toolbar:Update()\\\
Current.Modified=false\\\
Draw()\\\
end\\\
end\\\
function MakeNewLayer()\\\
if not CheckOpenArtboard()then\\\
return\\\
end\\\
if Current.Artboard.Format=='.skch'then\\\
TextDialougeWindow:Initialise('New Layer Name','Enter the name you want for the next layer.','Ok','Cancel',function(a,e,t)\\\
if e then\\\
Current.Artboard:MakeLayer(t,colours.transparent)\\\
end\\\
a:Close()\\\
end):Show()\\\
else\\\
local e='NFP'\\\
if Current.Artboard.Format=='.nft'then\\\
e='NFT'\\\
end\\\
ButtonDialougeWindow:Initialise(e..' does not support layers!','The format you are using, '..e..', does not support multiple layers. Use SKCH to have more than one layer.','Ok',nil,function(e)\\\
e:Close()\\\
end):Show()\\\
end\\\
end\\\
function ResizeDocument()\\\
if not CheckOpenArtboard()then\\\
return\\\
end\\\
ResizeDocumentWindow:Initialise(function(e,s,n,i)\\\
e:Close()\\\
local t=0\\\
local a=0\\\
local e=0\\\
local o=0\\\
if i==1 then\\\
a=1\\\
e=1\\\
elseif i==2 then\\\
a=.5\\\
o=.5\\\
e=1\\\
elseif i==3 then\\\
o=1\\\
e=1\\\
elseif i==4 then\\\
a=1\\\
e=.5\\\
t=.5\\\
elseif i==5 then\\\
a=.5\\\
o=.5\\\
e=.5\\\
t=.5\\\
elseif i==6 then\\\
o=1\\\
e=.5\\\
t=.5\\\
elseif i==7 then\\\
a=1\\\
t=1\\\
elseif i==8 then\\\
a=.5\\\
o=.5\\\
t=1\\\
elseif i==9 then\\\
o=1\\\
t=1\\\
end\\\
t=t*(n-Current.Artboard.Height)\\\
if t>0 then\\\
t=math.floor(t)\\\
else\\\
t=math.ceil(t)\\\
end\\\
e=e*(n-Current.Artboard.Height)\\\
if e>0 then\\\
e=math.ceil(e)\\\
else\\\
e=math.floor(e)\\\
end\\\
o=o*(s-Current.Artboard.Width)\\\
if o>0 then\\\
o=math.floor(o)\\\
else\\\
o=math.ceil(o)\\\
end\\\
a=a*(s-Current.Artboard.Width)\\\
if a>0 then\\\
a=math.ceil(a)\\\
else\\\
a=math.floor(a)\\\
end\\\
Current.Artboard:Resize(t,e,o,a)\\\
end):Show()\\\
end\\\
function RenameLayer()\\\
if not CheckOpenArtboard()then\\\
return\\\
end\\\
if Current.Artboard.Format=='.skch'then\\\
TextDialougeWindow:Initialise(\\\"Rename Layer '\\\"..Current.Layer.Name..\\\"'\\\",'Enter the new name you want the layer to be called.','Ok','Cancel',function(t,e,a)\\\
if e then\\\
Current.Layer.Name=a\\\
end\\\
t:Close()\\\
end):Show()\\\
else\\\
local e='NFP'\\\
if Current.Artboard.Format=='.nft'then\\\
e='NFT'\\\
end\\\
ButtonDialougeWindow:Initialise(e..' does not support layers!','The format you are using, '..e..', does not support renaming layers. Use SKCH to rename layers.','Ok',nil,function(e)\\\
e:Close()\\\
end):Show()\\\
end\\\
end\\\
function DeleteLayer()\\\
if not CheckOpenArtboard()then\\\
return\\\
end\\\
if Current.Artboard.Format=='.skch'then\\\
if#Current.Artboard.Layers>1 then\\\
ButtonDialougeWindow:Initialise(\\\"Delete Layer '\\\"..Current.Layer.Name..\\\"'?\\\",'Are you sure you want delete the layer?','Ok','Cancel',function(e,t)\\\
if t then\\\
Current.Layer:Remove()\\\
end\\\
e:Close()\\\
end):Show()\\\
else\\\
ButtonDialougeWindow:Initialise('Can not delete layer!','You can not delete the last layer of an image! Make another layer to delete this one.','Ok',nil,function(e)\\\
e:Close()\\\
end):Show()\\\
end\\\
else\\\
local e='NFP'\\\
if Current.Artboard.Format=='.nft'then\\\
e='NFT'\\\
end\\\
ButtonDialougeWindow:Initialise(e..' does not support layers!','The format you are using, '..e..', does not support deleting layers. Use SKCH to deleting layers.','Ok',nil,function(e)\\\
e:Close()\\\
end):Show()\\\
end\\\
end\\\
needsDraw=false\\\
isDrawing=false\\\
function Draw()\\\
if isDrawing then\\\
needsDraw=true\\\
return\\\
end\\\
needsDraw=false\\\
isDrawing=true\\\
if not Current.Window then\\\
Drawing.Clear(UIColours.Background)\\\
else\\\
Drawing.DrawArea(1,2,Drawing.Screen.Width,Drawing.Screen.Height,'|',colours.black,colours.lightGrey)\\\
end\\\
if Current.Artboard then\\\
ab:Draw()\\\
end\\\
if Current.InterfaceVisible then\\\
Current.MenuBar:Draw()\\\
Current.Toolbar.Width=Current.Toolbar.ExpandedWidth\\\
Current.Toolbar:Draw()\\\
else\\\
Current.Toolbar.Width=Current.Toolbar.ExpandedWidth\\\
end\\\
if Current.InterfaceVisible and Current.Menu then\\\
Current.Menu:Draw()\\\
end\\\
if Current.Window then\\\
Current.Window:Draw()\\\
end\\\
if not Current.InterfaceVisible then\\\
ShowInterfaceButton:Draw()\\\
end\\\
Drawing.DrawBuffer()\\\
if Current.Input and not Current.Menu then\\\
term.setCursorPos(Current.CursorPos[1],Current.CursorPos[2])\\\
term.setCursorBlink(true)\\\
term.setTextColour(Current.CursorColour)\\\
else\\\
term.setCursorBlink(false)\\\
end\\\
if Current.Selection and Current.Selection[1]and Current.Selection[2]~=nil then\\\
Current.SelectionDrawTimer=os.startTimer(.5)\\\
end\\\
isDrawing=false\\\
if needsDraw then\\\
Draw()\\\
end\\\
end\\\
function LoadMenuBar()\\\
Current.MenuBar=MenuBar:Initialise({\\\
Button:Initialise(1,1,nil,nil,colours.grey,Current.MenuBar,function(e,a,a,a,t)\\\
if t then\\\
Menu:New(1,2,{\\\
{\\\
Title=\\\"New...\\\",\\\
Click=function()\\\
DisplayNewDocumentWindow()\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.n\\\
}\\\
},\\\
{\\\
Title='Open...',\\\
Click=function()\\\
DisplayOpenDocumentWindow()\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.o\\\
}\\\
},\\\
{\\\
Separator=true\\\
},\\\
{\\\
Title='Save...',\\\
Click=function()\\\
Current.Artboard:Save()\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.s\\\
},\\\
Enabled=function()\\\
return CheckOpenArtboard()\\\
end\\\
},\\\
{\\\
Separator=true\\\
},\\\
{\\\
Title='Quit',\\\
Click=function()\\\
if Close()then\\\
OneOS.Close()\\\
end\\\
end\\\
},\\\
},e,true)\\\
else\\\
Current.Menu=nil\\\
end\\\
return true\\\
end,'File',colours.lightGrey,false),\\\
Button:Initialise(7,1,nil,nil,colours.grey,Current.MenuBar,function(e,t,t,t,t)\\\
if not e.Toggle then\\\
Menu:New(7,2,{\\\
{\\\
Title='Cut',\\\
Click=function()\\\
Clipboard.Cut(Current.Layer:PixelsInSelection(true),'sketchpixels')\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.x\\\
},\\\
Enabled=function()\\\
return Current.Selection and Current.Selection[1]and Current.Selection[2]~=nil\\\
end\\\
},\\\
{\\\
Title='Copy',\\\
Click=function()\\\
Clipboard.Copy(Current.Layer:PixelsInSelection(),'sketchpixels')\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.c\\\
},\\\
Enabled=function()\\\
return Current.Selection and Current.Selection[1]and Current.Selection[2]~=nil\\\
end\\\
},\\\
{\\\
Title='Paste',\\\
Click=function()\\\
Current.Layer:InsertPixels(Clipboard.Paste())\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.v\\\
},\\\
Enabled=function()\\\
return(not Clipboard.isEmpty())and Clipboard.Type=='sketchpixels'\\\
end\\\
}\\\
},e,true)\\\
else\\\
Current.Menu=nil\\\
end\\\
return true\\\
end,'Edit',colours.lightGrey,false),\\\
Button:Initialise(13,1,nil,nil,colours.grey,Current.MenuBar,function(i,t,t,t,e)\\\
if e then\\\
Menu:New(13,2,{\\\
{\\\
Title=\\\"Resize...\\\",\\\
Click=function()\\\
ResizeDocument()\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.r\\\
},\\\
Enabled=function()\\\
return CheckOpenArtboard()\\\
end\\\
},\\\
{\\\
Title=\\\"Crop\\\",\\\
Click=function()\\\
local o=0\\\
local a=0\\\
local t=0\\\
local e=0\\\
if Current.Selection[1].x<Current.Selection[2].x then\\\
a=Current.Selection[1].x-1\\\
e=Current.Artboard.Width-Current.Selection[2].x\\\
else\\\
a=Current.Selection[2].x-1\\\
e=Current.Artboard.Width-Current.Selection[1].x\\\
end\\\
if Current.Selection[1].y<Current.Selection[2].y then\\\
o=Current.Selection[1].y-1\\\
t=Current.Artboard.Height-Current.Selection[2].y\\\
else\\\
o=Current.Selection[2].y-1\\\
t=Current.Artboard.Height-Current.Selection[1].y\\\
end\\\
Current.Artboard:Resize(-1*o,-1*t,-1*a,-1*e)\\\
Current.Selection[2]=nil\\\
end,\\\
Enabled=function()\\\
if CheckSelectedLayer()and Current.Selection and Current.Selection[1]and Current.Selection[2]~=nil then\\\
return true\\\
else\\\
return false\\\
end\\\
end\\\
},\\\
{\\\
Separator=true\\\
},\\\
{\\\
Title='New Layer...',\\\
Click=function()\\\
MakeNewLayer()\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.l\\\
},\\\
Enabled=function()\\\
return CheckOpenArtboard()\\\
end\\\
},\\\
{\\\
Title='Delete Layer',\\\
Click=function()\\\
DeleteLayer()\\\
end,\\\
Enabled=function()\\\
return CheckSelectedLayer()\\\
end\\\
},\\\
{\\\
Title='Rename Layer...',\\\
Click=function()\\\
RenameLayer()\\\
end,\\\
Enabled=function()\\\
return CheckSelectedLayer()\\\
end\\\
},\\\
{\\\
Separator=true\\\
},\\\
{\\\
Title='Erase Selection',\\\
Click=function()\\\
Current.Layer:EraseSelection()\\\
end,\\\
Keys={\\\
keys.delete\\\
},\\\
Enabled=function()\\\
if CheckSelectedLayer()and Current.Selection and Current.Selection[1]and Current.Selection[2]~=nil then\\\
return true\\\
else\\\
return false\\\
end\\\
end\\\
},\\\
{\\\
Separator=true\\\
},\\\
{\\\
Title='Hide Interface',\\\
Click=function()\\\
Current.InterfaceVisible=not Current.InterfaceVisible\\\
end,\\\
Keys={\\\
keys.tab\\\
}\\\
}\\\
},i,true)\\\
else\\\
Current.Menu=nil\\\
end\\\
return true\\\
end,'Image',colours.lightGrey,false),\\\
Button:Initialise(20,1,nil,nil,colours.grey,Current.MenuBar,function(a,t,t,t,e)\\\
if e then\\\
local t={{\\\
Title=\\\"Change Size\\\",\\\
Click=function()\\\
DisplayToolSizeWindow()\\\
end,\\\
Keys={\\\
keys.leftCtrl,\\\
keys.t\\\
}\\\
},\\\
{\\\
Separator=true\\\
}\\\
}\\\
local o={'h','p','e','f','s','m','t'}\\\
for a,e in ipairs(Tools)do\\\
table.insert(t,{\\\
Title=e.Name,\\\
Click=function()\\\
SetTool(e)\\\
local e=ModuleNamed('Tools')\\\
e:Update(e.ToolbarItem)\\\
end,\\\
Keys={\\\
keys[o[a]]\\\
},\\\
Enabled=function()\\\
return CheckOpenArtboard()\\\
end\\\
})\\\
end\\\
Menu:New(20,2,t,a,true)\\\
else\\\
Current.Menu=nil\\\
end\\\
return true\\\
end,'Tools',colours.lightGrey,false),\\\
})\\\
end\\\
function Timer(t,e)\\\
if e==Current.ControlPressedTimer then\\\
Current.ControlPressedTimer=nil\\\
elseif e==Current.SelectionDrawTimer then\\\
if Current.Artboard then\\\
Current.Artboard.SelectionIsBlack=not Current.Artboard.SelectionIsBlack\\\
Draw()\\\
end\\\
end\\\
end\\\
function Initialise(e)\\\
if not OneOS then\\\
SplashScreen()\\\
end\\\
EventRegister('mouse_click',TryClick)\\\
EventRegister('mouse_drag',function(o,a,t,e)TryClick(o,a,t,e,true)end)\\\
EventRegister('mouse_scroll',Scroll)\\\
EventRegister('key',HandleKey)\\\
EventRegister('char',HandleKey)\\\
EventRegister('timer',Timer)\\\
EventRegister('terminate',function(e)if Close()then error(\\\"Terminated\\\",0)end end)\\\
Current.Toolbar=Toolbar:New('right',true)\\\
for t,e in pairs(Modules)do\\\
e:Initialise()\\\
end\\\
term.setBackgroundColour(UIColours.Background)\\\
term.clear()\\\
LoadMenuBar()\\\
local t=fs\\\
if OneOS then\\\
t=OneOS.FS\\\
end\\\
if e and t.exists(e)then\\\
OpenDocument(e)\\\
else\\\
DisplayNewDocumentWindow()\\\
Current.Window.Visible=false\\\
end\\\
ShowInterfaceButton=Button:Initialise(Drawing.Screen.Width-15,1,nil,1,colours.grey,nil,function(e)\\\
Current.InterfaceVisible=true\\\
Draw()\\\
end,'Show Interface')\\\
Draw()\\\
if Current.Window then\\\
Current.Window.Visible=true\\\
Draw()\\\
end\\\
EventHandler()\\\
end\\\
function SplashScreen()\\\
local e={{1,1,1,256,256,256,256,256,256,256,256,1,1,1,},{1,256,256,8,8,8,8,8,8,8,8,256,256,1,},{256,8,8,8,8,8,8,8,8,8,8,8,8,256,},{256,256,256,8,8,8,8,8,8,8,8,256,256,256,},{256,256,256,256,256,256,256,256,256,256,256,256,256,256,},{2048,2048,256,256,256,256,256,256,256,256,256,256,2048,2048,},{2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,},{2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,},{2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,},{2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,},{256,256,2048,2048,2048,2048,2048,2048,2048,2048,2048,2048,256,256,},{1,256,256,256,256,256,256,256,256,256,256,256,256,1,},{1,1,1,256,256,256,256,256,256,256,256,1,1,1,},[\\\"text\\\"]={{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\"S\\\",\\\"k\\\",\\\"e\\\",\\\"t\\\",\\\"c\\\",\\\"h\\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\"b\\\",\\\"y\\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\"o\\\",\\\"e\\\",\\\"e\\\",\\\"d\\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},{\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",\\\" \\\",},},[\\\"textcol\\\"]={{32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,},{32768,32768,32768,256,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,},{32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,},{32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,},{32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,},{32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,},{32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,},{32768,32768,32768,32768,1,1,1,1,1,1,32768,32768,32768,32768,},{32768,32768,32768,32768,8,8,8,8,8,8,8,32768,32768,32768,},{32768,32768,32768,32768,1,1,1,1,1,32768,8,32768,32768,32768,},{32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,},{32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,},{32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,},},}\\\
Drawing.Clear(colours.white)\\\
Drawing.DrawImage((Drawing.Screen.Width-14)/2,(Drawing.Screen.Height-13)/2,e,14,13)\\\
Drawing.DrawBuffer()\\\
parallel.waitForAny(function()sleep(1)end,function()os.pullEvent('mouse_click')end)\\\
end\\\
LongestString=function(e,a)\\\
local t=0\\\
for o=1,#e do\\\
local e=e[o]\\\
if a then\\\
if e[a]then\\\
e=e[a]\\\
else\\\
e=''\\\
end\\\
end\\\
local e=string.len(e)\\\
if e>t then\\\
t=e\\\
end\\\
end\\\
return t\\\
end\\\
function HandleKey(...)\\\
local e={...}\\\
local a=e[1]\\\
local t=e[2]\\\
if a=='key'and Current.Tool and Current.Tool.Name=='Text'and Current.Input and(t==keys.up or t==keys.down or t==keys.left or t==keys.right)then\\\
local e={Current.CursorPos[1]-Current.Artboard.X+1,Current.CursorPos[2]-Current.Artboard.Y+1}\\\
if t==keys.up then\\\
e[2]=e[2]-1\\\
elseif t==keys.down then\\\
e[2]=e[2]+1\\\
elseif t==keys.left then\\\
e[1]=e[1]-1\\\
elseif t==keys.right then\\\
e[1]=e[1]+1\\\
end\\\
if e[1]<1 then\\\
e[1]=1\\\
end\\\
if e[1]>Current.Artboard.Width then\\\
e[1]=Current.Artboard.Width\\\
end\\\
if e[2]<1 then\\\
e[2]=1\\\
end\\\
if e[2]>Current.Artboard.Height then\\\
e[2]=Current.Artboard.Height\\\
end\\\
Current.Tool:Use(e[1],e[2])\\\
Current.Modified=true\\\
Draw()\\\
elseif Current.Input then\\\
if a=='char'then\\\
Current.Input:Char(t)\\\
elseif a=='key'then\\\
Current.Input:Key(t)\\\
end\\\
elseif a=='key'then\\\
CheckKeyboardShortcut(t)\\\
end\\\
end\\\
function Scroll(t,e,t,t)\\\
if Current.Window and Current.Window.OpenButton then\\\
Current.Window.Scroll=Current.Window.Scroll+e\\\
if Current.Window.Scroll<0 then\\\
Current.Window.Scroll=0\\\
elseif Current.Window.Scroll>Current.Window.MaxScroll then\\\
Current.Window.Scroll=Current.Window.MaxScroll\\\
end\\\
end\\\
Draw()\\\
end\\\
function CheckKeyboardShortcut(t)\\\
local e={}\\\
if t==keys.leftCtrl then\\\
Current.ControlPressedTimer=os.startTimer(.5)\\\
return\\\
end\\\
if Current.ControlPressedTimer then\\\
e[keys.n]=function()DisplayNewDocumentWindow()end\\\
e[keys.o]=function()DisplayOpenDocumentWindow()end\\\
e[keys.s]=function()Current.Artboard:Save()end\\\
e[keys.x]=function()if Current.Selection and Current.Selection[1]and Current.Selection[2]~=nil then Clipboard.Cut(Current.Layer:PixelsInSelection(true),'sketchpixels')end end\\\
e[keys.c]=function()if Current.Selection and Current.Selection[1]and Current.Selection[2]~=nil then Clipboard.Copy(Current.Layer:PixelsInSelection(),'sketchpixels')end end\\\
e[keys.v]=function()if(not Clipboard.isEmpty())and Clipboard.Type=='sketchpixels'then Current.Layer:InsertPixels(Clipboard.Paste())end end\\\
e[keys.r]=function()ResizeDocument()end\\\
e[keys.l]=function()MakeNewLayer()end\\\
end\\\
e[keys.delete]=function()if CheckSelectedLayer()and Current.Selection and Current.Selection[1]and Current.Selection[2]~=nil then Current.Layer:EraseSelection()Draw()end end\\\
e[keys.backspace]=e[keys.delete]\\\
e[keys.tab]=function()Current.InterfaceVisible=not Current.InterfaceVisible Draw()end\\\
e[keys.h]=function()SetTool(ToolNamed('Hand'))ModuleNamed('Tools'):Update()Draw()end\\\
e[keys.e]=function()SetTool(ToolNamed('Eraser'))ModuleNamed('Tools'):Update()Draw()end\\\
e[keys.p]=function()SetTool(ToolNamed('Pencil'))ModuleNamed('Tools'):Update()Draw()end\\\
e[keys.f]=function()SetTool(ToolNamed('Fill Bucket'))ModuleNamed('Tools'):Update()Draw()end\\\
e[keys.m]=function()SetTool(ToolNamed('Move'))ModuleNamed('Tools'):Update()Draw()end\\\
e[keys.s]=function()SetTool(ToolNamed('Select'))ModuleNamed('Tools'):Update()Draw()end\\\
e[keys.t]=function()SetTool(ToolNamed('Text'))ModuleNamed('Tools'):Update()Draw()end\\\
if e[t]then\\\
e[t]()\\\
return true\\\
else\\\
return false\\\
end\\\
end\\\
function CheckClick(e,t,a)\\\
if e.X<=t and e.Y<=a and e.X+e.Width>t and e.Y+e.Height>a then\\\
return true\\\
end\\\
end\\\
function DoClick(e,i,a,t,o)\\\
if e and CheckClick(e,a,t)then\\\
return e:Click(i,a-e.X+1,t-e.Y+1,o)\\\
end\\\
end\\\
function TryClick(e,a,i,o,t)\\\
if Current.InterfaceVisible and Current.Menu then\\\
if DoClick(Current.Menu,a,i,o,t)then\\\
Draw()\\\
return\\\
else\\\
if Current.Menu.Owner and Current.Menu.Owner.Toggle then\\\
Current.Menu.Owner.Toggle=false\\\
end\\\
Current.Menu=nil\\\
Draw()\\\
return\\\
end\\\
elseif Current.Window then\\\
if DoClick(Current.Window,a,i,o,t)then\\\
Draw()\\\
return\\\
else\\\
Current.Window:Flash()\\\
return\\\
end\\\
end\\\
local e={}\\\
if Current.InterfaceVisible then\\\
table.insert(e,Current.MenuBar)\\\
else\\\
table.insert(e,ShowInterfaceButton)\\\
end\\\
for a,t in ipairs(Lists.Interface.Toolbars)do\\\
for a,t in ipairs(t.ToolbarItems)do\\\
table.insert(e,t)\\\
end\\\
table.insert(e,t)\\\
end\\\
table.insert(e,Current.Artboard)\\\
for n,e in ipairs(e)do\\\
if DoClick(e,a,i,o,t)then\\\
Draw()\\\
return\\\
end\\\
end\\\
Draw()\\\
end\\\
function EventRegister(e,t)\\\
if not Events[e]then\\\
Events[e]={}\\\
end\\\
table.insert(Events[e],t)\\\
end\\\
function EventHandler()\\\
while true do\\\
local e,t,a,i,n=os.pullEventRaw()\\\
if Events[e]then\\\
for s,o in ipairs(Events[e])do\\\
o(e,t,a,i,n)\\\
end\\\
end\\\
end\\\
end\\\
local t={[10]=\\\"a\\\",[11]=\\\"b\\\",[12]=\\\"c\\\",[13]=\\\"d\\\",[14]=\\\"e\\\",[15]=\\\"f\\\"}\\\
local function a(e)\\\
if e==colours.transparent or not e or not tonumber(e)then\\\
return\\\" \\\"\\\
end\\\
local e=math.log(e)/math.log(2)\\\
if e>9 then\\\
e=t[e]\\\
end\\\
return e\\\
end\\\
local function h(e)\\\
if e==' 'then\\\
return colours.transparent\\\
end\\\
local e=tonumber(e,16)\\\
if not e then return nil end\\\
e=math.pow(2,e)\\\
return e\\\
end\\\
function SaveSKCH()\\\
local t={}\\\
for a,e in ipairs(Current.Artboard.Layers)do\\\
local a=SaveNFT(a)\\\
local e={\\\
Name=e.Name,\\\
Pixels=a,\\\
BackgroundColour=e.BackgroundColour,\\\
Visible=e.Visible,\\\
Index=e.Index,\\\
}\\\
table.insert(t,e)\\\
end\\\
return t\\\
end\\\
function SaveNFT(t)\\\
t=t or 1\\\
local n={}\\\
local h=Current.Artboard.Width\\\
local e=Current.Artboard.Height\\\
for s=1,e do\\\
local e=''\\\
local i=nil\\\
local o=nil\\\
for n=1,h do\\\
local t=Current.Artboard.Layers[t].Pixels[n][s]\\\
if t.BackgroundColour~=i then\\\
e=e..string.char(30)..a(t.BackgroundColour)\\\
i=t.BackgroundColour\\\
end\\\
if t.TextColour~=o then\\\
e=e..string.char(31)..a(t.TextColour)\\\
o=t.TextColour\\\
end\\\
e=e..t.Character\\\
end\\\
table.insert(n,e)\\\
end\\\
return n\\\
end\\\
function SaveNFP()\\\
local t={}\\\
local o=Current.Artboard.Width\\\
local e=Current.Artboard.Height\\\
for i=1,e do\\\
local e=''\\\
for t=1,o do\\\
e=e..a(Current.Artboard.Layers[1].Pixels[t][i].BackgroundColour)\\\
end\\\
table.insert(t,e)\\\
end\\\
return t\\\
end\\\
function ReadNFP(t)\\\
local a={}\\\
local e=fs\\\
if OneOS then\\\
e=OneOS.FS\\\
end\\\
local o=e.open(t,'r')\\\
local t=o.readLine()\\\
local i=1\\\
while t do\\\
for e=1,#t do\\\
if not a[e]then\\\
a[e]={}\\\
end\\\
a[e][i]={BackgroundColour=h(t:sub(e,e))}\\\
end\\\
i=i+1\\\
t=o.readLine()\\\
end\\\
o.close()\\\
return{{Pixels=a}}\\\
end\\\
function ReadNFT(t)\\\
local e=fs\\\
if OneOS then\\\
e=OneOS.FS\\\
end\\\
local t=e.open(t,'r')\\\
local e=t.readLine()\\\
local a={}\\\
while e do\\\
table.insert(a,e)\\\
e=t.readLine()\\\
end\\\
t.close()\\\
return{{Pixels=ParseNFT(a)}}\\\
end\\\
function ParseNFT(e)\\\
local a={}\\\
for d,r in ipairs(e)do\\\
local s,n=false,false\\\
local o,i=nil,nil\\\
local t=1\\\
for e=1,#r do\\\
if not a[t]then\\\
a[t]={}\\\
end\\\
local e=string.sub(r,e,e)\\\
if e:byte()==30 then\\\
s=true\\\
elseif e:byte()==31 then\\\
n=true\\\
elseif s then\\\
o=h(e)\\\
if o==nil then\\\
o=colours.transparent\\\
end\\\
s=false\\\
elseif n then\\\
i=h(e)\\\
n=false\\\
else\\\
if e~=\\\" \\\"and i==nil then\\\
i=colours.white\\\
end\\\
a[t][d]={BackgroundColour=o,TextColour=i,Character=e}\\\
t=t+1\\\
end\\\
end\\\
end\\\
return a\\\
end\\\
function ReadSKCH(t)\\\
local e=fs\\\
if OneOS then\\\
e=OneOS.FS\\\
end\\\
local e=e.open(t,'r')\\\
local a=textutils.unserialize(e.readAll())\\\
e.close()\\\
local t={}\\\
for a,e in ipairs(a)do\\\
local e={\\\
Name=e.Name,\\\
Pixels=ParseNFT(e.Pixels),\\\
BackgroundColour=e.BackgroundColour,\\\
Visible=e.Visible,\\\
Index=e.Index,\\\
}\\\
table.insert(t,e)\\\
end\\\
return t\\\
end\\\
if term.isColor and term.isColor()then\\\
Initialise(...)\\\
else\\\
print('Sorry, but Sketch only works on Advanced (gold) Computers')\\\
end\",\
    [ \"System/Programs/Files.program/images/Unknown\" ] = \"8f b  f  \\\
8b  7?b  \\\
8f b 7?b f \\\
8f  b   \",\
    [ \"System/API/Environment.lua\" ] = \"--[[\\\
\\\
This essentially allows the programs to run sandboxed. For example, os.shutdown doesn't shut the entire computer down. Instead, it simply stops the program.\\\
\\\
]]\\\
\\\
local errorHandler = function(program, apiName, name, value)\\\
	if type(value) ~= 'function' then\\\
		return value\\\
	end\\\
	return function(...)local response = {pcall(value, ...)}\\\
				local ok = response[1]\\\
				table.remove(response, 1)\\\
				if ok then\\\
					return unpack(response)\\\
				else\\\
					for i, err in ipairs(response) do\\\
						printError(apiName .. ' Error ('..name..'): /System/API/' .. err)\\\
				    	Log.e('['..program.Title..'] Environment Error: '..apiName .. ' Error ('..name..'): /System/API/' .. err)\\\
					end\\\
\\\
				end\\\
			end\\\
end\\\
\\\
function addErrorHandler(program, api, apiName)\\\
	local newApi = {}\\\
	for k, v in pairs(api) do\\\
		newApi[k] = errorHandler(program, apiName, k, v)\\\
	end\\\
	return newApi\\\
end\\\
\\\
--[[\\\
cleanEnvironment.package = {\\\
	config = {\\\"/\\\", \\\";\\\", \\\"?\\\", \\\"!\\\", \\\"-\\\"},\\\
	loaded = _G,\\\
	preload = {},\\\
	path = \\\"/rom/apis/?;/rom/apis/?.lua;/rom/apis/?/init.lua;/rom/modules/main/?;rom/modules/main/?.lua;/rom/modules/main/?/init.lua\\\"\\\
}\\\
--]]\\\
\\\
GetCleanEnvironment = function(self)\\\
	local cleanEnv = {}\\\
	for k, v in pairs(cleanEnvironment) do\\\
		cleanEnv[k] = v\\\
	end\\\
	return cleanEnv\\\
end\\\
\\\
Initialise = function(self, program, shell, path)\\\
	local env = {}    -- the new instance\\\
	local cleanEnv = self:GetCleanEnvironment()\\\
	setmetatable( env, {__index = cleanEnv} )\\\
	env._G = cleanEnv\\\
	env.fs = addErrorHandler(program, self.FS(env, program, path), 'FS API')\\\
	env.io = addErrorHandler(program, self.IO(env, program, path), 'IO API')\\\
	env.os = addErrorHandler(program, self.OS(env, program, path), 'OS API')\\\
	env.loadfile = function( _sFile)\\\
		local file = env.fs.open( _sFile, \\\"r\\\")\\\
		if file then\\\
			local func, err = loadstring( file.readAll(), env.fs.getName( _sFile) )\\\
			file.close()\\\
			return func, err\\\
		end\\\
		return nil, \\\"File not found\\\"\\\
	end\\\
\\\
	env.dofile = function( _sFile )\\\
		local fnFile, e = env.loadfile( _sFile )\\\
		if fnFile then\\\
			setfenv( fnFile, getfenv(2) )\\\
			return fnFile()\\\
		else\\\
			error( e, 2 )\\\
		end\\\
	end\\\
\\\
	local tColourLookup = {}\\\
	for n=1,16 do\\\
		tColourLookup[ string.byte( \\\"0123456789abcdef\\\",n,n ) ] = 2^(n-1)\\\
	end\\\
\\\
	env.textutils.slowWrite = function( sText, nRate )\\\
		nRate = nRate or 20\\\
		if nRate < 0 then\\\
			error( \\\"rate must be positive\\\" )\\\
		end\\\
		local nSleep = 1 / nRate\\\
\\\
		sText = tostring( sText )\\\
		local x,y = term.getCursorPos(x,y)\\\
		local len = string.len( sText )\\\
\\\
		for n=1,len do\\\
			term.setCursorPos( x, y )\\\
			env.os.sleep( nSleep )\\\
			local nLines = write( string.sub( sText, 1, n ) )\\\
			local newX, newY = term.getCursorPos()\\\
			y = newY - nLines\\\
		end\\\
	end\\\
\\\
	env.textutils.slowPrint = function( sText, nRate )\\\
		env.textutils.slowWrite( sText, nRate)\\\
		print()\\\
	end\\\
\\\
	env.paintutils.loadImage = function( sPath )\\\
		local relPath = Helpers.RemoveFileName(path) .. sPath\\\
		local tImage = {}\\\
		if fs.exists( relPath ) then\\\
			local file = io.open(relPath, \\\"r\\\" )\\\
			local sLine = file:read()\\\
			while sLine do\\\
				local tLine = {}\\\
				for x=1,sLine:len() do\\\
					tLine[x] = tColourLookup[ string.byte(sLine,x,x) ] or 0\\\
				end\\\
				table.insert( tImage, tLine )\\\
				sLine = file:read()\\\
			end\\\
			file:close()\\\
			return tImage\\\
		end\\\
		return nil\\\
	end\\\
	env.shell = {}\\\
	local shellEnv = {}\\\
	setmetatable( shellEnv, { __index = env } )\\\
	setfenv(self.Shell, shellEnv)\\\
	self.Shell(env, program, shell, path, Helpers, os.run)\\\
	env.shell = addErrorHandler(program, shellEnv, 'Shell')\\\
	env.OneOS = addErrorHandler(program, self.OneOS(env, program, path), 'OneOS API')\\\
	env.sleep = env.os.sleep\\\
	return env\\\
end\\\
\\\
IO = function(env, program, path)\\\
	local relPath = Helpers.RemoveFileName(path)\\\
	return {\\\
		input = io.input,\\\
		output = io.output,\\\
		type = io.type,\\\
		close = io.close,\\\
		write = io.write,\\\
		flush = io.flush,\\\
		lines = io.lines,\\\
		read = io.read,\\\
		open = function(_path, mode)\\\
			return io.open(relPath .. _path, mode)\\\
		end\\\
	}\\\
end\\\
\\\
OneOS = function(env, program, path)\\\
	local h = fs.open('/System/.version', 'r')\\\
	local version = h.readAll()\\\
	h.close()\\\
\\\
	local tAPIsLoading = {}\\\
	return {\\\
		ToolBarColour = colours.white,\\\
		ToolBarColor = colours.white,\\\
		ToolBarTextColor = colours.black,\\\
		ToolBarTextColour = colours.black,\\\
		OpenFile = Helpers.OpenFile,\\\
		Helpers = Helpers,\\\
		Settings = Settings,\\\
		Version = version,\\\
		Restart = function(f)Restart(f, false)end,\\\
		Reboot = function(f)Restart(f, false)end,\\\
		Shutdown = function(f)Shutdown(f, false, true)end,\\\
		KillSystem = function()os.reboot()end,\\\
		Clipboard = Clipboard,\\\
		FS = fs,\\\
		OSRun = os.run,\\\
		Shell = shell,\\\
		ProgramLocation = program.Path,\\\
		SetTitle = function(title)\\\
			if title and type(title) == 'string' then\\\
				program.Title = title\\\
			end\\\
			UpdateOverlay()\\\
		end,\\\
		CanClose = function()end,\\\
		Close = function()\\\
			program:Close(true)\\\
		end,\\\
		Run = function(path, ...)\\\
			local args = {...}\\\
			if fs.isDir(path) and fs.exists(path..'/startup') then\\\
				Program:Initialise(shell, path..'/startup', Helpers.RemoveExtension(fs.getName(path)), args)\\\
			elseif not fs.isDir(path) then\\\
				Program:Initialise(shell, path, Helpers.RemoveExtension(fs.getName(path)), args)\\\
			end\\\
		end,\\\
		LoadAPI = function(_sPath, global)\\\
			local sName = Helpers.RemoveExtension(fs.getName( _sPath))\\\
			if tAPIsLoading[sName] == true then\\\
				env.printError( \\\"API \\\"..sName..\\\" is already being loaded\\\" )\\\
				return false\\\
			end\\\
			tAPIsLoading[sName] = true\\\
\\\
			local tEnv = {}\\\
			setmetatable( tEnv, { __index = env } )\\\
			if not global == false then\\\
				tEnv.fs = fs\\\
			end\\\
			local fnAPI, err = loadfile( _sPath)\\\
			if fnAPI then\\\
				setfenv( fnAPI, tEnv )\\\
				fnAPI()\\\
			else\\\
				printError( err )\\\
		        tAPIsLoading[sName] = nil\\\
				return false\\\
			end\\\
\\\
			local tAPI = {}\\\
			for k,v in pairs( tEnv ) do\\\
				tAPI[k] =  v\\\
			end\\\
\\\
			env[sName] = tAPI\\\
			tAPIsLoading[sName] = nil\\\
			return true\\\
		end,\\\
		LoadFile = function( _sFile)\\\
			local file = fs.open( _sFile, \\\"r\\\")\\\
			if file then\\\
				local func, err = loadstring( file.readAll(), fs.getName( _sFile) )\\\
				file.close()\\\
				return func, err\\\
			end\\\
			return nil, \\\"File not found\\\"\\\
		end,\\\
		LoadString = loadstring,\\\
		IO = io,\\\
		DoesRunAtStartup = function()\\\
			if not Settings:GetValues()['StartupProgram'] then\\\
				return false\\\
			end\\\
			return Helpers.TidyPath('/Programs/'..Settings:GetValues()['StartupProgram']..'/startup') == Helpers.TidyPath(path)\\\
		end,\\\
		RequestRunAtStartup = function()\\\
			if Settings:GetValues()['StartupProgram'] and Helpers.TidyPath('/Programs/'..Settings:GetValues()['StartupProgram']..'/startup') == Helpers.TidyPath(path) then\\\
				return\\\
			end\\\
			local settings = Settings:GetValues()\\\
			local onBlacklist = false\\\
			local h = fs.open('/System/.StartupBlacklist.settings', 'r')\\\
			if h then\\\
				local blacklist = textutils.unserialize(h.readAll())\\\
				h.close()\\\
				for i, v in ipairs(blacklist) do\\\
					if v == Helpers.TidyPath(path) then\\\
						onBlacklist = true\\\
						return\\\
					end\\\
				end\\\
			end\\\
\\\
			if not settings['StartupProgram'] or not Helpers.TidyPath('/Programs/'..settings['StartupProgram']..'/startup') == Helpers.TidyPath(path) then\\\
				Current.Bedrock:DisplayAlertWindow(\\\"Run at startup?\\\", \\\"Would you like run \\\"..Helpers.RemoveExtension(fs.getName(Helpers.RemoveFileName(path)))..\\\" when you turn your computer on?\\\", {\\\"Yes\\\", \\\"No\\\", \\\"Never Ask\\\"}, function(value)\\\
					if value == 'Yes' then\\\
						Settings:SetValue('StartupProgram', fs.getName(Helpers.RemoveFileName(path)))\\\
					elseif value == 'Never Ask' then\\\
						local h = fs.open('/System/.StartupBlacklist.settings', 'r')\\\
						local blacklist = {}\\\
						if h then\\\
							blacklist = textutils.unserialize(h.readAll())\\\
							h.close()\\\
						end\\\
						table.insert(blacklist, Helpers.TidyPath(path))\\\
						local h = fs.open('/System/.StartupBlacklist.settings', 'w')\\\
						if h then\\\
							h.write(textutils.serialize(blacklist))\\\
							h.close()\\\
						end\\\
					end\\\
				end)\\\
			end\\\
		end,\\\
		Log = {\\\
			i = function(msg)Log.i('['..program.Title..'] '..tostring(msg))end,\\\
			w = function(msg)Log.w('['..program.Title..'] '..tostring(msg))end,\\\
			e = function(msg)Log.e('['..program.Title..'] '..tostring(msg))end,\\\
		}\\\
	}\\\
end\\\
\\\
FS = function(env, program, path)\\\
	local function doIndex()\\\
		Current.Bedrock:StartTimer(Indexer.DoIndex, 4)\\\
	end\\\
	local relPath = Helpers.RemoveFileName(path)\\\
	local list = {}\\\
	for k, f in pairs(fs) do\\\
		if k ~= 'open' and k ~= 'combine' and k ~= 'copy' and k ~= 'move' and k ~= 'delete' and k ~= 'makeDir' then\\\
			list[k] = function(_path)\\\
				return fs[k](relPath .. _path)\\\
			end\\\
		elseif k == 'delete' or k == 'makeDir' then\\\
			list[k] = function(_path)\\\
				doIndex()\\\
				return fs[k](relPath .. _path)\\\
			end\\\
		elseif k == 'copy' or k == 'move' then\\\
			list[k] = function(_path, _path2)\\\
				doIndex()\\\
				return fs[k](relPath .. _path, relPath .. _path2)\\\
			end\\\
		elseif k == 'combine' then\\\
			list[k] = function(_path, _path2)\\\
				return fs[k](_path, _path2)\\\
			end\\\
		elseif k == 'open' then\\\
			list[k] = function(_path, mode)\\\
				if mode ~= 'r' then\\\
					doIndex()\\\
				end\\\
				return fs[k](relPath .. _path, mode)\\\
			end\\\
		end\\\
	end\\\
	return list\\\
end\\\
\\\
OS = function(env, program, path)\\\
	local tAPIsLoading = {}\\\
	_os = {\\\
\\\
		version = os.version,\\\
\\\
		getComputerID = os.getComputerID,\\\
\\\
		getComputerLabel = os.getComputerLabel,\\\
\\\
		setComputerLabel = os.setComputerLabel,\\\
\\\
		run = function( _tEnv, _sPath, ... )\\\
		    local tArgs = { ... }\\\
		    local fnFile, err = loadfile( Helpers.RemoveFileName(path) .. '/' .. _sPath )\\\
		    if fnFile then\\\
		        local tEnv = _tEnv\\\
		        --setmetatable( tEnv, { __index = function(t,k) return _G[k] end } )\\\
				setmetatable( tEnv, { __index = env} )\\\
		        setfenv( fnFile, tEnv )\\\
		        local ok, err = pcall( function()\\\
		        	fnFile( unpack( tArgs ) )\\\
		        end )\\\
		        if not ok then\\\
		        	if err and err ~= \\\"\\\" then\\\
			        	printError( err )\\\
			        end\\\
		        	return false\\\
		        end\\\
		        return true\\\
		    end\\\
		    if err and err ~= \\\"\\\" then\\\
				printError( err )\\\
			end\\\
		    return false\\\
		end,\\\
\\\
		loadAPI = function(_sPath)\\\
			local _fs = env.fs\\\
\\\
			local sName = _fs.getName( _sPath)\\\
			if tAPIsLoading[sName] == true then\\\
				env.printError( \\\"API \\\"..sName..\\\" is already being loaded\\\" )\\\
				return false\\\
			end\\\
			tAPIsLoading[sName] = true\\\
\\\
			local tEnv = {}\\\
			setmetatable( tEnv, { __index = env } )\\\
			tEnv.fs = _fs\\\
			local fnAPI, err = env.loadfile( _sPath)\\\
			if fnAPI then\\\
				setfenv( fnAPI, tEnv )\\\
				fnAPI()\\\
			else\\\
				printError( err )\\\
		        tAPIsLoading[sName] = nil\\\
				return false\\\
			end\\\
\\\
			local tAPI = {}\\\
			for k,v in pairs( tEnv ) do\\\
				tAPI[k] =  v\\\
			end\\\
\\\
			env[sName] = tAPI\\\
\\\
			tAPIsLoading[sName] = nil\\\
			return true\\\
		end,\\\
\\\
		unloadAPI = function ( _sName )\\\
			if _sName ~= \\\"_G\\\" and type(env[_sName]) == \\\"table\\\" then\\\
				env[_sName] = nil\\\
			end\\\
		end,\\\
\\\
		pullEvent = function(target)\\\
			local eventData = nil\\\
			local wait = true\\\
			while wait do\\\
				eventData = { coroutine.yield(target) }\\\
				if eventData[1] == \\\"terminate\\\" then\\\
					error( \\\"Terminated\\\", 0 )\\\
				elseif target == nil or eventData[1] == target then\\\
					wait = false\\\
				end\\\
			end\\\
			return unpack( eventData )\\\
		end,\\\
\\\
		pullEventRaw = function(target)\\\
			local eventData = nil\\\
			local wait = true\\\
			while wait do\\\
				eventData = { coroutine.yield(target) }\\\
				if target == nil or eventData[1] == target then\\\
					wait = false\\\
				end\\\
			end\\\
			return unpack( eventData )\\\
		end,\\\
\\\
		queueEvent = function(...)\\\
			program:QueueEvent(...)\\\
		end,\\\
\\\
		clock = function()\\\
			return os.clock()\\\
		end,\\\
\\\
		startTimer = function(time)\\\
			local timer = os.startTimer(time)\\\
			table.insert(program.Timers, timer)\\\
			return timer\\\
		end,\\\
\\\
		time = function()\\\
			return os.time()\\\
		end,\\\
\\\
		sleep = function(time)\\\
		    local timer = _os.startTimer( time )\\\
			repeat\\\
				local sEvent, param = _os.pullEvent( \\\"timer\\\" )\\\
			until param == timer\\\
		end,\\\
\\\
		day = function()\\\
			return os.day()\\\
		end,\\\
\\\
		setAlarm = os.setAlarm,\\\
\\\
		shutdown = function()\\\
			program:Close()\\\
		end,\\\
\\\
		reboot = function()\\\
			program:Restart()\\\
		end\\\
	}\\\
	return _os\\\
end\\\
\\\
Shell = function(env, program, nativeShell, appPath, Helpers, osrun)\\\
\\\
	local parentShell = nil--nativeShell\\\
\\\
	local bExit = false\\\
	local sDir = (parentShell and parentShell.dir()) or \\\"\\\"\\\
	local sPath = (parentShell and parentShell.path()) or \\\".:/rom/programs\\\"\\\
	local tAliases = {\\\
		ls = \\\"list\\\",\\\
		dir = \\\"list\\\",\\\
		cp = \\\"copy\\\",\\\
		mv = \\\"move\\\",\\\
		rm = \\\"delete\\\",\\\
		preview = \\\"edit\\\"\\\
	}\\\
	local tProgramStack = {fs.getName(appPath)}\\\
\\\
	-- Colours\\\
	local promptColour, textColour, bgColour\\\
	if env.term.isColour() then\\\
		promptColour = colours.yellow\\\
		textColour = colours.white\\\
		bgColour = colours.black\\\
	else\\\
		promptColour = colours.white\\\
		textColour = colours.white\\\
		bgColour = colours.black\\\
	end\\\
\\\
\\\
	local function _run( _sCommand, ... )\\\
		local sPath = nativeShell.resolveProgram(_sCommand)\\\
		if sPath == nil or sPath:sub(1,3) ~= 'rom' then\\\
			sPath = nativeShell.resolveProgram(Helpers.RemoveFileName(appPath) .. '/' ..  _sCommand )\\\
		end\\\
\\\
		if sPath ~= nil then\\\
			tProgramStack[#tProgramStack + 1] = sPath\\\
	   		local result = osrun( env, sPath, ... )\\\
			tProgramStack[#tProgramStack] = nil\\\
			return result\\\
	   	else\\\
	    	env.printError( \\\"No such program\\\" )\\\
	    	return false\\\
	    end\\\
	end\\\
\\\
	local function runLine( _sLine )\\\
		local tWords = {}\\\
		for match in string.gmatch( _sLine, \\\"[^ \\\\t]+\\\" ) do\\\
			table.insert( tWords, match )\\\
		end\\\
\\\
		local sCommand = tWords[1]\\\
		if sCommand then\\\
			return _run( sCommand, unpack( tWords, 2 ) )\\\
		end\\\
		return false\\\
	end\\\
\\\
	function run( ... )\\\
		return runLine( table.concat( { ... }, \\\" \\\" ) )\\\
	end\\\
\\\
	function exit()\\\
	    bExit = true\\\
	end\\\
\\\
	function dir()\\\
		return sDir\\\
	end\\\
\\\
	function setDir( _sDir )\\\
		sDir = _sDir\\\
	end\\\
\\\
	function path()\\\
		return sPath\\\
	end\\\
\\\
	function setPath( _sPath )\\\
		sPath = _sPath\\\
	end\\\
\\\
	function resolve( _sPath)\\\
		local sStartChar = string.sub( _sPath, 1, 1 )\\\
		if sStartChar == \\\"/\\\" or sStartChar == \\\"\\\\\\\\\\\" then\\\
			return env.fs.combine( \\\"\\\", _sPath)\\\
		else\\\
			return env.fs.combine( sDir, _sPath)\\\
		end\\\
	end\\\
\\\
	function resolveProgram( _sCommand)\\\
		-- Substitute aliases firsts\\\
		if tAliases[ _sCommand ] ~= nil then\\\
			_sCommand = tAliases[ _sCommand ]\\\
		end\\\
\\\
	    -- If the path is a global path, use it directly\\\
	    local sStartChar = string.sub( _sCommand, 1, 1 )\\\
	    if sStartChar == \\\"/\\\" or sStartChar == \\\"\\\\\\\\\\\" then\\\
	    	local sPath = fs.combine( \\\"\\\", _sCommand )\\\
	    	if fs.exists( sPath) and not fs.isDir( sPath) then\\\
				return sPath\\\
	    	end\\\
			return nil\\\
	    end\\\
\\\
	    function lookInFolder(_fPath)\\\
	    	for i, f in ipairs(fs.list(_fPath, true)) do\\\
	    		if not fs.isDir( fs.combine( _fPath, f), true) then\\\
					if f == _sCommand then\\\
						return fs.combine( _fPath, f)\\\
					end\\\
				end\\\
	    	end\\\
	    end\\\
\\\
	    local list = {Helpers.RemoveFileName(appPath), '/rom/programs/', '/rom/programs/color/', '/rom/programs/computer/'}\\\
	    if http then\\\
	    	table.insert(list, '/rom/programs/http/')\\\
	    end\\\
	    if turtle then\\\
	    	table.insert(list, '/rom/programs/turtle/')\\\
	    end\\\
	    for i, p in ipairs(list) do\\\
	    	local r = lookInFolder(p)\\\
	    	if r then\\\
	    		return r\\\
	    	end\\\
	    end\\\
\\\
		-- Not found\\\
		return nil\\\
	end\\\
\\\
	function programs( _bIncludeHidden )\\\
		local tItems = {}\\\
\\\
	    local function addFolder(_fPath)\\\
	    	for i, f in ipairs(fs.list(_fPath, true)) do\\\
	    		if not fs.isDir( fs.combine( _fPath, f), true) then\\\
					if (_bIncludeHidden or string.sub( f, 1, 1 ) ~= \\\".\\\") then\\\
						tItems[ f ] = true\\\
					end\\\
				end\\\
	    	end\\\
	    end\\\
\\\
	    addFolder('/rom/programs/')\\\
	    addFolder('/rom/programs/color/')\\\
	    addFolder('/rom/programs/computer/')\\\
	    if http then\\\
	    	addFolder('/rom/programs/http/')\\\
	    end\\\
	    if turtle then\\\
	    	addFolder('/rom/programs/turtle/')\\\
	    end\\\
	    addFolder(Helpers.RemoveFileName(appPath))\\\
\\\
		-- Sort and return\\\
		local tItemList = {}\\\
		for sItem, b in pairs( tItems ) do\\\
			table.insert( tItemList, sItem )\\\
		end\\\
		table.sort( tItemList )\\\
		return tItemList\\\
	end\\\
\\\
	function getRunningProgram()\\\
		if #tProgramStack > 0 then\\\
			return tProgramStack[#tProgramStack]\\\
		end\\\
		return nil\\\
	end\\\
\\\
	function setAlias( _sCommand, _sProgram )\\\
		tAliases[ _sCommand ] = _sProgram\\\
	end\\\
\\\
	function clearAlias( _sCommand )\\\
		tAliases[ _sCommand ] = nil\\\
	end\\\
\\\
	function aliases()\\\
		-- Add aliases\\\
		local tCopy = {}\\\
		for sAlias, sCommand in pairs( tAliases ) do\\\
			tCopy[sAlias] = sCommand\\\
		end\\\
		return tCopy\\\
	end\\\
end\",\
    [ \"Programs/LuaIDE.program/Icons/startup\" ] = \"f4>_   \\\
f4prog\\\
f    \",\
    [ \"System/Images/Boot/boot5\" ] = \"         8888          \\\
        888888         \\\
        888888         \\\
         8888          \\\
                       \\\
                       \\\
                       \\\
77777777777777788888888\",\
    [ \"Programs/Ink.program/icon\" ] = \"7f|0bInk\\\
7b 08---\\\
7f|08---\",\
    [ \"Programs/Quest.program/Elements/Script.lua\" ] = \"Text = nil\\\
URL = nil\\\
\\\
OnInitialise = function(self, node)\\\
	local attr = self.Attributes\\\
	self.Text = table.concat(node, '\\\\n')\\\
\\\
	if attr.src then\\\
		self.URL = attr.src\\\
		self.Text = nil\\\
	end\\\
end\\\
\\\
InsertScript = function(self, webView)\\\
	if self.Text then\\\
		webView:LoadScript(self.Text)\\\
	elseif self.URL then\\\
		fetchHTTPAsync(resolveFullUrl(self.URL), function(ok, event, response)\\\
			if ok then\\\
				self.Text = response.readAll()\\\
				webView:LoadScript(self.Text)\\\
			end\\\
		end)\\\
\\\
	end\\\
	return nil\\\
end\",\
    [ \"System/API/CRC32.lua\" ] = \"local CRC32 = {\\\
  0,79764919,159529838,222504665,319059676,\\\
  398814059,445009330,507990021,638119352,\\\
  583659535,797628118,726387553,890018660,\\\
  835552979,1015980042,944750013,1276238704,\\\
  1221641927,1167319070,1095957929,1595256236,\\\
  1540665371,1452775106,1381403509,1780037320,\\\
  1859660671,1671105958,1733955601,2031960084,\\\
  2111593891,1889500026,1952343757,2552477408,\\\
  2632100695,2443283854,2506133561,2334638140,\\\
  2414271883,2191915858,2254759653,3190512472,\\\
  3135915759,3081330742,3009969537,2905550212,\\\
  2850959411,2762807018,2691435357,3560074640,\\\
  3505614887,3719321342,3648080713,3342211916,\\\
  3287746299,3467911202,3396681109,4063920168,\\\
  4143685023,4223187782,4286162673,3779000052,\\\
  3858754371,3904687514,3967668269,881225847,\\\
  809987520,1023691545,969234094,662832811,\\\
  591600412,771767749,717299826,311336399,\\\
  374308984,453813921,533576470,25881363,\\\
  88864420,134795389,214552010,2023205639,\\\
  2086057648,1897238633,1976864222,1804852699,\\\
  1867694188,1645340341,1724971778,1587496639,\\\
  1516133128,1461550545,1406951526,1302016099,\\\
  1230646740,1142491917,1087903418,2896545431,\\\
  2825181984,2770861561,2716262478,3215044683,\\\
  3143675388,3055782693,3001194130,2326604591,\\\
  2389456536,2200899649,2280525302,2578013683,\\\
  2640855108,2418763421,2498394922,3769900519,\\\
  3832873040,3912640137,3992402750,4088425275,\\\
  4151408268,4197601365,4277358050,3334271071,\\\
  3263032808,3476998961,3422541446,3585640067,\\\
  3514407732,3694837229,3640369242,1762451694,\\\
  1842216281,1619975040,1682949687,2047383090,\\\
  2127137669,1938468188,2001449195,1325665622,\\\
  1271206113,1183200824,1111960463,1543535498,\\\
  1489069629,1434599652,1363369299,622672798,\\\
  568075817,748617968,677256519,907627842,\\\
  853037301,1067152940,995781531,51762726,\\\
  131386257,177728840,240578815,269590778,\\\
  349224269,429104020,491947555,4046411278,\\\
  4126034873,4172115296,4234965207,3794477266,\\\
  3874110821,3953728444,4016571915,3609705398,\\\
  3555108353,3735388376,3664026991,3290680682,\\\
  3236090077,3449943556,3378572211,3174993278,\\\
  3120533705,3032266256,2961025959,2923101090,\\\
  2868635157,2813903052,2742672763,2604032198,\\\
  2683796849,2461293480,2524268063,2284983834,\\\
  2364738477,2175806836,2238787779,1569362073,\\\
  1498123566,1409854455,1355396672,1317987909,\\\
  1246755826,1192025387,1137557660,2072149281,\\\
  2135122070,1912620623,1992383480,1753615357,\\\
  1816598090,1627664531,1707420964,295390185,\\\
  358241886,404320391,483945776,43990325,\\\
  106832002,186451547,266083308,932423249,\\\
  861060070,1041341759,986742920,613929101,\\\
  542559546,756411363,701822548,3316196985,\\\
  3244833742,3425377559,3370778784,3601682597,\\\
  3530312978,3744426955,3689838204,3819031489,\\\
  3881883254,3928223919,4007849240,4037393693,\\\
  4100235434,4180117107,4259748804,2310601993,\\\
  2373574846,2151335527,2231098320,2596047829,\\\
  2659030626,2470359227,2550115596,2947551409,\\\
  2876312838,2788305887,2733848168,3165939309,\\\
  3094707162,3040238851,2985771188,\\\
}\\\
\\\
local function rshift(num, right)\\\
  return math.floor(num/(2^right))\\\
end\\\
\\\
function Hash(str)\\\
  local crc = 2^32-1\\\
  for i, byte in pairs({str:byte(1, #str)}) do\\\
    crc = bit.bxor(bit.blshift(crc, 8), CRC32[bit.bxor(rshift(crc, 24), byte) + 1])\\\
  end\\\
  return crc\\\
end\",\
    [ \"Programs/Quest Server.program/Objects/LogView.lua\" ] = \"Inherit = 'View'\\\
Log = nil\\\
\\\
SaveLog = function(self)\\\
	local str = table.concat(self.Log, '\\\\n')\\\
	local f = fs.open('QuestServer.log', 'w')\\\
	if f then\\\
		f.write(str)\\\
		f.close()\\\
	end\\\
end\\\
\\\
AddItem = function(self, str, level)\\\
	local messageColours = {\\\
		Info 	= colours.blue,\\\
		Success	= colours.green,\\\
		Warning = colours.orange,\\\
		Error 	= colours.red,\\\
	}\\\
	table.insert(self.Log, str)\\\
\\\
	local y = 1\\\
\\\
	for i, v in ipairs(self.Children) do\\\
		y = y + v.Height\\\
	end\\\
\\\
	self:AddObject({\\\
		X = 1,\\\
		Y = y,\\\
		Width = \\\"100%\\\",\\\
		Type = 'Label',\\\
		Text = str,\\\
		TextColour = messageColours[level]\\\
	})\\\
	\\\
	self:SaveLog()\\\
end\\\
\\\
OnLoad = function(self)\\\
	self.Log = {}\\\
end\",\
    [ \"Programs/Quest.program/Objects/FormView.lua\" ] = \"Inherit = 'View'\\\
\\\
OnTab = function(self)\\\
	local active = self.Bedrock:GetActiveObject()\\\
	local selected = nil\\\
	local selectNext = false\\\
	local function node(tree)\\\
		for i, v in ipairs(tree) do\\\
			if selectNext then\\\
				if v.Type == 'TextBox' or v.Type == 'SecureTextBox' then\\\
					selected = v\\\
					return\\\
				end\\\
			elseif v == active then\\\
				selectNext = true\\\
			end\\\
			if v.Children then\\\
				node(v.Children)\\\
			end\\\
		end\\\
	end\\\
	node(self.Children)\\\
\\\
	if selected then\\\
		self.Bedrock:SetActiveObject(selected)\\\
	end\\\
end\",\
    [ \"Programs/Quest Server.program/Views/toolbar.view\" ] = \"{\\\
  [\\\"Width\\\"]=\\\"100%\\\",\\\
  [\\\"Height\\\"]=3,\\\
  [\\\"Type\\\"]=\\\"View\\\",\\\
  [\\\"BackgroundColour\\\"]=128,\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=2,\\\
      [\\\"Name\\\"]=\\\"GoStopButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\">\\\",\\\
      [\\\"BackgroundColour\\\"]=1,\\\
      [\\\"TextColour\\\"]=128\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=\\\"100%,-23\\\",\\\
      [\\\"Name\\\"]=\\\"LogButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Log\\\",\\\
      [\\\"BackgroundColour\\\"]=1,\\\
      [\\\"TextColour\\\"]=128,\\\
      [\\\"Toggle\\\"]=false\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=\\\"100%,-17\\\",\\\
      [\\\"Name\\\"]=\\\"SettingsButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Settings\\\",\\\
      [\\\"BackgroundColour\\\"]=1,\\\
      [\\\"TextColour\\\"]=128,\\\
      [\\\"Toggle\\\"]=false\\\
    },\\\
    [4]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=\\\"100%,-6\\\",\\\
      [\\\"Name\\\"]=\\\"QuitButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Quit\\\",\\\
      [\\\"BackgroundColour\\\"]=1,\\\
      [\\\"TextColour\\\"]=128\\\
    },\\\
    [5]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=6,\\\
      [\\\"Name\\\"]=\\\"StatusLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Stopped\\\",\\\
      [\\\"TextColour\\\"]=1\\\
    },\\\
  },\\\
}\",\
    [ \"System/.hash\" ] = \"1.86449353E9\",\
    [ \"System/.version\" ] = \"r1.3.4\",\
    [ \"System/API/Bedrock.lua\" ] = \"--Bedrock Build: 271\\\
--This code is squished down in to one, rather hard to read file.\\\
--As such it is not much good for anything other than being loaded as an API.\\\
--If you want to look at the code to learn from it, copy parts or just take a look,\\\
--you should go to the GitHub repo. http://github.com/oeed/Bedrock/\\\
\\\
--\\\
--		Bedrock is the core program framework used by all OneOS and OneCode programs.\\\
--							Inspired by Apple's Cocoa framework.\\\
--									   (c) oeed 2014\\\
--\\\
--		  For documentation see the Bedrock wiki, github.com/oeed/Bedrock/wiki/\\\
--\\\
\\\
local apis = {\\\
[\\\"Drawing\\\"] = [[\\\
local round = function(num, idp)\\\
	local mult = 10^(idp or 0)\\\
	return math.floor(num * mult + 0.5) / mult\\\
end\\\
\\\
local _w, _h = term.getSize()\\\
local copyBuffer = nil\\\
\\\
Screen = {\\\
	Width = _w,\\\
	Height = _h\\\
}\\\
\\\
Constraints = {\\\
	\\\
}\\\
\\\
CurrentConstraint = {1,1,_w,_h}\\\
IgnoreConstraint = false\\\
\\\
function AddConstraint(x, y, width, height)\\\
	local x2 = x + width - 1\\\
	local y2 = y + height - 1\\\
	table.insert(Drawing.Constraints, {x, y, x2, y2})\\\
	Drawing.GetConstraint()\\\
end\\\
\\\
function RemoveConstraint()\\\
	--table.remove(Drawing.Constraints, #Drawing.Constraints)\\\
	Drawing.Constraints[#Drawing.Constraints] = nil\\\
	Drawing.GetConstraint()\\\
end\\\
\\\
function GetConstraint()\\\
	local x = 1\\\
	local y = 1\\\
	local x2 = Drawing.Screen.Width\\\
	local y2 = Drawing.Screen.Height\\\
	for i, c in ipairs(Drawing.Constraints) do\\\
		if x < c[1] then\\\
			x = c[1]\\\
		end\\\
		if y < c[2] then\\\
			y = c[2]\\\
		end\\\
		if x2 > c[3] then\\\
			x2 = c[3]\\\
		end\\\
		if y2 > c[4] then\\\
			y2 = c[4]\\\
		end\\\
	end\\\
	Drawing.CurrentConstraint = {x, y, x2, y2}\\\
end\\\
\\\
function WithinContraint(x, y)\\\
	return Drawing.IgnoreConstraint or\\\
		  (x >= Drawing.CurrentConstraint[1] and\\\
		   y >= Drawing.CurrentConstraint[2] and\\\
		   x <= Drawing.CurrentConstraint[3] and\\\
		   y <= Drawing.CurrentConstraint[4])\\\
end\\\
\\\
colours.transparent = 0\\\
colors.transparent = 0\\\
\\\
Filters = {\\\
	Greyscale = {\\\
		[colours.white] = colours.white,\\\
		[colours.orange] = colours.lightGrey,\\\
		[colours.magenta] = colours.lightGrey,\\\
		[colours.lightBlue] = colours.lightGrey,\\\
		[colours.yellow] = colours.lightGrey,\\\
		[colours.lime] = colours.lightGrey,\\\
		[colours.pink] = colours.lightGrey,\\\
		[colours.grey] = colours.grey,\\\
		[colours.lightGrey] = colours.lightGrey,\\\
		[colours.cyan] = colours.grey,\\\
		[colours.purple] = colours.grey,\\\
		[colours.blue] = colours.grey,\\\
		[colours.brown] = colours.grey,\\\
		[colours.green] = colours.grey,\\\
		[colours.red] = colours.grey,\\\
		[colours.transparent] = colours.transparent,\\\
	}\\\
}\\\
\\\
function FilterColour(colour, filter)\\\
	if filter[colour] then\\\
		return filter[colour]\\\
	else\\\
		return colours.black\\\
	end\\\
end\\\
\\\
DrawCharacters = function (x, y, characters, textColour, bgColour)\\\
	Drawing.WriteStringToBuffer(x, y, tostring(characters), textColour, bgColour)\\\
end\\\
\\\
DrawBlankArea = function (x, y, w, h, colour)\\\
	if colour ~= colours.transparent then\\\
		Drawing.DrawArea (x, y, w, h, \\\" \\\", 1, colour)\\\
	end\\\
end\\\
\\\
DrawArea = function (x, y, w, h, character, textColour, bgColour)\\\
	--width must be greater than 1, otherwise we get problems\\\
	if w < 0 then\\\
		w = w * -1\\\
	elseif w == 0 then\\\
		w = 1\\\
	end\\\
\\\
	for ix = 1, w do\\\
		local currX = x + ix - 1\\\
		for iy = 1, h do\\\
			local currY = y + iy - 1\\\
			Drawing.WriteToBuffer(currX, currY, character, textColour, bgColour)\\\
		end\\\
	end\\\
end\\\
\\\
DrawImage = function(_x,_y,tImage, w, h)\\\
	if tImage then\\\
		for y = 1, h do\\\
			if not tImage[y] then\\\
				break\\\
			end\\\
			for x = 1, w do\\\
				if not tImage[y][x] then\\\
					break\\\
				end\\\
				local bgColour = tImage[y][x]\\\
	            local textColour = tImage.textcol[y][x] or colours.white\\\
	            local char = tImage.text[y][x]\\\
	            Drawing.WriteToBuffer(x+_x-1, y+_y-1, char, textColour, bgColour)\\\
			end\\\
		end\\\
	elseif w and h then\\\
		Drawing.DrawBlankArea(_x, _y, w, h, colours.lightGrey)\\\
	end\\\
end\\\
\\\
--using .nft\\\
LoadImage = function(path, global)\\\
	local image = {\\\
		text = {},\\\
		textcol = {}\\\
	}\\\
	if fs.exists(path) then\\\
		local _io = io\\\
		if OneOS and global then\\\
			_io = OneOS.IO\\\
		end\\\
        local file = _io.open(path, \\\"r\\\")\\\
        if not file then\\\
        	error('Error Occured. _io:'..tostring(_io)..' OneOS: '..tostring(OneOS)..' OneOS.IO'..tostring(OneOS.IO)..' io: '..tostring(io))\\\
        end\\\
        local sLine = file:read()\\\
        local num = 1\\\
        while sLine do  \\\
            table.insert(image, num, {})\\\
            table.insert(image.text, num, {})\\\
            table.insert(image.textcol, num, {})\\\
                                        \\\
            --As we're no longer 1-1, we keep track of what index to write to\\\
            local writeIndex = 1\\\
            --Tells us if we've hit a 30 or 31 (BG and FG respectively)- next char specifies the curr colour\\\
            local bgNext, fgNext = false, false\\\
            --The current background and foreground colours\\\
            local currBG, currFG = nil,nil\\\
            for i=1,#sLine do\\\
                    local nextChar = string.sub(sLine, i, i)\\\
                    if nextChar:byte() == 30 then\\\
                            bgNext = true\\\
                    elseif nextChar:byte() == 31 then\\\
                            fgNext = true\\\
                    elseif bgNext then\\\
                            currBG = Drawing.GetColour(nextChar)\\\
		                    if currBG == nil then\\\
		                    	currBG = colours.transparent\\\
		                    end\\\
                            bgNext = false\\\
                    elseif fgNext then\\\
                            currFG = Drawing.GetColour(nextChar)\\\
		                    if currFG == nil or currFG == colours.transparent then\\\
		                    	currFG = colours.white\\\
		                    end\\\
                            fgNext = false\\\
                    else\\\
                            if nextChar ~= \\\" \\\" and currFG == nil then\\\
                                    currFG = colours.white\\\
                            end\\\
                            image[num][writeIndex] = currBG\\\
                            image.textcol[num][writeIndex] = currFG\\\
                            image.text[num][writeIndex] = nextChar\\\
                            writeIndex = writeIndex + 1\\\
                    end\\\
            end\\\
            num = num+1\\\
            sLine = file:read()\\\
        end\\\
        file:close()\\\
    else\\\
    	return nil\\\
	end\\\
 	return image\\\
end\\\
\\\
DrawCharactersCenter = function(x, y, w, h, characters, textColour,bgColour)\\\
	w = w or Drawing.Screen.Width\\\
	h = h or Drawing.Screen.Height\\\
	x = x or 0\\\
	y = y or 0\\\
	x = math.floor((w - #characters) / 2) + x\\\
	y = math.floor(h / 2) + y\\\
\\\
	Drawing.DrawCharacters(x, y, characters, textColour, bgColour)\\\
end\\\
\\\
GetColour = function(hex)\\\
	if hex == ' ' then\\\
		return colours.transparent\\\
	end\\\
    local value = tonumber(hex, 16)\\\
    if not value then return nil end\\\
    value = math.pow(2,value)\\\
    return value\\\
end\\\
\\\
Clear = function (_colour)\\\
	_colour = _colour or colours.black\\\
	Drawing.DrawBlankArea(1, 1, Drawing.Screen.Width, Drawing.Screen.Height, _colour)\\\
end\\\
\\\
Buffer = {}\\\
BackBuffer = {}\\\
\\\
TryRestore = false\\\
\\\
\\\
--TODO: make this quicker\\\
-- maybe sort the pixels in order of colour so it doesn't have to set the colour each time\\\
DrawBuffer = function()\\\
	if TryRestore and Restore then\\\
		Restore()\\\
	end\\\
\\\
	for y,row in pairs(Drawing.Buffer) do\\\
		for x,pixel in pairs(row) do\\\
			local shouldDraw = true\\\
			local hasBackBuffer = true\\\
			if Drawing.BackBuffer[y] == nil or Drawing.BackBuffer[y][x] == nil or #Drawing.BackBuffer[y][x] ~= 3 then\\\
				hasBackBuffer = false\\\
			end\\\
			if hasBackBuffer and Drawing.BackBuffer[y][x][1] == Drawing.Buffer[y][x][1] and Drawing.BackBuffer[y][x][2] == Drawing.Buffer[y][x][2] and Drawing.BackBuffer[y][x][3] == Drawing.Buffer[y][x][3] then\\\
				shouldDraw = false\\\
			end\\\
			if shouldDraw then\\\
				term.setBackgroundColour(pixel[3])\\\
				term.setTextColour(pixel[2])\\\
				term.setCursorPos(x, y)\\\
				term.write(pixel[1])\\\
			end\\\
		end\\\
	end\\\
	Drawing.BackBuffer = Drawing.Buffer\\\
	Drawing.Buffer = {}\\\
end\\\
\\\
ClearBuffer = function()\\\
	Drawing.Buffer = {}\\\
end\\\
\\\
WriteStringToBuffer = function (x, y, characters, textColour,bgColour)\\\
	for i = 1, #characters do\\\
		local character = characters:sub(i,i)\\\
		Drawing.WriteToBuffer(x + i - 1, y, character, textColour, bgColour)\\\
	end\\\
end\\\
\\\
WriteToBuffer = function(x, y, character, textColour,bgColour, cached)\\\
	if not cached and not Drawing.WithinContraint(x, y) then\\\
		return\\\
	end\\\
	x = round(x)\\\
	y = round(y)\\\
\\\
	if textColour == colours.transparent then\\\
		character = ' '\\\
	end\\\
\\\
	if bgColour == colours.transparent then\\\
		Drawing.Buffer[y] = Drawing.Buffer[y] or {}\\\
		Drawing.Buffer[y][x] = Drawing.Buffer[y][x] or {\\\"\\\", colours.white, colours.black}\\\
		Drawing.Buffer[y][x][1] = character\\\
		Drawing.Buffer[y][x][2] = textColour\\\
	else\\\
		Drawing.Buffer[y] = Drawing.Buffer[y] or {}\\\
		Drawing.Buffer[y][x] = {character, textColour, bgColour}\\\
	end\\\
\\\
	if copyBuffer then\\\
		copyBuffer[y] = copyBuffer[y] or {}\\\
		copyBuffer[y][x] = {character, textColour, bgColour}		\\\
	end\\\
end\\\
\\\
DrawCachedBuffer = function(buffer)\\\
	for y, row in pairs(buffer) do\\\
		for x, pixel in pairs(row) do\\\
			WriteToBuffer(x, y, pixel[1], pixel[2], pixel[3], true)\\\
		end\\\
	end\\\
end\\\
\\\
StartCopyBuffer = function()\\\
	copyBuffer = {}\\\
end\\\
\\\
EndCopyBuffer = function()\\\
	local tmpCopy = copyBuffer\\\
	copyBuffer = nil\\\
	return tmpCopy\\\
end\\\
]],\\\
[\\\"Helpers\\\"] = [[\\\
LongestString = function(input, key, isKey)\\\
	local length = 0\\\
	if isKey then\\\
		for k, v in pairs(input) do\\\
			local titleLength = string.len(k)\\\
			if titleLength > length then\\\
				length = titleLength\\\
			end\\\
		end\\\
	else\\\
		for i = 1, #input do\\\
			local value = input[i]\\\
			if key then\\\
				if value[key] then\\\
					value = value[key]\\\
				else\\\
					value = ''\\\
				end\\\
			end\\\
			local titleLength = string.len(value)\\\
			if titleLength > length then\\\
				length = titleLength\\\
			end\\\
		end\\\
	end\\\
	return length\\\
end\\\
\\\
Split = function(str,sep)\\\
    sep=sep or'/'\\\
    return str:match(\\\"(.*\\\"..sep..\\\")\\\")\\\
end\\\
\\\
Extension = function(path, addDot)\\\
	if not path then\\\
		return nil\\\
	elseif not string.find(fs.getName(path), '%.') then\\\
		if not addDot then\\\
			return fs.getName(path)\\\
		else\\\
			return ''\\\
		end\\\
	else\\\
		local _path = path\\\
		if path:sub(#path) == '/' then\\\
			_path = path:sub(1,#path-1)\\\
		end\\\
		local extension = _path:gmatch('%.[0-9a-z]+$')()\\\
		if extension then\\\
			extension = extension:sub(2)\\\
		else\\\
			--extension = nil\\\
			return ''\\\
		end\\\
		if addDot then\\\
			extension = '.'..extension\\\
		end\\\
		return extension:lower()\\\
	end\\\
end\\\
\\\
RemoveExtension = function(path)\\\
--local name = string.match(fs.getName(path), '(%a+)%.?.-')\\\
	if path:sub(1,1) == '.' then\\\
		return path\\\
	end\\\
	local extension = Helpers.Extension(path)\\\
	if extension == path then\\\
		return fs.getName(path)\\\
	end\\\
	return string.gsub(path, extension, ''):sub(1, -2)\\\
end\\\
\\\
RemoveFileName = function(path)\\\
	if string.sub(path, -1) == '/' then\\\
		path = string.sub(path, 1, -2)\\\
	end\\\
	local v = string.match(path, \\\"(.-)([^\\\\\\\\/]-%.?([^%.\\\\\\\\/]*))$\\\")\\\
	if type(v) == 'string' then\\\
		return v\\\
	end\\\
	return v[1]\\\
end\\\
\\\
TruncateString = function(sString, maxLength)\\\
	if #sString > maxLength then\\\
		sString = sString:sub(1,maxLength-3)\\\
		if sString:sub(-1) == ' ' then\\\
			sString = sString:sub(1,maxLength-4)\\\
		end\\\
		sString = sString  .. '...'\\\
	end\\\
	return sString\\\
end\\\
\\\
TruncateStringStart = function(sString, maxLength)\\\
	local len = #sString\\\
	if #sString > maxLength then\\\
		sString = sString:sub(len - maxLength, len - 3)\\\
		if sString:sub(-1) == ' ' then\\\
			sString = sString:sub(len - maxLength, len - 4)\\\
		end\\\
		sString = '...' .. sString\\\
	end\\\
	return sString\\\
end\\\
\\\
WrapText = function(text, maxWidth)\\\
	local lines = {''}\\\
    for word, space in text:gmatch('(%S+)(%s*)') do\\\
            local temp = lines[#lines] .. word .. space:gsub('\\\\n','')\\\
            if #temp > maxWidth then\\\
                    table.insert(lines, '')\\\
            end\\\
            if space:find('\\\\n') then\\\
                    lines[#lines] = lines[#lines] .. word\\\
                    \\\
                    space = space:gsub('\\\\n', function()\\\
                            table.insert(lines, '')\\\
                            return ''\\\
                    end)\\\
            else\\\
                    lines[#lines] = lines[#lines] .. word .. space\\\
            end\\\
    end\\\
	return lines\\\
end\\\
\\\
TidyPath = function(path)\\\
	path = '/'..path\\\
	if fs.exists(path) and fs.isDir(path) then\\\
		path = path .. '/'\\\
	end\\\
\\\
	path, n = path:gsub(\\\"//\\\", \\\"/\\\")\\\
	while n > 0 do\\\
		path, n = path:gsub(\\\"//\\\", \\\"/\\\")\\\
	end\\\
	return path\\\
end\\\
\\\
Capitalise = function(str)\\\
	return str:sub(1, 1):upper() .. str:sub(2, -1)\\\
end\\\
\\\
Round = function(num, idp)\\\
	local mult = 10^(idp or 0)\\\
	return math.floor(num * mult + 0.5) / mult\\\
end\\\
]],\\\
[\\\"Object\\\"] = [[\\\
X = 1\\\
Y = 1\\\
Width = 1\\\
Height = 1\\\
Parent = nil\\\
OnClick = nil\\\
Visible = true\\\
IgnoreClick = false\\\
Name = nil \\\
ClipDrawing = true\\\
UpdateDrawBlacklist = {}\\\
Fixed = false\\\
\\\
DrawCache = {}\\\
\\\
NeedsDraw = function(self)\\\
	if not self.Visible then\\\
		return false\\\
	end\\\
	\\\
	if not self.DrawCache.Buffer or self.DrawCache.AlwaysDraw or self.DrawCache.NeedsDraw then\\\
		return true\\\
	end\\\
\\\
	if self.OnNeedsUpdate then\\\
		if self.OnNeedsUpdate() then\\\
			return true\\\
		end\\\
	end\\\
\\\
	if self.Children then\\\
		for i, v in ipairs(self.Children) do\\\
			if v:NeedsDraw() then\\\
				return true\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
GetPosition = function(self)\\\
	return self.Bedrock:GetAbsolutePosition(self)\\\
end\\\
\\\
GetOffsetPosition = function(self)\\\
	if not self.Parent then\\\
		return {X = 1, Y = 1}\\\
	end\\\
\\\
	local offset = {X = 0, Y = 0}\\\
	if not self.Fixed and self.Parent.ChildOffset then\\\
		offset = self.Parent.ChildOffset\\\
	end\\\
\\\
	return {X = self.X + offset.X, Y = self.Y + offset.Y}\\\
end\\\
\\\
Draw = function(self)\\\
	if not self.Visible then\\\
		return\\\
	end\\\
\\\
	self.DrawCache.NeedsDraw = false\\\
	local pos = self:GetPosition()\\\
	Drawing.StartCopyBuffer()\\\
\\\
	if self.ClipDrawing then\\\
		Drawing.AddConstraint(pos.X, pos.Y, self.Width, self.Height)\\\
	end\\\
\\\
	if self.OnDraw then\\\
		self:OnDraw(pos.X, pos.Y)\\\
	end\\\
\\\
	self.DrawCache.Buffer = Drawing.EndCopyBuffer()\\\
	\\\
	if self.Children then\\\
		for i, child in ipairs(self.Children) do\\\
			local pos = child:GetOffsetPosition()\\\
			if pos.Y + self.Height > 1 and pos.Y <= self.Height and pos.X + self.Width > 1 and pos.X <= self.Width then\\\
				child:Draw()\\\
			end\\\
		end\\\
	end\\\
\\\
	if self.ClipDrawing then\\\
		Drawing.RemoveConstraint()\\\
	end	\\\
end\\\
\\\
ForceDraw = function(self, ignoreChildren, ignoreParent, ignoreBedrock)\\\
	if not ignoreBedrock and self.Bedrock then\\\
		self.Bedrock:ForceDraw()\\\
	end\\\
	self.DrawCache.NeedsDraw = true\\\
	if not ignoreParent and self.Parent then\\\
		self.Parent:ForceDraw(true, nil, true)\\\
	end\\\
	if not ignoreChildren and self.Children then\\\
		for i, child in ipairs(self.Children) do\\\
			child:ForceDraw(nil, true, true)\\\
		end\\\
	end\\\
end\\\
\\\
OnRemove = function(self)\\\
	if self == self.Bedrock:GetActiveObject() then\\\
		self.Bedrock:SetActiveObject()\\\
	end\\\
end\\\
\\\
local function ParseColour(value)\\\
	if type(value) == 'string' then\\\
		if colours[value] and type(colours[value]) == 'number' then\\\
			return colours[value]\\\
		elseif colors[value] and type(colors[value]) == 'number' then\\\
			return colors[value]\\\
		end\\\
	elseif type(value) == 'number' and (value == colours.transparent or (value >= colours.white and value <= colours.black)) then\\\
		return value\\\
	end\\\
	error('Invalid colour: \\\"'..tostring(value)..'\\\"')\\\
end\\\
\\\
Initialise = function(self, values)\\\
	local _new = values    -- the new instance\\\
	_new.DrawCache = {\\\
		NeedsDraw = true,\\\
		AlwaysDraw = false,\\\
		Buffer = nil\\\
	}\\\
	setmetatable(_new, {__index = self} )\\\
\\\
	local new = {} -- the proxy\\\
	setmetatable(new, {\\\
		__index = function(t, k)\\\
			if k:find('Color') then\\\
				k = k:gsub('Color', 'Colour')\\\
			end\\\
\\\
			if k:find('Colour') and type(_new[k]) ~= 'table' then\\\
				if _new[k] then\\\
					return ParseColour(_new[k])\\\
				end\\\
			elseif _new[k] ~= nil then\\\
				return _new[k]\\\
			end\\\
		end,\\\
\\\
		__newindex = function (t,k,v)\\\
			if k:find('Color') then\\\
				k = k:gsub('Color', 'Colour')\\\
			end\\\
\\\
			if k == 'Width' or k == 'X' or k == 'Height' or k == 'Y' then\\\
				v = new.Bedrock:ParseStringSize(new.Parent, k, v)\\\
			end\\\
\\\
			if v ~= _new[k] then\\\
				_new[k] = v\\\
				if t.OnUpdate then\\\
					t:OnUpdate(k)\\\
				end\\\
\\\
				if t.UpdateDrawBlacklist[k] == nil then\\\
					t:ForceDraw()\\\
				end\\\
			end\\\
		end\\\
	})\\\
	if new.OnInitialise then\\\
		new:OnInitialise()\\\
	end\\\
\\\
	return new\\\
end\\\
\\\
Click = function(self, event, side, x, y)\\\
	if self.Visible and not self.IgnoreClick then\\\
		if event == 'mouse_click' and self.OnClick and self:OnClick(event, side, x, y) ~= false then\\\
			return true\\\
		elseif event == 'mouse_drag' and self.OnDrag and self:OnDrag(event, side, x, y) ~= false then\\\
			return true\\\
		elseif event == 'mouse_scroll' and self.OnScroll and self:OnScroll(event, side, x, y) ~= false then\\\
			return true\\\
		else\\\
			return false\\\
		end\\\
	else\\\
		return false\\\
	end\\\
\\\
end\\\
\\\
ToggleMenu = function(self, name, x, y)\\\
	return self.Bedrock:ToggleMenu(name, self, x, y)\\\
end\\\
\\\
function OnUpdate(self, value)\\\
	if value == 'Z' then\\\
		self.Bedrock:ReorderObjects()\\\
	end\\\
end\\\
]],\\\
}\\\
local objects = {\\\
[\\\"Button\\\"] = [[\\\
BackgroundColour = colours.lightGrey\\\
ActiveBackgroundColour = colours.blue\\\
ActiveTextColour = colours.white\\\
TextColour = colours.black\\\
DisabledTextColour = colours.lightGrey\\\
Text = \\\"\\\"\\\
Toggle = nil\\\
Momentary = true\\\
AutoWidthAutoWidth = true\\\
Align = 'Center'\\\
Enabled = true\\\
\\\
OnUpdate = function(self, value)\\\
	if value == 'Text' and self.AutoWidth then\\\
		self.Width = #self.Text + 2\\\
	end\\\
end\\\
\\\
OnDraw = function(self, x, y)\\\
	local bg = self.BackgroundColour\\\
\\\
	if self.Toggle then\\\
		bg = self.ActiveBackgroundColour\\\
	end\\\
\\\
	local txt = self.TextColour\\\
	if self.Toggle then\\\
		txt = self.ActiveTextColour\\\
	end\\\
	if not self.Enabled then\\\
		txt = self.DisabledTextColour\\\
	end\\\
	Drawing.DrawBlankArea(x, y, self.Width, self.Height, bg)\\\
\\\
	local _x = 1\\\
    if self.Align == 'Right' then\\\
        _x = self.Width - #self.Text - 1\\\
    elseif self.Align == 'Center' then\\\
        _x = math.floor((self.Width - #self.Text) / 2)\\\
    end\\\
\\\
\\\
	Drawing.DrawCharacters(x + _x, y-1+math.ceil(self.Height/2), self.Text, txt, bg)\\\
end\\\
\\\
OnLoad = function(self)\\\
	if self.Toggle ~= nil then\\\
		self.Momentary = false\\\
	end\\\
end\\\
\\\
Click = function(self, event, side, x, y)\\\
	if self.Visible and not self.IgnoreClick and self.Enabled and event ~= 'mouse_scroll' then\\\
		if self.OnClick then\\\
			if self.Momentary then\\\
				self.Toggle = true\\\
				self.Bedrock:StartTimer(function()self.Toggle = false end,0.25)\\\
			elseif self.Toggle ~= nil then\\\
				self.Toggle = not self.Toggle\\\
			end\\\
\\\
			self:OnClick(event, side, x, y, self.Toggle)\\\
		else\\\
			self.Toggle = not self.Toggle\\\
		end\\\
		return true\\\
	else\\\
		return false\\\
	end\\\
end\\\
]],\\\
[\\\"CollectionView\\\"] = [[\\\
Inherit = 'ScrollView'\\\
UpdateDrawBlacklist = {['NeedsItemUpdate']=true}\\\
\\\
TextColour = colours.black\\\
BackgroundColour = colours.white\\\
Items = false\\\
NeedsItemUpdate = false\\\
SpacingX = 2\\\
SpacingY = 1\\\
\\\
OnDraw = function(self, x, y)\\\
	if self.NeedsItemUpdate then\\\
		self:UpdateItems()\\\
		self.NeedsItemUpdate = false\\\
	end\\\
	Drawing.DrawBlankArea(x, y, self.Width, self.Height, self.BackgroundColour)\\\
end\\\
\\\
local function MaxIcons(self, obj)\\\
	local x, y = 2, 1\\\
	if not obj.Height or not obj.Width then\\\
		error('You must provide each object\\\\'s height when adding to a CollectionView.')\\\
	end\\\
	local slotHeight = obj.Height + self.SpacingY\\\
	local slotWidth = obj.Width + self.SpacingX\\\
	local maxX = math.floor((self.Width - 2) / slotWidth)\\\
	return x, y, maxX, slotWidth, slotHeight\\\
end\\\
\\\
local function IconLocation(self, obj, i)\\\
	local x, y, maxX, slotWidth, slotHeight = MaxIcons(self, obj)\\\
	local rowPos = ((i - 1) % maxX)\\\
	local colPos = math.ceil(i / maxX) - 1\\\
	x = x + (slotWidth * rowPos)\\\
	y = y + colPos * slotHeight\\\
	return x, y\\\
end\\\
\\\
local function AddItem(self, v, i)\\\
	local toggle = false\\\
	if not self.CanSelect then\\\
		toggle = nil\\\
	end\\\
	local x, y = IconLocation(self, v, i)\\\
	local item = {\\\
		[\\\"X\\\"]=x,\\\
		[\\\"Y\\\"]=y,\\\
		[\\\"Name\\\"]=\\\"CollectionViewItem\\\",\\\
		[\\\"Type\\\"]=\\\"View\\\",\\\
		[\\\"TextColour\\\"]=self.TextColour,\\\
		[\\\"BackgroundColour\\\"]=0F,\\\
		OnClick = function(itm)\\\
			if self.CanSelect then\\\
				for i2, _v in ipairs(self.Children) do\\\
					_v.Toggle = false\\\
				end\\\
				self.Selected = itm\\\
			end\\\
		end\\\
    }\\\
	for k, _v in pairs(v) do\\\
		item[k] = _v\\\
   	end\\\
	self:AddObject(item)\\\
end\\\
\\\
\\\
UpdateItems = function(self)\\\
	self:RemoveAllObjects()\\\
	local groupMode = false\\\
	for k, v in pairs(self.Items) do\\\
		if type(k) == 'string' then\\\
			groupMode = true\\\
			break\\\
		end\\\
	end\\\
\\\
	for i, v in ipairs(self.Items) do\\\
		AddItem(self, v, i)\\\
	end\\\
	self:UpdateScroll()\\\
end\\\
\\\
OnUpdate = function(self, value)\\\
	if value == 'Items' then\\\
		self.NeedsItemUpdate = true\\\
	end\\\
end\\\
]],\\\
[\\\"ImageView\\\"] = [[\\\
Image = false\\\
\\\
OnDraw = function(self, x, y)\\\
	Drawing.DrawImage(x, y, self.Image, self.Width, self.Height)\\\
end\\\
\\\
OnLoad = function(self)\\\
	if self.Path and fs.exists(self.Path) then\\\
		self.Image = Drawing.LoadImage(self.Path)\\\
	end\\\
end\\\
\\\
OnUpdate = function(self, value)\\\
	if value == 'Path' then\\\
		if self.Path and fs.exists(self.Path) then\\\
			self.Image = Drawing.LoadImage(self.Path)\\\
		end\\\
	end\\\
end\\\
]],\\\
[\\\"Label\\\"] = [[\\\
TextColour = colours.black\\\
BackgroundColour = colours.transparent\\\
Text = \\\"\\\"\\\
AutoWidth = false\\\
Align = 'Left'\\\
\\\
local wrapText = function(text, maxWidth)\\\
    local lines = {''}\\\
    for word, space in text:gmatch('(%S+)(%s*)') do\\\
        local temp = lines[#lines] .. word .. space:gsub('\\\\n','')\\\
        if #temp > maxWidth then\\\
            table.insert(lines, '')\\\
        end\\\
        if space:find('\\\\n') then\\\
            lines[#lines] = lines[#lines] .. word\\\
            \\\
            space = space:gsub('\\\\n', function()\\\
                    table.insert(lines, '')\\\
                    return ''\\\
            end)\\\
        else\\\
            lines[#lines] = lines[#lines] .. word .. space\\\
        end\\\
    end\\\
    if #lines[1] == 0 then\\\
        table.remove(lines,1)\\\
    end\\\
    return lines\\\
end\\\
\\\
OnUpdate = function(self, value)\\\
    if value == 'Text' then\\\
        if self.AutoWidth then\\\
            self.Width = #self.Text\\\
        else\\\
            self.Height = #wrapText(self.Text, self.Width)\\\
        end\\\
    end\\\
end\\\
\\\
OnDraw = function(self, x, y)\\\
	for i, v in ipairs(wrapText(self.Text, self.Width)) do\\\
        local _x = 0\\\
        if self.Align == 'Right' then\\\
            _x = self.Width - #v\\\
        elseif self.Align == 'Center' then\\\
            _x = math.floor((self.Width - #v) / 2)\\\
        end\\\
		Drawing.DrawCharacters(x + _x, y + i - 1, v, self.TextColour, self.BackgroundColour)\\\
	end\\\
end\\\
]],\\\
[\\\"ListView\\\"] = [[\\\
Inherit = 'ScrollView'\\\
UpdateDrawBlacklist = {['NeedsItemUpdate']=true}\\\
\\\
TextColour = colours.black\\\
BackgroundColour = colours.white\\\
HeadingColour = colours.lightGrey\\\
SelectionBackgroundColour = colours.blue\\\
SelectionTextColour = colours.white\\\
Items = false\\\
CanSelect = false\\\
Selected = nil\\\
NeedsItemUpdate = false\\\
ItemMargin = 1\\\
HeadingMargin = 0\\\
TopMargin = 0\\\
\\\
OnDraw = function(self, x, y)\\\
	if self.NeedsItemUpdate then\\\
		self:UpdateItems()\\\
	end\\\
	Drawing.DrawBlankArea(x, y, self.Width, self.Height, self.BackgroundColour)\\\
end\\\
\\\
local function AddItem(self, v, x, y, group)\\\
	local toggle = false\\\
	if not self.CanSelect then\\\
		toggle = nil\\\
	elseif v.Selected then\\\
		toggle = true\\\
	end\\\
	local item = {\\\
		[\\\"Width\\\"]=self.Width,\\\
		[\\\"X\\\"]=x,\\\
		[\\\"Y\\\"]=y,\\\
		[\\\"Name\\\"]=\\\"ListViewItem\\\",\\\
		[\\\"Type\\\"]=\\\"Button\\\",\\\
		[\\\"TextColour\\\"]=self.TextColour,\\\
		[\\\"BackgroundColour\\\"]=0,\\\
		[\\\"ActiveTextColour\\\"]=self.SelectionTextColour,\\\
		[\\\"ActiveBackgroundColour\\\"]=self.SelectionBackgroundColour,\\\
		[\\\"Align\\\"]='Left',\\\
		[\\\"Toggle\\\"]=toggle,\\\
		[\\\"Group\\\"]=group,\\\
		OnClick = function(itm)\\\
			if self.CanSelect then\\\
				self:SelectItem(itm)\\\
			elseif self.OnSelect then\\\
				self:OnSelect(itm.Text)\\\
			end\\\
		end\\\
    }\\\
    if type(v) == 'table' then\\\
    	for k, _v in pairs(v) do\\\
    		item[k] = _v\\\
    	end\\\
    else\\\
		item.Text = v\\\
    end\\\
	\\\
	local itm = self:AddObject(item)\\\
	if v.Selected then\\\
		self:SelectItem(itm)\\\
	end\\\
end\\\
\\\
UpdateItems = function(self)\\\
	if not self.Items or type(self.Items) ~= 'table' then\\\
		self.Items = {}\\\
	end\\\
	self.Selected = nil\\\
	self:RemoveAllObjects()\\\
	local groupMode = false\\\
	for k, v in pairs(self.Items) do\\\
		if type(k) == 'string' then\\\
			groupMode = true\\\
			break\\\
		end\\\
	end\\\
\\\
	if not groupMode then\\\
		for i, v in ipairs(self.Items) do\\\
			AddItem(self, v, self.ItemMargin, i)\\\
		end\\\
	else\\\
		local y = self.TopMargin\\\
		for k, v in pairs(self.Items) do\\\
			y = y + 1\\\
			AddItem(self, {Text = k, TextColour = self.HeadingColour, IgnoreClick = true}, self.HeadingMargin, y)\\\
			for i, _v in ipairs(v) do\\\
				y = y + 1\\\
				AddItem(self, _v, 1, y, k)\\\
			end\\\
			y = y + 1\\\
		end\\\
	end\\\
	self:UpdateScroll()\\\
	self.NeedsItemUpdate = false\\\
end\\\
\\\
OnKeyChar = function(self, event, keychar)\\\
	if keychar == keys.up or keychar == keys.down then\\\
		local n = self:GetIndex(self.Selected)\\\
		if keychar == keys.up then\\\
			n = n - 1\\\
		else\\\
			n = n + 1\\\
		end\\\
		local new = self:GetNth(n)\\\
		if new then\\\
			self:SelectItem(new)\\\
		end\\\
	elseif keychar == keys.enter and self.Selected then\\\
		self.Selected:Click('mouse_click', 1, 1, 1)\\\
	end\\\
end\\\
\\\
--returns the index/'n' of the given item\\\
GetIndex = function(self, obj)\\\
	local n = 1\\\
	for i, v in ipairs(self.Children) do\\\
		if not v.IgnoreClick then\\\
			if obj == v then\\\
				return n\\\
			end\\\
			n = n + 1\\\
		end\\\
	end\\\
end\\\
\\\
--gets the 'nth' list item (does not include headings)\\\
GetNth = function(self, n)\\\
	local _n = 1\\\
	for i, v in ipairs(self.Children) do\\\
		if not v.IgnoreClick then\\\
			if n == _n then\\\
				return v\\\
			end\\\
			_n = _n + 1\\\
		end\\\
	end\\\
end\\\
\\\
SelectItem = function(self, item)\\\
	for i, v in ipairs(self.Children) do\\\
		v.Toggle = false\\\
	end\\\
	self.Selected = item\\\
	item.Toggle = true\\\
	if self.OnSelect then\\\
		self:OnSelect(item.Text)\\\
	end\\\
end\\\
\\\
OnUpdate = function(self, value)\\\
	if value == 'Items' then\\\
		self.NeedsItemUpdate = true\\\
	end\\\
end\\\
]],\\\
[\\\"Menu\\\"] = [[\\\
Inherit = 'View'\\\
\\\
TextColour = colours.black\\\
BackgroundColour = colours.white\\\
HideTop = false\\\
\\\
OnDraw = function(self, x, y)\\\
	Drawing.IgnoreConstraint = true\\\
	Drawing.DrawBlankArea(x + 1, y + (self.HideTop and 0 or 1), self.Width, self.Height + (self.HideTop and 1 or 0), colours.grey)\\\
	Drawing.IgnoreConstraint = false\\\
	Drawing.DrawBlankArea(x, y, self.Width, self.Height, self.BackgroundColour)\\\
end\\\
\\\
OnLoad = function(self)\\\
	local owner = self.Owner\\\
	if type(owner) == 'string' then\\\
		owner = self.Bedrock:GetObject(self.Owner)\\\
	end\\\
\\\
	if owner then\\\
		if self.X == 0 and self.Y == 0 then\\\
			local pos = owner:GetPosition()\\\
			self.X = pos.X\\\
			self.Y = pos.Y + owner.Height\\\
		end\\\
		self.Owner = owner\\\
	else\\\
		self.Owner = nil\\\
	end\\\
end\\\
\\\
OnUpdate = function(self, value)\\\
	if value == 'Children' then\\\
		self.Width = self.Bedrock.Helpers.LongestString(self.Children, 'Text') + 2\\\
		self.Height = #self.Children + 1 + (self.HideTop and 0 or 1)\\\
		if not self.BaseY then\\\
			self.BaseY = self.Y\\\
		end\\\
\\\
		for i, v in ipairs(self.Children) do\\\
			if v.TextColour then\\\
				v.TextColour = self.TextColour\\\
			end\\\
			if v.BackgroundColour then\\\
				v.BackgroundColour = colours.transparent\\\
			end\\\
			if v.Colour then\\\
				v.Colour = colours.lightGrey\\\
			end\\\
			v.Align = 'Left'\\\
			v.X = 1\\\
			v.Y = i + (self.HideTop and 0 or 1)\\\
			v.Width = self.Width\\\
			v.Height = 1\\\
		end\\\
\\\
		self.Y = self.BaseY\\\
		local pos = self:GetPosition()\\\
		if pos.Y + self.Height + 1 > Drawing.Screen.Height then\\\
			self.Y = self.BaseY - ((self.Height +  pos.Y) - Drawing.Screen.Height)\\\
		end\\\
		\\\
		if pos.X + self.Width > Drawing.Screen.Width then\\\
			self.X = Drawing.Screen.Width - self.Width\\\
		end\\\
	end\\\
end\\\
\\\
Close = function(self, isBedrockCall)\\\
	self.Bedrock.Menu = nil\\\
	self.Parent:RemoveObject(self)\\\
	if self.Owner and self.Owner.Toggle then\\\
		self.Owner.Toggle = false\\\
	end\\\
	self.Parent:ForceDraw()\\\
	self = nil\\\
end\\\
\\\
OnChildClick = function(self, child, event, side, x, y)\\\
	self:Close()\\\
end\\\
]],\\\
[\\\"ProgressBar\\\"] = [[\\\
BackgroundColour = colours.lightGrey\\\
BarColour = colours.blue\\\
TextColour = colours.white\\\
ShowText = false\\\
Value = 0\\\
Maximum = 1\\\
Indeterminate = false\\\
AnimationStep = 0\\\
\\\
OnDraw = function(self, x, y)\\\
	Drawing.DrawBlankArea(x, y, self.Width, self.Height, self.BackgroundColour)\\\
\\\
	-- if self.Indeterminate then\\\
	-- 	for i = 1, self.Width do\\\
	-- 		local s = x + i - 1 + self.AnimationStep\\\
	-- 		if s % 4 == 1 or s % 4 == 2 then\\\
	-- 			Drawing.DrawBlankArea(s, y, 1, self.Height, self.BarColour)\\\
	-- 		end\\\
	-- 	end\\\
	-- 	self.AnimationStep = self.AnimationStep + 1\\\
	-- 	if self.AnimationStep >= 4 then\\\
	-- 		self.AnimationStep = 0\\\
	-- 	end\\\
	-- 	self.Bedrock:StartTimer(function()\\\
	-- 		self:Draw()\\\
	-- 	end, 0.25)\\\
	-- else\\\
		local values = self.Value\\\
		local barColours = self.BarColour\\\
		if type(values) == 'number' then\\\
			values = {values}\\\
		end\\\
		if type(barColours) == 'number' then\\\
			barColours = {barColours}\\\
		end\\\
		local total = 0\\\
		local _x = x\\\
		for i, v in ipairs(values) do\\\
			local width = self.Bedrock.Helpers.Round((v / self.Maximum) * self.Width)\\\
			total = total + v\\\
			Drawing.DrawBlankArea(_x, y, width, self.Height, barColours[((i-1)%#barColours)+1])\\\
			_x = _x + width\\\
		end\\\
\\\
		if self.ShowText then\\\
			local text = self.Bedrock.Helpers.Round((total / self.Maximum) * 100) .. '%'\\\
			Drawing.DrawCharactersCenter(x, y, self.Width, self.Height, text, self.TextColour, colours.transparent)\\\
		end\\\
	-- end\\\
end\\\
]],\\\
[\\\"ScrollBar\\\"] = [[\\\
BackgroundColour = colours.lightGrey\\\
BarColour = colours.lightBlue\\\
Scroll = 0\\\
MaxScroll = 0\\\
ClickPoint = nil\\\
Fixed = true\\\
\\\
OnUpdate = function(self, value)\\\
	if value == 'Text' and self.AutoWidth then\\\
		self.Width = #self.Text + 2\\\
	end\\\
end\\\
\\\
OnDraw = function(self, x, y)\\\
	local barHeight = self.Height * (self.Height / (self.Height + self.MaxScroll))\\\
    if barHeight < 3 then\\\
      barHeight = 3\\\
    end\\\
    local percentage = (self.Scroll/self.MaxScroll)\\\
\\\
    Drawing.DrawBlankArea(x, y, self.Width, self.Height, self.BackgroundColour)\\\
    Drawing.DrawBlankArea(x, y + math.ceil(self.Height*percentage - barHeight*percentage), self.Width, barHeight, self.BarColour)\\\
end\\\
\\\
OnScroll = function(self, event, direction, x, y)\\\
	if event == 'mouse_scroll' then\\\
		direction = self.Bedrock.Helpers.Round(direction * 3)\\\
	end\\\
	if self.Scroll < 0 or self.Scroll > self.MaxScroll then\\\
		return false\\\
	end\\\
	local old = self.Scroll\\\
	self.Scroll = self.Bedrock.Helpers.Round(self.Scroll + direction)\\\
	if self.Scroll < 0 then\\\
		self.Scroll = 0\\\
	elseif self.Scroll > self.MaxScroll then\\\
		self.Scroll = self.MaxScroll\\\
	end\\\
\\\
	if self.Scroll ~= old and self.OnChange then\\\
		self:OnChange()\\\
	end\\\
end\\\
\\\
OnClick = function(self, event, side, x, y)\\\
	if event == 'mouse_click' then\\\
		self.ClickPoint = y\\\
	else\\\
		local gapHeight = self.Height - (self.Height * (self.Height / (self.Height + self.MaxScroll)))\\\
		local barHeight = self.Height * (self.Height / (self.Height + self.MaxScroll))\\\
		--local delta = (self.Height + self.MaxScroll) * ((y - self.ClickPoint) / barHeight)\\\
		local delta = ((y - self.ClickPoint)/gapHeight)*self.MaxScroll\\\
		--l(((y - self.ClickPoint)/gapHeight))\\\
		--l(delta)\\\
		self.Scroll = self.Bedrock.Helpers.Round(delta)\\\
		--l(self.Scroll)\\\
		--l('----')\\\
		if self.Scroll < 0 then\\\
			self.Scroll = 0\\\
		elseif self.Scroll > self.MaxScroll then\\\
			self.Scroll = self.MaxScroll\\\
		end\\\
		if self.OnChange then\\\
			self:OnChange()\\\
		end\\\
	end\\\
\\\
	local relScroll = self.MaxScroll * ((y-1)/self.Height)\\\
	if y == self.Height then\\\
		relScroll = self.MaxScroll\\\
	end\\\
	self.Scroll = self.Bedrock.Helpers.Round(relScroll)\\\
\\\
\\\
end\\\
\\\
OnDrag = OnClick\\\
]],\\\
[\\\"ScrollView\\\"] = [[\\\
Inherit = 'View'\\\
ChildOffset = false\\\
ContentWidth = 0\\\
ContentHeight = 0\\\
ScrollBarBackgroundColour = colours.lightGrey\\\
ScrollBarColour = colours.lightBlue\\\
\\\
CalculateContentSize = function(self)\\\
	local function calculateObject(obj)\\\
		local pos = obj:GetPosition()\\\
		local x2 = pos.X + obj.Width - 1\\\
		local y2 = pos.Y + obj.Height - 1\\\
		if obj.Children then\\\
			for i, child in ipairs(obj.Children) do\\\
				local _x2, _y2 = calculateObject(child)\\\
				if _x2 > x2 then\\\
					x2 = _x2\\\
				end\\\
				if _y2 > y2 then\\\
					y2 = _y2\\\
				end\\\
			end\\\
		end\\\
		return x2, y2\\\
	end\\\
\\\
	local pos = self:GetPosition()\\\
	local x2, y2 = calculateObject(self)\\\
	self.ContentWidth = x2 - pos.X + 1\\\
	self.ContentHeight = y2 - pos.Y + 1\\\
end\\\
\\\
UpdateScroll = function(self)\\\
	self.ChildOffset.Y = 0\\\
	self:CalculateContentSize()\\\
	if self.ContentHeight > self.Height then\\\
		if not self:GetObject('ScrollViewScrollBar') then\\\
			local _scrollBar = self:AddObject({\\\
				[\\\"Name\\\"] = 'ScrollViewScrollBar',\\\
				[\\\"Type\\\"] = 'ScrollBar',\\\
				[\\\"X\\\"] = self.Width,\\\
				[\\\"Y\\\"] = 1,\\\
				[\\\"Width\\\"] = 1,\\\
				[\\\"Height\\\"] = self.Height,\\\
				[\\\"BackgroundColour\\\"] = self.ScrollBarBackgroundColour,\\\
				[\\\"BarColour\\\"] = self.ScrollBarColour,\\\
				[\\\"Z\\\"]=999\\\
			})\\\
\\\
			_scrollBar.OnChange = function(scrollBar)\\\
				self.ChildOffset.Y = -scrollBar.Scroll\\\
				for i, child in ipairs(self.Children) do\\\
					child:ForceDraw()\\\
				end\\\
			end\\\
		end\\\
		self:GetObject('ScrollViewScrollBar').MaxScroll = self.ContentHeight - self.Height\\\
	else\\\
		self:RemoveObject('ScrollViewScrollBar')\\\
	end\\\
end\\\
\\\
OnScroll = function(self, event, direction, x, y)\\\
	if self:GetObject('ScrollViewScrollBar') then\\\
		self:GetObject('ScrollViewScrollBar'):OnScroll(event, direction, x, y)\\\
	end\\\
end\\\
\\\
OnLoad = function(self)\\\
	if not self.ChildOffset or not self.ChildOffset.X or not self.ChildOffset.Y then\\\
		self.ChildOffset = {X = 0, Y = 0}\\\
	end\\\
end\\\
]],\\\
[\\\"SecureTextBox\\\"] = [[\\\
Inherit = 'TextBox'\\\
MaskCharacter = '*'\\\
\\\
OnDraw = function(self, x, y)\\\
	Drawing.DrawBlankArea(x, y, self.Width, self.Height, self.BackgroundColour)\\\
	if self.CursorPos > #self.Text then\\\
		self.CursorPos = #self.Text\\\
	elseif self.CursorPos < 0 then\\\
		self.CursorPos = 0\\\
	end\\\
	local text = ''\\\
\\\
	for i = 1, #self.Text do\\\
		text = text .. self.MaskCharacter\\\
	end\\\
\\\
	if self.Bedrock:GetActiveObject() == self then\\\
		if #text > (self.Width - 2) then\\\
			text = text:sub(#text-(self.Width - 3))\\\
			self.Bedrock.CursorPos = {x + 1 + self.Width-2, y}\\\
		else\\\
			self.Bedrock.CursorPos = {x + 1 + self.CursorPos, y}\\\
		end\\\
		self.Bedrock.CursorColour = self.TextColour\\\
	end\\\
\\\
	if #tostring(text) == 0 then\\\
		Drawing.DrawCharacters(x + 1, y, self.Placeholder, self.PlaceholderTextColour, self.BackgroundColour)\\\
	else\\\
		if not self.Selected then\\\
			Drawing.DrawCharacters(x + 1, y, text, self.TextColour, self.BackgroundColour)\\\
		else\\\
			for i = 1, #text do\\\
				local char = text:sub(i, i)\\\
				local textColour = self.TextColour\\\
				local backgroundColour = self.BackgroundColour\\\
				if i > self.DragStart and i - 1 <= self.CursorPos then\\\
					textColour = self.SelectedTextColour\\\
					backgroundColour = self.SelectedBackgroundColour\\\
				end\\\
				Drawing.DrawCharacters(x + i, y, char, textColour, backgroundColour)\\\
			end\\\
		end\\\
	end\\\
end\\\
]],\\\
[\\\"Separator\\\"] = [[\\\
Colour = colours.grey\\\
\\\
OnDraw = function(self, x, y)\\\
	local char = \\\"|\\\"\\\
	if self.Width > self.Height then\\\
		char = '-'\\\
	end\\\
	Drawing.DrawArea(x, y, self.Width, self.Height, char, self.Colour, colours.transparent)\\\
end\\\
]],\\\
[\\\"TextBox\\\"] = [[\\\
BackgroundColour = colours.lightGrey\\\
SelectedBackgroundColour = colours.blue\\\
SelectedTextColour = colours.white\\\
TextColour = colours.black\\\
PlaceholderTextColour = colours.grey\\\
Placeholder = ''\\\
AutoWidth = false\\\
Text = \\\"\\\"\\\
CursorPos = nil\\\
Numerical = false\\\
DragStart = nil\\\
Selected = false\\\
SelectOnClick = false\\\
ActualDragStart = nil\\\
\\\
OnDraw = function(self, x, y)\\\
	Drawing.DrawBlankArea(x, y, self.Width, self.Height, self.BackgroundColour)\\\
	if self.CursorPos > #self.Text then\\\
		self.CursorPos = #self.Text\\\
	elseif self.CursorPos < 0 then\\\
		self.CursorPos = 0\\\
	end\\\
	local text = self.Text\\\
	local offset = self:TextOffset()\\\
	if #text > (self.Width - 2) then\\\
		text = text:sub(offset+1, offset + self.Width - 2)\\\
		-- self.Bedrock.CursorPos = {x + 1 + self.Width-2, y}\\\
	-- else\\\
	end\\\
	if self.Bedrock:GetActiveObject() == self then\\\
		self.Bedrock.CursorPos = {x + 1 + self.CursorPos - offset, y}\\\
		self.Bedrock.CursorColour = self.TextColour\\\
	else\\\
		self.Selected = false\\\
	end\\\
\\\
	if #tostring(text) == 0 then\\\
		Drawing.DrawCharacters(x + 1, y, self.Placeholder, self.PlaceholderTextColour, self.BackgroundColour)\\\
	else\\\
		if not self.Selected then\\\
			Drawing.DrawCharacters(x + 1, y, text, self.TextColour, self.BackgroundColour)\\\
		else\\\
			local startPos = self.DragStart - offset\\\
			local endPos = self.CursorPos - offset\\\
			if startPos > endPos then\\\
				startPos = self.CursorPos - offset\\\
				endPos = self.DragStart - offset\\\
			end\\\
			for i = 1, #text do\\\
				local char = text:sub(i, i)\\\
				local textColour = self.TextColour\\\
				local backgroundColour = self.BackgroundColour\\\
\\\
				if i > startPos and i - 1 <= endPos then\\\
					textColour = self.SelectedTextColour\\\
					backgroundColour = self.SelectedBackgroundColour\\\
				end\\\
				Drawing.DrawCharacters(x + i, y, char, textColour, backgroundColour)\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
TextOffset = function(self)\\\
	if #self.Text < (self.Width - 2) then\\\
		return 0\\\
	elseif self.Bedrock:GetActiveObject() ~= self then\\\
		return 0\\\
	else\\\
		local textWidth = (self.Width - 2)\\\
		local offset = self.CursorPos - textWidth\\\
		if offset < 0 then\\\
			offset = 0\\\
		end\\\
		return offset\\\
	end\\\
end\\\
\\\
OnLoad = function(self)\\\
	if not self.CursorPos then\\\
		self.CursorPos = #self.Text\\\
	end\\\
end\\\
\\\
OnClick = function(self, event, side, x, y)\\\
	if self.Bedrock:GetActiveObject() ~= self and self.SelectOnClick then\\\
		self.CursorPos = #self.Text - 1\\\
		self.DragStart = 0\\\
		self.ActualDragStart = x - 2 + self:TextOffset()\\\
		self.Selected = true\\\
	else\\\
		self.CursorPos = x - 2 + self:TextOffset()\\\
		self.DragStart = self.CursorPos\\\
		self.Selected = false\\\
	end\\\
	self.Bedrock:SetActiveObject(self)\\\
end\\\
\\\
OnDrag = function(self, event, side, x, y)\\\
	self.CursorPos = x - 2 + self:TextOffset()\\\
	if self.ActualDragStart then\\\
		self.DragStart = self.ActualDragStart\\\
		self.ActualDragStart = nil\\\
	end\\\
	if self.DragStart then\\\
		self.Selected = true\\\
	end\\\
end\\\
\\\
OnKeyChar = function(self, event, keychar)\\\
	local deleteSelected = function()\\\
		if self.Selected then\\\
			local startPos = self.DragStart\\\
			local endPos = self.CursorPos\\\
			if startPos > endPos then\\\
				startPos = self.CursorPos\\\
				endPos = self.DragStart\\\
			end\\\
			self.Text = self.Text:sub(1, startPos) .. self.Text:sub(endPos + 2)\\\
			self.CursorPos = startPos\\\
			self.DragStart = nil\\\
			self.Selected = false\\\
			return true\\\
		end\\\
	end\\\
\\\
	if event == 'char' then\\\
		deleteSelected()\\\
		if self.Numerical then\\\
			keychar = tostring(tonumber(keychar))\\\
		end\\\
		if keychar == 'nil' then\\\
			return\\\
		end\\\
		self.Text = string.sub(self.Text, 1, self.CursorPos ) .. keychar .. string.sub( self.Text, self.CursorPos + 1 )\\\
		if self.Numerical then\\\
			self.Text = tostring(tonumber(self.Text))\\\
			if self.Text == 'nil' then\\\
				self.Text = '1'\\\
			end\\\
		end\\\
		\\\
		self.CursorPos = self.CursorPos + 1\\\
		if self.OnChange then\\\
			self:OnChange(event, keychar)\\\
		end\\\
		return false\\\
	elseif event == 'key' then\\\
		if keychar == keys.enter then\\\
			if self.OnChange then\\\
				self:OnChange(event, keychar)\\\
			end\\\
		elseif keychar == keys.left then\\\
			-- Left\\\
			if self.CursorPos > 0 then\\\
				if self.Selected then\\\
					self.CursorPos = self.DragStart\\\
					self.DragStart = nil\\\
					self.Selected = false\\\
				else\\\
					self.CursorPos = self.CursorPos - 1\\\
				end\\\
				if self.OnChange then\\\
					self:OnChange(event, keychar)\\\
				end\\\
			end\\\
			\\\
		elseif keychar == keys.right then\\\
			-- Right				\\\
			if self.CursorPos < string.len(self.Text) then\\\
				if self.Selected then\\\
					self.CursorPos = self.CursorPos\\\
					self.DragStart = nil\\\
					self.Selected = false\\\
				else\\\
					self.CursorPos = self.CursorPos + 1\\\
				end\\\
				if self.OnChange then\\\
					self:OnChange(event, keychar)\\\
				end\\\
			end\\\
		\\\
		elseif keychar == keys.backspace then\\\
			-- Backspace\\\
			if not deleteSelected() and self.CursorPos > 0 then\\\
				self.Text = string.sub( self.Text, 1, self.CursorPos - 1 ) .. string.sub( self.Text, self.CursorPos + 1 )\\\
				self.CursorPos = self.CursorPos - 1					\\\
				if self.Numerical then\\\
					self.Text = tostring(tonumber(self.Text))\\\
					if self.Text == 'nil' then\\\
						self.Text = '1'\\\
					end\\\
				end\\\
				if self.OnChange then\\\
					self:OnChange(event, keychar)\\\
				end\\\
			end\\\
		elseif keychar == keys.home then\\\
			-- Home\\\
			self.CursorPos = 0\\\
			if self.OnChange then\\\
				self:OnChange(event, keychar)\\\
			end\\\
		elseif keychar == keys.delete then\\\
			if not deleteSelected() and self.CursorPos < string.len(self.Text) then\\\
				self.Text = string.sub( self.Text, 1, self.CursorPos ) .. string.sub( self.Text, self.CursorPos + 2 )		\\\
				if self.Numerical then\\\
					self.Text = tostring(tonumber(self.Text))\\\
					if self.Text == 'nil' then\\\
						self.Text = '1'\\\
					end\\\
				end\\\
				if self.OnChange then\\\
					self:OnChange(keychar)\\\
				end\\\
			end\\\
		elseif keychar == keys[\\\"end\\\"] then\\\
			-- End\\\
			self.CursorPos = string.len(self.Text)\\\
		else\\\
			if self.OnChange then\\\
				self:OnChange(event, keychar)\\\
			end\\\
			return false\\\
		end\\\
	end\\\
end\\\
]],\\\
[\\\"View\\\"] = [[\\\
BackgroundColour = colours.transparent\\\
Children = {}\\\
\\\
OnDraw = function(self, x, y)\\\
	if self.BackgroundColour then\\\
		Drawing.DrawBlankArea(x, y, self.Width, self.Height, self.BackgroundColour)\\\
	end\\\
end\\\
\\\
OnInitialise = function(self)\\\
	self.Children = {}\\\
end\\\
\\\
InitialiseFile = function(self, bedrock, file, name)\\\
	local _new = {}\\\
	_new.X = 1\\\
	_new.Y = 1\\\
	_new.Width = Drawing.Screen.Width\\\
	_new.Height = Drawing.Screen.Height\\\
	_new.BackgroundColour = file.BackgroundColour\\\
	_new.Name = name\\\
	_new.Children = {}\\\
	_new.Bedrock = bedrock\\\
	local new = self:Initialise(_new)\\\
	for i, obj in ipairs(file.Children) do\\\
		local view = bedrock:ObjectFromFile(obj, new)\\\
		if not view.Z then\\\
			view.Z = i\\\
		end\\\
		view.Parent = new\\\
		table.insert(new.Children, view)\\\
	end\\\
	return new\\\
end\\\
\\\
function CheckClick(self, object, x, y)\\\
	local offset = {X = 0, Y = 0}\\\
	if not object.Fixed and self.ChildOffset then\\\
		offset = self.ChildOffset\\\
	end\\\
	if object.X + offset.X <= x and object.Y + offset.Y <= y and  object.X + offset.X + object.Width > x and object.Y + offset.Y + object.Height > y then\\\
		return true\\\
	end\\\
end\\\
\\\
function DoClick(self, object, event, side, x, y)\\\
	if object then\\\
		if self:CheckClick(object, x, y) then\\\
			local offset = {X = 0, Y = 0}\\\
			if not object.Fixed and self.ChildOffset then\\\
				offset = self.ChildOffset\\\
			end\\\
			return object:Click(event, side, x - object.X - offset.X + 1, y - object.Y + 1 - offset.Y)\\\
		end\\\
	end	\\\
end\\\
\\\
Click = function(self, event, side, x, y, z)\\\
	if self.Visible and not self.IgnoreClick then\\\
		for i = #self.Children, 1, -1 do --children are ordered from smallest Z to highest, so this is done in reverse\\\
			local child = self.Children[i]\\\
			if self:DoClick(child, event, side, x, y) then\\\
				if self.OnChildClick then\\\
					self:OnChildClick(child, event, side, x, y)\\\
				end\\\
				return true\\\
			end\\\
		end\\\
		if event == 'mouse_click' and self.OnClick and self:OnClick(event, side, x, y) ~= false then\\\
			return true\\\
		elseif event == 'mouse_drag' and self.OnDrag and self:OnDrag(event, side, x, y) ~= false then\\\
			return true\\\
		elseif event == 'mouse_scroll' and self.OnScroll and self:OnScroll(event, side, x, y) ~= false then\\\
			return true\\\
		else\\\
			return false\\\
		end\\\
	else\\\
		return false\\\
	end\\\
end\\\
\\\
OnRemove = function(self)\\\
	if self == self.Bedrock:GetActiveObject() then\\\
		self.Bedrock:SetActiveObject()\\\
	end\\\
	for i, child in ipairs(self.Children) do\\\
		child:OnRemove()\\\
	end\\\
end\\\
\\\
local function findObjectNamed(view, name, minI)\\\
	local minI = minI or 0\\\
	if view and view.Children then\\\
		for i, child in ipairs(view.Children) do\\\
			if child.Name == name or child == name then\\\
				return child, i, view\\\
			elseif child.Children then\\\
				local found, index, foundView = findObjectNamed(child, name)\\\
				if found and minI <= index then\\\
					return found, index, foundView\\\
				end\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
function AddObject(self, info, extra)\\\
	if type(info) == 'string' then\\\
		local h = fs.open(self.Bedrock.ViewPath..info..'.view', 'r')\\\
		if h then\\\
			info = textutils.unserialize(h.readAll())\\\
			h.close()\\\
		else\\\
			error('Error in opening object: '..info)\\\
		end\\\
	end\\\
\\\
	if extra then\\\
		for k, v in pairs(extra) do\\\
			if v then\\\
				info[k] = v\\\
			end\\\
		end\\\
	end\\\
\\\
	local view = self.Bedrock:ObjectFromFile(info, self)\\\
	if not view.Z then\\\
		view.Z = #self.Children + 1\\\
	end\\\
	\\\
	table.insert(self.Children, view)\\\
	if self.Bedrock.View then\\\
		self.Bedrock:ReorderObjects()\\\
	end\\\
	self:ForceDraw()\\\
	return view\\\
end\\\
\\\
function GetObject(self, name)\\\
	return findObjectNamed(self, name)\\\
end\\\
\\\
local function findObjects(view, name)\\\
	local objects = {}\\\
	if view and view.Children then\\\
		for i, child in ipairs(view.Children) do\\\
			if child.Name == name or child == name then\\\
				table.insert(objects, child)\\\
			elseif child.Children then\\\
				local objs = findObjects(child, name)\\\
				if objs then\\\
					for i2, v in ipairs(objs) do\\\
						table.insert(objects, v)\\\
					end\\\
				end\\\
			end\\\
		end\\\
	end\\\
	return objects\\\
end\\\
\\\
function GetObjects(self, name)\\\
	return findObjects(self, name)\\\
end\\\
\\\
function RemoveObject(self, name)\\\
	local obj, index, view = findObjectNamed(self, name, minI)\\\
	if index then\\\
		view.Children[index]:OnRemove()\\\
		table.remove(view.Children, index)\\\
		if view.OnUpdate then\\\
			view:OnUpdate('Children')\\\
		end\\\
		return true\\\
	end\\\
	return false\\\
end\\\
\\\
function RemoveObjects(self, name)\\\
	local i = 1\\\
	while self:RemoveObject(name) and i < 100 do\\\
		i = i + 1\\\
	end\\\
	\\\
end\\\
\\\
function RemoveAllObjects(self)\\\
	for i, child in ipairs(self.Children) do\\\
		child:OnRemove()\\\
		self.Children[i] = nil\\\
	end\\\
	self:ForceDraw()\\\
end\\\
]],\\\
[\\\"Window\\\"] = [[\\\
Inherit = 'View'\\\
\\\
ToolBarColour = colours.lightGrey\\\
ToolBarTextColour = colours.black\\\
ShadowColour = colours.grey\\\
Title = ''\\\
Flashing = false\\\
CanClose = true\\\
OnCloseButton = nil\\\
OldActiveObject = nil\\\
\\\
OnLoad = function(self)\\\
	--self:GetObject('View') = self.Bedrock:ObjectFromFile({Type = 'View',Width = 10, Height = 5, BackgroundColour = colours.red}, self)\\\
end\\\
\\\
LoadView = function(self)\\\
	local view = self:GetObject('View')\\\
	if view.ToolBarColour then\\\
		window.ToolBarColour = view.ToolBarColour\\\
	end\\\
	if view.ToolBarTextColour then\\\
		window.ToolBarTextColour = view.ToolBarTextColour\\\
	end\\\
	view.X = 1\\\
	view.Y = 2\\\
\\\
	view:ForceDraw()\\\
	self:OnUpdate('View')\\\
	if self.OnViewLoad then\\\
		self.OnViewLoad(view)\\\
	end\\\
	self.OldActiveObject = self.Bedrock:GetActiveObject()\\\
	self.Bedrock:SetActiveObject(view)\\\
end\\\
\\\
SetView = function(self, view)\\\
	self:RemoveObject('View')\\\
	table.insert(self.Children, view)\\\
	view.Parent = self\\\
	self:LoadView()\\\
end\\\
\\\
Flash = function(self)\\\
	self.Flashing = true\\\
	self:ForceDraw()\\\
	self.Bedrock:StartTimer(function()self.Flashing = false end, 0.4)\\\
end\\\
\\\
OnDraw = function(self, x, y)\\\
	local toolBarColour = (self.Flashing and colours.white or self.ToolBarColour)\\\
	local toolBarTextColour = (self.Flashing and colours.black or self.ToolBarTextColour)\\\
	if toolBarColour then\\\
		Drawing.DrawBlankArea(x, y, self.Width, 1, toolBarColour)\\\
	end\\\
	if toolBarTextColour then\\\
		local title = self.Bedrock.Helpers.TruncateString(self.Title, self.Width - 2)\\\
		Drawing.DrawCharactersCenter(self.X, self.Y, self.Width, 1, title, toolBarTextColour, toolBarColour)\\\
	end\\\
	Drawing.IgnoreConstraint = true\\\
	Drawing.DrawBlankArea(x + 1, y + 1, self.Width, self.Height, self.ShadowColour)\\\
	Drawing.IgnoreConstraint = false\\\
end\\\
\\\
Close = function(self)\\\
	self.Bedrock:SetActiveObject(self.OldActiveObject)\\\
	self.Bedrock.Window = nil\\\
	self.Bedrock:RemoveObject(self)\\\
	if self.OnClose then\\\
		self:OnClose()\\\
	end\\\
	self = nil\\\
end\\\
\\\
OnUpdate = function(self, value)\\\
	if value == 'View' and self:GetObject('View') then\\\
		self.Width = self:GetObject('View').Width\\\
		self.Height = self:GetObject('View').Height + 1\\\
		self.X = math.ceil((Drawing.Screen.Width - self.Width) / 2)\\\
		self.Y = math.ceil((Drawing.Screen.Height - self.Height) / 2)\\\
	elseif value == 'CanClose' then\\\
		self:RemoveObject('CloseButton')\\\
		if self.CanClose then\\\
			local button = self:AddObject({X = 1, Y = 1, Width = 1, Height = 1, Type = 'Button', BackgroundColour = colours.red, TextColour = colours.white, Text = 'x', Name = 'CloseButton'})\\\
			button.OnClick = function(btn)\\\
				if self.OnCloseButton then\\\
					self:OnCloseButton()\\\
				end\\\
				self:Close()\\\
			end\\\
		end\\\
	end\\\
end\\\
]],\\\
}\\\
\\\
BasePath = ''\\\
ProgramPath = nil\\\
\\\
-- Program functions...\\\
\\\
local function main(...)\\\
	-- Code here...\\\
end\\\
\\\
-- Run\\\
local args = {...}\\\
local _, err = pcall(function() main(unpack(args)) end)\\\
if err then\\\
	-- Make a nice error handling screen here...\\\
	term.setBackgroundColor(colors.black)\\\
	term.setTextColor(colors.white)\\\
	term.clear()\\\
	term.setCursorPos(1, 3)\\\
	print(\\\" An Error Has Occured! D:\\\\n\\\\n\\\")\\\
	print(\\\" \\\" .. tostring(err) .. \\\"\\\\n\\\\n\\\")\\\
	print(\\\" Press any key to exit...\\\")\\\
	os.pullEvent(\\\"key\\\")\\\
end\\\
\\\
\\\
\\\
function LoadAPIs(self)\\\
	local function loadAPI(name, content)\\\
		local env = setmetatable({}, { __index = getfenv() })\\\
		local func, err = loadstring(content, name..' (Bedrock API)')\\\
		if not func then\\\
			return false, printError(err)\\\
		end\\\
		setfenv(func, env)\\\
		func()\\\
		local api = {}\\\
		for k,v in pairs(env) do\\\
			api[k] = v\\\
		end\\\
		_G[name] = api\\\
		return true\\\
	end\\\
\\\
	local env = getfenv()\\\
	local function loadObject(name, content)\\\
		loadAPI(name, content)\\\
		if env[name].Inherit then\\\
			if not getfenv()[env[name].Inherit] then	\\\
				if objects[env[name].Inherit] then\\\
					loadObject(env[name].Inherit, objects[env[name].Inherit])\\\
				elseif fs.exists(self.ProgramPath..'/Objects/'..env[name].Inherit..'.lua') then\\\
				end\\\
			end\\\
			env[name].__index = getfenv()[env[name].Inherit]\\\
		else\\\
			env[name].__index = Object\\\
		end\\\
		setmetatable(env[name], env[name])\\\
	end\\\
\\\
	for k, v in pairs(apis) do\\\
		loadAPI(k, v)\\\
		if k == 'Helpers' then\\\
			self.Helpers = Helpers\\\
		end\\\
	end\\\
\\\
	for k, v in pairs(objects) do\\\
		loadObject(k, v)\\\
	end\\\
	\\\
	local privateObjPath = self.ProgramPath..'/Objects/'\\\
	if fs.exists(privateObjPath) and fs.isDir(privateObjPath) then\\\
		for i, v in ipairs(fs.list(privateObjPath)) do\\\
			if v ~= '.DS_Store' then\\\
				local name = string.match(v, '(%a+)%.?.-')\\\
				local h = fs.open(privateObjPath..v, 'r')\\\
				loadObject(name, h.readAll())\\\
				h.close()\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
AllowTerminate = true\\\
\\\
View = nil\\\
Menu = nil\\\
\\\
ActiveObject = nil\\\
\\\
DrawTimer = nil\\\
DrawTimerExpiry = 0\\\
\\\
IsDrawing = false\\\
\\\
Running = true\\\
\\\
DefaultView = 'main'\\\
\\\
EventHandlers = {\\\
	\\\
}\\\
\\\
ObjectClickHandlers = {\\\
	\\\
}\\\
\\\
ObjectUpdateHandlers = {\\\
	\\\
}\\\
\\\
Timers = {\\\
	\\\
}\\\
\\\
function Initialise(self, programPath)\\\
	self.ProgramPath = programPath or self.ProgramPath\\\
	if not programPath then\\\
		if self.ProgramPath then\\\
			local prgPath = self.ProgramPath\\\
			local prgName = fs.getName(prgPath)\\\
			if prgPath:find('/') then \\\
				self.ProgramPath = prgPath:sub(1, #prgPath-#prgName-1)\\\
				self.ProgramPath = prgPath:sub(1, #prgPath-#prgName-1) \\\
			else \\\
		 		self.ProgramPath = '' \\\
		 	end\\\
		else\\\
			self.ProgramPath = ''\\\
		end\\\
	end\\\
	self:LoadAPIs()\\\
	self.ViewPath = self.ProgramPath .. '/Views/'\\\
	--first, check that the barebones APIs are available\\\
	local requiredApis = {\\\
		'Drawing',\\\
		'View'\\\
	}\\\
	local env = getfenv()\\\
	for i,v in ipairs(requiredApis) do\\\
		if not env[v] then\\\
			error('The API: '..v..' is not loaded. Please make sure you load it to use Bedrock.')\\\
		end\\\
	end\\\
\\\
	local copy = { }\\\
	for k, v in pairs(self) do\\\
		if k ~= 'Initialise' then\\\
			copy[k] = v\\\
		end\\\
	end\\\
	return setmetatable(copy, getmetatable(self))\\\
end\\\
\\\
function HandleClick(self, event, side, x, y)\\\
	if self.Window then\\\
		if not self.View:CheckClick(self.Window, x, y) then\\\
			self.Window:Flash()\\\
		else\\\
			self.View:DoClick(self.Window, event, side, x, y)\\\
		end\\\
	elseif self.Menu then\\\
		if not self.View:DoClick(self.Menu, event, side, x, y) then\\\
			self.Menu:Close()\\\
		end\\\
	elseif self.View then\\\
		if self.View:Click(event, side, x, y) ~= false then\\\
		end		\\\
	end\\\
end\\\
\\\
function HandleKeyChar(self, event, keychar)\\\
	if self:GetActiveObject() then\\\
		local activeObject = self:GetActiveObject()\\\
		if activeObject.OnKeyChar then\\\
			if activeObject:OnKeyChar(event, keychar) ~= false then\\\
				--self:Draw()\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
function ToggleMenu(self, name, owner, x, y)\\\
	if self.Menu then\\\
		self.Menu:Close()\\\
		return false\\\
	else\\\
		self:SetMenu(name, owner, x, y)\\\
		return true\\\
	end\\\
end\\\
\\\
function SetMenu(self, menu, owner, x, y)\\\
	x = x or 1\\\
	y = y or 1\\\
	if self.Menu then\\\
		self.Menu:Close()\\\
	end	\\\
	if menu then\\\
		local pos = owner:GetPosition()\\\
		self.Menu = self:AddObject(menu, {Type = 'Menu', Owner = owner, X = pos.X + x - 1, Y = pos.Y + y})\\\
	end\\\
end\\\
\\\
function ObjectClick(self, name, func)\\\
	self.ObjectClickHandlers[name] = func\\\
end\\\
\\\
function ClickObject(self, object, event, side, x, y)\\\
	if self.ObjectClickHandlers[object.Name] then\\\
		return self.ObjectClickHandlers[object.Name](object, event, side, x, y)\\\
	end\\\
	return false\\\
end\\\
\\\
function ObjectUpdate(self, name, func)\\\
	self.ObjectUpdateHandlers[name] = func\\\
end\\\
\\\
function UpdateObject(self, object, ...)\\\
	if self.ObjectUpdateHandlers[object.Name] then\\\
		self.ObjectUpdateHandlers[object.Name](object, ...)\\\
		--self:Draw()\\\
	end\\\
end\\\
\\\
function GetAbsolutePosition(self, obj)\\\
	if not obj.Parent then\\\
		return {X = obj.X, Y = obj.Y}\\\
	else\\\
		local pos = self:GetAbsolutePosition(obj.Parent)\\\
		local x = pos.X + obj.X - 1\\\
		local y = pos.Y + obj.Y - 1\\\
		if not obj.Fixed and obj.Parent.ChildOffset then\\\
			x = x + obj.Parent.ChildOffset.X\\\
			y = y + obj.Parent.ChildOffset.Y\\\
		end\\\
		return {X = x, Y = y}\\\
	end\\\
end\\\
\\\
function LoadView(self, name, draw)\\\
	if self.View and self.OnViewClose then\\\
		self.OnViewClose(self.View.Name)\\\
	end\\\
	if self.View then\\\
		self.View:OnRemove()\\\
	end\\\
	local success = false\\\
\\\
	if not fs.exists(self.ViewPath..name..'.view') then\\\
		error('The view: '..name..'.view does not exist.')\\\
	end\\\
\\\
	local h = fs.open(self.ViewPath..name..'.view', 'r')\\\
	if h then\\\
		local view = textutils.unserialize(h.readAll())\\\
		h.close()\\\
		if view then\\\
			self.View = View:InitialiseFile(self, view, name)\\\
			self:ReorderObjects()\\\
\\\
			if OneOS and view.ToolBarColour then\\\
				OneOS.ToolBarColour = view.ToolBarColour\\\
			end\\\
			if OneOS and view.ToolBarTextColour then\\\
				OneOS.ToolBarTextColour = view.ToolBarTextColour\\\
			end\\\
			if not self:GetActiveObject() then\\\
				self:SetActiveObject()\\\
			end\\\
			success = true\\\
		end\\\
	end\\\
\\\
	if success and self.OnViewLoad then\\\
		self.OnViewLoad(name)\\\
	end\\\
\\\
	if draw ~= false then\\\
		self:Draw()\\\
	end\\\
\\\
	if not success then\\\
		error('Failed to load view: '..name..'. It probably isn\\\\'t formatted correctly. Did you forget a } or ,?')\\\
	end\\\
\\\
	return success\\\
end\\\
\\\
function InheritFile(self, file, name)\\\
	local h = fs.open(self.ViewPath..name..'.view', 'r')\\\
	if h then\\\
		local super = textutils.unserialize(h.readAll())\\\
		if super then\\\
			if type(super) ~= 'table' then\\\
				error('View: \\\"'..name..'.view\\\" is not formatted correctly.')\\\
			end\\\
\\\
			for k, v in pairs(super) do\\\
				if not file[k] then\\\
					file[k] = v\\\
				end\\\
			end\\\
			return file\\\
		end\\\
	end\\\
	return file\\\
end\\\
\\\
function ParseStringSize(self, parent, k, v)\\\
		local parentSize = parent.Width\\\
		if k == 'Height' or k == 'Y' then\\\
			parentSize = parent.Height\\\
		end\\\
		local parts = {v}\\\
		if type(v) == 'string' and string.find(v, ',') then\\\
			parts = {}\\\
			for word in string.gmatch(v, '([^,]+)') do\\\
			    table.insert(parts, word)\\\
			end\\\
		end\\\
\\\
		v = 0\\\
		for i2, part in ipairs(parts) do\\\
			if type(part) == 'string' and part:sub(#part) == '%' then\\\
				v = v + math.ceil(parentSize * (tonumber(part:sub(1, #part-1)) / 100))\\\
			else\\\
				v = v + tonumber(part)\\\
			end\\\
		end\\\
		return v\\\
end\\\
\\\
function ObjectFromFile(self, file, view)\\\
	local env = getfenv()\\\
	if env[file.Type] then\\\
		if not env[file.Type].Initialise then\\\
			error('Malformed Object: '..file.Type)\\\
		end\\\
		local object = {}\\\
\\\
		if file.InheritView then\\\
			file = self:InheritFile(file, file.InheritView)\\\
		end\\\
		\\\
		object.AutoWidth = true\\\
		for k, v in pairs(file) do\\\
			if k == 'Width' or k == 'X' or k == 'Height' or k == 'Y' then\\\
				v = self:ParseStringSize(view, k, v)\\\
			end\\\
\\\
			if k == 'Width' then\\\
				object.AutoWidth = false\\\
			end\\\
			if k ~= 'Children' then\\\
				object[k] = v\\\
			else\\\
				object[k] = {}\\\
			end\\\
		end\\\
\\\
		object.Parent = view\\\
		object.Bedrock = self\\\
		if not object.Name then\\\
			object.Name = file.Type\\\
		end\\\
\\\
		object = env[file.Type]:Initialise(object)\\\
\\\
		if file.Children then\\\
			for i, obj in ipairs(file.Children) do\\\
				local _view = self:ObjectFromFile(obj, object)\\\
				if not _view.Z then\\\
					_view.Z = i\\\
				end\\\
				_view.Parent = object\\\
				table.insert(object.Children, _view)\\\
			end\\\
		end\\\
\\\
		if not object.OnClick then\\\
			object.OnClick = function(...) return self:ClickObject(...) end\\\
		end\\\
		--object.OnUpdate = function(...) self:UpdateObject(...) end\\\
\\\
		if object.OnUpdate then\\\
			for k, v in pairs(env[file.Type]) do\\\
				object:OnUpdate(k)\\\
			end\\\
\\\
			for k, v in pairs(object.__index) do\\\
				object:OnUpdate(k)\\\
			end\\\
		end\\\
\\\
		if object.Active then\\\
			object.Bedrock:SetActiveObject(object)\\\
		end\\\
		if object.OnLoad then\\\
			object:OnLoad()\\\
		end\\\
		return object\\\
	elseif not file.Type then\\\
		error('No object type specified. (e.g. Type = \\\"Button\\\")')\\\
	else\\\
		error('No Object: '..file.Type..'. The API probably isn\\\\'t loaded')\\\
	end\\\
end\\\
\\\
function ReorderObjects(self)\\\
	if self.View and self.View.Children then\\\
		table.sort(self.View.Children, function(a,b)\\\
			return a.Z < b.Z \\\
		end)\\\
	end\\\
end\\\
\\\
function AddObject(self, info, extra)\\\
	return self.View:AddObject(info, extra)\\\
end\\\
\\\
function GetObject(self, name)\\\
	return self.View:GetObject(name)\\\
end\\\
\\\
function GetObjects(self, name)\\\
	return self.View:GetObjects(name)\\\
end\\\
\\\
function RemoveObject(self, name)\\\
	return self.View:RemoveObject(name)\\\
end\\\
\\\
function RemoveObjects(self, name)\\\
	return self.View:RemoveObjects(name)\\\
end\\\
\\\
function ForceDraw(self)\\\
	if not self.DrawTimer or self.DrawTimerExpiry <= os.clock() then\\\
		self.DrawTimer = self:StartTimer(function()\\\
			self.DrawTimer = nil\\\
			self:Draw()\\\
		end, 0.05)\\\
		self.DrawTimerExpiry = os.clock() + 0.1\\\
	end\\\
end\\\
\\\
function DisplayWindow(self, _view, title, canClose)\\\
	if canClose == nil then\\\
		canClose = true\\\
	end\\\
	if type(_view) == 'string' then\\\
		local h = fs.open(self.ViewPath.._view..'.view', 'r')\\\
		if h then\\\
			_view = textutils.unserialize(h.readAll())\\\
			h.close()\\\
		end\\\
	end\\\
\\\
	self.Window = self:AddObject({Type = 'Window', Z = 999, Title = title, CanClose = canClose})\\\
	_view.Type = 'View'\\\
	_view.Name = 'View'\\\
	_view.BackgroundColour = _view.BackgroundColour or colours.white\\\
	self.Window:SetView(self:ObjectFromFile(_view, self.Window))\\\
end\\\
\\\
function DisplayAlertWindow(self, title, text, buttons, callback)\\\
	local func = function(btn)\\\
		self.Window:Close()\\\
		if callback then\\\
			callback(btn.Text)\\\
		end\\\
	end\\\
	local children = {}\\\
	local usedX = -1\\\
	if buttons then\\\
		for i, text in ipairs(buttons) do\\\
			usedX = usedX + 3 + #text\\\
			table.insert(children, {\\\
				[\\\"Y\\\"]=\\\"100%,-1\\\",\\\
				[\\\"X\\\"]=\\\"100%,-\\\"..usedX,\\\
				[\\\"Name\\\"]=text..\\\"Button\\\",\\\
				[\\\"Type\\\"]=\\\"Button\\\",\\\
				[\\\"Text\\\"]=text,\\\
				OnClick = func\\\
			})\\\
		end\\\
	end\\\
\\\
	local width = usedX + 2\\\
	if width < 28 then\\\
		width = 28\\\
	end\\\
\\\
	local canClose = true\\\
	if buttons and #buttons~=0 then\\\
		canClose = false\\\
	end\\\
\\\
	local height = 0\\\
	if text then\\\
		height = #Helpers.WrapText(text, width - 2)\\\
		table.insert(children, {\\\
			[\\\"Y\\\"]=2,\\\
			[\\\"X\\\"]=2,\\\
			[\\\"Width\\\"]=\\\"100%,-2\\\",\\\
			[\\\"Height\\\"]=height,\\\
			[\\\"Name\\\"]=\\\"Label\\\",\\\
			[\\\"Type\\\"]=\\\"Label\\\",\\\
			[\\\"Text\\\"]=text\\\
		})\\\
	end\\\
	local view = {\\\
		Children = children,\\\
		Width=width,\\\
		Height=3+height+(canClose and 0 or 1),\\\
		OnKeyChar = function(_view, keychar)\\\
			func({Text=buttons[1]})\\\
		end\\\
	}\\\
	self:DisplayWindow(view, title, canClose)\\\
end\\\
\\\
function DisplayTextBoxWindow(self, title, text, callback, textboxText, cursorAtEnd)\\\
	textboxText = textboxText or ''\\\
	local func = function(btn)\\\
		self.Window:Close()\\\
		if callback then\\\
			callback(btn.Text)\\\
		end\\\
	end\\\
	local children = {\\\
		{\\\
			[\\\"Y\\\"]=\\\"100%,-1\\\",\\\
			[\\\"X\\\"]=\\\"100%,-4\\\",\\\
			[\\\"Name\\\"]=\\\"OkButton\\\",\\\
			[\\\"Type\\\"]=\\\"Button\\\",\\\
			[\\\"Text\\\"]=\\\"Ok\\\",\\\
			OnClick = function()\\\
				local text = self.Window:GetObject('TextBox').Text\\\
				self.Window:Close()\\\
				callback(true, text)\\\
			end\\\
		},\\\
		{\\\
			[\\\"Y\\\"]=\\\"100%,-1\\\",\\\
			[\\\"X\\\"]=\\\"100%,-13\\\",\\\
			[\\\"Name\\\"]=\\\"CancelButton\\\",\\\
			[\\\"Type\\\"]=\\\"Button\\\",\\\
			[\\\"Text\\\"]=\\\"Cancel\\\",\\\
			OnClick = function()\\\
				self.Window:Close()\\\
				callback(false)\\\
			end\\\
		}\\\
	}\\\
\\\
	local height = -1\\\
	if text and #text ~= 0 then\\\
		height = #Helpers.WrapText(text, 26)\\\
		table.insert(children, {\\\
			[\\\"Y\\\"]=2,\\\
			[\\\"X\\\"]=2,\\\
			[\\\"Width\\\"]=\\\"100%,-2\\\",\\\
			[\\\"Height\\\"]=height,\\\
			[\\\"Name\\\"]=\\\"Label\\\",\\\
			[\\\"Type\\\"]=\\\"Label\\\",\\\
			[\\\"Text\\\"]=text\\\
		})\\\
	end\\\
	table.insert(children,\\\
		{\\\
			[\\\"Y\\\"]=3+height,\\\
			[\\\"X\\\"]=2,\\\
			[\\\"Width\\\"]=\\\"100%,-2\\\",\\\
			[\\\"Name\\\"]=\\\"TextBox\\\",\\\
			[\\\"Type\\\"]=\\\"TextBox\\\",\\\
			[\\\"Text\\\"]=textboxText,\\\
			[\\\"CursorPos\\\"]=(cursorAtEnd and 0 or nil)\\\
		})\\\
	local view = {\\\
		Children = children,\\\
		Width=28,\\\
		Height=5+height+(canClose and 0 or 1),\\\
	}\\\
	self:DisplayWindow(view, title)\\\
	self.Window:GetObject('TextBox').OnUpdate = function(txtbox, keychar)\\\
		if keychar == keys.enter then\\\
			self.Window:Close()\\\
			callback(true, txtbox.Text)\\\
		end\\\
	end\\\
	self:SetActiveObject(self.Window:GetObject('TextBox'))\\\
	self.Window.OnCloseButton = function()callback(false)end\\\
end\\\
\\\
function DisplayOpenFileWindow(self, title, callback)\\\
	title = title or 'Open File'\\\
	local func = function(btn)\\\
		self.Window:Close()\\\
		if callback then\\\
			callback(btn.Text)\\\
		end\\\
	end\\\
\\\
	local sidebarItems = {}\\\
\\\
	--this is a really, really super bad way of doing it\\\
	local separator = '                               !'\\\
\\\
	local function addFolder(path, level)\\\
		for i, v in ipairs(fs.list(path)) do\\\
			local fPath = path .. '/' .. v\\\
			if fPath ~= '/rom' and fs.isDir(fPath) then\\\
				table.insert(sidebarItems, level .. v..separator..fPath)\\\
				addFolder(fPath, level .. '  ')\\\
			end\\\
		end\\\
	end\\\
	addFolder('','')\\\
\\\
	local currentFolder = ''\\\
	local selectedPath = nil\\\
\\\
	local goToFolder = nil\\\
\\\
	local children = {\\\
		{\\\
			[\\\"Y\\\"]=\\\"100%,-2\\\",\\\
			[\\\"X\\\"]=1,\\\
			[\\\"Height\\\"]=3,\\\
			[\\\"Width\\\"]=\\\"100%\\\",\\\
			[\\\"BackgroundColour\\\"]=colours.lightGrey,\\\
			[\\\"Name\\\"]=\\\"SidebarListView\\\",\\\
			[\\\"Type\\\"]=\\\"View\\\"\\\
		},\\\
		{\\\
			[\\\"Y\\\"]=\\\"100%,-1\\\",\\\
			[\\\"X\\\"]=\\\"100%,-4\\\",\\\
			[\\\"Name\\\"]=\\\"OkButton\\\",\\\
			[\\\"Type\\\"]=\\\"Button\\\",\\\
			[\\\"Text\\\"]=\\\"Ok\\\",\\\
			[\\\"BackgroundColour\\\"]=colours.white,\\\
			[\\\"Enabled\\\"]=false,\\\
			OnClick = function()\\\
				if selectedPath then\\\
					self.Window:Close()\\\
					callback(true, Helpers.TidyPath(selectedPath))\\\
				end\\\
			end\\\
		},\\\
		{\\\
			[\\\"Y\\\"]=\\\"100%,-1\\\",\\\
			[\\\"X\\\"]=\\\"100%,-13\\\",\\\
			[\\\"Name\\\"]=\\\"CancelButton\\\",\\\
			[\\\"Type\\\"]=\\\"Button\\\",\\\
			[\\\"Text\\\"]=\\\"Cancel\\\",\\\
			[\\\"BackgroundColour\\\"]=colours.white,\\\
			OnClick = function()\\\
				self.Window:Close()\\\
				callback(false)\\\
			end\\\
		},\\\
		{\\\
			[\\\"Y\\\"]=1,\\\
			[\\\"X\\\"]=1,\\\
			[\\\"Height\\\"]=\\\"100%,-3\\\",\\\
			[\\\"Width\\\"]=\\\"40%,-1\\\",\\\
			[\\\"Name\\\"]=\\\"SidebarListView\\\",\\\
			[\\\"Type\\\"]=\\\"ListView\\\",\\\
			[\\\"CanSelect\\\"]=true,\\\
			[\\\"Items\\\"]={\\\
				[\\\"Computer\\\"] = sidebarItems\\\
			},\\\
			OnSelect = function(listView, text)\\\
				local _,s = text:find(separator)\\\
				if s then\\\
					local path = text:sub(s + 1)\\\
					goToFolder(path)\\\
				end\\\
			end,\\\
			OnClick = function(listView, event, side, x, y)\\\
				if y == 1 then\\\
					goToFolder('/')\\\
				end\\\
			end\\\
		},\\\
		{\\\
			[\\\"Y\\\"]=1,\\\
			[\\\"X\\\"]=\\\"40%\\\",\\\
			[\\\"Height\\\"]=\\\"100%,-3\\\",\\\
			[\\\"Width\\\"]=1,\\\
			[\\\"Type\\\"]=\\\"Separator\\\"\\\
		},\\\
		{\\\
			[\\\"Y\\\"]=1,\\\
			[\\\"X\\\"]=\\\"40%,2\\\",\\\
			[\\\"Width\\\"]=\\\"65%,-3\\\",\\\
			[\\\"Height\\\"]=1,\\\
			[\\\"Type\\\"]=\\\"Label\\\",\\\
			[\\\"Name\\\"]=\\\"PathLabel\\\",\\\
			[\\\"TextColour\\\"]=colours.lightGrey,\\\
			[\\\"Text\\\"]='/hello/there'\\\
		},\\\
		{\\\
			[\\\"Y\\\"]=2,\\\
			[\\\"X\\\"]=\\\"40%,1\\\",\\\
			[\\\"Height\\\"]=\\\"100%,-4\\\",\\\
			[\\\"Width\\\"]=\\\"65%,-1\\\",\\\
			[\\\"Name\\\"]=\\\"FilesListView\\\",\\\
			[\\\"Type\\\"]=\\\"ListView\\\",\\\
			[\\\"CanSelect\\\"]=true,\\\
			[\\\"Items\\\"]={},\\\
			OnSelect = function(listView, text)\\\
				selectedPath = Helpers.TidyPath(currentFolder .. '/' .. text)\\\
				self.Window:GetObject('OkButton').Enabled = true\\\
			end,\\\
			OnClick = function(listView, event, side, x, y)\\\
				if y == 1 then\\\
					goToFolder('/')\\\
				end\\\
			end\\\
		},\\\
	}\\\
	local view = {\\\
		Children = children,\\\
		Width=40,\\\
		Height= Drawing.Screen.Height - 4\\\
	}\\\
	self:DisplayWindow(view, title)\\\
\\\
	goToFolder = function(path)\\\
		path = Helpers.TidyPath(path)\\\
		self.Window:GetObject('PathLabel').Text = path\\\
		currentFolder = path\\\
\\\
		local filesListItems = {}\\\
		for i, v in ipairs(fs.list(path)) do\\\
			if not fs.isDir(currentFolder .. v) then\\\
				table.insert(filesListItems, v)\\\
			end\\\
		end\\\
		self.Window:GetObject('OkButton').Enabled = false\\\
		selectedPath = nil\\\
		self.Window:GetObject('FilesListView').Items = filesListItems\\\
\\\
	end\\\
\\\
	goToFolder('')\\\
\\\
	self.Window.OnCloseButton = function()callback(false)end\\\
end\\\
\\\
function RegisterEvent(self, event, func)\\\
	if not self.EventHandlers[event] then\\\
		self.EventHandlers[event] = {}\\\
	end\\\
	table.insert(self.EventHandlers[event], func)\\\
end\\\
\\\
function StartRepeatingTimer(self, func, interval)\\\
	local int = interval\\\
	if type(int) == 'function' then\\\
		int = int()\\\
	end\\\
	if not int or int <= 0 then\\\
		return\\\
	end\\\
	local timer = os.startTimer(int)\\\
\\\
	self.Timers[timer] = {func, true, interval}\\\
	return timer\\\
end\\\
\\\
function StartTimer(self, func, delay)\\\
	local timer = os.startTimer(delay)\\\
	self.Timers[timer] = {func, false}\\\
	return timer\\\
end\\\
\\\
function StopTimer(self, timer)\\\
	if self.Timers[timer] then\\\
		self.Timers[timer] = nil\\\
	end\\\
end\\\
\\\
function HandleTimer(self, event, timer)\\\
	if self.Timers[timer] then\\\
		local oldTimer = self.Timers[timer]\\\
		self.Timers[timer] = nil\\\
		local new = nil\\\
		if oldTimer[2] then\\\
			new = self:StartRepeatingTimer(oldTimer[1], oldTimer[3])\\\
		end\\\
		if oldTimer and oldTimer[1] then\\\
			oldTimer[1](new)\\\
		end\\\
	elseif self.OnTimer then\\\
		self.OnTimer(self, event, timer)\\\
	end\\\
end\\\
\\\
function SetActiveObject(self, object)\\\
	if object then\\\
		if object ~= self.ActiveObject then\\\
			self.ActiveObject = object\\\
			object:ForceDraw()\\\
		end\\\
	elseif self.ActiveObject ~= nil then\\\
		self.ActiveObject = nil\\\
		self.CursorPos = nil\\\
		self.View:ForceDraw()\\\
	end\\\
end\\\
\\\
function GetActiveObject(self)\\\
	return self.ActiveObject\\\
end\\\
\\\
OnTimer = nil\\\
OnClick = nil\\\
OnKeyChar = nil\\\
OnDrag = nil\\\
OnScroll = nil\\\
OnViewLoad = nil\\\
OnViewClose = nil\\\
OnDraw = nil\\\
OnQuit = nil\\\
\\\
local eventFuncs = {\\\
	OnClick = {'mouse_click', 'monitor_touch'},\\\
	OnKeyChar = {'key', 'char'},\\\
	OnDrag = {'mouse_drag'},\\\
	OnScroll = {'mouse_scroll'},\\\
	HandleClick = {'mouse_click', 'mouse_drag', 'mouse_scroll', 'monitor_touch'},\\\
	HandleKeyChar = {'key', 'char'},\\\
	HandleTimer = {'timer'}\\\
}\\\
\\\
local drawCalls = 0\\\
local ignored = 0\\\
function Draw(self)\\\
	self.IsDrawing = true\\\
	if self.OnDraw then\\\
		self:OnDraw()\\\
	end\\\
\\\
	if self.View and self.View:NeedsDraw() then\\\
		self.View:Draw()\\\
		Drawing.DrawBuffer()\\\
		if isDebug then\\\
			drawCalls = drawCalls + 1\\\
		end\\\
	elseif not self.View then\\\
		print('No loaded view. You need to do program:LoadView first.')\\\
	end	\\\
\\\
	if self:GetActiveObject() and self.CursorPos and type(self.CursorPos[1]) == 'number' and type(self.CursorPos[2]) == 'number' then\\\
		term.setCursorPos(self.CursorPos[1], self.CursorPos[2])\\\
		term.setTextColour(self.CursorColour)\\\
		term.setCursorBlink(true)\\\
	else\\\
		term.setCursorBlink(false)\\\
	end\\\
\\\
	self.IsDrawing = false\\\
end\\\
\\\
function EventHandler(self)\\\
	local event = { os.pullEventRaw() }\\\
	\\\
	if self.EventHandlers[event[1]] then\\\
		for i, e in ipairs(self.EventHandlers[event[1]]) do\\\
			e(self, unpack(event))\\\
		end\\\
	end\\\
end\\\
\\\
function Quit(self)\\\
	self.Running = false\\\
	if self.OnQuit then\\\
		self:OnQuit()\\\
	end\\\
	if OneOS then\\\
		OneOS.Close()\\\
	end\\\
end\\\
\\\
function Run(self, ready)\\\
	for name, events in pairs(eventFuncs) do\\\
		if self[name] then\\\
			for i, event in ipairs(events) do\\\
				self:RegisterEvent(event, self[name])\\\
			end\\\
		end\\\
	end\\\
\\\
	if self.AllowTerminate then\\\
		self:RegisterEvent('terminate', function()error('Terminated', 0) end)\\\
	end\\\
\\\
	if self.DefaultView and self.DefaultView ~= '' and fs.exists(self.ViewPath..self.DefaultView..'.view') then\\\
		self:LoadView(self.DefaultView)\\\
	end\\\
\\\
	if ready then\\\
		ready()\\\
	end\\\
	\\\
	self:Draw()\\\
\\\
	while self.Running do\\\
		self:EventHandler()\\\
	end\\\
end\",\
    [ \"Desktop/Door Lock.shortcut\" ] = \"/Programs/Door Lock.program/\",\
    [ \"Programs/Transmit.program/Images/anm1\" ] = \" f  7         \\\
 f 7        7   \\\
7f    e       7 \\\
 f  e      e    \\\
 f    7       \",\
    [ \"System/API/Program.lua\" ] = \"Process = nil\\\
EventQueue = {}\\\
Timers = {}\\\
AppRedirect = nil\\\
Running = true\\\
Hidden = false\\\
local _args = {}\\\
Initialise = function(self, shell, path, title, args)\\\
	Log.i('Starting program: '..title..' ('..path..')')\\\
	local new = {}    -- the new instance\\\
	setmetatable( new, {__index = self} )\\\
	_args = args\\\
	new.Title = title or path\\\
	new.Path = path\\\
	new.Timers = {}\\\
	new.EventQueue = {}\\\
	new.AppRedirect = AppRedirect:Initialise(new)\\\
	new.Environment = Environment:Initialise(new, shell, path)\\\
	new.Running = true\\\
	if args.isHidden then\\\
		new.Hidden = true\\\
	end\\\
\\\
	local executable = function()\\\
		local _, err = pcall(function()\\\
			--os.run(new.Environment, path, unpack(args))\\\
			local fnFile, err2 = nil\\\
			local h = OneOS.FS.open( path, \\\"r\\\")\\\
			if h then\\\
				fnFile, err2 = loadstring( h.readAll(), OneOS.FS.getName(path) )\\\
				if err2 then\\\
					err2 = err2:gsub(\\\"^.-: %[string \\\\\\\"\\\",\\\"\\\")\\\
					err2 = err2:gsub('\\\"%]',\\\"\\\")\\\
				end\\\
				h.close()\\\
			end\\\
	        local tEnv = new.Environment\\\
			setmetatable( tEnv, { __index = _G } )\\\
			setfenv( fnFile, tEnv )\\\
\\\
			if (not fnFile) or err2 then\\\
				term.setTextColour(colours.red)\\\
				term.setBackgroundColour(colours.black)\\\
				if err2 then\\\
					print(err2)\\\
				end\\\
				if err2 == 'File not found' then\\\
					term.clear()\\\
					term.setTextColour(colours.white)\\\
					term.setCursorPos(1,2)\\\
					print('The program could not be found or is corrupt.')\\\
					print()\\\
					print('Try running the program again or reinstalling it.')\\\
					print()\\\
					print()\\\
				end\\\
				return false\\\
			end\\\
\\\
			local ok, err3 = pcall( function()\\\
	        	fnFile( unpack( args ) )\\\
	        end )\\\
	        if not ok then\\\
	        	if err3 and err3 ~= \\\"\\\" then\\\
					term.setTextColour(colours.red)\\\
					term.setBackgroundColour(colours.black)\\\
					term.setCursorPos(1,1)\\\
					print(err3)\\\
		        end\\\
	        end\\\
		end)\\\
\\\
    	if not _ and err and err ~= \\\"\\\" then\\\
			term.setTextColour(colours.red)\\\
			term.setBackgroundColour(colours.black)\\\
			term.setCursorPos(1,1)\\\
			print(err)\\\
		end\\\
	end\\\
\\\
	table.insert(Current.Programs, new)\\\
	Current.Program = new\\\
\\\
	if executable then\\\
		setfenv(executable, new.Environment)\\\
		new.Process = coroutine.create(executable)\\\
		new:Resume()\\\
	else\\\
		printError('Failed to load program: '..path)\\\
	end\\\
	Current.ProgramView:ForceDraw()\\\
\\\
	return new\\\
end\\\
\\\
Restart = function(self)\\\
	local path = self.Path\\\
	local title = self.Title\\\
	self:Close()\\\
	Helpers.LaunchProgram(path, {}, title)\\\
end\\\
\\\
QueueEvent = function(self, ...)\\\
	table.insert(self.EventQueue, {...})\\\
end\\\
\\\
Click = function(self, event, button, x, y)\\\
	if self.Running and self.Process and coroutine.status(self.Process) ~= \\\"dead\\\" then\\\
		self:QueueEvent(event, button, x, y)\\\
	else\\\
		self:Close()\\\
	end\\\
end\\\
\\\
Resume = function(self, ...)\\\
	local event = {...}\\\
	local result = false\\\
	_G.package = {\\\
		config = {\\\"/\\\", \\\";\\\", \\\"?\\\", \\\"!\\\", \\\"-\\\"},\\\
		loaded = _G,\\\
		preload = {},\\\
		path = \\\"/rom/apis/?;/rom/apis/?.lua;/rom/apis/?/init.lua;/rom/modules/main/?;rom/modules/main/?.lua;/rom/modules/main/?/init.lua\\\"\\\
	}\\\
	xpcall(function()\\\
			if not self.Process or coroutine.status(self.Process) == \\\"dead\\\" then\\\
				return false\\\
			end\\\
\\\
			term.redirect(self.AppRedirect.Term)\\\
			local response = {coroutine.resume(self.Process, unpack(event))}\\\
			if not response[1] and response[2] then\\\
				print()\\\
		    	term.setTextColour(colours.red)\\\
		    	print('The program has crashed.')\\\
		    	print(response[2])\\\
		    	Log.e('Program crashed')\\\
		    	Log.e(response[2])\\\
		    	self:Kill(1)\\\
			elseif coroutine.status(self.Process) == \\\"dead\\\" then\\\
		    	print()\\\
		    	term.setTextColour(colours.red)\\\
		    	print('The program has finished.')\\\
		    	self:Kill(0)\\\
		    end\\\
		    restoreTerm()\\\
		    --Drawing.DrawBuffer()\\\
		    result = unpack(response)\\\
		end, function(err)\\\
			if string.find(err, \\\"Too long without yielding\\\") then\\\
		    	term.redirect(self.AppRedirect.Term)\\\
		    	print()\\\
		    	term.setTextColour(colours.red)\\\
		    	print('Too long without yielding')\\\
		    	Log.e('Too long without yielding')\\\
		    	self:Kill(0)\\\
		    	restoreTerm()\\\
		    else\\\
		    	Log.e(err)\\\
		    	error(err)\\\
			end\\\
		end)\\\
	if result then\\\
		return result\\\
	end\\\
end\\\
\\\
Kill = function(self, code)\\\
	term.setBackgroundColour(colours.black)\\\
	term.setTextColour(colours.white)\\\
	term.setCursorBlink(false)\\\
	print('Click anywhere to close this program.')\\\
	for i, program in ipairs(Current.Programs) do\\\
		if program == self then\\\
			Current.Programs[i].Running = false\\\
			if code ~= 0 then\\\
				coroutine.yield(Current.Programs[i].Process)\\\
			end\\\
			Current.Programs[i].Process = nil\\\
		end\\\
	end\\\
end\\\
\\\
Close = function(self, force)\\\
	if force or not self.Environment.OneOS.CanClose or self.Environment.OneOS.CanClose() ~= false then\\\
		Log.i('Closing program: '..self.Title)\\\
		if self == Current.Program then\\\
			Current.Program = nil\\\
		end\\\
		for i, program in ipairs(Current.Programs) do\\\
			if program == self then\\\
				table.remove(Current.Programs, i)\\\
				break\\\
			end\\\
		end\\\
		UpdateOverlay()\\\
		Current.ProgramView:ForceDraw()\\\
		return true\\\
	else\\\
		Log.i('Closing program aborted: '..self.Title)\\\
		return false\\\
	end\\\
end\\\
\\\
SwitchTo = function(self)\\\
	if Current.Program ~= self then\\\
		Current.Program = self\\\
		Current.ProgramView:ForceDraw()\\\
	end\\\
end\\\
\\\
RenderPreview = function(self, width, height)\\\
	local preview = {}\\\
	local deltaX = self.AppRedirect.Size[1] / width\\\
	local deltaY = self.AppRedirect.Size[2] / height\\\
\\\
	for _x = 1, width do\\\
		local x = Helpers.Round(1 + (_x - 1) * deltaX)\\\
		preview[_x] = {}\\\
		for _y = 1, height do\\\
			local y = Helpers.Round(1 + (_y - 1) * deltaY)\\\
			preview[_x][_y] = self.AppRedirect.Buffer[y][x]\\\
		end\\\
	end\\\
	return preview\\\
end\",\
    [ \"Programs/Games/Maze3D.program/startup\" ] = \"OneOS.LoadAPI('/System/API/Bedrock.lua', false)\\\
\\\
local program = Bedrock:Initialise()\\\
\\\
program:ObjectClick('YesButton', function(self, event, side, x, y)\\\
	OneOS.Run('/Programs/App Store.program/', 'install', 61, 'Games', true)\\\
	OneOS.Close()\\\
end)\\\
\\\
program:ObjectClick('NoButton', function(self, event, side, x, y)\\\
	OneOS.Close()\\\
end)\\\
\\\
program:Run(function()\\\
	program:LoadView('main')\\\
end)\",\
    [ \"README.md\" ] = \"Version 1.2 (beta)\\\
====\\\
I am currently working on version 1.2, I'm not sure when it will be released, but it's got some *huge* changes. The most significant being the new Bedrock framework which revolutionizes how GUI programs are made. You can try it out, by downloading this git, but the latest build may crash immediatly, so don't expect it to work. If it crashes or doesn't work well download the latest stable commit (pre-Bedrock): https://github.com/oeed/OneOS/archive/c3c1e7eb061397cecf49d74a0eac6dc03fb28f48.zip\\\
\\\
You will need to create a file named '.version' in the System folder and type in: 'v1.1.1' for it to work.\\\
\\\
OneOS\\\
====\\\
\\\
If you are going to modify any part of OneOS you MUST set isDebug to true in the startup folder. Otherwise I'll be bombarded with error reports that have nothing to do with me.\\\
\\\
Forums Post: http://www.computercraft.info/forums2/index.php?s=6cde19f0e95d5793f759f7ab9687abe4&app=forums&module=post&section=post&do=edit_post&f=32&t=17286&p=166445&st=0&_from=quickedit\\\
\\\
Late last year I looked at PearOS and a few other ComputerCraft OSs and tried to find the best parts and problems with each. I found that in the case of PearOS and a few others you couldn't do anything. PearOS was nice and shiny, but it was completely useless. Others such as CraftBang were much loved by the community, however, I felt that CraftBang was a bit hard to use and a bit too plain. So, I set off to try to combine all the best parts of other OSs and a few things of my own in to one. I've tried to include everything into OneOS and what I couldn't/haven't can be found on the App Store (more on that later). In essence, it is an 'All in one OS' (are you picking up the meaning of the name yet :P)\\\
\\\
So, anyway, enough history. I present you the 21 thousand plus line monstrosity that is OneOS.\\\
\\\
I've compiled a fairly compact (trust me, a lot of features aren't listed) list of the main ones:\\\
- The ability to run any ComputerCraft program\\\
- Multitasking (not windowed, this was intentional)\\\
- A desktop interface\\\
- Custom file and folder icons\\\
- An easy to use file browser\\\
- An App Store\\\
- A very advanced Photoshop inspired image editor (Sketch)\\\
- An AirDrop like program to send files between computers quickly and easily\\\
- The ability to package a folder with a single click (similar to .zip files)\\\
- Aforementioned packages can then be extracted with a single click\\\
- A peripheral browser\\\
- A few games & LuaIDE\\\
- Auto-updating\\\
- A storage usage information page\\\
- Animations galore!\\\
- Many more\\\
- As you've hopefully picked up, this isn't another basic login screen OS. I started working on this in November and have worked on it fairly constantly since then.\\\
\\\
Installation\\\
====\\\
\\\
Simply run:\\\
pastebin run E1xftzLa\\\
\\\
If the above does not work replace run with 'get' and add 'installer' to the end, then type 'installer' in to the shell.\\\
\\\
FAQ\\\
====\\\
\\\
Why aren't you using windows?\\\
A few reasons, screen real estate is very minimal in CC, windows make that even worse. Many programs don't redraw when the screen size changes and they tend to be rather annoying to use. I'm quite happy with the tab based system in OneOS.\\\
\\\
Can you add ***?\\\
Let me know below, if it think it's a good idea and won't be too hard to add I might add it.\\\
\\\
I've found a bug/I've got a suggestion!\\\
Please to the GitHub issues page and make an issue there. Avoid posting an issue that is already listed.\\\
\\\
I'll add more here when people start asking more questions.\",\
    [ \"Programs/Quest.program/Pages/3.ccml\" ] = \"<!DOCTYPE ccml>\\\
<html>\\\
	<head>\\\
	  <title>Failed to Parse Page</title>\\\
	</head>\\\
	<body>\\\
		<br/>\\\
		<br/>\\\
		<h colour=\\\"red\\\">Failed to Parse Page</h>\\\
		<br/>\\\
		<center>\\\
			<br>\\\
			<p width=\\\"38\\\" align=\\\"center\\\">The page you requested failed to parse. It is either malformed or your browser is out of date.</p>\\\
		</center>\\\
	</body>\\\
</html>\",\
    [ \"System/API/Clipboard.lua\" ] = \"Content = nil\\\
Type = nil\\\
IsCut = false\\\
\\\
function Empty()\\\
	Clipboard.Content = nil\\\
	Clipboard.Type = nil\\\
	Clipboard.IsCut = false\\\
end\\\
\\\
function isEmpty()\\\
	return Clipboard.Content == nil\\\
end\\\
\\\
function Copy(content, _type)\\\
	Clipboard.Content = content\\\
	Clipboard.Type = _type or 'generic'\\\
	Clipboard.IsCut = false\\\
end\\\
\\\
function Cut(content, _type)\\\
	Clipboard.Content = content\\\
	Clipboard.Type = _type or 'generic'\\\
	Clipboard.IsCut = true\\\
end\\\
\\\
function Paste()\\\
	local c, t = Clipboard.Content, Clipboard.Type\\\
	if Clipboard.IsCut then\\\
		Clipboard.Empty()\\\
	end\\\
	return c, t\\\
end\",\
    [ \"Programs/Quest Server.program/Server Files/index.ccml\" ] = \"<!DOCTYPE ccml>\\\
<html>\\\
    <head>\\\
        <title>Welcome to your Quest Server Website!</title>\\\
    </head>\\\
\\\
    <body>\\\
        <br>\\\
        <h colour=\\\"green\\\">Welcome to your Quest Server Website!</h>\\\
        <br>\\\
        <center>\\\
	        <p width=\\\"46\\\" align=\\\"center\\\">\\\
	            The files for this website are stored in the /Server Files/ folder on the server.\\\
	        </p>\\\
	        <br>\\\
	        <p width=\\\"46\\\" align=\\\"center\\\">\\\
	            If you haven't made a Quest web page before you should look for the CCML tutorial on the ComputerCraft forums.\\\
	        </p>\\\
        </center>\\\
    </body>\\\
</html>\",\
    [ \"Programs/Door Lock.program/icon\" ] = \"1f 0|=f \\\
1f 0|f  \\\
10 @f  \",\
    [ \"Programs/Games/Gold Runner.program/Views/main.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"Toolbar\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"InheritView\\\"]=\\\"toolbar\\\"\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=5,\\\
      [\\\"X\\\"]=3,\\\
      [\\\"Width\\\"]=\\\"100%,-4\\\",\\\
      [\\\"Height\\\"]=3,\\\
      [\\\"Name\\\"]=\\\"Label\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"To save disc space, OneOS does not come with Gold Runner downloaded by default. Do you want to download it now?\\\"\\\
    },\\\
    [3]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"100%,-6\\\",\\\
      [\\\"Name\\\"]=\\\"YesButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"Yes\\\",\\\
      [\\\"BackgroundColour\\\"]=8192,\\\
      [\\\"TextColour\\\"]=1\\\
    },\\\
    [4]={\\\
      [\\\"Y\\\"]=\\\"100%,-1\\\",\\\
      [\\\"X\\\"]=\\\"100%,-11\\\",\\\
      [\\\"Name\\\"]=\\\"NoButton\\\",\\\
      [\\\"Type\\\"]=\\\"Button\\\",\\\
      [\\\"Text\\\"]=\\\"No\\\",\\\
      [\\\"BackgroundColour\\\"]=16384,\\\
      [\\\"TextColour\\\"]=1\\\
    },\\\
  },\\\
  [\\\"BackgroundColour\\\"]=1,\\\
  [\\\"ToolBarColour\\\"] = 128,\\\
  [\\\"ToolBarTextColour\\\"] = 1\\\
}\",\
    [ \"Programs/Games/Lasers.program/Views/toolbar.view\" ] = \"{\\\
  [\\\"Width\\\"]=\\\"100%\\\",\\\
  [\\\"Height\\\"]=3,\\\
  [\\\"Type\\\"]=\\\"View\\\",\\\
  [\\\"BackgroundColour\\\"] = 128,\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=2,\\\
      [\\\"Name\\\"]=\\\"InstallLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Install\\\",\\\
      [\\\"TextColour\\\"]=1\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=10,\\\
      [\\\"Name\\\"]=\\\"ProgramNameLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Lasers\\\",\\\
      [\\\"TextColour\\\"]=256\\\
    },\\\
  },\\\
}\",\
    [ \"System/Views/firstsetup.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Width\\\"]=\\\"100%\\\",\\\
      [\\\"Height\\\"]=\\\"100%\\\",\\\
      [\\\"Name\\\"]=\\\"ProgramView\\\",\\\
      [\\\"Type\\\"]=\\\"ProgramView\\\",\\\
      [\\\"Active\\\"]=true\\\
    },\\\
  }\\\
}\",\
    [ \"System/Images/Boot/boot1\" ] = \"         8888          \\\
        888888         \\\
        888888         \\\
         8888          \\\
                       \\\
                       \\\
                       \\\
77788888888888888888888\",\
    [ \"Programs/Shell.program/icon\" ] = \"f4>0_   \\\
f    \\\
f    \",\
    [ \"Programs/Quest.program/startup\" ] = \"local QuestVersion = 'v0.9.0 Private Beta'\\\
if OneOS then\\\
	QuestVersion = QuestVersion .. '-OneOS ' .. OneOS.Version\\\
end\\\
\\\
-- TODO: have a much simpler API loader... not a 70+ line one\\\
local Extension = function(path, addDot)\\\
	if not path then\\\
		return nil\\\
	elseif not string.find(fs.getName(path), '%.') then\\\
		if not addDot then\\\
			return fs.getName(path)\\\
		else\\\
			return ''\\\
		end\\\
	else\\\
		local _path = path\\\
		if path:sub(#path) == '/' then\\\
			_path = path:sub(1,#path-1)\\\
		end\\\
		local extension = _path:gmatch('%.[0-9a-z]+$')()\\\
		if extension then\\\
			extension = extension:sub(2)\\\
		else\\\
			--extension = nil\\\
			return ''\\\
		end\\\
		if addDot then\\\
			extension = '.'..extension\\\
		end\\\
		return extension:lower()\\\
	end\\\
end\\\
\\\
local RemoveExtension = function(path)\\\
	if path:sub(1,1) == '.' then\\\
		return path\\\
	end\\\
	local extension = Extension(path)\\\
	if extension == path then\\\
		return fs.getName(path)\\\
	end\\\
	return string.gsub(path, extension, ''):sub(1, -2)\\\
end\\\
\\\
local tAPIsLoading = {}\\\
local function LoadAPI(_sPath)\\\
	local sName = RemoveExtension(fs.getName( _sPath ))\\\
	if tAPIsLoading[sName] == true then\\\
	end\\\
	tAPIsLoading[sName] = true\\\
		\\\
	local tEnv = {isStartup = true }\\\
	setmetatable( tEnv, { __index = getfenv()} )\\\
	local fnAPI, err = loadfile( _sPath )\\\
	if fnAPI then\\\
		setfenv( fnAPI, tEnv )\\\
		fnAPI()\\\
	else\\\
		printError( err )\\\
		log('Error: '..err)\\\
        tAPIsLoading[sName] = nil\\\
		return false\\\
	end\\\
	\\\
	local tAPI = {}\\\
	for k,v in pairs( tEnv ) do\\\
		tAPI[k] =  v\\\
	end\\\
	\\\
	_G[sName] = tAPI\\\
end\\\
\\\
_G.Errors = {\\\
	Unknown = 1,\\\
	InvalidDoctype = 2,\\\
	ParseFailed = 3,\\\
	NotFound = 404,\\\
	TimeoutStop = 408,\\\
}\\\
\\\
local bedrockPath='/' if OneOS then OneOS.LoadAPI('/System/API/Bedrock.lua', false)elseif fs.exists(bedrockPath..'/Bedrock')then os.loadAPI(bedrockPath..'/Bedrock')else if http then print('Downloading Bedrock...')local h=http.get('http://pastebin.com/raw.php?i=0MgKNqpN')if h then local f=fs.open(bedrockPath..'/Bedrock','w')f.write(h.readAll())f.close()h.close()os.loadAPI(bedrockPath..'/Bedrock')else error('Failed to download Bedrock. Is your internet working?') end else error('This program needs to download Bedrock to work. Please enable HTTP.') end end if Bedrock then Bedrock.BasePath = bedrockPath Bedrock.ProgramPath = shell.getRunningProgram() end\\\
\\\
os.loadAPI('parser')\\\
os.loadAPI('hash')\\\
os.loadAPI('lQuery')\\\
\\\
if OneOS then\\\
	OneOS.LoadAPI('/System/API/Hash.lua')\\\
	hash = Hash\\\
	OneOS.LoadAPI('/System/API/Wireless.lua')\\\
	OneOS.LoadAPI('/System/API/Peripheral.lua')\\\
else\\\
	os.loadAPI('Peripheral')\\\
	os.loadAPI('Wireless')\\\
end\\\
\\\
LoadAPI('Elements/Element.lua')\\\
\\\
LoadAPI('Elements/ElementTree.lua')\\\
\\\
local elements = {\\\
	'Script',\\\
	'Center',\\\
	'Link',\\\
	'Image',\\\
	'Divider',\\\
	'Heading',\\\
	'Paragraph',\\\
	'Float',\\\
	'TextInput',\\\
	'FileInput',\\\
	'SecureTextInput',\\\
	'Select',\\\
	'Form',\\\
	'SelectOption',\\\
	'ButtonInput',\\\
	'HiddenInput',\\\
}\\\
\\\
for i, v in ipairs(elements) do\\\
	LoadAPI('Elements/' .. v .. '.lua')\\\
	local env = getfenv()\\\
	local super = Element\\\
	if env[v].Inherit then\\\
		super = env[env[v].Inherit]\\\
	end\\\
	env[v].__index = super\\\
	setmetatable(env[v], env[v])\\\
end\\\
\\\
local program = Bedrock:Initialise()\\\
\\\
local function split(str, pat)\\\
   local t = {}\\\
   local fpat = \\\"(.-)\\\" .. pat\\\
   local last_end = 1\\\
   local s, e, cap = str:find(fpat, 1)\\\
   while s do\\\
      if s ~= 1 or cap ~= \\\"\\\" then\\\
	 table.insert(t,cap)\\\
      end\\\
      last_end = e+1\\\
      s, e, cap = str:find(fpat, last_end)\\\
   end\\\
   if last_end <= #str then\\\
      cap = str:sub(last_end)\\\
      table.insert(t, cap)\\\
   end\\\
   return t\\\
end\\\
\\\
local httpQueue = {}\\\
\\\
program:RegisterEvent('http_success', function(self, event, url, response)\\\
	for i, request in ipairs(httpQueue) do\\\
		if request[3] == url then\\\
			request[2](true, url, response)\\\
			table.remove(httpQueue, i)\\\
			break\\\
		end\\\
	end\\\
end)\\\
\\\
program:RegisterEvent('http_failure', function(self, event, url)\\\
	for i, request in ipairs(httpQueue) do\\\
		if request[3] == url then\\\
			request[2](false, Errors.Unknown)\\\
			table.remove(httpQueue, i)\\\
			break\\\
		end\\\
	end\\\
end)\\\
\\\
program:RegisterEvent('modem_message', function(self, event, side, channel, replyChannel, message, distance)\\\
	Wireless.HandleMessage(event, side, channel, replyChannel, message, distance)\\\
end)\\\
\\\
local wifiQueue = {}\\\
\\\
Wireless.Responder = function(event, side, channel, replyChannel, message, distance)\\\
	if channel == Wireless.Channels.QuestServerRequestReply then\\\
		for i, request in ipairs(wifiQueue) do\\\
			if request[1] == message.content.url then\\\
				if message.content.content then\\\
					local line = 0\\\
					local lines = split(message.content.content, '\\\\n')\\\
					local handle = {\\\
						readAll = function()return message.content.content end,\\\
						readLine = function()\\\
							line = line + 1\\\
							return lines[line]\\\
						end,\\\
						close = function()end\\\
					}\\\
					request[2](true, message.content.url, handle)\\\
				else\\\
					request[2](false, 404)\\\
				end\\\
				table.remove(wifiQueue, i)\\\
				break\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
local function cancelHTTPAsync(url)\\\
	for i, request in ipairs(httpQueue) do\\\
		if request[1] == url then\\\
			request[2](false, Errors.TimeoutStop)\\\
			table.remove(httpQueue, i)\\\
			break\\\
		end\\\
	end\\\
end\\\
\\\
local settings = false\\\
\\\
local function fetchHTTPAsync(url, callback, post)\\\
	local components = urlComponents(url)\\\
	if components.protocol == 'quest' then\\\
		local file = fs.open(program.ProgramPath .. '/Pages/' .. components.filepathsansget, 'r')\\\
		callback(true, url, file)\\\
	elseif components.protocol == 'file' then\\\
		local file = fs.open(components.sansprotocol, 'r')\\\
		if file then\\\
			callback(true, url, file)\\\
		else\\\
			callback(false)\\\
		end\\\
	elseif components.protocol == 'wifi' then\\\
		if Wireless.Present() then\\\
			table.insert(wifiQueue, {url, callback})\\\
			Wireless.SendMessage(Wireless.Channels.QuestServerRequest, url)\\\
		else\\\
			callback(false, 7)\\\
		end\\\
	elseif components.protocol == 'http' then\\\
		local _url = resolveQuestHostUrl(url)\\\
		table.insert(httpQueue, {url, callback, _url})\\\
\\\
		if not post then\\\
			post = 'questClientIdentifier=' .. textutils.urlEncode(settings.ClientIdentifier)\\\
		else\\\
			post = post .. '&questClientIdentifier=' .. textutils.urlEncode(settings.ClientIdentifier)\\\
		end\\\
		http.request(_url, post, {\\\
			['User-Agent'] = 'Quest/'..QuestVersion\\\
		})\\\
	end\\\
end\\\
\\\
local questHost = 'http://quest.net76.net/sites/'\\\
\\\
local function findLast(haystack, needle)\\\
    local i=haystack:match(\\\".*\\\"..needle..\\\"()\\\")\\\
    if i==nil then return nil else return i-1 end\\\
end\\\
\\\
local hex_to_char = function(x)\\\
  return string.char(tonumber(x, 16))\\\
end\\\
\\\
local function urlUnencode( str )\\\
	-- essentially reverses textutils.urlDecode\\\
    if str then\\\
        str = string.gsub(str, \\\"+\\\", \\\" \\\")\\\
        str = string.gsub(str, \\\"\\\\r\\\\n\\\", \\\"\\\\n\\\")\\\
        term.setTextColor(colors.black)\\\
        str = str:gsub(\\\"%%(%x%x)\\\", hex_to_char)\\\
    end\\\
    return str    \\\
end\\\
\\\
local function urlComponents(url)\\\
	if url then\\\
		urlUnencode(textutils.urlEncode(url))\\\
		local components = {}\\\
		local parts = split(url, '[\\\\\\\\/]+')\\\
		if url:find('://') and parts[1]:sub(#parts[1]) == ':' then\\\
			components.protocol = parts[1]:sub(1, #parts[1]-1)\\\
			components.sansprotocol = url:sub(#components.protocol + 4)\\\
			components.host = parts[2]\\\
			components.fullhost = components.protocol .. '://' .. parts[2] .. '/'\\\
			components.filepath = url:sub(#components.fullhost)\\\
			if components.filepath:sub(#components.filepath) ~= '/' and components.filepath:find('?') then\\\
				components.filename = fs.getName(components.filepath:sub(1, components.filepath:find('?') - 1))\\\
			else\\\
				components.filename = fs.getName(components.filepath)\\\
			end\\\
			if components.filename == 'root' or components.filename == components.host then\\\
				components.filename = ''\\\
			end\\\
			components.base = url:sub(1, findLast(url, '/'))\\\
			components.get = {}\\\
			components.filepathsansget = components.sansprotocol\\\
			if url:find('?') then\\\
				local start = url:find('?')\\\
				components.filepathsansget = url:sub(#components.protocol + 4, start - 1)\\\
				local getString = url:sub(start + 1)\\\
				local values = split(getString, '&')\\\
				for i, v in ipairs(values) do\\\
					local keyvalue = split(v, '=')\\\
					components.get[keyvalue[1]] =  urlUnencode(keyvalue[2])\\\
				end\\\
			end\\\
			return components\\\
		end\\\
	end\\\
end\\\
\\\
local function resolveQuestHostUrl(url)\\\
	local components = urlComponents(url)\\\
	local hostParts = split(components.host, '%.')\\\
	local tld = hostParts[#hostParts]\\\
	if tld == 'qst' and #hostParts == 2 then\\\
		return questHost .. hostParts[1] .. components.filepath\\\
	end\\\
	return url\\\
end\\\
\\\
local function resolveFullUrl(url)\\\
	if url and type(url) ~= 'string' then\\\
	elseif url:find('://') then\\\
		return url\\\
	else\\\
		local components = urlComponents(program:GetObject('WebView').URL)\\\
		if components then\\\
			if url:sub(1,1) == '/' then\\\
				return components.fullhost .. url:sub(2)\\\
			else\\\
				return components.base .. url\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
local function getCurrentUrl()\\\
	return program:GetObject('WebView').URL\\\
end\\\
\\\
local function getCurrentFakeUrl()\\\
	return program:GetObject('WebView').FakeURL\\\
end\\\
\\\
local function goToUrl(url, post)\\\
	program:GetObject('WebView'):GoToURL(url, nil, nil, post)\\\
end\\\
\\\
--	Yes, it's evil and terrible, etc. But I'll hopefully change it later.\\\
_G.cancelHTTPAsync = cancelHTTPAsync\\\
_G.fetchHTTPAsync = fetchHTTPAsync\\\
_G.resolveFullUrl = resolveFullUrl\\\
_G.resolveQuestHostUrl = resolveQuestHostUrl\\\
_G.getCurrentUrl = getCurrentUrl\\\
_G.getCurrentFakeUrl = getCurrentFakeUrl\\\
_G.goToUrl = goToUrl\\\
_G.split = split\\\
_G.urlComponents = urlComponents\\\
_G.QuestVersion = QuestVersion\\\
\\\
local history = {}\\\
local historyItem = 0\\\
\\\
local function updateHistoryButtons()\\\
	if history[historyItem-1] then\\\
		program:GetObject('BackButton').Enabled = true\\\
	else\\\
		program:GetObject('BackButton').Enabled = false\\\
	end\\\
\\\
	if history[historyItem+1] then\\\
		program:GetObject('ForwardButton').Enabled = true\\\
	else\\\
		program:GetObject('ForwardButton').Enabled = false\\\
	end\\\
end\\\
\\\
local function addHistoryURL(url)\\\
	for i, v in ipairs(history) do\\\
		if i > historyItem then\\\
			history[i] = nil\\\
		end\\\
	end\\\
	table.insert(history, url)\\\
	historyItem = #history\\\
	updateHistoryButtons()\\\
end\\\
\\\
local defaultSettings = {\\\
	Home = 'http://thehub.qst/',\\\
	ClientIdentifier = nil\\\
}\\\
\\\
local function quit()\\\
	term.setBackgroundColour(colors.black)\\\
	shell.run('clear')\\\
	print('Thanks for using Quest, created by oeed.')\\\
	program:Quit()\\\
end\\\
\\\
local function goHome()\\\
	goToUrl(settings.Home)\\\
end\\\
\\\
local function saveSettings()\\\
	local f = fs.open('.Quest.settings', 'w')\\\
	if f then\\\
		f.write(textutils.serialize(settings))\\\
		f.close()\\\
	end\\\
end\\\
\\\
local function generateClientIdentifier()\\\
	program:DisplayWindow({\\\
		Children = {{\\\
			X = 2,\\\
			Y = 2,\\\
			Type = \\\"Label\\\",\\\
			Width = \\\"100%,-2\\\",\\\
			Height = 2,\\\
			Text = \\\"Registering computer with central server...\\\"\\\
		}},\\\
		Width = 28,\\\
		Height = 4\\\
	}, \\\"Please Wait\\\", false)\\\
	program:Draw()\\\
	local h = http.get('http://quest.net76.net/registerClient.php')\\\
	program.Window:Close()\\\
\\\
	if h then\\\
		settings.ClientIdentifier = h.readAll()\\\
		saveSettings()\\\
		h.close()\\\
		goHome()\\\
	else\\\
		program:DisplayAlertWindow(\\\"Register Failed\\\", \\\"Quest couldn't register your computer. There was something wrong with your internet connection. Please quit and try again.\\\", {'Quit'}, function(value)\\\
			quit()\\\
		end)\\\
	end\\\
\\\
end\\\
\\\
local function loadSettings()\\\
	if fs.exists('.Quest.settings') then\\\
		local f = fs.open('.Quest.settings', 'r')\\\
		if f then\\\
			settings = textutils.unserialize(f.readAll())\\\
			if not settings.ClientIdentifier then\\\
				generateClientIdentifier()\\\
			end\\\
			return settings\\\
		end\\\
	end\\\
\\\
	settings = defaultSettings\\\
	generateClientIdentifier()\\\
end\\\
\\\
program:Run(function()\\\
	local timeoutTimer = false\\\
\\\
	program:LoadView('main')\\\
\\\
	Wireless.Initialise()\\\
\\\
	loadSettings()\\\
\\\
	program:GetObject('BackButton').OnClick = function(self)\\\
		if history[historyItem-1] then\\\
			historyItem = historyItem - 1\\\
			program:GetObject('WebView'):GoToURL(history[historyItem], nil, true)\\\
			updateHistoryButtons()\\\
		end\\\
	end\\\
\\\
	program:GetObject('ForwardButton').OnClick = function(self)\\\
		if history[historyItem+1] then\\\
			historyItem = historyItem + 1\\\
			program:GetObject('WebView'):GoToURL(history[historyItem], nil, true)\\\
			updateHistoryButtons()\\\
		end\\\
	end\\\
\\\
	program:GetObject('URLTextBox').OnChange = function(self, event, keychar)\\\
		if keychar == keys.enter then\\\
			local url = self.Text\\\
			if not url:find('://') then\\\
				if url:find(' ') or not url:find('%.') then\\\
					url = 'http://thehub.qst/search.php?q='..textutils.urlEncode(url)\\\
				else\\\
					url = 'http://' .. url \\\
				end\\\
				self.Text = url\\\
			end\\\
			program:GetObject('WebView'):GoToURL(url)\\\
		end\\\
	end\\\
\\\
	program:GetObject('OptionsButton').OnClick = function(self, event, side, x, y)\\\
		if self:ToggleMenu('optionsmenu', x, y) then\\\
			program:GetObject('StopMenuItem').OnClick = function(self, event, side, x, y)\\\
				program:GetObject('WebView'):Stop()\\\
			end\\\
\\\
			program:GetObject('ReloadMenuItem').OnClick = function(self, event, side, x, y)\\\
				program:GetObject('WebView'):GoToURL(program:GetObject('WebView').URL)\\\
			end\\\
\\\
			program:GetObject('GoHomeMenuItem').OnClick = function(self, event, side, x, y)\\\
				goHome()\\\
			end\\\
\\\
			program:GetObject('SetHomeMenuItem').OnClick = function(self, event, side, x, y)\\\
				settings.Home = program:GetObject('WebView').FakeURL\\\
				saveSettings()\\\
			end\\\
\\\
			program:GetObject('QuitMenuItem').OnClick = function(self, event, side, x, y)\\\
				quit()\\\
			end\\\
		end\\\
	end\\\
\\\
	program:GetObject('WebView').OnPageLoadStart = function(self, url)\\\
		program:SetActiveObject()\\\
		-- program:GetObject('GoButton').Text = 'x'\\\
		program:GetObject('URLTextBox').Visible = false\\\
		program:GetObject('LoadingLabel').Visible = true\\\
		program:GetObject('PageTitleLabel').Text = ''\\\
		if OneOS then\\\
			OneOS.SetTitle('Quest')\\\
		end\\\
\\\
		if url:find('http://') or url:find('https://') then\\\
			timeoutTimer = program:StartTimer(function()\\\
				program:GetObject('WebView'):Stop()\\\
			end, 20)\\\
		else\\\
			timeoutTimer = program:StartTimer(function()\\\
				program:GetObject('WebView'):Stop()\\\
			end, 1)\\\
		end\\\
	end\\\
\\\
	program:GetObject('WebView').OnPageLoadEnd = function(self, url, noHistory)\\\
		program:GetObject('URLTextBox').Text = url\\\
		program:GetObject('URLTextBox').Visible = true\\\
		program:GetObject('LoadingLabel').Visible = false\\\
\\\
		local title = ''\\\
		if self.Tree:GetElement('title') then\\\
			title = self.Tree:GetElement('title').Text\\\
		end\\\
\\\
		if OneOS then\\\
			if #title == 0 then\\\
				OneOS.SetTitle('Quesst')\\\
			else\\\
				OneOS.SetTitle(title)\\\
			end\\\
		else\\\
			program:GetObject('PageTitleLabel').Text = title\\\
		end\\\
\\\
		if not noHistory then\\\
			addHistoryURL(url)\\\
		end\\\
\\\
		program.Timers[timeoutTimer] = nil\\\
	end\\\
\\\
	program:GetObject('WebView').OnPageLoadFailed = function(self, url, _error, noHistory)\\\
		program:GetObject('URLTextBox').Text = url\\\
		program:GetObject('URLTextBox').Visible = true\\\
		program:GetObject('LoadingLabel').Visible = false\\\
		program.Timers[timeoutTimer] = nil\\\
\\\
		if not noHistory then\\\
			addHistoryURL(url)\\\
		end\\\
		\\\
		local get = ''\\\
		_error = _error or 1\\\
		if type(_error) == 'string' then\\\
			get = '?reason='..textutils.urlEncode(_error)\\\
			_error = 'text'\\\
		end\\\
\\\
		program:GetObject('WebView'):GoToURL('quest://'.._error..'.ccml'..get, true, true)\\\
	end\\\
\\\
	program:GetObject('Toolbar').OnClick = function(self, event, side, x, y)\\\
		program:SetActiveObject()\\\
	end\\\
\\\
	program:GetObject('WebView').OnClick = function(self, event, side, x, y)\\\
		program:SetActiveObject()\\\
	end\\\
\\\
	if settings.ClientIdentifier then\\\
		goHome()\\\
	end\\\
end)\\\
\\\
\",\
    [ \"System/Programs/First Setup.program/startup\" ] = \"OneOS.LoadAPI('/System/API/Bedrock.lua', false)\\\
OneOS.LoadAPI('/System/API/Hash.lua')\\\
\\\
local program = Bedrock:Initialise()\\\
\\\
Current = {\\\
	Page = 1,\\\
	ComputerName = nil,\\\
	DesktopColour = nil,\\\
	AnimationsEnabled = nil,\\\
	Password = nil\\\
}\\\
\\\
function LoadCurrentView()\\\
	program:LoadView('page'..Current.Page)\\\
end\\\
\\\
program.OnViewClose = function(viewName)\\\
	if viewName == 'page2' then\\\
		Current.ComputerName = program:GetObject('ComputerNameTextBox').Text\\\
	elseif viewName == 'page3' then\\\
		Current.DesktopColour = program:GetObject('ColourWell').BackgroundColour\\\
	end\\\
end\\\
\\\
program.OnKeyChar = function(keychar)\\\
	if keychar == '\\\\\\\\' then\\\
		os.reboot()\\\
	end\\\
end\\\
\\\
program.OnViewLoad = function(viewName)\\\
	if viewName == 'page2' and Current.ComputerName then\\\
		program:GetObject('ComputerNameTextBox').Text = Current.ComputerName\\\
	elseif viewName == 'page3' and Current.DesktopColour then\\\
		program:GetObject('ColourWell').BackgroundColour = Current.DesktopColour\\\
	end\\\
end\\\
\\\
program:ObjectClick('NextButton', function(self, event, side, x, y)\\\
	Current.Page = Current.Page + 1\\\
	LoadCurrentView()\\\
end)\\\
\\\
program:ObjectClick('PasswordNextButton', function(self, event, side, x, y)\\\
	if program:GetObject('PasswordTextBox').Text == '' then\\\
		Current.Password = nil\\\
		program:GetObject('NoMatchLabel').Visible = false\\\
	elseif program:GetObject('PasswordTextBox').Text == program:GetObject('ConfirmPasswordTextBox').Text then\\\
		Current.Password = Hash.sha256(program:GetObject('PasswordTextBox').Text)\\\
		program:GetObject('NoMatchLabel').Visible = false\\\
	else\\\
		program:GetObject('NoMatchLabel').Visible = true\\\
		return\\\
	end\\\
	Current.Page = Current.Page + 1\\\
	LoadCurrentView()\\\
end)\\\
\\\
program:ObjectClick('BackButton', function(self, event, side, x, y)\\\
	Current.Page = Current.Page - 1\\\
	LoadCurrentView()\\\
end)\\\
\\\
program:ObjectClick('YesButton', function(self, event, side, x, y)\\\
	Current.Page = Current.Page + 1\\\
	Current.AnimationsEnabled = true\\\
	LoadCurrentView()\\\
end)\\\
\\\
program:ObjectClick('NoButton', function(self, event, side, x, y)\\\
	Current.Page = Current.Page + 1\\\
	Current.AnimationsEnabled = false\\\
	LoadCurrentView()\\\
end)\\\
\\\
program:ObjectClick('RestartButton', function(self, event, side, x, y)\\\
	if not OneOS.FS.exists('/System/.version') and OneOS.FS.exists('.version') then\\\
		OneOS.FS.copy('.version', '/System/.version')\\\
		OneOS.FS.delete('.version')\\\
	end\\\
\\\
	local h = OneOS.FS.open('/System/.OneOS.settings', 'w')\\\
	local settings = {\\\
		ComputerName = Current.ComputerName,\\\
		DesktopColour = Current.DesktopColour,\\\
		UseAnimations = Current.AnimationsEnabled,\\\
		Password = Current.Password\\\
	}\\\
	os.setComputerLabel(settings.ComputerName)\\\
	h.write(textutils.serialize(settings))\\\
	h.close()\\\
\\\
	OneOS.Log.i('Trying to reboot...')\\\
	OneOS.Restart(true)\\\
	print('You might have to hold Ctrl + R if you\\\\'re seeing this.')\\\
end)\\\
\\\
program:ObjectClick('ColourButton', function(self, event, side, x, y)\\\
	program:GetObject('ColourWell').BackgroundColour = self.BackgroundColour\\\
end)\\\
\\\
program:ObjectUpdate('ComputerNameTextBox', function(self, keychar)\\\
end)\\\
\\\
program:Run(function()\\\
	LoadCurrentView()\\\
end)\",\
    [ \"Programs/Quest.program/Pages/404.ccml\" ] = \"<!DOCTYPE ccml>\\\
<html>\\\
	<head>\\\
	  <title>Page Not Found</title>\\\
	</head>\\\
	<body>\\\
		<br/>\\\
		<br/>\\\
		<h colour=\\\"red\\\">404 Page Not Found</h>\\\
		<br/>\\\
		<center>\\\
			<p width=\\\"38\\\" align=\\\"center\\\">The page was not found on the server. Check the address and try again.</p>\\\
		</center>\\\
	</body>\\\
</html>\",\
    [ \"Programs/Quest.program/Pages/6.ccml\" ] = \"<!DOCTYPE ccml>\\\
<html>\\\
	<head>\\\
	  <title>Download Failed</title>\\\
	</head>\\\
	<body>\\\
		<br/>\\\
		<br/>\\\
		<h colour=\\\"red\\\">Download Failed</h>\\\
		<br/>\\\
		<center>\\\
			<br>\\\
			<p width=\\\"38\\\" align=\\\"center\\\">The file you wanted failed to download. Try again or contact the file owner.</p>\\\
		</center>\\\
	</body>\\\
</html>\",\
    [ \"Programs/Quest.program/Pages/5.ccml\" ] = \"<!DOCTYPE ccml>\\\
<html>\\\
	<head>\\\
	  <title>Page Not Whitelisted</title>\\\
	</head>\\\
	<body>\\\
		<br/>\\\
		<br/>\\\
		<h colour=\\\"red\\\">Page Not Whitelisted</h>\\\
		<br/>\\\
		<center>\\\
			<br>\\\
			<p width=\\\"38\\\" align=\\\"center\\\">The page you are trying to open isn't whitelisted. Please take a look on the forums or the wiki as to how to fix this.</p>\\\
		</center>\\\
	</body>\\\
</html>\",\
    [ \"Programs/Quest.program/Pages/408.ccml\" ] = \"<!DOCTYPE ccml>\\\
<html>\\\
	<head>\\\
	  <title>Page Not Found</title>\\\
	</head>\\\
	<body>\\\
		<br/>\\\
		<br/>\\\
		<h colour=\\\"red\\\">Page Load Cancelled</h>\\\
		<br/>\\\
		<center>\\\
			<p width=\\\"38\\\" align=\\\"center\\\">The page either took too long to load or you cancelled loading it.</p>\\\
		</center>\\\
	</body>\\\
</html>\",\
    [ \"Programs/Door Lock.program/startup\" ] = \"tArgs={...}\\\
if OneOS then\\\
OneOS.ToolBarColour=colours.white\\\
OneOS.ToolBarTextColour=colours.grey\\\
end\\\
local t,a=term.getSize()\\\
local l=function(t,e)\\\
local e=10^(e or 0)\\\
return math.floor(t*e+.5)/e\\\
end\\\
InterfaceElements={}\\\
Drawing={\\\
Screen={\\\
Width=t,\\\
Height=a\\\
},\\\
DrawCharacters=function(t,e,a,o,i)\\\
Drawing.WriteStringToBuffer(t,e,a,o,i)\\\
end,\\\
DrawBlankArea=function(e,a,t,i,o)\\\
Drawing.DrawArea(e,a,t,i,\\\" \\\",1,o)\\\
end,\\\
DrawArea=function(t,s,e,n,o,a,i)\\\
if e<0 then\\\
e=e*-1\\\
elseif e==0 then\\\
e=1\\\
end\\\
for e=1,e do\\\
local t=t+e-1\\\
for e=1,n do\\\
local e=s+e-1\\\
Drawing.WriteToBuffer(t,e,o,a,i)\\\
end\\\
end\\\
end,\\\
DrawImage=function(n,s,t,o,i)\\\
if t then\\\
for e=1,i do\\\
if not t[e]then\\\
break\\\
end\\\
for a=1,o do\\\
if not t[e][a]then\\\
break\\\
end\\\
local i=t[e][a]\\\
local o=t.textcol[e][a]or colours.white\\\
local t=t.text[e][a]\\\
Drawing.WriteToBuffer(a+n-1,e+s-1,t,o,i)\\\
end\\\
end\\\
elseif o and i then\\\
Drawing.DrawBlankArea(x,y,o,i,colours.green)\\\
end\\\
end,\\\
LoadImage=function(e)\\\
local t={\\\
text={},\\\
textcol={}\\\
}\\\
local a=fs\\\
if OneOS then\\\
a=OneOS.FS\\\
end\\\
if a.exists(e)then\\\
local a=io.open\\\
if OneOS then\\\
a=OneOS.IO.open\\\
end\\\
local r=a(e,\\\"r\\\")\\\
local i=r:read()\\\
local e=1\\\
while i do\\\
table.insert(t,e,{})\\\
table.insert(t.text,e,{})\\\
table.insert(t.textcol,e,{})\\\
local o=1\\\
local h,s=false,false\\\
local d,n=nil,nil\\\
for a=1,#i do\\\
local a=string.sub(i,a,a)\\\
if a:byte()==30 then\\\
h=true\\\
elseif a:byte()==31 then\\\
s=true\\\
elseif h then\\\
d=Drawing.GetColour(a)\\\
h=false\\\
elseif s then\\\
n=Drawing.GetColour(a)\\\
s=false\\\
else\\\
if a~=\\\" \\\"and n==nil then\\\
n=colours.white\\\
end\\\
t[e][o]=d\\\
t.textcol[e][o]=n\\\
t.text[e][o]=a\\\
o=o+1\\\
end\\\
end\\\
e=e+1\\\
i=r:read()\\\
end\\\
r:close()\\\
end\\\
return t\\\
end,\\\
DrawCharactersCenter=function(e,t,a,o,i,n,s)\\\
a=a or Drawing.Screen.Width\\\
o=o or Drawing.Screen.Height\\\
e=e or 0\\\
t=t or 0\\\
e=math.ceil((a-#i)/2)+e\\\
t=math.floor(o/2)+t\\\
Drawing.DrawCharacters(e,t,i,n,s)\\\
end,\\\
GetColour=function(e)\\\
if e==' 'then\\\
return colours.transparent\\\
end\\\
local e=tonumber(e,16)\\\
if not e then return nil end\\\
e=math.pow(2,e)\\\
return e\\\
end,\\\
Clear=function(e)\\\
e=e or colours.black\\\
Drawing.ClearBuffer()\\\
Drawing.DrawBlankArea(1,1,Drawing.Screen.Width,Drawing.Screen.Height,e)\\\
end,\\\
Buffer={},\\\
BackBuffer={},\\\
DrawBuffer=function()\\\
for e,t in pairs(Drawing.Buffer)do\\\
for t,a in pairs(t)do\\\
local i=true\\\
local o=true\\\
if Drawing.BackBuffer[e]==nil or Drawing.BackBuffer[e][t]==nil or#Drawing.BackBuffer[e][t]~=3 then\\\
o=false\\\
end\\\
if o and Drawing.BackBuffer[e][t][1]==Drawing.Buffer[e][t][1]and Drawing.BackBuffer[e][t][2]==Drawing.Buffer[e][t][2]and Drawing.BackBuffer[e][t][3]==Drawing.Buffer[e][t][3]then\\\
i=false\\\
end\\\
if i then\\\
term.setBackgroundColour(a[3])\\\
term.setTextColour(a[2])\\\
term.setCursorPos(t,e)\\\
term.write(a[1])\\\
end\\\
end\\\
end\\\
Drawing.BackBuffer=Drawing.Buffer\\\
Drawing.Buffer={}\\\
term.setCursorPos(1,1)\\\
end,\\\
ClearBuffer=function()\\\
Drawing.Buffer={}\\\
end,\\\
WriteStringToBuffer=function(i,n,t,a,o)\\\
for e=1,#t do\\\
local t=t:sub(e,e)\\\
Drawing.WriteToBuffer(i+e-1,n,t,a,o)\\\
end\\\
end,\\\
WriteToBuffer=function(t,e,a,i,o)\\\
t=l(t)\\\
e=l(e)\\\
if o==colours.transparent then\\\
Drawing.Buffer[e]=Drawing.Buffer[e]or{}\\\
Drawing.Buffer[e][t]=Drawing.Buffer[e][t]or{\\\"\\\",colours.white,colours.black}\\\
Drawing.Buffer[e][t][1]=a\\\
Drawing.Buffer[e][t][2]=i\\\
else\\\
Drawing.Buffer[e]=Drawing.Buffer[e]or{}\\\
Drawing.Buffer[e][t]={a,i,o}\\\
end\\\
end,\\\
}\\\
Current={\\\
Document=nil,\\\
TextInput=nil,\\\
CursorPos={1,1},\\\
CursorColour=colours.black,\\\
Selection={8,36},\\\
Window=nil,\\\
HeaderText='',\\\
StatusText='',\\\
StatusColour=colours.grey,\\\
StatusScreen=true,\\\
ButtonOne=nil,\\\
ButtonTwo=nil,\\\
Locked=false,\\\
Page='',\\\
PageControls={}\\\
}\\\
isRunning=true\\\
Events={}\\\
Button={\\\
X=1,\\\
Y=1,\\\
Width=0,\\\
Height=0,\\\
BackgroundColour=colours.lightGrey,\\\
TextColour=colours.white,\\\
ActiveBackgroundColour=colours.lightGrey,\\\
Text=\\\"\\\",\\\
Parent=nil,\\\
_Click=nil,\\\
Toggle=nil,\\\
AbsolutePosition=function(e)\\\
return e.Parent:AbsolutePosition()\\\
end,\\\
Draw=function(e)\\\
local t=e.BackgroundColour\\\
local o=e.TextColour\\\
if type(t)=='function'then\\\
t=t()\\\
end\\\
if e.Toggle then\\\
o=colours.white\\\
t=e.ActiveBackgroundColour\\\
end\\\
local a=GetAbsolutePosition(e)\\\
Drawing.DrawBlankArea(a.X,a.Y,e.Width,e.Height,t)\\\
Drawing.DrawCharactersCenter(a.X,a.Y,e.Width,e.Height,e.Text,o,t)\\\
end,\\\
Initialise=function(o,i,l,c,t,u,n,h,a,d,r,s)\\\
local e={}\\\
setmetatable(e,{__index=o})\\\
t=t or 1\\\
e.Width=c or#a+2\\\
e.Height=t\\\
e.Y=l\\\
e.X=i\\\
e.Text=a or\\\"\\\"\\\
e.BackgroundColour=u or colours.lightGrey\\\
e.TextColour=d or colours.white\\\
e.ActiveBackgroundColour=s or colours.lightBlue\\\
e.Parent=n\\\
e._Click=h\\\
e.Toggle=r\\\
return e\\\
end,\\\
Click=function(e,o,t,a)\\\
if e._Click then\\\
if e:_Click(o,t,a,not e.Toggle)~=false and e.Toggle~=nil then\\\
e.Toggle=not e.Toggle\\\
Draw()\\\
end\\\
return true\\\
else\\\
return false\\\
end\\\
end\\\
}\\\
Label={\\\
X=1,\\\
Y=1,\\\
Width=0,\\\
Height=0,\\\
BackgroundColour=colours.lightGrey,\\\
TextColour=colours.white,\\\
Text=\\\"\\\",\\\
Parent=nil,\\\
AbsolutePosition=function(e)\\\
return e.Parent:AbsolutePosition()\\\
end,\\\
Draw=function(e)\\\
local t=e.BackgroundColour\\\
local a=e.TextColour\\\
if e.Toggle then\\\
a=UIColours.MenuBarActive\\\
t=e.ActiveBackgroundColour\\\
end\\\
local t=GetAbsolutePosition(e)\\\
Drawing.DrawCharacters(t.X,t.Y,e.Text,e.TextColour,e.BackgroundColour)\\\
end,\\\
Initialise=function(h,n,s,t,i,a,o)\\\
local e={}\\\
setmetatable(e,{__index=h})\\\
height=height or 1\\\
e.Width=width or#t+2\\\
e.Height=height\\\
e.Y=s\\\
e.X=n\\\
e.Text=t or\\\"\\\"\\\
e.BackgroundColour=a or colours.white\\\
e.TextColour=i or colours.black\\\
e.Parent=o\\\
return e\\\
end,\\\
Click=function(e,e,e,e)\\\
return false\\\
end\\\
}\\\
TextBox={\\\
X=1,\\\
Y=1,\\\
Width=0,\\\
Height=0,\\\
BackgroundColour=colours.lightGrey,\\\
TextColour=colours.black,\\\
Parent=nil,\\\
TextInput=nil,\\\
Placeholder='',\\\
AbsolutePosition=function(e)\\\
return e.Parent:AbsolutePosition()\\\
end,\\\
Draw=function(e)\\\
local t=GetAbsolutePosition(e)\\\
Drawing.DrawBlankArea(t.X,t.Y,e.Width,e.Height,e.BackgroundColour)\\\
local a=e.TextInput.Value\\\
if#tostring(a)>(e.Width-2)then\\\
a=a:sub(#a-(e.Width-3))\\\
if Current.TextInput==e.TextInput then\\\
Current.CursorPos={t.X+1+e.Width-2,t.Y}\\\
end\\\
else\\\
if Current.TextInput==e.TextInput then\\\
Current.CursorPos={t.X+1+e.TextInput.CursorPos,t.Y}\\\
end\\\
end\\\
if#tostring(a)==0 then\\\
Drawing.DrawCharacters(t.X+1,t.Y,e.Placeholder,colours.lightGrey,e.BackgroundColour)\\\
else\\\
Drawing.DrawCharacters(t.X+1,t.Y,a,e.TextColour,e.BackgroundColour)\\\
end\\\
term.setCursorBlink(true)\\\
Current.CursorColour=e.TextColour\\\
end,\\\
Initialise=function(s,d,l,u,t,r,a,h,n,o,i)\\\
local e={}\\\
setmetatable(e,{__index=s})\\\
t=t or 1\\\
e.Width=u or#a+2\\\
e.Height=t\\\
e.Y=l\\\
e.X=d\\\
e.TextInput=TextInput:Initialise(a or'',function(e)\\\
if o then\\\
o(e)\\\
end\\\
Draw()\\\
end,i)\\\
e.BackgroundColour=h or colours.lightGrey\\\
e.TextColour=n or colours.black\\\
e.Parent=r\\\
return e\\\
end,\\\
Click=function(e,t,t,t)\\\
Current.Input=e.TextInput\\\
e:Draw()\\\
end\\\
}\\\
TextInput={\\\
Value=\\\"\\\",\\\
Change=nil,\\\
CursorPos=nil,\\\
Numerical=false,\\\
IsDocument=nil,\\\
Initialise=function(n,t,o,i,a)\\\
local e={}\\\
setmetatable(e,{__index=n})\\\
e.Value=tostring(t)\\\
e.Change=o\\\
e.CursorPos=#tostring(t)\\\
e.Numerical=i\\\
e.IsDocument=a or false\\\
return e\\\
end,\\\
Insert=function(e,a)\\\
if e.Numerical then\\\
a=tostring(tonumber(a))\\\
end\\\
local t=OrderSelection()\\\
if e.IsDocument and t then\\\
e.Value=string.sub(e.Value,1,t[1]-1)..a..string.sub(e.Value,t[2]+2)\\\
e.CursorPos=t[1]\\\
Current.Selection=nil\\\
else\\\
local o,t=string.gsub(e.Value:sub(1,e.CursorPos),'\\\\n','')\\\
e.Value=string.sub(e.Value,1,e.CursorPos+t)..a..string.sub(e.Value,e.CursorPos+1+t)\\\
e.CursorPos=e.CursorPos+1\\\
end\\\
e.Change(key)\\\
end,\\\
Extract=function(t,o)\\\
local e=OrderSelection()\\\
if t.IsDocument and e then\\\
local i,a=string.gsub(t.Value:sub(e[1],e[2]),'\\\\n','')\\\
local i=string.sub(t.Value,e[1],e[2]+1+a)\\\
if o then\\\
t.Value=string.sub(t.Value,1,e[1]-1)..string.sub(t.Value,e[2]+2+a)\\\
t.CursorPos=e[1]-1\\\
Current.Selection=nil\\\
end\\\
return i\\\
end\\\
end,\\\
Char=function(t,e)\\\
if e=='nil'then\\\
return\\\
end\\\
t:Insert(e)\\\
end,\\\
Key=function(e,t)\\\
if t==keys.enter then\\\
if e.IsDocument then\\\
e.Value=string.sub(e.Value,1,e.CursorPos)..'\\\\n'..string.sub(e.Value,e.CursorPos+1)\\\
e.CursorPos=e.CursorPos+1\\\
end\\\
e.Change(t)\\\
elseif t==keys.left then\\\
if e.CursorPos>0 then\\\
local a=FindColours(string.sub(e.Value,e.CursorPos,e.CursorPos))\\\
e.CursorPos=e.CursorPos-1-a\\\
e.Change(t)\\\
end\\\
elseif t==keys.right then\\\
if e.CursorPos<string.len(e.Value)then\\\
local a=FindColours(string.sub(e.Value,e.CursorPos+1,e.CursorPos+1))\\\
e.CursorPos=e.CursorPos+1+a\\\
e.Change(t)\\\
end\\\
elseif t==keys.backspace then\\\
if e.IsDocument and Current.Selection then\\\
e:Extract(true)\\\
e.Change(t)\\\
elseif e.CursorPos>0 then\\\
local a=FindColours(string.sub(e.Value,e.CursorPos,e.CursorPos))\\\
local i,o=string.gsub(e.Value:sub(1,e.CursorPos),'\\\\n','')\\\
e.Value=string.sub(e.Value,1,e.CursorPos-1-a+o)..string.sub(e.Value,e.CursorPos+1-a+o)\\\
e.CursorPos=e.CursorPos-1-a\\\
e.Change(t)\\\
end\\\
elseif t==keys.home then\\\
e.CursorPos=0\\\
e.Change(t)\\\
elseif t==keys.delete then\\\
if e.IsDocument and Current.Selection then\\\
e:Extract(true)\\\
e.Change(t)\\\
elseif e.CursorPos<string.len(e.Value)then\\\
e.Value=string.sub(e.Value,1,e.CursorPos)..string.sub(e.Value,e.CursorPos+2)\\\
e.Change(t)\\\
end\\\
elseif t==keys[\\\"end\\\"]then\\\
e.CursorPos=string.len(e.Value)\\\
e.Change(t)\\\
elseif t==keys.up and e.IsDocument then\\\
if Current.Document.CursorPos then\\\
local a=Current.Document.Pages[Current.Document.CursorPos.Page]\\\
e.CursorPos=a:GetCursorPosFromPoint(Current.Document.CursorPos.Collum+a.MarginX,Current.Document.CursorPos.Line-a.MarginY-1+Current.Document.ScrollBar.Scroll,true)\\\
e.Change(t)\\\
end\\\
elseif t==keys.down and e.IsDocument then\\\
if Current.Document.CursorPos then\\\
local a=Current.Document.Pages[Current.Document.CursorPos.Page]\\\
e.CursorPos=a:GetCursorPosFromPoint(Current.Document.CursorPos.Collum+a.MarginX,Current.Document.CursorPos.Line-a.MarginY+1+Current.Document.ScrollBar.Scroll,true)\\\
e.Change(t)\\\
end\\\
end\\\
end\\\
}\\\
local e=function(e)\\\
return e:sub(1,1):upper()..e:sub(2,-1)\\\
end\\\
local a=peripheral.getNames or function()\\\
local a={}\\\
for t,e in ipairs(rs.getSides())do\\\
if peripheral.isPresent(e)then\\\
table.insert(a,e)\\\
local t=false\\\
if not pcall(function()t=peripheral.call(e,'isWireless')end)then\\\
t=true\\\
end\\\
if peripheral.getType(e)==\\\"modem\\\"and not t then\\\
local e=peripheral.call(e,\\\"getNamesRemote\\\")\\\
for t,e in ipairs(e)do\\\
table.insert(a,e)\\\
end\\\
end\\\
end\\\
end\\\
return a\\\
end\\\
Peripheral={\\\
GetPeripheral=function(t)\\\
for a,e in ipairs(Peripheral.GetPeripherals())do\\\
if e.Type==t then\\\
return e\\\
end\\\
end\\\
end,\\\
Call=function(e,...)\\\
local t={...}\\\
local e=Peripheral.GetPeripheral(e)\\\
peripheral.call(e.Side,unpack(t))\\\
end,\\\
GetPeripherals=function(s)\\\
local i={}\\\
for t,e in ipairs(a())do\\\
local t=peripheral.getType(e):gsub(\\\"^%l\\\",string.upper)\\\
local n=string.upper(e:sub(1,1))\\\
if e:find('_')then\\\
n=e:sub(e:find('_')+1)\\\
end\\\
local a=false\\\
for o,e in ipairs(i)do\\\
if e[1]==t..' '..n then\\\
a=true\\\
end\\\
end\\\
if not a then\\\
local a=peripheral.getType(e)\\\
local o=false\\\
if a=='modem'then\\\
if not pcall(function()o=peripheral.call(sSide,'isWireless')end)then\\\
o=true\\\
end\\\
if o then\\\
a='wireless_modem'\\\
t='W '..t\\\
end\\\
end\\\
if not s or a==s then\\\
table.insert(i,{Name=t:sub(1,8)..' '..n,Fullname=t..' ('..e:sub(1,1):upper()..e:sub(2,-1)..')',Side=e,Type=a,Wireless=o})\\\
end\\\
end\\\
end\\\
return i\\\
end,\\\
PresentNamed=function(e)\\\
return peripheral.isPresent(e)\\\
end,\\\
CallType=function(e,...)\\\
local t={...}\\\
local e=Peripheral.GetPeripheral(e)\\\
return peripheral.call(e.Side,unpack(t))\\\
end,\\\
CallNamed=function(t,...)\\\
local e={...}\\\
return peripheral.call(t,unpack(e))\\\
end\\\
}\\\
Wireless={\\\
Channels={\\\
UltimateDoorlockPing=4210,\\\
UltimateDoorlockRequest=4211,\\\
UltimateDoorlockRequestReply=4212,\\\
},\\\
isOpen=function(e)\\\
return Peripheral.CallType('wireless_modem','isOpen',e)\\\
end,\\\
Open=function(e)\\\
if not Wireless.isOpen(e)then\\\
Peripheral.CallType('wireless_modem','open',e)\\\
end\\\
end,\\\
close=function(e)\\\
Peripheral.CallType('wireless_modem','close',e)\\\
end,\\\
closeAll=function()\\\
Peripheral.CallType('wireless_modem','closeAll')\\\
end,\\\
transmit=function(e,t,a)\\\
Peripheral.CallType('wireless_modem','transmit',e,t,textutils.serialize(a))\\\
end,\\\
Present=function()\\\
if Peripheral.GetPeripheral('wireless_modem')==nil then\\\
return false\\\
else\\\
return true\\\
end\\\
end,\\\
FormatMessage=function(a,t,e)\\\
return{\\\
content=textutils.serialize(a),\\\
senderID=os.getComputerID(),\\\
senderName=os.getComputerLabel(),\\\
channel=channel,\\\
replyChannel=reply,\\\
messageID=t or math.random(1e4),\\\
destinationID=e\\\
}\\\
end,\\\
Timeout=function(t,e)\\\
e=e or 1\\\
parallel.waitForAny(t,function()\\\
sleep(e)\\\
end)\\\
end,\\\
RecieveMessage=function(s,h,r)\\\
open(s)\\\
local n=false\\\
local i,a,t,o,e=nil\\\
Timeout(function()\\\
while not n do\\\
i,a,t,o,e=os.pullEvent('modem_message')\\\
if t~=s then\\\
i,a,t,o,e=nil\\\
else\\\
e=textutils.unserialize(e)\\\
e.content=textutils.unserialize(e.content)\\\
if h and h~=e.messageID or(e.destinationID~=nil and e.destinationID~=os.getComputerID())then\\\
i,a,t,o,e=nil\\\
else\\\
n=true\\\
end\\\
end\\\
end\\\
end,\\\
r)\\\
return i,a,t,o,e\\\
end,\\\
Initialise=function()\\\
if Wireless.Present()then\\\
for t,e in pairs(Wireless.Channels)do\\\
Wireless.Open(e)\\\
end\\\
end\\\
end,\\\
HandleMessage=function(i,n,t,a,e,o)\\\
e=textutils.unserialize(e)\\\
e.content=textutils.unserialize(e.content)\\\
if t==Wireless.Channels.Ping then\\\
if e.content=='Ping!'then\\\
SendMessage(a,'Pong!',nil,e.messageID)\\\
end\\\
elseif e.destinationID~=nil and e.destinationID~=os.getComputerID()then\\\
elseif Wireless.Responder then\\\
Wireless.Responder(i,n,t,a,e,o)\\\
end\\\
end,\\\
SendMessage=function(t,i,e,a,o)\\\
e=e or t+1\\\
Wireless.Open(t)\\\
Wireless.Open(e)\\\
local a=Wireless.FormatMessage(i,a,o)\\\
Wireless.transmit(t,e,a)\\\
return a\\\
end,\\\
Ping=function()\\\
local e=SendMessage(Channels.Ping,'Ping!',Channels.PingReply)\\\
RecieveMessage(Channels.PingReply,e.messageID)\\\
end\\\
}\\\
function GetAbsolutePosition(e)\\\
local e=e\\\
local t=0\\\
local a=1\\\
local o=1\\\
while true do\\\
a=a+e.X-1\\\
o=o+e.Y-1\\\
if not e.Parent then\\\
return{X=a,Y=o}\\\
end\\\
e=e.Parent\\\
if t>32 then\\\
return{X=1,Y=1}\\\
end\\\
t=t+1\\\
end\\\
end\\\
function Draw()\\\
Drawing.Clear(colours.white)\\\
if Current.StatusScreen then\\\
Drawing.DrawCharactersCenter(1,-2,nil,nil,Current.HeaderText,colours.blue,colours.white)\\\
Drawing.DrawCharactersCenter(1,-1,nil,nil,'by oeed',colours.lightGrey,colours.white)\\\
Drawing.DrawCharactersCenter(1,1,nil,nil,Current.StatusText,Current.StatusColour,colours.white)\\\
end\\\
if Current.ButtonOne then\\\
Current.ButtonOne:Draw()\\\
end\\\
if Current.ButtonTwo then\\\
Current.ButtonTwo:Draw()\\\
end\\\
for t,e in ipairs(Current.PageControls)do\\\
e:Draw()\\\
end\\\
Drawing.DrawBuffer()\\\
if Current.TextInput and Current.CursorPos and not Current.Menu and not(Current.Window and Current.Document and Current.TextInput==Current.Document.TextInput)and Current.CursorPos[2]>1 then\\\
term.setCursorPos(Current.CursorPos[1],Current.CursorPos[2])\\\
term.setCursorBlink(true)\\\
term.setTextColour(Current.CursorColour)\\\
else\\\
term.setCursorBlink(false)\\\
end\\\
end\\\
MainDraw=Draw\\\
function GenerateFingerprint()\\\
local e=\\\"\\\"\\\
for t=1,256 do\\\
local t=math.random(32,126)\\\
e=e..string.char(t)\\\
end\\\
return e\\\
end\\\
function MakeFingerprint()\\\
local e=fs.open('.fingerprint','w')\\\
if e then\\\
e.write(GenerateFingerprint())\\\
end\\\
e.close()\\\
Current.Fingerprint=str\\\
end\\\
local e=nil\\\
function SetText(a,t,e,o)\\\
if a then\\\
Current.HeaderText=a\\\
end\\\
if t then\\\
Current.StatusText=t\\\
end\\\
if e then\\\
Current.StatusColour=e\\\
end\\\
Draw()\\\
if not o then\\\
statusResetTimer=os.startTimer(2)\\\
end\\\
end\\\
function ResetStatus()\\\
if pocket then\\\
if Current.Locked then\\\
SetText('Ultimate Door Lock','Add Wireless Modem to PDA',colours.red,true)\\\
else\\\
SetText('Ultimate Door Lock','Ready',colours.grey,true)\\\
end\\\
else\\\
if Current.Locked then\\\
SetText('Ultimate Door Lock',' Attach a Wireless Modem then reboot',colours.red,true)\\\
else\\\
SetText('Ultimate Door Lock','Ready',colours.grey,true)\\\
end\\\
end\\\
end\\\
function ResetPage()\\\
Wireless.Responder=function()end\\\
pingTimer=nil\\\
Current.PageControls=nil\\\
Current.StatusScreen=false\\\
Current.ButtonOne=nil\\\
Current.ButtonTwo=nil\\\
Current.PageControls={}\\\
CloseDoor()\\\
end\\\
function PocketInitialise()\\\
Current.ButtonOne=Button:Initialise(Drawing.Screen.Width-6,Drawing.Screen.Height-1,nil,nil,nil,nil,Quit,'Quit',colours.black)\\\
if not Wireless.Present()then\\\
Current.Locked=true\\\
ResetStatus()\\\
return\\\
end\\\
Wireless.Initialise()\\\
ResetStatus()\\\
if fs.exists('.fingerprint')then\\\
local e=fs.open('.fingerprint','r')\\\
if e then\\\
Current.Fingerprint=e.readAll()\\\
else\\\
MakeFingerprint()\\\
end\\\
e.close()\\\
else\\\
MakeFingerprint()\\\
end\\\
Wireless.Responder=function(a,a,t,a,e,a)\\\
if t==Wireless.Channels.UltimateDoorlockPing then\\\
Wireless.SendMessage(Wireless.Channels.UltimateDoorlockRequest,Current.Fingerprint,Wireless.Channels.UltimateDoorlockRequestReply,nil,e.senderID)\\\
elseif t==Wireless.Channels.UltimateDoorlockRequestReply then\\\
if e.content==true then\\\
SetText(nil,'Opening Door',colours.green)\\\
else\\\
SetText(nil,' Access Denied',colours.red)\\\
end\\\
end\\\
end\\\
end\\\
function FingerprintIsOnWhitelist(t)\\\
if Current.Settings.Whitelist then\\\
for a,e in ipairs(Current.Settings.Whitelist)do\\\
if e==t then\\\
return true\\\
end\\\
end\\\
end\\\
return false\\\
end\\\
function SaveSettings()\\\
Current.Settings=Current.Settings or{}\\\
local e=fs.open('.settings','w')\\\
if e then\\\
e.write(textutils.serialize(Current.Settings))\\\
end\\\
e.close()\\\
end\\\
local n=nil\\\
function OpenDoor()\\\
if Current.Settings and Current.Settings.RedstoneSide then\\\
SetText(nil,'Opening Door',colours.green)\\\
redstone.setOutput(Current.Settings.RedstoneSide,true)\\\
n=os.startTimer(.6)\\\
end\\\
end\\\
function CloseDoor()\\\
if Current.Settings and Current.Settings.RedstoneSide then\\\
if redstone.getOutput(Current.Settings.RedstoneSide)then\\\
SetText(nil,'Closing Door',colours.orange)\\\
redstone.setOutput(Current.Settings.RedstoneSide,false)\\\
end\\\
end\\\
end\\\
DefaultSettings={\\\
Whitelist={},\\\
RedstoneSide='back',\\\
Distance=10\\\
}\\\
function RegisterPDA(e,o)\\\
if disk.hasData(o)then\\\
local a=fs\\\
if OneOS then\\\
a=OneOS.FS\\\
end\\\
local e=disk.getMountPath(o)\\\
local i=true\\\
if a.exists(e..'/System/')then\\\
e=e..'/System/'\\\
i=false\\\
end\\\
local t=nil\\\
if a.exists(e..'/.fingerprint')then\\\
local e=a.open(e..'/.fingerprint','r')\\\
if e then\\\
local e=e.readAll()\\\
if#e==256 then\\\
t=e\\\
end\\\
end\\\
e.close()\\\
end\\\
if not t then\\\
t=GenerateFingerprint()\\\
local o=a.open(e..'/.fingerprint','w')\\\
o.write(t)\\\
o.close()\\\
if i then\\\
local t=fs.open(shell.getRunningProgram(),'r')\\\
local o=t.readAll()\\\
t.close()\\\
local e=a.open(e..'/startup','w')\\\
e.write(o)\\\
e.close()\\\
end\\\
end\\\
if not FingerprintIsOnWhitelist(t)then\\\
table.insert(Current.Settings.Whitelist,t)\\\
SaveSettings()\\\
end\\\
disk.eject(o)\\\
SetText(nil,'Registered Pocket Computer',colours.green)\\\
end\\\
end\\\
function HostSetup()\\\
ResetPage()\\\
Current.Page='HostSetup'\\\
Current.ButtonTwo=Button:Initialise(Drawing.Screen.Width-6,Drawing.Screen.Height-1,nil,nil,nil,nil,HostStatusPage,'Save',colours.black)\\\
if not Current.Settings then\\\
Current.Settings=DefaultSettings\\\
end\\\
local t={}\\\
local function e(a)\\\
for t,e in ipairs(t)do\\\
if e.Toggle~=nil then\\\
e.Toggle=false\\\
end\\\
end\\\
Current.Settings.RedstoneSide=a.Text:lower()\\\
SaveSettings()\\\
end\\\
table.insert(Current.PageControls,Label:Initialise(2,2,'Redstone Side'))\\\
t={\\\
Button:Initialise(2,4,nil,nil,nil,nil,e,'Back',colours.black,false,colours.green),\\\
Button:Initialise(9,4,nil,nil,nil,nil,e,'Front',colours.black,false,colours.green),\\\
Button:Initialise(2,6,nil,nil,nil,nil,e,'Left',colours.black,false,colours.green),\\\
Button:Initialise(9,6,nil,nil,nil,nil,e,'Right',colours.black,false,colours.green),\\\
Button:Initialise(2,8,nil,nil,nil,nil,e,'Top',colours.black,false,colours.green),\\\
Button:Initialise(8,8,nil,nil,nil,nil,e,'Bottom',colours.black,false,colours.green)\\\
}\\\
for t,e in ipairs(t)do\\\
if e.Text:lower()==Current.Settings.RedstoneSide then\\\
e.Toggle=true\\\
end\\\
table.insert(Current.PageControls,e)\\\
end\\\
local a={}\\\
local function t(e)\\\
for t,e in ipairs(a)do\\\
if e.Toggle~=nil then\\\
e.Toggle=false\\\
end\\\
end\\\
if e.Text=='Small'then\\\
Current.Settings.Distance=5\\\
elseif e.Text=='Normal'then\\\
Current.Settings.Distance=10\\\
elseif e.Text=='Far'then\\\
Current.Settings.Distance=15\\\
end\\\
SaveSettings()\\\
end\\\
table.insert(Current.PageControls,Label:Initialise(23,2,'Opening Distance'))\\\
a={\\\
Button:Initialise(23,4,nil,nil,nil,nil,t,'Small',colours.black,false,colours.green),\\\
Button:Initialise(31,4,nil,nil,nil,nil,t,'Normal',colours.black,false,colours.green),\\\
Button:Initialise(40,4,nil,nil,nil,nil,t,'Far',colours.black,false,colours.green)\\\
}\\\
for t,e in ipairs(a)do\\\
if e.Text=='Small'and Current.Settings.Distance==5 then\\\
e.Toggle=true\\\
elseif e.Text=='Normal'and Current.Settings.Distance==10 then\\\
e.Toggle=true\\\
elseif e.Text=='Far'and Current.Settings.Distance==15 then\\\
e.Toggle=true\\\
end\\\
table.insert(Current.PageControls,e)\\\
end\\\
table.insert(Current.PageControls,Label:Initialise(2,10,'Registered PDAs: '..#Current.Settings.Whitelist))\\\
table.insert(Current.PageControls,Button:Initialise(2,12,nil,nil,nil,nil,function()Current.Settings.Whitelist={}HostSetup()end,'Unregister All',colours.black))\\\
table.insert(Current.PageControls,Label:Initialise(23,6,'Help',colours.black))\\\
local e={\\\
Label:Initialise(23,8,'To register a new PDA simply',colours.black),\\\
Label:Initialise(23,9,'place a Disk Drive next to',colours.black),\\\
Label:Initialise(23,10,'the computer, then put the',colours.black),\\\
Label:Initialise(23,11,'PDA in the Drive, it will',colours.black),\\\
Label:Initialise(23,12,'register automatically. If',colours.black),\\\
Label:Initialise(23,13,'it worked it will eject.',colours.black),\\\
Label:Initialise(23,15,'Make sure you hide this',colours.red),\\\
Label:Initialise(23,16,'computer away from the',colours.red),\\\
Label:Initialise(23,17,'door! (other people)',colours.red)\\\
}\\\
for t,e in ipairs(e)do\\\
table.insert(Current.PageControls,e)\\\
end\\\
table.insert(Current.PageControls,Button:Initialise(2,14,nil,nil,nil,nil,function()\\\
for t=1,6 do\\\
e[t].TextColour=colours.green\\\
end\\\
end,'Register New PDA',colours.black))\\\
end\\\
function HostStatusPage()\\\
ResetPage()\\\
Current.Page='HostStatus'\\\
Current.StatusScreen=true\\\
Current.ButtonOne=Button:Initialise(Drawing.Screen.Width-6,Drawing.Screen.Height-1,nil,nil,nil,nil,Quit,'Quit',colours.black)\\\
Current.ButtonTwo=Button:Initialise(2,Drawing.Screen.Height-1,nil,nil,nil,nil,HostSetup,'Settings/Help',colours.black)\\\
Wireless.Responder=function(o,o,e,o,t,a)\\\
if e==Wireless.Channels.UltimateDoorlockRequest and a<Current.Settings.Distance then\\\
if FingerprintIsOnWhitelist(t.content)then\\\
OpenDoor()\\\
Wireless.SendMessage(Wireless.Channels.UltimateDoorlockRequestReply,true)\\\
else\\\
Wireless.SendMessage(Wireless.Channels.UltimateDoorlockRequestReply,false)\\\
end\\\
end\\\
end\\\
PingPocketComputers()\\\
end\\\
function HostInitialise()\\\
if not Wireless.Present()then\\\
Current.Locked=true\\\
Current.ButtonOne=Button:Initialise(Drawing.Screen.Width-6,Drawing.Screen.Height-1,nil,nil,nil,nil,Quit,'Quit',colours.black)\\\
Current.ButtonTwo=Button:Initialise(2,Drawing.Screen.Height-1,nil,nil,nil,nil,function()os.reboot()end,'Reboot',colours.black)\\\
ResetStatus()\\\
return\\\
end\\\
Wireless.Initialise()\\\
ResetStatus()\\\
if fs.exists('.settings')then\\\
local e=fs.open('.settings','r')\\\
if e then\\\
Current.Settings=textutils.unserialize(e.readAll())\\\
end\\\
e.close()\\\
HostStatusPage()\\\
else\\\
HostSetup()\\\
end\\\
if OneOS then\\\
OneOS.CanClose=function()\\\
CloseDoor()\\\
return true\\\
end\\\
end\\\
end\\\
local t=nil\\\
function PingPocketComputers()\\\
Wireless.SendMessage(Wireless.Channels.UltimateDoorlockPing,'Ping!',Wireless.Channels.UltimateDoorlockRequest)\\\
t=os.startTimer(.5)\\\
end\\\
function Initialise(e)\\\
EventRegister('mouse_click',TryClick)\\\
EventRegister('mouse_drag',function(e,o,t,a)TryClick(e,o,t,a,true)end)\\\
EventRegister('mouse_scroll',Scroll)\\\
EventRegister('key',HandleKey)\\\
EventRegister('char',HandleKey)\\\
EventRegister('timer',Timer)\\\
EventRegister('terminate',function(e)if Close()then error(\\\"Terminated\\\",0)end end)\\\
EventRegister('modem_message',Wireless.HandleMessage)\\\
EventRegister('disk',RegisterPDA)\\\
if OneOS then\\\
OneOS.RequestRunAtStartup()\\\
end\\\
if pocket then\\\
PocketInitialise()\\\
else\\\
HostInitialise()\\\
end\\\
Draw()\\\
EventHandler()\\\
end\\\
function Timer(a,e)\\\
if e==t then\\\
PingPocketComputers()\\\
elseif e==n then\\\
CloseDoor()\\\
elseif e==statusResetTimer then\\\
ResetStatus()\\\
end\\\
end\\\
local e=false\\\
function HandleKey(...)\\\
local e={...}\\\
local t=e[1]\\\
local e=e[2]\\\
end\\\
function CheckClick(e,a,t)\\\
if e.X<=a and e.Y<=t and e.X+e.Width>a and e.Y+e.Height>t then\\\
return true\\\
end\\\
end\\\
function DoClick(e,n,o,a,i)\\\
local t=GetAbsolutePosition(e)\\\
t.Width=e.Width\\\
t.Height=e.Height\\\
if e and CheckClick(t,o,a)then\\\
return e:Click(n,o-e.X+1,a-e.Y+1,i)\\\
end\\\
end\\\
function TryClick(i,t,e,a,o)\\\
if Current.ButtonOne then\\\
if DoClick(Current.ButtonOne,t,e,a,o)then\\\
Draw()\\\
return\\\
end\\\
end\\\
if Current.ButtonTwo then\\\
if DoClick(Current.ButtonTwo,t,e,a,o)then\\\
Draw()\\\
return\\\
end\\\
end\\\
for n,i in ipairs(Current.PageControls)do\\\
if DoClick(i,t,e,a,o)then\\\
Draw()\\\
return\\\
end\\\
end\\\
Draw()\\\
end\\\
function Scroll(t,e,t,t)\\\
if Current.Window and Current.Window.OpenButton then\\\
Current.Document.Scroll=Current.Document.Scroll+e\\\
if Current.Window.Scroll<0 then\\\
Current.Window.Scroll=0\\\
elseif Current.Window.Scroll>Current.Window.MaxScroll then\\\
Current.Window.Scroll=Current.Window.MaxScroll\\\
end\\\
Draw()\\\
elseif Current.ScrollBar then\\\
if Current.ScrollBar:DoScroll(e*2)then\\\
Draw()\\\
end\\\
end\\\
end\\\
function EventRegister(e,t)\\\
if not Events[e]then\\\
Events[e]={}\\\
end\\\
table.insert(Events[e],t)\\\
end\\\
function EventHandler()\\\
while isRunning do\\\
local e,h,n,s,i,t,a=os.pullEventRaw()\\\
if Events[e]then\\\
for r,o in ipairs(Events[e])do\\\
o(e,h,n,s,i,t,a)\\\
end\\\
end\\\
end\\\
end\\\
function Quit()\\\
isRunning=false\\\
term.setCursorPos(1,1)\\\
term.setBackgroundColour(colours.black)\\\
term.setTextColour(colours.white)\\\
term.clear()\\\
if OneOS then\\\
OneOS.Close()\\\
end\\\
end\\\
if not term.current then\\\
print('Because it requires pocket computers, Ultimate Door Lock requires ComputerCraft 1.6. Please update to 1.6 to use Ultimate Door Lock.')\\\
elseif not(OneOS and pocket)and term.isColor and term.isColor()then\\\
local t,e=pcall(Initialise)\\\
if e then\\\
CloseDoor()\\\
term.setCursorPos(1,1)\\\
term.setBackgroundColour(colours.black)\\\
term.setTextColour(colours.white)\\\
term.clear()\\\
print('Ultimate Door Lock has crashed')\\\
print('To maintain security, the computer will reboot.')\\\
print('If you are seeing this alot try turning off all Pocket Computers or reinstall.')\\\
print()\\\
print('Error:')\\\
printError(e)\\\
sleep(5)\\\
os.reboot()\\\
end\\\
elseif OneOS and pocket then\\\
term.setCursorPos(1,3)\\\
term.setBackgroundColour(colours.white)\\\
term.setTextColour(colours.blue)\\\
term.clear()\\\
print('OneOS already acts as a door key. Simply place your PDA in the door\\\\'s disk drive to register it.')\\\
print()\\\
print('To setup a door, run this program on an advanced computer (non-pocket).')\\\
print()\\\
print('Click anywhere to quit')\\\
os.pullEvent('mouse_click')\\\
Quit()\\\
else\\\
print('Ultimate Door Lock requires an advanced (gold) computer or pocket computer.')\\\
end\",\
    [ \"Programs/Games/Redirection.program/Views/toolbar.view\" ] = \"{\\\
  [\\\"Width\\\"]=\\\"100%\\\",\\\
  [\\\"Height\\\"]=3,\\\
  [\\\"Type\\\"]=\\\"View\\\",\\\
  [\\\"BackgroundColour\\\"] = 128,\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=2,\\\
      [\\\"Name\\\"]=\\\"InstallLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Install\\\",\\\
      [\\\"TextColour\\\"]=1\\\
    },\\\
    [2]={\\\
      [\\\"Y\\\"]=2,\\\
      [\\\"X\\\"]=10,\\\
      [\\\"Name\\\"]=\\\"ProgramNameLabel\\\",\\\
      [\\\"Type\\\"]=\\\"Label\\\",\\\
      [\\\"Text\\\"]=\\\"Redirection\\\",\\\
      [\\\"TextColour\\\"]=256\\\
    },\\\
  },\\\
}\",\
    [ \"Programs/Quest.program/Pages/4.ccml\" ] = \"<!DOCTYPE ccml>\\\
<html>\\\
	<head>\\\
	  <title>HTTP Not Enabled</title>\\\
	</head>\\\
	<body>\\\
		<br/>\\\
		<br/>\\\
		<h colour=\\\"red\\\">HTTP Not Enabled</h>\\\
		<br/>\\\
		<center>\\\
			<br>\\\
			<p width=\\\"38\\\" align=\\\"center\\\">You haven't enabled the HTTP API. To do so, take a look on the HTTP API page on the wiki for a link to a tutorial.</p>\\\
		</center>\\\
	</body>\\\
</html>\",\
    [ \"Programs/Quest Server.program/APIs/Wireless\" ] = \"--This is just the OneOS Wireless API\\\
\\\
--OneOS uses channels between 4200 and 4300, avoid use where possible\\\
\\\
Channels = {\\\
	Ignored = 4299,\\\
	Ping = 4200,\\\
	PingReply = 4201,\\\
	QuestServerRequest = 4250,\\\
	QuestServerRequestReply = 4251,\\\
	QuestServerNameAvailable = 4252,\\\
	QuestServerNameAvailableReply = 4253,\\\
}\\\
\\\
local function isOpen(channel)\\\
	return Peripheral.CallType('wireless_modem', 'isOpen', channel)\\\
end\\\
\\\
local function open(channel)\\\
	if not isOpen(channel) then\\\
		Peripheral.CallType('wireless_modem', 'open', channel)\\\
	end\\\
end\\\
\\\
Open = open\\\
\\\
local function close(channel)\\\
	Peripheral.CallType('wireless_modem', 'close', channel)\\\
end\\\
\\\
local function closeAll()\\\
	Peripheral.CallType('wireless_modem', 'closeAll')\\\
end\\\
\\\
local function transmit(channel, replyChannel, message)\\\
	Peripheral.CallType('wireless_modem', 'transmit', channel, replyChannel, textutils.serialize(message))\\\
end\\\
\\\
function Present()\\\
	if Peripheral.GetPeripheral('wireless_modem') == nil then\\\
		return false\\\
	else\\\
		return true\\\
	end\\\
end\\\
\\\
local function FormatMessage(message, messageID, destinationID)\\\
	return {\\\
		content = textutils.serialize(message),\\\
		senderID = os.getComputerID(),\\\
		senderName = os.getComputerLabel(),\\\
		channel = channel,\\\
		replyChannel = reply,\\\
		messageID = messageID or math.random(10000),\\\
		destinationID = destinationID\\\
	}\\\
end\\\
\\\
local Timeout = function(func, time)\\\
	time = time or 1\\\
	parallel.waitForAny(func, function()\\\
		sleep(time)\\\
		--log('Timeout!'..time)\\\
	end)\\\
end\\\
\\\
RecieveMessage = function(_channel, messageID, timeout)\\\
	open(_channel)\\\
	local done = false\\\
	local event, side, channel, replyChannel, message = nil\\\
	Timeout(function()\\\
		while not done do\\\
			event, side, channel, replyChannel, message = os.pullEvent('modem_message')\\\
			if channel ~= _channel then\\\
				event, side, channel, replyChannel, message = nil\\\
			else\\\
				message = textutils.unserialize(message)\\\
				message.content = textutils.unserialize(message.content)\\\
				if messageID and messageID ~= message.messageID or (message.destinationID ~= nil and message.destinationID ~= os.getComputerID()) then\\\
					event, side, channel, replyChannel, message = nil\\\
				else\\\
					done = true\\\
				end\\\
			end\\\
		end\\\
	end,\\\
	timeout)\\\
	return event, side, channel, replyChannel, message\\\
end\\\
\\\
Initialise = function()\\\
	if Present() then\\\
		for i, c in pairs(Channels) do\\\
			open(c)\\\
		end\\\
	end\\\
end\\\
\\\
HandleMessage = function(event, side, channel, replyChannel, message, distance)\\\
	message = textutils.unserialize(message)\\\
	message.content = textutils.unserialize(message.content)\\\
\\\
	if channel == Channels.Ping then\\\
		if message.content == 'Ping!' then\\\
			SendMessage(replyChannel, 'Pong!', nil, message.messageID)\\\
		end\\\
	elseif message.destinationID ~= nil and message.destinationID ~= os.getComputerID() then\\\
	elseif Wireless.Responder then\\\
		Wireless.Responder(event, side, channel, replyChannel, message, distance)\\\
	end\\\
end\\\
\\\
SendMessage = function(channel, message, reply, messageID, destinationID)\\\
	reply = reply or channel + 1\\\
	open(channel)\\\
	open(reply)\\\
	local _message = FormatMessage(message, messageID, destinationID)\\\
	transmit(channel, reply, _message)\\\
	return _message\\\
end\\\
\\\
Ping = function()\\\
	local message = SendMessage(Channels.Ping, 'Ping!', Channels.PingReply)\\\
	RecieveMessage(Channels.PingReply, message.messageID)\\\
end\",\
    [ \"System/Objects/CentrePoint.lua\" ] = \"Inherit = 'View'\\\
\\\
local oldProgram = nil\\\
local oldActive = nil\\\
local oldProgramPosition = nil\\\
\\\
OnLoad = function(self)\\\
	self:GetObject('AboutButton').OnClick = function(itm)\\\
		oldProgram = Current.Desktop\\\
		Helpers.OpenFile('System/Programs/About OneOS.program')\\\
	end\\\
\\\
	self:GetObject('SettingsButton').OnClick = function(itm)\\\
		oldProgram = Current.Desktop\\\
		Helpers.OpenFile('System/Programs/Settings.program')\\\
	end\\\
\\\
	self:GetObject('UpdateButton').OnClick = function(itm)\\\
		CheckAutoUpdate(true)\\\
	end\\\
\\\
	self:GetObject('RestartButton').OnClick = function(itm)\\\
		Restart()\\\
	end\\\
\\\
	self:GetObject('ShutdownButton').OnClick = function(itm)\\\
		Shutdown()\\\
	end\\\
\\\
	self.Visible = false\\\
end\\\
\\\
Show = function(self)\\\
	-- self:UpdatePreviews()\\\
	oldProgram = Current.Program\\\
	self:UpdatePrograms()\\\
	oldActive = self.Bedrock:GetActiveObject()\\\
	Current.Program = nil\\\
	self.Bedrock:GetObject('Overlay').CenterPointMode = true\\\
	self.Bedrock:GetObject('Overlay'):GetObject('OneButton').Toggle = true\\\
	self.Bedrock:SetActiveObject(nil)\\\
	UpdateOverlay()\\\
	self.Visible = true\\\
	self:AnimateEntry()\\\
end\\\
\\\
function AnimateEntry(self)\\\
	local animatePreview = self:GetObject('AnimateProgramPreview')\\\
	if Settings:GetValues()['UseAnimations'] then\\\
		animatePreview.Visible = true\\\
		animatePreview.X = 1\\\
		animatePreview.Y = 1\\\
		animatePreview.Width = self.Width\\\
		animatePreview.Height = self.Height\\\
		animatePreview.Program = oldProgram\\\
		animatePreview:UpdatePreview()\\\
\\\
		local steps = 5\\\
		local deltaW = (self.Width - ProgramPreview.PreviewWidth) / steps\\\
		local deltaH = (self.Height - ProgramPreview.PreviewHeight) / steps\\\
		local deltaX = deltaW \\\
		local deltaY = deltaH \\\
		if oldProgramPosition then\\\
			deltaX = (self.X - oldProgramPosition.X) / steps\\\
			deltaY = (self.Y - oldProgramPosition.Y - 1) / steps\\\
		end\\\
\\\
		self.Bedrock:GetObject('Overlay'):Draw()\\\
		for i = 1, steps do\\\
			animatePreview.X = animatePreview.X - deltaX\\\
			animatePreview.Y = animatePreview.Y - deltaY\\\
			animatePreview.Width = animatePreview.Width - deltaW\\\
			animatePreview.Height = animatePreview.Height - deltaH\\\
			animatePreview:UpdatePreview()\\\
			self:Draw()\\\
			Drawing.DrawBuffer()\\\
		end\\\
		self.Bedrock:Draw()\\\
	end\\\
	animatePreview.Visible = false\\\
end\\\
\\\
function AnimateExit(self)\\\
	local animatePreview = self:GetObject('AnimateProgramPreview')\\\
	Current.Program = oldProgram\\\
	Current.ProgramView.CachedProgram = nil\\\
	Current.ProgramView:ForceDraw()\\\
	if Settings:GetValues()['UseAnimations'] then\\\
		local previews = self:GetObjects('ProgramPreview')\\\
\\\
		for i, v in ipairs(previews) do\\\
			if v.Program == oldProgram then\\\
				oldProgramPosition = self.Bedrock:GetAbsolutePosition(v)\\\
			end\\\
		end\\\
\\\
		animatePreview.Visible = true\\\
		animatePreview.X = oldProgramPosition.X\\\
		animatePreview.Y = oldProgramPosition.Y\\\
		animatePreview.Width = ProgramPreview.PreviewWidth\\\
		animatePreview.Height = ProgramPreview.PreviewHeight\\\
		animatePreview.Program = oldProgram\\\
		animatePreview:UpdatePreview()\\\
\\\
		local steps = 5\\\
		local deltaW = (ProgramPreview.PreviewWidth - self.Width - 1) / steps\\\
		local deltaH = (ProgramPreview.PreviewHeight - self.Height - 1) / steps\\\
		local deltaX = deltaW \\\
		local deltaY = deltaH \\\
		if oldProgramPosition then\\\
			deltaX = (oldProgramPosition.X - 1) / steps\\\
			deltaY = (oldProgramPosition.Y - 1) / steps\\\
		end\\\
\\\
		for i = 1, steps do\\\
			animatePreview.X = animatePreview.X - deltaX\\\
			animatePreview.Y = animatePreview.Y - deltaY\\\
			animatePreview.Width = animatePreview.Width - deltaW\\\
			animatePreview.Height = animatePreview.Height - deltaH\\\
			if i == steps then\\\
				animatePreview.X = 1\\\
				animatePreview.Y = 1\\\
				animatePreview.Width = self.Width\\\
				animatePreview.Height = self.Height\\\
				self.Bedrock:GetObject('Overlay'):UpdateButtons()\\\
				self.Bedrock:GetObject('Overlay'):Draw()\\\
			end\\\
			animatePreview:UpdatePreview()\\\
			self:Draw()\\\
			Drawing.DrawBuffer()\\\
		end\\\
		self.Bedrock:Draw()\\\
	end\\\
	animatePreview.Visible = false\\\
end\\\
\\\
UpdatePrograms = function(self)\\\
	self:RemoveObjects('ProgramPreview')\\\
\\\
	local maxCols = math.floor(self.Width / (2 + ProgramPreview.Width))\\\
	local currentY = 3\\\
\\\
	local rows = {}\\\
	for i, program in ipairs(Current.Programs) do\\\
		local row = math.ceil(i / maxCols)\\\
		Log.i(row)\\\
		if not rows[row] then\\\
			rows[row] = {}\\\
		end\\\
		table.insert(rows[row], program)\\\
	end\\\
\\\
	local scrollView = self:GetObject('ScrollView')\\\
	for i, row in ipairs(rows) do\\\
		local currentX = math.ceil((self.Width - (#row * (2 + ProgramPreview.Width)) + 2)/2)\\\
		for i2, program in ipairs(row) do\\\
			local obj = scrollView:AddObject({\\\
				X = currentX,\\\
				Y = currentY,\\\
				Type = 'ProgramPreview',\\\
				Program = program,\\\
				OnClick = function(prv, event, side, x, y)\\\
					if not prv.Program.Hidden and ((x == 1 and y == 1) or side == 3) then\\\
						prv.Program:Close()\\\
						prv.Bedrock:GetObject('CentrePoint'):UpdatePrograms()\\\
					else\\\
						oldProgram = prv.Program\\\
						prv.Bedrock:GetObject('CentrePoint'):Hide()\\\
						-- prv.Program:SwitchTo()\\\
					end\\\
				end\\\
			})\\\
			if program == oldProgram then\\\
				oldProgramPosition = self.Bedrock:GetAbsolutePosition(obj)\\\
			end\\\
			currentX = currentX + 2 + ProgramPreview.Width\\\
		end\\\
		currentY = currentY + ProgramPreview.Height + 1\\\
	end\\\
	scrollView:UpdateScroll()\\\
end\\\
\\\
Hide = function(self)\\\
	self.Bedrock:GetObject('Overlay').CenterPointMode = false\\\
	self.Bedrock:GetObject('Overlay'):GetObject('OneButton').Toggle = false\\\
	self:AnimateExit()\\\
	self.Visible = false\\\
	self.Bedrock:SetActiveObject(oldActive)\\\
	if oldProgram and oldProgram.Running then\\\
		oldProgram:SwitchTo()\\\
	else\\\
		Current.Desktop:SwitchTo()\\\
	end\\\
end\",\
    [ \"System/Programs/Files.program/images/Drive\" ] = \"7f ___ \\\
7f --- \\\
8f     \\\
8f    =\",\
    [ \"Programs/Quest.program/Elements/TextInput.lua\" ] = \"BackgroundColour = colours.lightGrey\\\
SelectedBackgroundColour = colours.blue\\\
SelectedTextColour = colours.white\\\
PlaceholderTextColour = colours.grey\\\
Placeholder = ''\\\
Value = nil\\\
Attributes = nil\\\
Children = nil\\\
Tag = nil\\\
Width = 20\\\
InputName = ''\\\
\\\
OnInitialise = function(self, node)\\\
	local attr = self.Attributes\\\
	if attr.selbgcolour then\\\
		self.SelectedBackgroundColour = self:ParseColour(attr.selbgcolour)\\\
	elseif attr.selbgcolor then\\\
		self.SelectedBackgroundColour = self:ParseColour(attr.selbgcolor)\\\
	end\\\
\\\
	if attr.selcolour then\\\
		self.SelectedTextColour = self:ParseColour(attr.selcolour)\\\
	elseif attr.selcolor then\\\
		self.SelectedTextColour = self:ParseColour(attr.selcolor)\\\
	end\\\
\\\
	if attr.plcolour then\\\
		self.PlaceholderTextColour = self:ParseColour(attr.plcolour)\\\
	elseif attr.plcolour then\\\
		self.PlaceholderTextColour = self:ParseColour(attr.plcolour)\\\
	end\\\
\\\
	if attr.value then\\\
		self.Value = attr.value\\\
	end\\\
\\\
	if attr.placeholder then\\\
		self.Placeholder = attr.placeholder\\\
	end\\\
\\\
	if attr.name then\\\
		self.InputName = attr.name\\\
	end\\\
end\\\
\\\
UpdateValue = function(self)\\\
	self.Value = self.Object.Text\\\
end\\\
\\\
OnCreateObject = function(self, parentObject, y)\\\
	return {\\\
		Element = self,\\\
		Y = y,\\\
		X = 1,\\\
		Width = self.Width,\\\
		Type = \\\"TextBox\\\",\\\
		Text = self.Value,\\\
		TextColour = self.TextColour,\\\
		BackgroundColour = self.BackgroundColour,\\\
		SelectedBackgroundColour = self.SelectedBackgroundColour,\\\
		SelectedTextColour = self.SelectedTextColour,\\\
		PlaceholderTextColour = self.PlaceholderTextColour,\\\
		Placeholder = self.Placeholder,\\\
		InputName = self.InputName,\\\
		OnChange = function(_self, event, keychar)\\\
			if keychar == keys.tab or keychar == keys.enter then\\\
				local form = self\\\
				local step = 0\\\
				while form.Tag ~= 'form' and step < 50 do\\\
					form = form.Parent\\\
				end\\\
				if keychar == keys.tab then\\\
					if form and form.Object and form.Object.OnTab then\\\
						form.Object:OnTab()\\\
					end\\\
				else\\\
					if form and form.Submit then\\\
						form:Submit(true)\\\
					end\\\
				end\\\
			end\\\
		end\\\
	}\\\
end\",\
    [ \"Programs/Quest Server.program/Views/main.view\" ] = \"{\\\
  [\\\"Children\\\"]={\\\
    [1]={\\\
      [\\\"Y\\\"]=1,\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Name\\\"]=\\\"Toolbar\\\",\\\
      [\\\"Type\\\"]=\\\"View\\\",\\\
      [\\\"InheritView\\\"]=\\\"toolbar\\\"\\\
    },\\\
    [2]={\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Y\\\"]=4,\\\
      [\\\"Name\\\"]=\\\"SettingsView\\\",\\\
      [\\\"Type\\\"]=\\\"SettingsView\\\",\\\
      [\\\"Width\\\"]=\\\"100%\\\",\\\
      [\\\"Height\\\"]=\\\"100%,-3\\\",\\\
      [\\\"Visible\\\"]=false,\\\
      [\\\"InheritView\\\"]=\\\"settings\\\"\\\
    },\\\
    [3]={\\\
      [\\\"X\\\"]=1,\\\
      [\\\"Y\\\"]=4,\\\
      [\\\"Name\\\"]=\\\"LogView\\\",\\\
      [\\\"Type\\\"]=\\\"LogView\\\",\\\
      [\\\"Width\\\"]=\\\"100%\\\",\\\
      [\\\"Height\\\"]=\\\"100%,-3\\\",\\\
      [\\\"Visible\\\"]=false\\\
    },\\\
  },\\\
  [\\\"BackgroundColour\\\"]=1,\\\
  [\\\"ToolBarColour\\\"]=128,\\\
  [\\\"ToolBarTextColour\\\"]=1\\\
}\",\
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
