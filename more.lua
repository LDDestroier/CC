local allowedScrolls = 0

local tArg = {...}

if tArg[1] then
	local oldScroll = term.scroll
	term.scroll = function(lines)
		local scr_x, scr_y
		local evt, key
		if lines < 0 then
		 	oldScroll(lines)
		else
			for i = 1, lines do
				if allowedScrolls == 0 then
					evt, key = os.pullEvent("key")
					scr_x, scr_y = term.getSize()
					if key == keys.enter then
						allowedScrolls = scr_y - 1
					end
				else
					allowedScrolls = allowedScrolls - 1
				end
				oldScroll(1)
			end
		end
	end
	shell.run(tArg[1])
	term.scroll = oldScroll
else
	print("more [filename]")
end
