local function checkOption(argName, argInfo, isShort)
    for i = 1, #argInfo do
        if argInfo[i][isShort and 2 or 3] == argName then
            return i
        end
    end
    return false
end

function argParse(argInput, argInfo)
    local sDelim = "-"
    local lDelim = "--"

    optOutput = {}
    argOutput = {}
    argError = {}

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
                        else
                            argError[#argError + 1] = "expected parameter " .. tostring(ii) .. " for argument " .. lDelim .. lOpt
                            break
                        end
                    end
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
                            else
                                argError[#argError + 1] = "expected parameter " .. tostring(ii) .. " for argument " .. sDelim .. sOpt
                                break
                            end
                        end
                    else
                        argError[#argError + 1] = "options with parameters must be at the end of their group"
                        break
                    end
                else
                    argError[#argError + 1] = "invalid argument " .. sDelim .. sOpt
                    break
                end
                

            end

        else
            argOutput[#argOutput + 1] = lOpt
        end
    end

    return argOutput, optOutput, argError
end

local tArg = {...}

-- {amount of parameters for the option, short option, long option}
local argInfo = {
    [1] = {0, "h", "help"},
    [2] = {0, "w", "what"},
    [3] = {1, "n", "name"}
}

arguments, options, errors = argParse(tArg, argInfo)

print(textutils.serialise(arguments))
print(textutils.serialise(options))
if #errors > 0 then
    printError(textutils.serialise(errors))
end
