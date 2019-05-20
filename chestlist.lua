--Initially started by MinerMan132
--Also made by LDDestroier I guess
--Config

--List your chest type
--(String)
local chestType = "minecraft:ironchest_diamond"

--Select what container you want for dispensing
--(String)
local dropperName = "minecraft:dropper_240"
local dropper = peripheral.wrap(dropperName)

--Determine how far from the bottom of the screen the list will cut off at
--(Number)
local listBottom = 4

--Choose what direction you want to dispense
--(String)
local dropdir = "east"

--Choose your input chest
--(String)
local input = "quark:quark_chest_1241"


--===============================================--

if chestType == nil then
    error("Chest type is empty!")
end
if dropperName == nil then
    error("Output not selected!")
end
if dropdir == nil then
    error("Dropper direction not selected!")
end
if input == nil then
    error("Input container not selected!")
end

--34 26
--==============================================--
local chests, chestNames = {}, {}
for k,v in pairs(peripheral.getNames()) do
    if peripheral.getType(v) == chestType then
        chests[#chests + 1] = peripheral.wrap(v)
        chestNames[#chestNames + 1] = v
    end
end
local input = peripheral.wrap(input)
local dropper = peripheral.wrap(dropperName)
local monitor = peripheral.find("monitor")
if monitor == nil then
    error("Monitor not found!")
end
monitor.setTextScale(0.5)
local width, height = monitor.getSize()
print(width,height)
if (width <= 33) or (height <= 23) then
    error("Monitor too small!")
end
local max = 0
for temp = 1, table.getn(chests) do
    local max = chests[temp].size() + max
end
term.redirect(monitor)
term.clear()
--===============================================--
local getBiggestKey = function(tbl)
    local output = 0
    for k, v in pairs(tbl) do
        output = math.max(output, k)
    end
    return output
end
local pos = 0
local maxScroll
local fulllist, fullchecklist = {}, {}
local itemData, itemCheckData = {}, {}
function display()
    while true do
        fulllist = {}
        itemData = {}
        --term.setCursorPos(7,height - 2)
        --term.setTextColor(colors.orange)
        --write("<"..pos..">  ")

        -- temp: vertical scroll offset when going through chests
        -- list: per-chest item list
        -- maxScroll: self-explanatory
        local temp, list = 0
        for i = 1, table.getn(chests) do
            list = chests[i].list()
            fulllist[temp + 1] = "PARTITION " .. ("-"):rep(width)
            fulllist[temp + 2] = "PARTITION " .. chestNames[i]
            fulllist[temp + 3] = "PARTITION " .. ("-"):rep(width)
            temp = temp + 3
            for k,v in pairs(list) do
                fulllist[temp + k] = v
                itemData[temp + k] = {
                    chestName = chestNames[i],
                    item = v,
                    slot = k,
                }
            end
            --error(getBiggestKey(list))
            --error(textutils.serialize(list))
            temp = temp + getBiggestKey(list)
            fulllist[temp + 1] = "PARTITION  "
            temp = temp + 1
            if i == table.getn(chests) then
                fulllist[temp + 1] = "PARTITION " .. ("-"):rep(width)
                temp = temp + 1
            end
        end
        fulllist[temp + 1] = "PARTITION End of the line, bucko"
        maxScroll = math.max(0, temp - height + (listBottom + 1))
        fullchecklist = fulllist
        itemCheckData = itemData
        
        term.setCursorPos(7, height - 2)
        term.setTextColor(colors.orange)
        term.write("<" .. pos .. "/" .. maxScroll .. ">")
        
        term.setCursorPos(1,2)
        -- temp:  line number on screen
        -- temp2: current chest number
        -- pos:   scroll position
        for temp = 1, height - listBottom do
            --for temp2 = 1, getBiggestKey(fulllist) do
                term.setCursorPos(1, temp)
                term.clearLine()
                if string.sub(tostring(fulllist[temp + pos] or ""), 1, 9) == "PARTITION" then
                    term.setTextColor(colors.gray)
                    term.write(fulllist[temp + pos]:sub(11))
                else
                    if temp + pos <= getBiggestKey(fulllist) then
                        term.setTextColor(colors.yellow)
                        term.write("> ")
                    end
                    --if temp + pos <= getBiggestKey(fulllist[temp2]) then
                        --if fulllist[temp2][temp + pos] ~= nil then
                        if fulllist[temp + pos] ~= nil then
                            term.setTextColor(colors.cyan)
                            --write(fulllist[temp2][temp + pos].name)
                            write(fulllist[temp + pos].count .. " x ")
                            term.setTextColor(colors.green)
                            write(fulllist[temp + pos].name)
                            local xp = term.getCursorPos()
                            term.write((" "):rep(width - xp))
                            --print("")
                        else
                            term.write((" "):rep(width))
                        end
                    --end
                    --print("")
                --end
            end
        end
    end
end
function control()
    while true do
        local _, _2, xm, ym = os.pullEvent("monitor_touch")
        if ym == height - 2 then
            if xm == 2 then
                --if pos ~= 0 then
                    pos = pos - 1
                --end
            elseif xm == 5 then
                --if pos ~= max - (height - listBottom) then
                    pos = pos + 1
                --end
            end
        elseif ym == height - 1 then
            if xm == 2 then
                --if pos >= 10 then
                    pos = pos - 10
                --end
            elseif xm == 5 then
                --if pos >= max - (height - 17) then
                    pos = pos + 10
                --end
            end
        elseif ym >= 1 and ym <= (height - listBottom) then
            if fullchecklist[ym + pos] then
                --error(fullchecklist[ym + pos].name)
                if tostring(fullchecklist[ym + pos] or ""):sub(1,9) ~= "PARTITION" then
                    --error(tostring(itemCheckData[ym + pos]))
                    dropper.pullItems(itemCheckData[ym + pos].chestName, itemCheckData[ym + pos].slot, 1)
                    dropper.drop(1)
                    --error(fullchecklist[ym + pos].name)
                end
            end
        end
        pos = math.min(pos, maxScroll)
        pos = math.max(pos, 0)
    end    
end
term.setCursorPos(2,height - 2)
term.setBackgroundColor(colors.green)
term.setTextColor(colors.white)
write("<")
term.setCursorPos(5,height - 2)
write(">")
term.setBackgroundColor(colors.blue)
term.setCursorPos(2,height - 1)
write("<")
term.setCursorPos(5,height - 1)
write(">")
term.setBackgroundColor(colors.black)
parallel.waitForAll(display,control)
