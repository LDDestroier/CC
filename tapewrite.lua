local tArg = {...}

local fileName = tArg[1]
local tapeName = tArg[2]

local function getHelp()
    print("tapewrite [file / url] [name]")
end

if not fileName then
    getHelp()
    return
end

local tape = peripheral.find("tape_drive")
if not tape then
    print("Tape drive not connected.")
    return
end

local totalSize = tape.getSize()

-- Make file, and detect URL
local file, contents
if fileName:sub(1,8) == "https://" then
    write("Downloading...")
    file = http.get(fileName, nil, true)
    print("Done.")
else
    file = fs.open(fs.combine(shell.dir(), fileName), "r")
end
contents = file.readAll()
file.close()

if tapeName then
    tape.setLabel(tapeName)
end

tape.seek(-tape.getPosition())

print("Writing...")

if #contents > totalSize then
    contents = contents:sub(1, totalSize)
    print("Tape too small. Audio was written incompletely.")
end
tape.write(contents)

tape.seek(-tape.getPosition())

print("\nIt is written. (" .. tostring(#contents) .. " bytes)")
