-- goto
goto = function(tag) local f,c,l,o=fs.open(shell.getRunningProgram(), "r"),"","",false while l do if o then c=c..l l=f.readLine() if l then c=c.."\n" else break end else l=f.readLine() if l then o=l:find("--::"..tag.."::")==1 end end end f.close() load(c,nil,nil,_ENV)() end

-- example
goto("test")

print("Before")

--::test::

print("After")

--[[
	After
	Before
	After
--]]
