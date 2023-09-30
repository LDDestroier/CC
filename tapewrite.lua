local tArg = {...}

-- this doesn't work very well, keep it false
local doByteByByte = false

local fileName = tArg[1]
local tapeName = tArg[2]
local tape = peripheral.find("tape_drive")
local file
if fileName:sub(1,8) == "https://" then
    file = http.get(fileName)
else
    file = fs.open(fs.combine(shell.dir(),fileName), "r")
end

local byte = 0
tape.seek(-tape.getPosition())

if tapeName then
    tape.setLabel(tapeName)
end
local counter = 0

local totalSize = tape.getSize()

if doByteByByte then

    while true do
        byte = file.read()
        if not byte then break end
        counter = counter + 1
        tape.write(byte:byte())
        if counter == 4096 then
            counter = 0
            os.queueEvent("yield")
            os.pullEvent("yield")
            write(".")
        end
    end

else

    print("Writing...")
    local contents = file.readAll()
    if #contents > totalSize then
        contents = contents:sub(1, totalSize)
        print("Tape too small. Audio was written incompletely.")
    end
    tape.write(contents)

end

tape.seek(-tape.getPosition())
file.close()

print("\nIt is written.")
