--[[
pastebin get jgyepx3g tron 
std pb jgyepx3g tron 
--]]

local isOpen=false
for k,v in pairs({"right","left","top","bottom","front","back"}) do
	if peripheral.getType(v)=="modem" then
		rednet.open(v)
		isOpen=true
	end
end
if not isOpen then
	error("no modem attached")
end
if not term.isColor() then
	if _CC_VERSION then
		colors.orange = colors.lightGray
		colors.blue = colors.lightGray
		colors.red = colors.white
		colors.lightBlue = colors.white
	else
		colors.gray = colors.black
		colors.orange = colors.white
		colors.blue = colors.white
		colors.red = colors.white
		colors.lightBlue = colors.white
	end
end

local Mx,My=term.getSize()
local Cx,Cy=math.floor(Mx/2),math.floor(My/2)
function maingame()
	local lang={"Waiting for player",{[0]="^",">","v","<"},{{"|","/","|","\\"},{"/","-","\\","-"},{"|","\\","|","/"},{"\\","-","/","-"}},"You died.","You won."}
	local board=setmetatable({},{__index=function(s,n) s[n]={} return s[n] end})
	for l1=99,-99,-1 do
		board[l1][-99]={"-",3}
	end
	for l1=99,-99,-1 do
		board[l1][99]={"|",3}
	end
	for l1=99,-99,-1 do
		board[-99][l1]={"-",3}
	end
	for l1=99,-99,-1 do
		board[99][l1]={"|",3}
	end
	board[100][100]={"/",3}
	board[100][-100]={"\\",3}
	board[-100][100]={"/",3}
	board[-100][-100]={"\\",3}
	local modem
	local initheader="TRON:"
	local pnid
	local function send(...)
		rednet.send(pnid,string.sub(textutils.serialize({...}),2,-2))
	end
	local function decode(dat)
		return textutils.unserialize("{"..dat.."}")
	end
	local col
	term.setCursorPos(math.floor(Cx-(#lang[1])/2),Cy)
	term.setTextColor(colors.orange)
	term.setBackgroundColor(colors.black)
	term.clear()
	term.write(lang[1])
	rednet.broadcast(initheader.."pingcon")
	local p1,p2
	while true do
		local p={os.pullEvent()}
		if p[1]=="rednet_message" and p[2]~=os.getComputerID() then
			if p[3]==initheader.."pingcon" then
				rednet.send(p[2],initheader.."pongcon")
				pnid=p[2]
				col={colors.blue,colors.red,colors.lightBlue}
				p1={pos={x=2,y=1},dir=0}
				p2={pos={x=1,y=1},dir=0}
				break
			elseif p[3]==initheader.."pongcon" then
				pnid=p[2]
				col={colors.red,colors.blue,colors.lightBlue}
				p1={pos={x=1,y=1},dir=0}
				p2={pos={x=2,y=1},dir=0}
				break
			end
		end
	end
	term.setBackgroundColor(colors.black)
	term.clear()
	local frs=0
	local fps=0 -- frame counter (debugging)
	local function render()
		local tsv = term.current().setVisible
		if tsv then tsv(false) end
		frs=frs+1
		term.setTextColor(colors.gray)
		for l1=1,My do
			term.setCursorPos(1,l1)
			local pre=p1.pos.x%3
			if (l1+p1.pos.y)%3==0 then
				if pre==1 then
					pre="--"
				elseif pre==2 then
					pre="-"
				else
					pre=""
				end
				term.write(pre..("+--"):rep(math.ceil(Mx/2)))
			else
				if pre==1 then
					pre="  "
				elseif pre==2 then
					pre=" "
				else
					pre=""
				end
				term.write(pre..("|  "):rep(math.ceil(Mx/2)))
			end
		end
		term.setTextColor(colors.blue)
		local num=0
		for k,v in pairs(board) do
			for l,y in pairs(v) do
				if (k-p1.pos.x)+Cx<=Mx and (k-p1.pos.x)+Cx>=1 and (l-p1.pos.y)+Cy<=My and (l-p1.pos.y)+Cy>=1 then
					term.setTextColor(col[y[2]] or y[2])
					term.setCursorPos((k-p1.pos.x)+Cx,(l-p1.pos.y)+Cy)
					term.write(y[1])
					num=num+1
				end
			end		
		end
		term.setCursorPos(1,1)
		if col[1]==colors.blue then
			term.setTextColor(colors.blue)
			term.write("BLUE")
		else
			term.setTextColor(colors.red)
			term.write("RED")
		end
		if tsv then tsv(true) end
	end
	local odr={[p1]=p1.dir,[p2]=p2.dir}
	local function processmove(u)
		local ccol
		if u==p1 then
			ccol=col[1]
		else
			ccol=col[2]
		end
		term.setTextColor(ccol)
		if u==p1 and board[u.pos.x][u.pos.y] then
			send("DIE")
			term.setCursorPos(Cx,Cy)
			term.write("x")
			sleep(2)
			term.setCursorPos(Cx-math.floor(#lang[4]/2),Cy)
			term.setTextColor(colors.orange)
			term.clear()
			term.write(lang[4])
			sleep(5)
			term.setTextColor(colors.white)
			term.setBackgroundColor(colors.black)
			term.setCursorPos(1,1)
			term.clear()
			error("",0)
		end
		if odr[u]~=u.dir then
			board[u.pos.x][u.pos.y]={lang[3][odr[u]+1][u.dir+1],ccol}
		end
		if not board[u.pos.x][u.pos.y] then
			if u.dir%2==0 then
				board[u.pos.x][u.pos.y]={"|",ccol}
			else
				board[u.pos.x][u.pos.y]={"-",ccol}
			end
		end
		local chr=board[u.pos.x][u.pos.y][1]
		local shr={x=u.pos.x,y=u.pos.y}
		if u.dir==0 then
			u.pos.y=u.pos.y-1
		elseif u.dir==1 then
			u.pos.x=u.pos.x+1
		elseif u.dir==2 then
			u.pos.y=u.pos.y+1
		else
			u.pos.x=u.pos.x-1
		end
		odr[u]=u.dir
		return chr,shr
	end
	local function renderchar(u)
		local ccol
		if u==p1 then
			ccol=col[1]
			term.setCursorPos(Cx,Cy)
		else
			ccol=col[2]
			term.setCursorPos((p2.pos.x-p1.pos.x)+Cx,(p2.pos.y-p1.pos.y)+Cy)
		end
		term.setTextColor(ccol)
		term.write(lang[2][u.dir])
	end
	function processturn(p,u)
		local dirs={[keys.up]=0,[keys.right]=1,[keys.down]=2,[keys.left]=3}
		if (odr[u]+2)%4~=dirs[p] then
			u.dir=dirs[p]
			renderchar(u)
			if u==p1 then
				send("ROT",u.dir)
			end
		end
	end
	render()
	local move=os.startTimer(0.1)
	local fct=os.startTimer(1)
	while true do
		local p={os.pullEvent()}
		if p[1]=="key" then
			if p[2]==keys.up or p[2]==keys.right or p[2]==keys.down or p[2]==keys.left then
				processturn(p[2],p1)
			end
		elseif p[1]=="timer" then
			if p[2]==move then
				local ret,ret2=processmove(p1)
				move=os.startTimer(0.1)
				send("MOVE",ret2,ret)
			elseif p[2]==fct then
				fps=frs
				frs=0
				fct=os.startTimer(1)
			end
		elseif p[1]=="rednet_message" and p[2]==pnid then
			local dat=decode(p[3])
			if dat[1]=="ROT" then
				p2.dir=dat[2]
				renderchar(p2)
			elseif dat[1]=="DIE" then
				p1.pos=p2.pos
				render()
				term.setTextColor(col[2])
				term.setCursorPos(Cx,Cy)
				term.write("x")
				sleep(2)
				term.setCursorPos(Cx-math.floor(#lang[5]/2),Cy)
				term.setTextColor(colors.orange)
				term.clear()
				term.write(lang[5])
				sleep(5)
				term.setTextColor(colors.white)
				term.setBackgroundColor(colors.black)
				term.setCursorPos(1,1)
				term.clear()
				return
			elseif dat[1]=="MOVE" then
				p2.pos=dat[2]
				board[p2.pos.x][p2.pos.y]={dat[3],col[2]}
				render()
				renderchar(p1)
				renderchar(p2)
			end
		end
	end
end
local selected=1
local function rmain()
	term.setBackgroundColor(colors.black)
	term.clear()
	term.setCursorPos(1,1)
	term.setTextColor(colors.blue)
	local txt="  _  _______________     ________    __       _\n/ \\/  _____________\\   /  ____  \\  |  \\     / |\n\\_/| /    / \\       | /  /    \\  \\ |   \\ __/  |\n   | |    | |\\  ___/ |  |      |  ||    \\     |\n   | |    | | \\ \\    |  |      |  ||   __\\    |\n   | |    | |  \\ \\    \\  \\____/  / |  /   \\   |\n   \\_/    \\_/   \\_/    \\________/  |_/     \\__|"
	local cnt=1
	local cnt2=Cx-23
	for char in string.gmatch(txt,".") do
		if char~=" " and char~="\n" then
			term.setCursorPos(cnt2,cnt)
			term.write(char)
		elseif char=="\n" then
			cnt=cnt+1
			cnt2=Cx-23
		end
		cnt2=cnt2+1
	end
	local selections={"Multiplayer","Exit"}
	selected=((selected-1)%(#selections))+1
	for k,v in pairs(selections) do
		if k==selected then
			term.setTextColor(colors.blue)
			term.setCursorPos(Cx-(math.floor(#v/2)+1),k+10)
			term.write(">"..v.."<")
			term.setTextColor(colors.lightBlue)
			term.setCursorPos(Cx-math.floor(#v/2),k+10)
			term.write(v)
		else
			term.setTextColor(colors.lightBlue)
			term.setCursorPos(Cx-math.floor(#v/2),k+10)
			term.write(v)
		end
	end
end
rmain()
while true do
	p={os.pullEvent()}
	if p[1]=="key" then
		if p[2]==keys.up then
			selected=selected-1
			rmain()
		elseif p[2]==keys.down then
			selected=selected+1
			rmain()
		elseif p[2]==keys.enter then
			if selected==1 then
				a,b=pcall(maingame)
				if not a and b~="" then
					error(b,0)
				end
				rmain()
			else
			break
			end
		end
	end
end
term.setCursorPos(1,1)
term.clear()
