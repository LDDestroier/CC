-- ed text editor
-- Port to ComputerCraft by LDDestroier

local state = {
    output = 0,
    halt = false,
    debug = true,

    mode = "command", -- command or input

    buffer = {},

    show_help = false,
    show_version = false,
    extended_regexp = false,
    traditional = false,
    loose_exit_status = false,
    prompt = "*",
    show_prompt = false,
    restricted = false,
    silent = false,
    verbose = false,
    strip_trailing_cr = false
}

-- takes multi-line string for text
local function printMore(text, width, height)
    local linecount = 1
    local linesize = 0
    for i = 1, #text do
        if text:sub(i,i) == "\n" then
            linesize = 0
            linecount = linecount + 1
        else
            linesize = linesize + 1
        end
        if linesize >= width then
            linesize = 0
            linecount = linecount + 1
        end
    end
    local win = window.create(term.current(), 1, 1, width, linecount + 1, false)
    local cTerm = term.redirect(win)
    print(text)
    term.redirect(cTerm)
    for y = 1, linecount - 1 do
        print(win.getLine(y), "")
--        if y % 4 == 0 then sleep(0.05) end -- i like the scrolling effect
        if (y + 2) % height == 0  then
            os.pullEvent("char")
        end
    end
end

local function fn_version()
    local versiontext = [[
CC ed 0.1pr
Based on GNU ed 1.18
Copyright (C) 2023 Evan Theilig
MIT License: Permission is granted to freely distribute and modify this program.
There is NO WARRANTY, to the extent permitted by law.
]]
    printMore(versiontext, term.getSize())
end

local function fn_help()
    local helptext = [[
CC ed is a line-oriented text editor. It is used to create, display, modify and otherwise manipulate text files, both interactively and via shell scripts. A restricted version of ed, red, can only edit files in the current directory and cannot execute shell commands. Ed is the 'standard' text editor in the sense that it is the original editor for Unix, and thus widely available. For most purposes, however, it is superseded by full-screen editors such as GNU Emacs or GNU Moe.

Usage: ed [options] [file]

Options:
  -h, --help                 display this help and exit
  -V, --version              output version information and exit
  -E, --extended-regexp      use extended regular expressions
  -G, --traditional          run in compatibility mode
  -l, --loose-exit-status    exit with 0 status even if a command fails
  -p, --prompt=STRING        use STRING as an interactive prompt
  -r, --restricted           run in restricted mode
  -s, --quiet, --silent      suppress diagnostics, byte counts and '!' prompt
  -v, --verbose              be verbose; equivalent to the 'H' command
      --strip-trailing-cr    strip carriage returns at end of text lines

Start edit by reading in 'file' if given.
If 'file' begins with a '!', read output of shell command.

Exit status: 0 for a normal exit, 1 for environmental problems (file not found, invalid flags, I/O errors, etc), 2 to indicate a corrupt or invalid input file, 3 for an internal consistency error (e.g., bug) which caused ed to panic.

Report bugs to @lddestroier on Discord.
Ed home page: http://www.gnu.org/software/ed/ed.html
General help using GNU software: http://www.gnu.org/gethelp]]
    printMore(helptext, term.getSize())
end

local t_options_list = {
    help = {
        value = false,
        short = "h",
        long = "help",
        order = 2^16
    },
    version = {
        value = false,
        short = "V",
        long = "version",
        order = 2^16
    },
    extended_regexp = {
        value = nil,
        short = "E",
        long = "extended-regexp"
    },
    traditional = {
        value = nil,
        short = "G",
        long = "traditional"
    },
    loose_exit_status = {
        value = nil,
        short = "l",
        long = "loose-exit-status"
    },
    prompt = {
        value = nil,
        short = "p",
        long = "prompt",
        needs_param = true,
    },
    restricted = {
        value = nil,
        short = "r",
        long = "restricted"
    },
    quiet = {
        value = nil,
        short = "s",
        long = "quiet"
    },
    silent = {
        value = nil,
        short = "s",
        long = "silent"
    },
    verbose = {
        value = nil,
        short = "v",
        long = "verbose",
    },
    strip_trailing_cr = {
        value = nil,
        short = nil,
        long = "strip-trailing-cr"
    }
}

-- finds equal sign in table of arguments, then splits it into an extra index
local function fn_split_equal(tbl, index)
    local equal_pos = tbl[index]:find("=")
    if equal_pos then
        table.insert(tbl, index + 1, tbl[index]:sub(equal_pos + 1))
        tbl[index] = tbl[index]:sub(1, equal_pos - 1)
        return true
    end
    return false
end

local function fail(message, beg_help)
    print("ed: " .. message)
    if beg_help then
        print("Try 'ed --help' for more information.")
    end
    state.output = 1
    state.halt = true
end

local t_args = {...}
local n_args = {}

local arg
local found_equal, argument_done
local i = 0
while i < #t_args do
    i = i + 1
    arg = t_args[i]
    found_equal = false
    argument_done = false
    found_option = false

    if arg:sub(1,2) == "--" then
        -- long option
        found_option = false
        found_equal = fn_split_equal(t_args, i)
        for name, info in pairs(t_options_list) do
            if t_args[i]:sub(3) == info.long then
                found_option = true
                if info.needs_param then
                    if t_args[i + 1] then
                        t_options_list[name].value = t_args[i + 1]
                        t_options_list[name].order = i
                        i = i + 1
                    else
                        fail("option '" .. t_args[i] .. "' requires an argument", true)
                        break
                    end
                else
                    if found_equal then
                        fail("option '" .. t_args[i] .. "' doesn't allow an argument", true)
                        break
                    else
                        t_options_list[name].value = true
                        t_options_list[name].order = i
                    end
                end
            end
        end
        if not found_option then
            fail("unrecognized option '" .. t_args[i] .. "'", true)
        end
        
    elseif arg:sub(1,1) == "-" then
        -- short option
        -- ed's short option handling is a little silly :)
        found_option = false
        argument_done = false
        for p = 2, #arg do
            if (not argument_done) and (not state.halt) then
                for name, info in pairs(t_options_list) do
                    if arg:sub(p,p) == info.short then
                        found_option = true
                        if info.needs_param then
                            if arg:sub(p + 1) == "" then
                                if t_args[i + 1] then
                                    t_options_list[name].value = t_args[i + 1]
                                    t_options_list[name].order = i
                                    i = i + 1
                                else
                                    fail("option requires an argument -- '" .. info.short .. "'", true)
                                end
                                break
                            end
                            t_options_list[name].value = arg:sub(p + 1)
                            t_options_list[name].order = i
                            argument_done = true
                        else
                            t_options_list[name].value = true
                            t_options_list[name].order = i
                        end
                        break
                    end
                end
                if not found_option then
                    fail("invalid option -- '" .. arg:sub(p,p) .. "'", true)
                    break
                end
            else
                break
            end
        end

    else
        table.insert(n_args, t_args[i])
    end
end

state.extended_regexp   = t_options_list.extended_regexp.value or state.extended_regexp
state.traditional       = t_options_list.traditional.value or state.traditional
state.loose_exit_status = t_options_list.loose_exit_status.value or state.loose_exit_status
state.prompt            = t_options_list.prompt.value or state.prompt
state.show_prompt       = t_options_list.prompt.value and true or false
state.restricted        = t_options_list.restricted.value or state.restricted
state.silent            = (t_options_list.silent.value or t_options_list.quiet.value) or state.silent
state.verbose           = t_options_list.verbose.value or state.verbose
state.strip_trailing_cr = t_options_list.strip_trailing_cr.value or state.strip_trailing_cr
state.show_help         = t_options_list.help.value and (t_options_list.help.order < t_options_list.version.order)
state.show_version      = t_options_list.version.value and (t_options_list.version.order < t_options_list.help.order)

if state.halt then
    return state.output
end

if state.show_help then
    fn_help()
    return state.output
end

if state.show_version then
    fn_version()
    return state.output
end

if state.debug then
    print("Prompt is '" .. state.prompt .. "'")
    print("Extended Regexp is " .. (state.extended_regexp and "on" or "off"))
    print("You are " .. ((not state.verbose) and "not " or "") .. "verbose")
    print("Traditional is " .. (state.traditional and "on" or "off"))
    print("Loose exit is " .. (state.loose_exit_status and "on" or "off"))
    print("Restricted mode is " .. (state.restricted and "on" or "off"))
    print("Silent/quiet mode is " .. (state.silent and "on" or "off"))
    print("Verbose mode is " .. (state.verbose and "on" or "off"))
    print("Strip trailing cr is " .. (state.strip_trailing_cr and "on" or "off"))
    print("Arguments: " .. textutils.serialize(n_args))
end

-- do things

local function fn_input()
    local finished = false
    local interrupt = false
    local text = ""
    local cursor = 1
    local ox, oy = term.getCursorPos()
    local scr_x, scr_y = term.getSize()

    local evt
    local keysDown = {}

    term.setCursorPos(1, oy)
    term.write(state.prompt)
    term.setCursorBlink(true)

    while not finished do
        if state.show_prompt then
            term.setCursorPos(#state.prompt + 1, oy)
            term.write(text .. (" "):rep(scr_x - #text))
            term.setCursorPos(#state.prompt + cursor, oy)

        else
            term.setCursorPos(1, oy)
            term.write(text .. (" "):rep(scr_x - #text))
            term.setCursorPos(cursor, oy)
        
        end

        evt = {os.pullEventRaw()}

        if evt[1] == "terminate" then
            finished = true
            interrupt = true

        elseif evt[1] == "key" then
            keysDown[evt[2]] = true
            if evt[2] == keys.left then
                cursor = math.max(1, cursor - 1)
            end
            if evt[2] == keys.right then
                cursor = math.min(cursor + 1, #text + 1)
            end
            if evt[2] == keys.backspace then
                cursor = math.max(1, cursor - 1)
                text = text:sub(1, cursor - 1) .. text:sub(cursor + 1)
            end
            if evt[2] == keys.delete then
                text = text:sub(1, cursor - 1) .. text:sub(cursor + 1)
            end
            if evt[2] == keys.home then
                cursor = 1
            end
            if evt[2] == keys["end"] then
                cursor = #text + 1
            end
            if evt[2] == keys.enter then
                finished = true
            end

            if evt[2] == keys.d and (keysDown[keys.leftCtrl] or keysDown[keys.rightCtrl]) then
                finished = true
                interrupt = true
            end

        elseif evt[1] == "key_up" then
            keysDown[evt[2]] = false

        elseif evt[1] == "char" then
            text = text:sub(1, cursor - 1) .. evt[2] .. text:sub(cursor)
            cursor = cursor + 1

        end
    end

    if oy + 1 > scr_y then
        term.scroll(1)
        term.setCursorPos(1, oy)
    else
        term.setCursorPos(1, oy + 1)
    end

    return text, interrupt
end

local function fn_shell_resolve(command)
    -- TODO: make dynamically resizing window object
    -- set every pixel of window to black-on-black, then always make window draw white-on-white text to mark written regions
    -- then, return a table of lines from the window that are just as long as needed to represent the "marked" portions
    return {}
end

local function fn_command_parse(text)
    local valid = false

    if text == "P" then
        valid = true
        state.show_prompt = not state.show_prompt
    end
    if text == "q" then
        valid = true
        return false
    end
    if text == "i" then
        valid = true
        state.mode = "input"
    end

    -- TODO: inplement every command

    if not valid then
        print("?")
    end

    return true
end

local function fn_input_parse(text, interrupt)
    if interrupt then
        state.mode == "command"
        return true
    else
        print("WIP")
        return false
    end
end

local function main()
    state.mode = "command"
    local running = true
    local text, interrupt
    while running do
        text, interrupt = fn_input()
        if interrupt then
            running = false
        end

        if state.mode == "command" then
            running = running and fn_command_parse(text)
        
        elseif state.mode == "input" then
            running = fn_input_parse(text, interrupt)
        
        else
            running = false
            state.output = 1

        end
    end
end

main()

return state.output