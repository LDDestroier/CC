--[[
Lua Argument Parser
written by LDDestroier

Features:
    + Full/abbreviated options in addition to regular arguments
    + Abbreviated option grouping
    + Option parameters (of which there can be more than one per option)
--]]

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

local function demoArgParse(...)

    --[[
    argInfo is structured as such:
    {
        amount of parameters for the option (usually 0 or 1),
        short option,
        long option
    }
    --]]

    local argInfo = {
        [1] = {0, "h", "help"},
        [2] = {0, "w", "what"},
        [3] = {1, "n", "name"}
    }

    --[[
    with this, you can do the following:
        "argparse.lua --help --what --name LDD"
        "argparse.lua -hwn LDD"
        "argparse.lua --help -wn LDD"

    return 1 is a table of arguments (not options)
    return 2 is a table of options (not regular arguments)
    return 3 is a table of errors (invalid inputs)
    --]]

    arguments, options, errors = argParse({...}, argInfo)

    if #errors > 0 then
        for i = 1, #errors do
            printError(errors[i])
        end
    else
        for i = 1, #arguments do
            write(arguments[i])
            if i == #arguments then
                write("\n")
            else
                write(", ")
            end
        end
        for i,v in pairs(options) do
            write("--" .. argInfo[i][3] .. " ")
            if argInfo[i][1] > 0 then
                for ii = 1, #options[i] do
                    write(options[i][ii])
                    if ii == #options[i] then
                        write("\n")
                    else
                        write(", ")
                    end
                end
            end
            
        end
    end
end

return argParse
