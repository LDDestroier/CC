local tArg = {...}
local selfDelete = false -- if true, deletes extractor after running
local file
local outputPath = tArg[1] and shell.resolve(tArg[1]) or "."
local safeColorList = {[colors.white] = true,[colors.lightGray] = true,[colors.gray] = true,[colors.black] = true}
local stc = function(color) if (term.isColor() or safeColorList[color]) then term.setTextColor(color) end end
local choice = function()
	local input = "yn"
	write("[")
	for a = 1, #input do
		write(input:sub(a,a):upper())
		if a < #input then
			write(",")
		end
	end
	print("]?")
	local evt,char
	repeat
		evt,char = os.pullEvent("char")
	until string.find(input:lower(),char:lower())
	if verbose then
		print(char:upper())
	end
	local pos = string.find(input:lower(), char:lower())
	return pos, char:lower()
end
local archive = textutils.unserialize("{\
  mainFile = \"arc.lua\",\
  compressed = false,\
  data = {\
    [ \"TAFiles/Functions/Sync.lua\" ] = \"function sync(object,type)\\\
  if tMode.sync.amount > 0 then \\\
    object.type = type\\\
    rednet.send(\\\
      tMode.sync.ids,\\\
      \\\"Sync edit\\\",\\\
      object\\\
    )\\\
  end\\\
end\",\
    [ \"TAFiles/installer.Lua\" ] = \"local minification = true\\\
local folder = tFile.folder:match\\\"(.)/TAFiles\\\" or \\\"\\\"\\\
local tGitSha\\\
local file = fs.open(tFile.folder..\\\"/\\\"..\\\"gitSha\\\",\\\"r\\\")\\\
if file then\\\
  tGitSha = file and textutils.unserialize(file.readAll()) or {}\\\
  file.close()\\\
else\\\
  tGitSha = {}\\\
end\\\
local updateFiles = {}\\\
local getContents\\\
local tActive = {}\\\
getContents = function(path,main)\\\
  tActive[#tActive+1] = true\\\
  local success = function(tEvent)\\\
    local web = tEvent[3]\\\
    local path = tEvent[2]:match\\\"https://api.github.com/repos/CometWolf/TurtleArchitectV2/contents(.+)\\\" or \\\"\\\"\\\
    local sContents = web.readAll()\\\
    web.close()\\\
    local _s,remainder = sContents:find'\\\"name\\\":\\\"'\\\
    local name = sContents:match'\\\"name\\\":\\\"(.-)\\\"'\\\
    while name do\\\
      sContents = sContents:sub(remainder)..\\\"\\\"\\\
      local sha = sContents:match'\\\"sha\\\":\\\"(.-)\\\"'\\\
      if name ~= \\\"README.md\\\" and tGitSha[path..\\\"/\\\"..name] ~= sha then\\\
        tGitSha[path..\\\"/\\\"..name] = sha\\\
        local url = sContents:match'html_url\\\":\\\"(.-)\\\"'\\\
        url = url:gsub(\\\"https://\\\",\\\"https://raw.\\\")\\\
        url = url:gsub(\\\"blob/\\\",\\\"\\\")\\\
        local type = sContents:match'\\\"type\\\":\\\"(.-)\\\"'\\\
        if type == \\\"file\\\" then\\\
          updateFiles[#updateFiles+1] = {\\\
            file = folder..path..\\\"/\\\"..name,\\\
            url = url\\\
          }\\\
        elseif type == \\\"dir\\\" then\\\
          local newFolder = folder..path..\\\"/\\\"..name\\\
          if not fs.exists(newFolder) then\\\
            fs.makeDir(newFolder)\\\
          end\\\
          getContents(path..\\\"/\\\"..name)\\\
        end\\\
      end\\\
      _s,remainder = sContents:find'\\\"name\\\":\\\"'\\\
      name = sContents:match'\\\"name\\\":\\\"(.-)\\\"'\\\
    end\\\
    table.remove(tActive,1)\\\
  end\\\
  local failure = function(tEvent)\\\
    if path ~= \\\"\\\" then\\\
      local button = window.text(\\\
        \\\"Error: Failed to get contents of \\\"..path..\\\". Retry?\\\",\\\
        {\\\
          \\\"No\\\",\\\
          \\\"Yes\\\"\\\
        }\\\
      )\\\
      if button == \\\"No\\\" then\\\
        return \\\"Cancel\\\"\\\
      else\\\
        http.request(\\\"https://api.github.com/repos/CometWolf/TurtleArchitectV2/contents\\\"..path)\\\
      end\\\
    else\\\
      window.text\\\"Error: Github download limit exceeded\\\"\\\
      return \\\"Cancel\\\"\\\
    end\\\
  end\\\
  http.request(\\\"https://api.github.com/repos/CometWolf/TurtleArchitectV2/contents\\\"..path)\\\
  if main then\\\
    return success,failure\\\
  else\\\
    eventHandler.active.http_success = success\\\
    eventHandler.active.http_failure = failure\\\
  end\\\
end\\\
\\\
local fSuccess,fFailure = getContents(\\\"\\\",true)\\\
local button = window.text(\\\
  {\\\
    {\\\
      text = \\\"Looking for updates\\\",\\\
      renderTime = 0.2\\\
    },\\\
    {\\\
      text = \\\"Looking for updates.\\\",\\\
      renderTime = 0.2\\\
    },\\\
    {\\\
      text = \\\"Looking for updates..\\\",\\\
      renderTime = 0.2\\\
    },\\\
    {\\\
      text = \\\"Looking for updates...\\\",\\\
      renderTime = 0.2\\\
    }\\\
  },\\\
  {\\\
    \\\"Cancel\\\"\\\
  },\\\
  nil,\\\
  {\\\
    http_success = fSuccess,\\\
    http_failure = fFailure,\\\
    timer = function()\\\
      if #tActive == 0 then\\\
        return \\\"Done\\\"\\\
      end\\\
    end\\\
  }\\\
)\\\
if button == \\\"Done\\\" then\\\
  if #updateFiles > 0 then\\\
    local button = window.text(\\\
      \\\"Update found!\\\\nInstall?\\\\nAll unsaved progress will be lost.\\\",\\\
      {\\\
        \\\"Cancel\\\",\\\
        \\\"Ok\\\"\\\
      }\\\
    )    \\\
    if button == \\\"Ok\\\" then\\\
      local updatingFile = 1\\\
      local tUpdated = {}\\\
      http.request(updateFiles[updatingFile].url)\\\
      local button = window.text(\\\
        {\\\
          {\\\
            text = \\\"Updating\\\",\\\
            renderTime = 0.2\\\
          },\\\
          {\\\
            text = \\\"Updating.\\\",\\\
            renderTime = 0.2\\\
          },\\\
          {\\\
            text = \\\"Updating..\\\",\\\
            renderTime = 0.2\\\
          },\\\
          {\\\
            text = \\\"Updating...\\\",\\\
            renderTime = 0.2\\\
          }\\\
        },\\\
        {\\\
          \\\"Cancel\\\"\\\
        },\\\
        false,\\\
        {\\\
          http_success = function(tEvent)\\\
            local fileName = updateFiles[updatingFile].file\\\
            local saveFile = fs.open(fileName,\\\"w\\\")\\\
            local webFile = tEvent[3]\\\
            if fileName:match\\\"TAFiles/Settings.Lua\\\" then --settings file can't be minified\\\
              saveFile.write(webFile.readAll())\\\
            else\\\
              local line = webFile.readLine()\\\
              while line do\\\
                saveFile.write((minification and (line:match\\\"(%S.*)$\\\" or \\\"\\\") or line)..\\\"\\\\n\\\")\\\
                line = webFile.readLine()\\\
              end\\\
            end\\\
            saveFile.close()\\\
            webFile.close()\\\
            tUpdated[#tUpdated+1] = updateFiles[updatingFile].file\\\
            updatingFile = updatingFile+1\\\
            if updatingFile > #updateFiles then\\\
              return \\\"Done\\\"\\\
            end\\\
            http.request(updateFiles[updatingFile].url)\\\
          end,\\\
          http_failure = function()\\\
            local button = window.text(\\\
              \\\"Update of \\\"..updateFiles[updatingFile].file..\\\" failed. Retry?\\\",\\\
              {\\\
                \\\"No\\\",\\\
                \\\"Yes\\\"\\\
              }\\\
            )\\\
            if button == \\\"No\\\" then\\\
              saveFile.close()\\\
              return \\\"Cancel\\\"\\\
            end\\\
          end\\\
        }\\\
      )\\\
      if button == \\\"Cancel\\\" then\\\
        return false\\\
      end\\\
      local file = fs.open(tFile.folder..\\\"/\\\"..\\\"gitSha\\\",\\\"w\\\")\\\
      file.write(textutils.serialize(tGitSha))\\\
      file.close()\\\
      window.text(\\\"Updated:\\\\n\\\"..table.concat(tUpdated,\\\"\\\\n\\\"))\\\
      return true\\\
    end\\\
    return false\\\
  else\\\
    window.text(\\\"No update available\\\")\\\
    return false\\\
  end\\\
end\\\
\",\
    [ \"TAFiles/APIs/window.lua\" ] = \"--[[----------------------------------------------------------------------------------------------------------\\\
Input functions\\\
----------------------------------------------------------------------------------------------------------]]--\\\
local activeInputs = 0 --amount of windows open\\\
inputOpen = false --whether an input window is currently open or not\\\
local inputDefaults = { --default values for tInputFields tables passed to the input function\\\
  name = \\\"\\\", --text on the side of the field\\\
  accepted = \\\".\\\", --accepted input pattern\\\
  value = \\\"\\\", --value already inputted\\\
  charLimit = math.huge, --amount of characters allowed\\\
  backgroundColor = tColors.inputBar,\\\
  textColor = tColors.inputText,\\\
  nameColor = tColors.inputBoxText\\\
}\\\
local animationDefaults = { --default animation values for animated text\\\
  text = \\\"\\\",\\\
  bColor = tColors.inputBox, --backgroundColor\\\
  tColor = tColors.inputBoxText, --textColor\\\
  renderTime = 1 --time before next frame\\\
}\\\
local scrollDefaults = { --default values for scroll selections\\\
  text = \\\"\\\",\\\
  sText = tColors.scrollBoxSelectText, --selected text color\\\
  sBackground = tColors.scrollBoxSelected, --selected text background color\\\
  uText = tColors.scrollBoxSelectText, --unselected text color\\\
  uBackground = tColors.scrollBoxUnselected, --unselected text background color\\\
  selected = false --selected by default\\\
}\\\
window = {\\\
  text = function(text,tButtonFields,tInputFields,customEvent,reInput)\\\
    local screenLayer = screen.layers.dialogue+activeInputs\\\
    inputOpen = true\\\
    screen:setLayer(screenLayer)\\\
    activeInputs = activeInputs+1\\\
    tInputFields = tInputFields or {}\\\
    --set up text\\\
    local lineLength = tTerm.screen.x-2 --max line length\\\
    local animated = false\\\
    local textColor\\\
    local maxLines = tTerm.screen.y-3-#tInputFields\\\
    if type(text) == \\\"table\\\" then\\\
      if type(text[1]) == \\\"table\\\" then --animation\\\
        animated = true\\\
        text.activeFrame = 1\\\
        for i,frame in ipairs(text) do\\\
          setmetatable(frame,{__index = animationDefaults})\\\
          frame.lines = string.lineFormat(frame.text,lineLength,true)\\\
        end\\\
      else --plain text\\\
        text = {\\\
          lines = string.lineFormat(table.concat(text,\\\"\\\\n\\\"),lineLength,true),\\\
          tColor = text.tColor or tColors.inputBoxText,\\\
          bColor = text.bColor or tColors.inputBox\\\
        }\\\
      end\\\
    else--converts to table if it's not a table\\\
      text = {\\\
        lines = string.lineFormat(text,lineLength,true),\\\
        tColor = tColors.inputBoxText,\\\
        bColor = tColors.inputBox\\\
      }\\\
    end\\\
    local tLine = \\\"\\\"\\\
    if animated then \\\
      for i,frame in ipairs(text) do\\\
        if #frame.lines > #tLine then\\\
          tLine = frame.lines\\\
          tLine.text = frame.text\\\
        end\\\
      end\\\
      if #tLine > maxLines then\\\
        error(\\\"Screen too small for animation\\\",2)\\\
      end\\\
      glasses.log.write(tLine.text)\\\
    else\\\
      tLine = text.lines\\\
      if #tLine > maxLines then\\\
        local windowLines = {}\\\
        for i=#tLine-maxLines+1,#tLine do\\\
          windowLines[#windowLines+1] = tLine[i]\\\
          tLine[i] = nil\\\
        end\\\
        window.text(table.concat(tLine),{\\\"Ok\\\"}) --omg recursion\\\
        screen:setLayer(screenLayer)\\\
        tLine = windowLines\\\
      end\\\
    end\\\
    --default input fields\\\
    local tInputs = {}\\\
    for i=1,#tInputFields do\\\
      if type(tInputFields[i]) ~= \\\"table\\\" then\\\
        tInputs[i] = {\\\
          name = tInputFields[i]\\\
        }\\\
        tInputFields[i] = {\\\
          name = tInputFields[i]\\\
        }\\\
      else\\\
        tInputs[i] = {}\\\
        for k,v in pairs(tInputFields[i]) do\\\
          tInputs[i][k] = v\\\
        end\\\
      end\\\
      local field = tInputs[i]\\\
      if field.value and type(field.value) == \\\"number\\\" then\\\
        field.value = string.format(field.value)\\\
      end\\\
      setmetatable(field,\\\
        {\\\
          __index = inputDefaults\\\
        }\\\
      )\\\
    end\\\
    --default buttons\\\
    local tButtons = {}\\\
    if type(tButtonFields) == \\\"string\\\" then\\\
      tButtons = {\\\
        [1] = tButtonFields\\\
      }\\\
    elseif not tButtonFields or #tButtonFields < 1 then\\\
      tButtons = {\\\
        [1] = \\\"Ok\\\"\\\
      }\\\
    else\\\
      for k,v in pairs(tButtonFields) do\\\
        tButtons[k] = v\\\
      end\\\
    end\\\
    local oldHandlers = eventHandler.active--stores currently in use event handlers, prior to switch\\\
    local eventQueue = {} --unrelated events which occurred during the dialogue\\\
    local prevBlink = screen:getBlink()\\\
    screen:setCursorBlink(false)\\\
    local function endExecution(event)\\\
      --closes input box and returns event and the values in the input fields\\\
      eventHandler.switch(oldHandlers,true)\\\
      local tRes = {}\\\
      for iR=1,#tInputs do\\\
        tRes[tInputs[iR].name] = tInputs[iR].value ~= \\\"-\\\" and tonumber(tInputs[iR].value) or #tInputs[iR].value > 0 and tInputs[iR].value\\\
      end\\\
      screen:setCursorBlink(false)\\\
      if reInput then\\\
        for i=1,#tInputFields do\\\
          for k,v in pairs(tRes) do\\\
            if k == tInputFields[i].name then\\\
              tInputFields[i].value = v\\\
              break\\\
            end\\\
          end\\\
        end\\\
        reInput = function(reText) --set up reInput function\\\
          return window.text(reText,tButtonFields,tInputFields,customEvent,true)\\\
        end\\\
      end\\\
      screen:setCursorBlink(prevBlink)\\\
      screen:delLayer(screenLayer)\\\
      inputOpen = (screenLayer ~= screen.layers.dialogue)\\\
      activeInputs = activeInputs-1\\\
      for i=1,#eventQueue do\\\
        os.queueEvent(unpack(eventQueue[i]))\\\
      end\\\
      return event,tRes,reInput\\\
    end\\\
    --render box\\\
    local box = {\\\
      height = #tLine+2+#tInputs,\\\
      width = tTerm.screen.x-2\\\
    }\\\
    box.top = math.ceil(tTerm.screen.yMid-(box.height/2))\\\
    box.bottom = box.height+box.top\\\
    if box.top < 1 then\\\
      box.bottom = box.bottom+(1-box.top)\\\
      box.top = 1\\\
    end\\\
    screen:drawBox(2,box.top,tTerm.screen.x-1,box.bottom,tColors.inputBox)\\\
    screen:drawFrame(1,box.top,tTerm.screen.x,box.bottom,tColors.inputBoxBorder)\\\
    --write text\\\
    screen:setBackgroundColor(tColors.inputBox)\\\
    screen:setTextColor(tColors.inputBoxText)\\\
    for i,line in ipairs(tLine) do\\\
      screen:setCursorPos(2,box.top+i)\\\
      screen:write(line)\\\
    end\\\
    --set up & render buttons\\\
    local totalButtonSpace = 0\\\
    local buttonTouchMap = class.matrix.new(2)\\\
    for i=1,#tButtons do\\\
      tButtons[i] = {\\\
        name = tButtons[i]\\\
      }\\\
      tButtons[i].size = #tButtons[i].name+2\\\
      totalButtonSpace = totalButtonSpace+tButtons[i].size+2\\\
    end\\\
    local nextButton = math.ceil(tTerm.screen.xMid-(totalButtonSpace/2)+2)\\\
    screen:setTextColor(tColors.inputButtonText)\\\
    screen:setBackgroundColor(tColors.inputButton)\\\
    for i=1,#tButtons do\\\
      tButtons[i].sX = nextButton\\\
      tButtons[i].eX = nextButton+tButtons[i].size-1\\\
      tButtons[i].y = box.bottom-1\\\
      screen:setCursorPos(tButtons[i].sX,tButtons[i].y)\\\
      screen:write(\\\" \\\"..tButtons[i].name..\\\" \\\")  --add spaces for appearances\\\
      for iX=tButtons[i].sX,tButtons[i].eX do\\\
        buttonTouchMap[iX][tButtons[i].y] = tButtons[i].name\\\
      end\\\
      nextButton = nextButton+#tButtons[i].name+3\\\
    end\\\
    --set up & render input boxes\\\
    local inputTouchMap = class.matrix.new(2)\\\
    if #tInputs > 0 then\\\
      for i=#tInputs,1,-1 do\\\
        local field = tInputs[i]\\\
        field.value = field.value and field.value or \\\"\\\"\\\
        screen:setBackgroundColor(tColors.inputBox)\\\
        screen:setTextColor(field.nameColor)\\\
        screen:setCursorPos(3,box.bottom-2-#tInputs+i)\\\
        screen:write(field.name..\\\":\\\")\\\
        field.sX,field.y = screen:getCursorPos() -- input area start x point\\\
        field.eX = tTerm.screen.x-2 --end x point\\\
        field.lX = field.eX-field.sX --total field length\\\
        screen:setTextColor(field.textColor)\\\
        screen:setBackgroundColor(field.backgroundColor)\\\
        screen:write(string.sub(field.value,1,field.lX) or \\\"\\\")\\\
        field.cX = (screen:getCursorPos())-field.sX --cursor pos\\\
        field.scroll = math.max(0,#field.value-field.lX) --scroll value\\\
        screen:drawLine(field.cX+field.sX,field.y,field.eX,field.y,field.backgroundColor)\\\
        for iX = field.sX,field.eX do\\\
          inputTouchMap[iX][field.y] = i\\\
        end\\\
      end\\\
      screen:setCursorBlink(true)\\\
      tInputs.enabled = 1\\\
      screen:setCursorPos(tInputs[1].cX+tInputs[1].sX,tInputs[1].y)\\\
    end\\\
    local function refreshField(field)\\\
     --updates input fields\\\
      screen:setLayer(screenLayer)\\\
      field = tInputs[field]\\\
      field.scroll = (\\\
        field.cX > field.lX \\\
        and math.min(field.scroll+(field.cX-field.lX),#field.value-field.lX)\\\
        or field.cX < 0\\\
        and math.max(field.scroll-math.abs(field.cX),0)\\\
        or field.scroll\\\
      )\\\
      field.cX = math.max(0,math.min(field.cX,field.lX))\\\
      local fieldString = field.value:sub(field.scroll+1,field.lX+field.scroll+1)\\\
      screen:setCursorPos(field.sX,field.y)\\\
      screen:setBackgroundColor(field.backgroundColor)\\\
      screen:write(fieldString..string.rep(\\\" \\\",math.max(0,field.lX-#fieldString+1)))\\\
      screen:setCursorPos(field.sX+field.cX,field.y)\\\
    end\\\
    local eventHandlers = {\\\
      mouse_click = function(tEvent)\\\
        local x,y = tEvent[3],tEvent[4]\\\
        if inputTouchMap[x][y] then --input bar clicked\\\
          tInputs.enabled = inputTouchMap[x][y]\\\
          local enabled = tInputs.enabled\\\
          screen:setCursorPos(math.min(#tInputs[enabled].value+tInputs[enabled].sX,x),y)\\\
          tInputs[enabled].cX = (screen:getCursorPos())-tInputs[enabled].sX\\\
        elseif buttonTouchMap[x][y] then\\\
          return endExecution(buttonTouchMap[x][y])\\\
        end\\\
      end,\\\
      char = function(tEvent)\\\
        if tInputs.enabled then\\\
          local field = tInputs[tInputs.enabled]\\\
          if tEvent[2]:match(field.accepted) and #field.value < field.charLimit then -- check for accepted character and character limit\\\
            local curs = field.cX+field.scroll\\\
            field.value = field.value:sub(1,curs)..tEvent[2]..field.value:sub(curs+1)\\\
            field.cX = field.cX+1\\\
            refreshField(tInputs.enabled)\\\
          end\\\
        end\\\
      end,\\\
      key = function(tEvent)\\\
        local key = tEvent[2]\\\
        if tInputs.enabled then\\\
          local field = tInputs[tInputs.enabled]\\\
          --input box\\\
          if key == 14\\\
          and field.cX > 0 then\\\
            --backspace\\\
            local curs = field.cX+field.scroll\\\
            field.value = field.value:sub(1,curs-1)..field.value:sub(curs+1)\\\
            if field.scroll > 0 then\\\
              field.scroll = field.scroll-1\\\
            else\\\
              field.cX = field.cX-1\\\
            end\\\
          elseif key == 205 then --right arrow\\\
            field.cX = field.cX+1\\\
          elseif key == 203 then --left arrow\\\
            field.cX = field.cX-1\\\
          elseif key == 200 then --up arrow\\\
            tInputs.enabled = math.max(1,tInputs.enabled-1)\\\
          elseif key == 208 then --down arrow\\\
            tInputs.enabled = math.min(#tInputs,tInputs.enabled+1)\\\
          elseif key == 211 then --delete\\\
            local curs = field.cX+field.scroll\\\
            if #field.value <= 1 and curs == 0 then\\\
              field.value = \\\"\\\"\\\
            else\\\
              field.value = field.value:sub(1,curs)..field.value:sub(curs+2)\\\
            end\\\
          elseif key == 207 then --end\\\
            field.cX = field.lX\\\
            field.scroll = #field.value-field.lX\\\
          elseif key == 199 then --home\\\
            field.cX = 1\\\
            field.scroll = 0\\\
          elseif key == 28 then --enter\\\
            if tInputs.enabled == #tInputs then\\\
              return endExecution(\\\"Ok\\\")\\\
            else\\\
              tInputs.enabled = tInputs.enabled+1\\\
            end\\\
          end\\\
          refreshField(tInputs.enabled)\\\
        else --no input boxes\\\
          if key == 28 then --enter\\\
            return endExecution(\\\"Ok\\\")\\\
          end\\\
        end\\\
      end,\\\
      chat_command = function(tEvent)\\\
        local command = tEvent[2]:lower()\\\
        for i=1,#tButtons do\\\
          if tButtons[i].name:lower() == command then\\\
            return endExecution(tButtons[i].name)\\\
          end\\\
        end\\\
        local tCommand = {}\\\
        for word in command:gmatch\\\"%S+\\\" do\\\
          local num = tonumber(word)\\\
          if num then\\\
            tCommand[#tCommand+1] = num\\\
          else\\\
            tCommand[#tCommand+1] = word:lower()\\\
          end\\\
        end\\\
        if tInputs.enabled then\\\
          local field\\\
          if type(tCommand[1]) == \\\"number\\\" then\\\
            field = math.max(1,math.min(#tInputs,tCommand[1]))\\\
            tInputs[field].value = table.concat(tCommand,\\\" \\\",2)\\\
            refreshField(field)\\\
          else\\\
            for i=1,#tInputs do\\\
              if command:match(tInputs[i].name:lower()) then\\\
                tInputs[i].value = command:match(tInputs[i].name:lower()..\\\" (.+)\\\")\\\
                refreshField(i)\\\
                break\\\
              end\\\
            end\\\
          end\\\
        end\\\
      end\\\
    }\\\
    if animated then\\\
      text.timerId = os.startTimer(text[1].renderTime)\\\
      eventHandlers.timer = function(tEvent)\\\
        if tEvent[2] == text.timerId then\\\
          text.activeFrame = text.activeFrame+1\\\
          if text.activeFrame > #text then\\\
            text.activeFrame = 1\\\
          end\\\
          screen:setLayer(screenLayer)\\\
          screen:setBackgroundColor(tColors.inputBox)\\\
          screen:setTextColor(tColors.inputBoxText)\\\
          for i,line in ipairs(text[text.activeFrame].lines) do\\\
            screen:setCursorPos(2,box.top+i)\\\
            screen:write(line)\\\
          end\\\
          text.timerId = os.startTimer(text[text.activeFrame].renderTime)\\\
          return true\\\
        else\\\
          eventQueue[#eventQueue+1] = tEvent\\\
        end\\\
      end\\\
    else\\\
      eventHandler.timer = function(tEvent)\\\
        eventQueue[#eventQueue+1] = tEvent\\\
        return true\\\
      end\\\
    end\\\
    if customEvent then\\\
      for k,v in pairs(customEvent) do\\\
        local mainFunc = eventHandlers[k]\\\
        eventHandlers[k] = function(tEvent)\\\
          local button = v(tEvent)\\\
          if button then\\\
            return endExecution(button)\\\
          end\\\
          if mainFunc then\\\
            return mainFunc(tEvent)\\\
          end\\\
        end\\\
      end\\\
    end\\\
    eventHandler.switch(eventHandlers)\\\
    while true do\\\
    --user interaction begins\\\
      local event,tRes,reInput = eventHandler.pull()\\\
      if type(event) == \\\"string\\\" then\\\
        return event,tRes,reInput\\\
      end\\\
    end\\\
  end,\\\
  scroll = function(text,tItems,multiSelection,reinput,customEvent)\\\
    local screenLayer = screen.layers.dialogue+activeInputs\\\
    inputOpen = true\\\
    screen:setLayer(screenLayer)\\\
    activeInputs = activeInputs+1\\\
    local scroll = 0\\\
    local selected\\\
    if multiSelection then\\\
      selected = {}\\\
      for i,v in ipairs(tItems) do\\\
        selected[i] = type(v) == \\\"table\\\" and v.selected and true or nil\\\
      end\\\
    else\\\
      for i,v in ipairs(tItems) do\\\
        if type(v) == \\\"table\\\" and v.selected then\\\
          selected = i\\\
          break\\\
        end\\\
      end\\\
      selected = selected or 1\\\
    end\\\
    local oldHandlers = eventHandler.active--stores currently in use event handlers, prior to switch\\\
    local function endExecution(event,selection)\\\
      --closes input box and returns event and the values in the input fields\\\
      eventHandler.switch(oldHandlers,true)\\\
      screen:delLayer(screenLayer)\\\
      inputOpen = (screenLayer ~= screen.layers.dialogue)\\\
      activeInputs = activeInputs-1\\\
      return event, selection\\\
    end\\\
    --set up text\\\
    local lineLength = tTerm.screen.x-2 --max line length\\\
    if type(text) == \\\"table\\\" then --converts text to string if it's a table\\\
      text = table.concat(text,\\\"\\\\n\\\")\\\
    end\\\
    glasses.log.write(text)\\\
    local tLine = string.lineFormat(text,lineLength)\\\
    local maxLines = 3\\\
    if #tLine > maxLines then\\\
      window.text(table.concat(tLine,\\\"\\\\n\\\",maxLines+1))\\\
      tLine[maxLines+1] = nil\\\
    end\\\
    local selectionLength = tTerm.screen.x-5\\\
    for i,selection in ipairs(tItems) do\\\
      tItems[i] = (\\\
        type(selection) == \\\"table\\\"\\\
        and selection\\\
        or {text = selection}\\\
      )\\\
      selection = tItems[i]\\\
      setmetatable(selection,{__index = scrollDefaults})\\\
      local text = string.rep(\\\" \\\",math.max(0,math.floor((selectionLength-#selection.text)/2)))..selection.text\\\
      selection.string = text..string.rep(\\\" \\\",math.max(selectionLength-#text,0))\\\
    end\\\
    local touchMap = class.matrix.new(2)\\\
    local box = {\\\
      height = 2+math.min(#tItems+#tLine,tTerm.screen.y-5),\\\
      width = tTerm.screen.x\\\
    }\\\
    box.top = tTerm.screen.yMid-math.ceil(box.height/2)\\\
    box.bottom = box.top+box.height\\\
    screen:drawBox(2,box.top+1,box.width-1,box.bottom-1,tColors.inputBox)\\\
    screen:drawFrame(1,box.top,box.width,box.bottom,tColors.inputBoxBorder)\\\
    screen:setBackgroundColor(tColors.inputBox)\\\
    screen:setTextColor(tColors.inputBoxText)\\\
    for i,line in ipairs(tLine) do\\\
      screen:setCursorPos(tTerm.screen.xMid-math.ceil(#line/2),box.top+i)\\\
      screen:write(line)\\\
    end\\\
    local visibleSelections = tTerm.screen.y-6-#tLine\\\
    local selFunc = (\\\
      multiSelection\\\
      and function(clickX,clickY)\\\
        local newSelection = clickY-box.top-#tLine+scroll\\\
        screen:setLayer(screenLayer)\\\
        if selected[newSelection] then --de selection\\\
          selected[newSelection] = nil\\\
          local selection = tItems[newSelection]\\\
          screen:setTextColor(selection.uText)\\\
          screen:setBackgroundColor(selection.uBackground)\\\
          screen:setCursorPos(4,clickY)\\\
          screen:write(selection.string)\\\
        else --new selection\\\
          selected[newSelection] = true\\\
          local selection = tItems[newSelection]\\\
          screen:setTextColor(selection.sText)\\\
          screen:setBackgroundColor(selection.sBackground)\\\
          screen:setCursorPos(4,clickY)\\\
          screen:write(selection.string)\\\
        end\\\
      end\\\
      or function(clickX,clickY)\\\
        local newSelection = clickY-box.top-#tLine+scroll\\\
        if newSelection == selected then\\\
          return\\\
        end\\\
        screen:setLayer(screenLayer)\\\
        if visibleSelections+scroll >= selected\\\
        and scroll < selected then\\\
          local selection = tItems[selected]\\\
          screen:setTextColor(selection.uText)\\\
          screen:setBackgroundColor(selection.uBackground)\\\
          screen:setCursorPos(4,selected+box.top+#tLine-scroll)\\\
          screen:write(selection.string)\\\
        end\\\
        local selection = tItems[newSelection]\\\
        screen:setTextColor(selection.sText)\\\
        screen:setBackgroundColor(selection.sBackground)\\\
        screen:setCursorPos(4,clickY)\\\
        screen:write(selection.string)\\\
        selected = newSelection\\\
      end\\\
    )\\\
    for i = 1,visibleSelections do\\\
      if not tItems[i] then\\\
        break\\\
      end\\\
      local iY = i+box.top+#tLine\\\
      for iX = 4,#tItems[i].string+4 do\\\
        touchMap[iX][iY] = selFunc\\\
      end\\\
    end\\\
    local function refresh()\\\
      screen:setLayer(screenLayer)\\\
      for iY=1+scroll,scroll+visibleSelections do\\\
        if not tItems[iY] then\\\
          return\\\
        end\\\
        local y = box.top+#tLine+iY-scroll\\\
        screen:setCursorPos(4,y)\\\
        if multiSelection then\\\
          screen:setBackgroundColor(selected[iY] and tItems[iY].sBackground or tItems[iY].uBackground)\\\
          screen:setTextColor(selected[iY] and tItems[iY].sText or tItems[iY].uText)\\\
        else\\\
          screen:setBackgroundColor(selected == iY and tItems[iY].sBackground or tItems[iY].uBackground)\\\
          screen:setTextColor(selected == iY and tItems[iY].sText or tItems[iY].uText)\\\
        end\\\
        screen:write(tItems[iY].string)\\\
      end\\\
    end\\\
    refresh()\\\
    local y = box.bottom-1\\\
    local x = tTerm.screen.xMid-6\\\
    screen:setCursorPos(x,y)\\\
    screen:setBackgroundColor(tColors.inputButton)\\\
    screen:setTextColor(tColors.inputButtonText)\\\
    screen:write(\\\" Cancel \\\")\\\
    screen:setCursorPos(x+9)\\\
    screen:write(\\\" Ok \\\")\\\
    local cancelFunc = function()\\\
      return endExecution(\\\"Cancel\\\")\\\
    end\\\
    local okFunc = (\\\
      multiSelection\\\
      and function()\\\
        local tSelected = {}\\\
        for k in pairs(selected) do\\\
          tSelected[#tSelected+1] = tItems[k].text\\\
        end\\\
        return endExecution(\\\"Ok\\\",tSelected)\\\
      end\\\
      or function()\\\
        return endExecution(\\\"Ok\\\",tItems[selected].text)\\\
      end\\\
    )\\\
    for i = x,x+7 do\\\
      touchMap[i][y] = cancelFunc\\\
    end\\\
    for i = x+9,x+12 do\\\
      touchMap[i][y] = okFunc\\\
    end\\\
    local eventHandlers = {\\\
      mouse_click = function(tEvent)\\\
        local x,y = tEvent[3],tEvent[4]\\\
        local func = touchMap[x][y]\\\
        if func then\\\
          return func(x,y)\\\
        end\\\
      end,\\\
      mouse_scroll = function(tEvent)\\\
        local oldScroll = scroll\\\
        scroll = math.max(0,math.min(scroll+tEvent[2],#tItems-visibleSelections))\\\
        if scroll ~= oldScroll then\\\
          refresh()\\\
        end\\\
      end,\\\
      key = function(tEvent)\\\
        local key = tEvent[2]\\\
        if key == 28 then\\\
          return endExecution(\\\"Ok\\\",selected)\\\
        end\\\
      end\\\
    }\\\
    if customEvent then\\\
      for k,v in pairs(customEvent) do\\\
        local mainFunc = eventHandlers[k]\\\
        eventHandlers[k] = function(tEvent)\\\
          local customEvent = v(tEvent)\\\
          if button then\\\
            return endExecution(customEvent,selected)\\\
          end\\\
          if mainFunc then\\\
            return mainFunc(tEvent,selected)\\\
          end\\\
        end\\\
      end\\\
    end\\\
    eventHandler.switch(eventHandlers)\\\
    while true do\\\
    --user interaction begins\\\
      local event,selection = eventHandler.pull()\\\
      if type(event) == \\\"string\\\" then\\\
        if reinput then\\\
          for i,item in ipairs(tItems) do\\\
            item.selected = selected[i]\\\
          end\\\
          reinput = function(reText)\\\
            return window.scroll(reText,tItems,multiSelection,true,customEvent)\\\
          end\\\
        end\\\
        return event,selection,reinput\\\
      end\\\
    end\\\
  end\\\
}\\\
--[[----------------------------------------------------------------------------------------------------------\\\
Common inputs\\\
----------------------------------------------------------------------------------------------------------]]--\\\
local colorSelect = {}\\\
for k,v in pairs(colors) do\\\
  if type(v) == \\\"number\\\" then\\\
    k = k:gsub(\\\"(%u)\\\",function(l) return \\\" \\\"..l:lower() end)\\\
    k = k:sub(1,1):upper()..k:sub(2)\\\
    colorSelect[#colorSelect+1] = {\\\
      text = k,\\\
      uText = v ~= tColors.scrollBoxSelectText and tColors.scrollBoxSelectText or colors.black,\\\
      uBackground = v\\\
    }\\\
  end\\\
end\\\
dialogue = {\\\
  selectTurtle = function(text,multi)\\\
    local connected = {}\\\
    for k,v in pairs(tMode.sync.ids) do\\\
      if v == \\\"turtle\\\" then\\\
        connected[#connected+1] = k..\\\" - Turtle\\\"\\\
      end\\\
    end\\\
    local ids,button\\\
    if #connected > 1 then\\\
      button,ids = window.scroll(text,connected,multi)\\\
      if button == \\\"Cancel\\\" then\\\
        return false\\\
      end\\\
    else\\\
      ids = connected\\\
    end\\\
    local retIDs = {}\\\
    local nID\\\
    for i,id in ipairs(ids) do\\\
      nID = tonumber(id:match\\\"%d+\\\")\\\
      retIDs[nID] = true\\\
    end\\\
    return retIDs, multi and #ids or nID\\\
  end,\\\
  selectColor = function(text)\\\
    local event,selected = window.scroll(text,colorSelect)\\\
    if event ~= \\\"Cancel\\\" then\\\
      selected = selected:lower()\\\
      local space = selected:find\\\" \\\"\\\
      if space then\\\
        selected = selected:sub(1,space-1)..string.upper(selected:sub(space+1,space+1))..selected:sub(space+2)\\\
      end\\\
      return selected\\\
    end\\\
    return event\\\
  end,\\\
  save = function(text)\\\
    local fileName = tFile.blueprint\\\
    local button,tRes,reInput\\\
    if not fileName then\\\
      button, tRes, reInput = window.text(\\\
        text or \\\"No file name for current blueprint,\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"File name\\\",\\\
            value = \\\"/\\\",\\\
            accepted = \\\".\\\"\\\
          },\\\
        },\\\
        false,\\\
        true\\\
      )\\\
    end\\\
    while button and button ~= \\\"Cancel\\\" do\\\
      fileName = not tFile.blueprint and tRes[\\\"File name\\\"] or fileName\\\
      if not fileName then\\\
        button,tRes,reInput = reinput(\\\"Invalid file name!\\\")\\\
      elseif fs.exists(fileName..\\\".TAb\\\") then\\\
        button = window.text(\\\
          fileName..\\\" already exists!\\\\n Overwrite?\\\",\\\
          {\\\
            \\\"Cancel\\\",\\\
            \\\"Overwrite\\\"\\\
          }\\\
        )\\\
        if button == \\\"Overwrite\\\" or button == \\\"Ok\\\" then\\\
          break\\\
        end\\\
        button,tRes,reInput = reInput(\\\"Overwrite of \\\"..fileName..\\\" cancelled. Input new file name.\\\")\\\
      else\\\
        break\\\
      end\\\
    end\\\
    if button == \\\"Cancel\\\" then\\\
      return false\\\
    end\\\
    tBlueprint:save(fileName)\\\
    tFile.blueprint = fileName\\\
    window.text(\\\"Successfully saved \\\"..fileName..\\\".TAb.\\\")\\\
    return true\\\
  end\\\
}\",\
    [ \"TAFiles/Functions/Commands.lua\" ] = \"function saveProgress(fileName,tProgress)\\\
  local file = class.fileTable.new()\\\
  file:write(\\\"layers: \\\"..textutils.serialize(tProgress.layers):gsub(\\\"\\\\n%s-\\\",\\\"\\\"))\\\
  file:write(\\\"X: \\\"..tProgress.x)\\\
  file:write(\\\"Y: \\\"..tProgress.y)\\\
  file:write(\\\"Z: \\\"..tProgress.z)\\\
  file:write(\\\"dir X: \\\"..tProgress.dir.x)\\\
  file:write(\\\"dir Y: \\\"..tProgress.dir.y)\\\
  file:write(\\\"dir Z: \\\"..tProgress.dir.z)\\\
  file:write(\\\"Enderchest: Disabled\\\")\\\
  file:write(\\\"Break mode: Disabled\\\")\\\
  file:save(fileName..\\\".TAo\\\")\\\
end\\\
\\\
function loadProgress(fileName)\\\
  local tOngoing = {}\\\
  local file = fs.open(fileName..\\\".TAo\\\",\\\"r\\\")\\\
  local read = file.readLine\\\
  local line = read()\\\
  tOngoing.layers = textutils.unserialize(line:match\\\"layers: ({.+)\\\" or 1)\\\
  line = read()\\\
  tOngoing.x = tonumber(line:match\\\"X: ([%d-]+)\\\" or 0)\\\
  line = read()\\\
  tOngoing.y = tonumber(line:match\\\"Y: ([%d-]+)\\\" or 0)\\\
  line = read()\\\
  tOngoing.z = tonumber(line:match\\\"Z: ([%d-]+)\\\" or 0)\\\
  tOngoing.dir = {}\\\
  line = read()\\\
  tOngoing.dir.x = line:match\\\"dir X: ([+-])\\\" or \\\"+\\\"\\\
  line = read()\\\
  tOngoing.dir.y = line:match\\\"dir Y: ([+-])\\\" or \\\"+\\\"\\\
  line = read()\\\
  tOngoing.dir.z = line:match\\\"dir Z: ([+-])\\\" or \\\"+\\\"\\\
  file.close()\\\
  return tOngoing\\\
end\\\
\\\
function assignColorSlots(color)\\\
  local button, tRes, reInput = window.text(\\\
    \\\"Input block ID for \\\"..keyColor[color],\\\
    {\\\
      \\\"Cancel\\\",\\\
      \\\"Ok\\\",\\\
    },\\\
    {\\\
      {\\\
        name = \\\"ID\\\",\\\
        accepted = \\\"[%d:]\\\",\\\
      },\\\
    },\\\
    false,\\\
    true\\\
  )\\\
  while button ~= \\\"Cancel\\\" do\\\
    if not tRes.ID then\\\
      button, tRes, reInput = reInput\\\"Missing block ID parameter!\\\"\\\
    else\\\
      tBlueprint.colorSlots[color] = tRes.ID\\\
      return true\\\
    end\\\
  end\\\
  return false\\\
end\\\
\\\
function checkUsage(blueprint,tLayers)\\\
  --checks amount of materials required to build the given blueprint\\\
  blueprint = blueprint or tBlueprint\\\
  if not tOngoing.layers then\\\
    tOngoing.layers = {}\\\
    for i=1,#tBlueprint do\\\
      tOngoing.layers[i] = i\\\
    end\\\
  end\\\
  local tUsage = {}\\\
  local loop = 0\\\
  for iL,nL in ipairs(tLayers) do\\\
    for nX,vX in pairs(blueprint[nL]) do\\\
      for nZ,block in pairs(vX) do\\\
        local nX = nX\\\
        if block:match\\\"[%lX]\\\" then\\\
          tUsage[block] = (tUsage[block] or 0)+1\\\
        end\\\
      end\\\
    end\\\
    loop = loop+1\\\
    if loop%1000 == 0 then\\\
      sleep(0.05)\\\
    end\\\
  end\\\
  return tUsage\\\
end\\\
\\\
function checkProgress(fileName,tProgress,blueprint,auto)\\\
  blueprint = blueprint or class.blueprint.load(fileName) or tBlueprint\\\
  if fileName\\\
  and fs.exists(fileName..\\\".TAo\\\")\\\
  and not tProgress then\\\
    tProgress = loadProgress(fileName)\\\
    local button = window.text(\\\
      [[In-progress build of current blueprint found.\\\
layers ]]..tProgress.layers[1]..[[-]]..tProgress.layers[#tProgress.layers]..[[ \\\
X: ]]..tProgress.x..[[ \\\"]]..tProgress.dir.x..[[\\\"\\\
Y: ]]..tProgress.y..[[ \\\"]]..tProgress.dir.y..[[\\\"\\\
Z: ]]..tProgress.z..[[ \\\"]]..tProgress.dir.z..[[\\\"\\\
Load?]],\\\
      {\\\
        \\\"Yes\\\",\\\
        \\\"No\\\"\\\
      }\\\
    )\\\
    if button == \\\"No\\\" then\\\
      tProgress = {\\\
        dir = {}\\\
      }\\\
    end\\\
  else\\\
    tProgress = {\\\
      dir = {}\\\
    }\\\
  end\\\
  if not (tProgress.layers) then\\\
    local tSelection = {}\\\
    for i=1,#tBlueprint do\\\
      tSelection[i] = {\\\
        text = tostring(i),\\\
        selected = true\\\
      }\\\
    end\\\
    local button, tRes, reinput = window.scroll(\\\
      \\\"Select layers to build\\\",\\\
      tSelection,\\\
      true,\\\
      true\\\
    )\\\
    while button ~= \\\"Cancel\\\" do\\\
      if #tRes < 1 then\\\
        button, tRes, reinput = reinput(\\\"Atleast 1 layer must be selected\\\")\\\
      else\\\
        tProgress.layers = {}\\\
        for i,v in ipairs(tRes) do\\\
          tProgress.layers[i] = tonumber(v)\\\
        end\\\
        break\\\
      end\\\
    end\\\
    if button == \\\"Cancel\\\" then\\\
      return false\\\
    end\\\
  end\\\
  local tUsage = checkUsage(blueprint,tProgress.layers)\\\
  local fuelUsage = tUsage.fuel\\\
  tUsage.fuel = nil\\\
  for k,v in pairs(tUsage) do\\\
    if (not tBlueprint.colorSlots[k] or type(tBlueprint.colorSlots[k]) ~= \\\"number\\\") and k ~= \\\"X\\\" then\\\
      if not assignColorSlots(k) then\\\
        return false\\\
      end\\\
    end\\\
  end\\\
  blueprint:save(fileName or tFile.blueprint)\\\
  if not tProgress.x then\\\
    local button, tRes, reInput = window.text(\\\
      \\\"Input build coordinates\\\",\\\
      {\\\
        \\\"Cancel\\\",\\\
        \\\"Ok\\\",\\\
        ((cTurtle or commands) and \\\"Cur pos\\\" or nil)\\\
      },\\\
      {\\\
        {\\\
          name = \\\"X\\\",\\\
          value = cTurtle and cTurtle.tPos.x or commands and tPos.x or \\\"\\\",\\\
          accepted = \\\"[+%d-]\\\"\\\
        },\\\
        {\\\
          name = \\\"Y\\\",\\\
          value = cTurtle and cTurtle.tPos.y or commands and tPos.y or \\\"\\\",\\\
          accepted = \\\"[%d+-]\\\"\\\
        },\\\
        {\\\
          name = \\\"Z\\\",\\\
          value = cTurtle and cTurtle.tPos.z or commands and tPos.z or \\\"\\\",\\\
          accepted = \\\"[%d+-]\\\"\\\
        },\\\
      },\\\
      false,\\\
      true\\\
    )\\\
    while true do\\\
      if button == \\\"Cancel\\\" then\\\
        return false\\\
      elseif button == \\\"Cur pos\\\" then\\\
        if cTurtle then\\\
          tRes.X = cTurtle.tPos.x\\\
          tRes.Y = cTurtle.tPos.y\\\
          tRes.Z = cTurtle.tPos.z\\\
        else\\\
          tRes.X = tPos.x\\\
          tRes.Y = tPos.y+1\\\
          tRes.Z = tPos.z\\\
        end\\\
      end\\\
      if not tRes.X then\\\
        button,tRes,reInput = reinput(\\\"Missing parameter X!\\\")\\\
      elseif not tRes.Y then\\\
        button,tRes,reInput = reinput(\\\"Missing parameter Y!\\\")\\\
      elseif not tRes.Z then\\\
        button,tRes,reInput = reinput(\\\"Missing parameter Z!\\\")\\\
      elseif button == \\\"Ok\\\" or button == \\\"Cur pos\\\" then\\\
        tProgress.x = tRes.X\\\
        tProgress.y = tRes.Y\\\
        tProgress.z = tRes.Z\\\
        break\\\
      end\\\
    end\\\
  end\\\
  if not tProgress.dir.x then\\\
    local button, tRes, reInput = window.text(\\\
      \\\"Input build directions\\\",\\\
      {\\\
        \\\"Cancel\\\",\\\
        \\\"Ok\\\",\\\
      },\\\
      {\\\
        {\\\
          name = \\\"X\\\",\\\
          value = \\\"+\\\",\\\
          accepted = \\\"[+-]\\\",\\\
          charLimit = 1\\\
        },\\\
        {\\\
          name = \\\"Y\\\",\\\
          value = \\\"+\\\",\\\
          accepted = \\\"[+-]\\\",\\\
          charLimit = 1\\\
        },\\\
        {\\\
          name = \\\"Z\\\",\\\
          value = \\\"+\\\",\\\
          accepted = \\\"[+-]\\\",\\\
          charLimit = 1\\\
        },\\\
      },\\\
      false,\\\
      true\\\
    )\\\
    while true do\\\
      if button == \\\"Cancel\\\" then\\\
        return false\\\
      elseif not tRes.X then\\\
        button,tRes,reInput = reinput(\\\"Missing X direction!\\\")\\\
      elseif not tRes.Y then\\\
        button,tRes,reInput = reinput(\\\"Missing Y direction!\\\")\\\
      elseif not tRes.Z then\\\
        button,tRes,reInput = reinput(\\\"Missing Z direction!\\\")\\\
      elseif button == \\\"Ok\\\" then\\\
        tProgress.dir.x = tRes.X\\\
        tProgress.dir.y = tRes.Y\\\
        tProgress.dir.z = tRes.Z\\\
        break\\\
      end\\\
    end\\\
  end\\\
  saveProgress(fileName,tProgress)\\\
  return tProgress,fileName\\\
end\\\
\\\
function build(blueprint,clear)\\\
  --builds the given blueprint layers\\\
  if not clear and not tFile.blueprint then\\\
    if not dialogue.save\\\"Blueprint must be saved locally prior to building\\\" then\\\
      window.text\\\"Construction cancelled\\\"\\\
      return\\\
    end\\\
  end\\\
  blueprint = blueprint or tBlueprint\\\
  local tOngoing = checkProgress(tFile.blueprint)\\\
  if not tOngoing then\\\
    window.text((clear and \\\"Removal\\\" or \\\"Construction\\\")..\\\" cancelled.\\\")\\\
    return\\\
  else\\\
    tOngoing = loadProgress(tFile.blueprint)\\\
  end\\\
  screen:refresh()\\\
  local dirX = tOngoing.dir.x\\\
  local dirZ = tOngoing.dir.z\\\
  local dirY = tOngoing.dir.y\\\
  local loop = 0\\\
  for iL,nL in ipairs(tOngoing.layers) do\\\
    local layerCopy = blueprint[nL]:copy() --table copy because fuck you next\\\
    for nX,vX in pairs(layerCopy) do\\\
      for nZ in pairs(vX) do\\\
        local block = blueprint[nL][nX][nZ]\\\
        if block then\\\
          if clear then\\\
            if block ~= \\\"X\\\" then\\\
              commands.execAsync(\\\"setblock \\\"..tOngoing.x + tonumber(dirX..nX-1)..\\\" \\\"..tOngoing.y + tonumber(dirY..nL-1)..\\\" \\\"..tOngoing.z + tonumber(dirZ..nZ-1)..\\\" 0\\\")\\\
              blueprint[nL][nX][nZ] = block:lower()\\\
              loop = loop+1\\\
            end\\\
          elseif block:match\\\"[%lX]\\\" then\\\
            if block == \\\"X\\\" then\\\
              commands.execAsync(\\\"setblock \\\"..tOngoing.x + tonumber(dirX..nX-1)..\\\" \\\"..tOngoing.y + tonumber(dirY..nL-1)..\\\" \\\"..tOngoing.z + tonumber(dirZ..nZ-1)..\\\" 0\\\")\\\
              blueprint[nL][nX][nZ] = nil\\\
            else\\\
              commands.execAsync(\\\"setblock \\\"..tOngoing.x + tonumber(dirX..nX-1)..\\\" \\\"..tOngoing.y + tonumber(dirY..nL-1)..\\\" \\\"..tOngoing.z + tonumber(dirZ..nZ-1)..\\\" \\\"..tBlueprint.colorSlots[block])\\\
              blueprint[nL][nX][nZ] = block:upper()\\\
            end\\\
            loop = loop+1\\\
          end\\\
          if loop%10000 == 0 then\\\
            blueprint:save(tFile.blueprint,true)\\\
            scroll(nL,nX-math.floor(tTerm.canvas.tX/2),nZ-math.floor(tTerm.canvas.tZ/2),true,true)\\\
            screen:refresh()\\\
            sleep(1)\\\
          end\\\
        end\\\
      end\\\
    end\\\
  end\\\
  blueprint:save(tFile.blueprint,true)\\\
  scroll()\\\
  window.text((clear and \\\"Removal\\\" or \\\"Construction\\\")..\\\" complete.\\\")\\\
end\\\
\\\
function scan(x1,y1,z1,x2,y2,z2)\\\
  if not (x1 and y1 and z1 and x2 and y2 and z2) then\\\
    local button, tRes, reInput = window.text(\\\
      \\\"Input scan boundaries\\\",\\\
      {\\\
        \\\"Cancel\\\",\\\
        \\\"Ok\\\",\\\
      },\\\
      {\\\
        {\\\
          name = \\\"X1\\\",\\\
          value = tPos.x,\\\
          accepted = \\\"[%d+-]\\\",\\\
        },\\\
        {\\\
          name = \\\"Y1\\\",\\\
          value = tPos.y,\\\
          accepted = \\\"[%d+-]\\\",\\\
        },\\\
        {\\\
          name = \\\"Z1\\\",\\\
          value = tPos.z,\\\
          accepted = \\\"[%d+-]\\\",\\\
        },\\\
        {\\\
          name = \\\"X2\\\",\\\
          value = tPos.x,\\\
          accepted = \\\"[%d+-]\\\",\\\
        },\\\
        {\\\
          name = \\\"Y2\\\",\\\
          value = tPos.y,\\\
          accepted = \\\"[%d+-]\\\",\\\
        },\\\
        {\\\
          name = \\\"Z2\\\",\\\
          value = tPos.z,\\\
          accepted = \\\"[%d+-]\\\",\\\
        },\\\
      },\\\
      false,\\\
      true\\\
    )\\\
    while button ~= \\\"Cancel\\\" do\\\
      if not tRes.X1 then\\\
        button, tRes, reInput = reInput\\\"Missing X1 parameter!\\\"\\\
      elseif not tRes.X2 then\\\
        button, tRes, reInput = reInput\\\"Missing X2 parameter!\\\"\\\
      elseif not tRes.Y1 then\\\
        button, tRes, reInput = reInput\\\"Missing Y1 parameter!\\\"\\\
      elseif not tRes.Y2 then\\\
        button, tRes, reInput = reInput\\\"Missing Y2 parameter!\\\"\\\
      elseif not tRes.Z1 then\\\
        button, tRes, reInput = reInput\\\"Missing Z1 parameter!\\\"\\\
      elseif not tRes.Z2 then\\\
        button, tRes, reInput = reInput\\\"Missing Z2 parameter!\\\"\\\
      else\\\
        x1 = math.min(tRes.X1,tRes.X2)\\\
        x2 = math.max(tRes.X1,tRes.X2)\\\
        y1 = math.min(tRes.Y1,tRes.Y2)\\\
        y2 = math.max(tRes.Y1,tRes.Y2)\\\
        z1 = math.min(tRes.Z1,tRes.Z2)\\\
        z2 = math.max(tRes.Z1,tRes.Z2)\\\
        break\\\
      end\\\
    end\\\
    if button == \\\"Cancel\\\" then\\\
      window.text\\\"Scan cancelled.\\\"\\\
      return\\\
    end\\\
  end\\\
  local tBlocks = {}\\\
  local iColor = 1\\\
  loop = 1\\\
  for iY = 1,math.abs(y2-y1)+1 do\\\
    tBlueprint[iY] = tBlueprint[iY] or class.layer.new()\\\
    for iX = 1,math.abs(x2-x1)+1 do\\\
      for iZ = 1,math.abs(z2-z1)+1 do\\\
        local block = commands.getBlockInfo(x1+iX-1,y1+iY-1,z1+iZ-1)\\\
        if block.name ~= \\\"minecraft:air\\\" then\\\
          if not tBlocks[block.name] then\\\
            tBlocks[block.name] = colorKey[2^iColor]:upper()\\\
            iColor = (iColor < 16 and iColor+1 or 1)\\\
          end\\\
          tBlueprint[iY][iX][iZ] = tBlocks[block.name]\\\
          loop = loop+1\\\
          if loop >= 10 then\\\
            scroll(iY,iX-math.floor(tTerm.canvas.tX/2),iZ-math.floor(tTerm.canvas.tZ/2),true,true)\\\
            screen:refresh()\\\
            loop = 1\\\
          end\\\
        end\\\
      end\\\
    end\\\
  end\\\
  window.text\\\"Scan complete.\\\"\\\
end\",\
    [ \"TAFiles/Tools/fCircle.Lua\" ] = \"local calcFunc = function(x1,z1,x2,z2,color)\\\
  local x = {\\\
    max = math.max(x1,x2),\\\
    min = math.min(x1,x2)\\\
  }\\\
  x.max = x.max-x.min+1\\\
  x.min = 1\\\
  x.rad = math.round((x.max-x.min)/2)\\\
  x.center = x.rad+x.min\\\
  local z = {\\\
    max = math.max(z1,z2),\\\
    min = math.min(z1,z2)\\\
  }\\\
  z.max = z.max-z.min+1\\\
  z.min = 1\\\
  z.rad = math.round((z.max-z.min)/2)\\\
  z.center = z.rad+z.min\\\
  local points = class.layer.new()\\\
  local radStep = 1/((1.5*x.rad)+(1.5*z.rad)/2)\\\
  for angle = 1, math.pi+radStep, radStep do\\\
    local pX = math.round(math.cos(angle)*x.rad)\\\
    local pZ = math.round(math.sin(angle)*z.rad)\\\
    for iX = x.center-pX,x.center+pX do\\\
      for i=-1,1,2 do\\\
        points[iX][z.center+(pZ*i)] = color\\\
      end\\\
    end\\\
    for iZ = z.center-pZ,z.center+pZ do\\\
      for i=-1,1,2 do\\\
        points[x.center+(pX*i)][iZ] = color\\\
      end\\\
    end\\\
  end\\\
  return points\\\
end\\\
\\\
local tool\\\
tool = {\\\
  menuOrder = 7, --menu order, 1 being top\\\
  enabled = true,\\\
  help = function(clickButton)\\\
    local button = window.text(\\\
      \\\"The filled circle tool lets you draw a filled circle by left clicking a point and dragging to the opposite point. When you are satisfied, simply right click to draw it on the blueprint\\\",\\\
      {\\\
        \\\"Ok\\\",\\\
        \\\"Equip\\\"\\\
      }\\\
    )\\\
    if button == \\\"Equip\\\" then\\\
      tool.selectFunc(clickButton)\\\
    end\\\
  end,\\\
  selectFunc = function(button)\\\
    tTool.change(\\\"fCircle\\\",1,2)\\\
  end,\\\
  renderFunc = function(event,button,x,z,color)\\\
    local c = tTool.shape\\\
    if event == \\\"mouse_click\\\" then\\\
      if button == 1 then\\\
        c.sX = x+tTerm.scroll.x\\\
        c.sZ = z+tTerm.scroll.z\\\
        if c.eX then\\\
          screen:clearLayer(screen.layers.toolsOverlay)\\\
        end\\\
        c.eX = false\\\
        c.eZ = false\\\
      elseif c.eX then --button 2\\\
        c.layer = tTerm.scroll.layer\\\
        sync(c,\\\"Paste\\\")\\\
        tBlueprint[tTerm.scroll.layer]:paste(c.l,math.min(c.sX,c.eX),math.min(c.sZ,c.eZ),not tMode.overwrite)\\\
        renderArea(c.sX,c.sZ,c.eX,c.eZ,true)\\\
        tTool.shape = {}\\\
        renderToolOverlay()\\\
      end\\\
    elseif button == 1 and c.sX then --drag\\\
      c.eX = x+tTerm.scroll.x\\\
      c.eZ = z+tTerm.scroll.z\\\
      c.l = calcFunc(c.sX,c.sZ,c.eX,c.eZ,color)\\\
      renderToolOverlay()\\\
    end\\\
    if c.sX and c.sZ and c.eX and c.eZ then\\\
      tTerm.misc.csAmend = \\\"Circ: \\\" .. math.abs(c.eX - c.sX) + 1 .. \\\"x\\\" .. math.abs(c.eZ - c.sZ) + 1\\\
      tTerm.misc.forceBottomBarRender = true\\\
    end\\\
  end,\\\
  codeFunc = function(sX,sZ,eX,eZ,color,layer) --this is used by the code tool\\\
    color = color or codeEnv.click.color\\\
    layer = layer or codeEnv.click.layer\\\
    local layerType = type(layer)\\\
    if not (sX and sZ and eX and eZ)\\\
    or not (type(sX) == \\\"number\\\" and type(sZ) == \\\"number\\\" and type(eX) == \\\"number\\\" and type(eZ) == \\\"number\\\") then\\\
      error(\\\"Expected number,number,number,number\\\",2)\\\
    end\\\
    if layerType == \\\"table\\\" and layer.paste then\\\
      layer:paste(calcFunc(sX,sZ,eX,eZ,color),math.min(sX,eX),math.min(sZ,eZ),not tMode.overwrite)\\\
    elseif codeEnv.settings.direct then\\\
      local c = {\\\
        sX = sX,\\\
        sZ = sZ,\\\
        eX = eX,\\\
        eZ = eZ,\\\
        layer = layer,\\\
        l = calcFunc(sX,sZ,eX,eZ,color)\\\
      }\\\
      tBlueprint[layer]:paste(c.l,math.min(sX,eX),math.min(sZ,eZ),not tMode.overwrite)\\\
      sync(c,\\\"Paste\\\")\\\
      renderArea(sX,sZ,eX,eZ,true)\\\
    elseif layerType == \\\"number\\\" then\\\
      codeEnv.blueprint[layer]:paste(calcFunc(sX,sZ,eX,eZ,color),math.min(sX,eX),math.min(sZ,eZ),not tMode.overwrite)\\\
    else\\\
      error(\\\"Expected layer, got \\\"..layerType,2)\\\
    end\\\
  end\\\
}\\\
return tool\\\
\",\
    [ \"TAFiles/Menus/rightClick.Lua\" ] = \"local rightClick = {}\\\
\\\
for _k,file in pairs(fs.list(tFile.menuFolder..\\\"/rightClick\\\")) do\\\
  if not fs.isDir(tFile.menuFolder..\\\"/\\\"..file) then\\\
    rightClick[file:match\\\"(.+)%.Lua\\\"] = loadFile(tFile.menuFolder..\\\"/rightClick/\\\"..file,progEnv)\\\
  end\\\
end\\\
\\\
--create menu strings\\\
for name,menu in pairs(rightClick) do\\\
  menu.name = name\\\
  local longest = 0\\\
  for i,menu in ipairs(menu) do\\\
    longest = math.max(longest,#menu.name)\\\
  end\\\
  menu.lX = longest+1\\\
  longest = longest/2 --center text\\\
  for i,menu in ipairs(menu) do\\\
    local name = menu.name\\\
    menu.string = string.rep(\\\" \\\",math.floor(longest+1-(#name/2)))..name..string.rep(\\\" \\\",math.ceil(longest+1-(#name/2)))\\\
  end\\\
  menu.lZ = #menu\\\
end\\\
\\\
rightClick.render = function(menu,x,z)\\\
  menu = rightClick[menu]\\\
  if not menu then\\\
    return\\\
  end\\\
  screen:setLayer(screen.layers.menus)\\\
  x = x or menu.sX\\\
  z = z or menu.sZ\\\
  menu.eZ = z+menu.lZ-1\\\
  menu.eX = x+menu.lX\\\
  tMenu.touchMap = class.matrix.new(2)\\\
  tMenu.open = menu.name\\\
  menu.sX = x\\\
  menu.sZ = z\\\
  menu.splits = math.ceil(menu.lZ/(tTerm.screen.y-1))\\\
  if menu.splits > 1 then\\\
    menu.sZ = 1\\\
    menu.eZ = math.ceil(menu.lZ/menu.splits)\\\
    menu.sX = tTerm.canvas.eX-(menu.lX*menu.splits)\\\
    menu.eX = tTerm.canvas.eX\\\
  else\\\
    if menu.sZ < 1 then\\\
      while menu.sZ < 1 do\\\
        menu.sZ = menu.sZ+1\\\
        menu.eZ = menu.eZ+1\\\
      end\\\
    elseif menu.eZ > tTerm.canvas.eZ then\\\
      while menu.eZ > tTerm.canvas.eZ do\\\
        menu.sZ = menu.sZ-1\\\
        menu.eZ = menu.eZ-1\\\
      end\\\
    end\\\
    if menu.sX < 1 then\\\
      while menu.sX < 1 do\\\
        menu.sX = menu.sX+1\\\
        menu.eX = menu.eX+1\\\
      end\\\
    elseif menu.eX > tTerm.canvas.eX then\\\
      while menu.eX > tTerm.canvas.eX do\\\
        menu.sX = menu.sX-1\\\
        menu.eX = menu.eX-1\\\
      end\\\
    end\\\
  end\\\
  local eZ = menu.eZ\\\
  local nextMenu = 0\\\
  for split=1,menu.splits do\\\
    local sX = math.floor(menu.eX-(menu.lX*split))\\\
    local eX = sX+menu.lX-split+1 --i dunno why this is necessary...\\\
    for i=1,math.ceil(#menu/menu.splits) do\\\
      nextMenu = nextMenu+1\\\
      local item = menu[nextMenu]\\\
      if not item then\\\
        break\\\
      end\\\
      local help = item.help\\\
      local helpFunc = (\\\
        help\\\
        and function(button)\\\
          return tTool[button].tool == \\\"Help\\\" and (help() or true)\\\
        end\\\
        or function(button)\\\
          return tTool[button].tool == \\\"Help\\\" and window.text(item.name..\\\"\\\\ndosen't have a help function. Please define it in the menu file as \\\\\\\"help\\\\\\\"\\\") and true\\\
        end\\\
      )\\\
      local iMenu = nextMenu\\\
      local iZ = menu.sZ+i-1\\\
      local enabled = item.enabled\\\
      enabled = type(enabled) == \\\"function\\\" and enabled() or enabled == true\\\
      screen:setBackgroundColor((i%2 == 0 and tColors.rightClickPri) or tColors.rightClickSec)\\\
      if enabled then\\\
        screen:setTextColor(tColors.rightClickUseable)\\\
        local function menuFunc(button)\\\
          if not helpFunc(button) then\\\
            renderMenu()\\\
            item.func(button)\\\
          end\\\
        end\\\
        for iX = sX,eX do\\\
          tMenu.touchMap[iX][iZ] = menuFunc\\\
        end\\\
      else\\\
        screen:setTextColor(tColors.rightClickUnuseable)\\\
        for iX = sX,eX do\\\
          tMenu.touchMap[iX][iZ] = helpFunc\\\
        end\\\
      end\\\
      screen:setCursorPos(sX,iZ)\\\
      screen:write(item.string)\\\
    end\\\
  end\\\
  --[[for i,item in ipairs(menu) do\\\
    local z = z+i-1\\\
    screen:setCursorPos(x,z)\\\
    screen:setBackgroundColor((i%2 == 0 and tColors.rightClickPri) or tColors.rightClickSec)\\\
    local help = item.help\\\
    local helpFunc = (\\\
      help\\\
      and function(button)\\\
        return tTool[button].tool == \\\"Help\\\" and (help() or true)\\\
      end\\\
      or function(button)\\\
        return tTool[button].tool == \\\"Help\\\" and window.text(menu[i].name..\\\"\\\\ndosen't have a help function. Please define it in the menu file as \\\\\\\"help\\\\\\\"\\\") and true\\\
      end\\\
    )\\\
    if type(item.enabled) == \\\"function\\\" and item.enabled() or item.enabled == true then\\\
      screen:setTextColor(tColors.rightClickUseable)\\\
      local function menuFunc(button)\\\
        if not helpFunc(button) then\\\
          renderMenu()\\\
          item.func(button)\\\
        end\\\
      end\\\
      for iX = x,eX do\\\
        tMenu.touchMap[iX][z] = menuFunc\\\
      end\\\
    else\\\
      screen:setTextColor(tColors.rightClickUnuseable)\\\
      for iX = x,eX do\\\
        tMenu.touchMap[iX][z] = helpFunc\\\
      end\\\
    end\\\
    screen:write(item.string)\\\
  end]]\\\
end\\\
\\\
return rightClick\\\
\",\
    [ \"TAFiles/EventHandlers/eventHandler.Lua\" ] = \"local eventHandler\\\
eventHandler = {\\\
  keysDown = {}, --list of all keys currently pressed\\\
  miceDown = { --list of all mice currently pressed, and their last positions\\\
    [1] = {false, 0, 0},\\\
    [2] = {false, 0, 0},\\\
    [3] = {false, 0, 0},\\\
    changed = false\\\
  },\\\
  active = {}, --current event handlers\\\
  switch = function(tHandlers,skipCommon)\\\
    eventHandler.active = {}\\\
    if cTurtle then\\\
       cTurtle.clearEventHandler(true)\\\
    end\\\
    for k,v in pairs(tHandlers) do\\\
      eventHandler.active[k] = (\\\
        eventHandler.common[k]\\\
        and not skipCommon\\\
        and function(tEvent)\\\
          local var1,var2,var3,var4,var5 = eventHandler.common[k](tEvent)\\\
          if var1 then\\\
            return var1,var2,var3,var4,var5\\\
          else\\\
            return v(tEvent)\\\
          end\\\
        end\\\
        or v\\\
      )\\\
      if cTurtle then\\\
        cTurtle.eventHandler[k] = function(tEvent)\\\
          eventHandler.active[k](tEvent)\\\
          screen:refresh()\\\
        end\\\
      end\\\
    end\\\
    if not skipCommon then\\\
      for k,v in pairs(eventHandler.common) do\\\
        eventHandler.active[k] = eventHandler.active[k] or v\\\
        if cTurtle and not cTurtle.eventHandler[k] then\\\
          cTurtle.eventHandler[k] = function(tEvent)\\\
            eventHandler.active[k](tEvent)\\\
            screen:refresh()\\\
          end\\\
        end\\\
      end\\\
    end\\\
  end,\\\
  pull = function(sFilter)\\\
    screen:refresh()\\\
    local tEvent = {os.pullEvent(sFilter)}\\\
\\\
    if tEvent[1] == \\\"key\\\" and not tEvent[3] then --populate eventHandler.keysDown\\\
      eventHandler.keysDown[tEvent[2]] = true\\\
    elseif tEvent[1] == \\\"key_up\\\" then --depopulate said table\\\
      eventHandler.keysDown[tEvent[2]] = false\\\
    end\\\
\\\
    if tEvent[1] == \\\"mouse_click\\\" or tEvent[1] == \\\"mouse_drag\\\" then\\\
      eventHandler.miceDown[ tEvent[2] ] = {true, tEvent[3], tEvent[4]}\\\
      eventHandler.miceDown.changed = true\\\
    elseif tEvent[1] == \\\"mouse_up\\\" then\\\
      eventHandler.miceDown[ tEvent[2] ][1] = false\\\
      eventHandler.miceDown.changed = true\\\
    end\\\
    \\\
    if eventHandler.active[tEvent[1]] then\\\
      return eventHandler.active[tEvent[1]](tEvent)\\\
    end\\\
  end\\\
}\\\
for _k, file in pairs(fs.list(tFile.eventHandlerFolder)) do\\\
  if file ~= \\\"eventHandler.Lua\\\" then\\\
    eventHandler[file:match\\\"(.-)\\\\.Lua\\\"] = loadFile(tFile.eventHandlerFolder..\\\"/\\\"..file)\\\
  end\\\
end\\\
if cTurtle then\\\
  for k,v in pairs(eventHandler.cTurtle) do --load cTurtle specific events\\\
    cTurtle.eventHandler[k] = v\\\
  end\\\
end\\\
return eventHandler\\\
\",\
    [ \"TAFiles/EventHandlers/main.Lua\" ] = \"local main\\\
main = { \\\
  mouse_click = function(tEvent)\\\
    local button,x,y = tEvent[2],tEvent[3],tEvent[4]\\\
    if tMenu.open and tMenu.touchMap[x][y] then\\\
      if tMenu.touchMap[x][y] ~= true then --true signifies a disabled menu\\\
        tMenu.touchMap[x][y](button,x,y)\\\
      end\\\
      return true\\\
    elseif tBar.touchMap[x][y] and tEvent[1] == \\\"mouse_click\\\" then --right menu bar click\\\
      tBar.touchMap[x][y](button,x,y)\\\
      return true\\\
    elseif y <= tTerm.canvas.eZ\\\
    and y >= tTerm.canvas.sZ \\\
    and x <= tTerm.canvas.eX\\\
    and x >= tTerm.canvas.sX then --canvas click\\\
      x,y = x-tTerm.viewable.mX,y-tTerm.viewable.mZ\\\
      if tMenu.open then\\\
        renderMenu() --closes open menu\\\
      elseif tMenu.rightClick.open then\\\
        renderBottomBar()\\\
        renderSideBar()\\\
      else\\\
        --executes tool function\\\
        local tool = tTool[button].tool\\\
        local color = tTool[button].color\\\
        tTool[tool](tEvent[1],button,x,y,tMode.builtDraw and color:upper() or color,tTerm.scroll.layer)\\\
      end\\\
      if tTerm.misc.forceBottomBarRender then\\\
        tTerm.misc.forceBottomBarRender = false\\\
        renderBottomBar()\\\
      end\\\
      return true\\\
    end\\\
  end,\\\
  key = function(tEvent)\\\
    local key = tEvent[2]\\\
    -- Control mappings\\\
\\\
    -- CTRL Hotkeys:\\\
    local bMenu --blueprint menu\\\
    if eventHandler.keysDown[keys.leftCtrl] then\\\
\\\
      -- New blueprint\\\
      if key == keys.n then\\\
        bMenu = loadFile(tFile.mainMenuFolder..\\\"/Blueprint.Lua\\\",progEnv)\\\
        bMenu[1].func()\\\
        return true\\\
      end\\\
\\\
      -- Open blueprint\\\
      if key == keys.o then\\\
        bMenu = loadFile(tFile.mainMenuFolder..\\\"/Blueprint.Lua\\\",progEnv)\\\
        bMenu[2].func()\\\
        return true\\\
      end\\\
\\\
      -- Save-as blueprint\\\
      if key == keys.s and eventHandler.keysDown[keys.leftShift] then\\\
        bMenu = loadFile(tFile.mainMenuFolder..\\\"/Blueprint.Lua\\\",progEnv)\\\
        bMenu[4].func()\\\
        return true\\\
      end\\\
\\\
      -- Save blueprint\\\
      if key == keys.s then\\\
        bMenu = loadFile(tFile.mainMenuFolder..\\\"/Blueprint.Lua\\\",progEnv)\\\
        bMenu[3].func()\\\
        return true\\\
      end\\\
\\\
      -- Flip blueprint\\\
      if key == keys.f then\\\
        bMenu = loadFile(tFile.mainMenuFolder..\\\"/Blueprint.Lua\\\",progEnv)\\\
        bMenu[6].func()\\\
        return true\\\
      end\\\
\\\
      -- Rotate blueprint\\\
      if key == keys.r then\\\
        bMenu = loadFile(tFile.mainMenuFolder..\\\"/Blueprint.Lua\\\",progEnv)\\\
        bMenu[7].func()\\\
        return true\\\
      end\\\
\\\
      -- Edit slot data\\\
      if key == keys.e then\\\
        bMenu = loadFile(tFile.mainMenuFolder..\\\"/Blueprint.Lua\\\",progEnv)\\\
        bMenu[8].func()\\\
        return true\\\
      end\\\
\\\
      -- Check slot usage for current layer\\\
      if key == keys.c then\\\
        bMenu = loadFile(tFile.mainMenuFolder..\\\"/Blueprint.Lua\\\",progEnv)\\\
        bMenu[11].func()\\\
        return true\\\
      end\\\
\\\
      -- Exit program\\\
      if key == keys.q then\\\
        error(\\\"Exit\\\",0)\\\
      end\\\
\\\
    end\\\
\\\
    -- Tool hotkeys:\\\
\\\
    local b = eventHandler.keysDown[keys.leftShift] and 2 or 1\\\
\\\
    if key == keys.b then\\\
      tTool.change(\\\"Brush\\\", b)\\\
      return true\\\
    end\\\
\\\
    if key == keys.f then\\\
      tTool.change(\\\"Fill\\\", b)\\\
      return true\\\
    end\\\
\\\
    if key == keys.p then\\\
      tTool.change(\\\"Pipette\\\", b)\\\
      return true\\\
    end\\\
\\\
    if key == keys.q then\\\
      tTool.change(tTool[b].prevTool, b)\\\
      return true\\\
    end\\\
\\\
    if key == keys.c then\\\
      tTool.change(\\\"hCircle\\\", 1)\\\
      tTool.change(\\\"hCircle\\\", 2)\\\
      return true\\\
    end\\\
\\\
    if key == keys.s then\\\
      tTool.change(\\\"Select\\\", 1)\\\
      tTool.change(\\\"Select\\\", 2)\\\
      return true\\\
    end\\\
\\\
    if key == keys.v then\\\
      tTool.change(\\\"fCircle\\\", 1)\\\
      tTool.change(\\\"fCircle\\\", 2)\\\
      return true\\\
    end\\\
\\\
    if key == keys.n then\\\
      tTool.change(\\\"hSquare\\\", 1)\\\
      tTool.change(\\\"hSquare\\\", 2)\\\
      return true\\\
    end\\\
\\\
    if key == keys.m then\\\
      tTool.change(\\\"fSquare\\\", 1)\\\
      tTool.change(\\\"fSquare\\\", 2)\\\
      return true\\\
    end\\\
\\\
    if key == keys.l then\\\
      tTool.change(\\\"Line\\\", 1)\\\
      tTool.change(\\\"Line\\\", 2)\\\
      return true\\\
    end\\\
\\\
    -- scroll left\\\
    if key == keys.left then\\\
      scroll(false,-1,0)\\\
      return true\\\
    \\\
    --scroll right\\\
    elseif key == keys.right then\\\
      scroll(false,1,0)\\\
      return true\\\
    \\\
    -- scroll down\\\
    elseif key == keys.down then\\\
      scroll(false,0,1)\\\
      return true\\\
\\\
    -- scroll up\\\
    elseif key == keys.up then\\\
      scroll(false,0,-1)\\\
      return true\\\
\\\
    -- change to lower Y canvas\\\
    elseif key == keys.pageDown then\\\
      scroll(tTerm.scroll.layer-1)\\\
      return true\\\
    \\\
    -- change to higher Y canvas\\\
    elseif key == keys.pageUp then\\\
      scroll(tTerm.scroll.layer+1)\\\
      return true\\\
\\\
    --change to highest Y canvas\\\
    elseif key == keys[\\\"end\\\"] then\\\
      scroll(#tBlueprint)\\\
      return true\\\
\\\
    -- change to lowest Y canvas\\\
    elseif key == keys.home then\\\
      scroll(1)\\\
      return true\\\
\\\
    -- toggle menus\\\
    elseif key == keys.tab then\\\
      toggleMenus()\\\
\\\
    -- ???\\\
    elseif key == keys.leftShift\\\
    or key == keys.rightShift then --shift\\\
      if not tTimers.shift.pressed then\\\
        tTimers.shift.pressed = true\\\
        tTimers.shift.start()\\\
        return true\\\
      end\\\
    elseif key == keys.leftCtrl then --left ctrl\\\
      if not tTimers.ctrl.lPressed then\\\
        tTimers.ctrl.lPressed = true\\\
        tTimers.ctrl.start()\\\
        return true\\\
      end\\\
    elseif tTimers.ctrl.lPressed and ctrlShortcuts.active[key] then\\\
      ctrlShortcuts.active[key](1)\\\
      return true\\\
    elseif key == keys.rightCtrl then --right ctrl\\\
      if not tTimers.ctrl.rPressed then\\\
        tTimers.ctrl.rPressed = true\\\
        tTimers.ctrl.start()\\\
        return true\\\
      end\\\
    elseif tTimers.ctrl.rPressed and ctrlShortcuts.active[key] then\\\
      ctrlShortcuts.active[key](2)\\\
      return true\\\
    end\\\
  end,\\\
  mouse_scroll = function(tEvent)\\\
    local x,y = tEvent[3],tEvent[4]\\\
    local layerBar = tBar.layerBar\\\
    if x == layerBar.sX and tMode.layerBar and  y >= layerBar.sZ and y <= layerBar.eZ then\\\
      local eLNew = layerBar.eL-tEvent[2]\\\
      local sLNew = layerBar.sL-tEvent[2]\\\
      if tBlueprint[eLNew]\\\
      and tBlueprint[sLNew] then\\\
        layerBar.eL = eLNew\\\
        layerBar.sL = sLNew\\\
        renderLayerBar()\\\
      end\\\
    else\\\
      scroll(false,0,tEvent[2])\\\
    end\\\
    return true\\\
  end\\\
}\\\
main.mouse_drag = main.mouse_click\\\
return main\\\
\",\
    [ \"TAFiles/Menus/mainMenus/Tools.Lua\" ] = \"tTool.change = function(tool,b1,b2) --tool change function\\\
  if b1 then\\\
    local deselected = tTool.deselected[tTool[b1].tool]\\\
    if deselected then\\\
      deselected()\\\
    end\\\
    tTool[b1].prevTool = tTool[b1].tool\\\
    tTool[b1].tool = tool\\\
    tTool[b1].prevDouble = tTool[b1].double\\\
    if b2 then\\\
      local deselected = tTool[b1].tool ~= tTool[b2].tool and tTool.deselected[tTool[b2].tool]\\\
      if deselected then\\\
        deselected()\\\
      end\\\
      tTool[b2].prevTool = tTool[b2].tool\\\
      tTool[b2].tool = tool\\\
      tTool[b2].prevDouble = tTool[b2].double\\\
      tTool[b2].double = true\\\
      tTool[b1].double = true\\\
    elseif tTool[b1].double then\\\
      tTool[b1].double = false\\\
      b2 = b1 == 1 and 2 or 1\\\
      tTool[b2].tool = tTool[b2].prevTool\\\
      tTool[b2].prevTool = tTool[b2].tool\\\
      tTool[b2].double = tTool[b2].prevDouble\\\
      tTool[b2].prevDouble = true\\\
    end\\\
  end\\\
  if tTool.shape.eX or tTool.clipboard or tTool.select.sX then\\\
    tTool.select = {}\\\
    tTool.clipboard = false\\\
    tTool.shape = {}\\\
    screen:clearLayer(screen.layers.toolsOverlay)\\\
  end\\\
  renderBottomBar()\\\
end\\\
\\\
local menu = {\\\
  enabled = true\\\
}\\\
codeEnv = { --Environment for the code tool\\\
  tool = {}, --holds tool codefuncs\\\
  class = { --class table for creating layers and blueprints\\\
    layer = class.layer.new,\\\
    blueprint = class.blueprint.new\\\
  },\\\
  window = setmetatable(\\\
    {},\\\
    {__index = window}\\\
  ),\\\
  debug = debug --direct inheritance,cause idgaf\\\
}\\\
--load tools\\\
for _k,file in pairs(fs.list(tFile.toolFolder)) do\\\
  if file ~= \\\"Code.Lua\\\" then\\\
    local tool = loadFile(tFile.toolFolder..\\\"/\\\"..file,progEnv)\\\
    local toolName = file:match\\\"(.+)%.Lua\\\"\\\
    tTool[toolName] = tool.renderFunc\\\
    tTool.selected[toolName] = tool.selectFunc\\\
    tTool.deselected[toolName] = tool.deselectFunc\\\
    codeEnv.tool[toolName] = tool.codeFunc\\\
    menu[tool.menuOrder] = {\\\
      name = toolName,\\\
      enabled = tool.enabled,\\\
      help = tool.help,\\\
      func = tool.selectFunc\\\
    }\\\
  end\\\
end\\\
\\\
--code tool must be loaded last\\\
local tool = loadFile(tFile.toolFolder..\\\"/Code.Lua\\\",getfenv())\\\
tTool[\\\"Code\\\"] = function(...) --since it changes, it has to be looked up on each call.\\\
  tool.renderFunc(...)\\\
end\\\
menu[tool.menuOrder] = {\\\
  name = \\\"Code\\\",\\\
  enabled = tool.enabled,\\\
  help = tool.help,\\\
  func = tool.selectFunc\\\
}\\\
return menu\\\
\",\
    [ \"TAFiles/APIs/math.lua\" ] = \"math = setmetatable(\\\
  {\\\
    round = function(num)\\\
      return math.floor(num+0.5)\\\
    end\\\
  },\\\
  {\\\
    __index = _G.math\\\
  }\\\
)\",\
    [ \"TAFiles/Classes/blueprint.Lua\" ] = \"local blueprint\\\
blueprint = { --blueprint class\\\
  new = function(data,auto)\\\
    data = data or {}\\\
    data[1] = class.layer.new(data[1])\\\
    data.orientation = data.orientation or \\\"Y\\\"\\\
    data.colorSlots = class.matrix.new(2,data.colorSlots)\\\
    if auto then\\\
      return setmetatable(\\\
        data,\\\
        {\\\
          __index = function(t,k)\\\
            if type(k) == \\\"number\\\" then\\\
              for i=#t+1,k do\\\
                t[i] = class.layer.new()\\\
              end\\\
              return t[k]\\\
            else\\\
              return blueprint[k]\\\
            end\\\
          end,\\\
          __metatable = false\\\
        }\\\
      )\\\
    else\\\
      return setmetatable(\\\
        data,\\\
        {\\\
          __index = blueprint,\\\
          __metatable = false\\\
        }\\\
      )\\\
    end\\\
  end,\\\
  save = function(blueprint,path,disableTrimming)\\\
  --saves the blueprint to the specified path\\\
    local file = class.fileTable.new()\\\
    file:write(\\\"Blueprint file for CometWolf's Turtle Architect. Pastebin code: \\\"..tPaste.program)\\\
    local blankLayer = true\\\
    for nL=#blueprint,1,-1 do\\\
      local blankX = true\\\
      file:write(\\\"L\\\"..nL)\\\
      local fX = class.fileTable.new()\\\
      for nX=class.layer.size(blueprint[nL],\\\"x\\\"),1,-1 do\\\
        local sX = \\\"\\\"\\\
        for nZ,vZ in pairs(blueprint[nL][nX]) do\\\
          if #sX < nZ then\\\
            sX = sX..string.rep(\\\" \\\",nZ-#sX-1)..vZ\\\
          else\\\
            sX = sX:sub(1,nZ-1)..vZ..sX:sub(nZ+1)\\\
          end\\\
          if blankX and vZ ~= \\\" \\\" then\\\
            blankX = false\\\
            blankLayer = false\\\
          end\\\
        end\\\
        if blankX and not disableTrimming then\\\
          blueprint[nL][nX] = nil\\\
        else\\\
          fX:write(sX,nX)\\\
        end\\\
      end\\\
      if blankLayer and not disableTrimming and nL > 1 then\\\
        file:delete()\\\
        blueprint[nL] = nil\\\
      else\\\
        file:write(fX)\\\
      end\\\
    end\\\
    file:write\\\"END\\\"\\\
    file:write(\\\"Orientation: \\\"..blueprint.orientation)\\\
    file:write((textutils.serialize(blueprint.colorSlots):gsub(\\\"\\\\n%s-\\\",\\\"\\\")))\\\
    if path == true then\\\
      return file:readAll()\\\
    end\\\
    file:save(path..\\\".TAb\\\")\\\
  end,\\\
  load = function(path)\\\
  --loads the blueprint from the specified path\\\
    local file\\\
    if type(path) == \\\"table\\\" then\\\
      local curLine = 1\\\
      file = {\\\
        readLine = function()\\\
          curLine = curLine+1\\\
          return path[curLine-1]\\\
        end,\\\
        close = function()\\\
          path = nil\\\
        end\\\
      }\\\
    else\\\
      path = path..\\\".TAb\\\"\\\
      if not fs.exists(path) then\\\
        return false\\\
      end\\\
      file = fs.open(path,\\\"r\\\")\\\
    end\\\
    read = file.readLine\\\
    if read() ~= \\\"Blueprint file for CometWolf's Turtle Architect. Pastebin code: \\\"..tPaste.program then\\\
      file.close()\\\
      return false\\\
    end\\\
    local blueprint = class.blueprint.new()\\\
    local line = read()\\\
    while line and line:match\\\"L%d+\\\" do\\\
      local layer = tonumber(line:match\\\"%d+\\\")\\\
      blueprint[layer] = class.layer.new()\\\
      line = read()\\\
      local x = 0\\\
      while line and not line:match\\\"L%d\\\" and line ~= \\\"END\\\" do\\\
        x = x+1\\\
        blueprint[layer][x] = class.x.new()\\\
        local tPoints = string.gfind(line,\\\"%S\\\")\\\
        for k,z in pairs(tPoints) do\\\
          blueprint[layer][x][z] = line:sub(z,z)\\\
        end\\\
        line = read()\\\
      end\\\
    end\\\
    local line = read()\\\
    blueprint.orientation = line:match\\\"Orientation: ([XYZ])$\\\"\\\
    if not blueprint.orientation then\\\
      blueprint.orientation = \\\"Y\\\"\\\
    else\\\
      line = read()\\\
    end\\\
    blueprint.colorSlots = class.matrix.new(2,(textutils.unserialize(line or \\\"{}\\\")))\\\
    file.close()\\\
    return blueprint\\\
  end,\\\
  size = function(blueprint)\\\
  --returns the amount of layers and the dimensions of the blueprint\\\
    local x = 0\\\
    local z = 0\\\
    for iL,vL in ipairs(blueprint) do\\\
      local lX,lZ = vL:size()\\\
      x = math.max(x,lX)\\\
      z = math.max(z,lZ)\\\
    end\\\
    return #blueprint,x,z\\\
  end,\\\
  copy = function(cBlueprint,x1,z1,x2,z2)\\\
  --returns a blueprint copy, optional coordinates\\\
    local x,z = {},{}\\\
    if not (x1 and x2) then\\\
      x.min,x.max = 1,math.huge\\\
    else\\\
      x.max = math.max(x1,x2)\\\
      x.min = math.min(x1,x2)\\\
    end\\\
    if not (z1 and z2) then\\\
      z.min,z.max = 1,math.huge\\\
    else\\\
      z.max = math.max(z1,z2)\\\
      z.min = math.min(z1,z2)\\\
    end\\\
    local copy = blueprint.new({colorSlots = table.deepCopy(cBlueprint.colorSlots)})\\\
    for nL=1,#cBlueprint do\\\
      copy[nL] = class.layer.new()\\\
      for nX,vX in pairs(cBlueprint[nL]) do\\\
        if nX >= x.min and nX <= x.max then\\\
          copy[nL][nX] = class.x.new()\\\
          for nZ,vZ in pairs(vX) do\\\
            if nZ >= z.min and nZ <= z.max then\\\
              copy[nL][nX][nZ] = vZ\\\
            end\\\
          end\\\
        end\\\
      end\\\
    end\\\
    return copy\\\
  end,\\\
  paste = function(blueprint,clipboard,pX,pZ,merge)\\\
    --combines blueprint, with an optional offset\\\
    pX = pX and pX-1 or 1\\\
    pZ = pZ and pZ-1 or 1\\\
    while #blueprint < #clipboard do\\\
      blueprint[#blueprint+1] = class.layer.new()\\\
    end\\\
    for nL = 1,#clipboard do\\\
      blueprint[nL]:paste(clipboard[nL],pX,pZ,merge)\\\
    end\\\
  end,\\\
  markBuilt = function(blueprint,x1,z1,x2,z2,clearBreak)\\\
    --marks the blueprint as built, optionally just one area\\\
    for i=1,#blueprint do\\\
      blueprint[i]:markBuilt(x1,z1,x2,z2,clearBreak)\\\
    end\\\
  end,\\\
  markUnbuilt = function(blueprint,x1,z1,x2,z2)\\\
    --marks the blueprint as unbuilt, optionally just one area\\\
    for i=1,#blueprint do\\\
      blueprint[i]:markUnbuilt(x1,z1,x2,z2)\\\
    end\\\
  end,\\\
  flipX = function(blueprint,x1,z1,x2,z2)\\\
  --flips blueprint on the x-axis, optionally just one area\\\
    for i=1,#blueprint do\\\
      blueprint[i] = blueprint[i]:flipX(x1,z1,x2,z2)\\\
    end\\\
  end,\\\
  flipZ = function(blueprint,x1,z1,x2,z2)\\\
  --flips blueprint on the Z-axis, optionally just one area\\\
    for i=1,#blueprint do\\\
      blueprint[i] = blueprint[i]:flipZ(x1,z1,x2,z2)\\\
    end\\\
  end,\\\
  rotate = function(blueprint,axis)\\\
    if blueprint.orientation == axis then\\\
      return blueprint\\\
    end\\\
    local rotated = class.blueprint.new()\\\
    local y,x,z = blueprint:size()\\\
    if axis == \\\"Y\\\" then\\\
      if blueprint.orientation == \\\"X\\\" then --X to Y\\\
        for iX = 1,x do\\\
          rotated[iX] = class.layer.new()\\\
          for iY,vL in ipairs(blueprint) do\\\
            rotated[iX][iY] = vL[iX]\\\
          end\\\
        end\\\
      else --Z to Y\\\
        for iZ = 1,z do\\\
          rotated[iZ] = class.layer.new()\\\
          local rL = rotated[iZ]\\\
          for iY,vY in ipairs(blueprint) do\\\
            for iX,vX in pairs(vY) do\\\
              rL[iX][iY] = vX[iZ]\\\
            end\\\
          end\\\
        end\\\
      end\\\
    elseif axis == \\\"X\\\" then\\\
      if blueprint.orientation == \\\"Y\\\" then --Y to X\\\
        for iX = 1,x do\\\
          rotated[iX] = class.layer.new()\\\
          local rL = rotated[iX]\\\
          for iY,vL in ipairs(blueprint) do\\\
            rL[iY] = vL[iX]\\\
          end\\\
        end\\\
      else --Z to X\\\
        for iY,vY in ipairs(blueprint) do\\\
          rotated[iY] = class.layer.new()\\\
          for iX,vX in pairs(vY) do\\\
            for iZ,vZ in pairs(vX) do \\\
              rotated[iY][iZ][iX] = vZ\\\
            end\\\
          end\\\
        end\\\
      end\\\
    elseif axis == \\\"Z\\\" then\\\
      if blueprint.orientation == \\\"X\\\" then --X to Z\\\
        for iY,vY in ipairs(blueprint) do\\\
          rotated[iY] = class.layer.new()\\\
          for iX,vX in pairs(vY) do\\\
            for iZ,vZ in pairs(vX) do \\\
              rotated[iY][iZ][iX] = vZ\\\
            end\\\
          end\\\
        end\\\
      else --Y to Z\\\
        for iZ = 1,z do\\\
          rotated[iZ] = class.layer.new()\\\
          local rL = rotated[iZ]\\\
          for iY,vY in ipairs(blueprint) do\\\
            for iX,vX in pairs(vY) do\\\
              rL[iX][iY] = vX[iZ]\\\
            end\\\
          end\\\
        end\\\
      end\\\
    end\\\
    rotated.orientation = axis\\\
    return rotated\\\
  end\\\
}\\\
return blueprint\\\
\",\
    [ \"TAFiles/Tools/Pipette.Lua\" ] = \"local tool\\\
tool = {\\\
  menuOrder = 2, --menu order, 1 being top\\\
  enabled = true,\\\
  help = function(clickButton)\\\
    local button = window.text(\\\
      \\\"The pipette is used to select a color from the canvas. Simply click on an already drawn block, and it will switch to that color as well as revert to the previously equipped tool\\\",\\\
      {\\\
        \\\"Ok\\\",\\\
        \\\"Equip\\\"\\\
      }\\\
    )\\\
    if button == \\\"Equip\\\" then\\\
      tool.selectFunc(clickButton)\\\
    end\\\
  end,\\\
  selectFunc = function(button)\\\
    tTool.change(\\\"Pipette\\\", button)\\\
  end,\\\
  renderFunc = function(event,button,x,z,color,layer)\\\
    tTool[button].color = tBlueprint[layer][x+tTerm.scroll.x][z+tTerm.scroll.z]\\\
    tTool.change(tTool[button].prevTool,button)\\\
  end\\\
}\\\
return tool\\\
\",\
    [ \"TAFiles/Tools/hCircle.Lua\" ] = \"local calcFunc = function(x1,z1,x2,z2,color)\\\
  local x = {\\\
    max = math.max(x1,x2),\\\
    min = math.min(x1,x2)\\\
  }\\\
  x.max = x.max-x.min+1\\\
  x.min = 1\\\
  x.rad = math.round((x.max-x.min)/2)\\\
  x.center = x.rad+x.min\\\
  local z = {\\\
    max = math.max(z1,z2),\\\
    min = math.min(z1,z2)\\\
  }\\\
  z.max = z.max-z.min+1\\\
  z.min = 1\\\
  z.rad = math.round((z.max-z.min)/2)\\\
  z.center = z.rad+z.min\\\
  local points = class.layer.new()\\\
  local radStep = 1/((1.5*x.rad)+(1.5*z.rad)/2)\\\
  for angle = 1, math.pi+radStep, radStep do\\\
    local pX = math.round(math.cos(angle)*x.rad)\\\
    local pZ = math.round(math.sin(angle)*z.rad)\\\
    for i=-1,1,2 do\\\
      for j=-1,1,2 do\\\
        points[x.center + i*pX][z.center + j*pZ] = color\\\
      end\\\
    end\\\
  end\\\
  return points\\\
end\\\
\\\
local tool\\\
tool = {\\\
  menuOrder = 6, --menu order, 1 being top\\\
  enabled = true,\\\
  help = function(clickButton)\\\
    local button = window.text(\\\
      \\\"The hollow circle tool lets you draw a hollow circle by left clicking a point and dragging to the opposite point. When you are satisfied, simply right click to draw it on the blueprint\\\",\\\
      {\\\
        \\\"Ok\\\",\\\
        \\\"Equip\\\"\\\
      }\\\
    )\\\
    if button == \\\"Equip\\\" then\\\
      tool.selectFunc(clickButton)\\\
    end\\\
  end,\\\
  selectFunc = function(button)\\\
    tTool.change(\\\"hCircle\\\",1,2)\\\
  end,\\\
  renderFunc = function(event,button,x,z,color)\\\
    local c = tTool.shape\\\
    if event == \\\"mouse_click\\\" then\\\
      if button == 1 then\\\
        c.sX = x+tTerm.scroll.x\\\
        c.sZ = z+tTerm.scroll.z\\\
        if c.eX then\\\
          screen:clearLayer(screen.layers.toolsOverlay)\\\
        end\\\
        c.eX = false\\\
        c.eZ = false\\\
      elseif c.eX then --button 2\\\
        c.layer = tTerm.scroll.layer\\\
        sync(c,\\\"Paste\\\")\\\
        tBlueprint[tTerm.scroll.layer]:paste(c.l,math.min(c.sX,c.eX),math.min(c.sZ,c.eZ),not tMode.overwrite)\\\
        renderArea(c.sX,c.sZ,c.eX,c.eZ,true)\\\
        tTool.shape = {}\\\
        renderToolOverlay()\\\
      end\\\
    elseif button == 1 and c.sX then --drag\\\
      c.eX = x+tTerm.scroll.x\\\
      c.eZ = z+tTerm.scroll.z\\\
      c.l = calcFunc(c.sX,c.sZ,c.eX,c.eZ,color)\\\
      renderToolOverlay()\\\
    end\\\
    if c.sX and c.sZ and c.eX and c.eZ then\\\
      tTerm.misc.csAmend = \\\"Circ: \\\" .. math.abs(c.eX - c.sX) + 1 .. \\\"x\\\" .. math.abs(c.eZ - c.sZ) + 1\\\
      tTerm.misc.forceBottomBarRender = true\\\
    end\\\
  end,\\\
  codeFunc = function(sX,sZ,eX,eZ,color,layer) --this is used by the code tool\\\
    color = color or codeEnv.click.color\\\
    layer = layer or codeEnv.click.layer\\\
    if not (sX and sZ and eX and eZ)\\\
    or not (type(sX) == \\\"number\\\" and type(sZ) == \\\"number\\\" and type(eX) == \\\"number\\\" and type(eZ) == \\\"number\\\") then\\\
      error(\\\"Expected number,number,number,number\\\",2)\\\
    end\\\
    if type(layer) == \\\"table\\\" and layer.paste then\\\
      layer:paste(calcFunc(sX,sZ,eX,eZ,color),math.min(sX,eX),math.min(sZ,eZ),not tMode.overwrite)\\\
    elseif codeEnv.settings.direct then\\\
      local c = {\\\
        sX = sX,\\\
        sZ = sZ,\\\
        eX = eX,\\\
        eZ = eZ,\\\
        layer = layer,\\\
        l = calcFunc(sX,sZ,eX,eZ,color)\\\
      }\\\
      tBlueprint[layer]:paste(c.l,math.min(sX,eX),math.min(sZ,eZ),not tMode.overwrite)\\\
      sync(c,\\\"Paste\\\")\\\
      renderArea(sX,sZ,eX,eZ,true)\\\
    elseif type(layer) == \\\"number\\\" then\\\
      codeEnv.blueprint[layer]:paste(calcFunc(sX,sZ,eX,eZ,color),math.min(sX,eX),math.min(sZ,eZ),not tMode.overwrite)\\\
    else\\\
      error(\\\"Expected layer, got \\\"..type(layer),2)\\\
    end\\\
  end\\\
}\\\
return tool\\\
\",\
    [ \"TAFiles/APIs/http.lua\" ] = \"http = setmetatable(\\\
  {\\\
    paste = {\\\
      get = function(code,file)\\\
        local paste\\\
        local response = http.get(\\\"http://pastebin.com/raw.php?i=\\\"..code)\\\
        if response then\\\
        --sucesss\\\
          if file == true then\\\
            --save to table\\\
            local tLines = {}\\\
            local line = response.readLine()\\\
            while line do\\\
              tLines[#tLines+1] = line\\\
              line = response.readLine()\\\
            end\\\
            return tLines\\\
          elseif file then\\\
            --save to file\\\
            local paste = response.readAll()\\\
            response.close()\\\
            local file = fs.open(file,\\\"w\\\")\\\
            file.write(paste)\\\
            file.close()\\\
            return true\\\
          else\\\
            --save to variable\\\
            local paste = response.readAll()\\\
            response.close()\\\
            return paste\\\
          end\\\
        else\\\
          --failure\\\
          return false\\\
        end\\\
      end,\\\
      put = function(file,name)\\\
        local upload\\\
        if type(file) == \\\"string\\\" and fs.exists(file) then\\\
        --local file\\\
          file = fs.open(\\\"file\\\",\\\"r\\\")\\\
          upload = file.readAll()\\\
          file.close()\\\
        elseif type(file) == \\\"table\\\" then\\\
        --blueprint\\\
          upload = file:save(true)\\\
        end\\\
        local key = tPaste.key\\\
        local response = http.post(\\\
          \\\"http://pastebin.com/api/api_post.php\\\",\\\
          \\\"api_option=paste&\\\"..\\\
          \\\"api_dev_key=\\\"..key..\\\"&\\\"..\\\
          \\\"api_paste_format=text&\\\"..\\\
          \\\"api_paste_name=\\\"..textutils.urlEncode(name or \\\"Untitled\\\")..\\\"&\\\"..\\\
          \\\"api_paste_code=\\\"..textutils.urlEncode(upload)\\\
        )\\\
        if response then\\\
        --sucess\\\
          local sResponse = response.readAll()\\\
          response.close()      \\\
          local sCode = string.match( sResponse, \\\"[^/]+$\\\" )\\\
          return sResponse, sCode\\\
        else\\\
          --failure\\\
          return false\\\
        end\\\
      end\\\
    }\\\
  },\\\
  {\\\
    __index = _G.http\\\
  }\\\
)\",\
    [ \"TAFiles/APIs/rednet.lua\" ] = \"rednet = setmetatable(\\\
  {\\\
    send = function(rID,event,content,success,timeout,time,failure)\\\
      content = content or {}\\\
      content.rID = type(rID) == \\\"table\\\" and rID or {[rID] = true}\\\
      content.sID = os.id\\\
      content.event = event\\\
      -- Fields used by repeaters\\\
      content.nMessageID = math.random( 1, 2147483647 )\\\
      content.nRecipient = modemChannel\\\
      -- End Fields used by repeaters\\\
      local clear\\\
      for id in pairs(content.rID) do\\\
        local timerId\\\
        if timeout then\\\
          timerId = tTimers.modemRes.start(time) --if not time, the default modemRes time is used\\\
          clear = function(rID,tID)\\\
            tTimers.modemRes.ids[tID] = nil\\\
            tTransmissions.failure.timeout[tID] = nil\\\
            tTransmissions.failure[event][rID] = nil\\\
            tTransmissions.success[event][rID] = nil\\\
          end\\\
          tTransmissions.failure.timeout[timerId] = function()\\\
            clear(id,timerId)\\\
            timeout(id)\\\
          end\\\
        end\\\
        clear = clear or function(rID) --different clear if there is no timeout function\\\
          tTransmissions.failure[event][rID] = nil\\\
          tTransmissions.success[event][rID] = nil\\\
        end\\\
        tTransmissions.success[event][id] = (\\\
          success \\\
          and function(data)\\\
            clear(id,timerId)\\\
            success(id,data)\\\
          end\\\
          or function() \\\
            clear(id,timerId)\\\
          end\\\
        )\\\
        tTransmissions.failure[event][rID] = (\\\
          failure\\\
          and function()\\\
            clear(id,timerId)\\\
            failure(id)\\\
          end\\\
          or clear\\\
        )\\\
      end\\\
      modem.transmit(\\\
        modemChannel,\\\
        modemChannel,\\\
        content\\\
      )\\\
      modem.transmit( -- Also transmit on the repeater channel\\\
        65533,\\\
        modemChannel,\\\
        content\\\
      )\\\
    end,\\\
    connected = { --connected computers\\\
      amount = 0,\\\
      ids = {\\\
        \\\
      }\\\
    },\\\
    connect = function(id,type,time,success)\\\
      rednet.send(\\\
        id,\\\
        \\\"Init connection\\\",\\\
        {\\\
          type = type,\\\
          turtle = turtle and true\\\
        },\\\
        function(id,data)\\\
          rednet.connected.ids[id] = true\\\
          rednet.connected.amount = rednet.connected.amount+1\\\
          --tTimers.connectionPing.start()\\\
          if success then\\\
            success(id,data)\\\
          end\\\
        end,\\\
        function(id)\\\
          window.text(\\\"Failed to connect to computer ID \\\"..id..\\\".\\\")\\\
        end,\\\
        time,\\\
        function(id)\\\
          window.text(\\\"Computer ID \\\"..id..\\\" denied your connection request\\\")\\\
        end\\\
      )\\\
    end,\\\
    disconnect = function(ids)\\\
      ids = type(ids) == \\\"table\\\" and ids or {[ids] = true}\\\
      rednet.send(ids,\\\"Close connection\\\")\\\
      local idsLoop = {}\\\
      for id in pairs(ids) do\\\
        idsLoop[#idsLoop+1] = id\\\
      end\\\
      for i = 1,#idsLoop do\\\
        local id = idsLoop[i]\\\
        rednet.connected.ids[id] = nil\\\
        rednet.connected.amount = rednet.connected.amount-1\\\
        if tMode.sync.ids[id] then\\\
          tMode.sync.turtles = tMode.sync.ids[id] == \\\"turtle\\\" and tMode.sync.turtles-1 or tMode.sync.turtles\\\
          tMode.sync.ids[id] = nil\\\
          tMode.sync.amount = tMode.sync.amount-1\\\
        end\\\
      end\\\
    end\\\
  },\\\
  {\\\
  __index = _G.rednet\\\
  }\\\
)\",\
    [ \"TAFiles/APIs/os.lua\" ] = \"os = setmetatable(\\\
  {\\\
    sleepTimer = {},\\\
    sleep = function(time)\\\
      local sleeping = true\\\
      os.sleepTimer[os.startTimer(time)] = function()\\\
        sleeping = false\\\
      end\\\
      while sleeping do\\\
        eventHandler.pull()\\\
      end\\\
    end,\\\
    id = _G.os.getComputerID()\\\
  },\\\
  {\\\
    __index = _G.os\\\
  }\\\
)\",\
    [ \"TAFiles/Tools/Drag.Lua\" ] = \"local tool\\\
tool = {\\\
  menuOrder = 11, --menu order, 1 being top\\\
  enabled = true,\\\
  help = function(clickButton)\\\
    local button = window.text(\\\
      \\\"The drag tool lets you drag the view around, instead of having to use the arrow keys or mouse wheel\\\",\\\
      {\\\
        \\\"Ok\\\",\\\
        \\\"Equip\\\"\\\
      }\\\
    )\\\
    if button == \\\"Equip\\\" then\\\
      tool.selectFunc(clickButton)\\\
    end\\\
  end,\\\
  selectFunc = function(button)\\\
    tTool.change(\\\"Drag\\\",button)\\\
  end,\\\
  renderFunc = function(event,button,x,z,color)\\\
    if event == \\\"mouse_click\\\" then\\\
      tTool.dragPoint = {\\\
        x = x,\\\
        z = z\\\
      }\\\
    else --mouse drag\\\
      scroll(false,tTool.dragPoint.x-x,tTool.dragPoint.z-z)\\\
      tTool.dragPoint = {\\\
        x = x,\\\
        z = z\\\
      }\\\
    end\\\
  end\\\
}\\\
return tool\\\
\",\
    [ \"arc.lua\" ] = \"--[[\\\
--------------------------------------------------------------------------------------------------------------\\\
|                                              Turtle Architect                                              |\\\
|                                                by CometWolf                                                |\\\
--------------------------------------------------------------------------------------------------------------\\\
--------------------------------------------------------------------------------------------------------------\\\
environment init\\\
----------------------------------------------------------------------------------------------------------]]--\\\
if multishell then --disable multishell for performance reasons\\\
  term.redirect(term.native())\\\
end\\\
\\\
local env = {  --new environment\\\
  tFile = {\\\
  --file path table, edit in the File paths section\\\
    [\\\"program\\\"] = shell.getRunningProgram(), --must be done prior to changing environment\\\
  }\\\
}\\\
\\\
env.progEnv = setmetatable(env, {__index = getfenv()}) --inherit global\\\
setfenv(1, env)    --set it, now all variables are local to this script.\\\
tArg = {...} --store program arguments\\\
\\\
--[[----------------------------------------------------------------------------------------------------------\\\
File paths\\\
----------------------------------------------------------------------------------------------------------]]--\\\
tFile.folder = (tFile.program:match\\\"^(.+/).-$\\\" or \\\"\\\")..\\\"/TAFiles\\\" --program files folder\\\
tFile.classFolder = tFile.folder..\\\"/Classes\\\" --classes folder\\\
tFile.APIFolder = tFile.folder..\\\"/APIs\\\" --APIs folder\\\
tFile.functionFolder = tFile.folder..\\\"/Functions\\\" --Functions folder\\\
tFile.menuFolder = tFile.folder..\\\"/Menus\\\" --menu tables folder\\\
tFile.mainMenuFolder = tFile.menuFolder..\\\"/mainMenus\\\" --main menus folder\\\
tFile.toolFolder = tFile.folder..\\\"/Tools\\\" --tools folder\\\
tFile.eventHandlerFolder = tFile.folder..\\\"/EventHandlers\\\"\\\
tFile.cTurtle = \\\"/cTurtle\\\" --cTurtle API,downloaded automatically if missing on a turtle.\\\
tFile.settings = tFile.folder..\\\"/Settings.Lua\\\" --settings file\\\
tFile.installer = tFile.folder..\\\"/installer.Lua\\\" --github installer, used for updates\\\
tFile.log = tFile.folder..\\\"/log\\\" --error log, errors are only logged while running in auto-recovery\\\
\\\
tPaste = {\\\
--pastebin codes and functions\\\
  program = \\\"VTZ6CqWY\\\", --program installer\\\
  cTurtle = \\\"JRPN0P8x\\\", --Turtle API, downloaded automatically if needed\\\
  key = \\\"0ec2eb25b6166c0c27a394ae118ad829\\\", -- pastbin dev key, cc default\\\
}\\\
\\\
--[[----------------------------------------------------------------------------------------------------------\\\
Load class files and APIs\\\
----------------------------------------------------------------------------------------------------------]]--\\\
function loadFile(path,env,arg) --custom file loader, sets environment, handles errors and runs file and returns results\\\
  if not path then\\\
    return\\\
  end\\\
  assert(fs.exists(path),\\\"Error: Attempted to load non-existent file \\\"..path..\\\"!\\\")\\\
  local tRes = {loadfile(path)}\\\
  if not tRes[1] then\\\
    error(\\\"The following error occured while loading \\\"..path..\\\": \\\"..tRes[2],2)\\\
  end\\\
  local func = setfenv(tRes[1],env or progEnv)\\\
  tRes = {\\\
    pcall(\\\
      function()\\\
        return func(arg)\\\
      end\\\
    )\\\
  }\\\
  if not tRes[1] then\\\
    error(\\\"The following error occured while loading \\\"..path..\\\":\\\\n\\\"..tRes[2],2)\\\
  end\\\
  return unpack(tRes,2)\\\
end\\\
\\\
--load class files\\\
class = {}\\\
for _k,file in pairs(fs.list(tFile.classFolder)) do\\\
  class[file:match\\\"(.+)%.Lua\\\"] = loadFile(tFile.classFolder..\\\"/\\\"..file,progEnv)\\\
end\\\
\\\
--load APIs\\\
for _k,file in pairs(fs.list(tFile.APIFolder)) do\\\
  if not file:match\\\"glasses\\\" and not file:match\\\"window\\\" then --glasses and window API must be loaded after the settings, which is done after assorted variables are defined.\\\
    loadFile(tFile.APIFolder..\\\"/\\\"..file,progEnv)\\\
  end\\\
end\\\
\\\
--[[----------------------------------------------------------------------------------------------------------\\\
Assorted variables\\\
----------------------------------------------------------------------------------------------------------]]--\\\
tTerm = { --screen size and canvas area\\\
  screen = {},  --screen size\\\
  canvas = {},  --canvas size\\\
  scroll = {},  --canvas scroll amount\\\
  viewable = {},--currently visible canvas area\\\
  misc = {}     --other nonsense\\\
}\\\
tTerm.screen.x,tTerm.screen.y = term.getSize()\\\
tTerm.screen.xMid = math.floor(tTerm.screen.x/2) --middle of the screen sideways\\\
tTerm.screen.yMid = math.floor(tTerm.screen.y/2) --middle of the screen up and down\\\
tTerm.canvas.sX = 1 --canvas left side\\\
tTerm.canvas.eX = tTerm.screen.x-2 --canvas edge\\\
tTerm.canvas.tX = tTerm.canvas.eX-tTerm.canvas.sX+1 --canvas total length\\\
tTerm.canvas.sZ = 1 --canvas top side\\\
tTerm.canvas.eZ = tTerm.screen.y-1 --canvas bottom\\\
tTerm.canvas.tZ = tTerm.canvas.eZ-tTerm.canvas.sZ+1 --canvas total height\\\
tTerm.viewable.sX = 1 --left side of the blueprint in view\\\
tTerm.viewable.eX = tTerm.canvas.eX --edge of the blueprint in view\\\
tTerm.viewable.sZ = 1 --top side of the blueprint in view\\\
tTerm.viewable.eZ = tTerm.canvas.eZ --bottom of the blueprint in view\\\
tTerm.viewable.mX = 0 --view modifier sideways\\\
tTerm.viewable.mZ = 0 --view modifier up or down\\\
tTerm.scroll.x = 0 --canvas scroll sideways\\\
tTerm.scroll.z = 0 --canvas scroll up or down\\\
tTerm.scroll.layer = 1 --currently in view layer\\\
tTerm.color = term.isColor()\\\
tTerm.misc.csAmend = \\\"\\\" --string that shows up left of the coordString\\\
tTerm.misc.forceBottomBarRender = false --forces the bottom bar to draw, used in tools commonly\\\
tTerm.misc.csMousePos = \\\"\\\" --string that shows last mouse coordinates\\\
\\\
tOngoing = { --stores ongoing build info\\\
  dir = {}, --stores build directions\\\
  breakMode = false --whether turtle will break obstructions automatically.\\\
}\\\
\\\
screen = class.screenBuffer.new() --screen buffer, supports layers and uses custom methods, no silly redirect here.\\\
screen.layers = { --screen layers\\\
  canvas = 1,\\\
  toolsOverlay = 2,\\\
  bottomBar = 3,\\\
  sideBar = 3,\\\
  gridBorder = 3,\\\
  layerBar = 3,\\\
  menus = 4,\\\
  dialogue = 5\\\
}\\\
\\\
tBar = { --menu bar variables\\\
  menu = {\\\
    touchMap = class.matrix.new(2) --used for open menus\\\
  },\\\
  layerBar = {\\\
    --open = tMode.layerBar, change this in the settings menu. true by default\\\
    sX = tTerm.canvas.eX,\\\
    eX = tTerm.canvas.eX,\\\
    sZ = 1,\\\
    eZ = tTerm.canvas.eZ,\\\
    sL = 1,\\\
    eL = tTerm.canvas.eZ,\\\
    tSelected = {\\\
      [1] = true\\\
    },\\\
    selectedAmt = 1,\\\
    prevSelected = 1,\\\
    clipboard = false,\\\
  },\\\
  touchMap = class.matrix.new(2) --used for clicks on the side and bottom bar\\\
}\\\
\\\
tTransmissions = { --stores reaction functions to modem transmissions\\\
  success = class.matrix.new(2), --received a success response, stored by event type and sender id\\\
  failure = class.matrix.new( --received a failure response, stored by event type and sender id\\\
    2,\\\
    {\\\
      timeout = {} --timed out, stored by timer id\\\
    }\\\
  )\\\
}\\\
\\\
tIgnore = { --ids of turtles to ignore status messages from\\\
\\\
}\\\
--load settings\\\
loadFile(tFile.settings)\\\
loadFile(tFile.APIFolder..\\\"/glasses.lua\\\")\\\
loadFile(tFile.APIFolder..\\\"/window.lua\\\")\\\
\\\
--[[----------------------------------------------------------------------------------------------------------\\\
Program init\\\
----------------------------------------------------------------------------------------------------------]]--\\\
\\\
if turtle then\\\
  if not term.isColor() then\\\
    error(\\\"Turtle Architect is incompatible with regular turtles!\\\",0)\\\
  end\\\
  if not fs.exists(tFile.cTurtle) then\\\
    assert(http.paste.get(tPaste.cTurtle,tFile.cTurtle),\\\"Error: Failed to download cTurtle API\\\")\\\
  end\\\
  os.loadAPI(tFile.cTurtle)\\\
  cTurtle.tSettings.renderMove = false\\\
  if modem then --cTurtle handles modem wrapping on turtles\\\
    modem.open(modemChannel)\\\
  end\\\
  cTurtle.eventHandler[\\\"modem_message\\\"] = rednet.received\\\
elseif term.isColor() then\\\
  for k,side in pairs(peripheral.getNames()) do\\\
    local pType = peripheral.getType(side)\\\
    if pType == \\\"modem\\\"\\\
    and not modem\\\
    and peripheral.call(side,\\\"isWireless\\\") then\\\
      modem = peripheral.wrap(side)\\\
      modem.side = side\\\
      modem.open(modemChannel)\\\
    elseif pType == \\\"openperipheral_glassesbridge\\\"\\\
    and not glasses.bridge then\\\
      glasses.bridge = peripheral.wrap(side)\\\
      glasses.side = side\\\
      glasses.bridge.clear()\\\
      if glasses.screenMode:match\\\"Screen\\\" then\\\
        screen:glassInit(glasses.bridge,glasses.screen.size.x,glasses.screen.size.y,glasses.screen.pos.x,glasses.screen.pos.y)\\\
      end\\\
      if glasses.screenMode:match\\\"Log\\\" then\\\
			  glasses.log.open(glasses.log.sX,glasses.log.sY,glasses.log.eX,glasses.log.eY)\\\
        glasses.log.write(\\\"Welcome to Turtle Architect V2\\\",5)\\\
      end\\\
    end\\\
    if glasses.bridge and modem then\\\
      break\\\
    end\\\
  end\\\
  if commands then\\\
    local x,y,z = commands.getBlockPosition()\\\
    tPos = {\\\
      x = x,\\\
      z = z,\\\
      y = y\\\
    }\\\
  end\\\
else\\\
  error(\\\"Turtle Architect is incompatible with regular computers!\\\",0)\\\
end\\\
if not glasses.bridge then\\\
  glasses.screenMode = \\\"\\\"\\\
end\\\
\\\
if tArg[1] then --attempt to load argument blueprint\\\
  tBlueprint = class.blueprint.load(tArg[1]) or class.blueprint.new()\\\
  tFile.blueprint = tArg[1]\\\
else\\\
  tBlueprint = class.blueprint.new()\\\
end\\\
\\\
--load menus\\\
--tools are loaded within the Tools menu file\\\
tMenu = {}\\\
for _k,file in pairs(fs.list(tFile.menuFolder)) do\\\
  if not fs.isDir(tFile.menuFolder..\\\"/\\\"..file) then\\\
    tMenu[file:match\\\"(.+)%.Lua\\\"] = loadFile(tFile.menuFolder..\\\"/\\\"..file,progEnv)\\\
  end\\\
end\\\
\\\
--load program functions\\\
do\\\
  local tIgnore = {\\\
    [\\\"Turtle.lua\\\"] = (commands and true),\\\
    [\\\"Commands.lua\\\"] = (not commands)\\\
  }\\\
  for _k,file in pairs(fs.list(tFile.functionFolder)) do\\\
    if not tIgnore[file] then\\\
      loadFile(tFile.functionFolder..\\\"/\\\"..file,progEnv)\\\
    end\\\
  end\\\
end\\\
--[[----------------------------------------------------------------------------------------------------------\\\
Event handlers\\\
----------------------------------------------------------------------------------------------------------]]--\\\
eventHandler = loadFile(tFile.eventHandlerFolder..\\\"/eventHandler.Lua\\\")\\\
local firstRun = true\\\
local execution = function()\\\
  if not firstRun then\\\
    while rawget(screen,1) do --clear buffer for redraw, incase of crash\\\
      screen:delLayer(1)\\\
    end\\\
    if tMode.grid then\\\
      removeGrid()\\\
      renderGrid()\\\
    end\\\
    if tMode.layerBar then \\\
      closeLayerBar()\\\
      openLayerBar()\\\
    end\\\
  else\\\
    if tMode.grid then \\\
      renderGrid()\\\
    end\\\
    if tMode.layerBar then\\\
      openLayerBar()\\\
    end\\\
  end\\\
  eventHandler.switch(eventHandler.main)\\\
  tBlueprint[1] = tBlueprint[1] or class.layer.new()\\\
  tTimers.blink.start()\\\
  tTimers.blink.toggle = true\\\
  renderSideBar()\\\
  --renderBottomBar() --sidebar calls this on the first call anyways.\\\
  tBlueprint[tTerm.scroll.layer]:render()\\\
  if turtle and tArg[2] == \\\"-r\\\" then\\\
    build(tBlueprint,true)\\\
    tArg[2] = nil\\\
  end \\\
  firstRun = false\\\
  while true do\\\
    eventHandler.pull()\\\
    if eventHandler.miceDown.changed then\\\
      tTerm.misc.forceBottomBarRender = true\\\
      eventHandler.miceDown.changed = false\\\
      tTerm.misc.csMousePos = \\\"Mouse: (\\\" .. eventHandler.miceDown[1][2] .. \\\", \\\" .. eventHandler.miceDown[1][3] .. \\\")\\\"\\\
    end\\\
  end\\\
end\\\
--[[----------------------------------------------------------------------------------------------------------\\\
Error handling\\\
----------------------------------------------------------------------------------------------------------]]--\\\
local function Quit()\\\
  if tMode.sync.amount > 0 then\\\
    rednet.send(tMode.sync.ids,\\\"Sync OFF\\\")\\\
  end\\\
  if glasses.bridge then\\\
    glasses.bridge.clear()\\\
  end\\\
  if modem then\\\
    modem.close(modemChannel)\\\
  end\\\
  term.setTextColor(colors.white)\\\
  term.setBackgroundColor(colors.black)\\\
  term.clear()\\\
  term.setCursorPos(1,1)\\\
  print\\\"Thank you for using Turtle Architect, by CometWolf.\\\"\\\
  print\\\"Version modified by LDDestroier\\\"\\\
end\\\
local crashCounter = 0\\\
while true do\\\
  local tRes = {pcall(execution)}\\\
  if not tRes[1] then\\\
    if tRes[2] == \\\"Update\\\" then\\\
      os.reboot()\\\
    elseif tRes[2] == \\\"Exit\\\"\\\
    or tRes[2] == \\\"Terminated\\\" then\\\
      return Quit()\\\
    elseif tArg[2] == \\\"-r\\\" then\\\
      --recovery mode logs errors and resumes operation as normal\\\
      if crashCounter > 10 then\\\
        local button = window.text(\\\
          \\\"Crash limit exceeded, please check \\\"..tFile.log..\\\" for further details\\\",\\\
          {\\\
            \\\"Quit\\\"\\\
          }\\\
        )\\\
        return\\\
      end\\\
      local file\\\
      if not fs.exists(tFile.log) then\\\
        file = fs.open(tFile.log,\\\"w\\\")\\\
      else\\\
        file = fs.open(tFile.log,\\\"a\\\")\\\
      end\\\
      file.writeLine(tostring(tRes[2]))\\\
      file.close()\\\
      crashCounter = crashCounter+1\\\
    elseif tTerm.color then --color supported crash\\\
      local errors = \\\"\\\"\\\
      local button = window.text(\\\
        \\\"Turtle Architect has encountered an unexpected error:\\\\n\\\"..tostring(tRes[2])..\\\"\\\\n\\\\nPlease report this to CometWolf immediately!\\\",\\\
        {\\\
          \\\"Ignore\\\",\\\
          \\\"Save & quit\\\",\\\
          \\\"Quit\\\"\\\
        }\\\
      )\\\
      if button == \\\"Quit\\\" then\\\
        return Quit()\\\
      elseif button == \\\"Save & quit\\\" then\\\
        dialogue.save()\\\
        return Quit()\\\
      end\\\
    else --non color supported crash\\\
      error(tRes[2])\\\
    end\\\
  else\\\
    return tRes[2]\\\
  end\\\
end\",\
    [ \"TAFiles/Menus/mainMenus/Commands.Lua\" ] = \"local menu\\\
menu = {\\\
  enabled = commands and true,\\\
  [1] = {\\\
    name = \\\"Scan construct...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Scans an already built structure and imports it into TA. Block colors will be random.\\\"\\\
    end,\\\
    func = function()\\\
      scan()\\\
    end\\\
  },\\\
  [2] = {\\\
    name = \\\"Build blueprint...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Begins construction of the currently loaded blueprint, missing build parameters will be requested as well\\\"\\\
    end,\\\
    func = function()\\\
      build(tBlueprint)\\\
    end\\\
  },\\\
  [3] = {\\\
    name = \\\"Remove construct...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Uses air instead of blocks to build the loaded blueprint. Mainly used to remove already built structures.\\\"\\\
    end,\\\
    func = function()\\\
      build(tBlueprint,true)\\\
    end\\\
  },\\\
}\\\
return menu\\\
\",\
    [ \"TAFiles/APIs/glasses.lua\" ] = \"--The actual glasses table is defined in the settings file, the screen functions are part of the screenBuffer class\\\
glasses.log.open = function(sX,sY,eX,eY)\\\
  glasses.lines = {\\\
    background = glasses.bridge.addBox(sX,eY-1,eX-sX,1,tColors.glass.log,glasses.log.opacity)\\\
  }\\\
  glasses.lines.background.setZ(1)\\\
  for i = eY-10,sY,-10 do\\\
    glasses.lines[#glasses.lines+1] = glasses.bridge.addText(sX+1,i+1,\\\" \\\",tColors.glass.logText)\\\
    local line = glasses.lines[#glasses.lines]\\\
    line.setZ(2)\\\
    line.setAlpha(glasses.log.opacity)\\\
	end\\\
  local file = class.fileTable.new(tFile.settings)\\\
  local line = file:find(\\\"  log = { --where to render the message bar\\\",true)\\\
  file:write(\\\
[[    sX = ]]..sX..[[,\\\
    sY = ]]..sY..[[,\\\
    eX = ]]..eX..[[,\\\
    eY = ]]..eY..[[,]],\\\
    line+1\\\
  )\\\
  file:save()\\\
	glasses.lineLength = math.floor((eX-sX)/5)\\\
  glasses.log.refresh()\\\
end\\\
\\\
glasses.log.write = function(text,time)\\\
  local timerId = tTimers.display.start()\\\
  local logLine = {text = text,visible = true}\\\
  table.insert(glasses.log,1,logLine)\\\
  glasses.log.timers[tTimers.display.start(time)] = function()\\\
    logLine.visible = false\\\
  end\\\
  glasses.log[glasses.log.maxSize+1] = nil\\\
  if glasses.screenMode:match\\\"Log\\\" then\\\
    glasses.log.refresh()\\\
  end\\\
end\\\
\\\
glasses.log.refresh = function()\\\
  local curLine = 1\\\
	local curLog = 1\\\
  while #glasses.lines >= curLine do\\\
    while glasses.log[curLog] and not glasses.log[curLog].visible do\\\
      curLog = curLog+1\\\
    end\\\
    if not glasses.log[curLog] then\\\
      break\\\
    end\\\
	  local text = glasses.log[curLog].text\\\
    if not text then \\\
      break\\\
    end\\\
    local tLines = string.lineFormat(text,glasses.lineLength)\\\
    for i=#tLines,1,-1 do\\\
      glasses.lines[curLine].setText(tLines[i])\\\
      curLine = curLine+1\\\
      if not glasses.lines[curLine] then\\\
        break\\\
      end\\\
    end\\\
    curLog = curLog+1\\\
  end\\\
  for i=curLine,#glasses.lines do\\\
    glasses.lines[i].setText\\\"\\\"\\\
  end\\\
  local background = glasses.lines.background\\\
  local upper = glasses.log.eY-(10*(curLine-1))\\\
  background.setY(upper)\\\
  background.setHeight(glasses.log.eY-upper)\\\
end\\\
\\\
glasses.log.setOpacity = function(opacity)\\\
  glasses.lines.background.setOpacity(opacity)\\\
  for i=1,#glasses.lines do\\\
    glasses.lines[i].setAlpha(opacity)\\\
  end\\\
  local file = class.fileTable.new(tFile.settings)\\\
  local line = file:find(\\\"    opacity = %d%.?%d?%d?d?, %-%-log transparency\\\")\\\
  file:write(\\\"    opacity = \\\"..opacity..\\\", --log transparency\\\",line)\\\
  file:save()\\\
end\\\
\\\
glasses.log.close = function()\\\
  glasses.log.lines.background.delete()\\\
	for i=1,#glasses.log.lines do\\\
    glasses.log.lines[i].delete()\\\
	end\\\
	glasses.log.lines = nil\\\
end\",\
    [ \"TAFiles/Menus/mainMenus/Layer.Lua\" ] = \"local menu\\\
menu = {\\\
  enabled = function()\\\
    return not tMode.layerBar\\\
  end,\\\
  [1] = {\\\
    name = \\\"Create new...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Creates a new blank layer\\\"\\\
    end,\\\
    func = function()\\\
      local button, tRes, reInput = window.text(\\\
        \\\"Create new layer...\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"New layer\\\",\\\
            value = string.format(#tBlueprint+1),\\\
            accepted = \\\"%d\\\"\\\
          }\\\
        },\\\
        false,\\\
        true\\\
      )\\\
      while button ~= \\\"Cancel\\\" do\\\
        local newLayer = tRes[\\\"New layer\\\"]\\\
        if not newLayer then\\\
          button,tRes,reInput = reInput(\\\"Missing layer parameter!\\\")\\\
        elseif tBlueprint[newLayer] then\\\
          button = window.text(\\\
            \\\"Layer \\\"..newLayer..\\\" already exists!\\\\nOverwrite?\\\",\\\
            {\\\
              \\\"Cancel\\\",\\\
              \\\"Overwrite\\\"\\\
            }\\\
          )\\\
          if button == \\\"Overwrite\\\" then\\\
            break\\\
          end\\\
          button,tRes,reInput = reInput(\\\"Overwrite of \\\"..newLayer..\\\" Cancelled. Input new layer number\\\")\\\
        else\\\
          break\\\
        end\\\
      end\\\
      if button ~= \\\"Cancel\\\" then\\\
        while #tBlueprint < newLayer do\\\
          tBlueprint[#tBlueprint+1] = class.layer.new()\\\
        end\\\
        tTerm.scroll.layer = newLayer\\\
        scroll()\\\
        sync({layer = newLayer},\\\"Layer add\\\")\\\
        return\\\
      end\\\
    end\\\
  },\\\
  [2] = {\\\
    name = \\\"Import...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Import layers from another blueprint into this one\\\"\\\
    end,\\\
    func = function()\\\
      local button, tRes, reInput = window.text(\\\
        \\\"Import layers from another blueprint\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\",\\\
          \\\"Pastebin\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"Blueprint\\\",\\\
            value = \\\"/\\\",\\\
            accepted = \\\".\\\"\\\
          },\\\
          {\\\
            name = \\\"From\\\",\\\
            value = 1,\\\
            accepted = \\\"%d\\\"\\\
          },\\\
          {\\\
            name = \\\"To\\\",\\\
            value = 1,\\\
            accepted = \\\"%d\\\"\\\
          },\\\
          {\\\
            name = \\\"Into\\\",\\\
            value = #tBlueprint+1,\\\
            accepted = \\\"%d\\\"\\\
          },\\\
        },\\\
        false,\\\
        true\\\
      )\\\
      while button ~= \\\"Cancel\\\" do\\\
        local iBlueprint\\\
        local fileName = tRes.Blueprint\\\
        if not fileName then\\\
          if button == \\\"Pastebin\\\" then\\\
            button,tRes,reInput = reInput\\\"Pastebin code parameter missing!\\\"\\\
          else\\\
            button,tRes,reInput = reInput\\\"Import blueprint parameter missing!\\\"\\\
          end\\\
        elseif not tRes.From then\\\
          button,tRes,reInput = reInput\\\"From layer parameter missing!\\\"\\\
        elseif not tRes.To then\\\
          button,tRes,reInput = reInput\\\"To layer parameter missing!\\\"\\\
        elseif not tRes.Into then\\\
          button,tRes,reInput = reInput\\\"Into layer parameter missing!\\\"\\\
        elseif button == \\\"Pastebin\\\" then\\\
          local paste = {}\\\
          http.request(\\\"http://pastebin.com/raw.php?i=\\\"..fileName)\\\
          local dlStatus = window.text(\\\
            {\\\
              {\\\
                text = \\\"Downloading \\\"..fileName..\\\".\\\",\\\
                renderTime = 0.2\\\
              },\\\
              {\\\
                text = \\\"Downloading \\\"..fileName..\\\"..\\\",\\\
                renderTime = 0.2\\\
              },\\\
              {\\\
                text = \\\"Downloading \\\"..fileName..\\\"...\\\",\\\
                renderTime = 0.2\\\
              },\\\
            },\\\
            {\\\
              \\\"Cancel\\\"\\\
            },\\\
            nil,\\\
            {\\\
              http_success = function(tEvent)\\\
                local web = tEvent[3]\\\
                local line = web.readLine()\\\
                while line do\\\
                  paste[#paste+1] = line\\\
                  line = web.readLine()\\\
                end\\\
                web.close()\\\
                return \\\"Success\\\"\\\
              end,\\\
              http_failure = function(tEvent)\\\
                button,tRes,reInput = reInput(\\\"Pastebin download of \\\"..fileName..\\\" failed!\\\")\\\
                return \\\"Failure\\\"\\\
              end\\\
            }\\\
          )\\\
          if dlStatus == \\\"Success\\\" then\\\
            iBlueprint = tBlueprint.load(paste)\\\
            button = dlStatus\\\
          end\\\
        else\\\
          iBlueprint = tBlueprint.load(fileName)\\\
          if not fs.exists(fileName) then\\\
            button,tRes,reInput = reInput(fileName..\\\" does not exist!\\\")\\\
          else\\\
            button = \\\"Success\\\"\\\
          end\\\
        end\\\
        if button == \\\"Success\\\" then\\\
          if not iBlueprint then\\\
            button,tRes,reInput = reInput(fileName..\\\" is not a blueprint file!\\\")\\\
          elseif not iBlueprint[tRes.To] then\\\
            button,tRes,reInput = reInput(\\\"The layer \\\"..tRes.To..\\\" does not exist in the blueprint \\\"..tRes.Blueprint..\\\"!\\\")\\\
          elseif tBlueprint[tRes.Into] then\\\
            local button2 = window.text(\\\
              \\\"Layers already exist in the range \\\"..tRes.Into..\\\"-\\\"..tRes.Into+(tRes.To-tRes.From)..\\\" in the current blueprint!\\\",\\\
              {\\\
                \\\"Cancel\\\",\\\
                \\\"Overwrite\\\",\\\
                \\\"Insert\\\"\\\
              }\\\
            )\\\
            button = (button2 == \\\"cancel\\\") and reInput\\\"Import layers from another blueprint\\\" or button2\\\
          elseif button == \\\"Overwrite\\\"\\\
          or button == \\\"Success\\\" then\\\
            while #tBlueprint < tRes.Into do\\\
              tBlueprint[#tBlueprint+1] = class.layer.new()\\\
            end\\\
            for i=tRes.From,tRes.To do\\\
              local layer = tRes.Into+i-tRes.From\\\
              tBlueprint[layer] = iBlueprint[i]:copy()\\\
            end\\\
            scroll()\\\
            sync({blueprint = tBlueprint,blueprintName = tFile.blueprint},\\\"Blueprint load\\\")\\\
            return\\\
          elseif button == \\\"Insert\\\" then\\\
            while #tBlueprint < tRes.Into do\\\
              tBlueprint[#tBlueprint+1] = class.layer.new()\\\
            end\\\
            for i=tRes.From,tRes.To do\\\
              local layer = tRes.Into+i-tRes.From\\\
              table.insert(tBlueprint,iBlueprint[i]:copy(),layer)\\\
            end\\\
            scroll()\\\
            sync({blueprint = tBlueprint,blueprintName = tFile.blueprint},\\\"Blueprint load\\\")\\\
            return\\\
          end\\\
        end\\\
      end\\\
    end\\\
  },\\\
  [3] = {\\\
    name = \\\"Delete current\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Deletes the currently selected layer\\\"\\\
    end,\\\
    func = function()\\\
      local delLayer = tTerm.scroll.layer\\\
      local button, tRes = window.text(\\\
        \\\"Are you sure you wish to delete layer \\\"..delLayer..\\\"?\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        }\\\
      )\\\
      while button ~= \\\"Cancel\\\" do\\\
        if delLayer == 1 and #tBlueprint == 1 then\\\
          tBlueprint[1] = tBlueprint[1].new()\\\
        else\\\
          table.remove(tBlueprint,delLayer)\\\
        end\\\
        tTerm.scroll.layer = math.max(tTerm.scroll.layer-1,1)\\\
        scroll()\\\
        sync({layer = delLayer},\\\"Layer delete\\\")\\\
        return\\\
      end\\\
    end\\\
  },\\\
  [4] = {\\\
    name = \\\"Delete range...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Deletes a specified set of layers, aswell as moving any existant layers down to fill the gap\\\"\\\
    end,\\\
    func = function()\\\
      local button, tRes, reInput = window.text(\\\
        \\\"Delete layer range\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"From\\\",\\\
            value = tTerm.scroll.layer,\\\
            accepted = \\\"%d\\\"\\\
          },\\\
          {\\\
            name = \\\"To\\\",\\\
            value = #tBlueprint,\\\
            accepted = \\\"%d\\\"\\\
          },\\\
        },\\\
        false,\\\
        true\\\
      )\\\
      while button ~= \\\"Cancel\\\" do\\\
        local from,to = tRes.From,tRes.To\\\
        if not from then\\\
          button,tRes,reInput = reInput\\\"Missing starting layer parameter!\\\"\\\
        elseif not to then\\\
          button,tRes,reInput = reInput\\\"Missing to layer parameter!\\\"\\\
        elseif from > to\\\
        or from < 1 then\\\
          button,tRes,reInput = reInput(\\\"Invalid layer range \\\"..from..\\\"-\\\"..to)\\\
        else\\\
          for i=tRes.From,tRes.To do\\\
            if i == 1 and #tBlueprint == 1 then\\\
              tBlueprint[1] = tBlueprint[1].new()\\\
            else\\\
              table.remove(tBlueprint,tRes.From)\\\
            end\\\
          end\\\
          tTerm.scroll.layer = math.min(tTerm.scroll.layer,#tBlueprint)\\\
          scroll()\\\
          sync({from = tRes.From,to = tRes.To},\\\"Layer delete\\\")\\\
          return\\\
        end\\\
      end\\\
    end\\\
  },\\\
  [5] = {\\\
    name = \\\"Move to...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Move the currently selected layer\\\"\\\
    end,\\\
    func = function()\\\
      local curLayer = tTerm.scroll.layer\\\
      local button, tRes, reInput = window.text(\\\
        \\\"Move current layer(\\\"..curLayer..\\\")\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"To\\\",\\\
            value = curLayer,\\\
            accepted = \\\"%d\\\"\\\
          }\\\
        },\\\
        false,\\\
        true\\\
      )\\\
      while button ~= \\\"Cancel\\\" do\\\
        if not tRes.To then\\\
          button,tRes,reInput = reInput\\\"Missing move to layer parameter!\\\"\\\
        elseif tRes.To < 1 then\\\
          button,tRes,reInput = reInput(\\\"Invalid layer number \\\"..tRes.To)\\\
        elseif tBlueprint[tRes.To] then\\\
          local button2 = window.text(\\\
            \\\"The layer \\\"..tRes.To..\\\" already exists!\\\",\\\
            {\\\
              \\\"Cancel\\\",\\\
              \\\"Overwrite\\\",\\\
              \\\"Insert\\\",\\\
            }\\\
          )\\\
          button = (button2 == \\\"Cancel\\\") and \\\"reinput\\\" or button2\\\
        elseif button == \\\"Ok\\\"\\\
        or button == \\\"Overwrite\\\" then\\\
          while #tBlueprint < tRes.To do\\\
            tBlueprint[#tBlueprint+1] = class.layer.new()\\\
          end\\\
          tBlueprint[tRes.To] = tBlueprint[curLayer]:copy()\\\
          tBlueprint[curLayer] = class.layer.new()\\\
          scroll()\\\
          sync({blueprint = tBlueprint,blueprintName = tFile.blueprint},\\\"Blueprint load\\\")\\\
          return\\\
        elseif button == \\\"Insert\\\" then\\\
          while #tBlueprint < tRes.To do\\\
            tBlueprint[#tBlueprint+1] = class.layer.new()\\\
          end\\\
          table.insert(tBlueprint, tBlueprint[curLayer]:copy(), tRes.To)\\\
          tBlueprint[curLayer] = class.layer.new()\\\
          scroll()\\\
          sync({blueprint = tBlueprint,blueprintName = tFile.blueprint},\\\"Blueprint load\\\")\\\
          return\\\
        end\\\
      end\\\
    end\\\
  },\\\
  [6] = {\\\
    name = \\\"Move range...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Move a set of layers\\\"\\\
    end,\\\
    func = function()\\\
      local button, tRes, reInput = window.text(\\\
        \\\"Move layer range\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"From\\\",\\\
            value = tTerm.scroll.layer,\\\
            accepted = \\\"%d\\\"\\\
          },\\\
          {\\\
            name = \\\"To\\\",\\\
            value = #tBlueprint,\\\
            accepted = \\\"%d\\\"\\\
          },\\\
          {\\\
            name = \\\"Into\\\",\\\
            value = #tBlueprint+1,\\\
            accepted = \\\"%d\\\"\\\
          },\\\
        },\\\
        false,\\\
        true\\\
      )\\\
      while button ~= \\\"Cancel\\\" do\\\
        local from,to = tRes.From,tRes.To\\\
        if not from then\\\
          button,tRes,reInput = reInput\\\"Missing starting layer parameter!\\\"\\\
        elseif not to then\\\
          button,tRes,reInput = reInput\\\"Missing to layer parameter!\\\"\\\
        elseif from > to\\\
        or from < 1 then\\\
          button,tRes,reInput = reInput(\\\"Invalid layer range \\\"..from..\\\"-\\\"..to)\\\
        elseif not tRes.Into then\\\
          button,tRes,reInput = reInput\\\"Missing move into layer parameter!\\\"\\\
        elseif tRes.Into < 1 then\\\
          button,tRes,reInput = reInput(\\\"Invalid move to layer \\\"..tRes.Into) \\\
        elseif tBlueprint[tRes.Into] then\\\
          local button2 = window.text(\\\
            \\\"Layers already exist in the range \\\"..tRes.Into..\\\"-\\\"..tRes.Into+(tRes.To-tRes.From)..\\\"!\\\",\\\
            {\\\
              \\\"Cancel\\\",\\\
              \\\"Overwrite\\\",\\\
              \\\"Insert\\\"\\\
            }\\\
          )\\\
          button = (button2 == \\\"cancel\\\") and \\\"reinput\\\" or button2\\\
        elseif button == \\\"Ok\\\"\\\
        or button == \\\"Overwrite\\\" then\\\
          while #tBlueprint < tRes.Into do\\\
            tBlueprint[#tBlueprint+1] = class.layer.new()\\\
          end\\\
          for i=tRes.From,tRes.To do\\\
            local layer = tRes.Into+i-tRes.From\\\
            tBlueprint[layer] = tBlueprint[i]:copy()\\\
            tBlueprint[i] = class.layer.new()\\\
          end\\\
          scroll()\\\
          sync({blueprint = tBlueprint,blueprintName = tFile.blueprint},\\\"Blueprint load\\\")\\\
          return\\\
        elseif button == \\\"Insert\\\" then\\\
          while #tBlueprint < tRes.Into do\\\
            tBlueprint[#tBlueprint+1] = class.layer.new()\\\
          end\\\
          for i=tRes.From,tRes.To do\\\
            local layer = tRes.Into+i-tRes.From\\\
            table.insert(tBlueprint,iBlueprint[i]:copy(),layer)\\\
            tBlueprint[i] = class.layer.new()\\\
          end\\\
          scroll()\\\
          sync({blueprint = tBlueprint,blueprintName = tFile.blueprint},\\\"Blueprint load\\\")\\\
          return\\\
        end\\\
      end\\\
    end\\\
  },\\\
  [7] = {\\\
    name = \\\"Copy to...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Make a copy of the currently selected layer\\\"\\\
    end,\\\
    func = function()\\\
      local curLayer = tTerm.scroll.layer\\\
      local button, tRes, reInput = window.text(\\\
        \\\"Copy current layer(\\\"..curLayer..\\\")\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"To\\\",\\\
            value = curLayer+1,\\\
            accepted = \\\"%d\\\"\\\
          }\\\
        },\\\
        false,\\\
        true\\\
      )\\\
      while button ~= \\\"Cancel\\\" do\\\
        if button == \\\"reinput\\\" then\\\
          button, tRes, reInput = reInput(\\\"Copy current layer(\\\"..curLayer..\\\")\\\")\\\
        elseif not tRes.To then\\\
          button,tRes,reInput = reInput\\\"Missing copy to layer parameter!\\\"\\\
        elseif tRes.To < 1 then\\\
          button,tRes,reInput = reInput(\\\"Invalid copy to layer \\\"..tRes.To)\\\
        elseif button == \\\"Ok\\\" and tBlueprint[tRes.To] then\\\
          local button2 = window.text(\\\
            \\\"The layer \\\"..tRes.To..\\\" already exists!\\\",\\\
            {\\\
              \\\"Cancel\\\",\\\
              \\\"Overwrite\\\",\\\
              \\\"Insert\\\",\\\
            }\\\
          )\\\
          button = (button2 == \\\"Cancel\\\") and \\\"reinput\\\" or button2\\\
        elseif button == \\\"Ok\\\"\\\
        or button == \\\"Overwrite\\\" then\\\
          tBlueprint[tRes.To] = tBlueprint[curLayer]:copy()\\\
          while #tBlueprint < tRes.To do\\\
            tBlueprint[#tBlueprint+1] = class.layer.new()\\\
          end\\\
          sync({blueprint = tBlueprint,blueprintName = tFile.blueprint},\\\"Blueprint load\\\")\\\
          return\\\
        elseif button == \\\"Insert\\\" then\\\
          table.insert(tBlueprint, tBlueprint[curLayer]:copy(), tRes.To)\\\
          while #tBlueprint < tRes.To do\\\
            tBlueprint[#tBlueprint+1] = class.layer.new()\\\
          end\\\
          sync({blueprint = tBlueprint,blueprintName = tFile.blueprint},\\\"Blueprint load\\\")\\\
          return\\\
        end\\\
      end\\\
    end\\\
  },\\\
  [8] = {\\\
    name = \\\"Stretch copy...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Make multiple copies of the currently selected layer\\\"\\\
    end,\\\
    func = function()\\\
      local button, tRes, reInput = window.text(\\\
        \\\"Stretch copy current layer(\\\"..tTerm.scroll.layer..\\\") across\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"From\\\",\\\
            value = tTerm.scroll.layer,\\\
            accepted = \\\"%d\\\"\\\
          },\\\
          {\\\
            name = \\\"To\\\",\\\
            value = #tBlueprint,\\\
            accepted = \\\"%d\\\"\\\
          },\\\
        },\\\
        false,\\\
        true\\\
      )\\\
      while button ~= \\\"Cancel\\\" do\\\
        local from,to = tRes.From,tRes.To\\\
        if not from then\\\
          button,tRes,reInput = reInput\\\"Missing starting layer parameter!\\\"\\\
        elseif not to then\\\
          button,tRes,reInput = reInput\\\"Missing to layer parameter!\\\"\\\
        elseif from > to\\\
        or from < 1 then\\\
          button,tRes,reInput = reInput(\\\"Invalid layer range \\\"..from..\\\"-\\\"..to)\\\
        elseif tBlueprint[tRes.From] and button == \\\"Ok\\\" then\\\
          local button2 = window.text(\\\
            \\\"Layers already exist in the range \\\"..tRes.From..\\\"-\\\"..tRes.To..\\\"!\\\",\\\
            {\\\
              \\\"Cancel\\\",\\\
              \\\"Overwrite\\\",\\\
              \\\"Insert\\\"\\\
            }\\\
          )\\\
          button = (button2 == \\\"Cancel\\\") and \\\"reinput\\\" or button2\\\
          if button == \\\"reinput\\\" then\\\
            button,tRes,reInput = reInput(\\\"Stretch copy current layer(\\\"..tTerm.scroll.layer..\\\") across\\\")\\\
          end\\\
        elseif button == \\\"Ok\\\"\\\
        or button == \\\"Overwrite\\\" then\\\
          for i=tRes.From,tRes.To do\\\
            tBlueprint[i] = tBlueprint[tTerm.scroll.layer]:copy()\\\
          end\\\
          while #tBlueprint < tRes.From do\\\
            tBlueprint[#tBlueprint+1] = class.layer.new()\\\
          end\\\
          scroll()\\\
          sync({blueprint = tBlueprint,blueprintName = tFile.blueprint},\\\"Blueprint load\\\")\\\
          return\\\
        elseif button == \\\"Insert\\\" then\\\
          for i=tRes.From,tRes.To do\\\
            table.insert(tBlueprint,tBlueprint[tTerm.scroll.layer]:copy(),i)\\\
          end\\\
          while #tBlueprint < tRes.From do\\\
            tBlueprint[#tBlueprint+1] = class.layer.new()\\\
          end\\\
          scroll()\\\
          sync({blueprint = tBlueprint,blueprintName = tFile.blueprint},\\\"Blueprint load\\\")\\\
          return\\\
        end\\\
      end\\\
    end\\\
  },\\\
  [9] = {\\\
    name = \\\"Copy range...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Copy a set of layers\\\"\\\
    end,\\\
    func = function()\\\
      local button, tRes, reInput = window.text(\\\
        \\\"Copy layer range\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"From\\\",\\\
            value = tTerm.scroll.layer,\\\
            accepted = \\\"%d\\\"\\\
          },\\\
          {\\\
            name = \\\"To\\\",\\\
            value = #tBlueprint,\\\
            accepted = \\\"%d\\\"\\\
          },\\\
          {\\\
            name = \\\"Into\\\",\\\
            value = #tBlueprint+1,\\\
            accepted = \\\"%d\\\"\\\
          },\\\
        },\\\
        false,\\\
        true\\\
      )\\\
      while button ~= \\\"Cancel\\\" do\\\
        local from,to = tRes.From,tRes.To\\\
        if button == \\\"reinput\\\" then\\\
          button,tRes,reInput = reInput\\\"Copy layer range\\\"\\\
        elseif not from then\\\
          button,tRes,reInput = reInput\\\"Missing starting layer parameter!\\\"\\\
        elseif not to then\\\
          button,tRes,reInput = reInput\\\"Missing to layer parameter!\\\"\\\
        elseif from > to\\\
        or from < 1 then\\\
          button,tRes,reInput = reInput(\\\"Invalid layer range \\\"..from..\\\"-\\\"..to)\\\
        elseif not tRes.Into then\\\
          button,tRes,reInput = reInput\\\"Missing copy into layer parameter!\\\"\\\
        elseif tRes.Into < 1 then\\\
          button,tRes,reInput = reInput(\\\"Invalid copy to layer \\\"..tRes.Into) \\\
        elseif button == \\\"Ok\\\" and tBlueprint[tRes.Into] then\\\
          local button2 = window.text(\\\
            \\\"Layers already exist in the range \\\"..tRes.Into..\\\"-\\\"..tRes.Into+(tRes.To-tRes.From)..\\\"!\\\",\\\
            {\\\
              \\\"Cancel\\\",\\\
              \\\"Overwrite\\\",\\\
              \\\"Insert\\\"\\\
            }\\\
          )\\\
          button = (button2 == \\\"Cancel\\\") and \\\"reinput\\\" or button2\\\
        elseif button == \\\"Ok\\\"\\\
        or button == \\\"Overwrite\\\" then\\\
          while #tBlueprint < tRes.Into do\\\
            tBlueprint[#tBlueprint+1] = class.layer.new()\\\
          end\\\
          for i=tRes.From,tRes.To do\\\
            local layer = tRes.Into+i-tRes.From\\\
            tBlueprint[layer] = tBlueprint[i]:copy()\\\
          end\\\
          scroll()\\\
          sync({blueprint = tBlueprint,blueprintName = tFile.blueprint},\\\"Blueprint load\\\")\\\
          return\\\
        elseif button == \\\"Insert\\\" then\\\
          while #tBlueprint < tRes.Into do\\\
            tBlueprint[#tBlueprint+1] = class.layer.new()\\\
          end\\\
          for i=tRes.From,tRes.To do\\\
            local layer = tRes.Into+i-tRes.From\\\
            table.insert(tBlueprint,tBlueprint[i]:copy(),layer)\\\
          end\\\
          scroll()\\\
          sync({blueprint = tBlueprint,blueprintName = tFile.blueprint},\\\"Blueprint load\\\")\\\
          return\\\
        end\\\
      end\\\
    end\\\
  },\\\
  [10] = {\\\
    name = \\\"Merge...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Combine a set of layers into 1\\\"\\\
    end,\\\
    func = function()\\\
      local button, tRes, reInput = window.text(\\\
        \\\"Merge layer range\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"From\\\",\\\
            value = tTerm.scroll.layer,\\\
            accepted = \\\"%d\\\"\\\
          },\\\
          {\\\
            name = \\\"To\\\",\\\
            value = #tBlueprint,\\\
            accepted = \\\"%d\\\"\\\
          },\\\
        },\\\
        false,\\\
        true\\\
      )\\\
      while button ~= \\\"Cancel\\\" do\\\
        local from,to = tRes.From,tRes.To\\\
        if not from then\\\
          button,tRes,reInput = reInput\\\"Missing starting layer parameter!\\\"\\\
        elseif not to then\\\
          button,tRes,reInput = reInput\\\"Missing to layer parameter!\\\"\\\
        elseif from > to\\\
        or from < 1 then\\\
          button,tRes,reInput = reInput(\\\"Invalid layer range \\\"..from..\\\"-\\\"..to)\\\
        elseif not tBlueprint[to] then\\\
          button,tRes,reInput = reInput(\\\"Non-existant layer range \\\"..from..\\\"-\\\"..to..\\\".\\\\nCurrent top layer: \\\"..#tBlueprint)\\\
        else\\\
          for i=tRes.From+1,tRes.To do\\\
            tBlueprint[tRes.From]:paste(tBlueprint[tRes.From+1])\\\
            table.remove(tBlueprint,tRes.From+1)\\\
          end\\\
          scroll()\\\
          sync({blueprint = tBlueprint,blueprintName = tFile.blueprint},\\\"Blueprint load\\\")\\\
          return\\\
        end\\\
      end\\\
    end\\\
  },\\\
  [11] = {\\\
    name = \\\"Flip...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Flip the currently selected layer horizontally or vertically\\\"\\\
    end,\\\
    func = function()\\\
      local curLayer = tTerm.scroll.layer\\\
      local button = window.text(\\\
        \\\"Flip current layer\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Horizontal\\\",\\\
          \\\"Vertical\\\"\\\
        }\\\
      )\\\
      if button == \\\"Horizontal\\\" then\\\
        tBlueprint[curLayer] = tBlueprint[curLayer]:flipX()\\\
        scroll()\\\
        sync({layer = curLayer,dir = \\\"X\\\"},\\\"Flip\\\")\\\
      elseif button == \\\"Vertical\\\" then\\\
        tBlueprint[curLayer] = tBlueprint[curLayer]:flipZ()\\\
        scroll()\\\
        sync({layer = curLayer,dir = \\\"Z\\\"},\\\"Flip\\\")\\\
      end\\\
    end\\\
  },\\\
  [12] = {\\\
    name = \\\"Recolor\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Changes the color of the entire selected layer\\\"\\\
    end,\\\
    func = function()\\\
      local curLayer = tTerm.scroll.layer\\\
      local color = dialogue.selectColor(\\\"Recolor the current layer(\\\"..curLayer..\\\") to\\\")\\\
      if color ~= \\\"Cancel\\\" then\\\
        tBlueprint[curLayer]:recolor(colorKey[color])\\\
        scroll()\\\
        sync({layer = curLayer},\\\"Mark built\\\")\\\
      end\\\
    end\\\
  },\\\
  [13] = {\\\
    name = \\\"Mark built\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Mark the entire current layer as built, meaning the turtle will skip it\\\"\\\
    end,\\\
    func = function()\\\
      local curLayer = tTerm.scroll.layer\\\
      local button, tRes = window.text(\\\
        \\\"Mark the current layer(\\\"..curLayer..\\\") as built. This means the turtle will not build it.\\\\n\\\\nClear break markers?\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Yes\\\",\\\
          \\\"No\\\"\\\
        }\\\
      )\\\
      if button == \\\"Yes\\\" or button == \\\"Ok\\\" then\\\
        tBlueprint[curLayer]:markBuilt(nil,nil,nil,nil,true)\\\
        scroll()\\\
        sync({layer = curLayer,clearBreak = true},\\\"Mark built\\\")\\\
      elseif button == \\\"No\\\" then\\\
        tBlueprint[curLayer]:markBuilt()\\\
        if tMode.builtRender then\\\
          scroll()\\\
        end\\\
        sync({layer = curLayer},\\\"Mark built\\\")\\\
      end\\\
    end\\\
  },\\\
  [14] = {\\\
    name = \\\"Mark unbuilt\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Reset all build progress made on current layer\\\"\\\
    end,\\\
    func = function()\\\
      local curLayer = tTerm.scroll.layer\\\
      local button, tRes = window.text(\\\
        \\\"Mark the current layer(\\\"..curLayer..\\\") as unbuilt. This will reset any progress the turtle has made on this layer\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        }\\\
      )\\\
      if button == \\\"Ok\\\" then\\\
        tBlueprint[curLayer]:markUnbuilt()\\\
        if tMode.builtRender then\\\
          scroll()\\\
        end\\\
        sync({layer = curLayer},\\\"Mark unbuilt\\\")\\\
      end\\\
    end\\\
  },\\\
  [15] = {\\\
    name = \\\"Goto...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Scroll to given layer\\\"\\\
    end,\\\
    func = function()\\\
      local button, tRes = window.text(\\\
        \\\"Goto layer number...\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"Layer\\\",\\\
            value = string.format(tTerm.scroll.layer),\\\
            accepted = \\\"%d\\\"\\\
          }\\\
        }\\\
      )\\\
      if button == \\\"Ok\\\" then\\\
        local newLayer = tRes.Layer\\\
        while not tBlueprint[newLayer] do\\\
          local button, tRes = window.text(\\\
            \\\"The layer \\\"..newLayer..\\\" does not exist!\\\\nCurrent top layer: \\\"..#tBlueprint,\\\
            {\\\
              \\\"Cancel\\\",\\\
              \\\"Ok\\\"\\\
            },\\\
            {\\\
              {\\\
                name = \\\"Layer\\\",\\\
                value = string.format(tTerm.scroll.layer),\\\
                accepted = \\\"%d\\\"\\\
              }\\\
            }\\\
          )\\\
          if button == \\\"Cancel\\\" then\\\
            return\\\
          end\\\
          newLayer = tRes.Layer\\\
        end\\\
        scroll(newLayer,false,false,true)\\\
      end\\\
    end\\\
  },\\\
  [16] = {\\\
    name = \\\"save as paint\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Saves the current layer as a paint file\\\"\\\
    end,\\\
    func = function()\\\
      local button,tRes,reInput = window.text(\\\
        \\\"Input save path for paint conversion of layer \\\"..tTerm.scroll.layer,\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"Path\\\",\\\
            value = \\\"/\\\"\\\
          }\\\
        },\\\
        nil,\\\
        true\\\
      )\\\
      while button ~= \\\"Cancel\\\" do\\\
        if not tRes.Path or not tRes.Path:match\\\"/[^/]+$\\\" then\\\
          button,tRes,reInput = reInput\\\"Invalid path!\\\"\\\
        elseif fs.exists(tRes.Path) and button ~= \\\"Overwrite\\\" then\\\
          local button2 = window.text(\\\
            tRes.Path..\\\" already exists!\\\\nOverwrite?\\\",\\\
            {\\\
              \\\"Cancel\\\",\\\
              \\\"Overwrite\\\"\\\
            }\\\
          )\\\
          if button2 == \\\"Cancel\\\" then\\\
            button,tRes,reInput = reInput\\\"Input save path\\\"\\\
          else \\\
            button = button2\\\
          end\\\
        else\\\
          local file = class.fileTable.new(tRes.Path)\\\
          local layer = tBlueprint[tTerm.scroll.layer]\\\
          for nX = 1,layer:size(\\\"x\\\") do\\\
            local sX = \\\"\\\"\\\
            for nZ,vZ in pairs(layer[nX]) do\\\
              vZ = paintColors[vZ:lower()]\\\
              if #sX < nZ then\\\
                sX = sX..string.rep(\\\" \\\",nZ-#sX-1)..vZ\\\
              else\\\
                sX = sX:sub(1,nZ-1)..vZ..sX:sub(nZ+1)\\\
              end\\\
            end\\\
            file:write(sX,nX)\\\
          end\\\
          file:save()\\\
          return\\\
        end\\\
      end\\\
    end\\\
  },\\\
  [17] = {\\\
    name = \\\"Open layerbar\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Opens the layer bar and disables the layer menu\\\"\\\
    end,\\\
    func = function()\\\
      openLayerBar()\\\
      local file = class.fileTable.new(tFile.settings)\\\
      local line = file:find(\\\"  layerBar = false,\\\",true)\\\
      file:write(\\\"  layerBar = true,\\\",line)\\\
      file:save()\\\
    end\\\
  }\\\
}\\\
return menu\\\
\",\
    [ \"TAFiles/Tools/Line.Lua\" ] = \"local calcFunc = function(x1,z1,x2,z2,color)\\\
  local points = class.layer.new()\\\
  local xS,zS,xD,zD,xR,zR\\\
  if x1 > x2 then\\\
    xD = x1-x2\\\
    x1 = x1-x2+1\\\
    x2 = 1\\\
    xS = -1\\\
    xR = true\\\
  else\\\
    xD = x2-x1\\\
    x2 = x2-x1+1\\\
    x1 = 1\\\
    xS = 1\\\
  end\\\
  if z1 > z2 then\\\
    zD = z1-z2\\\
    z1 = z1-z2+1\\\
    z2 = 1\\\
    zS = -1\\\
    zR = true\\\
  else\\\
    zD = z2-z1\\\
    z2 = z2-z1+1\\\
    z1 = 1\\\
    zS = 1\\\
  end\\\
  if xD >= zD then\\\
    zS = zD/xD\\\
    zS = zR and -zS or zS\\\
    local iZ = z1\\\
    for iX = x1,x2,xS do\\\
      points[iX][math.round(iZ)] = color\\\
      iZ = iZ+zS\\\
    end\\\
  else\\\
    xS = xD/zD\\\
    xS = xR and -xS or xS\\\
    local iX = x1\\\
    for iZ = z1,z2,zS do\\\
      points[math.round(iX)][iZ] = color\\\
      iX = iX+xS\\\
    end\\\
  end\\\
  return  points\\\
end\\\
\\\
local tool \\\
tool = {\\\
  menuOrder = 3, --menu order, 1 being top\\\
  enabled = true,\\\
  help = function(clickButton)\\\
    local button = window.text(\\\
      \\\"The line tool lets you draw a simple line by left clicking a point and dragging to the opposite point. When you are satisfied, simply right click to draw it on the blueprint\\\",\\\
      {\\\
        \\\"Ok\\\",\\\
        \\\"Equip\\\"\\\
      }\\\
    )\\\
    if button == \\\"Equip\\\" then\\\
      tool.selectFunc(clickButton)\\\
    end\\\
  end,\\\
  selectFunc = function(button)\\\
    tTool.change(\\\"Line\\\",1,2)\\\
  end,\\\
  renderFunc = function(event,button,x,z,color,layer)\\\
    local s = tTool.shape\\\
    if event == \\\"mouse_click\\\" then\\\
      if button == 1 then\\\
        s.sX = x+tTerm.scroll.x\\\
        s.sZ = z+tTerm.scroll.z\\\
        if s.eX then\\\
          screen:clearLayer(screen.layers.toolsOverlay)\\\
        end\\\
        s.eX = false\\\
        s.eZ = false\\\
      elseif s.eX then --button 2\\\
        s.layer = tTerm.scroll.layer\\\
        sync(s,\\\"Paste\\\")\\\
        tBlueprint[tTerm.scroll.layer]:paste(s.l,math.min(s.sX,s.eX),math.min(s.sZ,s.eZ),not tMode.overwrite)\\\
        renderArea(s.sX,s.sZ,s.eX,s.eZ,true)\\\
        tTool.shape = {}\\\
        renderToolOverlay()\\\
      end\\\
    elseif button == 1 and s.sX then --drag\\\
      s.eX = x+tTerm.scroll.x\\\
      s.eZ = z+tTerm.scroll.z\\\
      s.l = calcFunc(s.sX,s.sZ,s.eX,s.eZ,color)\\\
      renderToolOverlay()\\\
    end\\\
    if s.sX and s.sZ and s.eX and s.eZ then\\\
      tTerm.misc.csAmend = \\\"Line: \\\" .. math.abs(s.eX - s.sX) + 1 .. \\\"x\\\" .. math.abs(s.eZ - s.sZ) + 1\\\
      tTerm.misc.forceBottomBarRender = true\\\
    end\\\
  end,\\\
  codeFunc = function(sX,sZ,eX,eZ,color,layer) --this is used by the code tool\\\
    color = color or codeEnv.click.color\\\
    layer = layer or codeEnv.click.layer\\\
    if not (sX and sZ and eX and eZ)\\\
    or not (type(sX) == \\\"number\\\" and type(sZ) == \\\"number\\\" and type(eX) == \\\"number\\\" and type(eZ) == \\\"number\\\") then\\\
      error(\\\"Expected number,number,number,number\\\",2)\\\
    end\\\
    if type(layer) == \\\"table\\\" and layer.paste then\\\
      layer:paste(calcFunc(sX,sZ,eX,eZ,color),math.min(sX,eX),math.min(sZ,eZ),not tMode.overwrite)\\\
    elseif codeEnv.settings.direct then\\\
      local s = {\\\
        sX = sX,\\\
        sZ = sZ,\\\
        eX = eX,\\\
        eZ = eZ,\\\
        layer = layer,\\\
        l = calcFunc(sX,sZ,eX,eZ,color)\\\
      }\\\
      tBlueprint[layer]:paste(s.l,math.min(sX,eX),math.min(sZ,eZ),not tMode.overwrite)\\\
      sync(s,\\\"Paste\\\")\\\
      renderArea(sX,sZ,eX,eZ,true)\\\
    elseif type(layer) == \\\"number\\\" then\\\
      codeEnv.blueprint[layer]:paste(calcFunc(sX,sZ,eX,eZ,color),math.min(sX,eX),math.min(sZ,eZ),not tMode.overwrite)\\\
    else\\\
      error(\\\"Expected layer, got \\\"..type(layer),2)\\\
    end\\\
  end\\\
}\\\
return tool\\\
\",\
    [ \"TAFiles/Tools/fSquare.Lua\" ] = \"local calcFunc = function(x1,z1,x2,z2,color)\\\
  local x = {\\\
    max = math.max(x1,x2),\\\
    min = math.min(x1,x2)\\\
  }\\\
  x.max = x.max-x.min+1\\\
  x.min = 1\\\
  local z = {\\\
    max = math.max(z1,z2),\\\
    min = math.min(z1,z2)\\\
  }\\\
  z.max = z.max-z.min+1\\\
  z.min = 1\\\
  local points = class.layer.new()\\\
  for iX = x.min,x.max do\\\
    for iZ = z.min,z.max do\\\
      points[iX][iZ] = color\\\
    end\\\
  end\\\
  return points\\\
end\\\
\\\
local tool \\\
tool = {\\\
  menuOrder = 5, --menu order, 1 being top\\\
  enabled = true,\\\
  help = function(clickButton)\\\
    local button = window.text(\\\
      \\\"The filled square tool lets you draw a filled square by left clicking a point and dragging to the opposite point. When you are satisfied, simply right click to draw it on the blueprint\\\",\\\
      {\\\
        \\\"Ok\\\",\\\
        \\\"Equip\\\"\\\
      }\\\
    )\\\
    if button == \\\"Equip\\\" then\\\
      tool.selectFunc(clickButton)\\\
    end\\\
  end,\\\
  selectFunc = function(button)\\\
    tTool.change(\\\"fSquare\\\",1,2)\\\
  end,\\\
  renderFunc = function(event,button,x,z,color,layer)\\\
    local s = tTool.shape\\\
    if event == \\\"mouse_click\\\" then\\\
      if button == 1 then\\\
        s.sX = x+tTerm.scroll.x\\\
        s.sZ = z+tTerm.scroll.z\\\
        if s.eX then\\\
          screen:clearLayer(screen.layers.toolsOverlay)\\\
        end\\\
        s.eX = false\\\
        s.eZ = false\\\
      elseif s.eX then --button 2\\\
        s.layer = tTerm.scroll.layer\\\
        sync(s,\\\"Paste\\\")\\\
        tBlueprint[tTerm.scroll.layer]:paste(s.l,math.min(s.sX,s.eX),math.min(s.sZ,s.eZ),not tMode.overwrite)\\\
        renderArea(s.sX,s.sZ,s.eX,s.eZ,true)\\\
        tTool.shape = {}\\\
        renderToolOverlay()\\\
      end\\\
    elseif button == 1 and s.sX then --drag\\\
      s.eX = x+tTerm.scroll.x\\\
      s.eZ = z+tTerm.scroll.z\\\
      s.l = calcFunc(s.sX,s.sZ,s.eX,s.eZ,color)\\\
      renderToolOverlay()\\\
    end\\\
    if s.sX and s.sZ and s.eX and s.eZ then\\\
      tTerm.misc.csAmend = \\\"Sqr: \\\" .. math.abs(s.eX - s.sX) + 1 .. \\\"x\\\" .. math.abs(s.eZ - s.sZ) + 1\\\
      tTerm.misc.forceBottomBarRender = true\\\
    end\\\
  end,\\\
  codeFunc = function(sX,sZ,eX,eZ,color,layer) --this is used by the code tool\\\
    color = color or codeEnv.click.color\\\
    layer = layer or codeEnv.click.layer\\\
    if not (sX and sZ and eX and eZ)\\\
    or not (type(sX) == \\\"number\\\" and type(sZ) == \\\"number\\\" and type(eX) == \\\"number\\\" and type(eZ) == \\\"number\\\") then\\\
      error(\\\"Expected number,number,number,number\\\",2)\\\
    end\\\
    if type(layer) == \\\"table\\\" and layer.paste then\\\
      layer:paste(calcFunc(sX,sZ,eX,eZ,color),math.min(sX,eX),math.min(sZ,eZ),not tMode.overwrite)\\\
    elseif codeEnv.settings.direct then\\\
      local s = {\\\
        sX = sX,\\\
        sZ = sZ,\\\
        eX = eX,\\\
        eZ = eZ,\\\
        layer = layer,\\\
        l = calcFunc(sX,sZ,eX,eZ,color)\\\
      }\\\
      tBlueprint[layer]:paste(s.l,math.min(sX,eX),math.min(sZ,eZ),not tMode.overwrite)\\\
      sync(s,\\\"Paste\\\")\\\
      renderArea(sX,sZ,eX,eZ,true)\\\
    elseif type(layer) == \\\"number\\\" then\\\
      codeEnv.blueprint[layer]:paste(calcFunc(sX,sZ,eX,eZ,color),math.min(sX,eX),math.min(sZ,eZ),not tMode.overwrite)\\\
    else\\\
      error(\\\"Expected layer, got \\\"..type(layer),2)\\\
    end\\\
  end\\\
}\\\
return tool\\\
\",\
    [ \"TAFiles/APIs/string.lua\" ] = \"string = setmetatable(\\\
  {\\\
    gfind = function(sString,pattern)\\\
      --returns a table of pattern occurrences in a string\\\
      local tRes = {}\\\
      local point = 1\\\
      while point <= #sString do\\\
        tRes[#tRes+1],point = sString:find(pattern,point)\\\
        if not point then\\\
          break\\\
        else\\\
          point = point+1\\\
        end\\\
      end\\\
      return tRes\\\
    end,\\\
    lineFormat = function(text,lineLength,center)\\\
      local tLines = {}\\\
      while #text > 0 do  --splits text into a table containing each line\\\
        local line = text:sub(1,lineLength)\\\
        local newLine = string.find(line..\\\"\\\",\\\"\\\\n\\\") --check for new line character\\\
        if newLine then\\\
          line = line:sub(1,newLine-1)\\\
          text = text:sub(#line+2,#text)\\\
        elseif #line == lineLength then\\\
          local endSpace = line:find\\\"%s$\\\" or line:find\\\"%s%S-$\\\" or lineLength\\\
          line = line:sub(1,endSpace)\\\
          text = text:sub(#line+1)\\\
        else\\\
          text = \\\"\\\"\\\
        end\\\
        if center then\\\
          line = string.rep(\\\" \\\",math.max(math.floor((lineLength-#line)/2),0))..line\\\
          line = line..string.rep(\\\" \\\",math.max(lineLength-#line,0))\\\
        end\\\
        tLines[#tLines+1] = line\\\
      end\\\
      return tLines\\\
    end\\\
  },\\\
  {\\\
    __index = _G.string\\\
  }\\\
)\",\
    [ \"TAFiles/Tools/Select.Lua\" ] = \"local rightClickFunc = function(name,button) --used for modularity's sake\\\
  for _i,v in ipairs(tMenu.rightClick.select) do\\\
    if v.name == name then\\\
      return v.enabled() and v.func(button)\\\
    end\\\
  end\\\
  return false\\\
end\\\
\\\
local shortcuts = {\\\
  [46] = function(button) --C\\\
    rightClickFunc\\\"Copy\\\"\\\
  end,\\\
  [45] = function(button) --X\\\
    rightClickFunc\\\"Cut\\\"\\\
  end,\\\
  [47] = function(button) --V\\\
    rightClickFunc\\\"Paste\\\"\\\
  end,\\\
  [19] = function(button) --R\\\
    rightClickFunc(\\\"Recolor\\\",button)\\\
  end,\\\
  [48] = function(button) --B\\\
    rightClickFunc\\\"Mark built\\\"\\\
  end,\\\
  [22] = function(button) --U\\\
    rightClickFunc\\\"Mark unbuilt\\\"\\\
  end,\\\
}\\\
local tool\\\
tool = {\\\
  menuOrder = 9, --menu order, 1 being top\\\
  enabled = true,\\\
  help = function(clickButton)\\\
    local button = window.text(\\\
      \\\"The select tool has a myriad of functions.\\\\nLeft click and drag to select an area, then right click to open up the selection menu. Here you can cut, copy, delete, recolor and change the built status of your current selection\\\",\\\
      {\\\
        \\\"Ok\\\",\\\
        \\\"Equip\\\"\\\
      }\\\
    )\\\
    if button == \\\"Equip\\\" then\\\
      tool.selectFunc(clickButton)\\\
    end\\\
  end,\\\
  selectFunc = function(button)\\\
    tTool.change(\\\"Select\\\",1,2)\\\
    for k,v in pairs(shortcuts) do\\\
      ctrlShortcuts.active[k] = v\\\
    end\\\
  end,\\\
  deselectFunc = function()\\\
    ctrlShortcuts.active = {}\\\
    for k,v in pairs(ctrlShortcuts.default) do\\\
      ctrlShortcuts.active[k] = v\\\
    end\\\
  end,\\\
  renderFunc = function(event,button,x,z,color)\\\
    if button == 1 then\\\
      screen:setLayer(screen.layers.toolsOverlay)\\\
      local c = tTool.clipboard\\\
      local t = tTool.select\\\
      if c then\\\
        c.sX = x+tTerm.scroll.x\\\
        c.sZ = z+tTerm.scroll.z\\\
        c.eX = c.sX+c.lX-1\\\
        c.eZ = c.sZ+c.lZ-1\\\
      elseif event == \\\"mouse_click\\\" then\\\
        t.layer = tTerm.scroll.layer\\\
        t.sX = x+tTerm.scroll.x\\\
        t.sZ = z+tTerm.scroll.z\\\
        t.eX = nil\\\
        t.eZ = nil\\\
      else --drag\\\
        t.eX = x+tTerm.scroll.x\\\
        t.eZ = z+tTerm.scroll.z\\\
      end\\\
\\\
      if t.sX and t.sZ and t.eX and t.eZ then\\\
        tTerm.misc.csAmend = \\\"Sel: \\\" .. math.abs(t.eX - t.sX) + 1 .. \\\"x\\\" .. math.abs(t.eZ - t.sZ) + 1\\\
        tTerm.misc.forceBottomBarRender = true\\\
      end\\\
\\\
      renderToolOverlay()\\\
      tTimers.blink.id = os.startTimer(tTimers.blink.time)\\\
    else --right click\\\
      tMenu.rightClick.render(\\\"select\\\",x,z)\\\
    end\\\
  end\\\
}\\\
return tool\\\
\",\
    [ \"TAFiles/Menus/mainMenus/Settings.Lua\" ] = \"local menu\\\
menu = {\\\
  enabled = true,\\\
  [1] = {\\\
    name = \\\"Update\\\",\\\
    enabled = _G.http and true,\\\
    help = function()\\\
      window.text\\\"Updates Turtle Architect to the latest version\\\"\\\
    end,\\\
    func = function()\\\
      if loadFile(tFile.installer) then\\\
        error(\\\"Update\\\",0)\\\
      end\\\
    end\\\
  },\\\
  [2] = {\\\
    name = \\\"Color settings\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text(\\\"Change the programs color settings. Every color of the GUI may be changed here, with the exception of the actual drawing colors. These settings are saved between sessions.\\\")\\\
    end,\\\
    func = function()\\\
      local colorSelection = {}\\\
      for k,v in pairs(tColors) do\\\
        if type(v) == \\\"number\\\" then\\\
          k = k:gsub(\\\"(%u)\\\",function(l) return \\\" \\\"..l:lower() end)\\\
          k = k:sub(1,1):upper()..k:sub(2)\\\
          colorSelection[#colorSelection+1] = {\\\
            text = k,\\\
            uText = v ~= tColors.scrollBoxSelectText and tColors.scrollBoxSelectText or colors.black,\\\
            uBackground = v\\\
          }\\\
        end\\\
      end\\\
      while true do\\\
        local button,selected = window.scroll(\\\"Select the color you wish to change\\\",colorSelection)\\\
        if button == \\\"Cancel\\\" then\\\
          return\\\
        end\\\
        local selectedColor = dialogue.selectColor(\\\"Select new \\\"..selected..\\\" color\\\")\\\
        if selectedColor ~= \\\"Cancel\\\" then\\\
          selectedColor = string.gsub(\\\
            string.lower(selectedColor:sub(1,1))..selectedColor:sub(2),\\\
            \\\"%s.\\\",\\\
            function(match)\\\
              return string.upper(match:sub(2)) \\\
            end\\\
          )\\\
          for k,v in pairs(colorSelection) do\\\
            if v.text == selected then\\\
              v.uText = colors[selectedColor] ~= tColors.scrollBoxSelectText and tColors.scrollBoxSelectText or colors.black\\\
              v.uBackground = colors[selectedColor]\\\
              break\\\
            end\\\
          end\\\
          selected = string.gsub(\\\
            string.lower(selected:sub(1,1))..selected:sub(2),\\\
            \\\"%s.\\\",\\\
            function(match)\\\
              return string.upper(match:sub(2)) \\\
            end\\\
          )\\\
          if selected == \\\"canvas\\\" then\\\
            colorKey[\\\" \\\"] = colors[selectedColor]\\\
            tBlueprint[tTerm.scroll.layer]:render()\\\
          end\\\
          tColors[selected] = colors[selectedColor]\\\
          local file = class.fileTable.new(tFile.settings)\\\
          local line = file:find(\\\"    \\\"..selected..\\\" = colors\\\")\\\
          file:write(\\\"    \\\"..selected..\\\" = colors.\\\"..selectedColor..\\\", \\\"..(file[line]:match\\\"%-%-(.+)$\\\" and \\\"--\\\"..file[line]:match\\\"%-%-(.+)$\\\" or \\\"\\\"),line)\\\
          file:save()\\\
          renderSideBar()\\\
          renderBottomBar()\\\
        end\\\
      end\\\
    end\\\
  },\\\
  [3] = {\\\
    name = \\\"Built mode\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Built mode let's you draw/see blocks marked as built. This means a turtle will consider these blocks already built, and ignore them.\\\"\\\
    end,\\\
    func = function()\\\
      local button = window.text(\\\
        [[Built mode let's you draw/see blocks marked as built. This means a turtle will consider these blocks already built, and ignore them.\\\
Built render mode: ]]..(tMode.builtRender and \\\"ON\\\" or \\\"OFF\\\")..[[ \\\
Built draw mode: ]]..(tMode.builtDraw and \\\"ON\\\" or \\\"OFF\\\"),\\\
        {\\\
          \\\"Cancel\\\",\\\
          (tMode.builtRender and \\\"Render OFF\\\" or \\\"Render ON\\\"),\\\
          (tMode.builtDraw and \\\"Draw OFF\\\" or \\\"Draw ON\\\")\\\
        }\\\
      )\\\
      if button == \\\"Render ON\\\" then\\\
        tMode.builtRender = true\\\
        scroll()\\\
      elseif button == \\\"Render OFF\\\" then\\\
        tMode.builtRender = false\\\
        scroll()\\\
      elseif button == \\\"Draw ON\\\" then\\\
        tMode.builtDraw = true\\\
      elseif button == \\\"Draw OFF\\\" then\\\
        tMode.builtDraw = false\\\
      end\\\
    end\\\
  },\\\
  [4] = {\\\
    name = \\\"Grid mode\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Grid mode renders a grid line ontop of your blueprint, for ease of visualization.\\\"\\\
    end,\\\
    func = function()\\\
      if tMode.grid then\\\
        tMode.grid = false\\\
        removeGrid()\\\
        local file = class.fileTable.new(tFile.settings)\\\
        local line = file:find(\\\"  grid = true,\\\",true)\\\
        file:write(\\\"  grid = false,\\\",line)\\\
        file:save()\\\
      else\\\
        tMode.grid = true\\\
        renderGrid()\\\
        local file = class.fileTable.new(tFile.settings)\\\
        local line = file:find(\\\"  grid = false,\\\",true)\\\
        file:write(\\\"  grid = true,\\\",line)\\\
        file:save()\\\
      end\\\
    end\\\
  },\\\
  [5] = {\\\
    name = \\\"Grid major\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Change the size of the major grid marker (the darker marker)\\\"\\\
    end,\\\
    func = function()\\\
      local button,tRes,reInput = window.text(\\\
        \\\"Change the size of the major grid marker\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"Major\\\",\\\
            value = tMode.gridMajor,\\\
            accepted = \\\"%d\\\"\\\
          },\\\
        },\\\
        nil,\\\
        true\\\
      )\\\
      while true do\\\
        if button == \\\"cancel\\\" then\\\
          return\\\
        elseif not tRes.Major then\\\
          button,tRes,reInput = reInput(\\\"Missing major parameter!\\\")\\\
        else\\\
          if tRes.Major ~= tMode.gridMajor then\\\
            tMode.gridMajor = tRes.Major\\\
            local file = class.fileTable.new(tFile.settings)\\\
            local line = file:find(\\\"  gridMajor = %d-,\\\")\\\
            file:write(\\\"  gridMajor = \\\"..tMode.gridMajor..\\\",\\\",line)\\\
            file:save()\\\
            if tMode.grid then\\\
              scroll()\\\
            end\\\
          end\\\
          return\\\
        end\\\
      end\\\
    end\\\
  },\\\
  [6] = {\\\
    name = \\\"Background layer\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Background layer mode renders the specified layer in gray underneath the layer you are currently viewing. This makes comparisons a breeze.\\\"\\\
    end,\\\
    func = function()\\\
      local button,tRes,reInput = window.text(\\\
        [[BGL mode renders the specified layer underneath the layer you are currently viewing. This makes comparisons a breeze.\\\
BGL mode: ]]..(tMode.backgroundLayer and \\\"ON\\\" or \\\"OFF\\\"),\\\
        {\\\
          \\\"Cancel\\\",\\\
          (tMode.backgroundLayer and \\\"BGL OFF\\\" or \\\"BGL ON\\\"),\\\
          (tMode.backgroundLayer and \\\"BGL change\\\" or nil),\\\
        },\\\
        {\\\
          {\\\
            name = \\\"BGL\\\",\\\
            value = math.max(tTerm.scroll.layer-1,1),\\\
            accepted = \\\"%d\\\"\\\
          },\\\
        },\\\
        nil,\\\
        true\\\
      )\\\
      if button == \\\"BGL ON\\\"\\\
      or button == \\\"BGL change\\\"\\\
      or button == \\\"Ok\\\" then\\\
        if not tBlueprint[tRes.BGL] then\\\
          button,tRes,reInput = reInput(\\\"Layer (\\\"..tRes.BGL..\\\") does not exist!\\\")\\\
        else\\\
          tMode.backgroundLayer = tBlueprint[tRes.BGL]\\\
          scroll()\\\
        end\\\
      elseif button == \\\"BGL OFF\\\" then\\\
        tMode.backgroundLayer = false\\\
        scroll()\\\
      end\\\
    end\\\
  },\\\
  [7] = {\\\
    name = \\\"Overwrite mode\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Overwrite mode lets you draw over any color. If it's off, you may only draw on blank areas(white).\\\"\\\
    end,\\\
    func = function()\\\
      tMode.overwrite = not tMode.overwrite\\\
    end\\\
  },\\\
  [8] = {\\\
    name = \\\"Hide menus\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Hides all menus, leaving only the canvas. Press ctrl+H to re-enable menus.\\\"\\\
    end,\\\
    func = function()\\\
      toggleMenus()\\\
    end\\\
  },\\\
  [9] = {\\\
    name = \\\"Sync mode\\\",\\\
    enabled = function()\\\
      return modem and true or false\\\
    end,\\\
    help = function()\\\
      window.text\\\"Sync mode syncs the blueprint in real-time across multiple computers. If you sync with turtles, they can be ordered to build the blueprint together\\\"\\\
    end,\\\
    func = function()\\\
      local synced = {}\\\
      for id in pairs(tMode.sync.ids) do\\\
        synced[id] = true\\\
      end\\\
      local inRange = {}\\\
      rednet.send(\\\"All\\\",\\\"Ping\\\")\\\
      tTimers.scan.start()\\\
      local scanRes = window.text(\\\
        {\\\
          {\\\
            text = \\\"Scanning\\\",\\\
            renderTime = 0.2\\\
          },\\\
          {\\\
            text = \\\"Scanning.\\\",\\\
            renderTime = 0.2\\\
          },\\\
          {\\\
            text = \\\"Scanning..\\\",\\\
            renderTime = 0.2\\\
          },\\\
          {\\\
            text = \\\"Scanning...\\\",\\\
            renderTime = 0.2\\\
          },\\\
        },\\\
        {\\\
          \\\"Cancel\\\"\\\
        },\\\
        nil,\\\
        {\\\
          timer = function(tEvent)\\\
            if tTimers.scan.ids[tEvent[2]] then\\\
              return \\\"Done\\\"\\\
            end\\\
          end,\\\
          modem_message = function(tEvent)\\\
            if tEvent[3] == modemChannel\\\
            and type(tEvent[5]) == \\\"table\\\" --All Turtle Architect messages are sent as tables\\\
            and tEvent[5].rID[os.id] then\\\
              local data = tEvent[5]\\\
              if data.event == \\\"Success\\\"\\\
              and data.type == \\\"Ping\\\" then\\\
                inRange[#inRange+1] = {\\\
                  text = data.turtle and data.sID..\\\" - Turtle\\\" or data.sID..\\\" - Computer\\\",\\\
                  selected = tMode.sync.ids[data.sID] and true\\\
                }\\\
              end\\\
            end\\\
          end\\\
        }\\\
      )\\\
      if scanRes == \\\"Cancel\\\" then\\\
        return\\\
      end\\\
      if #inRange == 0 then\\\
        window.text\\\"No syncable computers in range!\\\"\\\
        return\\\
      end\\\
      local button,connectIds = window.scroll(\\\"Select sync IDs:\\\",inRange,true)\\\
      if button == \\\"Cancel\\\" then\\\
        return\\\
      end\\\
      local syncIds = {}\\\
      for i,id in ipairs(connectIds) do\\\
        syncIds[tonumber(id:match\\\"%d+\\\")] = true\\\
      end\\\
      connectIds = nil\\\
      local deSyncIds = {}\\\
      local deSync\\\
      for id in pairs(tMode.sync.ids) do\\\
        if not syncIds[id] then\\\
          deSyncIds[id] = true\\\
          deSync = true\\\
        else\\\
          syncIds[id] = nil\\\
        end\\\
      end\\\
      if deSync then\\\
        rednet.disconnect(deSyncIds)\\\
      end\\\
      deSyncIds = nil\\\
      rednet.connect(\\\
        syncIds,\\\
        \\\"Sync\\\",\\\
        100,\\\
        function(id,data)\\\
          tMode.sync.ids[id] = data.turtle and \\\"turtle\\\" or \\\"computer\\\"\\\
          tMode.sync.amount = tMode.sync.amount+1\\\
          tMode.sync.turtles = tMode.sync.turtles+(data.turtle and 1 or 0)\\\
          rednet.send(\\\
            id,\\\
            \\\"Sync edit\\\",\\\
            {\\\
              type = \\\"Blueprint load\\\",\\\
              blueprint = tBlueprint,\\\
              blueprintName = tFile.blueprint\\\
            }\\\
          )\\\
          sync({sync = tMode.sync},\\\"Ids\\\")\\\
          local timerId = os.startTimer(10)\\\
          if data.turtle and tMode.sync.turtles == 1 then\\\
            renderSideBar()\\\
          end\\\
          window.text(\\\
            \\\"Successfully synced with \\\"..(data.turtle and \\\"Turtle\\\" or \\\"Computer\\\")..\\\" ID \\\"..id,\\\
            false,\\\
            false,\\\
            {\\\
              timer = function(tEvent)\\\
                if tEvent[2] == timerId then\\\
                  return \\\"Ok\\\"\\\
                end\\\
              end\\\
            }\\\
          )\\\
        end\\\
      )\\\
    end\\\
  },\\\
  [10] = {\\\
    name = \\\"About\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Tells the story of how awesome i am\\\"\\\
    end,\\\
    func = function()\\\
      window.text([[Turtle Architect 2.0.\\\
This software lets you draw your Minecraft constructions on your computer, and have your turtle build it wherever you desire. Files may easily be saved or even uploaded to Pastebin, for later use.\\\
Developed by CometWolf.\\\
\\\
Use the help tool, found under the To menu, if you desire more information.\\\
]]\\\
      )\\\
    end\\\
  },\\\
  [11] = {\\\
    name = \\\"Quit\\\",\\\
    enabled = true,\\\
    func = function()\\\
      error(\\\"Exit\\\",0)\\\
    end\\\
  }\\\
}\\\
return menu\\\
\",\
    [ \"TAFiles/Tools/hSquare.Lua\" ] = \"local calcFunc = function(x1,z1,x2,z2,color)\\\
  local x = {\\\
    max = math.max(x1,x2),\\\
    min = math.min(x1,x2)\\\
  }\\\
  x.max = x.max-x.min+1\\\
  x.min = 1\\\
  local z = {\\\
    max = math.max(z1,z2),\\\
    min = math.min(z1,z2)\\\
  }\\\
  z.max = z.max-z.min+1\\\
  z.min = 1\\\
  local points = class.layer.new()\\\
  for iX = x.min,x.max do\\\
    points[iX][z.min] = color\\\
    points[iX][z.max] = color\\\
  end\\\
  for iZ = z.min,z.max do\\\
    points[x.min][iZ] = color\\\
    points[x.max][iZ] = color\\\
  end\\\
  return points\\\
end\\\
\\\
local tool \\\
tool = {\\\
  menuOrder = 4, --menu order, 1 being top\\\
  enabled = true,\\\
  help = function(clickButton)\\\
    local button = window.text(\\\
      \\\"The hollow square tool lets you draw a hollow square by left clicking a point and dragging to the opposite point. When you are satisfied, simply right click to draw it on the blueprint\\\",\\\
      {\\\
        \\\"Ok\\\",\\\
        \\\"Equip\\\"\\\
      }\\\
    )\\\
    if button == \\\"Equip\\\" then\\\
      tool.selectFunc(clickButton)\\\
    end\\\
  end,\\\
  selectFunc = function(button)\\\
    tTool.change(\\\"hSquare\\\",1,2)\\\
  end,\\\
  renderFunc = function(event,button,x,z,color,layer)\\\
    local s = tTool.shape\\\
    if event == \\\"mouse_click\\\" then\\\
      if button == 1 then\\\
        s.sX = x+tTerm.scroll.x\\\
        s.sZ = z+tTerm.scroll.z\\\
        if s.eX then\\\
          screen:clearLayer(screen.layers.toolsOverlay)\\\
        end\\\
        s.eX = false\\\
        s.eZ = false\\\
      elseif s.eX then --button 2\\\
        s.layer = tTerm.scroll.layer\\\
        sync(s,\\\"Paste\\\")\\\
        tBlueprint[tTerm.scroll.layer]:paste(s.l,math.min(s.sX,s.eX),math.min(s.sZ,s.eZ),not tMode.overwrite)\\\
        renderArea(s.sX,s.sZ,s.eX,s.eZ,true)\\\
        tTool.shape = {}\\\
        renderToolOverlay()\\\
      end\\\
    elseif button == 1 and s.sX then --drag\\\
      s.eX = x+tTerm.scroll.x\\\
      s.eZ = z+tTerm.scroll.z\\\
      s.l = calcFunc(s.sX,s.sZ,s.eX,s.eZ,color)\\\
      renderToolOverlay()\\\
    end\\\
    if s.sX and s.sZ and s.eX and s.eZ then\\\
      tTerm.misc.csAmend = \\\"Sqr: \\\" .. math.abs(s.eX - s.sX) + 1 .. \\\"x\\\" .. math.abs(s.eZ - s.sZ) + 1\\\
      tTerm.misc.forceBottomBarRender = true\\\
    end\\\
  end,\\\
  codeFunc = function(sX,sZ,eX,eZ,color,layer) --this is used by the code tool\\\
    color = color or codeEnv.click.color\\\
    layer = layer or codeEnv.click.layer\\\
    if not (sX and sZ and eX and eZ)\\\
    or not (type(sX) == \\\"number\\\" and type(sZ) == \\\"number\\\" and type(eX) == \\\"number\\\" and type(eZ) == \\\"number\\\") then\\\
      error(\\\"Expected number,number,number,number\\\",2)\\\
    end\\\
    if type(layer) == \\\"table\\\" and layer.paste then\\\
      layer:paste(calcFunc(sX,sZ,eX,eZ,color),math.min(sX,eX),math.min(sZ,eZ),not tMode.overwrite)\\\
    elseif codeEnv.settings.direct then\\\
      local s = {\\\
        sX = sX,\\\
        sZ = sZ,\\\
        eX = eX,\\\
        eZ = eZ,\\\
        layer = layer,\\\
        l = calcFunc(sX,sZ,eX,eZ,color)\\\
      }\\\
      tBlueprint[layer]:paste(s.l,math.min(sX,eX),math.min(sZ,eZ),not tMode.overwrite)\\\
      sync(s,\\\"Paste\\\")\\\
      renderArea(sX,sZ,eX,eZ,true)\\\
    elseif type(layer) == \\\"number\\\" then\\\
      codeEnv.blueprint[layer]:paste(calcFunc(sX,sZ,eX,eZ,color),math.min(sX,eX),math.min(sZ,eZ),not tMode.overwrite)\\\
    else\\\
      error(\\\"Expected layer, got \\\"..type(layer),2)\\\
    end\\\
  end\\\
}\\\
return tool\\\
\",\
    [ \"TAFiles/Settings.Lua\" ] = \"modemChannel = 62700 --Channel used to communicate with other computers/turtles running Turtle Architect\\\
\\\
tColors = setmetatable(\\\
  { -- color settings\\\
    canvas = colors.white, --changing this can cause some derps\\\
    bottomBar = colors.gray, --Bottom bar color\\\
    coordsText = colors.white, --text color for the coordinates on the bottom right\\\
    sideBarText = colors.white, --menu buttons text color\\\
    sideBar = colors.gray, --menu sidebar color\\\
    menuTop = colors.blue, --menu header color\\\
    menuPri = colors.black, --Menu color alteration primary \\\
    menuSec = colors.gray, --Menu color alteration secondary\\\
    enabledMenuText = colors.yellow, --Enabled Menus text\\\
    disabledMenuText = colors.lightGray, --disabled menus text\\\
    inputBox = colors.gray, -- popup boxes background\\\
    inputBoxBorder = colors.lightGray, --popup boxes border\\\
    inputBoxText = colors.yellow, --popup boxes text\\\
    inputBar = colors.black, --popup boxes input fields\\\
    inputText = colors.white, --popup boxes input fields text\\\
    inputButton = colors.lightBlue, --popup boxes buttons\\\
    inputButtonText = colors.yellow, --popup boxes buttons text\\\
    scrollBoxSelectText = colors.white, --popup scroll boxes scroll selection text\\\
    scrollBoxSelected = colors.blue, --popup scroll boxes selected scroll selection background\\\
    scrollBoxUnselected = colors.black, --popup scroll boxes selected scroll selection background\\\
    builtMarker = colors.white, --built mode marker\\\
    gridMarkerMajor = colors.blue, --grid mode marker for major units\\\
	  gridMarkerMinor = colors.lightBlue, --grid mode marker for minor units\\\
    gridMarkerMajor2 = colors.black, --this is used when rendering the grid ontop of a block matching the color of gridMarkerMajor\\\
    gridMarkerMinor2 = colors.gray, --this is used when rendering the grid ontop of a block matching the color of gridMarkerMinor\\\
    gridBorder = colors.blue, -- background for grid numbers\\\
    gridBorderText = colors.white, --grid numbers 12345...\\\
    backgroundLayer = colors.gray, --background layer rendered with background mode\\\
    toolText = colors.white, --T1 and T2 on the bottom bar, this color is also used as the background if the tool currently has the same color as the bottom bar equipped\\\
    rightClickPri = colors.black, --Right click selection menu color alteration primary\\\
    rightClickSec = colors.gray, --Right click selection menu color alteration secondary\\\
    rightClickUseable = colors.white, --Useable right click selection menu options\\\
    rightClickUnuseable = colors.lightGray, --Not useable right click selection menu options\\\
    selection = colors.gray, --Color of the selection marker\\\
    layerBar = colors.black, --Background color of the layer bar\\\
    layerBarViewSelected = colors.lightBlue, --in view and selected layer item on the layer bar\\\
    layerBarViewUnselected = colors.lightGray, --in view layer item on layer bar    \\\
    layerBarSelected = colors.blue, --Selected layer item on the layer bar\\\
    layerBarUnselected = colors.black, --Unselected layer item on the layer bar\\\
    layerBarText = colors.white, --layer numbers color on the layer bar\\\
  },\\\
  {\\\
    __index = function(t,k)\\\
      error(\\\"The color \\\"..k..\\\" is not defined!\\\",2)\\\
    end\\\
  }\\\
)\\\
tColors.glass = { --glass colors\\\
	white = 0xFFFFFF,\\\
	orange = 0xFFA500,\\\
	magenta = 0xFF00FF,\\\
	lightBlue = 0xADD8E6,\\\
	yellow = 0xFFFF00,\\\
	lime = 0x00FF00,\\\
	pink = 0xFFC0CB,\\\
	gray = 0x808080,\\\
	lightGray = 0xD3D3D3,\\\
	cyan = 0x00FFFF,\\\
	purple = 0x800080,\\\
	blue = 0x0000FF,\\\
	brown = 0xA52A2A,\\\
	green = 0x008000,\\\
	red = 0xFF0000,\\\
	black = 0x000000,\\\
}\\\
glasses = { --openP glass settings\\\
  screen = {\\\
    size = { --the size of each screen pixel\\\
      x = 3,\\\
      y = 5 \\\
    },\\\
    pos = { --where to render the glasses screen\\\
      x = 0,\\\
      y = 0\\\
    },\\\
    opacity = 1 --screen transparency\\\
  },\\\
  log = { --where to render the message bar\\\
    sX = 331,\\\
    sY = 100,\\\
    eX = 480,\\\
    eY = 246,\\\
    opacity = 0.5, --log transparency\\\
	  maxSize = 50, --amount of entries to store in the log\\\
    timers = {--used to store cleanup timer functions, indexed by timer id\\\
      \\\
    }\\\
  },\\\
  followTurtle = true, --whether to auto scroll the canvas along with the turtle as it builds, provided you have glasses connected\\\
  screenMode = \\\"Screen Log\\\", --glasses display mode,simply write which modes you want in plain text, remember to capitalize the first letter\\\
  colors = {} --CC to HEX color conversion\\\
}\\\
--cc to hex color conversion table\\\
local colorValueToHex = {}\\\
for gK,gV in pairs(tColors.glass) do\\\
  for cK,cV in pairs(colors) do\\\
    if gK == cK then\\\
      colorValueToHex[cV] = gV\\\
      break\\\
    end\\\
  end\\\
end\\\
for k,v in pairs(colorValueToHex) do\\\
  glasses.colors[k] = v\\\
end\\\
tColors.glass.log = tColors.glass.blue --message log window color\\\
tColors.glass.logText = tColors.glass.yellow --message log text color\\\
\\\
tTimers = setmetatable( -- timer settings\\\
  {\\\
    restockRetry = { --wait before re-attempting failed restock\\\
      time = 20,\\\
    },\\\
    blink = { --how often to blink tool overlays\\\
      time = 1\\\
    },\\\
    modemRes = { --how long to wait for a modem response\\\
      time = 3,\\\
    },\\\
    connectionPing = { --How often to check connection\\\
      time = 10,\\\
    },\\\
    inputTimeout = { --Time to wait for time sensitive dialogue boxes, eg accept blueprint transmission or sync mode\\\
      time = 100\\\
    },\\\
    shift = { --shift key press timer, for shift shortcuts\\\
      time = 1\\\
    },\\\
    ctrl = { --ctrl key press timer, for ctrl shortcuts\\\
      time = 1\\\
    },\\\
    display = { --time a openP glasses message remains in the log\\\
      time = 20\\\
    },\\\
    scan = { --time to wait for responses when scanning for other computers running TA\\\
      time = 1\\\
    }\\\
  },\\\
  {\\\
    __index = function(t,k)\\\
      error(\\\"The timer \\\"..k..\\\" is not defined!\\\",2)\\\
    end\\\
  }\\\
)\\\
for k,v in pairs(tTimers) do\\\
  v.ids = {}\\\
  v.start = function(time)\\\
    v.id = os.startTimer(time or v.time)\\\
    v.ids[v.id] = true\\\
    return v.id\\\
  end\\\
  v.stop = function()\\\
    v.id = nil\\\
  end\\\
end\\\
\\\
colorKey = setmetatable(\\\
  { --what character correlates to what color in the blueprint\\\
    [\\\" \\\"] = tColors.canvas,\\\
    a = 2 ^ 1, --orange\\\
    b = 2 ^ 2, --purple\\\
    c = 2 ^ 3, --light blue\\\
    d = 2 ^ 4, --yellow\\\
    e = 2 ^ 5, --lime\\\
    f = 2 ^ 6, --pink\\\
    g = 2 ^ 7, --gray\\\
    h = 2 ^ 8, --light gray\\\
    i = 2 ^ 9, --blue\\\
    j = 2 ^ 10, --purple\\\
    k = 2 ^ 11, --blue\\\
    l = 2 ^ 12, --brown\\\
    m = 2 ^ 13, --green\\\
    n = 2 ^ 14, --red\\\
    o = 2 ^ 15  --black\\\
  },\\\
  {\\\
    __index = function(t,k)\\\
      error(\\\"Attempt to access non-existant color \\\"..(tostring(k) or \\\"nil\\\"),2)\\\
    end\\\
  }\\\
)\\\
\\\
local colorLoop = {}\\\
keyColor = {}\\\
for kK,vK in pairs(colorKey) do -- add color names to colorKey table\\\
  colorLoop[kK:upper()] = vK\\\
  for kC,vC in pairs(colors) do\\\
    if vC == vK then\\\
      colorLoop[vC] = kK\\\
      colorLoop[kC] = kK\\\
      kC = kC:gsub(\\\"(%u)\\\",function(l) return \\\" \\\"..l:lower() end)\\\
      keyColor[kK] = kC:sub(1,1):upper()..kC:sub(2)\\\
      keyColor[kK:upper()] = keyColor[kK]\\\
      break\\\
    end\\\
  end\\\
end\\\
for k,v in pairs(colorLoop) do\\\
  colorKey[k] = v\\\
end\\\
colorLoop = nil\\\
\\\
paintColors = { --paint colors,used for conversion\\\
  j = \\\"a\\\",\\\
  k = \\\"b\\\",\\\
  l = \\\"c\\\",\\\
  m = \\\"d\\\",\\\
  n = \\\"e\\\",\\\
  o = \\\"f\\\",\\\
  X = \\\"e\\\"\\\
}\\\
for i=1,9 do\\\
  paintColors[colorKey[2^i]] = i\\\
end\\\
local paintUpper = {}\\\
for k,v in pairs(paintColors) do\\\
  paintUpper[k:upper()] = v\\\
end\\\
for k,v in pairs(paintUpper) do\\\
  paintColors[k] = v\\\
end\\\
paintUpper = nil\\\
\\\
keyColor.S = \\\"Scan\\\"\\\
colorKey.S = colors.blue\\\
keyColor.X = \\\"Break\\\"\\\
colorKey.X = colors.red --break block marker\\\
\\\
local shortcutChange = function(t1,t2,primary) --ctrl shortcut tool change function\\\
  local secondary = primary == 1 and 2 or 1\\\
  if t1 == tTool[primary].tool then\\\
    if tTool[primary].prevDouble then\\\
      tTool.change(tTool[primary].prevTool,primary,secondary)\\\
    elseif tTool[primary].double and tTool[secondary].double then\\\
      tTool.change(tTool[primary].prevTool,primary)\\\
      tTool.change(tTool[secondary].prevTool,secondary)\\\
      tTool[primary].prevDouble = true\\\
      tTool[secondary].prevDouble = true\\\
    else\\\
      tTool.change(tTool[primary].prevTool or tTool[primary].tool,primary,t2 and secondary or nil)\\\
    end\\\
  elseif tTool[primary].double then\\\
    if t2 or tTool[secondary].prevDouble then\\\
      tTool.change(t1,primary,secondary)\\\
    else\\\
      tTool.change(t1,primary)\\\
      tTool.change(tTool[secondary].prevTool,secondary)\\\
    end\\\
  else\\\
    tTool.change(t1,primary,t2 and secondary or nil)\\\
  end\\\
end\\\
\\\
ctrlShortcuts = { --ctrl+key shortcuts, left ctrl button = 1, right ctrl button = 2\\\
  default = { --these are active by default\\\
    [48] = function(button) --B\\\
      shortcutChange(\\\"Brush\\\",nil,button)\\\
    end,\\\
    [33] = function(button) --F\\\
      shortcutChange(\\\"Fill\\\",nil,button)\\\
    end,\\\
    [25] = function(button) --P\\\
      shortcutChange(\\\"Pipette\\\",nil,button)\\\
    end,\\\
    [31] = function(button) --S\\\
      if tTool[1].tool == \\\"Select\\\" then\\\
        shortcutChange(\\\"Select\\\",true,button)\\\
      else\\\
        tTool.selected.Select()\\\
      end\\\
    end,\\\
    [46] = function(button) --C\\\
      shortcutChange(\\\"Code\\\",nil,button)\\\
    end,\\\
    [38] = function(button) --L\\\
      shortcutChange(\\\"Line\\\",true,button)\\\
    end,\\\
    [32] = function(button) --D\\\
      shortcutChange(\\\"Drag\\\",nil,button)\\\
    end,\\\
    [49] = function() --N\\\
      table.insert(tBlueprint,tTerm.scroll.layer+1,class.layer.new())\\\
      scroll(tTerm.scroll.layer+1)\\\
    end,\\\
    [35] = function() --H\\\
      toggleMenus()\\\
    end,\\\
  },\\\
  active = { --holds the currently active shortcuts, don't add anything here\\\
    \\\
  }\\\
}\\\
for k,v in pairs(ctrlShortcuts.default) do --activate default shortcuts\\\
  ctrlShortcuts.active[k] = v\\\
end\\\
\\\
tTool = { --Default equipped tools and colors\\\
  [1] = { --left mouse button\\\
    tool = \\\"Brush\\\",\\\
    color = colorKey.black\\\
  },\\\
  [2] = { --right mouse button\\\
    tool = \\\"Brush\\\",\\\
    color = colorKey.white\\\
  },\\\
  [3] = { --middle mouse button, somewhat secret...\\\
    tool = \\\"Help\\\",\\\
    color = colorKey.white\\\
  },\\\
  select = {}, --contains selection tool info\\\
  clipboard = false, --tool clipboard\\\
  shape = {}, --contains circle and square tool info\\\
  selected = {}, --contains select functions, indexed by tool name\\\
  deselected = {}, --contains deselect functions, indexed by tool name\\\
}\\\
\\\
tMode = { -- default modes\\\
  builtDraw = false,\\\
  builtRender = true,\\\
  overwrite = true,\\\
  grid = false,\\\
  gridMajor = 10,\\\
  layerBar = true,\\\
  backgroundLayer = false,\\\
  hideMenus = false,\\\
  sync = {\\\
    amount = 0,\\\
    turtles = 0,\\\
    ids = {\\\
    \\\
    }\\\
  }\\\
}\",\
    [ \"TAFiles/Classes/layer.Lua\" ] = \"local layer\\\
layer = { --layer class\\\
  new = function(data)\\\
    return setmetatable(\\\
      data or {},\\\
      {\\\
        __index = function(t,k)\\\
          if not layer[k] then\\\
            t[k] = class.x.new()\\\
            return t[k]\\\
          end\\\
          return layer[k]\\\
        end,\\\
        __metatable = false\\\
      }\\\
    )\\\
  end,\\\
  size = function(layer,dir)\\\
    local x,z = 0,0\\\
      for nX,vX in pairs(layer) do\\\
        local nZ = type(vX) == \\\"table\\\" and class.x.size(vX) or #vX\\\
        if nZ > 0 then\\\
          x = math.max(x,nX)\\\
          z = math.max(z,nZ)\\\
        end\\\
      end\\\
    return dir == \\\"x\\\" and x or dir == \\\"z\\\" and z or x,z\\\
  end,\\\
  copy = function(layer,x1,z1,x2,z2,clipboard)\\\
  --returns a layer copy, optional coordinates\\\
    local _copy = layer.new()\\\
    local x,z = {},{}\\\
    if not (x1 and x2) then\\\
      x.min,x.max = 1,layer:size(\\\"x\\\")\\\
    else\\\
      x.max = math.max(x1,x2)\\\
      x.min = math.min(x1,x2)\\\
    end\\\
    if not (z1 and z2) then\\\
      z.min,z.max = 1,math.huge\\\
    else\\\
      z.max = math.max(z1,z2)\\\
      z.min = math.min(z1,z2)\\\
    end\\\
    local eZ = 1\\\
    for nX = x.min,x.max do\\\
      local vX = layer[nX]\\\
      nX = nX-x.min+1\\\
      _copy[nX] = vX.new()\\\
      for nZ,vZ in pairs(vX) do\\\
        if nZ >= z.min and nZ <= z.max then\\\
          _copy[nX][nZ-z.min+1] = vZ ~= \\\" \\\" and vZ or nil\\\
          eZ = math.max(eZ,nZ)\\\
        end\\\
      end\\\
    end\\\
    if clipboard then\\\
      return {\\\
        l = _copy,\\\
        sX = x.min,\\\
        eX = x.max,\\\
        sZ = z.min,\\\
        eZ = eZ,\\\
        lX = x.max-x.min+1,\\\
        lZ = eZ-z.min+1,\\\
      }\\\
    end\\\
    return _copy\\\
  end,\\\
  paste = function(layer,clipboard,pX,pZ,merge)\\\
    --combines layers, with an optional offset\\\
    pX = pX and pX-1 or 0\\\
    pZ = pZ and pZ-1 or 0\\\
    for nX,vX in pairs(clipboard) do\\\
      for nZ,vZ in pairs(vX) do\\\
        if merge then\\\
          if layer[nX+pX][nZ+pZ] == \\\" \\\" then\\\
            layer[nX+pX][nZ+pZ] = vZ\\\
          end\\\
        else\\\
          layer[nX+pX][nZ+pZ] = vZ\\\
        end\\\
      end\\\
    end\\\
  end,\\\
  markBuilt = function(layer,x1,z1,x2,z2,clearBreak)\\\
    --marks the layer as built, optionally just one area\\\
    local x,z = {},{}\\\
    if not (x1 and x2) then\\\
      x.min,x.max = 1,layer:size(\\\"x\\\")\\\
    else\\\
      x.max = math.max(x1,x2)\\\
      x.min = math.min(x1,x2)\\\
    end\\\
    if not (z1 and z2) then\\\
      z.min,z.max = 1,math.huge\\\
    else\\\
      z.max = math.max(z1,z2)\\\
      z.min = math.min(z1,z2)\\\
    end\\\
    for nX = x.min,x.max do\\\
      local vX = layer[nX]\\\
      for nZ,vZ in pairs(vX) do\\\
        if nZ >= z.min and nZ <= z.max then\\\
          vX[nZ] = clearBreak and vZ == \\\"X\\\" and \\\" \\\" or vZ:upper()\\\
        end\\\
      end\\\
    end\\\
  end,\\\
  markUnbuilt = function(layer,x1,z1,x2,z2)\\\
    --marks the layer as unbuilt, optionally just one area\\\
    local x,z = {},{}\\\
    if not (x1 and x2) then\\\
      x.min,x.max = 1,layer:size(\\\"x\\\")\\\
    else\\\
      x.max = math.max(x1,x2)\\\
      x.min = math.min(x1,x2)\\\
    end\\\
    if not (z1 and z2) then\\\
      z.min,z.max = 1,math.huge\\\
    else\\\
      z.max = math.max(z1,z2)\\\
      z.min = math.min(z1,z2)\\\
    end\\\
    for nX = x.min,x.max do\\\
      local vX = layer[nX]\\\
      for nZ,vZ in pairs(vX) do\\\
        if nZ >= z.min and nZ <= z.max and vZ ~= \\\"X\\\" then\\\
          vX[nZ] = vZ:lower()\\\
        end\\\
      end\\\
    end\\\
  end,\\\
  flipX = function(layer,x1,z1,x2,z2)\\\
  --flips layer on the x-axis, optionally just one area\\\
    local x,z = {},{}\\\
    if not (x1 and x2) then\\\
      x.min,x.max = 1,layer:size(\\\"x\\\")\\\
      x.size = x.max+1\\\
    else\\\
      x.max = math.max(x1,x2)\\\
      x.min = math.min(x1,x2)\\\
      x.size = x.max+1\\\
    end\\\
    if not (z1 and z2) then\\\
      z.min,z.max = 1,math.huge\\\
    else\\\
      z.max = math.max(z1,z2)\\\
      z.min = math.min(z1,z2)\\\
    end\\\
    local flipped = layer.new()\\\
    for nX = x.min,x.max do\\\
      local vX = layer[nX]\\\
      nX = x.size-nX\\\
      flipped[nX] = vX.new()\\\
      for nZ,vZ in pairs(vX) do\\\
        if nZ >= z.min and nZ <= z.max then\\\
          flipped[nX][nZ] = vZ\\\
        end\\\
      end\\\
    end\\\
    return flipped\\\
  end,\\\
  flipZ = function(layer,x1,z1,x2,z2)\\\
  --flips layer on the Z-axis, optionally just one area\\\
    local x,z = {},{}\\\
    if not (x1 and x2) then\\\
      x.min,x.max = 1,layer:size(\\\"x\\\")\\\
    else\\\
      x.max = math.max(x1,x2)\\\
      x.min = math.min(x1,x2)\\\
    end\\\
    if not (z1 and z2) then\\\
      z.min,z.max = 0,math.huge\\\
      z.size = 0\\\
      for nX,vX in pairs(layer) do\\\
        z.size = math.max(z.size,vX:size())\\\
      end\\\
      z.size = z.size+1\\\
    else\\\
      z.max = math.max(z1,z2)\\\
      z.min = math.min(z1,z2)\\\
      z.size = z.max+1\\\
    end\\\
    local flipped = layer.new()\\\
    for nX = x.min,x.max do\\\
      local vX = layer[nX]\\\
      flipped[nX] = vX.new()\\\
      for nZ,vZ in pairs(vX) do\\\
        if nZ >= z.min and nZ <= z.max then\\\
          flipped[nX][z.size-nZ] = vZ\\\
        end\\\
      end\\\
    end\\\
    return flipped\\\
  end,\\\
  recolor = function(layer,color,x1,z1,x2,z2)\\\
  --changes all colored blocks to the specified color, optionally within an area\\\
    local x,z = {},{}\\\
    if not (x1 and x2) then\\\
      x.min,x.max = 1,layer:size(\\\"x\\\")\\\
    else\\\
      x.max = math.max(x1,x2)\\\
      x.min = math.min(x1,x2)\\\
    end\\\
    if not (z1 and z2) then\\\
      z.min,z.max = 1,math.huge\\\
    else\\\
      z.max = math.max(z1,z2)\\\
      z.min = math.min(z1,z2)\\\
    end\\\
    local loopLayer = layer:copy()\\\
    for nX = x.min,x.max do\\\
      for nZ,vZ in pairs(loopLayer[nX]) do\\\
        if nZ >= z.min and nZ <= z.max then\\\
          layer[nX][nZ] = color\\\
        end\\\
      end\\\
    end\\\
  end,\\\
  delete = function(layer,sX,sZ,eX,eZ)\\\
  --clears the specified area\\\
    for iX = math.min(sX,eX),math.max(eX,sX) do\\\
      for iZ = math.min(sZ,eZ),math.max(eZ,sZ) do\\\
        layer[iX][iZ] = nil\\\
      end\\\
    end\\\
  end,\\\
  render = function(layer)\\\
  --renders the layer on the canvas\\\
    local view = tTerm.viewable\\\
  	local mX = view.mX\\\
    local mZ = view.mZ\\\
    screen:setLayer(screen.layers.canvas)\\\
    local scrX = tTerm.scroll.x\\\
    local scrZ = tTerm.scroll.z\\\
    for x = view.sX,view.eX do\\\
      for z = view.sZ,view.eZ do\\\
        screen:setCursorPos(x-scrX+mX,z-scrZ+mZ)\\\
        writePoint(x,z)\\\
      end\\\
    end\\\
  end\\\
}\\\
return layer\\\
\",\
    [ \"TAFiles/Classes/x.Lua\" ] = \"local x \\\
x = { --x-axis class\\\
  new = function()\\\
    return setmetatable(\\\
      {\\\
\\\
      },\\\
      {\\\
        __index = function(t,k)\\\
          if not x[k] then\\\
            assert(type(k) == \\\"number\\\",\\\"Error: Attempt to access non-number value \\\"..k..\\\" on z-axis\\\")\\\
            return \\\" \\\"\\\
          end\\\
          return x[k]\\\
        end,\\\
        __metatable = false\\\
      }\\\
    )\\\
  end,\\\
  size = function(t)\\\
    local z = 0\\\
    for nZ in pairs(t) do\\\
      z = math.max(z,nZ)\\\
    end\\\
    return z\\\
  end\\\
}\\\
return x\\\
\",\
    [ \"TAFiles/Classes/screenBuffer.Lua\" ] = \"local screenBuffer\\\
screenBuffer = {\\\
  new = function()\\\
    local buffer\\\
    buffer = setmetatable(\\\
      {\\\
        x = 1,\\\
        y = 1,\\\
        bColor = colors.black,\\\
        tColor = colors.white,\\\
        marker = \\\" \\\",\\\
        layer = 1,\\\
        blink = false,\\\
        changed = class.matrix.new(2),\\\
      },\\\
      {\\\
        __index = function(t,k)\\\
          if not screenBuffer[k] then\\\
            if type(k) == \\\"number\\\" then\\\
              for i = #t+1,k do\\\
                t[i] = rawget(t,layer) or class.matrix.new(2)\\\
              end\\\
              buffer.layer = k\\\
              return t[k]\\\
            end\\\
          end\\\
          return screenBuffer[k]\\\
        end\\\
      }\\\
    )\\\
    return buffer\\\
  end,\\\
  setBackgroundColor = function(buffer,color)\\\
    buffer.bColor = (\\\
      type(color) == \\\"number\\\" and color \\\
      or colorKey[color]\\\
      or colors[color]\\\
    )\\\
  end,\\\
  setTextColor = function(buffer,color)\\\
    buffer.tColor = (\\\
      type(color) == \\\"number\\\" and color \\\
      or colorKey[color]\\\
      or colors[color]\\\
    )\\\
  end,\\\
  setMarker = function(buffer,marker)\\\
    buffer.marker = marker or \\\" \\\"\\\
  end,\\\
  setLayer = function(buffer,layer)\\\
    buffer.layer = layer or #buffer\\\
  end,\\\
  setCursorPos = function(buffer,x,y)\\\
    buffer.x = x or buffer.x\\\
    buffer.y = y or buffer.y\\\
  end,\\\
  getCursorPos = function(buffer)\\\
    return buffer.x,buffer.y\\\
  end,\\\
  setCursorBlink = function(buffer,BOOL)\\\
    buffer.blink = BOOL\\\
    term.setCursorBlink(BOOL)\\\
  end,\\\
  getTextColor = function(buffer)\\\
    return buffer.tColor\\\
  end,\\\
  getBackgroundColor = function(buffer)\\\
    return buffer.bColor\\\
  end,\\\
  getBlink = function(buffer)\\\
    return buffer.blink\\\
  end,\\\
  getTop = function(buffer,x,y,from)\\\
    for iL = (from or #buffer),1,-1 do\\\
	    local xLine = rawget(buffer[iL],x)\\\
      if xLine and xLine[y] then\\\
        return iL\\\
      end\\\
    end\\\
  end,\\\
  write = function(buffer,text,bColor,tColor)\\\
    bColor = bColor or buffer.bColor\\\
	tColor = tColor or buffer.tColor\\\
    for character in string.gmatch(text,\\\".\\\") do\\\
      local p = buffer[buffer.layer][buffer.x][buffer.y]\\\
      if not p\\\
      or p.marker ~= character\\\
      or p.bColor ~= bColor\\\
      or p.tColor ~= tColor and character ~= \\\" \\\" then\\\
        buffer[buffer.layer][buffer.x][buffer.y] = {\\\
          bColor = bColor,\\\
          tColor = tColor,\\\
          marker = character,\\\
        }\\\
        if buffer.layer == buffer:getTop(buffer.x,buffer.y) then\\\
          buffer.changed[buffer.x][buffer.y] = buffer.layer\\\
        end\\\
      end\\\
      buffer.x = buffer.x+1\\\
    end\\\
  end,\\\
  clearLine = function(buffer)\\\
    buffer:setCursorPos(1,buffer.y)\\\
    buffer:write(string.rep(\\\" \\\",tTerm.screen.x))\\\
  end,\\\
  clear = function(buffer)\\\
    for iL = #buffer,1,-1 do\\\
      buffer:del(iL)\\\
    end\\\
  end,\\\
  fill = function(buffer,color)\\\
    buffer.bColor = color or buffer.bColor\\\
    for iY = 1,tTerm.screen.y do\\\
      buffer:setCursorPos(1,iY)\\\
      buffer:write(string.rep(\\\" \\\",tTerm.screen.x))\\\
    end\\\
  end,\\\
  drawPoint = function(buffer,x,y,color,marker,mColor)\\\
    marker = marker or buffer.marker\\\
    color = color or buffer.bColor\\\
    x = x or buffer.x\\\
    y = y or buffer.y\\\
    mColor = mColor or color\\\
    local p = buffer[buffer.layer][x][y]\\\
    if not p\\\
    or p.bColor ~= color\\\
    or p.tColor ~= mColor and marker and marker ~= \\\" \\\"\\\
    or marker and p.marker ~= marker then\\\
      buffer[buffer.layer][x][y] = {\\\
        bColor = color,\\\
        tColor = mColor,\\\
        marker = marker\\\
      }\\\
      if buffer.layer == buffer:getTop(x,y) then\\\
        buffer.changed[x][y] = buffer.layer\\\
      end\\\
    end\\\
  end,\\\
  drawLine = function(buffer,x1,y1,x2,y2,color,marker)\\\
    local x = {\\\
      max = math.min(tTerm.screen.x,math.max(x1,x2)),\\\
      min = math.max(1,math.min(x1,x2))\\\
    }\\\
    local y = {\\\
      max = math.min(tTerm.screen.y,math.max(y1,y2)),\\\
      min = math.max(1,math.min(y1,y2))\\\
    }\\\
    marker = marker or \\\" \\\"\\\
    color = color or buffer.bColor\\\
    for iX = x.min,x.max do\\\
      for iY = y.min,y.max do\\\
        local p = buffer[buffer.layer][iX][iY]\\\
        if not p\\\
        or p.bColor ~= color\\\
        or p.tColor ~= color and marker ~= \\\" \\\"\\\
        or p.marker ~= marker then\\\
          buffer[buffer.layer][iX][iY] = {\\\
            bColor = color,\\\
            tColor = color,\\\
            marker = marker\\\
          }\\\
          if buffer.layer == buffer:getTop(iX,iY) then\\\
            buffer.changed[iX][iY] = buffer.layer\\\
          end\\\
        end\\\
      end\\\
    end\\\
  end,\\\
  drawBox = function(buffer,x1,y1,x2,y2,color,marker)\\\
    for iX = x1,x2 do\\\
      buffer:drawLine(iX,y1,iX,y2,color,marker)\\\
    end\\\
  end,\\\
  drawFrame = function(buffer,x1,y1,x2,y2,color,marker)\\\
    buffer:drawLine(x1,y1,x2,y1,color,marker)\\\
    buffer:drawLine(x2,y1,x2,y2,color,marker)\\\
    buffer:drawLine(x2,y2,x1,y2,color,marker)\\\
    buffer:drawLine(x1,y2,x1,y1,color,marker)\\\
  end,\\\
  add = function(buffer,num)\\\
    table.insert(buffer,class.matrix.new(2),num)\\\
  end,\\\
  delLayer = function(buffer,layer)\\\
    layer = layer or #buffer\\\
    if layer == #buffer then\\\
      for nX,vX in pairs(buffer[layer]) do\\\
        for nY,vY in pairs(vX) do\\\
          buffer.changed[nX][nY] = buffer:getTop(nX,nY,layer-1)\\\
        end\\\
      end\\\
    else\\\
      for nX,vX in pairs(buffer[layer]) do\\\
        for nY,vY in pairs(vX) do\\\
          if buffer:getTop(nX,nY) == layer then\\\
            buffer.changed[nX][nY] = buffer:getTop(nX,nY,layer-1)\\\
          end\\\
        end\\\
      end\\\
    end\\\
    table.remove(buffer,layer)\\\
  end,\\\
	clearLayer = function(buffer,layer)\\\
    layer = layer or #buffer\\\
    if layer == #buffer then\\\
      for nX,vX in pairs(buffer[layer]) do\\\
        for nY,vY in pairs(vX) do\\\
          buffer.changed[nX][nY] = buffer:getTop(nX,nY,layer-1)\\\
        end\\\
      end\\\
    else\\\
      for nX,vX in pairs(buffer[layer]) do\\\
        for nY,vY in pairs(vX) do\\\
          if buffer:getTop(nX,nY) == layer then\\\
            buffer.changed[nX][nY] = buffer:getTop(nX,nY,layer-1)\\\
          end\\\
        end\\\
      end\\\
    end\\\
    buffer[layer] = class.matrix.new(2)\\\
	end,\\\
  delPoint = function(buffer,x,y,layer)\\\
    layer = layer or buffer.layer\\\
    if layer == #buffer\\\
    or buffer:getTop(x,y) == layer then\\\
      buffer.changed[x][y] = buffer:getTop(x,y,layer-1)\\\
    end\\\
    buffer[layer][x][y] = nil\\\
  end,\\\
  refresh = function(buffer)\\\
    for x,vX in pairs(buffer.changed) do\\\
      for y,layer in pairs(vX) do\\\
        local c = buffer[layer][x][y]\\\
        term.setCursorPos(x,y)\\\
        term.setBackgroundColor(c.bColor)\\\
        term.setTextColor(c.tColor)\\\
        term.write(c.marker)\\\
      end\\\
    end\\\
    buffer:glassRefresh()\\\
    buffer.changed = class.matrix.new(2)\\\
    if buffer.blink then\\\
      term.setTextColor(buffer.tColor)\\\
      term.setCursorPos(buffer:getCursorPos())\\\
    end\\\
  end,\\\
  redraw = function(buffer)\\\
    for iY = 1,tTerm.screen.y do\\\
      term.setCursorPos(1,iY)\\\
      for iX = 1,tTerm.screen.x do\\\
        local c = buffer[buffer:getTop(iX,iY)][iX][iY]\\\
        term.setBackgroundColor(c.bColor)\\\
        term.setTextColor(c.tColor)\\\
        term.write(c.marker)\\\
      end\\\
    end\\\
    buffer:glassRedraw()\\\
  end,\\\
  glassInit = function(buffer,bridge,sizeX,sizeY,posX,posY)\\\
    bridge = bridge or buffer.bridge\\\
    if rawget(buffer,glass) then\\\
      buffer:glassClose()\\\
    end\\\
    buffer.glass = {\\\
      pixel = class.matrix.new(2),\\\
      text = class.matrix.new(2),\\\
    }\\\
    local textScale = ((sizeX+sizeY)/2)/8\\\
    local opacity = glasses.screen.opacity\\\
    for iX = 1,tTerm.screen.x do\\\
      local xPixel = buffer.glass.pixel[iX]\\\
      local xText = buffer.glass.text[iX]\\\
      local pX = ((iX-1)*sizeX)+posX\\\
      for iY = 1,tTerm.screen.y do\\\
        local pY = ((iY-1)*sizeY)+posY\\\
        xPixel[iY] = bridge.addBox(pX,pY,sizeX,sizeY,opacity)\\\
        xText[iY] = bridge.addText(pX,pY,\\\" \\\")\\\
        xText[iY].setScale(textScale)\\\
      end\\\
    end\\\
    local file = class.fileTable.new(tFile.settings)\\\
    local line = file:find(\\\"glasses = { --openP glass settings\\\",true)\\\
    file:write(\\\
[[      x = ]]..sizeX..[[,\\\
      y = ]]..sizeY..[[ \\\
    },\\\
    pos = { --where to render the glasses screen\\\
      x = ]]..posX..[[,\\\
      y = ]]..posY,\\\
      line+3\\\
    )\\\
    file:save()\\\
  end,\\\
  glassResize = function(buffer,x,y)\\\
    glasses.size.x = x\\\
    glasses.size.y = y\\\
    local textScale = ((x+y)/2)/8\\\
    for iX = 1,tTerm.screen.x do\\\
      local pX = iX*x\\\
      local xPixel = buffer.glass.pixel[iX]\\\
      local xText = buffer.glass.text[iX]\\\
      for iY = 1,tTerm.screen.y do\\\
        local pixel = xPixel[iY]\\\
        pixel.setHeight(y)\\\
        pixel.setWidth(x)\\\
        pixel.setX(pX)\\\
        pixel.setY(iY*y)\\\
        local text = xPixel[iY]\\\
        text.setScale(textScale)\\\
        text.setX(iX*x)\\\
        text.setY(iY*y)\\\
      end\\\
    end\\\
    local file = class.fileTable.new(tFile.settings)\\\
    local line = file:find(\\\"glasses = { --openP glass settings\\\",true)\\\
    file:write(\\\
[[      x = ]]..sizeX..[[,\\\
      y = ]]..sizeY,\\\
      line+3\\\
    )\\\
    file:save()\\\
  end,\\\
  glassRedraw = function(buffer)\\\
    if not buffer.glass then\\\
      return\\\
    end\\\
    for iX = 1,tTerm.screen.x do\\\
      for iY = 1,tTerm.screen.y do\\\
        buffer.glass.pixel[iX][iY].setColor(glasses.colors[buffer[buffer:getTop(iX,iY)][iX][iY].bColor])\\\
      end\\\
    end\\\
  end,\\\
  glassRefresh = function(buffer)\\\
    if not buffer.glass then\\\
      return\\\
    end\\\
    for x,vX in pairs(buffer.changed) do\\\
      local xLine = buffer.glass.text[x]\\\
      for y,layer in pairs(vX) do\\\
        local text = xLine[y]\\\
        if text then\\\
          local pixel = buffer[layer][x][y]\\\
          buffer.glass.pixel[x][y].setColor(glasses.colors[pixel.bColor])\\\
          text.setText(pixel.marker)\\\
          text.setColor(glasses.colors[pixel.tColor])\\\
        end\\\
      end\\\
    end\\\
  end,\\\
  glassOpacity = function(buffer,opacity)\\\
    if not buffer.glass then\\\
      return\\\
    end\\\
    for iX = 1,tTerm.screen.x do\\\
      for iY = 1,tTerm.screen.y do\\\
        buffer.glass.pixel[iX][iY].setOpacity(opacity)\\\
        buffer.glass.text[iX][iY].setAlpha(opacity)\\\
      end\\\
    end\\\
    local file = class.fileTable.new(tFile.settings)\\\
    local line = file:find(\\\"    opacity = %d%.?%d?%d?%d? %-%-screen transparency\\\")\\\
    file:write(\\\"    opacity = \\\"..opacity..\\\" --screen transparency\\\",line)\\\
    file:save()\\\
  end,\\\
  glassClose = function(buffer)\\\
    if not buffer.glass then\\\
      return\\\
    end\\\
    for iX = 1,tTerm.screen.x do\\\
      for iY = 1,tTerm.screen.y do\\\
        buffer.glass.pixel[iX][iY].delete()\\\
        buffer.glass.text[iX][iY].delete()\\\
      end\\\
    end\\\
    buffer.glass = nil\\\
  end\\\
}\\\
return screenBuffer\\\
\",\
    [ \"TAFiles/Classes/fileTable.Lua\" ] = \"local fileTable\\\
fileTable = { --file table class, this is used to simplify file handling\\\
  new = function(path)\\\
    local file = setmetatable(\\\
      {\\\
      \\\
      },\\\
      {\\\
        __index = fileTable\\\
      }\\\
    )\\\
    if path then\\\
      file:load(path)\\\
    end\\\
    return file\\\
  end,\\\
  load = function(tTable,filePath)\\\
    --loads the specified file into the table\\\
    local file = fs.open(filePath,\\\"r\\\")\\\
    if file then\\\
      for line in file.readLine do\\\
        tTable[#tTable+1] = line\\\
      end\\\
      file.close()\\\
    end\\\
    tTable.path = filePath\\\
  end,\\\
  save = function(tTable,filePath)\\\
    --saves the current table to the specified filePath\\\
    local file = fs.open(filePath or tTable.path,\\\"w\\\")\\\
    file.write(table.concat(tTable,\\\"\\\\n\\\"))\\\
    file.close()\\\
  end,\\\
  insert = function(tTable,line,lineNum)\\\
    --inserts the specified line into the table, optionally at the specified lineNum\\\
    lineNum = lineNum or #tTable+1\\\
    if type(line) == \\\"table\\\" then\\\
      for i=1,#line do\\\
        table.insert(tTable,line[i],lineNum+i-1)\\\
      end        \\\
    else\\\
      table.insert(tTable,line,lineNum)\\\
    end\\\
  end,\\\
  write = function(tTable,line,lineNum)\\\
    --write the specified line to the table, optionally at the specified lineNum\\\
    lineNum = lineNum or #tTable+1\\\
    if type(line) == \\\"table\\\" then\\\
      for i=1,#line do\\\
        tTable[lineNum+i-1] = line[i]\\\
      end\\\
      return\\\
    end\\\
    while line:match\\\"\\\\n.\\\" do --multi line\\\
      local newLine = line:match\\\"^(.-)\\\\n\\\"\\\
      line = line:sub(#newLine+2)\\\
      tTable[lineNum] = newLine\\\
      lineNum = lineNum+1\\\
    end\\\
    tTable[lineNum] = line\\\
  end,\\\
  find = function(tTable,sString,plain)\\\
    --finds the specified string in the file\\\
    for i,v in ipairs(tTable) do\\\
      if v:find(sString,1,plain) then\\\
        return i\\\
      end\\\
    end\\\
    return false\\\
  end,\\\
  delete = function(tTable,lineNum)\\\
    --clears the last line, or optionally the specified lineNum\\\
    if lineNum then\\\
      table.remove(tTable,lineNum)\\\
    else\\\
      tTable[#tTable] = nil\\\
    end\\\
  end,\\\
  read = function(tTable,lineNum)\\\
    --returns the last line, or optionally the specified lineNum\\\
    return tTable[lineNum or #tTable]\\\
  end,\\\
  readAll = function(tTable) --returns all lines as a single string, with newline characters.\\\
    return table.concat(tTable,\\\"\\\\n\\\")\\\
  end\\\
}\\\
return fileTable\\\
\",\
    [ \"TAFiles/Menus/mainMenus/Blueprint.Lua\" ] = \"local menu\\\
menu = {\\\
  enabled = true,\\\
  [1] = {\\\
    name = \\\"Create new...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Creates a new blueprint and unloads the current one.\\\"\\\
    end,\\\
    func = function()\\\
      local button, tRes, reInput = window.text(\\\
        \\\"Create new blueprint file...\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"File name\\\",\\\
            value = \\\"/\\\",\\\
            accepted = \\\".\\\"\\\
          }\\\
        },\\\
        false,\\\
        true\\\
      )\\\
      while button ~= \\\"Cancel\\\" do\\\
        local fileName = tRes[\\\"File name\\\"]\\\
        if not fileName then\\\
          button,tRes,reInput = reInput\\\"Invalid file name!\\\"\\\
        elseif fs.exists(fileName..\\\".TAb\\\") then\\\
          button,tRes,reInput = reInput(fileName..\\\" already exists!\\\")\\\
        else\\\
          tBlueprint = class.blueprint.new()\\\
          tFile.blueprint = fileName\\\
          scroll()\\\
          if tMode.layerBar then\\\
            renderLayerBar(true)\\\
          end\\\
          window.text(\\\"Successfully created \\\"..fileName..\\\".TAb.\\\")\\\
          return\\\
        end\\\
      end\\\
    end\\\
  },\\\
  [2] = {\\\
    name = \\\"Load...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Loads a previously saved blueprint.\\\"\\\
    end,\\\
    func = function()\\\
      local button, tRes, reInput = window.text(\\\
        \\\"Load blueprint file\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\",\\\
          \\\"Pastebin\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"File name\\\",\\\
            value = \\\"/\\\",\\\
            accepted = \\\".\\\"\\\
          },\\\
        },\\\
        false,\\\
        true\\\
      )\\\
      while button ~= \\\"Cancel\\\" do\\\
        local fileName = tRes[\\\"File name\\\"]\\\
        if button == \\\"Pastebin\\\" then\\\
          if not fileName then\\\
            button,tRes,reInput = reInput\\\"Missing pastebin code parameter!\\\"\\\
          else\\\
            fileName = fileName:match\\\"[^/]+\\\"\\\
            local paste\\\
            http.request(\\\"http://pastebin.com/raw.php?i=\\\"..fileName)\\\
            local dlStatus = window.text(\\\
              {\\\
                {\\\
                  text = \\\"Downloading \\\"..fileName..\\\".\\\",\\\
                  renderTime = 0.2\\\
                },\\\
                {\\\
                  text = \\\"Downloading \\\"..fileName..\\\"..\\\",\\\
                  renderTime = 0.2\\\
                },\\\
                {\\\
                  text = \\\"Downloading \\\"..fileName..\\\"...\\\",\\\
                  renderTime = 0.2\\\
                },\\\
              },\\\
              {\\\
                \\\"Cancel\\\"\\\
              },\\\
              nil,\\\
              {\\\
                http_success = function(tEvent)\\\
                  local web = tEvent[3]\\\
                  paste = {}\\\
                  local line = web.readLine()\\\
                  while line do\\\
                    paste[#paste+1] = line\\\
                    line = web.readLine()\\\
                  end\\\
                  web.close()\\\
                  return \\\"Success\\\"\\\
                end,\\\
                http_failure = function(tEvent)\\\
                  button,tRes,reInput = reInput(\\\"Pastebin download of \\\"..fileName..\\\" failed!\\\")\\\
                  return \\\"Failure\\\"\\\
                end\\\
              }\\\
            )\\\
            if dlStatus == \\\"Success\\\" then\\\
              local blueprint = tBlueprint.load(paste)\\\
              if not blueprint then\\\
                button,tRes,reInput = reInput(fileName..\\\" was not a Turtle Architect file!\\\")\\\
              else\\\
                tBlueprint = blueprint\\\
                scroll()\\\
                if tMode.layerBar then\\\
                  renderLayerBar(true)\\\
                end\\\
                sync({blueprint = tBlueprint,blueprintName = false},\\\"Blueprint load\\\")\\\
                window.text(\\\"Successfully downloaded \\\"..fileName..\\\"!\\\")\\\
                return\\\
              end\\\
            elseif dlStatus == \\\"Cancel\\\" then\\\
              button,tRes,reInput = reInput\\\"Load blueprint file\\\"\\\
            end\\\
          end\\\
        else\\\
          local blueprint = tBlueprint.load(fileName)\\\
          if not fileName then\\\
            button,tRes,reInput = reInput(\\\"Missing blueprint file name parameter!\\\")\\\
          elseif not fs.exists(fileName..\\\".TAb\\\") then\\\
            button,tRes,reInput = reInput(fileName..\\\" does not exist!\\\")\\\
          elseif not blueprint then\\\
            button,tRes,reInput = reInput(fileName..\\\" is not a blueprint file!\\\")\\\
          elseif button == \\\"Ok\\\" then\\\
            tFile.blueprint = fileName\\\
            tBlueprint = blueprint\\\
            scroll()\\\
            if tMode.layerBar then\\\
              renderLayerBar(true)\\\
            end\\\
            sync({blueprint = tBlueprint,blueprintName = fileName},\\\"Blueprint load\\\")\\\
            window.text(\\\"Successfully loaded \\\"..fileName..\\\".TAb.\\\")\\\
            return\\\
          end\\\
        end\\\
      end\\\
    end\\\
  },\\\
  [3] = {\\\
    name = \\\"Save\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Saves the current blueprint. If it has not been saved previously, a file name is requested\\\"\\\
    end,\\\
    func = function()\\\
      dialogue.save()\\\
    end\\\
  },\\\
  [4] = {\\\
    name = \\\"Save as...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Save the current blueprint with a new name, or upload it to pastebin\\\"\\\
    end,\\\
    func = function()\\\
      local button, tRes, reInput = window.text(\\\
        \\\"Save current blueprint as\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\",\\\
          \\\"Pastebin\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"File name\\\",\\\
            value = tFile.blueprint or \\\"/\\\",\\\
            accepted = \\\".\\\"\\\
          },\\\
        },\\\
        false,\\\
        true\\\
      )\\\
      while button ~= \\\"Cancel\\\" do\\\
        local fileName = tRes[\\\"File name\\\"]\\\
        if not fileName then\\\
          button,tRes,reInput = reInput(\\\"Invalid file name!\\\")\\\
        elseif button == \\\"Pastebin\\\" then\\\
          local upload = tBlueprint:save(true)\\\
          http.request(\\\
            \\\"http://pastebin.com/api/api_post.php\\\",\\\
            \\\"api_option=paste&\\\"..\\\
            \\\"api_dev_key=\\\"..tPaste.key..\\\"&\\\"..\\\
            \\\"api_paste_format=text&\\\"..\\\
            \\\"api_paste_name=\\\"..textutils.urlEncode(fileName or \\\"Untitled\\\")..\\\"&\\\"..\\\
            \\\"api_paste_code=\\\"..textutils.urlEncode(upload)\\\
          )\\\
          local ulStatus = window.text(\\\
            {\\\
              {\\\
                text = \\\"Uploading \\\"..fileName..\\\".\\\",\\\
                renderTime = 0.2\\\
              },\\\
              {\\\
                text = \\\"Uploading \\\"..fileName..\\\"..\\\",\\\
                renderTime = 0.2\\\
              },\\\
              {\\\
                text = \\\"Uploading \\\"..fileName..\\\"...\\\",\\\
                renderTime = 0.2\\\
              },\\\
            },\\\
            {\\\
              \\\"Cancel\\\"\\\
            },\\\
            nil,\\\
            {\\\
              http_success = function(tEvent)\\\
                local web = tEvent[3]\\\
                local sResponse = web.readAll()\\\
                web.close()      \\\
                local sCode = string.match( sResponse, \\\"[^/]+$\\\" )\\\
                window.text(\\\"Sucsessfully uploaded the blueprint to pastebin!\\\\nCode: \\\"..sCode..\\\" \\\\nURL: \\\"..sResponse)\\\
                return \\\"Success\\\"\\\
              end,\\\
              http_failure = function(tEvent)\\\
                button,tRes,reInput = reInput(\\\"Pastebin upload failed!\\\")\\\
                return \\\"Failure\\\"\\\
              end\\\
            }\\\
          )\\\
          if ulStatus == \\\"Success\\\" then\\\
            return\\\
          elseif ulStatus == \\\"Cancel\\\" then\\\
            button,tRes,reInput = reInput(\\\"Save current blueprint as\\\")\\\
          end\\\
        elseif fs.exists(fileName..\\\".TAb\\\") then\\\
          button,tRes,reInput = reInput(fileName..\\\" already exists!\\\")\\\
        else\\\
          tBlueprint:save(fileName)\\\
          tFile.blueprint = fileName\\\
          window.text(\\\"Successfully saved \\\"..fileName..\\\".TAb.\\\")\\\
          return\\\
        end\\\
      end\\\
    end\\\
  },\\\
  [5] = {\\\
    name = \\\"Send...\\\",\\\
    enabled = function()\\\
      return modem and true or false\\\
    end,\\\
    help = function()\\\
      window.text\\\"Transfer the currently loaded blueprint via rednet. This is only enabled if a modem is connected\\\"\\\
    end,\\\
    func = function()\\\
      local inRange = {}\\\
      rednet.send(\\\"All\\\",\\\"Ping\\\")\\\
      tTimers.scan.start()\\\
      local scanRes = window.text(\\\
        {\\\
          {\\\
            text = \\\"Scanning\\\",\\\
            renderTime = 0.2\\\
          },\\\
          {\\\
            text = \\\"Scanning.\\\",\\\
            renderTime = 0.2\\\
          },\\\
          {\\\
            text = \\\"Scanning..\\\",\\\
            renderTime = 0.2\\\
          },\\\
          {\\\
            text = \\\"Scanning...\\\",\\\
            renderTime = 0.2\\\
          },\\\
        },\\\
        {\\\
          \\\"Cancel\\\"\\\
        },\\\
        nil,\\\
        {\\\
          timer = function(tEvent)\\\
            if tTimers.scan.ids[tEvent[2]] then\\\
              return \\\"Done\\\"\\\
            end\\\
          end,\\\
          modem_message = function(tEvent)\\\
            if tEvent[3] == modemChannel\\\
            and type(tEvent[5]) == \\\"table\\\" --All Turtle Architect messages are sent as tables\\\
            and tEvent[5].rID[os.id] then\\\
              local data = tEvent[5]\\\
              if data.event == \\\"Success\\\"\\\
              and data.type == \\\"Ping\\\" then\\\
                inRange[#inRange+1] = {\\\
                  text = data.turtle and data.sID..\\\" - Turtle\\\" or data.sID..\\\" - Computer\\\"\\\
                }\\\
              end\\\
            end\\\
          end\\\
        }\\\
      )\\\
      if scanRes == \\\"Cancel\\\" then\\\
        return\\\
      end\\\
      if #inRange == 0 then\\\
        window.text\\\"No Turtle Architect computers in range!\\\"\\\
        return\\\
      end\\\
      local button,ids = window.scroll(\\\"Select IDs to transfer to:\\\",inRange,true)\\\
      if button == \\\"Cancel\\\" then\\\
        return\\\
      end\\\
      local transferIds = {}\\\
      for i,id in ipairs(ids) do\\\
        transferIds[tonumber(id:match\\\"%d+\\\")] = true\\\
      end\\\
      rednet.send(transferIds,\\\"Ping\\\",\\\
        {},\\\
        function(id)\\\
          rednet.send(id,\\\"Blueprint transmission\\\",\\\
            {\\\
              blueprint = tBlueprint,\\\
              blueprintName = tFile.blueprint or \\\"Untitled\\\"\\\
            }\\\
          )\\\
        end,\\\
        function(id)\\\
          window.text(\\\"Failed to connect to computer ID \\\"..id)\\\
        end\\\
      )\\\
    end\\\
  },\\\
  [6] = {\\\
    name = \\\"Flip...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Flip the entire blueprint vertically or horizontally\\\"\\\
    end,\\\
    func = function()\\\
      local button = window.text(\\\
        \\\"Flip the entire blueprint\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Horizontal\\\",\\\
          \\\"Vertical\\\"\\\
        }\\\
      )\\\
      if button == \\\"Horizontal\\\" then\\\
        tBlueprint:flipX()\\\
        scroll()\\\
        sync({dir = \\\"X\\\",blueprint = true},\\\"Flip\\\")\\\
      elseif button == \\\"Vertical\\\" then\\\
        tBlueprint:flipZ()\\\
        scroll()\\\
        sync({dir = \\\"Z\\\",blueprint = true},\\\"Flip\\\")\\\
      end\\\
    end\\\
  },\\\
  [7] = {\\\
    name = \\\"Rotate...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Rotate the blueprint along a coordinal axis (X, Y or Z).\\\"\\\
    end,\\\
    func = function()\\\
      local button,selected = window.scroll(\\\
        \\\"Select which axis to view from\\\",\\\
        {\\\
          {\\\
            text = \\\"X\\\",\\\
            selected = tBlueprint.orientation == \\\"X\\\"\\\
          },\\\
          {\\\
            text = \\\"Y\\\",\\\
            selected = tBlueprint.orientation == \\\"Y\\\",\\\
          },\\\
          {\\\
            text = \\\"Z\\\",\\\
            selected = tBlueprint.orientation == \\\"Z\\\"\\\
          }\\\
        }\\\
      )\\\
      if button == \\\"Cancel\\\" then\\\
        return\\\
      end\\\
      tBlueprint = tBlueprint:rotate(selected)\\\
      scroll(1,nil,nil,nil,true)\\\
      if tMode.layerBar then\\\
        renderLayerBar(true)\\\
      end\\\
    end\\\
  },\\\
  [8] = {\\\
    name = \\\"Edit slot data...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Change the slots used for the color currently equipped on the button you clicked with\\\"\\\
    end,\\\
    func = function(button)\\\
      assignColorSlots(tTool[button].color)\\\
      sync({colorSlots = tBlueprint.colorSlots},\\\"Colorslots load\\\")\\\
    end\\\
  },\\\
  [9] = {\\\
    name = \\\"Mark built\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Marks the entire blueprint as built, meaning the turtle will not build any of the currently drawn blocks.\\\\n\\\\nClear break markers?\\\"\\\
    end,\\\
    func = function()\\\
      local curLayer = tTerm.scroll.layer\\\
      local button, tRes = window.text(\\\
        \\\"Mark the entire blueprint as built. This means the turtle will not build it\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Yes\\\",\\\
          \\\"No\\\"\\\
        }\\\
      )\\\
      if button == \\\"Yes\\\" or button == \\\"Ok\\\" then\\\
        tBlueprint:markBuilt(nil,nil,nil,nil,true)\\\
        scroll()\\\
        sync({blueprint = true,clearBreak = true},\\\"Mark built\\\")\\\
      elseif button == \\\"No\\\" then\\\
        tBlueprint:markBuilt()\\\
        if tMode.builtRender then\\\
          scroll()\\\
        end\\\
        sync({blueprint = true},\\\"Mark built\\\")\\\
      end\\\
    end\\\
  },\\\
  [10] = {\\\
    name = \\\"Mark unbuilt\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Resets all build progress made on the blueprint, by marking every block as un-built\\\"\\\
    end,\\\
    func = function()\\\
      local curLayer = tTerm.scroll.layer\\\
      local button, tRes = window.text(\\\
        \\\"Mark the entire blueprint as unbuilt. This will reset any progress the turtle has made\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        }\\\
      )\\\
      if button == \\\"Ok\\\" then\\\
        tBlueprint:markUnbuilt()\\\
        if tMode.builtRender then\\\
          scroll()\\\
        end\\\
      end\\\
      sync({blueprint = true},\\\"Mark unbuilt\\\")\\\
    end\\\
  },\\\
  [11] = {\\\
    name = \\\"Check usage\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Check the materials required to build a given layer range\\\"\\\
    end,\\\
    func = function()\\\
      local tSelection = {}\\\
      for i=1,#tBlueprint do\\\
        tSelection[i] = {\\\
          text = tostring(i),\\\
          selected = true\\\
        }\\\
      end\\\
      local button, tRes = window.scroll(\\\
        \\\"Select layers to check usage for\\\",\\\
        tSelection,\\\
        true\\\
      )\\\
      if button ~= \\\"Cancel\\\" then\\\
        local tLayers = {}\\\
        for i,v in ipairs(tRes) do\\\
          tLayers[i] = tonumber(v)\\\
        end\\\
        local tLines = {\\\
          [1] = \\\"Materials required to build current blueprint\\\"\\\
        }\\\
        for k,v in pairs(checkUsage(tBlueprint,tLayers)) do\\\
          tLines[#tLines+1] = (keyColor[k] or k)..\\\": \\\"..v\\\
        end\\\
        window.text(tLines)\\\
      end\\\
    end\\\
  },\\\
}\\\
return menu\\\
\",\
    [ \"TAFiles/EventHandlers/cTurtle.Lua\" ] = \"local handler\\\
local tSlots = {}\\\
for i=1,16 do\\\
  tSlots[i] = \\\"Slot \\\"..i\\\
end\\\
handler = { --cTurtle only events\\\
  refuel = function()\\\
    if tMode.sync.amount > 0 then\\\
      rednet.send(tMode.sync.ids,\\\"Turtle status\\\",{type = \\\"Fuel required\\\",x = cTurtle.tPos.x,y = cTurtle.tPos.y,z = cTurtle.tPos.z})\\\
    end\\\
    tTimers.restockRetry.start()\\\
    local button,slot = window.scroll(\\\
      \\\"Fuel required, please select slot to refuel from and press Ok\\\",\\\
      tSlots,\\\
      false,\\\
      {\\\
        timer = function(tEvent)\\\
          if tTimers.restockRetry.ids[tEvent[2]] then\\\
            return \\\"timeout\\\"\\\
          end\\\
        end,\\\
        modem_message = function(tEvent)\\\
          if tEvent[3] == modemChannel\\\
          and _G.type(tEvent[5]) == \\\"table\\\"\\\
          and tEvent[5].rID[os.id] then\\\
            local data = tEvent[5]\\\
            if data.event == \\\"Turtle command\\\"\\\
            and data.type == \\\"Refuel\\\" then\\\
              return \\\"timeout\\\"\\\
            end\\\
          end\\\
        end\\\
      },\\\
      true\\\
    )\\\
    while button ~= \\\"timeout\\\" do\\\
      turtle.select(tonumber(slot:match\\\"%d+\\\"))\\\
      turtle.refuel(64)\\\
      return true\\\
    end\\\
  end,\\\
  blocked = 0, --amount of times the turtle has been blocked\\\
  moveFail = function() --movement blocked\\\
    handler.blocked = handler.blocked+1\\\
    if handler.blocked > 10\\\
    and tMode.sync.amount > 0 then\\\
      handler.blocked = 0\\\
      rednet.send(tMode.sync.ids,\\\"Turtle status\\\",{type = \\\"Blocked\\\",x = cTurtle.tPos.x,y = cTurtle.tPos.y,z = cTurtle.tPos.z})\\\
    end\\\
  end\\\
}\\\
return cTurtle\\\
\",\
    [ \"TAFiles/Menus/mainMenus/Sync.Lua\" ] = \"local menu\\\
menu = {\\\
  enabled = function()\\\
    return tMode.sync.amount > 0 and not turtle and true\\\
  end,\\\
  [1] = {\\\
    name = \\\"Move to...\\\",\\\
    enabled = function()\\\
      return tMode.sync.turtles > 0\\\
    end,\\\
    help = function()\\\
      window.text\\\"Move a synced turtle to the given coordinates\\\"\\\
    end,\\\
    func = function()\\\
      local id,nID = dialogue.selectTurtle(\\\"Select turtle ID to move\\\")\\\
      if not id then\\\
        return\\\
      end\\\
      local button,tRes,reInput = window.text(\\\
        \\\"Move turtle \\\"..nID..\\\" to coordinates...\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"X\\\",\\\
            value = \\\"\\\",\\\
            accepted = \\\"[-+%d]\\\"\\\
          },\\\
          {\\\
            name = \\\"Y\\\",\\\
            value = \\\"\\\",\\\
            accepted = \\\"[-+%d]\\\"\\\
          },\\\
          {\\\
            name = \\\"Z\\\",\\\
            value = \\\"\\\",\\\
            accepted = \\\"[-+%d]\\\"\\\
          }\\\
        },\\\
        false,\\\
        true\\\
      )\\\
      while button ~= \\\"Cancel\\\" do\\\
        local id = tRes.ID or id\\\
        if not tRes.X then\\\
          button,tRes,reInput = reInput\\\"Missing X Coordinate!\\\"\\\
        elseif not tRes.Y then\\\
          button,tRes,reInput = reInput\\\"Missing Y Coordinate!\\\"\\\
        elseif not tRes.Z then\\\
          button,tRes,reInput = reInput\\\"Missing Z Coordinate!\\\"\\\
        else\\\
          rednet.send(\\\
            id,\\\
            \\\"Turtle command\\\",\\\
            {\\\
              type = \\\"Move\\\",\\\
              x = tRes.X,\\\
              y = tRes.Y,\\\
              z = tRes.Z\\\
            }\\\
          )\\\
          return\\\
        end\\\
      end\\\
    end\\\
  },\\\
  [2] = {\\\
    name = \\\"Turn\\\",\\\
    enabled = function()\\\
      return tMode.sync.turtles > 0 and true\\\
    end,\\\
    help = function()\\\
      window.text\\\"Turn a synced turtle in the given direction. Most forms of directions are supported, like x+,north or right\\\"\\\
    end,\\\
    func = function()\\\
      local id,nID = dialogue.selectTurtle(\\\"Select turtle ID to turn\\\")\\\
      if not id then\\\
        return\\\
      end\\\
      local button, tRes, reInput = window.text(\\\
        \\\"Turn turtle \\\"..nID..\\\"...\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"Direction\\\",\\\
            value = \\\"\\\",\\\
            accepted = \\\".\\\"\\\
          }\\\
        },\\\
        false,\\\
        true\\\
      )\\\
      while button ~= \\\"Cancel\\\" do\\\
        if not tRes.Direction then\\\
          button,tRes,reInput = reInput\\\"Missing turn direction!\\\"\\\
        else\\\
          rednet.send(\\\
            id,\\\
            \\\"Turtle command\\\",\\\
            {\\\
              type = \\\"Turn\\\",\\\
              dir = tRes.Direction\\\
            }\\\
          )\\\
          return\\\
        end\\\
      end\\\
    end\\\
  },\\\
  [3] = {\\\
    name = \\\"Build blueprint...\\\",\\\
    enabled = function()\\\
      return tMode.sync.turtles > 0 and true\\\
    end,\\\
    help = function()\\\
      window.text\\\"Makes synced turtles build the currently loaded blueprint\\\"\\\
    end,\\\
    func = function()\\\
      if not dialogue.save\\\"Blueprint must be saved locally prior to building!\\\" then\\\
        window.text\\\"Construction cancelled\\\"\\\
        return\\\
      end\\\
      local ids, turtleAmount = dialogue.selectTurtle(\\\"Select turtle IDs to use for building\\\",true)\\\
      if not ids then\\\
        return\\\
      end\\\
      local tProgress = checkProgress(tFile.blueprint,false,tBlueprint)\\\
      if not tProgress then\\\
        return\\\
      end\\\
      local button = window.text(\\\
        \\\"Enable auto resume?\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        }\\\
      )\\\
      local autoRecovery = button == \\\"Ok\\\"\\\
      rednet.send(\\\
        ids,\\\
        \\\"Turtle command\\\",\\\
        {\\\
          type = \\\"Save blueprint progress\\\",\\\
          progress = tProgress,\\\
          blueprintName = tFile.blueprint\\\
        }\\\
      )\\\
      rednet.send(\\\
        ids,\\\
        \\\"Sync edit\\\",\\\
        {\\\
          type = \\\"Colorslots load\\\",\\\
          colorSlots = tBlueprint.colorSlots\\\
        }\\\
      )\\\
      local layers,x,z = tBlueprint:size()\\\
      local xChunks = math.ceil(x/turtleAmount)\\\
      local xNext = 0\\\
      for id in pairs(ids) do\\\
        rednet.send(\\\
          id,\\\
          \\\"Sync edit\\\",\\\
          {\\\
            type = \\\"Blueprint sub\\\",\\\
            sX = xNext+1,\\\
            sZ = 1,\\\
            eX = xNext+xChunks,\\\
            eZ = z,\\\
          }\\\
        )\\\
        xNext = xNext+xChunks\\\
      end\\\
      rednet.send(ids,\\\"Turtle command\\\",{type = \\\"Build\\\", auto = autoRecovery})\\\
    end\\\
  }\\\
}\\\
return menu\\\
\",\
    [ \"TAFiles/Tools/Brush.Lua\" ] = \"local tool\\\
tool = {\\\
  menuOrder = 1, --menu order, 1 being top\\\
  enabled = true,\\\
  help = function(clickButton)\\\
    local button = window.text(\\\
      \\\"The brush tool is the simplest tool, it merely draws a single block of your chosen color\\\",\\\
      {\\\
        \\\"Ok\\\",\\\
        \\\"Equip\\\"\\\
      }\\\
    )\\\
    if button == \\\"Equip\\\" then\\\
      tool.selectFunc(clickButton)\\\
    end\\\
  end,\\\
  selectFunc = function(button)\\\
    tTool.change(\\\"Brush\\\",button)\\\
  end,\\\
  renderFunc = function(event,button,x,z,color,layer)\\\
    drawPoint(x,z,color,layer)\\\
    sync(\\\
      {\\\
        layer = tTerm.scroll.layer,\\\
        x = x+tTerm.scroll.x,\\\
        z = z+tTerm.scroll.z,\\\
        color = color\\\
      },\\\
      \\\"Point\\\"\\\
    )\\\
  end,\\\
  codeFunc = function(x,z,color,layer)\\\
    if not (type(x) == \\\"number\\\" and type(z) == \\\"number\\\") then\\\
      error(\\\"Expected number,number\\\",2)\\\
    end\\\
    color = color or codeEnv.click.color\\\
    layer = layer or codeEnv.click.layer\\\
    local layerType = type(layer)\\\
    if layerType == \\\"table\\\" and layer.paste then\\\
      layer[x][z] = color\\\
    elseif layerType == \\\"number\\\" then\\\
      if codeEnv.settings.direct then\\\
        drawPoint(x,z,color,layer,true)\\\
      else\\\
        codeEnv.blueprint[layer][x][z] = color\\\
      end\\\
    else\\\
      error(\\\"Expected layer, got \\\"..layerType,2)\\\
    end\\\
  end\\\
}\\\
return tool\\\
\",\
    [ \"TAFiles/Menus/rightClick/select.Lua\" ] = \"local menu\\\
menu = {\\\
  [1] = {\\\
    name = \\\"Cut\\\",\\\
    enabled = function()\\\
      return tTool.select.eX and true\\\
    end,\\\
    select = true,\\\
    help = function()\\\
      window.text\\\"Copies the current selection into the clipboard, and deletes it from the canvas\\\"\\\
    end,\\\
    func = function()\\\
      local t = tTool.select\\\
      tTool.clipboard = tBlueprint[t.layer]:copy(t.sX,t.sZ,t.eX,t.eZ,true)\\\
      sync(t,\\\"Delete\\\")\\\
      tBlueprint[t.layer]:delete(t.sX,t.sZ,t.eX,t.eZ)\\\
      renderArea(t.sX,t.sZ,t.eX,t.eZ,true)\\\
      tTool.select = {}\\\
    end\\\
  },\\\
  [2] = {\\\
    name = \\\"Copy\\\",\\\
    enabled = function()\\\
      return tTool.select.eX and true\\\
    end,\\\
    help = function()\\\
      window.text\\\"Copies the current selection into the clipboard\\\"\\\
    end,\\\
    func = function()\\\
      local t = tTool.select\\\
      tTool.clipboard = tBlueprint[t.layer]:copy(t.sX,t.sZ,t.eX,t.eZ,true)\\\
      tTool.select = {}\\\
      screen:clearLayer(screen.layers.toolsOverlay)\\\
      local c = tTool.clipboard\\\
      c.sX = c.sX+1\\\
      c.sZ = c.sZ+1\\\
      c.eX = c.eX+1\\\
      c.eZ = c.eZ+1\\\
      renderToolOverlay()\\\
    end\\\
  },\\\
  [3] = {\\\
    name = \\\"Paste\\\",\\\
    enabled = function()\\\
      return tTool.clipboard and true\\\
    end,\\\
    help = function()\\\
      window.text\\\"Draws the current clipboard to the blueprint\\\"\\\
    end,\\\
    func = function()\\\
      local c = tTool.clipboard\\\
      c.layer = tTerm.scroll.layer\\\
      sync(c,\\\"Paste\\\")\\\
      tBlueprint[tTerm.scroll.layer]:paste(c.l,c.sX,c.sZ,not tMode.overwrite)\\\
      renderArea(c.sX,c.sZ,c.eX,c.eZ,true)\\\
      c.sX = c.sX+1\\\
      c.sZ = c.sZ+1\\\
      c.eX = c.eX+1\\\
      c.eZ = c.eZ+1\\\
      renderToolOverlay()\\\
    end\\\
  },\\\
  [4] = {\\\
    name = \\\"Recolor\\\",\\\
    enabled = function()\\\
      return tTool.select.eX and true or tTool.clipboard and true\\\
    end,\\\
    help = function()\\\
      window.text\\\"Recolors the currently selected area or the clipboard, to color equipped on the button you pressed with\\\"\\\
    end,\\\
    func = function(button)\\\
      local c = tTool.clipboard\\\
      local color = tTool[button].color\\\
      if c then\\\
        c.l:recolor(color,1,1,c.lX,c.lZ)\\\
        renderToolOverlay()\\\
      else\\\
        local t = tTool.select\\\
        sync(t,\\\"Recolor\\\")\\\
        tBlueprint[t.layer]:recolor(color,t.sX,t.sZ,t.eX,t.eZ)\\\
        renderArea(t.sX,t.sZ,t.eX,t.eZ,true)\\\
      end\\\
    end\\\
  },\\\
  [5] = {\\\
    name = \\\"Flip vert\\\",\\\
    enabled = function()\\\
      return tTool.select.eX and true or tTool.clipboard and true\\\
    end,\\\
    help = function()\\\
      window.text\\\"Flips the current selection or clipboard vertically(Z)\\\"\\\
    end,\\\
    func = function()\\\
      local t = tTool.select\\\
      local c = tTool.clipboard\\\
      if t.eX then\\\
        local layer = tBlueprint[t.layer]\\\
\\\
        term.setTextColor(colors.blue)\\\
\\\
        local flip = layer:copy(t.sX,t.sZ,t.eX,t.eZ,true):flipZ(t.sX,t.sZ,t.eX,t.eZ)\\\
        layer:paste(flip,t.sX,t.sZ)\\\
        renderArea(t.sX,t.sZ,t.eX,t.eZ,true)\\\
      else\\\
        c.l = c.l:flipZ(1,1,c.lX,c.lZ)\\\
        renderToolOverlay()\\\
      end\\\
    end\\\
  },\\\
  [6] = {\\\
    name = \\\"Flip hori\\\",\\\
    enabled = function()\\\
      return tTool.select.eX and true or tTool.clipboard and true\\\
    end,\\\
    help = function()\\\
      window.text\\\"Flips the current selection or clipboard horizontally(X)\\\"\\\
    end,\\\
    func = function()\\\
      local t = tTool.select\\\
      local c = tTool.clipboard\\\
      if t.eX then\\\
        local layer = tBlueprint[t.layer]\\\
        local flip = layer:copy(t.sX,t.sZ,t.eX,t.eZ,true):flipX(t.sX,t.sZ,t.eX,t.eZ)\\\
        layer:paste(flip,t.sX,t.sZ)\\\
        renderArea(t.sX,t.sZ,t.eX,t.eZ,true)\\\
      else\\\
        c.l = c.l:flipX(1,1,c.lX,c.lZ)\\\
        renderToolOverlay()\\\
      end\\\
    end\\\
  },\\\
  [7] = {\\\
    name = \\\"Mark built\\\",\\\
    enabled = function()\\\
      return tTool.select.eX and true or tTool.clipboard and true\\\
    end,\\\
    help = function()\\\
      window.text\\\"Marks the current selection or clipboard as built, thus making the turtle skip it\\\"\\\
    end,\\\
    func = function()\\\
      local t = tTool.select\\\
      local c = tTool.clipboard\\\
      if t.eX then\\\
        sync(t,\\\"Mark built\\\")\\\
        tBlueprint[t.layer]:markBuilt(t.sX,t.sZ,t.eX,t.eZ)\\\
        if tMode.renderBuilt then\\\
          renderArea(t.sX,t.sZ,t.eX,t.eZ,true)\\\
        end\\\
      else\\\
        c.l:markBuilt(1,1,c.lX,c.lZ)\\\
        renderToolOverlay()\\\
      end\\\
    end\\\
  },\\\
  [8] = {\\\
    name = \\\"Mark unbuilt\\\",\\\
    enabled = function()\\\
      return tTool.select.eX and true or tTool.clipboard and true\\\
    end,\\\
    help = function()\\\
      window.text\\\"Resets any build progress made within the current selection or clipboard\\\"\\\
    end,\\\
    func = function()\\\
      local t = tTool.select\\\
      local c = tTool.clipboard\\\
      if t.eX then\\\
        sync(t,\\\"Mark unbuilt\\\")\\\
        tBlueprint[t.layer]:markUnbuilt(t.sX,t.sZ,t.eX,t.eZ)\\\
        if tMode.renderBuilt then\\\
          renderArea(t.sX,t.sZ,t.eX,t.eZ,true)\\\
        end\\\
      else\\\
        c.l:markUnbuilt(1,1,c.lX,c.lZ)\\\
        renderToolOverlay()\\\
      end\\\
    end\\\
  },\\\
  [9] = {\\\
    name = \\\"Delete\\\",\\\
    enabled = function()\\\
      return tTool.select.eX and true or tTool.clipboard and true\\\
    end,\\\
    help = function()\\\
      window.text\\\"Removes the current selection from the blueprint, or clears the clipbord\\\"\\\
    end,\\\
    func = function()\\\
      local t = tTool.select\\\
      local c = tTool.clipboard\\\
      if t.eX then\\\
        sync(t,\\\"Delete\\\")\\\
        tBlueprint[t.layer]:delete(t.sX,t.sZ,t.eX,t.eZ)\\\
        renderArea(t.sX,t.sZ,t.eX,t.eZ,true)\\\
      else\\\
        tTool.clipboard = false\\\
        screen:clearLayer(screen.layers.toolsOverlay)\\\
      end\\\
    end\\\
  },\\\
}\\\
\\\
return menu\\\
\",\
    [ \"TAFiles/Functions/Render.lua\" ] = \"function toggleMenus(FORCE) --Hides/reveals menus, FORCE reveal.\\\
  local cX,cZ = 2,1 --cavnas size change\\\
  if tMode.hideMenus or FORCE then --reveal\\\
    tMode.hideMenus = false\\\
    renderSideBar()\\\
    renderBottomBar()\\\
    if tMode.layerBar then\\\
      openLayerBar()\\\
    end\\\
    local change = tMode.layer\\\
    tTerm.canvas.eX = tTerm.canvas.eX-cX\\\
    tTerm.canvas.tX = tTerm.canvas.eX-tTerm.canvas.sX+1\\\
    tTerm.canvas.eZ = tTerm.canvas.eZ-cZ\\\
    tTerm.canvas.tZ = tTerm.canvas.eZ-tTerm.canvas.sZ+1\\\
    tTerm.viewable.eX = tTerm.viewable.eX-cX\\\
    tTerm.viewable.eZ = tTerm.viewable.eZ-cZ\\\
    if tMode.grid then\\\
      renderGrid()\\\
    end\\\
  else --hide\\\
    if tMode.layerBar then\\\
      cX = cX+1\\\
    end\\\
    screen:clearLayer(screen.layers.bottomBar or screen.layers.sideBar or screen.layers.layerBar) --they all use the same layer\\\
    if tMode.grid then --the grid border is on the same layer as the menus, and must be re-rendered\\\
      removeGrid()\\\
    end\\\
    tBar.touchMap = class.matrix.new(2)\\\
    tTerm.canvas.eX = tTerm.canvas.eX+cX\\\
    tTerm.canvas.tX = tTerm.canvas.eX-tTerm.canvas.sX+1\\\
    tTerm.canvas.eZ = tTerm.canvas.eZ+cZ\\\
    tTerm.canvas.tZ = tTerm.canvas.eZ-tTerm.canvas.sZ+1\\\
    tTerm.viewable.eX = tTerm.viewable.eX+cX\\\
    tTerm.viewable.eZ = tTerm.viewable.eZ+cZ\\\
    tMode.hideMenus = true\\\
  end\\\
  scroll()\\\
end\\\
\\\
function renderGrid() --renders grid overlay and borders\\\
  local canvas = tTerm.canvas\\\
  screen:setLayer(screen.layers.gridBorder)\\\
  screen:setCursorPos(1,1)\\\
  screen:setBackgroundColor(tColors.gridBorder)\\\
  screen:setTextColor(tColors.gridBorderText)\\\
  screen:write\\\" \\\"\\\
  local nextChar = 1\\\
  for i=2,canvas.eX do\\\
    screen:write(string.format(nextChar))\\\
    nextChar = (nextChar < 9 and nextChar+1 or 0)\\\
  end\\\
  screen:setCursorPos(1,2)\\\
  nextChar = 1\\\
  for i=2,canvas.eZ do\\\
    screen:setCursorPos(1,i)\\\
    screen:write(string.format(nextChar))\\\
    nextChar = (nextChar < 9 and nextChar+1 or 0)\\\
  end\\\
  canvas.sX = canvas.sX+1\\\
  canvas.tX = canvas.eX-canvas.sX\\\
  canvas.sZ = canvas.sZ+1\\\
  canvas.tZ = canvas.eZ-canvas.sZ\\\
  local view = tTerm.viewable\\\
  view.mX = view.mX+1\\\
  view.mZ = view.mZ+1\\\
  view.eX = view.sX+tTerm.canvas.tX\\\
  view.eZ = view.sZ+tTerm.canvas.tZ\\\
  scroll()\\\
  tBlueprint[tTerm.scroll.layer]:render()\\\
end\\\
\\\
function removeGrid() --removes the grid border and overlay\\\
  local canvas = tTerm.canvas\\\
  canvas.sX = canvas.sX-1\\\
  canvas.tX = canvas.eX-canvas.sX\\\
  canvas.sZ = canvas.sZ-1\\\
  canvas.tZ = canvas.eZ-canvas.sZ\\\
  local view = tTerm.viewable\\\
  view.mX = view.mX-1\\\
  view.mZ = view.mZ-1\\\
  view.eX = view.sX+tTerm.canvas.tX\\\
  view.eZ = view.sZ+tTerm.canvas.tZ\\\
  for i=1,canvas.eX do\\\
    screen:delPoint(i,1,screen.layers.gridBorder)\\\
  end\\\
  for i=1,canvas.eZ do\\\
    screen:delPoint(1,i,screen.layers.gridBorder)\\\
  end\\\
  scroll()\\\
end\\\
\\\
function renderBottomBar() --renders bottom bar and updates info\\\
  if tMode.hideMenus then\\\
    return\\\
  end\\\
  screen:setLayer(screen.layers.bottomBar)\\\
  screen:setCursorPos(1,tTerm.screen.y)\\\
  local bgColor = tColors.bottomBar\\\
  screen:setBackgroundColor(bgColor)\\\
  screen:setTextColor(tColors.toolText)\\\
  local toolColor = colorKey[tTool[1].color]\\\
  screen:write(\\\"T1: \\\")\\\
  screen:setTextColor(toolColor)\\\
  if toolColor == bgColor then\\\
    screen:setBackgroundColor(tColors.toolText)\\\
  end\\\
  screen:write(tTool[1].tool)\\\
  screen:setBackgroundColor(bgColor)\\\
  screen:setTextColor(tColors.toolText)\\\
  screen:write(\\\" T2: \\\")\\\
  toolColor = colorKey[tTool[2].color]\\\
  screen:setTextColor(toolColor)\\\
  if toolColor == bgColor then\\\
    screen:setBackgroundColor(tColors.toolText)\\\
  end\\\
  screen:write(tTool[2].tool)\\\
  screen:setTextColor(tColors.coordsText)\\\
  screen:setBackgroundColor(bgColor)\\\
  local cursX,cursY = screen:getCursorPos()\\\
  local coordString = \\\"Pos=(\\\"..tTerm.scroll.x..\\\", \\\"..tTerm.scroll.layer..\\\", \\\"..tTerm.scroll.z..\\\")\\\"\\\
  -- add csAmend\\\
  coordString = (tTerm.misc.csAmend or \\\"\\\") .. \\\" \\\" .. coordString\\\
  -- add csMousePos\\\
  coordString = (tTerm.misc.csMousePos or \\\"\\\") .. \\\" \\\" .. coordString\\\
\\\
  local screenX = tBar.menu.sizeReduction and tTerm.screen.x-4 or tTerm.screen.x-2\\\
  screen:write(string.rep(\\\" \\\",math.max(screenX-#coordString-cursX+1,0))..coordString)\\\
\\\
  for iX = screenX-#coordString+1,screenX do\\\
    tBar.touchMap[iX][cursY] = function(button)\\\
      if tTool[button].tool == \\\"Help\\\" then\\\
        window.text\\\"These are the current view coordinates.\\\\nX is left and right.\\\\nZ is up and down.\\\\nY is the current layer.\\\\nClicking these without the help tool equipped will allow you to input them directly\\\"\\\
      else\\\
        local button, tRes, reInput = window.text(\\\
          \\\"Go to\\\",\\\
          {\\\
            \\\"Ok\\\",\\\
            \\\"Cancel\\\"\\\
          },\\\
          {\\\
            {\\\
              name = \\\"X\\\",\\\
              value = tTerm.scroll.x,\\\
              accepted = \\\"%d\\\"\\\
            },\\\
            {\\\
              name = \\\"Y\\\",\\\
              value = tTerm.scroll.layer,\\\
              accepted = \\\"%d\\\"\\\
            },\\\
            {\\\
              name = \\\"Z\\\",\\\
              value = tTerm.scroll.z,\\\
              accepted = \\\"%d\\\"\\\
            }\\\
          },\\\
          false,\\\
          true\\\
        )\\\
        while button ~= \\\"Cancel\\\" do\\\
          if not tBlueprint[tRes.Y] then\\\
            button, tRes, reInput = reInput(\\\"The layer \\\"..tRes.Y..\\\" does not exist!\\\\n The current top layer is \\\"..#tBlueprint)\\\
          else\\\
            scroll(tRes.Y,tRes.X,tRes.Z,true)\\\
            return\\\
          end\\\
        end\\\
      end\\\
    end\\\
  end\\\
end\\\
\\\
function renderMenu(menu) --renders the given menu and activates the touch map for said menu\\\
  tMenu.touchMap = class.matrix.new(2)\\\
  screen:clearLayer(screen.layers.menus)\\\
  if not menu \\\
  or not tMenu.main[menu] and not tMenu.rightClick[menu]\\\
  or tMenu.main[menu] and (not tMenu.main[menu].enabled or type(tMenu.main[menu].enabled) == \\\"function\\\" and not tMenu.main[menu].enabled()) then\\\
    tMenu.open = false\\\
    return\\\
  elseif tMenu.rightClick[menu] then\\\
    tMenu.open = menu\\\
    tMenu.rightClick.render(menu)\\\
    return\\\
  end\\\
  tMenu.open = menu\\\
  menu = tMenu.main[menu]\\\
  screen:setLayer(screen.layers.menus)\\\
  screen:setBackgroundColor(tColors.menuTop)\\\
  screen:setTextColor(tColors.enabledMenuText)\\\
  screen:setCursorPos(menu.sX,menu.sY)\\\
  local extraSpaces = string.rep(\\\" \\\",math.ceil((menu.eX-menu.sX-#menu.string)/2))\\\
  local menuString = extraSpaces..menu.string..extraSpaces\\\
  if #menuString > menu.lX*menu.splits then\\\
    menuString = menuString:sub(2)\\\
  end\\\
  screen:write(menuString)\\\
  for iX = menu.sX,menu.sX+#menuString do\\\
    tMenu.touchMap[iX][menu.sY] = true --clicking the header does nothing, currently\\\
  end\\\
  local nextMenu = 0\\\
  for split=1,menu.splits do\\\
    local sX = menu.eX-(menu.lX*split)\\\
    for i=1,math.ceil(#menu.items/menu.splits) do\\\
      nextMenu = nextMenu+1\\\
      if not menu.items[nextMenu] then\\\
        break\\\
      end\\\
      local iMenu = nextMenu\\\
      local sY = menu.sY+i\\\
      local enabled = menu.items[iMenu].enabled\\\
      if type(enabled) == \\\"function\\\" then\\\
        enabled = enabled()\\\
      end\\\
      screen:setBackgroundColor(i%2 == 0 and tColors.menuPri or tColors.menuSec)\\\
      screen:setTextColor(enabled and tColors.enabledMenuText or tColors.disabledMenuText)\\\
      screen:setCursorPos(sX,sY)\\\
      screen:write(menu.items[iMenu].string)\\\
      local help = menu.items[iMenu].help\\\
      local helpFunc = (\\\
        help\\\
        and function(button)\\\
          return tTool[button].tool == \\\"Help\\\" and (help() or true)\\\
        end\\\
        or function(button)\\\
          return tTool[button].tool == \\\"Help\\\" and window.text(menu.items[iMenu].name..\\\"\\\\ndosen't have a help function. Please define it in the menu file as \\\\\\\"help\\\\\\\"\\\") and true\\\
        end\\\
      )\\\
      local menuFunc = function(button)\\\
        if not helpFunc(button) then\\\
          renderMenu()\\\
          menu.items[iMenu].func(button)\\\
        end\\\
      end\\\
      for iX = sX,sX+menu.lX-1 do\\\
        tMenu.touchMap[iX][sY] = enabled and menuFunc or helpFunc --true prevents the touchmap func from closing the menu\\\
      end\\\
    end\\\
  end\\\
end\\\
\\\
local layerBarClick = function(button,x,z) --touch map layer bar function\\\
  local layerBar = tBar.layerBar\\\
  if tTool[button].tool == \\\"Help\\\" then\\\
    window.text\\\"This is the layer bar.\\\\nLeft click any layer here to instantly scroll to it.\\\\nOr use the ctrl and shift keys to select multiple layers, which may then be manipulated by right clickling.\\\\nYou can also scroll the menu up and down using a mouse wheel.\\\"\\\
    return\\\
  elseif tMenu.open then\\\
    renderMenu()\\\
    return\\\
  end\\\
  local layer = layerBar.eZ-z+layerBar.sL\\\
  if button == 1 and tBlueprint[layer] then\\\
    if tTimers.shift.pressed then\\\
      if layerBar.prevSelected > 0 then\\\
        layerBar.tSelected = {}\\\
        local bottomSel = math.min(layerBar.prevSelected,layer)\\\
        local topSel = math.max(layerBar.prevSelected,layer)\\\
        for i = bottomSel,topSel do\\\
          layerBar.tSelected[i] = true\\\
        end\\\
        layerBar.selectedAmt = topSel-bottomSel+1\\\
        renderLayerBar()\\\
      end\\\
    elseif tTimers.ctrl.lPressed or tTimers.ctrl.rPressed then\\\
      if layerBar.tSelected[layer] then\\\
        layerBar.tSelected[layer] = nil\\\
        layerBar.selectedAmt = layerBar.selectedAmt-1\\\
        layerBar.prevSelected = layerBar.selectedAmt == 0 and 0 or layer\\\
      else\\\
        layerBar.tSelected[layer] = true\\\
        layerBar.selectedAmt = layerBar.selectedAmt+1\\\
        layerBar.prevSelected = layer\\\
      end\\\
      renderLayerBar()\\\
    else\\\
      layerBar.tSelected = {\\\
        [layer] = true\\\
      }\\\
      scroll(layer,nil,nil,nil,true)\\\
      layerBar.selectedAmt = 1\\\
      layerBar.prevSelected = layer\\\
      renderLayerBar()\\\
    end\\\
  elseif button == 2 then --right click\\\
    if tMenu.open then\\\
      renderMenu()\\\
    else\\\
      if tBlueprint[layer] and not layerBar.tSelected[layer] then\\\
        layerBar.tSelected = {\\\
          [layer] = true\\\
        }\\\
        layerBar.prevSelected = layer\\\
        layerBar.selectedAmt = layer\\\
        scroll(layer)\\\
      end\\\
      tMenu.rightClick.render(\\\"layerBar\\\",x,z)\\\
    end\\\
  end\\\
end\\\
\\\
function renderLayerBar(fullRefresh) --updates the layer sidebar, optionally redrawing it entirely\\\
  if tMode.hideMenus then\\\
    return\\\
  end\\\
  if not tMode.layerBar then\\\
    return\\\
  end\\\
  local layerBar = tBar.layerBar\\\
  screen:setTextColor(tColors.layerBarText)\\\
  local tSelected = layerBar.tSelected\\\
  screen:setLayer(screen.layers.layerBar)\\\
  tBar.touchMap[layerBar.eX-1][layerBar.eZ] = nil\\\
  tBar.touchMap[layerBar.eX-2][layerBar.eZ] = nil\\\
  screen:delPoint(layerBar.eX-1,layerBar.eZ)\\\
  screen:delPoint(layerBar.eX-2,layerBar.eZ)\\\
  if fullRefresh then\\\
    screen:drawLine(layerBar.sX,layerBar.sZ,layerBar.eX,layerBar.eZ,tColors.layerBar)\\\
    layerBar.eL = layerBar.eL-layerBar.sL+1\\\
    layerBar.sL = 1\\\
  end\\\
  local indicatorLength = #string.format(layerBar.sL)\\\
  for iX = 2,indicatorLength do\\\
    tBar.touchMap[layerBar.eX-iX+1][layerBar.eZ] = layerBarClick\\\
  end\\\
  screen:setCursorPos(layerBar.eX-indicatorLength+1,layerBar.eZ)\\\
  screen:setBackgroundColor(\\\
    layerBar.sL == tTerm.scroll.layer and (tSelected[layerBar.sL] and tColors.layerBarViewSelected or tColors.layerBarViewUnselected) \\\
    or tSelected[layerBar.sL] and tColors.layerBarSelected \\\
    or tColors.layerBarUnselected\\\
  )\\\
  screen:write(layerBar.sL)\\\
  local curs = 1\\\
  for layer = layerBar.sL+1,layerBar.eL do\\\
    if tBlueprint[layer] then\\\
      screen:setBackgroundColor(\\\
        layer == tTerm.scroll.layer and (tSelected[layer] and tColors.layerBarViewSelected or tColors.layerBarViewUnselected) \\\
        or tSelected[layer] and tColors.layerBarSelected \\\
        or tColors.layerBarUnselected\\\
      )\\\
      screen:setCursorPos(layerBar.sX,layerBar.eZ-curs)\\\
      screen:write(string.match(layer,\\\".$\\\"))\\\
      curs = curs+1\\\
    else\\\
      break\\\
    end\\\
  end\\\
end\\\
\\\
function openLayerBar() --renders the layer sidebar and adds it to the touch map\\\
  tMode.layerBar = true\\\
  if tMode.hideMenus then\\\
    return\\\
  end\\\
  local layerBar = tBar.layerBar\\\
  local x = tBar.layerBar.eX\\\
  for y = tBar.layerBar.sL,tBar.layerBar.eL do\\\
    tBar.touchMap[x][y] = layerBarClick\\\
  end\\\
  renderLayerBar(true)\\\
  local canvas = tTerm.canvas\\\
  canvas.eX = canvas.eX-1\\\
  canvas.tX = canvas.eX-canvas.sX\\\
  local view = tTerm.viewable\\\
  view.eX = view.sX+canvas.tX\\\
  renderSideBar()\\\
  scroll()\\\
end\\\
\\\
function closeLayerBar() --closes the layer sidebar and removes it from the touch map\\\
  tMode.layerBar = false\\\
  if tMode.hideMenus then\\\
    return\\\
  end\\\
  local canvas = tTerm.canvas\\\
  canvas.eX = canvas.eX+1\\\
  canvas.tX = canvas.eX-canvas.sX\\\
  local view = tTerm.viewable\\\
  view.eX = view.sX+canvas.tX\\\
  local iX = tBar.layerBar.eX\\\
  screen:delPoint(iX-1,tBar.layerBar.eZ,screen.layers.layerBar)\\\
  screen:delPoint(iX-2,tBar.layerBar.eZ,screen.layers.layerBar)\\\
  tBar.touchMap[iX-1][tBar.layerBar.eZ] = nil\\\
  tBar.touchMap[iX-2][tBar.layerBar.eZ] = nil\\\
  for iZ=tBar.layerBar.sZ,tBar.layerBar.eZ do\\\
    tBar.touchMap[iX][iZ] = nil\\\
    screen:delPoint(iX,iZ,screen.layers.layerBar)\\\
  end\\\
  if tMode.grid then\\\
    screen:setLayer(screen.layers.gridBorder)\\\
    screen:setCursorPos(tBar.layerBar.sX,tBar.layerBar.sZ)\\\
    screen:setBackgroundColor(tColors.gridBorder)\\\
    screen:setTextColor(tColors.gridBorderText)\\\
    local gridChar = string.format(tBar.layerBar.sZ-1)\\\
    screen:write(gridChar:sub(#gridChar-1))\\\
  end\\\
  renderSideBar()\\\
  scroll()\\\
end\\\
\\\
function renderSideBar() --renders sidebar and fills the touch map with sidebar buttons\\\
  if tMode.hideMenus then\\\
    return\\\
  end\\\
  for iY=1,tTerm.screen.y do\\\
    tBar.touchMap[tTerm.screen.x][iY] = nil\\\
    tBar.touchMap[tTerm.screen.x-1][iY] = nil\\\
  end\\\
  screen:setLayer(screen.layers.sideBar)\\\
  local sizeReduction = tTerm.screen.y < 9+tMenu.main.enabled()\\\
  local posX,posY = tTerm.screen.x,sizeReduction and tTerm.screen.y or tTerm.screen.y-1\\\
  for k,v in pairs(colorKey) do\\\
    if string.match(k,\\\"^[%l%s]$\\\") then\\\
      screen:setBackgroundColor(v)\\\
      screen:setCursorPos(posX,posY)\\\
      screen:write\\\" \\\"\\\
      tBar.touchMap[posX][posY] = function(button)\\\
        if tTool[button].tool == \\\"Help\\\" then\\\
          window.text\\\"This is the color selection. It's used to select what color your current tool draws with\\\"\\\
        else\\\
          tTool[button].color = k\\\
          renderBottomBar()\\\
        end\\\
      end\\\
      posX = posX-1\\\
      if posX < tTerm.screen.x-1 then\\\
        posX = tTerm.screen.x\\\
        posY = posY-1\\\
      end\\\
    end\\\
  end\\\
  screen:setTextColor(tColors.sideBarText)\\\
  screen:setBackgroundColor(tColors.sideBar)\\\
  for i=1,#tMenu.main do\\\
    local menu = tMenu.main[i]\\\
    if type(menu.enabled) == \\\"function\\\" and menu.enabled() \\\
    or menu.enabled == true then\\\
      screen:setCursorPos(tTerm.screen.x-1,posY)\\\
      screen:write(menu.name:sub(1,2))\\\
      tBar.touchMap[tTerm.screen.x][posY] = function() \\\
        renderMenu(menu.name)\\\
      end\\\
      tBar.touchMap[tTerm.screen.x-1][posY] = tBar.touchMap[tTerm.screen.x][posY]\\\
      menu.sX = tTerm.screen.x-1-#menu.string\\\
      menu.eX = menu.sX+#menu.string\\\
      menu.lX = menu.eX-menu.sX\\\
      menu.sY = math.ceil(posY-(#menu.items/2))\\\
      menu.eY = math.ceil(posY+(#menu.items/2))\\\
      menu.lY = menu.eY-menu.sY+1\\\
      menu.splits = math.ceil(menu.lY/tTerm.screen.y)\\\
      if menu.splits <= 1 then\\\
        while menu.sY < 1 do\\\
          menu.sY = menu.sY+1\\\
          menu.eY = menu.eY+1\\\
        end\\\
        while menu.eY > tTerm.screen.y do\\\
          menu.sY = menu.sY-1\\\
          menu.eY = menu.eY-1\\\
        end\\\
      else\\\
        menu.sY = 1\\\
        menu.eY = math.ceil(menu.lY/menu.splits)\\\
        menu.lY = menu.eY\\\
        menu.sX = menu.sX-(menu.lX*(menu.splits-1))\\\
      end\\\
      posY = posY-1\\\
    end\\\
  end\\\
  if posY > 0 then\\\
    screen:drawLine(tTerm.screen.x,1,tTerm.screen.x,posY,tColors.sideBar)\\\
    screen:drawLine(tTerm.screen.x-1,1,tTerm.screen.x-1,posY,tColors.sideBar)\\\
    if posY >= 2 then\\\
      screen:setCursorPos(tTerm.screen.x-1,1)\\\
      screen:write\\\"/\\\\\\\\\\\"\\\
      tBar.touchMap[tTerm.screen.x][1] = function(button)\\\
        if tTool[button].tool == \\\"Help\\\" then\\\
          window.text\\\"These buttons are used to change layers up and down. This one goes up one layer, as well as create new ones if they don't exist\\\"\\\
        else\\\
          if not tBlueprint[tTerm.scroll.layer+1] then\\\
            tBlueprint[tTerm.scroll.layer+1] = class.layer.new()\\\
            sync({layer = tTerm.scroll.layer+1},\\\"Layer add\\\")\\\
          end\\\
          scroll(tTerm.scroll.layer+1)\\\
        end\\\
      end\\\
      tBar.touchMap[tTerm.screen.x-1][1] = tBar.touchMap[tTerm.screen.x][1]\\\
      screen:setCursorPos(tTerm.screen.x-1,2)\\\
      screen:write\\\"\\\\\\\\/\\\"\\\
      tBar.touchMap[tTerm.screen.x][2] = function(button)\\\
        if tTool[button].tool == \\\"Help\\\" then\\\
          window.text\\\"These buttons are used to change layers up and down. This one goes down one layer\\\"\\\
        else\\\
          scroll(tTerm.scroll.layer-1)\\\
        end\\\
      end\\\
      tBar.touchMap[tTerm.screen.x-1][2] = tBar.touchMap[tTerm.screen.x][2]\\\
    end\\\
  end\\\
  local x = sizeReduction and tTerm.screen.x-3 or tTerm.screen.x-1\\\
  screen:setCursorPos(x,tTerm.screen.y)\\\
  screen:setBackgroundColor(colors.white)\\\
  screen:setTextColor(colorKey.S)\\\
  screen:write(\\\"S\\\")\\\
  screen:setBackgroundColor(colors.black)\\\
  screen:setTextColor(colorKey.X)\\\
  screen:write(\\\"X\\\")\\\
  tBar.touchMap[x][tTerm.screen.y] = function(button)\\\
    if tTool[button].tool == \\\"Help\\\" then\\\
      window.text\\\"This is the scan marker, every block you draw with this will be scanned by the turtle, and saved to the blueprint.\\\"\\\
    else\\\
      tTool[button].color = \\\"S\\\"\\\
      renderBottomBar()\\\
    end\\\
  end\\\
  tBar.touchMap[x+1][tTerm.screen.y] = function(button)\\\
    if tTool[button].tool == \\\"Help\\\" then\\\
      window.text\\\"This is the break marker, every block you draw with this will be broken by the turtle.\\\"\\\
    else\\\
      tTool[button].color = \\\"X\\\"\\\
      renderBottomBar()\\\
    end\\\
  end\\\
  if tBar.menu.sizeReduction ~= sizeReduction then --if the reduction has changed state, the bottom bar must be re-rendered\\\
    tBar.menu.sizeReduction = sizeReduction\\\
    renderBottomBar()\\\
  end\\\
end\\\
\\\
function scroll(layer,x,z,absolute,forceRefresh) --scrolls the canvas x and z on layer, if absolute is given, it will scroll to those coordinates\\\
  if not (layer or x or z) then\\\
    --re-renders current view if no args are given\\\
    tTerm.scroll.layer = math.min(#tBlueprint,math.max(tTerm.scroll.layer,1))\\\
    tBlueprint[tTerm.scroll.layer]:render()\\\
    return\\\
  end\\\
  local oldX,oldZ = tTerm.scroll.x,tTerm.scroll.z\\\
  x = x or 0\\\
  z = z or 0\\\
  layer = layer or tTerm.scroll.layer\\\
  if absolute then\\\
    tTerm.scroll.x = math.max(x,0)\\\
    tTerm.scroll.z = math.max(z,0)\\\
  else\\\
    tTerm.scroll.x = math.max(tTerm.scroll.x+x,0)\\\
    tTerm.scroll.z = math.max(tTerm.scroll.z+z,0)\\\
  end\\\
  if oldX ~= tTerm.scroll.x or oldZ ~= tTerm.scroll.z or layer ~= tTerm.scroll.layer or forceRefresh then\\\
    if layer ~= tTerm.scroll.layer and tBlueprint[layer] then\\\
      tTerm.scroll.layer = math.max(layer,1)\\\
      tBar.layerBar.tSelected = {\\\
        [tTerm.scroll.layer] = true\\\
      }\\\
      tBar.layerBar.prevSelected = tTerm.scroll.layer\\\
      tBar.layerBar.selectedAmt = 1\\\
      renderLayerBar()\\\
    end\\\
    local view = tTerm.viewable\\\
    view.sX = tTerm.scroll.x+1\\\
    view.eX = view.sX+tTerm.canvas.tX\\\
    view.sZ = tTerm.scroll.z+1\\\
    view.eZ = tTerm.viewable.sZ+tTerm.canvas.tZ\\\
    tBlueprint[tTerm.scroll.layer]:render()\\\
    renderBottomBar()\\\
    renderToolOverlay()\\\
  end\\\
end\\\
\\\
function renderToolOverlay() --renders all tool overlays\\\
  screen:clearLayer(screen.layers.toolsOverlay)\\\
  screen:setLayer(screen.layers.toolsOverlay)\\\
  local view = tTerm.viewable\\\
  local mX = view.mX\\\
  local mZ = view.mZ\\\
  local t = tTool.clipboard or (tTool.shape.eX and tTool.shape)\\\
  if t then\\\
    local sX = math.min(t.sX,t.eX)\\\
    local eX = math.max(t.eX,t.sX)\\\
    local sZ = math.min(t.sZ,t.eZ)\\\
    local eZ = math.max(t.eZ,t.sZ)\\\
    for iX = math.max(sX,view.sX),math.min(eX,view.eX) do\\\
      for iZ = math.max(sZ,view.sZ),math.min(eZ,view.eZ) do \\\
        local block = t.l[iX-sX+1][iZ-sZ+1]\\\
        if block ~= \\\" \\\" then\\\
          screen:drawPoint(iX-tTerm.scroll.x+mX,iZ-tTerm.scroll.z+mZ,colorKey[block],block == \\\"X\\\" and block)\\\
        end\\\
      end\\\
    end\\\
  end\\\
  t = tTool.select\\\
  if t.sX\\\
  and t.layer == tTerm.scroll.layer then\\\
    screen:clearLayer(screen.layers.toolsOverlay)\\\
    screen:setLayer(screen.layers.toolsOverlay)\\\
    local sX = t.sX >= view.sX and t.sX <= view.eX and t.sX-tTerm.scroll.x+mX\\\
    local sZ = t.sZ >= view.sZ and t.sZ <= view.eZ and t.sZ-tTerm.scroll.z+mZ\\\
    local eX = t.eX and t.eX >= view.sX and t.eX <= view.eX and t.eX-tTerm.scroll.x+mX\\\
    local eZ = t.eX and t.eZ >= view.sZ and t.eZ <= view.eZ and t.eZ-tTerm.scroll.z+mZ\\\
    local color = tColors.selection\\\
    if sX then\\\
      if sZ then\\\
        screen:drawPoint(sX,sZ,color)\\\
        if eX then\\\
          screen:drawPoint(eX,sZ,color)\\\
          if eZ then\\\
            screen:drawPoint(sX,eZ,color)\\\
            screen:drawPoint(eX,eZ,color)\\\
          end\\\
        elseif eZ then\\\
          screen:drawPoint(sX,eZ,color)\\\
        end\\\
      elseif eZ then\\\
        screen:drawPoint(sX,eZ,color)\\\
        if eX then\\\
          screen:drawPoint(eX,eZ,color)\\\
        end\\\
      end\\\
    elseif sZ then\\\
      if eX then\\\
        screen:drawPoint(eX,sZ,color)\\\
        if eZ then\\\
          screen:drawPoint(eX,eZ,color)\\\
        end\\\
      end\\\
    elseif eX and eZ then\\\
      screen:drawPoint(eX,eZ,color)\\\
    end\\\
  end\\\
end\\\
\\\
function writePoint(x,z) --renders the specified blueprint point at wherever the cursor is\\\
  local marker,bColor,tColor,gridColor,gridColor2\\\
  local color = tBlueprint[tTerm.scroll.layer][x][z]\\\
  local bgLayer = tMode.backgroundLayer\\\
  if color == \\\"X\\\" then\\\
    marker = \\\"X\\\"\\\
    tColor = colorKey.X\\\
    bColor = colors.white\\\
  elseif color == \\\"S\\\" then\\\
    marker = \\\"S\\\"\\\
    tColor = colorKey.S\\\
    bColor = colors.white\\\
  elseif bgLayer and color == \\\" \\\" and (bgLayer[x][z] ~= \\\" \\\" and bgLayer[x][z] ~= \\\"X\\\") then\\\
    if tMode.grid then\\\
      marker = \\\"+\\\"\\\
      if x%tMode.gridMajor == 0 or z%tMode.gridMajor == 0 then\\\
        gridColor = tColors.gridMarkerMajor\\\
        gridColor2 = tColors.gridMarkerMajor2\\\
      else\\\
        gridColor = tColors.gridMarkerMinor\\\
        gridColor2 = tColors.gridMarkerMinor2\\\
      end\\\
      tColor = tColors.backgroundLayer ~= gridColor and gridColor or gridColor2\\\
    end\\\
    bColor = tColors.backgroundLayer\\\
  elseif tMode.builtRender and color:match\\\"%u\\\" then\\\
    marker = \\\"B\\\"\\\
    tColor = tColors.builtMarker\\\
  elseif tMode.grid then\\\
    marker = \\\"+\\\"\\\
    if x%tMode.gridMajor == 0 or z%tMode.gridMajor == 0 then\\\
      gridColor = tColors.gridMarkerMajor\\\
      gridColor2 = tColors.gridMarkerMajor2\\\
    else\\\
      gridColor = tColors.gridMarkerMinor\\\
      gridColor2 = tColors.gridMarkerMinor2\\\
    end\\\
    tColor = colorKey[color] ~= gridColor and gridColor or gridColor2\\\
  end\\\
  screen:drawPoint(nil,nil,bColor or colorKey[color],marker or \\\" \\\",tColor)\\\
end\\\
\\\
function renderPoint(x,z,skipScroll) --renders the given point on screen\\\
  local view = tTerm.viewable\\\
  local pX,pZ\\\
  if skipScroll then\\\
    pX = x-tTerm.scroll.x\\\
    pZ = z-tTerm.scroll.z\\\
  else\\\
    pX = x\\\
    pZ = z\\\
    x = x+tTerm.scroll.x\\\
    z = z+tTerm.scroll.z\\\
  end\\\
  screen:setLayer(screen.layers.canvas)\\\
  screen:setCursorPos(pX+view.mX,pZ+view.mZ)\\\
  writePoint(x,z)\\\
end\\\
\\\
function renderArea(x1,z1,x2,z2,skipScroll) --renders the specified area of the blueprint on screen\\\
  layer = layer or tBlueprint[tTerm.scroll.layer]\\\
  local view = tTerm.viewable\\\
  if not skipScroll then\\\
    x1 = x1+tTerm.scroll.x\\\
    z1 = z1+tTerm.scroll.z\\\
    x2 = x2+tTerm.scroll.x\\\
    z2 = z2+tTerm.scroll.z\\\
  end\\\
  screen:setLayer(screen.layers.canvas)\\\
  for iX = math.max(math.min(x1,x2),view.sX),math.min(math.max(x2,x1),view.eX) do\\\
    for iZ = math.max(math.min(z1,z2),view.sZ),math.min(math.max(z2,z1),view.eZ) do\\\
      screen:setCursorPos(iX-tTerm.scroll.x+view.mX,iZ-tTerm.scroll.z+view.mZ)\\\
      writePoint(iX,iZ)\\\
    end\\\
  end\\\
end\\\
\\\
function drawPoint(x,z,color,layer,skipScroll,ignoreOverwrite) --renders the point on screen as well as adding it to the blueprint\\\
  local layer = tBlueprint[layer or tTerm.scroll.layer]\\\
  color = tMode.builtDraw and color:upper() or color\\\
  if not skipScroll then\\\
    x = x+tTerm.scroll.x\\\
    z = z+tTerm.scroll.z\\\
  end\\\
  if not tMode.overwrite and not ignoreOverwrite and color ~= \\\" \\\" and layer[x+tTerm.scroll.x][z+tTerm.scroll.z] ~= \\\" \\\" then\\\
    return\\\
  end\\\
  layer[x][z] = (color ~= \\\" \\\" and color) or nil\\\
  renderPoint(x,z,color,true)\\\
end\\\
\",\
    [ \"TAFiles/APIs/debug.lua\" ] = \"debug = {\\\
  times = 0,\\\
  tExecutionTime = {\\\
    program = os.clock()\\\
  },\\\
  tEventQueue = {},\\\
  prep = function()\\\
    term.setBackgroundColor(colors.black)\\\
    term.clear()\\\
    term.setCursorPos(1,1)\\\
    term.setTextColor(colors.white)\\\
  end,\\\
  pause = function()\\\
    local tEventQueue = {}\\\
    while true do\\\
      local tEvent = {os.pullEventRaw()}\\\
      if tEvent[1] == \\\"key\\\" then\\\
        if tEvent[2] == 14 then\\\
          error(\\\"Quit\\\",0)\\\
        else\\\
          return\\\
        end\\\
      elseif tEvent[1] == \\\"mouse_click\\\"\\\
      or tEvent[1] == \\\"mouse_drag\\\"\\\
      or tEvent[1] == \\\"mouse_scroll\\\" then\\\
        --ignore user input\\\
      else\\\
        debug.tEventQueue[#debug.tEventQueue+1] = tEvent\\\
      end\\\
    end\\\
  end,\\\
  variables = function(...)\\\
    debug.times = debug.times+1\\\
    local tLines = {}\\\
    for i=1,#arg do\\\
      local var = arg[i]\\\
      if not var then\\\
        tLines[#tLines+1] = \\\"nil\\\"\\\
      elseif type(var) == \\\"table\\\" then\\\
        for k,v in pairs(var) do\\\
          tLines[#tLines+1] = k..\\\": \\\"..type(v)..\\\" \\\"..tostring(v)\\\
        end\\\
      else\\\
        tLines[#tLines+1] = type(var)..\\\" \\\"..tostring(var)\\\
      end\\\
    end\\\
    local lines = tTerm.screen.y-3\\\
    local pages = math.ceil(#tLines/lines)\\\
    for page = 1,pages do\\\
      debug.prep()\\\
      print(\\\"Page \\\"..page..\\\"/\\\"..pages..\\\" Debug call #\\\"..debug.times..\\\" on \\\"..tFile.program)\\\
      for line = lines*(page-1)+1,lines*page do\\\
        if not tLines[line] then\\\
          break\\\
        else\\\
          print(tLines[line])\\\
        end\\\
      end\\\
      debug.pause()\\\
    end\\\
    if screen then\\\
      screen:redraw()\\\
    end\\\
    for _i,event in ipairs(debug.tEventQueue) do\\\
      os.queueEvent(unpack(event))\\\
    end\\\
    debug.tEventQueue = {}\\\
    return\\\
  end,\\\
  timedStart = function(key)\\\
    debug.tExecutionTime[k] = os.clock()\\\
  end,\\\
  timedEnd = function(key)\\\
    local endTime = os.clock()\\\
    debug.prep()\\\
    assert(debug.tExecutionTime[key],\\\"Attempt to check non-defined execution time \\\"..key)\\\
    print(\\\"Initiated at \\\"..debug.tExecutionTime[key])\\\
    print(\\\"Completed at \\\"..endTime)\\\
    print(\\\"Total run time: \\\"..endTime-debug.tExecutionTime[key])\\\
    debug.pause()\\\
  end\\\
}\\\
setmetatable(debug,\\\
  {\\\
    __call = function(t,...)\\\
      return debug.variables(...)\\\
    end\\\
  }\\\
)\",\
    [ \"TAFiles/Menus/rightClick/layerBar.Lua\" ] = \"local menu\\\
local layerBar = tBar.layerBar\\\
menu = {\\\
  [1] = {\\\
    name = \\\"Insert new above\\\",\\\
    enabled = function()\\\
      return layerBar.selectedAmt == 1\\\
    end,\\\
    help = function()\\\
      window.text\\\"Inserts a new blank layer above the currently selected layer\\\"\\\
    end,\\\
    func = function()\\\
      local layer = layerBar.prevSelected+1\\\
      table.insert(tBlueprint,layer,class.layer.new())\\\
      renderLayerBar()\\\
      sync({layer = layer},\\\"Layer add\\\")\\\
    end\\\
  },\\\
  [2] = {\\\
    name = \\\"Insert new below\\\",\\\
    enabled = function()\\\
      return layerBar.selectedAmt == 1\\\
    end,\\\
    help = function()\\\
      window.text\\\"Inserts a new blank layer below the currently selected layer\\\"\\\
    end,\\\
    func = function()\\\
      local layer = layerBar.prevSelected\\\
      table.insert(tBlueprint,layer,class.layer.new())\\\
      renderLayerBar()\\\
      scroll(layer+1)\\\
      sync({layer = layer},\\\"Layer add\\\")\\\
    end\\\
  },\\\
  [3] = {\\\
    name = \\\"Import...\\\",\\\
    enabled = function()\\\
      return layerBar.selectedAmt == 1\\\
    end,\\\
    help = function()\\\
      window.text\\\"Import layers from another blueprint into the layers above the one currently selected\\\"\\\
    end,\\\
    func = function()\\\
      local button, tRes, reInput = window.text(\\\
        \\\"Import layers from another blueprint\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\",\\\
          \\\"Pastebin\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"Blueprint\\\",\\\
            value = \\\"/\\\",\\\
            accepted = \\\".\\\"\\\
          },\\\
          {\\\
            name = \\\"From\\\",\\\
            value = 1,\\\
            accepted = \\\"%d\\\"\\\
          },\\\
          {\\\
            name = \\\"To\\\",\\\
            value = 1,\\\
            accepted = \\\"%d\\\"\\\
          },\\\
        },\\\
        false,\\\
        true\\\
      )\\\
      while button ~= \\\"Cancel\\\" do\\\
        local iBlueprint\\\
        local fileName = tRes.Blueprint\\\
        if not fileName then\\\
          if button == \\\"Pastebin\\\" then\\\
            button,tRes,reInput = reInput\\\"Pastebin code parameter missing!\\\"\\\
          else\\\
            button,tRes,reInput = reInput\\\"Import blueprint parameter missing!\\\"\\\
          end\\\
        elseif not tRes.From then\\\
          button,tRes,reInput = reInput\\\"From layer parameter missing!\\\"\\\
        elseif not tRes.To then\\\
          button,tRes,reInput = reInput\\\"To layer parameter missing!\\\"\\\
        elseif button == \\\"Pastebin\\\" then\\\
          local paste = {}\\\
          http.request(\\\"http://pastebin.com/raw.php?i=\\\"..fileName)\\\
          local dlStatus = window.text(\\\
            {\\\
              {\\\
                text = \\\"Downloading \\\"..fileName..\\\".\\\",\\\
                renderTime = 0.2\\\
              },\\\
              {\\\
                text = \\\"Downloading \\\"..fileName..\\\"..\\\",\\\
                renderTime = 0.2\\\
              },\\\
              {\\\
                text = \\\"Downloading \\\"..fileName..\\\"...\\\",\\\
                renderTime = 0.2\\\
              },\\\
            },\\\
            {\\\
              \\\"Cancel\\\"\\\
            },\\\
            nil,\\\
            {\\\
              http_success = function(tEvent)\\\
                local web = tEvent[3]\\\
                local line = web.readLine()\\\
                while line do\\\
                  paste[#paste+1] = line\\\
                  line = web.readLine()\\\
                end\\\
                web.close()\\\
                return \\\"Success\\\"\\\
              end,\\\
              http_failure = function(tEvent)\\\
                button,tRes,reInput = reInput(\\\"Pastebin download of \\\"..fileName..\\\" failed!\\\")\\\
                return \\\"Failure\\\"\\\
              end\\\
            }\\\
          )\\\
          if dlStatus == \\\"Success\\\" then\\\
            iBlueprint = tBlueprint.load(paste)\\\
            button = dlStatus\\\
          end\\\
        else\\\
          iBlueprint = tBlueprint.load(fileName)\\\
          if not fs.exists(fileName..\\\".TAb\\\") then\\\
            button,tRes,reInput = reInput(fileName..\\\" does not exist!\\\")\\\
          else\\\
            button = \\\"Success\\\"\\\
          end\\\
        end\\\
        if button == \\\"Success\\\" then\\\
          if not iBlueprint then\\\
            button,tRes,reInput = reInput(fileName..\\\" is not a blueprint file!\\\")\\\
          elseif not iBlueprint[tRes.To] then\\\
            button,tRes,reInput = reInput(\\\"The layer \\\"..tRes.To..\\\" does not exist in the blueprint \\\"..tRes.Blueprint..\\\"!\\\")\\\
          else\\\
            for i=tRes.From,tRes.To do\\\
              local layer = layerBar.prevSelected+i-tRes.From\\\
              table.insert(tBlueprint,layer,iBlueprint[i]:copy())\\\
            end\\\
            scroll()\\\
            sync({blueprint = tBlueprint,blueprintName = tFile.blueprint},\\\"Blueprint load\\\")\\\
            return\\\
          end\\\
        end\\\
      end\\\
    end\\\
  },\\\
  [4] = {\\\
    name = \\\"Delete\\\",\\\
    enabled = function()\\\
      return layerBar.selectedAmt > 0\\\
    end,\\\
    help = function()\\\
      window.text\\\"Deletes the currently selected layers\\\"\\\
    end,\\\
    func = function()\\\
      local scrollLayer = tTerm.scroll.layer\\\
      local delLayers = {}\\\
      for layer in pairs(layerBar.tSelected) do\\\
        delLayers[#delLayers+1] = layer\\\
      end\\\
      table.sort(\\\
        delLayers,\\\
        function(k1,k2)\\\
          return k1 > k2\\\
        end\\\
      )\\\
      for i,layer in ipairs(delLayers) do\\\
        if layer == 1 and #tBlueprint == 1 then\\\
          tBlueprint[1] = tBlueprint[1].new()\\\
        else\\\
          table.remove(tBlueprint,layer)\\\
        end\\\
        if scrollLayer >= layer then\\\
          scrollLayer = scrollLayer-1\\\
        end\\\
      end\\\
      sync({layers = layerBar.tSelected},\\\"Layer delete\\\")\\\
      layerBar.tSelected = {\\\
        [scrollLayer] = true\\\
      }\\\
      layerBar.prevSelected = scrollLayer\\\
      layerBar.selectedAmt = 1\\\
      renderLayerBar(true)\\\
      scroll(math.max(scrollLayer,1))\\\
    end\\\
  },\\\
  [5] = {\\\
    name = \\\"Clear\\\",\\\
    enabled = function()\\\
      return layerBar.selectedAmt > 0\\\
    end,\\\
    help = function()\\\
      window.text\\\"Clears the currently selected layers\\\"\\\
    end,\\\
    func = function()\\\
      for layer in pairs(layerBar.tSelected) do\\\
        tBlueprint[layer] = class.layer.new()\\\
      end\\\
      scroll()\\\
      sync({layers = layerBar.tSelected},\\\"Layer clear\\\")\\\
    end\\\
  },\\\
  [6] = {\\\
    name = \\\"Cut\\\",\\\
    enabled = function()\\\
      return layerBar.selectedAmt > 0\\\
    end,\\\
    help = function()\\\
      window.text\\\"Move the currently selected layers\\\"\\\
    end,\\\
    func = function()\\\
      layerBar.clipboard = {}\\\
      local cutLayers = {}\\\
      for layer in pairs(layerBar.tSelected) do\\\
        cutLayers[#cutLayers+1] = layer\\\
      end\\\
      table.sort(\\\
        cutLayers,\\\
        function(k1,k2)\\\
          return k1 > k2\\\
        end\\\
      )\\\
      local scrollLayer = tTerm.scroll.layer\\\
      for i,layer in ipairs(cutLayers) do\\\
        layerBar.clipboard[#cutLayers-i+1] = table.remove(tBlueprint,layer)\\\
        if scrollLayer >= layer then\\\
          scrollLayer = scrollLayer-1\\\
        end\\\
      end\\\
      sync({layers = layerBar.tSelected},\\\"Layer delete\\\")\\\
      layerBar.tSelected = {\\\
        [scrollLayer] = true\\\
      }\\\
      layerBar.prevSelected = scrollLayer\\\
      renderLayerBar(true)\\\
      scroll(scrollLayer)\\\
    end\\\
  },\\\
  [7] = {\\\
    name = \\\"Copy\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Copy the currently selected layers\\\"\\\
    end,\\\
    func = function()\\\
      layerBar.clipboard = {}\\\
      local copyOrder = {}\\\
      for layer in pairs(layerBar.tSelected) do\\\
        copyOrder[#copyOrder+1] = layer\\\
      end\\\
      table.sort(\\\
        copyOrder,\\\
        function(v1,v2)\\\
          return v1 < v2\\\
        end\\\
      )\\\
      for i,layer in ipairs(copyOrder) do\\\
        layerBar.clipboard[i] = tBlueprint[layer]:copy()\\\
      end\\\
    end\\\
  },\\\
  [8] = {\\\
    name = \\\"Paste\\\",\\\
    enabled = function()\\\
      return layerBar.clipboard and layerBar.selectedAmt == 1\\\
    end,\\\
    help = function()\\\
      window.text\\\"Paste the current clipboard above the currently selected layer\\\"\\\
    end,\\\
    func = function()\\\
      for i,layer in ipairs(layerBar.clipboard) do \\\
        table.insert(tBlueprint,layerBar.prevSelected+i,layer:copy())\\\
      end\\\
      renderLayerBar()\\\
      sync({blueprint = tBlueprint,blueprintName = tFile.blueprint},\\\"Blueprint load\\\")\\\
    end\\\
  },\\\
  [9] = {\\\
    name = \\\"Merge\\\",\\\
    enabled = function()\\\
      return layerBar.selectedAmt > 1\\\
    end,\\\
    help = function()\\\
      window.text\\\"Combine the selected layers into the bottom one\\\"\\\
    end,\\\
    func = function()\\\
      local mergeLayers = {}\\\
      for layer in pairs(layerBar.tSelected) do\\\
        mergeLayers[#mergeLayers+1] = layer\\\
      end\\\
      table.sort(\\\
        mergeLayers,\\\
        function(v1,v2)\\\
          return v1 < v2\\\
        end\\\
      )\\\
      local bottomLayer = table.remove(mergeLayers,1)\\\
      local scrollLayer = tTerm.scroll.layer\\\
      for i,layer in ipairs(mergeLayers) do\\\
        tBlueprint[bottomLayer]:paste(tBlueprint[layer])\\\
      end\\\
      table.sort(\\\
        mergeLayers,\\\
        function(v1,v2)\\\
          return v1 > v2\\\
        end\\\
      )\\\
      for i,layer in ipairs(mergeLayers) do\\\
        table.remove(tBlueprint,layer)\\\
        if scrollLayer >= layer then\\\
          scrollLayer = scrollLayer-1\\\
        end\\\
      end\\\
      layerBar.tSelected = {\\\
        [bottomLayer] = true\\\
      }\\\
      layerBar.selectedAmt = 1\\\
      layerBar.prevSelected = bottomLayer\\\
      renderLayerBar(true)\\\
      if scrollLayer ~= tTerm.scroll.layer or scrollLayer == bottomLayer then\\\
        scroll(scrollLayer,nil,nil,nil,true)\\\
      end\\\
      sync({blueprint = tBlueprint,blueprintName = tFile.blueprint},\\\"Blueprint load\\\")\\\
    end\\\
  },\\\
  [10] = {\\\
    name = \\\"Select all\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Selects all the layers in the blueprint\\\"\\\
    end,\\\
    func = function()\\\
      for layer=1,#tBlueprint do\\\
        layerBar.tSelected[layer] = true\\\
      end\\\
      layerBar.selectedAmt = #tBlueprint\\\
      renderLayerBar()\\\
    end\\\
  },\\\
  [11] = {\\\
    name = \\\"Flip hori\\\",\\\
    enabled = function()\\\
      return layerBar.selectedAmt > 0\\\
    end,\\\
    help = function()\\\
      window.text\\\"Flip the selected layers horizontally\\\"\\\
    end,\\\
    func = function()\\\
      for layer in pairs(layerBar.tSelected) do\\\
        tBlueprint[layer] = tBlueprint[layer]:flipZ()\\\
      end\\\
      if layerBar.tSelected[tTerm.scroll.layer] then\\\
        scroll()\\\
      end\\\
      sync({layers = layerBar.tSelected,dir = \\\"X\\\"},\\\"Flip\\\")\\\
    end\\\
  },\\\
  [12] = {\\\
    name = \\\"Flip vert\\\",\\\
    enabled = function()\\\
      return layerBar.selectedAmt > 0\\\
    end,\\\
    help = function()\\\
      window.text\\\"Flip the selected layers vertically\\\"\\\
    end,\\\
    func = function()\\\
      for layer in pairs(layerBar.tSelected) do\\\
        tBlueprint[layer] = tBlueprint[layer]:flipZ()\\\
      end\\\
      if layerBar.tSelected[tTerm.scroll.layer] then\\\
        scroll()\\\
      end\\\
      sync({layers = layerBar.tSelected,dir = \\\"Z\\\"},\\\"Flip\\\")\\\
    end\\\
  },\\\
  [13] = {\\\
    name = \\\"Recolor\\\",\\\
    enabled = function()\\\
      return layerBar.selectedAmt > 0\\\
    end,\\\
    help = function()\\\
      window.text\\\"Changes the color of the selected layers\\\"\\\
    end,\\\
    func = function()\\\
      local color = dialogue.selectColor(\\\"Recolor the selected layers to\\\")\\\
      if color ~= \\\"Cancel\\\" then\\\
        for layer in pairs(layerBar.tSelected) do\\\
          tBlueprint[layer]:recolor(colorKey[color])\\\
        end\\\
        if layerBar.tSelected[tTerm.scroll.layer] then\\\
          scroll()\\\
        end\\\
        sync({layers = layerBar.tSelected,color = colorKey[color]},\\\"Recolor\\\")\\\
      end\\\
    end\\\
  },\\\
  [14] = {\\\
    name = \\\"Mark built\\\",\\\
    enabled = function()\\\
      return layerBar.selectedAmt > 0\\\
    end,\\\
    help = function()\\\
      window.text\\\"Mark the selected layers as built, meaning the turtle will skip it during construction\\\"\\\
    end,\\\
    func = function()\\\
      for layer in pairs(layerBar.tSelected) do\\\
        tBlueprint[layer]:markBuilt()\\\
        if tMode.builtRender then\\\
          scroll()\\\
        end\\\
      end\\\
      if tMode.builtRender and layerBar.tSelected[tTerm.scroll.layer] then\\\
        scroll()\\\
      end\\\
      sync({layers = layerBar.tSelected},\\\"Mark built\\\")\\\
    end\\\
  },\\\
  [15] = {\\\
    name = \\\"Mark unbuilt\\\",\\\
    enabled = function()\\\
      return layerBar.selectedAmt > 0\\\
    end,\\\
    help = function()\\\
      window.text\\\"Reset all build progress made on selected layers\\\"\\\
    end,\\\
    func = function()\\\
      for layer in pairs(layerBar.tSelected) do\\\
        tBlueprint[layer]:markUnbuilt()\\\
      end\\\
      if tMode.builtRender and layerBar.tSelected[tTerm.scroll.layer] then\\\
        scroll()\\\
      end\\\
      sync({layers = layerBar.tSelected},\\\"Mark unbuilt\\\")\\\
    end\\\
  },\\\
  [16] = {\\\
    name = \\\"Save as paint\\\",\\\
    enabled = function()\\\
      return layerBar.selectedAmt == 1\\\
    end,\\\
    help = function()\\\
      window.text\\\"Saves the layer as a paint file\\\"\\\
    end,\\\
    func = function()\\\
      local button,tRes,reInput = window.text(\\\
        \\\"Input save path\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"Path\\\",\\\
            value = \\\"/\\\"\\\
          }\\\
        },\\\
        nil,\\\
        true\\\
      )\\\
      while button ~= \\\"Cancel\\\" do\\\
        if not tRes.Path or not tRes.Path:match\\\"/[^/]+$\\\" then\\\
          button,tRes,reInput = reInput\\\"Invalid path!\\\"\\\
        elseif fs.exists(tRes.Path) and button ~= \\\"Overwrite\\\" then\\\
          local button2 = window.text(\\\
            tRes.Path..\\\" already exists!\\\\nOverwrite?\\\",\\\
            {\\\
              \\\"Cancel\\\",\\\
              \\\"Overwrite\\\"\\\
            }\\\
          )\\\
          if button2 == \\\"Cancel\\\" then\\\
            button,tRes,reInput = reInput\\\"Input save path\\\"\\\
          else \\\
            button = button2\\\
            fs.delete(tRes.Path)\\\
          end\\\
        else\\\
          local stringTable = setmetatable(\\\
            {},\\\
            {\\\
              __index = function(t,k)\\\
                t[k] = setmetatable(\\\
                  {},\\\
                  {\\\
                    __index = function(t,k)\\\
                      return \\\"\\\"\\\
                    end\\\
                  }\\\
                )\\\
                return t[k]\\\
              end\\\
            }\\\
          )\\\
          local file = class.fileTable.new(tRes.Path)\\\
          local layer = tBlueprint[layerBar.prevSelected]\\\
          for nX,vX in pairs(layer) do\\\
            for nZ,vZ in pairs(vX)  do\\\
              for i=#stringTable[nZ]+1,nX-1 do\\\
                stringTable[nZ][i] = \\\" \\\"\\\
              end\\\
              stringTable[nZ][nX] = paintColors[vZ:lower()]\\\
            end\\\
          end\\\
          for i=1,#stringTable do\\\
            file:write(table.concat(stringTable[i]),i)\\\
          end\\\
          file:save()\\\
          return\\\
        end\\\
      end\\\
    end\\\
  },\\\
  [17] = {\\\
    name = \\\"Close layer bar\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Closes the layer bar and re-enables the layer menu\\\"\\\
    end,\\\
    func = function()\\\
      closeLayerBar()\\\
      local file = class.fileTable.new(tFile.settings)\\\
      local line = file:find(\\\"  layerBar = true,\\\",true)\\\
      file:write(\\\"  layerBar = false,\\\",line)\\\
      file:save()\\\
    end\\\
  },\\\
}\\\
\\\
return menu\\\
\",\
    [ \"TAFiles/APIs/table.lua\" ] = \"table = setmetatable(\\\
  {\\\
    deepCopy = function(t)\\\
      local copy = {}\\\
      for k,v in pairs(t) do\\\
        if type(v) == \\\"table\\\" and v ~= _G then\\\
          copy[k] = table.deepCopy(v)\\\
        else\\\
          copy[k] = v\\\
        end\\\
      end\\\
      return copy\\\
    end\\\
  },\\\
  {\\\
    __index = _G.table\\\
  }\\\
)\",\
    [ \"TAFiles/Tools/Help.Lua\" ] = \"local tool\\\
tool = {\\\
  menuOrder = 12, --menu order, 1 being top\\\
  enabled = true,\\\
  help = function()\\\
    window.text\\\"The tool you are currently using, displays help windows describing what things do when you click on any element of TA's UI\\\"\\\
  end,\\\
  selectFunc = function(button)\\\
    tTool.change(\\\"Help\\\",button)\\\
  end,\\\
  renderFunc = function(event,button,x,z,color,layer)\\\
    window.text\\\"This is the canvas where you draw your creations. It's scrollable in all directions using the arrow keys.\\\"\\\
  end\\\
}\\\
return tool\\\
\",\
    [ \"TAFiles/EventHandlers/common.Lua\" ] = \"-- Variables used for the modem_message handler\\\
local modem_messageMessages = {}\\\
local modem_messageTimeouts = {}\\\
\\\
local common\\\
common = { --common event handlers, these are always active\\\
  turtle_response = function(tEvent)\\\
    os.queueEvent(unpack(tEvent))\\\
    return true\\\
  end,\\\
  timer = function(tEvent)\\\
    local timerID = tEvent[2]\\\
    if timerID == tTimers.blink.id then\\\
      local toggle = tTimers.blink.toggle\\\
      tTimers.blink.toggle = not toggle\\\
      if toggle then\\\
        renderToolOverlay()\\\
      else\\\
        screen:clearLayer(screen.layers.toolsOverlay)\\\
      end\\\
      tTimers.blink.start()\\\
      return true\\\
    elseif timerID == tTimers.ctrl.id then\\\
      tTimers.ctrl.lPressed = false\\\
      tTimers.ctrl.rPressed = false\\\
      return true\\\
    elseif timerID == tTimers.shift.id then\\\
      tTimers.shift.pressed = false\\\
      return true\\\
    elseif tTimers.display.ids[timerID] then\\\
      local func = glasses.log.timers[timerID]\\\
      if func then\\\
        func()\\\
        if glasses.screenMode:match\\\"Log\\\" then\\\
          glasses.log.refresh()\\\
        end\\\
      end\\\
      return true\\\
    elseif timerID == tTimers.connectionPing.id then\\\
      if rednet.connected.amount > 0 then\\\
        rednet.send(\\\
          rednet.connected.ids,\\\
          \\\"Ping\\\",\\\
          false,\\\
          false,\\\
          function(id)\\\
            rednet.connected.ids[id] = nil\\\
            local turtle = tMode.sync.ids[id] == \\\"turtle\\\"\\\
            tMode.sync.turtles = tMode.sync.turtles-(turtle and 1 or 0)\\\
            tMode.sync.amount = tMode.sync.ids[id] and tMode.sync.amount-1 or tMode.sync.amount\\\
            tMode.sync.ids[id] = nil \\\
            if turtle and tMode.sync.turtles == 0 then\\\
              renderSideBar()\\\
            end\\\
            window.text(\\\"Connection to computer ID \\\"..id..\\\" was lost.\\\")\\\
          end\\\
        )\\\
      end\\\
      tTimers.connectionPing.start()\\\
      return true\\\
    elseif tTimers.modemRes.ids[timerID] then\\\
      local func = tTransmissions.failure.timeout[timerID]\\\
      if func then\\\
        return func()\\\
      end\\\
      return true\\\
    elseif os.sleepTimer[timerID] then\\\
      os.sleepTimer[timerID]()\\\
      return true\\\
    elseif modem_messageTimeouts[timerID] then\\\
      local messageID = modem_messageTimeouts[ timerID ]\\\
      modem_messageTimeouts[ timerID ] = nil\\\
      modem_messageMessages[ messageID ] = nil\\\
    end\\\
  end,\\\
  peripheral = function(tEvent)\\\
    local side = tEvent[2]\\\
    if not modem and peripheral.getType(side) == \\\"modem\\\" and peripheral.call(side,\\\"isWireless\\\") then\\\
      modem = peripheral.wrap(side)\\\
      modem.open(modemChannel)\\\
      modem.side = side\\\
      return true\\\
    elseif not glasses and peripheral.getType(side) == \\\"openperipheral_glassesbridge\\\" then\\\
      glasses.bridge = peripheral.wrap(side)\\\
      glasses.side = side\\\
      if glasses.screenMode:match\\\"Screen\\\" then\\\
        screen:glassInit(glasses.bridge,glasses.screen.size.x,glasses.screen.size.y,glasses.screen.pos.x,glasses.screen.pos.y)\\\
      end\\\
      if glasses.screenMode:match\\\"Log\\\" then\\\
			  glasses.log.open(glasses.log.sX,glasses.log.sY,glasses.log.eX,glasses.log.eY)\\\
      end\\\
      return true\\\
    end\\\
  end,\\\
  peripheral_detach = function(tEvent)\\\
    local side = tEvent[2]\\\
    if modem and side == modem.side then\\\
      modem = nil\\\
      return true\\\
    elseif glasses.bridge and side == glasses.side then\\\
      glasses.log.close()\\\
      screen:glassClose()\\\
      glasses.bridge = nil\\\
      return true\\\
    end\\\
  end,\\\
  term_resize = function()\\\
    tTerm.screen.x,tTerm.screen.y = term.getSize()\\\
    tTerm.screen.xMid = math.floor(tTerm.screen.x/2) --middle of the screen sideways\\\
    tTerm.screen.yMid = math.floor(tTerm.screen.y/2) --middle of the screen up and down\\\
    tTerm.canvas.sX = 1 --canvas left side\\\
    tTerm.canvas.eX = tTerm.screen.x-2 --canvas edge\\\
    tTerm.canvas.tX = tTerm.canvas.eX-tTerm.canvas.sX+1 --canvas total length\\\
    tTerm.canvas.sZ = 1 --canvas top side\\\
    tTerm.canvas.eZ = tTerm.screen.y-1 --canvas bottom\\\
    tTerm.canvas.tZ = tTerm.canvas.eZ-tTerm.canvas.sZ+1 --canvas total height\\\
    tTerm.viewable.sX = 1 --left side of the blueprint in view\\\
    tTerm.viewable.eX = tTerm.canvas.eX --edge of the blueprint in view\\\
    tTerm.viewable.sZ = 1 --top side of the blueprint in view\\\
    tTerm.viewable.eZ = tTerm.canvas.eZ --bottom of the blueprint in view\\\
    tTerm.viewable.mX = 0 --view modifier sideways\\\
    tTerm.viewable.mZ = 0 --view modifier up or down\\\
    tTerm.scroll.x = 0 --canvas scroll sideways\\\
    tTerm.scroll.z = 0 --canvas scroll up or down\\\
    tTerm.scroll.layer = 1 --currently in view layer\\\
    while rawget(screen,1) do\\\
      screen:delLayer(1)\\\
    end\\\
    eventHandler.switch(eventHandler.main)\\\
    renderBottomBar()\\\
    renderSideBar()\\\
  end,\\\
  chat_command = function(tEvent)\\\
    local command = tEvent[2]:lower()\\\
    local tCommand = {}\\\
    for word in command:gmatch\\\"%S+\\\" do\\\
      local num = tonumber(word)\\\
      if num then\\\
        tCommand[#tCommand+1] = num\\\
      else\\\
        tCommand[#tCommand+1] = word:lower()\\\
      end\\\
    end\\\
    local menuName = string.upper(string.sub(tCommand[1],1,1))..string.sub(tCommand[1],2)\\\
    if tCommand[1] == \\\"resize\\\"\\\
    or tCommand[1] == \\\"repos\\\" then\\\
      local x,y,command\\\
      if type(tCommand[2]) == \\\"number\\\" and type(tCommand[3]) == \\\"number\\\" then\\\
        command = glasses.screenMode:match\\\"^%S+$\\\"\\\
        command = command and command:lower()\\\
        x1 = tCommand[2]\\\
        y1 = tCommand[3]\\\
        x2 = tCommand[4]\\\
        y2 = tCommand[5]\\\
      elseif type(tCommand[2]) == \\\"string\\\" then\\\
        command = tCommand[2]\\\
        x1 = tCommand[3]\\\
        y1 = tCommand[4]\\\
        x2 = tCommand[5]\\\
        y2 = tCommand[6]\\\
      end\\\
      if tCommand[1] == \\\"resize\\\" then\\\
        if type(x1) == \\\"number\\\" and type(y1) == \\\"number\\\" then\\\
          screen:glassResize(x1,y1)\\\
        end\\\
      elseif tCommand[1] == \\\"repos\\\" then\\\
        if command == \\\"screen\\\" then\\\
          if type(x1) == \\\"number\\\" and type(y1) == \\\"number\\\" then\\\
            screen:glassInit(x1,y1,glasses.screen.size.x,glasses.screen.size.y)\\\
          end\\\
        elseif command == \\\"log\\\" then\\\
          if type(x1) == \\\"number\\\" and type(y1) == \\\"number\\\" and type(x2) == \\\"number\\\" and type(y2) == \\\"number\\\" then\\\
            glasses.log.close()\\\
            glasses.log.open(x1,y1,x2,y2)\\\
          end\\\
        end\\\
      end\\\
    elseif tCommand[1] == \\\"opacity\\\" then\\\
      local opacity,command\\\
      if type(tCommand[2]) == \\\"number\\\" then\\\
        command = glasses.screenMode:match\\\"^%S+$\\\"\\\
        command = command and command:lower()\\\
        opacity = tCommand[2]\\\
      else\\\
        command = tCommand[2]\\\
        opacity = tCommand[3]\\\
      end\\\
      if type(opacity) == \\\"number\\\" then\\\
        if command == \\\"screen\\\" then\\\
          screen:glassOpacity(opacity)\\\
        elseif command == \\\"log\\\" then\\\
          glasses.log.setOpacity(opacity)\\\
        end\\\
      end\\\
    elseif tCommand[1] == \\\"mode\\\" then\\\
      local screenMode = command:match\\\"screen\\\" and true\\\
      local logMode = command:match\\\"log\\\" and true\\\
      local oldScreenMode = glasses.screenMode:match\\\"Screen\\\" and true\\\
      local oldLogMode = glasses.screenMode:match\\\"Log\\\" and true\\\
      if screenMode or logMode then\\\
        glasses.screenMode = (screenMode and \\\"Screen \\\" or \\\"\\\")..(logMode and \\\"Log\\\" or \\\"\\\")\\\
        local file = class.fileTable.new(tFile.settings)\\\
        local line = file:find('  screenMode = \\\".+\\\", %-%-glasses display mode')\\\
        file:write('  screenMode = \\\"'..glasses.screenMode..'\\\", --glasses display mode,simply write which modes you want in plain text, remember to capitalize the first letter',line)\\\
        file:save()\\\
        if not oldScreenMode and screenMode then\\\
          screen:glassInit(glasses.screen.size.x,glasses.screen.size.y,glasses.screen.pos.x,glasses.screen.pos.y)\\\
        elseif not screenMode and oldScreenMode then\\\
          screen:glassClose()\\\
        end\\\
        if not oldLogMode and logMode then\\\
          glasses.log.open(glasses.log.sX,glasses.log.sY,glasses.log.eX,glasses.log.eY)\\\
        elseif not logMode and oldLogMode then\\\
          glasses.log.close()\\\
        end\\\
      end\\\
    elseif tCommand[1] == \\\"toggle\\\" then\\\
      if tCommand[2] == \\\"follow\\\" and tCommand[3] == \\\"turtle\\\" then\\\
        glasses.followTurtle = not glasses.followTurtle\\\
      end\\\
    elseif tCommand[1] == \\\"test\\\" then\\\
      glasses.log.write(table.concat(tCommand,\\\" \\\",2))\\\
    elseif tMenu.main[menuName] and not inputOpen then\\\
      if not tCommand[2] and not tMenu.open then\\\
        renderMenu(menuName)\\\
      else\\\
        local funcName = table.concat(tCommand,\\\" \\\",(tCommand[2] and 2 or 1))\\\
        funcName = string.upper(string.sub(funcName,1,1))..string.sub(funcName,2)\\\
        for i=1,#tMenu.main[menuName].items do\\\
          if tMenu.main[menuName].items[i].name:match(funcName) then\\\
            renderMenu()\\\
            tMenu.main[menuName].items[i].func()\\\
          end\\\
        end\\\
      end\\\
    elseif tMenu.open and not inputOpen then\\\
      menuName = tMenu.open\\\
      local funcName = table.concat(tCommand,\\\" \\\",2)\\\
      funcName = string.upper(string.sub(funcName,1,1))..string.sub(funcName,2)\\\
      for i=1,#tMenu.main[menuName].items do\\\
        if tMenu.main[menuName].items[i].name:match(funcName) then\\\
          tMenu.main[menuName].items[i].func()\\\
        end\\\
      end\\\
    end\\\
  end,\\\
  modem_message = function(tEvent)\\\
    if tEvent[3] == modemChannel\\\
    and type(tEvent[5]) == \\\"table\\\" --All Turtle Architect messages are sent as tables\\\
    and (tEvent[5].rID[os.id] or tEvent[5].rID.All) then\\\
      local data = tEvent[5]\\\
      local event = data.event\\\
      local senderId = data.sID\\\
      local type = data.type\\\
      if data.nMessageID ~= nil then\\\
        if modem_messageMessages[ data.nMessageID ] then\\\
          -- The message is a duplicate\\\
          return true\\\
        else\\\
          modem_messageMessages[ data.nMessageID ] = true\\\
          modem_messageTimeouts[ os.startTimer( 30 ) ] = data.nMessageID\\\
        end\\\
      end\\\
      if event == \\\"Success\\\" then\\\
        local func = tTransmissions.success[type][senderId]\\\
        if func then\\\
          func(data)\\\
          return true\\\
        end\\\
      elseif event == \\\"Failure\\\" then\\\
        local func = tTransmissions.failure[type][senderId]\\\
        if func then\\\
          func(data)\\\
          return true\\\
        end\\\
      elseif event == \\\"Ping\\\" then\\\
        rednet.send(senderId,\\\"Success\\\",{type=\\\"Ping\\\",turtle = turtle and true or nil})\\\
      elseif event == \\\"Init connection\\\" then\\\
        if type == \\\"Sync\\\" then\\\
          --[[local timeoutId = tTimers.inputTimeout.start()\\\
          local button = window.text(\\\
            \\\"Computer ID \\\"..senderId..\\\" wants to initiate sync mode.\\\",\\\
            {\\\
              \\\"Deny\\\",\\\
              \\\"Accept\\\"\\\
            },\\\
            false,\\\
            {\\\
              timer = function(tEvent)\\\
                if tEvent[2] == timeoutId then\\\
                  return \\\"Deny\\\"\\\
                end\\\
              end\\\
            }\\\
          )\\\
          if button == \\\"Accept\\\" or \\\"Ok\\\" then]]--\\\
            if not tMode.sync.ids[senderId] then \\\
              local reRenderSideBar = tMode.sync.turtles > 0\\\
              if tMode.sync.amount > 0 then\\\
                rednet.disconnect(tMode.sync.ids)\\\
              end\\\
              rednet.connected.amount = rednet.connected.amount+1\\\
              rednet.connected.ids[senderId] = true\\\
              tMode.sync.amount = 1\\\
              if data.turtle then\\\
                tMode.sync.turtles = 1\\\
                tMode.sync.ids = {[senderId] = \\\"turtle\\\"}\\\
                if not reRenderSideBar then\\\
                  renderSideBar()\\\
                end\\\
              else\\\
                tMode.sync.turtles = 0\\\
                tMode.sync.ids = {[senderId] = \\\"computer\\\"}\\\
                if reRenderSideBar then\\\
                  renderSideBar()\\\
                end\\\
              end\\\
            end\\\
            rednet.send(senderId,\\\"Success\\\",{type = event,turtle = turtle and true})\\\
          --else\\\
          --  rednet.send(senderId,\\\"Failure\\\",{type = event})\\\
          --end\\\
          return true\\\
        end\\\
      elseif event == \\\"Sync edit\\\"\\\
      and tMode.sync.ids[senderId] then\\\
        if type == \\\"Ids\\\" then\\\
          tMode.sync = data.sync\\\
          tMode.sync.ids[os.id] = nil\\\
          tMode.sync.ids[senderId] = true\\\
          if turtle then\\\
            tMode.sync.turtles = tMode.sync.turtles-1\\\
          end\\\
          for k,v in pairs(tMode.sync.ids) do\\\
            if not rednet.connected.ids[k] then\\\
              rednet.connected.ids[k] = true\\\
              rednet.connected.amount = rednet.connected.amount+1\\\
            end\\\
          end\\\
        elseif type == \\\"Paste\\\" then --this is used for most tools\\\
          if data.layer then\\\
            tBlueprint[data.layer]:paste(data.l,data.sX,data.sZ,data.merge)\\\
          else\\\
            tBlueprint:paste(data.l,data.sX,data.sZ,data.merge)\\\
          end\\\
          if data.eX and data.eZ then\\\
            renderArea(data.sX,data.sZ,data.eX,data.eZ,true)\\\
          else\\\
            scroll()\\\
          end\\\
        elseif type == \\\"Point\\\" then --probably brush\\\
          tBlueprint[data.layer][data.x][data.z] = data.color\\\
          if tTerm.scroll.layer == data.layer then\\\
            renderPoint(data.x,data.z,true)\\\
          end\\\
					if data.isBuilding then\\\
					  glasses.log.write(\\\"Turtle \\\"..senderId..\\\" \\\"..(data.color and \\\"placed \\\"..keyColor[data.color]..\\\" at\\\" or \\\"broke\\\")..\\\"\\\\n\\\"..data.x..\\\", \\\"..data.layer..\\\", \\\"..data.z)\\\
            if glasses.bridge and glasses.followTurtle then\\\
              scroll(data.layer,data.x-math.floor(tTerm.canvas.tX/2),data.z-math.floor(tTerm.canvas.tZ/2),true,true)\\\
            end\\\
					end\\\
        elseif type == \\\"Delete\\\" then\\\
          for iX = data.sX,data.eX do\\\
            for iZ = data.sZ,data.eZ do\\\
              tBlueprint[data.layer][iX][iZ] = nil\\\
            end\\\
          end\\\
          renderArea(data.sX,data.sZ,data.eX,data.eZ,true)\\\
        elseif type == \\\"Recolor\\\" then\\\
          if data.layers then\\\
            for layer in pairs(data.layers) do\\\
              tBlueprint[data.layer]:recolor(data.color,data.sX,data.sZ,data.eX,data.eZ)\\\
            end\\\
            if data.layers[tTerm.scroll.layer] then\\\
              renderArea(data.sX,data.sZ,data.eX,data.eZ)\\\
            end\\\
          else\\\
            tBlueprint[data.layer]:recolor(data.color,data.sX,data.sZ,data.eX,data.eZ)\\\
            if tTerm.scroll.layer == data.layer then\\\
              renderArea(data.sX,data.sZ,data.eX,data.eZ)\\\
            end\\\
          end\\\
        elseif type == \\\"Mark built\\\" then\\\
          if data.blueprint then\\\
            tBlueprint:markBuilt(nil,nil,nil,nil,data.clearBreak)\\\
            if tMode.renderBuilt then\\\
              renderArea(data.sX,data.sZ,data.eX,data.eZ)\\\
            end\\\
          elseif data.layer then\\\
            tBlueprint[data.layer]:markBuilt(data.sX,data.sZ,data.eX,data.eZ)\\\
            if tMode.renderBuilt and data.layer == tTerm.scroll.layer then\\\
              renderArea(data.sX,data.sZ,data.eX,data.eZ,data.clearBreak)\\\
            end\\\
          elseif data.layers then\\\
            for layer in pairs(data.layers) do\\\
              tBlueprint[layer]:markBuilt(data.sX,data.sZ,data.eX,data.eZ,data.clearBreak)\\\
            end\\\
            if (tMode.renderBuilt or data.clearBreak) and data.layers[tTerm.scroll.layer] then\\\
              renderArea(data.sX,data.sZ,data.eX,data.eZ)\\\
            end\\\
          end\\\
        elseif type == \\\"Mark unbuilt\\\" then\\\
          if data.blueprint then\\\
            tBlueprint:markUnbuilt()\\\
            if tMode.renderBuilt then\\\
              renderArea(data.sX,data.sZ,data.eX,data.eZ)\\\
            end\\\
          elseif data.layer then\\\
            tBlueprint[data.layer]:markUnbuilt(data.sX,data.sZ,data.eX,data.eZ)\\\
            if tMode.renderBuilt and data.layer == tTerm.scroll.layer then\\\
              renderArea(data.sX,data.sZ,data.eX,data.eZ)\\\
            end\\\
          elseif data.layers then\\\
            for layer in pairs(data.layers) do\\\
              tBlueprint[layer]:markUnbuilt(data.sX,data.sZ,data.eX,data.eZ)\\\
            end\\\
            if tMode.renderBuilt and data.layers[tTerm.scroll.layer] then\\\
              renderArea(data.sX,data.sZ,data.eX,data.eZ)\\\
            end\\\
          end\\\
        elseif type == \\\"Layer add\\\" then\\\
          while #tBlueprint < data.layer do\\\
            tBlueprint[#tBlueprint+1] = class.layer.new()\\\
          end\\\
          if tMode.layerBar then\\\
            renderLayerBar(true)\\\
          end\\\
        elseif type == \\\"Layer delete\\\" then\\\
          if data.layers then\\\
            local delLayers = {}\\\
            for layer in pairs(data.layers) do\\\
              delLayers[#delLayers+1] = layer\\\
            end\\\
            table.sort(\\\
              delLayers,\\\
              function(k1,k2)\\\
                return k1 < k2\\\
              end\\\
            )\\\
            for i,layer in ipairs(delLayers) do\\\
              if layer == 1 and #tBlueprint == 1 then\\\
                tBlueprint[1] = tBlueprint[1].new()\\\
              else\\\
                table.remove(tBlueprint,i)\\\
              end\\\
            end\\\
            scroll()\\\
            if tMode.layerBar then\\\
              renderLayerBar(true)\\\
            end\\\
            return\\\
          elseif data.layer then\\\
            data.from = data.layer\\\
            data.to = data.layer\\\
          end\\\
          for layer=data.to,data.from,-1 do\\\
            if layer == 1 and #tBlueprint == 1 then\\\
              tBlueprint[1] = tBlueprint[1].new()\\\
            else\\\
              table.remove(tBlueprint,layer)\\\
            end\\\
          end\\\
          scroll()\\\
          if tMode.layerBar then\\\
            renderLayerBar(true)\\\
          end\\\
        elseif type == \\\"Layer clear\\\" then\\\
          if data.layers then\\\
            for layer in pairs(data.layers) do\\\
              tBlueprint[layer] = class.layer.new()\\\
            end\\\
            if data.layers[tTerm.scroll.layer] then\\\
              scroll()\\\
            end\\\
            return\\\
          elseif data.layer then\\\
            data.from = data.layer\\\
            data.to = data.layer\\\
          end\\\
          for layer=data.from,data.to do\\\
            tBlueprint[layer] = class.layer.new()\\\
          end\\\
          scroll()\\\
        elseif type == \\\"Flip\\\" then\\\
          local flip = data.blueprint and tBlueprint or tBlueprint[data.layer]\\\
          if data.dir == \\\"X\\\" then\\\
            flip:flipX(data.sX,data.sZ,data.eX,data.eZ)\\\
          else\\\
            flip:flipZ(data.sX,data.sZ,data.eX,data.eZ)\\\
          end\\\
          renderArea(data.sX,data.sZ,data.eX,data.eZ)\\\
        elseif type == \\\"Blueprint load\\\" then\\\
          tBlueprint = class.blueprint.copy(data.blueprint)\\\
          tFile.blueprint = data.blueprintName\\\
          scroll(1,0,0,true,true)\\\
          if tMode.layerBar then\\\
            renderLayerBar(true)\\\
          end\\\
        elseif type == \\\"Blueprint sub\\\" then\\\
          tBlueprint = tBlueprint:copy(data.sX,data.sZ,data.eX,data.eZ)\\\
          tBlueprint:save(tFile.blueprint,true)\\\
          for i=1,#tBlueprint do\\\
            scroll(i,0,0,true) --i don't fucking know anymore, I GIVE UP\\\
          end\\\
          scroll(1,0,0,true,true)\\\
        elseif type == \\\"Colorslots load\\\" then\\\
          tBlueprint.colorsSlots = class.matrix.new(2)\\\
          local colorSlots = tBlueprint.colorSlots\\\
          for k,v in pairs(data.colorSlots) do\\\
            for k2,v2 in pairs(v) do\\\
              colorSlots[k][k2] = v2\\\
            end\\\
          end\\\
          tBlueprint:save(tFile.blueprint,true)\\\
        end\\\
        return true\\\
      elseif event == \\\"Sync OFF\\\"\\\
      or event == \\\"Close connection\\\" then\\\
        if tMode.sync.ids[senderId] then\\\
          local turtle = tMode.sync.ids[senderId] == \\\"turtle\\\"\\\
          tMode.sync.turtles = tMode.sync.turtles-(turtle and 1 or 0)\\\
          tMode.sync.amount = tMode.sync.amount-1\\\
          tMode.sync.ids[senderId] = nil\\\
          if turtle and tMode.sync.turtles == 0 then\\\
            renderSideBar()\\\
          end\\\
          window.text((turtle and \\\"Turtle\\\" or \\\"Computer\\\")..\\\" ID \\\"..senderId..\\\" has de-synced\\\")\\\
        end\\\
        if rednet.connected.ids[senderId] then\\\
          rednet.connected.ids[senderId] = nil\\\
          rednet.connected.amount = rednet.connected.amount-1\\\
        end\\\
        return true\\\
      elseif event == \\\"Turtle command\\\" then\\\
        local response = {\\\
          type = event\\\
        }\\\
        if type == \\\"Move\\\" then\\\
          cTurtle.moveToXYZ(data.x,data.y,data.z)\\\
        elseif type == \\\"Turn\\\" then\\\
          cTurtle.turn(data.dir)\\\
        elseif type == \\\"Get blueprint progress\\\" then\\\
          response.progress = loadProgress(data.blueprintName)\\\
          rednet.send(senderId,\\\"Success\\\",response)\\\
        elseif type == \\\"Save blueprint progress\\\" then\\\
          tFile.blueprint = data.blueprintName\\\
          saveProgress(data.blueprintName,data.progress)\\\
        elseif type == \\\"Build\\\" then\\\
          local oldSync = tMode.sync\\\
          tMode.sync = {\\\
            ids = {\\\
              [senderId] = true\\\
            },\\\
            amount = 1,\\\
            turtles = 0\\\
          }\\\
          if data.auto then\\\
            local file = class.fileTable.new(\\\"/startup\\\")\\\
            if not file:find(\\\"--Turtle Architect auto recovery\\\") then\\\
              file:write(\\\
[[\\\
--Turtle Architect auto recovery\\\
if fs.exists(\\\"]]..tFile.blueprint..[[.TAo\\\") then\\\
  shell.run(\\\"]]..tFile.program..\\\" \\\"..tFile.blueprint..[[ -r\\\")\\\
end\\\
]]\\\
              )\\\
              file:save()\\\
            end\\\
          end\\\
          build(tBlueprint,true)\\\
          tMode.sync = oldSync\\\
        end\\\
        return true\\\
      elseif event == \\\"Turtle status\\\" and not tIgnore[senderId] then\\\
        if type == \\\"Build complete\\\" then\\\
				  window.text(\\\"Turtle \\\"..senderId..\\\" has completed construction of \\\"..data.blueprintName)\\\
          return true\\\
				elseif type == \\\"Layer complete\\\" then\\\
					glasses.log.write(\\\"Turtle \\\"..senderId..\\\" completed layer \\\"..data.layer..\\\" of \\\"..data.blueprintName)\\\
          return true\\\
        elseif type == \\\"Blocked\\\" then\\\
          glasses.log.write(\\\"Turtle \\\"..senderId..\\\" is being blocked, please remove the obstruction at\\\\nX: \\\"..data.x..\\\"\\\\nY: \\\"..data.y..\\\"n\\\\Z: \\\"..data.z)\\\
          return true\\\
				elseif type == \\\"Blocks required\\\" then\\\
          local timeOut = tTimers.restockRetry.start()\\\
          local button = window.text(\\\
            \\\"Turtle \\\"..senderId..\\\" requires more \\\"..keyColor[data.color]..\\\" blocks in the slots \\\"..data.slots..\\\" to continue building\\\",\\\
            {\\\
              \\\"Cancel\\\",\\\
              \\\"Ignore\\\",\\\
              \\\"Ok\\\"\\\
            },\\\
            false,\\\
            {\\\
              modem_message = function(tEvent)\\\
                if tEvent[3] == modemChannel\\\
                and _G.type(tEvent[5]) == \\\"table\\\"\\\
                and tEvent[5].rID[os.id] then\\\
                  local data = tEvent[5]\\\
                  local event = data.event\\\
                  local senderId2 = data.sID\\\
                  local type = data.type\\\
                  if event == \\\"Turtle status\\\"\\\
                  and type == \\\"Restock\\\" \\\
                  and senderId == senderId2 then\\\
                    return \\\"Cancel\\\"\\\
                  end\\\
                end\\\
              end,\\\
              timer = function(tEvent)\\\
                if tTimers.restockRetry[tEvent[2]] then\\\
                  return \\\"Cancel\\\"\\\
                end\\\
              end\\\
            }\\\
          )\\\
          if button == \\\"Ok\\\" then\\\
            rednet.send(senderId,\\\"Turtle command\\\",{type == \\\"Restock\\\"})\\\
          elseif button == \\\"Ignore\\\" then\\\
            tIgnore[senderId] = true\\\
          end\\\
          return true\\\
				elseif type == \\\"Fuel required\\\" then\\\
          local timeOut = tTimers.restockRetry.start()\\\
          local button = window.text(\\\
            \\\"Turtle \\\"..senderId..\\\" located at\\\\nX: \\\"..data.x..\\\"\\\\nY: \\\"..data.y..\\\"\\\\nZ: \\\"..data.z..\\\"\\\\nrequires fuel\\\",\\\
            {\\\
              \\\"Cancel\\\",\\\
              \\\"Ignore\\\",\\\
              \\\"Ok\\\"\\\
            },\\\
            false,\\\
            {\\\
              modem_message = function(tEvent)\\\
                if tEvent[3] == modemChannel\\\
                and _G.type(tEvent[5]) == \\\"table\\\"\\\
                and tEvent[5].rID[os.id] then\\\
                  local data = tEvent[5]\\\
                  local event = data.event\\\
                  local senderId2 = data.sID\\\
                  local type = data.type\\\
                  if event == \\\"Turtle status\\\"\\\
                  and type == \\\"Refuel\\\" \\\
                  and senderId == senderId2 then\\\
                    return \\\"Cancel\\\"\\\
                  end\\\
                end\\\
              end,\\\
              timer = function(tEvent)\\\
                if tTimers.restockRetry[tEvent[2]] then\\\
                  return \\\"Cancel\\\"\\\
                end\\\
              end\\\
            }\\\
          )\\\
          if button == \\\"Ok\\\" then\\\
            rednet.send(senderId,\\\"Turtle command\\\",{type == \\\"Refuel\\\"})\\\
          elseif button == \\\"Ignore\\\" then\\\
            tIgnore[senderId] = true\\\
          end\\\
        end\\\
        return true\\\
      elseif event == \\\"Blueprint transmission\\\" then\\\
        local timeoutId = tTimers.inputTimeout.start()\\\
        local button, tRes, reInput = window.text(\\\
          \\\"Received blueprint \\\"..tEvent[5].blueprintName..\\\" from computer ID \\\"..senderId,\\\
          {\\\
            \\\"Ignore\\\",\\\
            \\\"Save\\\",\\\
            \\\"Load\\\"\\\
          },\\\
          {\\\
            {\\\
              name = \\\"File name\\\",\\\
              value = \\\"/\\\",\\\
              accepted = \\\".\\\"\\\
            },\\\
          },\\\
          {\\\
            timer = function(tEvent)\\\
              if tEvent[2] == timeoutId then\\\
                return \\\"Ignore\\\"\\\
              end\\\
            end\\\
          },\\\
          true\\\
        )\\\
        while button ~= \\\"Ignore\\\" do\\\
          timeoutId = false\\\
          fileName = tRes[\\\"File name\\\"]\\\
          if button == \\\"Load\\\" then\\\
            tBlueprint = class.blueprint.copy(data.blueprint)\\\
            tFile.blueprint = nil\\\
            scroll(1,0,0,true,true)\\\
            return\\\
          elseif not fileName then\\\
            button,tRes,reInput = reInput\\\"Invalid file name!\\\"\\\
          elseif fs.exists(fileName..\\\".TAb\\\") then\\\
            button,tRes,reInput = reInput(fileName..\\\" already exists!\\\")\\\
          else\\\
            class.blueprint.save(data.blueprint,fileName)\\\
            window.text(\\\"Successfully saved \\\"..fileName..\\\".TAb.\\\")\\\
            return\\\
          end\\\
        end\\\
        return true\\\
      end\\\
    end\\\
  end,\\\
}\\\
return common\\\
\",\
    [ \"TAFiles/Tools/Code.Lua\" ] = \"codeEnv.tool.select = tTool.change\\\
\\\
codeEnv.getCanvas = function()\\\
  return tBlueprint\\\
end\\\
\\\
codeEnv.getLayer = function(num)\\\
  return tBlueprint[num or codeEnv.click.layer]\\\
end\\\
\\\
codeEnv.settings = { --changing these here has no effect, they're simply used to illustrate their function.\\\
  direct = false, --whether to affect the blueprint directly, or through a pasted blueprint. this should only be enabled if your code is very light drawing wise.\\\
  overwrite = true --overwrite settings\\\
}\\\
\\\
codeEnv.overlay = function(overlay,x,z)\\\
  x = x or 1\\\
  z = z or 1\\\
  if not overlay\\\
  or type(x) ~= \\\"number\\\"\\\
  or type(z) ~= \\\"number\\\" \\\
  or type(overlay) ~= \\\"table\\\" \\\
  or not overlay.size then\\\
    error(\\\"layer,number,number expected\\\",2)\\\
  end\\\
  tTool.shape.sX = x\\\
  tTool.shape.sZ = z\\\
  local eX,eZ = overlay:size()\\\
  tTool.shape.eX = eX+x\\\
  tTool.shape.eZ = eZ+z\\\
  tTool.shape.l = overlay\\\
end\\\
\\\
codeEnv.getOverlay = function()\\\
  return tTool.shape.l\\\
end\\\
\\\
codeEnv.tool.brush = codeEnv.tool.Brush\\\
codeEnv.tool.Brush = nil\\\
codeEnv.tool.line = codeEnv.tool.Line\\\
codeEnv.tool.Line = nil\\\
for k,v in pairs(codeEnv.tool) do --setup proper environment access for the tool functions\\\
  if type(v) == \\\"function\\\" then\\\
    setfenv(v,progEnv)\\\
  end\\\
end\\\
\\\
local tDisabled = { --disabled APIs and functions, edit them if you wish...\\\
  fs = true,\\\
  term = true,\\\
  turtle = true,\\\
  loadfile = true,\\\
  dofile = true,\\\
  io = true,\\\
  paintutils = true,\\\
  window = true,\\\
  shell = true,\\\
  multishell = true,\\\
  print = true,\\\
  write = true\\\
}\\\
local disabled_G = {}\\\
\\\
for k,v in pairs(_G) do\\\
  if tDisabled[k] then\\\
    disabled_G[k] = (\\\
      type(v) == \\\"table\\\"\\\
      and setmetatable(\\\
        {},\\\
        {\\\
          __index = function()\\\
            error(k..\\\" functions are disabled within the code tool!\\\",2)\\\
          end\\\
        }\\\
      )\\\
    ) or (\\\
      function() \\\
        error(k..\\\" is disabled within the code tool!\\\",2)\\\
      end\\\
    )\\\
  elseif type(v) == \\\"table\\\" then\\\
    disabled_G[k] = setmetatable({},{__index = v})\\\
  end\\\
end\\\
disabled_G.getfenv = function(level)\\\
  local env = getfenv(level)\\\
  if env == progEnv\\\
  or env == disabled_G\\\
  or env == _G then\\\
    return codeEnv\\\
  end\\\
  return env\\\
end\\\
\\\
setmetatable(\\\
  codeEnv,\\\
  {\\\
    __index = setmetatable(\\\
      disabled_G,\\\
      {\\\
        __index = _G,\\\
        __metatable = {}\\\
      }\\\
    ),\\\
    __metatable = codeEnv\\\
  }\\\
)\\\
codeEnv._G = codeEnv\\\
\\\
for k,v in pairs(_G.colors) do\\\
  if type(v) == \\\"number\\\" then\\\
    codeEnv.colors[k] = colorKey[v]\\\
    codeEnv.colours[k] = colorKey[v]\\\
  end\\\
end\\\
\\\
local tool  \\\
tool = {\\\
  menuOrder = 10, --menu order, 1 being top\\\
  enabled = true,\\\
  help = function(clickButton)\\\
    local button = window.text(\\\
      \\\"The code tool is a very unique tool. Using regular Lua code, you can code your own tool directly. This code can either be input directly into the dialogue window, or loaded from a file\\\",\\\
      {\\\
        \\\"Ok\\\",\\\
        \\\"Equip\\\"\\\
      }\\\
    )\\\
    if button == \\\"Equip\\\" then\\\
      tool.selectFunc(clickButton)\\\
      return\\\
    end\\\
    button = window.text(\\\
      \\\"Click information is stored in the click table under the keys:\\\\nx,z,color,layer,button and event.\\\\n\\\",\\\
      {\\\
        \\\"Ok\\\",\\\
        \\\"Equip\\\"\\\
      }\\\
    )\\\
    if button == \\\"Equip\\\" then\\\
      tool.selectFunc(clickButton)\\\
      return\\\
    end\\\
    window.text(\\\
      \\\"Most of the default tools may be called from this code as well, indexed in the tool table.\\\\ntool.hSquare(x1,z1,x2,z2,color,layer)\\\\nIf not specified, click.color and click.layer is used for the color and layer respectively\\\",\\\
      {\\\
        \\\"Ok\\\",\\\
        \\\"Equip\\\"\\\
      }\\\
    )\\\
    if button == \\\"Equip\\\" then\\\
      tool.selectFunc(clickButton)\\\
    end\\\
  end,\\\
  selectFunc = function(clickButton)\\\
    local button,tRes,reInput = window.text(\\\
      \\\"Input path to code tool file\\\\nor input code directly.\\\",\\\
      {\\\
        \\\"Cancel\\\",\\\
        \\\"Load\\\",\\\
        \\\"Edit\\\",\\\
        \\\"Compile\\\"\\\
      },\\\
      {\\\
        {\\\
          name = \\\"Path\\\",\\\
          value = codeEnv.code or \\\"/\\\",\\\
          accepted = \\\".\\\"\\\
        }\\\
      },\\\
      false,\\\
      true\\\
    )\\\
    while button ~= \\\"Cancel\\\" do\\\
      local path = tRes.Path\\\
      if button == \\\"Compile\\\" then\\\
        local loadRes = {loadstring(path)}\\\
        if not loadRes[1] then\\\
          button,tRes,reInput = reInput(\\\"Error: \\\"..loadRes[2])\\\
        else\\\
          setfenv(loadRes[1],codeEnv)\\\
          codeEnv.code = path\\\
          codeEnv.settings.direct = false\\\
          codeEnv.settings.overwrite = tMode.overwrite\\\
          tool.renderFunc = function(event,button,x,z,color,layer)\\\
            codeEnv.click = {\\\
              event = event,\\\
              button = button,\\\
              x = x+tTerm.scroll.x,\\\
              z = z+tTerm.scroll.z,\\\
              color = color,\\\
              layer = layer\\\
            }\\\
            codeEnv.blueprint = class.blueprint.new(nil,true)\\\
            local tCallRes = {pcall(loadRes[1])}\\\
            if not tCallRes[1] then\\\
              local button = window.text(\\\
                \\\"Code tool error:\\\\n\\\"..(tCallRes[2]:match\\\"string:1: (.+)\\\" or tCallRes[2]),\\\
                {\\\
                  \\\"Ok\\\",\\\
                  \\\"Edit\\\"\\\
                }\\\
              )\\\
              if button == \\\"Edit\\\" then\\\
                tool.selectFunc()\\\
              end\\\
            elseif not codeEnv.settings.direct then\\\
              tBlueprint:paste(codeEnv.blueprint,nil,nil,not codeEnv.overwrite)\\\
              local syncObj = {\\\
                sX = 0,\\\
                sZ = 0,\\\
                l = codeEnv.blueprint\\\
              }\\\
              sync(syncObj,\\\"Paste\\\")\\\
              scroll()\\\
            end\\\
          end\\\
          break\\\
        end\\\
      elseif button == \\\"Edit\\\" then\\\
        local events = {}\\\
        parallel.waitForAny(\\\
          function()\\\
            shell.run(\\\"edit \\\"..path) --lmao, im actually using shell.run!\\\
          end,\\\
          function()\\\
            while true do\\\
              local tEvent = {os.pullEvent()}\\\
              if tEvent[1] == \\\"modem_message\\\"\\\
              or tEvent[1] == \\\"timer\\\" then\\\
                events[#events+1] = tEvent\\\
              end\\\
            end\\\
          end\\\
        )\\\
        screen:redraw()\\\
        for i=1,#events do\\\
          os.queueEvent(unpack(events[i]))\\\
        end\\\
        button,tRes,reInput = reInput\\\"Input path to code tool file\\\"\\\
      else --button == Load, load code\\\
        if not fs.exists(path) then\\\
          button,tRes,reInput = reInput(path..\\\" does not exist!\\\")\\\
        else\\\
          local loadRes = {loadfile(path)}\\\
          if not loadRes[1] then\\\
            button,tRes,reInput = reInput(\\\"Error: \\\"..loadRes[2])\\\
          else\\\
            codeEnv.settings.direct = false\\\
            codeEnv.settings.overwrite = tMode.overwrite\\\
            setfenv(loadRes[1],codeEnv)\\\
            codeEnv.code = path\\\
            tool.renderFunc = function(event,button,x,z,color,layer)\\\
              codeEnv.settings.direct = false\\\
              codeEnv.click = {\\\
                event = event,\\\
                button = button,\\\
                x = x+tTerm.scroll.x,\\\
                z = z+tTerm.scroll.z,\\\
                color = color,\\\
                layer = layer\\\
              }\\\
              codeEnv.blueprint = class.blueprint.new(nil,true)\\\
              local tCallRes = {pcall(loadRes[1])}\\\
              if not tCallRes[1] then\\\
                local button = window.text(\\\
                  \\\"Code tool error:\\\\n\\\"..tCallRes[2],\\\
                  {\\\
                    \\\"Ok\\\",\\\
                    \\\"Edit\\\"\\\
                  }\\\
                )\\\
                if button == \\\"Edit\\\" then\\\
                  tool.selectFunc()\\\
                end\\\
              elseif not codeEnv.settings.direct then\\\
                tBlueprint:paste(codeEnv.blueprint,nil,nil,not codeEnv.overwrite)\\\
                local syncObj = {\\\
                  sX = 0,\\\
                  sZ = 0,\\\
                  l = codeEnv.blueprint\\\
                }\\\
                sync(syncObj,\\\"Paste\\\")\\\
                scroll()\\\
              end\\\
            end\\\
            break\\\
          end\\\
        end\\\
      end\\\
    end\\\
    if button ~= \\\"Cancel\\\" then\\\
      tTool.change(\\\"Code\\\",clickButton)\\\
    end\\\
  end,\\\
  renderFunc = function(event,button,x,z,color,layer)\\\
    \\\
  end\\\
}\\\
return tool\\\
\",\
    [ \"TAFiles/Tools/Fill.Lua\" ] = \"local tool\\\
tool = {\\\
  menuOrder = 8, --menu order, 1 being top\\\
  enabled = true,\\\
  help = function(clickButton)\\\
    local button = window.text(\\\
      \\\"The fill tool will replace the block you click on and any block connected to it of the same color, to the color it has equipped. It will not go beyond the visible canvas however\\\",\\\
      {\\\
        \\\"Ok\\\",\\\
        \\\"Equip\\\"\\\
      }\\\
    )\\\
    if button == \\\"Equip\\\" then\\\
      tool.selectFunc(clickButton)\\\
    end\\\
  end,\\\
  selectFunc = function(button) --called when the tool is selected\\\
    tTool.change(\\\"Fill\\\",button) --sets the tool on (button) to \\\"Fill\\\"\\\
  end,\\\
  renderFunc = function(event,button,x,z,color,layer) --called when the tool is used\\\
    local replaceColor = tBlueprint[tTerm.scroll.layer][x+tTerm.scroll.x][z+tTerm.scroll.z]\\\
    \\\
    term.setTextColor(colors.black)\\\
    term.setBackgroundColor(colors.white)\\\
    term.setCursorPos(1,1)\\\
    --print(replaceColor)\\\
\\\
    if color == replaceColor then\\\
      return\\\
    end\\\
    --[[\\\
    drawPoint(x,z,color)\\\
    local loops = 0\\\
    local tAffectedPoints = {\\\
      [1] = {\\\
        x = x+tTerm.scroll.x,\\\
        z = z+tTerm.scroll.z\\\
      }\\\
    }\\\
    while #tAffectedPoints > 0 do\\\
      if loops%200 == 0 then\\\
        sleep(0.05)\\\
        --print(#tAffectedPoints)\\\
      end\\\
      for i=-1,1,2 do\\\
        local x = tAffectedPoints[1][\\\"x\\\"]+i\\\
        local z = tAffectedPoints[1][\\\"z\\\"]\\\
        if tBlueprint[layer][x][z] == replaceColor\\\
        and x >= tTerm.viewable.sX and x <= tTerm.viewable.eX \\\
        and z >= tTerm.viewable.sZ and z <= tTerm.viewable.eZ then\\\
          drawPoint(x,z,color,layer,true,true)\\\
          table.insert(tAffectedPoints,{[\\\"x\\\"] = x,[\\\"z\\\"] = z})\\\
        end\\\
        x = tAffectedPoints[1][\\\"x\\\"]\\\
        z = tAffectedPoints[1][\\\"z\\\"]+i\\\
        if tBlueprint[layer][x][z] == replaceColor\\\
        and x >= tTerm.viewable.sX and x <= tTerm.viewable.eX \\\
        and z >= tTerm.viewable.sZ and z <= tTerm.viewable.eZ then\\\
          drawPoint(x,z,color,layer,true,true)\\\
          table.insert(tAffectedPoints,{[\\\"x\\\"] = x,[\\\"z\\\"] = z})\\\
        end\\\
      end\\\
      table.remove(tAffectedPoints,1)\\\
      loops = loops+1\\\
    end\\\
    --]]\\\
\\\
    local tAffectedPointsIndexed = {} -- table of affected points, indexed linearly\\\
    local tAffectedPoints = { -- table of affected points, indexed in a hashmap by coordinate\\\
      [x+tTerm.scroll.x .. \\\",\\\" .. z+tTerm.scroll.z] = {x+tTerm.scroll.x, z+tTerm.scroll.z}\\\
    }\\\
    tAffectedPointsIndexed[1] = tAffectedPoints[x+tTerm.scroll.x .. \\\",\\\" .. z+tTerm.scroll.z]\\\
\\\
    -- Find all fillable points\\\
    local x, z\\\
    local foundPoint = true\\\
    local loops = 0\\\
    while foundPoint do\\\
\\\
      foundPoint = false\\\
\\\
      for i = 1, #tAffectedPointsIndexed do\\\
        if loops % 200 == 0 then\\\
          sleep(0.05)\\\
        end\\\
\\\
        for m = -1, 1, 2 do\\\
          x = tAffectedPointsIndexed[i][1] + m\\\
          z = tAffectedPointsIndexed[i][2]\\\
\\\
          if not tAffectedPoints[x..\\\",\\\"..z]\\\
          and tBlueprint[layer][x][z] == replaceColor\\\
          and x >= tTerm.viewable.sX and x <= tTerm.viewable.eX \\\
          and z >= tTerm.viewable.sZ and z <= tTerm.viewable.eZ then\\\
            tAffectedPoints[x..\\\",\\\"..z] = {x, z}\\\
            table.insert(tAffectedPointsIndexed, tAffectedPoints[x..\\\",\\\"..z])\\\
            foundPoint = true\\\
          end\\\
\\\
          x = tAffectedPointsIndexed[i][1]\\\
          z = tAffectedPointsIndexed[i][2] + m\\\
\\\
          if not tAffectedPoints[x..\\\",\\\"..z]\\\
          and tBlueprint[layer][x][z] == replaceColor\\\
          and x >= tTerm.viewable.sX and x <= tTerm.viewable.eX \\\
          and z >= tTerm.viewable.sZ and z <= tTerm.viewable.eZ then\\\
            tAffectedPoints[x..\\\",\\\"..z] = {x, z}\\\
            table.insert(tAffectedPointsIndexed, tAffectedPoints[x..\\\",\\\"..z])\\\
            foundPoint = true\\\
          end\\\
\\\
        end\\\
\\\
        loops = loops + 1\\\
\\\
      end\\\
\\\
    end\\\
    --print(#tAffectedPointsIndexed)\\\
\\\
    -- Fill all fillable points\\\
    for i = 1, #tAffectedPointsIndexed do\\\
      drawPoint(\\\
        tAffectedPointsIndexed[i][1],\\\
        tAffectedPointsIndexed[i][2],\\\
        color\\\
      )\\\
    end\\\
\\\
    -- Fill tool done, back to last tool\\\
    tTool.change(tTool[button].prevTool,button)\\\
\\\
  end\\\
}\\\
return tool\\\
\",\
    [ \"TAFiles/Classes/matrix.Lua\" ] = \"local matrix\\\
matrix = {\\\
  new = function(dimensions,tTable)\\\
    return setmetatable(\\\
      tTable\\\
      or {\\\
        \\\
      },\\\
      {\\\
        __index = function(t,k)\\\
          if k == nil then\\\
            error(\\\"Attempt to index nil value\\\",2)\\\
          end\\\
          local dimension = dimensions-1\\\
          if dimension <= 0 then\\\
            return nil\\\
          end\\\
          t[k] = matrix.new(dimension)\\\
          return t[k]\\\
        end\\\
      }\\\
    )\\\
  end\\\
}\\\
return matrix \\\
\",\
    [ \"TAFiles/Functions/Turtle.lua\" ] = \"function saveProgress(fileName,tProgress)\\\
  local file = class.fileTable.new()\\\
  file:write(\\\"layers: \\\"..textutils.serialize(tProgress.layers):gsub(\\\"\\\\n%s-\\\",\\\"\\\"))\\\
  file:write(\\\"X: \\\"..tProgress.x)\\\
  file:write(\\\"Y: \\\"..tProgress.y)\\\
  file:write(\\\"Z: \\\"..tProgress.z)\\\
  file:write(\\\"dir X: \\\"..tProgress.dir.x)\\\
  file:write(\\\"dir Y: \\\"..tProgress.dir.y)\\\
  file:write(\\\"dir Z: \\\"..tProgress.dir.z)\\\
  file:write(\\\"Enderchest: \\\"..(tProgress.enderChest or \\\"Disabled\\\"))\\\
  file:write(\\\"Break mode: \\\"..(tProgress.breakMode and \\\"Enabled\\\" or \\\"Disabled\\\"))\\\
  file:save(fileName..\\\".TAo\\\")\\\
end\\\
\\\
function loadProgress(fileName)\\\
  local tOngoing = {}\\\
  local file = fs.open(fileName..\\\".TAo\\\",\\\"r\\\")\\\
  local read = file.readLine\\\
  local line = read()\\\
  tOngoing.layers = textutils.unserialize(line:match\\\"layers: ({.+)\\\" or 1)\\\
  line = read()\\\
  tOngoing.x = tonumber(line:match\\\"X: ([%d-]+)\\\" or 0)\\\
  line = read()\\\
  tOngoing.y = tonumber(line:match\\\"Y: ([%d-]+)\\\" or 0)\\\
  line = read()\\\
  tOngoing.z = tonumber(line:match\\\"Z: ([%d-]+)\\\" or 0)\\\
  tOngoing.dir = {}\\\
  line = read()\\\
  tOngoing.dir.x = line:match\\\"dir X: ([+-])\\\" or \\\"+\\\"\\\
  line = read()\\\
  tOngoing.dir.y = line:match\\\"dir Y: ([+-])\\\" or \\\"+\\\"\\\
  line = read()\\\
  tOngoing.dir.z = line:match\\\"dir Z: ([+-])\\\" or \\\"+\\\"\\\
  line = read()\\\
  tOngoing.enderChest = tonumber(line:match\\\"Enderchest: (%d+)\\\") or false\\\
  line = read()\\\
  tOngoing.breakMode = (line:match\\\"Break mode: (.+)\\\" == \\\"Enabled\\\")\\\
  file.close()\\\
  return tOngoing\\\
end\\\
\\\
function selectColor(color,threshold)\\\
  --checks the slots assigned to (color) for blocks,\\\
  --and acts accordingly\\\
  threshold = threshold or 0 --min amount of items in accepted slot\\\
  while true do\\\
    for k,v in pairs(tBlueprint.colorSlots[color]) do\\\
      if turtle.getItemCount(v) >= threshold then\\\
        turtle.select(v)\\\
        return true\\\
      end\\\
    end\\\
    if cTurtle.tSettings.enderFuel then\\\
      if cTurtle.enderRestock(cTurtle.tSettings.enderFuel,tBlueprint.colorSlots[color],tBlueprint.colorSlots[color]) then\\\
        turtle.select(tBlueprint.colorSlots[color][1])\\\
        return true\\\
      end\\\
    end\\\
    local retry = tTimers.restockRetry.start()\\\
    if tMode.sync.amount > 0 then\\\
      rednet.send(tMode.sync.ids,\\\"Turtle status\\\",{type = \\\"Blocks required\\\",color = color, slots = tBlueprint.colorSlots[color][1]..\\\"-\\\"..tBlueprint.colorSlots[color][#tBlueprint.colorSlots[color]]})\\\
    end\\\
    local button,tRes = window.text(\\\
      keyColor[color]..\\\" blocks required in slots \\\"..tBlueprint.colorSlots[color][1]..\\\"-\\\"..tBlueprint.colorSlots[color][#tBlueprint.colorSlots[color]],\\\
      {\\\
        \\\"Cancel\\\",\\\
        \\\"Ok\\\"\\\
      },\\\
      false,\\\
      {\\\
        timer = function(tEvent)\\\
          if tEvent[2] == retry then\\\
            return \\\"Ok\\\"\\\
          end\\\
        end,\\\
        modem_message = function(tEvent)\\\
          if tEvent[3] == modemChannel\\\
          and type(tEvent[5]) == \\\"table\\\"\\\
          and tEvent[5].rID[os.id] then\\\
            local data = tEvent[5]\\\
            local event = data.event\\\
            local senderId = data.sID\\\
            local type = data.type\\\
            if event == \\\"Turtle command\\\"\\\
            and type == \\\"Restock\\\" then\\\
              return \\\"Ok\\\"\\\
            end\\\
          end\\\
        end\\\
      }\\\
    )\\\
    if button == \\\"Cancel\\\" then\\\
      return false\\\
    end\\\
  end\\\
end\\\
\\\
function checkUsage(blueprint,tLayers)\\\
  --checks amount of materials required to build the given blueprint\\\
  blueprint = blueprint or tBlueprint\\\
  if not tOngoing.layers then\\\
    tOngoing.layers = {}\\\
    for i=1,#tBlueprint do\\\
      tOngoing.layers[i] = i\\\
    end\\\
  end\\\
  local tUsage = {\\\
    fuel = 0\\\
  }\\\
  local tPos = {\\\
    x = 0,\\\
    y = 1,\\\
    z = 0\\\
  }\\\
  local placed = class.matrix.new(3)\\\
  local loop = 0\\\
  for iL,nL in ipairs(tLayers) do\\\
    for nX,vX in pairs(blueprint[nL]) do\\\
      for nZ,block in pairs(vX) do\\\
        local nX = nX\\\
        while block do\\\
          if block:match\\\"[%lXS]\\\"\\\
          and not placed[nL][nX][nZ] then\\\
            tUsage.fuel = math.abs(nX-tPos.x+math.abs(nZ-tPos.z))+tUsage.fuel\\\
            tPos.z = nZ\\\
            tPos.x = nX\\\
            tUsage[block] = (tUsage[block] or 0)+1\\\
            placed[nL][nX][nZ] = true\\\
          end\\\
          block = nil\\\
          local nextBlock = {}\\\
          for i=-1,1 do --scan for blocks in vicinity\\\
            for j=-1,1 do\\\
              if blueprint[nL][nX+i][nZ+j]:match\\\"[X%l]\\\"\\\
              and not placed[nL][nX+i][nZ+j] then\\\
                nextBlock = {\\\
                  b = blueprint[nL][nX+i][nZ+j],\\\
                  nX = nX+i,\\\
                  nZ = nZ+j\\\
                }\\\
                if j == 0\\\
                or i == 0 then --1 block away, diagonal blocks are second priority\\\
                  block = nextBlock.b\\\
                  break\\\
                end\\\
              end\\\
              if block then\\\
                break\\\
              end\\\
            end\\\
            if block then\\\
              break\\\
            end\\\
          end\\\
          block = block or nextBlock.b\\\
          nX = nextBlock.nX\\\
          nZ = nextBlock.nZ\\\
        end\\\
      end\\\
    end\\\
    tUsage.fuel = math.abs(nL-tPos.y)+tUsage.fuel\\\
    tPos.y = nL\\\
    loop = loop+1\\\
    if loop%10 == 0 then\\\
      sleep(0.05)\\\
    end\\\
  end\\\
  return tUsage\\\
end\\\
\\\
function assignColorSlots(color)\\\
  local tSelection = {}\\\
  for iS = 1,16 do\\\
    tSelection[iS] = {}\\\
    local selection = tSelection[iS]\\\
    selection.text = tostring(iS)\\\
    for iC,v in ipairs(tBlueprint.colorSlots[color]) do\\\
      if v == iS then\\\
        selection.selected = true\\\
        break\\\
      end\\\
    end\\\
  end\\\
  local button, tRes = window.scroll(\\\
    \\\"Select slots for \\\"..keyColor[color],\\\
    tSelection,\\\
    true\\\
  )\\\
  if button ~= \\\"Cancel\\\" then\\\
    table.sort(tRes)\\\
    tBlueprint.colorSlots[color] = {}\\\
    for i,slot in ipairs(tRes) do\\\
      tBlueprint.colorSlots[color][i] = tonumber(slot)\\\
    end\\\
    return true\\\
  end\\\
  return false\\\
end\\\
\\\
function checkProgress(fileName,tProgress,blueprint,auto)\\\
  blueprint = blueprint or class.blueprint.load(fileName) or tBlueprint\\\
  if fileName\\\
  and fs.exists(fileName..\\\".TAo\\\")\\\
  and not tProgress then\\\
    tProgress = loadProgress(fileName)\\\
    if auto then\\\
      return tProgress\\\
    else\\\
      local button = window.text(\\\
        [[In-progress build of current blueprint found.\\\
layers ]]..tProgress.layers[1]..[[-]]..tProgress.layers[#tProgress.layers]..[[ \\\
X: ]]..tProgress.x..[[ \\\"]]..tProgress.dir.x..[[\\\"\\\
Y: ]]..tProgress.y..[[ \\\"]]..tProgress.dir.y..[[\\\"\\\
Z: ]]..tProgress.z..[[ \\\"]]..tProgress.dir.z..[[\\\"\\\
Break mode: ]]..(tProgress.breakMode and \\\"ON\\\" or \\\"OFF\\\")..[[ \\\
Enderchest: ]]..(tProgress.enderChest or \\\"Disabled\\\")..[[ \\\
Load?]],\\\
        {\\\
          \\\"Yes\\\",\\\
          \\\"No\\\"\\\
        }\\\
      )\\\
      if button == \\\"No\\\" then\\\
        tProgress = {\\\
          dir = {}\\\
        }\\\
      end\\\
    end\\\
  else\\\
    tProgress = {\\\
      dir = {}\\\
    }\\\
  end\\\
  if not (tProgress.layers) then\\\
    local tSelection = {}\\\
    for i=1,#tBlueprint do\\\
      tSelection[i] = {\\\
        text = tostring(i),\\\
        selected = true\\\
      }\\\
    end\\\
    local button, tRes, reinput = window.scroll(\\\
      \\\"Select layers to build\\\",\\\
      tSelection,\\\
      true,\\\
      true\\\
    )\\\
    while button ~= \\\"Cancel\\\" do\\\
      if #tRes < 1 then\\\
        button, tRes, reinput = reinput(\\\"Atleast 1 layer must be selected\\\")\\\
      else\\\
        tProgress.layers = {}\\\
        for i,v in ipairs(tRes) do\\\
          tProgress.layers[i] = tonumber(v)\\\
        end\\\
        break\\\
      end\\\
    end\\\
    if button == \\\"Cancel\\\" then\\\
      return false\\\
    end\\\
  end\\\
  local tUsage = checkUsage(blueprint,tProgress.layers)\\\
  local fuelUsage = tUsage.fuel\\\
  tUsage.fuel = nil\\\
  for k,v in pairs(tUsage) do\\\
    if not tBlueprint.colorSlots[k][1] then\\\
      if not assignColorSlots(k) then\\\
        window.text(\\\"Construction cancelled.\\\")\\\
        return false\\\
      end\\\
    end\\\
  end\\\
  blueprint:save(fileName or tFile.blueprint)\\\
  if not tProgress.x then\\\
    local button, tRes, reInput = window.text(\\\
      \\\"Input build coordinates\\\",\\\
      {\\\
        \\\"Cancel\\\",\\\
        \\\"Ok\\\",\\\
        (cTurtle and \\\"Cur pos\\\" or nil)\\\
      },\\\
      {\\\
        {\\\
          name = \\\"X\\\",\\\
          value = cTurtle and cTurtle.tPos.x or \\\"\\\",\\\
          accepted = \\\"[+%d-]\\\"\\\
        },\\\
        {\\\
          name = \\\"Y\\\",\\\
          value = cTurtle and cTurtle.tPos.y or \\\"\\\",\\\
          accepted = \\\"[%d+-]\\\"\\\
        },\\\
        {\\\
          name = \\\"Z\\\",\\\
          value = cTurtle and cTurtle.tPos.z or \\\"\\\",\\\
          accepted = \\\"[%d+-]\\\"\\\
        },\\\
      },\\\
      false,\\\
      true\\\
    )\\\
    while true do\\\
      if button == \\\"Cancel\\\" then\\\
        window.text(\\\"Construction cancelled.\\\")\\\
        return\\\
      elseif button == \\\"Cur pos\\\" then\\\
        tRes.X = cTurtle.tPos.x\\\
        tRes.Y = cTurtle.tPos.y\\\
        tRes.Z = cTurtle.tPos.z\\\
      end\\\
      if not tRes.X then\\\
        button,tRes,reInput = reinput(\\\"Missing parameter X!\\\")\\\
      elseif not tRes.Y then\\\
        button,tRes,reInput = reinput(\\\"Missing parameter Y!\\\")\\\
      elseif not tRes.Z then\\\
        button,tRes,reInput = reinput(\\\"Missing parameter Z!\\\")\\\
      elseif button == \\\"Ok\\\" or button == \\\"Cur pos\\\" then\\\
        tProgress.x = tRes.X\\\
        tProgress.y = tRes.Y\\\
        tProgress.z = tRes.Z\\\
        break\\\
      end\\\
    end\\\
  end\\\
  if not tProgress.dir.x then\\\
    local button, tRes, reInput = window.text(\\\
      \\\"Input build directions\\\",\\\
      {\\\
        \\\"Cancel\\\",\\\
        \\\"Ok\\\",\\\
      },\\\
      {\\\
        {\\\
          name = \\\"X\\\",\\\
          value = \\\"+\\\",\\\
          accepted = \\\"[+-]\\\",\\\
          charLimit = 1\\\
        },\\\
        {\\\
          name = \\\"Y\\\",\\\
          value = \\\"+\\\",\\\
          accepted = \\\"[+-]\\\",\\\
          charLimit = 1\\\
        },\\\
        {\\\
          name = \\\"Z\\\",\\\
          value = \\\"+\\\",\\\
          accepted = \\\"[+-]\\\",\\\
          charLimit = 1\\\
        },\\\
      },\\\
      false,\\\
      true\\\
    )\\\
    while true do\\\
      if button == \\\"Cancel\\\" then\\\
        window.text(\\\"Construction cancelled.\\\")\\\
        return\\\
      elseif not tRes.X then\\\
        button,tRes,reInput = reinput(\\\"Missing X direction!\\\")\\\
      elseif not tRes.Y then\\\
        button,tRes,reInput = reinput(\\\"Missing Y direction!\\\")\\\
      elseif not tRes.Z then\\\
        button,tRes,reInput = reinput(\\\"Missing Z direction!\\\")\\\
      elseif button == \\\"Ok\\\" then\\\
        tProgress.dir.x = tRes.X\\\
        tProgress.dir.y = tRes.Y\\\
        tProgress.dir.z = tRes.Z\\\
        break\\\
      end\\\
    end\\\
  end\\\
  if not tProgress.enderChest and not auto then\\\
    local button, tRes, reInput = window.text(\\\
      \\\"Enable ender chest?\\\",\\\
      {\\\
        \\\"No\\\",\\\
        \\\"Ok\\\",\\\
        (cTurtle and \\\"Permanent\\\" or nil)\\\
      },\\\
      {\\\
        {\\\
          name = \\\"Slot\\\",\\\
          value = \\\"\\\",\\\
          accepted = \\\"%d\\\",\\\
          charLimit = 2\\\
        },\\\
      },\\\
      false,\\\
      true\\\
    )\\\
    while button ~= \\\"No\\\" do\\\
      if not tRes.Slot then\\\
        break\\\
      elseif tRes.Slot and (tRes.Slot > 16 or tRes.Slot < 1 ) then\\\
        button,tRes,reInput = reinput(\\\"Invalid slot \\\"..tRes.Slot)\\\
      elseif button == \\\"Ok\\\" then\\\
        tProgress.enderChest = tRes.Slot\\\
        if cTurtle then\\\
          cTurtle.tSettings.enderFuel = tRes.Slot\\\
        end\\\
        break\\\
      elseif button == \\\"Permanent\\\" then\\\
        tProgress.enderChest = tRes.Slot\\\
        cTurtle.tSettings.enderFuel = tProgress.enderChest\\\
        cTurtle.saveSettings()\\\
        break\\\
      end\\\
    end\\\
  end\\\
  if not tProgress.breakMode and not auto then\\\
    local button = window.text(\\\
      \\\"Enable break mode?\\\",\\\
      {\\\
        \\\"No\\\",\\\
        \\\"Yes\\\"\\\
      }\\\
    )\\\
    tProgress.breakMode = (button == \\\"Ok\\\" or button == \\\"Yes\\\")\\\
  end\\\
  saveProgress(fileName,tProgress)\\\
  return tProgress,fileName\\\
end\\\
\\\
function build(blueprint,auto)\\\
  --builds the given blueprint layers\\\
  if not tFile.blueprint then\\\
    if not dialogue.save\\\"Blueprint must be saved locally prior to building\\\" then\\\
      window.text\\\"Construction cancelled\\\"\\\
      return\\\
    end\\\
  end\\\
  blueprint = blueprint or tBlueprint\\\
  local tOngoing \\\
  if not auto then\\\
    tOngoing = checkProgress(tFile.blueprint)\\\
    if not tOngoing then\\\
      window.text\\\"Construction cancelled\\\"\\\
      return\\\
    end\\\
    local button = window.text(\\\
      \\\"Enable auto resume?\\\",\\\
      {\\\
        \\\"No\\\",\\\
        \\\"Yes\\\"\\\
      }\\\
    )\\\
    if button == \\\"Yes\\\" or button == \\\"Ok\\\" then\\\
      local file = class.fileTable.new(\\\"/startup\\\")\\\
      if not file:find(\\\"--Turtle Architect auto recovery\\\") then\\\
        file:write(\\\
[[--Turtle Architect auto recovery\\\
if fs.exists(\\\"]]..tFile.blueprint..[[.TAo\\\") then\\\
  shell.run(\\\"]]..tFile.program..\\\" \\\"..tFile.blueprint..[[ -r\\\")\\\
end]]\\\
        )\\\
        file:save()\\\
      end\\\
      auto = true\\\
    end\\\
  else\\\
    tOngoing = loadProgress(tFile.blueprint)\\\
  end\\\
  cTurtle.tSettings.enderFuel = tOngoing.enderChest\\\
  screen:refresh()\\\
  local digSlot = blueprint.colorSlots.X[1] or 1\\\
  tOngoing.dropoff = #blueprint.colorSlots.X > 1 and tOngoing.enderChest and blueprint.colorSlots.X[#blueprint.colorSlots.X]\\\
  table.sort(blueprint.colorSlots.X)\\\
  local dirX = tOngoing.dir.x\\\
  local dirZ = tOngoing.dir.z\\\
  local dirY = tOngoing.dir.y\\\
  local buildDir = dirY == \\\"+\\\" and \\\"Y-\\\" or \\\"Y+\\\"\\\
  local revBuildDir = dirY == \\\"+\\\" and \\\"Y+\\\" or \\\"Y-\\\"\\\
  local blockAbove\\\
  local saveCount = 0\\\
  local scanMode = blueprint.colorSlots.S and blueprint.colorSlots.S[1]\\\
  local function moveTo(nL,nX,nZ,skipCheck)\\\
    local mL = tonumber(dirY..nL-1)\\\
    local mX = tonumber(dirX..nX-1)\\\
    local mZ = tonumber(dirZ..nZ-1)\\\
    local cL = math.abs(cTurtle.tPos.y)-math.abs(tOngoing.y)+1\\\
    local cX = math.abs(cTurtle.tPos.x)-math.abs(tOngoing.x)+1\\\
    local cZ = math.abs(cTurtle.tPos.z)-math.abs(tOngoing.z)+1\\\
    local dL = tonumber(nL..dirY..(1))\\\
    cTurtle.moveTo(tOngoing.y + mL,\\\"Y\\\",tOngoing.breakMode and digSlot)\\\
    if blueprint[dL] then\\\
      for iL=math.min(cL,dL),math.max(nL,dL) do\\\
        local xLine = blueprint[iL][cX]\\\
        if xLine[cZ] == \\\"X\\\" then\\\
          xLine[cZ] = nil\\\
          sync(\\\
            {\\\
              layer = iL,\\\
              x = cX,\\\
              z = cZ,\\\
              isBuilding = true\\\
            },\\\
            \\\"Point\\\"\\\
          )\\\
        end\\\
      end\\\
      local layer = blueprint[dL]\\\
      cTurtle.moveTo(tOngoing.x + mX,\\\"X\\\",tOngoing.breakMode and digSlot)\\\
      for iX=math.min(cX,nX),math.max(nX,cX) do\\\
        local xLine = layer[iX]\\\
        if xLine[cZ] == \\\"X\\\" then\\\
          xLine[cZ] = nil\\\
          sync(\\\
            {\\\
              layer = dL+1,\\\
              x = iX,\\\
              z = cZ,\\\
              isBuilding = true\\\
            },\\\
            \\\"Point\\\"\\\
          )\\\
        end\\\
      end\\\
      local xLine = layer[nX]\\\
      cTurtle.moveTo(tOngoing.z + mZ,\\\"Z\\\",tOngoing.breakMode and digSlot)\\\
      for iZ=math.min(cZ,nZ),math.max(nZ,cZ) do\\\
        if xLine[iZ] == \\\"X\\\" then\\\
          xLine[iZ] = nil\\\
          sync(\\\
            {\\\
              layer = dL+1,\\\
              x = nX,\\\
              z = iZ,\\\
              isBuilding = true\\\
            },\\\
            \\\"Point\\\"\\\
          )\\\
        end\\\
      end\\\
    else\\\
      cTurtle.moveTo(tOngoing.x + mX,\\\"X\\\",tOngoing.breakMode and digSlot)\\\
      cTurtle.moveTo(tOngoing.z + mZ,\\\"Z\\\",tOngoing.breakMode and digSlot)\\\
    end\\\
  end\\\
  for iL,nL in ipairs(tOngoing.layers) do\\\
    local layerCopy = blueprint[nL]:copy() --table copy because fuck you next\\\
    for nX,vX in pairs(layerCopy) do\\\
      for nZ in pairs(vX) do\\\
        local block = blueprint[nL][nX][nZ]\\\
        local nX = nX\\\
        while block do\\\
          if scanMode then\\\
            if block == \\\"S\\\" then --scan block\\\
              if not blockAbove then\\\
                moveTo(nL,nX,nZ)\\\
              end\\\
              if cTurtle.detect(blockAbove and revBuildDir or buildDir) then\\\
                local identified\\\
                for i,slot in ipairs(blueprint.colorSlots.S) do\\\
                  if cTurtle.compare(buildDir,slot) then\\\
                    identified = slot\\\
                    break\\\
                  end\\\
                end\\\
                identified = identified and colorKey[2^identified] or \\\"X\\\"\\\
                blueprint[nL][nX][nZ] = identified\\\
                saveCount = saveCount+1\\\
                if saveCount >= 25 then\\\
                  blueprint:save(tFile.blueprint,true)\\\
                  saveCount = 0\\\
                end\\\
                sync(\\\
                  {\\\
                    layer = nL,\\\
                    x = nX,\\\
                    z = nZ,\\\
                    color = identified,\\\
                    isBuilding = true\\\
                  },\\\
                  \\\"Point\\\"\\\
                )\\\
                scroll(nL,nX-math.floor(tTerm.canvas.tX/2),nZ-math.floor(tTerm.canvas.tZ/2),true,true)\\\
                screen:refresh()\\\
              else\\\
                blueprint[nL][nX][nZ] = nil\\\
                saveCount = saveCount+1\\\
                if saveCount >= 25 then\\\
                  blueprint:save(tFile.blueprint,true)\\\
                  saveCount = 0\\\
                end\\\
                sync(\\\
                  {\\\
                    layer = nL,\\\
                    x = nX,\\\
                    z = nZ,\\\
                    isBuilding = true\\\
                  },\\\
                  \\\"Point\\\"\\\
                )\\\
                scroll(nL,nX-math.floor(tTerm.canvas.tX/2),nZ-math.floor(tTerm.canvas.tZ/2),true,true)\\\
                screen:refresh()\\\
              end\\\
            end\\\
          elseif block:match\\\"%l\\\" then --unbuilt block\\\
            moveTo(nL,nX,nZ)\\\
            if not selectColor(block,2) then\\\
              window.text(\\\"Construction cancelled.\\\")\\\
              return\\\
            end\\\
            cTurtle.replace(buildDir,false,digSlot)\\\
            blueprint[nL][nX][nZ] = block:upper()\\\
            saveCount = saveCount+1\\\
            if saveCount >= 25 then\\\
              blueprint:save(tFile.blueprint,true)\\\
              saveCount = 0\\\
            end\\\
            sync(\\\
              {\\\
                layer = nL,\\\
                x = nX,\\\
                z = nZ,\\\
                color = block:upper(),\\\
								isBuilding = true\\\
              },\\\
              \\\"Point\\\"\\\
            )\\\
            scroll(nL,nX-math.floor(tTerm.canvas.tX/2),nZ-math.floor(tTerm.canvas.tZ/2),true,true)\\\
            screen:refresh()\\\
          elseif block == \\\"X\\\" then --break block\\\
            turtle.select(blueprint.colorSlots.X[1])\\\
            if not blockAbove then\\\
              moveTo(nL,nX,nZ)\\\
            end\\\
            if tOngoing.dropoff then\\\
              if turtle.getItemCount(tOngoing.dropoff) > 0 then\\\
                cTurtle.enderDropoff(cTurtle.tSettings.enderFuel,tBlueprint.colorSlots.X,tBlueprint.colorSlots.X)\\\
              end\\\
            elseif turtle.getItemCount(blueprint.colorSlots.X[#blueprint.colorSlots.X]) > 0 then\\\
              cTurtle.drop(\\\"Y-\\\",false,64)\\\
            end\\\
            cTurtle.dig(blockAbove and revBuildDir or buildDir)\\\
            blueprint[nL][nX][nZ] = nil\\\
            saveCount = saveCount+1\\\
            if saveCount >= 25 then\\\
              blueprint:save(tFile.blueprint,true)\\\
              saveCount = 0\\\
            end\\\
            sync(\\\
              {\\\
                layer = nL,\\\
                x = nX,\\\
                z = nZ,\\\
								isBuilding = true\\\
              },\\\
              \\\"Point\\\"\\\
            )\\\
            scroll(nL,nX-math.floor(tTerm.canvas.tX/2),nZ-math.floor(tTerm.canvas.tZ/2),true,true)\\\
            screen:refresh()\\\
          end\\\
          if blockAbove and (blockAbove == \\\"X\\\" or blockAbove == \\\"S\\\") then\\\
            nL = dirY == \\\"+\\\" and nL-2 or nL+2\\\
            blockAbove = false\\\
          else\\\
            blockAbove = ( --check for block above/below turtle\\\
              dirY == \\\"+\\\" and (rawget(blueprint,nL+2) and blueprint[nL+2][nX][nZ]) \\\
              or (rawget(blueprint,nL-2) and blueprint[nL-2][nX][nZ])\\\
            )\\\
          end\\\
          if blockAbove and (blockAbove == \\\"X\\\" and not scanMode or blockAbove == \\\"S\\\") then\\\
            block = blockAbove\\\
            nL = dirY == \\\"+\\\" and nL+2 or nL-2\\\
          else\\\
            block = nil\\\
            local nextBlock = {}\\\
            local dir = cTurtle.tPos.dir\\\
            local iX1 = 1\\\
            local iX2 = -1\\\
            local iX3 = -1\\\
            local iZ1 = 1\\\
            local iZ2 = -1\\\
            local iZ3 = -1\\\
            if dir == 3 then\\\
              iX1 = -1\\\
              iX2 = 1\\\
              iX3 = 1\\\
            elseif dir == 4 then\\\
              iZ1 = -1\\\
              iZ2 = 1\\\
              iZ3 = 1\\\
            end\\\
            for iX=iX1,iX2,iX3 do --scan for blocks in vicinity\\\
              for iZ=iZ1,iZ2,iZ3 do\\\
                local newBlock = blueprint[nL][nX+iX][nZ+iZ]\\\
                if newBlock and newBlock:match\\\"[XS%l]\\\" and (not scanMode or newBlock == \\\"S\\\") then\\\
                  nextBlock = {\\\
                    b = newBlock,\\\
                    nX = nX+iX,\\\
                    nZ = nZ+iZ\\\
                  }\\\
                  if iZ == 0\\\
                  or iX == 0 then --1 block away, diagonal blocks are second priority\\\
                    block = nextBlock.b\\\
                    nextBlock.nonDiagonal = true\\\
                    break\\\
                  end\\\
                end\\\
              end\\\
              if  nextBlock.nonDiagonal then\\\
                break\\\
              end\\\
            end\\\
            block = block or nextBlock.b\\\
            nX = nextBlock.nX\\\
            nZ = nextBlock.nZ\\\
          end\\\
        end\\\
      end\\\
    end\\\
		if tMode.sync.amount > 0 then\\\
			rednet.send(tMode.sync.ids,\\\"Turtle status\\\",{type = \\\"Layer complete\\\", blueprintName = tFile.blueprint, layer = nL})\\\
    end\\\
  end\\\
  blueprint:save(tFile.blueprint,true)\\\
	if tMode.sync.amount > 0 then\\\
	  rednet.send(tMode.sync.ids,\\\"Turtle status\\\",{type = \\\"Build complete\\\", blueprintName = tFile.blueprint})\\\
	end\\\
  if auto then\\\
    local file = class.fileTable.new(\\\"/startup\\\")\\\
    local line = file:find(\\\"--Turtle Architect auto recovery\\\")\\\
    if line then\\\
      for i=line+3,line,-1 do\\\
        file:delete(i)\\\
      end\\\
    end\\\
    file:save()\\\
  end\\\
end\\\
\",\
    [ \"TAFiles/Menus/mainMenus/Turtle.Lua\" ] = \"local menu\\\
menu = {\\\
  enabled = turtle and true,\\\
  [1] = {\\\
    name = \\\"Move to...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Moves the turtle to the given coordinates\\\"\\\
    end,\\\
    func = function()\\\
      local button, tRes = window.text(\\\
        \\\"Move to coordinates...\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"X\\\",\\\
            value = cTurtle.tPos.x,\\\
            accepted = \\\"[-+%d]\\\"\\\
          },\\\
          {\\\
            name = \\\"Y\\\",\\\
            value = cTurtle.tPos.y,\\\
            accepted = \\\"[-+%d]\\\"\\\
          },\\\
          {\\\
            name = \\\"Z\\\",\\\
            value = cTurtle.tPos.z,\\\
            accepted = \\\"[-+%d]\\\"\\\
          },\\\
        }\\\
      )\\\
      if button == \\\"Ok\\\" then\\\
        screen:refresh()\\\
        cTurtle.moveToXYZ(tRes.X,tRes.Y,tRes.Z)\\\
      end\\\
    end\\\
  },\\\
  [2] = {\\\
    name = \\\"Turn\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Turns the turtle in the given direction. Supports most forms of direction input like x+, north, right\\\"\\\
    end,\\\
    func = function()\\\
      local button, tRes = window.text(\\\
        \\\"Turn to...\\\",\\\
        {\\\
          \\\"Cancel\\\",\\\
          \\\"Ok\\\"\\\
        },\\\
        {\\\
          {\\\
            name = \\\"Direction\\\",\\\
            value = cTurtle.tPos.dir,\\\
            accepted = \\\".\\\"\\\
          },\\\
        }\\\
      )\\\
    end\\\
  },\\\
  [3] = {\\\
    name = \\\"Build blueprint...\\\",\\\
    enabled = true,\\\
    help = function()\\\
      window.text\\\"Begins construction of the currently loaded blueprint, missing build parameters will be requested as well\\\"\\\
    end,\\\
    func = function()\\\
      build(tBlueprint)\\\
    end\\\
  },\\\
}\\\
return menu\\\
\",\
    [ \"TAFiles/Menus/main.Lua\" ] = \"local main = { --note that the menus are numbered from the bottom and up\\\
  [7] = \\\"Blueprint\\\",\\\
  [6] = \\\"Layer\\\",\\\
  [5] = \\\"Tools\\\",\\\
  [4] = \\\"Commands\\\",\\\
  [3] = \\\"Turtle\\\",\\\
  [2] = \\\"Sync\\\",\\\
  [1] = \\\"Settings\\\",\\\
}\\\
\\\
for i = 1,#main do\\\
  main[i] = {\\\
    name = main[i],\\\
    items = loadFile(tFile.mainMenuFolder..\\\"/\\\"..main[i]..\\\".Lua\\\",progEnv)\\\
  }\\\
  main[i].enabled = main[i].items.enabled\\\
  main[main[i].name] = main[i]\\\
end\\\
\\\
--create menu strings\\\
for iMain = 1,#main do\\\
  local items = main[iMain].items\\\
  local longest = #main[iMain].name\\\
  for iItems = 1,#items do\\\
    longest = math.max(longest,#items[iItems].name)\\\
  end\\\
  longest = longest/2 --center text\\\
  for iItems = 1,#items do\\\
    local name = items[iItems].name\\\
    items[iItems].string = string.rep(\\\" \\\",math.floor(longest+1-(#name/2)))..name..string.rep(\\\" \\\",math.ceil(longest+1-(#name/2)))\\\
  end\\\
  local name = main[iMain].name\\\
  main[iMain].string = string.rep(\\\" \\\",math.floor(longest+1-(#name/2)))..name..string.rep(\\\" \\\",math.ceil(longest+1-(#name/2)))\\\
end\\\
\\\
main.enabled = function()\\\
  local enabled = 0\\\
  for i,menu in ipairs(main) do\\\
    if type(menu.enabled) == \\\"function\\\" and menu.enabled() or menu.enabled == true then\\\
      enabled = enabled+1\\\
    end\\\
  end\\\
  return enabled\\\
end\\\
\\\
return main\\\
\",\
  },\
}")
if fs.isReadOnly(outputPath) then
	error("Output path is read-only. Abort.")
elseif fs.getFreeSpace(outputPath) <= #archive then
	error("Insufficient space. Abort.")
end

if fs.exists(outputPath) and fs.combine("", outputPath) ~= "" then
	print("File/folder already exists! Overwrite?")
	stc(colors.lightGray)
	print("(Use -o when making the extractor to always overwrite.)")
	stc(colors.white)
	if choice() ~= 1 then
		error("Chose not to overwrite. Abort.")
	else
		fs.delete(outputPath)
	end
end
if selfDelete or (fs.combine("", outputPath) == shell.getRunningProgram()) then
	fs.delete(shell.getRunningProgram())
end
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
