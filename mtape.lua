-- Mtape
-- tape managing program
-- made by LDDestroier

local _DEBUG = true

local function checkOption(argName, argInfo, isShort)
    for i = 1, #argInfo do
        if argInfo[i][isShort and 2 or 3] == argName then
            return i
        end
    end
    return false
end

local function argParse(argInput, argInfo)
    local sDelim = "-"
    local lDelim = "--"

    local optOutput = {}
    local argOutput = {}
    local argError = {}

    local usedTokens = {}

    local lOpt, sOpt, optNum

    for i = 1, #argInfo do
        optOutput[i] = {}
    end

    for i = 1, #argInput do
        lOpt = argInput[i]
        -- check type of delimiter
        if lOpt:sub(1, #lDelim) == lDelim then
            -- handle long delimiter
            lOpt = lOpt:sub(#lDelim + 1)
            optNum = checkOption(lOpt, argInfo, false)
            if optNum then
                if argInfo[optNum][1] == 0 then
                    optOutput[optNum] = true
                
                else
                    optOutput[optNum] = {}
                    for ii = 1, argInfo[optNum][1] do
                        if argInput[i + ii] then
                            optOutput[optNum][#optOutput[optNum] + 1] = argInput[i + ii]
                            usedTokens[i + ii] = true
                        else
                            argError[#argError + 1] = "expected parameter " .. tostring(ii) .. " for argument " .. lDelim .. lOpt
                            break
                        end
                    end
                    i = i + argInfo[optNum][1]
                end

            else
                argError[#argError + 1] = "invalid argument " .. lDelim .. lOpt
            end


        elseif lOpt:sub(1, #sDelim) == sDelim then
            -- handle short delimiter
            lOpt = lOpt:sub(#sDelim + 1)
            for si = 1, #lOpt do
                sOpt = lOpt:sub(si, si)
                optNum = checkOption(sOpt, argInfo, true)
                if optNum then
                    if argInfo[optNum][1] == 0 then
                        optOutput[optNum] = true
                    
                    elseif si == #lOpt then
                        optOutput[optNum] = {}
                        for ii = 1, argInfo[optNum][1] do
                            if argInput[i + ii] then
                                optOutput[optNum][#optOutput[optNum] + 1] = argInput[i + ii]
                                usedTokens[i + ii] = true
                            else
                                argError[#argError + 1] = "expected parameter " .. tostring(ii) .. " for argument " .. sDelim .. sOpt
                                break
                            end
                        end
                        i = i + argInfo[optNum][1]
                    else
                        argError[#argError + 1] = "options with parameters must be at the end of their group"
                        break
                    end
                else
                    argError[#argError + 1] = "invalid argument " .. sDelim .. sOpt
                    break
                end
                
            end

        elseif not usedTokens[i] then
            argOutput[#argOutput + 1] = lOpt
        end
    end

    return argOutput, optOutput, argError
end


local function getHelp(specify)
    if not specify then
        print("mtape [file / url] (label)")
        print("mtape [-i --info]")
        print("mtape [-e --erase]")
        print("mtape [-u --unclean]")
        print("mtape [-c --cc-media]")
        print("mtape [-u]")
        print("Use -h with other options for details")
    else
        if specify == "--info" then
            print("Prints information about the connected tape drive.")
            print("This includes the label, size, minutes length, and current seeking position.")
        elseif specify == "--erase" then
            print("Erases the connected tape drive.")
        elseif specify == "--unclean" then
            print("Normally, tapes are erased before writing them anew. Use this option to not erase them first.")
            print("If the tape has something longer written to it beforehand, you'll hear it after whatever is written now.")
        elseif specify == "--ldd-github" then
            print("Adds URL info from LDDestroier's personal CC-Media github to make it easier to pull from there.")
            print("Ex. 'tapey -c krabii'")
            print("    'tapey -c simple'")
        elseif specify == "--reinstall" then
            print("Updates Mtape to the latest version on the LDDestroier/CC github.")
        end
    end
end

local tierInfo = {
    -- damage value indicates type of tape
    -- value of tierInfo indicates minutes of storage
    [0] = 4,
    [1] = 8,
    [2] = 16,
    [3] = 32,
    [4] = 64,
    [5] = 2,
    [6] = 6,
    [8] = 128
}

local function getFileContents(path, isURL)
    local file, contents
    if isURL then
        file = http.get(path, nil, true)
    else
        file = fs.open(fs.combine(shell.dir(), path), "rb")
    end
    if not file then
        return false, ""
    else
        contents = file.readAll()
        file.close()
        return true, contents
    end
end

local function getTapeDrive(side)
    local tape
    if side then
        tape = peripheral.wrap(side)
        if not tape then
            return false, "No such tape drive found.", 0
        elseif peripheral.getType(tape) ~= "tape_drive" then
            return false, "Not a tape drive.", 0
        else
            return true, tape, tape.getSize()
        end
    else
        tape = peripheral.find("tape_drive")
        if not tape then
            return false, "Tape drive not connected.", 0
        else
            return true, tape, tape.getSize()
        end
    end
end

local function writeToTape(tape, contents, tapeName)
    local output = ""
    if not tape then error("expected tape peripheral") end
    if not contents then error("expected contents") end

    local totalTapeSize = tape.getSize()

    if tapeName then
        tape.setLabel(tapeName)
    end

    tape.stop()
    tape.seek(-tape.getPosition())
    if #contents > totalTapeSize then
        output = "Tape too small, audio truncated."
        for i = 0, 8 do
            if tierInfo[i] then
                if tierInfo[i] * 360000 >= #contents then
                    output = output .. "\nIt would fit on a" .. (tierInfo[i] == 8 and "n " or " ") .. tostring(tierInfo[i]) .. " minute tape."
                    break
                end
            end
        end
        contents = contents:sub(1, totalTapeSize)
    end
    tape.write(contents)
    tape.seek(-tape.getPosition())
    tape.stop()

    return output
end

local function infoMode(tape)
    local scr_x, scr_y = term.getSize()
    print("Info for tape drive:")
    print(("-"):rep(scr_x))

    local gi = tape.getItem(1).getMetadata()

    local info = {
        inserted = gi ~= nil
    }

    local minute = 360000

    if not info.inserted then
        print("No tape inserted.")
    else
        info.displayname = gi.displayName
        info.label = gi.media.label
        info.itemname = gi.name
        info.damage = gi.damage
        info.minutes = tierInfo[info.damage]
        info.maxsize = tape.getSize()
        info.position = tape.getPosition()

        print(info.displayname .. " inserted.")
        print("Label: \"" .. info.label .. "\"")
        write("Stores " .. tostring(info.minutes) .. " minutes")
        print(" (" .. tostring(info.maxsize) .. " bytes)")
        print("Seeked to " .. tostring(info.position) .. "/" .. tostring(info.maxsize))
    end
    return info
end

local argInfo = {
    [1] = {0, "h", "help"},
    [2] = {0, "i", "info"},
    [3] = {1, "d", "drive"},
    [4] = {0, "e", "erase"},
    [5] = {0, "u", "unclean"},
    [6] = {1, "c", "cc-media"},
    [7] = {0, "r", "reinstall"}
}

local arguments, options, errors = argParse({...}, argInfo)

local tape, totalTapeSize, success, contents

if #errors > 0 then
    for i = 1, #errors do
        printError(errors[i])
    end
    return
end

local fileName = arguments[1]
local tapeName = arguments[2]
local tapeDriveName = options[3][1]
local wantedHelp = options[1] == true
local wantedInfo = options[2] == true
local wantedErase = options[4] == true
local doUnclean = options[5] == true
local getFromGithub = options[6][1]
local wantedUpdate = options[7] == true

if wantedHelp then
    if wantedInfo then
        getHelp("--info")
    elseif wantedErase then
        getHelp("--erase")
    elseif doUnclean then
        getHelp("--unclean")
    elseif getFromGithub then
        getHelp("--ldd-github")
    elseif wantedUpdate then
        getHelp("--reinstall")
    else
        getHelp()
    end
    return
end

if wantedUpdate then
    print("Redownloading Mtape...")
    local cpath = shell.getRunningProgram()
    local file = http.get("https://github.com/LDDestroier/CC/raw/master/mtape.lua")
    local contents

    local sizeBefore = fs.getSize(cpath)
    local sizeAfter = 0
    
    if file then
        contents = file.readAll()
        sizeAfter = #contents
        file.close()
        file = fs.open(cpath, "w")
        file.write(contents)
        file.close()
        print("Done! (diff: " .. tostring(sizeAfter - sizeBefore) .. " bytes)")
        return
    else
        print("Couldn't update.")
        return
    end
end

-- Try to wrap specified tape drive OR find tape drive
success, tape, totalTapeSize = getTapeDrive(tapeDriveName)
if not success then
    print(tape)
    return
end

if wantedInfo then
    infoMode(tape)
    return true
end

if wantedErase then
    success = writeToTape(tape, string.char(0):rep(tape.getSize()), tapeName)
    print("Tape erased.")
    return
end

if getFromGithub then
    print("Pulling from CC-Media.")
    fileName = "https://github.com/LDDestroier/CC-Media/raw/master/DFPWM/" .. getFromGithub .. ".dfpwm"
end

if not fileName then
    getHelp()
    return
end

-- Make file, and detect URL
if fileName:sub(1,8) == "https://" then
    write("Downloading...")
    success, contents = getFileContents(fileName, true)
    print("Done.")
else
    success, contents = getFileContents(fileName, false)
end

if not success then
    error("Could not get file. Abort.")
else
    if _DEBUG then
        print("File size: " .. tostring(#contents) .. " bytes")
        print("Tape size: " .. tostring(tape.getSize()) .. " bytes")
    end
end

-- Adds null data to the end of the file if you want a clean tape write
if doUnclean then
    print("Won't clean up tape first.")
else
    contents = contents .. string.char(0):rep(math.max(0, totalTapeSize - #contents))
end

write("Writing...")
success = writeToTape(tape, contents, tapeName)
if success then
    print("\n" .. success)
    print("Nonetheless, it is written.")
else
    print("done!")
end

return true
