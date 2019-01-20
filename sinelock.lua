--[[
   Sinelock v1.3
  The *COOLEST* computer/door lock ever!
 Now with slightly less seizure!

 pastebin get XDgeSDTq sinelock
 std pb XDgeSDTq sinelock
 std ld sinelock sinelock

 Now with salting!
--]]
local scr_x, scr_y = term.getSize()	--Gets screen size. Don't modify this

--Config variables start!
local terminateMode = 2				--0 enables termination, 1 blocks it, 2 provides a taunting screen.
local passFile = ".sl_password"		--The ABSOLUTE path of the password file.
local saltFile = ".sl_salt"			--The ABSOLUTE path of the salt file.
local characterLimit = 1024			--The cap of characters at the read() prompt. Set this to prevent crashes.
local runProgram = ""				--Set to something to run it when correct, and not using doors.
local dahChar = "*"					--The character used to hide characters when typed.
local doKeyCards = true				--Whether or not the lock also accepts keycards (floppy disks) as well as passwords.
local doEjectDisk = false			--Whether or not to eject a keycard after it's accepted, just to speed things up a bit.
local doorSides = {}				--If it has anything, the lock will open the doors instead of unlocking the PC.
local doInvertSignal = false		--If true, it will invert the redstone signal of the door, in case you need to.
local doShowDoorSides = true		--If true, will show the door sides being opened. Set to false if you are paranoid.
local beWavey = true				--Whether or not to animate the sine wave.
local readYpos = scr_y-2			--The Y position of the read() prompt
local requireAllPasswords = false	--Whether or not the lock asks for ONE of the multiple passwords, or ALL of them in order.
local badlength = 4					--The length in seconds that you have to wait to try again.
local goodlength = 6				--The length in seconds that doors will stay open.
local sineFrameDelay = 0.15			--The amount of time between sine animation frames. Tradeoff of purty vs performance.
local palate = {
	frontsine = colors.lightGray,
	backsine = colors.gray,
	background = colors.black,
	rainColor = colors.gray,
	rainChar = "|",
	promptBG = colors.gray,
	promptTXT = colors.white,
	wrongBG = colors.black,
	wrongTXT = colors.gray,
}
local language = "english"
local lang = {
	english = {
		wrong1 = "YOU ARE WRONG.",
		wrong2 = "YOU ARE WRONG. AS ALWAYS.",
		right1 = "Correct!",
		right2 = "Correct, finally!",
	},
	spanish = {
		wrong1 = "ESTA USTED EQUIVOCADO.",
		wrong2 = "ESTA USTED EQUIVOCADO. TODAVIA OTRA VEZ.",
		right1 = "Correcto!",
		right2 = "Asi es, por fin!",
		noTerminate = "No termine!",
	},
	german = {
		wrong1 = "SIE LIEGEN FALSCH.",
		wrong2 = "SIE LIEGEN FALSCH. WIE IMMER.",
		right1 = "Richtig!",
		right2 = "Richtig, endlich!",
		noTerminate = "Nicht zu beenden!",
	},
	dutch = {
		wrong1 = "U BENT ONJUIST.",
		wrong2 = "JE BENT ONJUIST, ALS ALTIJD.",
		right1 = "Dat is juist!",
		right2 = "Dat is juist, eindelijk!",
		noTerminate = "Niet te beeindigen!",
	},
	latin = { --As a joke
		wrong1 = "ERRAS",
		wrong2 = "TU DEFICIENTES!",
		right1 = "Quod suus 'verum!",
		right2 = "Quod suus 'verum, demum!",
		noTerminate = "Vade futuo te ipsum!",
	},
	italian = {
		wrong1 = "HAI SBAGLIATO.",
		wrong2 = "HAI SBAGLIATO, COME SEMPRE D'ALTRONDE.",
		right1 = "CORRETTO!",
		right2 = "CORRETTO, FINALMENTE!",
		noTerminate = "Non cercare di terminarmi",
	},
}

-- Config variables end. Don't touch anything else, m'kay?
if not _VERSION then
	return printError("Sorry, only CC 1.7 and later supported.")
end
local csv, salt, doSine
local floor, ceil, random, abs = math.floor, math.ceil, math.random, math.abs
local sin, cos = math.sin, math.cos
local rhite = term.write
local setTextColor, setBackgroundColor, getTextColor, getBackgroundColor = term.setTextColor, term.setBackgroundColor, term.getTextColor, term.getBackgroundColor
local setCursorPos, setCursorBlink, getCursorPos, getSize = term.setCursorPos, term.setCursorBlink, term.getCursorPos, term.getSize
local sineLevel = 1
local isTerminable = false
local kaykaycoolcool = true
if term.current().setVisible then
	csv = true
else
	csv = false
end

local writeError = function(...)
	local tx,bg = getTextColor(),getBackgroundColor()
	if term.isColor() then
		setTextColor(colors.red)
	else
		setTextColor(colors.white)
	end
	rhite(table.concat(arg," "))
	setTextColor(tx)
	setBackgroundColor(bg)
end

local goodPullEvent
if terminateMode == 1 then
	if os.pullEvent ~= os.pullEventRaw then
		goodPullEvent = os.pullEvent
	end
	os.pullEvent = os.pullEventRaw
end

local keepLooping = true

---- SHA256 START ----
--SHA256 implementation done by GravityScore.

local MOD = 2^32
local MODM = MOD-1

local function memoize(f)
	local mt = {}
	local t = setmetatable({}, mt)
	function mt:__index(k)
		local v = f(k)
		t[k] = v
		return v
	end
	return t
end

local function make_bitop_uncached(t, m)
	local function bitop(a, b)
		local res,p = 0,1
		while a ~= 0 and b ~= 0 do
			local am, bm = a % m, b % m
			res = res + t[am][bm] * p
			a = (a - am) / m
			b = (b - bm) / m
			p = p*m
		end
		res = res + (a + b) * p
		return res
	end
	return bitop
end

local function make_bitop(t)
	local op1 = make_bitop_uncached(t,2^1)
	local op2 = memoize(function(a) return memoize(function(b) return op1(a, b) end) end)
	return make_bitop_uncached(op2, 2 ^ (t.n or 1))
end

local bxor1 = make_bitop({[0] = {[0] = 0,[1] = 1}, [1] = {[0] = 1, [1] = 0}, n = 4})

local function bxor(a, b, c, ...)
	local z = nil
	if b then
		a = a % MOD
		b = b % MOD
		z = bxor1(a, b)
		if c then z = bxor(z, c, ...) end
		return z
	elseif a then return a % MOD
	else return 0 end
end

local function band(a, b, c, ...)
	local z
	if b then
		a = a % MOD
		b = b % MOD
		z = ((a + b) - bxor1(a,b)) / 2
		if c then z = bit32_band(z, c, ...) end
		return z
	elseif a then return a % MOD
	else return MODM end
end

local function bnot(x) return (-1 - x) % MOD end

local function rshift1(a, disp)
	if disp < 0 then return lshift(a,-disp) end
	return floor(a % 2 ^ 32 / 2 ^ disp)
end

local function rshift(x, disp)
	if disp > 31 or disp < -31 then return 0 end
	return rshift1(x % MOD, disp)
end

local function lshift(a, disp)
	if disp < 0 then return rshift(a,-disp) end 
	return (a * 2 ^ disp) % 2 ^ 32
end

local function rrotate(x, disp)
    x = x % MOD
    disp = disp % 32
    local low = band(x, 2 ^ disp - 1)
    return rshift(x, disp) + lshift(low, 32 - disp)
end

local k = {
	0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
	0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
	0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
	0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
	0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
	0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
	0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
	0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
	0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
	0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
	0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
	0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
	0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
	0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
	0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
	0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
}

local function str2hexa(s)
	return (string.gsub(s, ".", function(c) return string.format("%02x", string.byte(c)) end))
end

local function num2s(l, n)
	local s = ""
	for i = 1, n do
		local rem = l % 256
		s = string.char(rem) .. s
		l = (l - rem) / 256
	end
	return s
end

local function s232num(s, i)
	local n = 0
	for i = i, i + 3 do n = n*256 + string.byte(s, i) end
	return n
end

local function preproc(msg, len)
	local extra = 64 - ((len + 9) % 64)
	len = num2s(8 * len, 8)
	msg = msg .. "\128" .. string.rep("\0", extra) .. len
	assert(#msg % 64 == 0)
	return msg
end

local function initH256(H)
	H[1] = 0x6a09e667
	H[2] = 0xbb67ae85
	H[3] = 0x3c6ef372
	H[4] = 0xa54ff53a
	H[5] = 0x510e527f
	H[6] = 0x9b05688c
	H[7] = 0x1f83d9ab
	H[8] = 0x5be0cd19
	return H
end

local function digestblock(msg, i, H)
	local w = {}
	for j = 1, 16 do w[j] = s232num(msg, i + (j - 1)*4) end
	for j = 17, 64 do
		local v = w[j - 15]
		local s0 = bxor(rrotate(v, 7), rrotate(v, 18), rshift(v, 3))
		v = w[j - 2]
		w[j] = w[j - 16] + s0 + w[j - 7] + bxor(rrotate(v, 17), rrotate(v, 19), rshift(v, 10))
	end

	local a, b, c, d, e, f, g, h = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
	for i = 1, 64 do
		local s0 = bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22))
		local maj = bxor(band(a, b), band(a, c), band(b, c))
		local t2 = s0 + maj
		local s1 = bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25))
		local ch = bxor (band(e, f), band(bnot(e), g))
		local t1 = h + s1 + ch + k[i] + w[i]
		h, g, f, e, d, c, b, a = g, f, e, d + t1, c, b, a, t1 + t2
	end

	H[1] = band(H[1] + a)
	H[2] = band(H[2] + b)
	H[3] = band(H[3] + c)
	H[4] = band(H[4] + d)
	H[5] = band(H[5] + e)
	H[6] = band(H[6] + f)
	H[7] = band(H[7] + g)
	H[8] = band(H[8] + h)
end

local function sha256(...)
	local msg = table.concat(arg,",")
	msg = preproc(msg, #msg)
	local H = initH256({})
	for i = 1, #msg, 64 do digestblock(msg, i, H) end
	return str2hexa(num2s(H[1], 4) .. num2s(H[2], 4) .. num2s(H[3], 4) .. num2s(H[4], 4) ..
		num2s(H[5], 4) .. num2s(H[6], 4) .. num2s(H[7], 4) .. num2s(H[8], 4))
end

---- SHA256 END ----

local terminates = 0
local sillyTerminate = function()
	local goodpull = _G.os.pullEvent
	os.pullEvent = os.pullEventRaw
	terminates = terminates + 1
	local script = {
		"You shall not pass!",
		"THOU shalt not pass!",
		"Stop trying to pass!",
		"...maybe I'm not clear.",
		"YOU. SHALL NOT. PASS!!",
		"Pass thou shalt not!",
		"Hey, piss off, will ya?",
		"I haven't got all day.",
		"...no, shut up. I don't.",
		"I won't tell you it!",
		"No password for you.",
		"It's been hashed!",
		"Hashed...with a salt!",
		"I'll never tell you the salt.",
		"You know why?",
		"Because that requires passing!",
		"WHICH THOU SHALT NOT DO!",
		"(oh btw don't pass k?)",
		"You! Don't pass!",
		"That means YOU!",
		"Cut it out!",
		"Re: Cut it out!",
		"Perhaps if you keep it up...",
		"..hmm...",
		"..oh I give up.",
		"<bullshitterm>",
		"What? Is this what you wanted?",
		"Huh? No? I-it's not?",
		"Well then...!",
		"<toobad>",
		"YEAH I SAID IT",
		"You think you're a terminating machine!",
		"You think you're above consequence!",
		"...w-...",
		"eat my shorts",
		"Your attempts are futile anyhow.",
		"Here I am getting drunk off your sweat,",
		"...while you push CTRL and T.",
		"Or maybe you're pressing that [T] button.",
		"Like, um, in CCEmuRedux.",
		"But it matters not!",
		"For you see, my defences are great!",
		"Nothing can bust my rock-hard abs!",
		"<fuckinghell>",
		"Oh bualls.",
		"That was embarrasing.",
		"...?",
		"What're YOU lookin' at??",
		"You callin' me UNSTABLE!?",
		"HUH!??",
		"...",
		"...w-well at least I admit it",
		"...b-bakka",
		".......",
		"Hey, have you ever played EarthBound?",
		"(Yes. I'm gonna rant.)",
		"It's an RPG on the Super Nintendo.",
		"Like, instead of fighting fantasy demons,",
		"you fight stop signs and cars and shit",
		"And, like, you hit rabid dogs with a bat",
		"And you have magical PSI spells",
		"...speaking of PSI, I happen to use it a lot.",
		"...er, *I* as in the coder of this lock...",
		"And by PSI, I mean the mod.",
		"You don't see too many psychic locks these days.",
		"A shame, really.",
		"I bet a PSI lock could act as a heater with PSI Fire.",
		"Or maybe it can kill rats with PSI Ground or Thunder",
		"Maybe, you can get a psychic KEY lock, so, like,",
		"you could put it on that Psychonauts head door thing.",
		"...WHAT!? just a suggestion.",
		"Psychonauts is another game I reccommend.",
		"It has some really clever dialogue.",
		"I'm sure you'd like it quite a lot.",
		"I know, because you've been here for ten fucking minutes.",
		"And you're not ONE STEP closer to getting the password",
		"Which I've been guarding very, very closely.",
		"Yes. Extremely closely.",
		"Excrutiatingly, some would say.",
		"You know, I should probably get to shouting.",
		"*ahem*",
		"...",
		"*aahhhechhemmemmhmm*",
		"*aachkskacehchachkhackcoughfartfuckdammitaaucahkh*",
		"...",
		"STAHP IT",
		"STAHP TEHRMINATIN",
		"do it for the CHILDREN",
		"okay fuck the children, who needs 'em",
		"then",
		"um",
		"THINK OF THE...THE...",
		"the babies...?",
		"um",
		"<abuseofcommunity>",
		"That's a fucking horrible idea.",
		"I'd rather eat my own brain then think about that.",
		"I'd sooner kiss a pig!",
		"I'd sooner swallow an avocado pit!",
		"...",
		"You know, you suck so much.",
		"You suck so much, and I'm sick of writing this script",
		"If my knuckles bleed, you're paying my insurance",
		"In order to save time, money, and my joints,",
		"I believe it would be in order to...",
		"...to say,",
		"NO TERMINATING.",
	}
	setCursorBlink(false)
	local mess
	if terminates > #script then
		mess = script[#script]
	else
		mess = script[terminates]
	end
	if mess == "<bullshitterm>" then
		setBackgroundColor(colors.black)
		if term.isColor() then
			setTextColor(colors.yellow)
		else
			setTextColor(colors.white)
		end
		term.clear()
		setCursorPos(1,1)
		print(os.version())
		write("> ")
		setTextColor(colors.white)
		read()
		printError("shell:350: Unable to pass")
		sleep(2)
	elseif mess == "<toobad>" then
		setBackgroundColor(colors.black)
		if term.isColor() then
			setTextColor(colors.red)
		else
			setTextColor(colors.white)
		end
		term.clear()
		setCursorPos(1,scr_y/2)
		local toobad = " T"..("O"):rep(scr_x-8).." BAD!"
		for a = 1, #toobad do
			for y = 1, scr_y do
				setCursorPos(a,y)
				rhite(toobad:sub(a,a))
			end
			sleep(0)
		end
		sleep(1.5)
		for a = 1, 16 do
			if a%3 == 0 then
				setBackgroundColor(colors.white)
			elseif a%3 == 1 then
				setBackgroundColor(colors.black)
			else
				if term.isColor() then
					setBackgroundColor(colors.red)
				else
					setBackgroundColor(colors.gray)
				end
			end
			term.clear()
			sleep(0)
		end
	elseif mess == "<fuckinghell>" then
		writeError("Terminated")
		setBackgroundColor(colors.black)
		setTextColor(colors.white)
		term.blit(">","4","f")
		read()
		sleep(0.75)
		for a = 1, 2 do
			sleep(0.05)
			term.scroll(1)
		end
		for a = 1, scr_y do 
			sleep(0.05)
			term.scroll(-1)
		end
		sleep(0.25)
		setBackgroundColor(colors.gray)
		term.clear()
		sleep(0.1)
		setBackgroundColor(colors.lightGray)
		term.clear()
		sleep(0.1)
		setBackgroundColor(colors.white)
		term.clear()
		sleep(0.25)
		local msg = "taht didn't happan"
		term.setCursorPos(scr_x-#msg,scr_y)
		setTextColor(colors.black)
		rhite(msg)
		sleep(1)
	elseif mess == "<abuseofcommunity>" then
		setBackgroundColor(colors.white)
		setTextColor(colors.black)
		term.clear()
		setCursorPos(2,3)
		print("Since you're such a smart bastard, why don't you come up with something objectionable to think about?\n")
		setBackgroundColor(colors.gray)
		setTextColor(colors.white)
		term.clearLine()
		local yourFuckingShittyAssResponceThatSucksSoMuchBallsThatIWouldRatherListenToThatFuckingOwlFromOcarinaOfTimeBlatherAboutHisFuckingDayThanSitWithYouForAnotherGoddamnedSecondReeeeee = read()
		setBackgroundColor(colors.white)
		setTextColor(colors.black)
		for a = 1, 5 do
			sleep(0.6)
			write(".")
		end
		sleep(1)
		term.setTextColor(colors.red)
		for a = 1, 20 do
			sleep(0.05)
			write(".")
		end
		sleep(0.5)
	else
		setBackgroundColor(colors.gray)
		setTextColor(colors.white)
		setCursorPos(math.max(1,(scr_x/2)-(#mess/2)),scr_y/2)
		if language == "english" then
			write(mess)
		else
			write(lang[language].noTerminate)
		end
		sleep(1.5)
	end
	os.pullEvent = goodpull
	return terminates
end

local shuffle = function(txt)
	local output = ""
	for a = 1, #txt do
		if a % 2 == 0 then
			output = output..txt:sub(a,a)
		else
			output = txt:sub(a,a)..output
		end
	end
	return output
end

local goodpass = function(pswd,count)
	isTerminable = true
	doSine = false
	setCursorBlink(false)
	local flashes = {
		colors.white,
		colors.lightGray,
		colors.gray,
	}
	if type(pswd) == "table" then
		pswd = pswd[1]
	end
	setTextColor(colors.black)
	local correctmsg
	if count < 10 then
		correctmsg = lang[language].right1
	else
		correctmsg = lang[language].right2
	end
	for a = 1, #flashes do
		setBackgroundColor(flashes[#flashes-(a-1)])
		term.clear()
		setCursorPos((scr_x/2)-(#correctmsg/2),scr_y/2)
		rhite(correctmsg)
		sleep(0)
	end
	if #doorSides == 0 then
		sleep(0.4)
		keepLooping = false
	else
		local doormsg
		if doShowDoorSides then
			doormsg = "Applying RS to "..table.concat(doorSides,", ").."."
		else
			doormsg = "Applying redstone."
		end
		setCursorPos((scr_x/2)-(#doormsg/2),(scr_y/2)+2)
		rhite(doormsg)
		for a = 1, #doorSides do
			redstone.setOutput(doorSides[a],not doInvertSignal)
		end
		if terminateMode == 1 then
			os.pullEvent = goodPullEvent
		end
		sleep(goodlength)
		if terminateMode == 1 then
			os.pullEvent = os.pullEventRaw
		end
		for a = 1, #doorSides do
			redstone.setOutput(doorSides[a],doInvertSignal)
		end
	end
	for a = 1, #flashes do
		setBackgroundColor(flashes[a])
		term.clear()
		setCursorPos((scr_x/2)-(#correctmsg/2),scr_y/2)
		rhite(correctmsg)
		sleep(0)
	end
	setBackgroundColor(colors.black)
	term.clear()
	setCursorPos(1,1)
	if terminateMode == 1 and goodPullEvent and (#doorSides == 0) then
		os.pullEvent = goodPullEvent
	end
	setCursorBlink(true)
	isTerminable = false
	return true
end

local badpass = function(pswd,count)
	doSine = false
	local getevent = os.pullEvent
	os.pullEvent = os.pullEventRaw
	setCursorBlink(false)
	setBackgroundColor(palate.wrongBG)
	setTextColor(palate.wrongTXT)
	term.clear()
	if type(pswd) == "table" then
		pswd = pswd[1]
	end
	local badmsg
	if count < 10 then
		if pswd == sha256("bepis",salt) then
			badmsg = "Bepis."
		else
			badmsg = lang[language].wrong1
		end
	else
		if pswd == sha256("bepis",salt) then
			badmsg = "BEPIS!"
		else
			badmsg = lang[language].wrong2
		end
	end
	setCursorPos((scr_x/2)-(#badmsg/2),scr_y/2)
	rhite(badmsg)
	sleep(badlength)
	doSine = true
	setCursorBlink(true)
	os.pullEvent = getevent
	return "man you suck"
end
	
local readPassFile = function()
	local _output, _salt
	if fs.exists(passFile) then
		local file = fs.open(passFile,"r")
		_output = file.readLine()
		file.close()
	end
	if fs.exists(saltFile) then
		local file = fs.open(saltFile,"r")
		_salt = file.readLine()
		file.close()
	end
	return _output, _salt
end

local addNewPassword = function(pword,_path)
	local file = fs.open(_path or passFile,"a")
	file.write( sha256(pword,salt) )
	file.close()
end
       
local rendersine = function(move)
	move = move or 0
	local res1,res2,x,y
	if csv then term.current().setVisible(false) end
	setBackgroundColor(colors.black)
	setCursorBlink(false)
	for a = 1, scr_y do
		if a ~= readYpos then
			for b = 1, scr_x do
				x = b+floor(scr_x/2)
				y = a-floor(scr_y/2)
				res1 = abs( floor(sin((x/(scr_x/7.3))+move)*scr_y/4) - y ) <= 2
				setCursorPos(b,a)
				if res1 then
					setBackgroundColor(palate.backsine)
				else
					setBackgroundColor(palate.background)
				end
				rhite(" ")
				res2 = abs( floor(cos((x/(scr_x/12.75))+(move*4))*scr_y/7) - y+2 ) <= 1
				setCursorPos(b,a)
				if res2 then
					setBackgroundColor(palate.frontsine)
					rhite(" ")
				elseif not res1 then
					setBackgroundColor(palate.background)
					setTextColor(palate.rainColor)
					if (x % 2 == 0) and ((y+floor(move*-10)+(x % 5)) % 5 <= 1) then
						rhite(palate.rainChar)
					else
						rhite(" ")
					end
				end
			end
		end
	end
	if csv then term.current().setVisible(true) end
	setCursorBlink(true)
end

local sine = function()
	doSine = true
	while true do
		if sineLevel > 900 then
			sineLevel = 1
		end
		if doSine then
			local cX,cY = getCursorPos()
			local bg,txt = getBackgroundColor(),getTextColor()
			rendersine(sineLevel/10)
			setCursorPos(cX,cY)
			setBackgroundColor(bg)
			setTextColor(txt)
		end
		sleep(sineFrameDelay)
		if kaykaycoolcool then
			sineLevel = sineLevel + 1
		end
	end
end

local funcread = function(repchar,rHistory,doFunc,noNewLine,writeFunc,cursorAdjFunc,doFuncEvent,charLimit)
	local scr_x,scr_y = term.getSize()
	local sx,sy = term.getCursorPos()
	local cursor = 1
	local rCursor = #rHistory+1
	local output = ""
	term.setCursorBlink(true)
	local rite = writeFunc or term.write
	cursorAdjFunc = cursorAdjFunc or function() return 0 end
	while true do
		local evt,key = os.pullEvent()
		if evt == doFuncEvent then
			pleaseDoFunc = true
		elseif evt == "key" then
			if key == keys.enter then
				if not noNewLine then
					write("\n")
				end
				term.setCursorBlink(false)
				return output
			elseif key == keys.left then
				if cursor-1 >= 1 then
					cursor = cursor - 1
				end
			elseif key == keys.right then
				if cursor <= #output then
					cursor = cursor + 1
				end
			elseif key == keys.up then
				if rCursor > 1 then
					rCursor = rCursor - 1
					term.setCursorPos(sx,sy)
					rite((" "):rep(#output))
					output = (rHistory[rCursor] or ""):sub(1,charLimit or -1)
					cursor = #output+1
					pleaseDoFunc = true
				end
			elseif key == keys.down then
				term.setCursorPos(sx,sy)
				rite((" "):rep(#output))
				if rCursor < #rHistory then
					rCursor = rCursor + 1
					output = (rHistory[rCursor] or ""):sub(1,charLimit or -1)
					cursor = #output+1
					pleaseDoFunc = true
				else
					rCursor = #rHistory+1
					output = ""
					cursor = 1
				end
			elseif key == keys.backspace then
				if cursor > 1 and #output > 0 then
					output = (output:sub(1,cursor-2)..output:sub(cursor)):sub(1,charLimit or -1)
					cursor = cursor - 1
					pleaseDoFunc = true
				end
			elseif key == keys.delete then
				if #output:sub(cursor,cursor) == 1 then
					output = (output:sub(1,cursor-1)..output:sub(cursor+1)):sub(1,charLimit or -1)
					pleaseDoFunc = true
				end
			end
		elseif evt == "char" or evt == "paste" then
			output = (output:sub(1,cursor-1)..key..output:sub(cursor+(#key-1))):sub(1,charLimit or -1)
			cursor = math.min(#output+1,cursor+#key)
			pleaseDoFunc = true
		end
		local pOut = (output or ""):sub(math.max( 1,(#output+sx)-scr_x) )
		if pleaseDoFunc then
			pleaseDoFunc = false
			if type(doFunc) == "function" then
				doFunc(output:sub(1,charLimit or -1))
			end
			term.setCursorPos(sx,sy)
			if repchar then
				rite(repchar:sub(1,1):rep(#pOut))
			else
				rite(pOut)
			end
			term.write(" ")
		end
		term.setCursorPos(sx+cursorAdjFunc(pOut)+cursor-math.max( 1,(#output+sx)-scr_x),sy)
	end
end

local arse, arseSHA, passes

local awaitKeyCard = function()
	local bwop,_,side
	repeat
		_,side = os.pullEvent("disk")
		if side then
			bwop = fs.combine(disk.getMountPath(side),".sinepw") --bwop!
		else
			bwop = ""
		end
	until fs.exists(bwop) and not fs.isDir(bwop)
	local file = fs.open(bwop,"r")
	local output = file.readLine()
	file.close()
	arseSHA = output
	if doEjectDisk then disk.eject(side) end
end

local passwordPrompt = function()
	if requireAllPasswords then
		arse = {}
		arseSHA = ""
		for a = 1, ceil(#passes/64) do
			setCursorPos(1,readYpos)
			setBackgroundColor(palate.promptBG)
			term.clearLine()
			setTextColor(palate.promptTXT)
			write("P"..a..">")
			arse[#arse+1] = read(dahChar)
			arseSHA = arseSHA..sha256(arse[#arse],salt)
		end
	else
		setCursorPos(1,readYpos)
		setBackgroundColor(palate.promptBG)
		term.clearLine()
		setTextColor(palate.promptTXT)
		write(">")
		arse = funcread(dahChar,{},nil,true,nil,nil,nil,characterLimit)
		arseSHA = sha256(arse,salt)
	end
end

local count = 0

local lock = function()
	if #doorSides > 0 then
		for a = 1, #doorSides do
			redstone.setOutput(doorSides[a],doInvertSignal)
		end
	end
	while true do
		passes, salt = readPassFile()
		count = count + 1
		if doKeyCards then
			parallel.waitForAny(passwordPrompt,awaitKeyCard)
		else
			passwordPrompt()
		end
		local good
		if requireAllPasswords then
			if passes == arseSHA then
				good = true
			else
				good = false
			end
		else
			if string.find(passes,arseSHA) then
				good = true
			else
				good = false
			end
		end
		if good then
			goodpass(arseSHA,count)
			if #doorSides == 0 then
				return true
			else
				doSine = true
			end
		else
			badpass(arseSHA,count)
		end
	end
end

local choice = function(input)
	repeat
		event, key = os.pullEvent("key")
		if type(key) == "number" then key = keys.getName(key) end
		if key == nil then key = " " end
	until string.find(input, key)
	return key
end

if not fs.exists(saltFile) then
	local file = fs.open(saltFile,"w")
	for a = 1, 128 do
		local c = string.char(random(1,255))
		file.write(c)
	end
	file.close()
	local f = fs.open(saltFile,"r")
	salt = f.readLine()
	f.close()
end

passes, salt = readPassFile()

local tArg = {...}
if tArg[1] == "addpass" then
	if tArg[2] then
		print("Really add password? [Y,N]")
		local answer = choice("yn")
		if answer == "n" then
			sleep(0)
			return print("Oh, okay.")
		else
			table.remove(tArg,1)
			addNewPassword(table.concat(tArg," "))
			sleep(0)
			return print("Added password.")
		end
	else
		sleep(0)
		return print("Expected a new password...")
	end
elseif tArg[1] == "keymake" then
	if tArg[2] then
		print("Really add to disk?")
		print("Keep in mind the password has to be manually added for the keycard to work.\n[Y,N]")
		local answer = choice("yn")
		if answer == "n" then
			sleep(0)
			return print("Oh, okay.")
		else
			print("Please insert a disk or pocket computer.")
			local _,side = os.pullEvent("disk")
			local diskPassPath = fs.combine(disk.getMountPath(side),".sinepw")
			table.remove(tArg,1)
			addNewPassword(table.concat(tArg," "),diskPassPath)
			if not disk.getLabel(side) then
				disk.setLabel(side,"slkey-"..random(1,1000))
			end
			sleep(0)
			print("Added password.")
			if not doKeyCards then
				print("Key cards aren't enabled, though.")
			end
			return
		end
	else
		sleep(0)
		return print("Expected a password...")
	end
end

if not fs.exists(passFile) then
	local progname = fs.getName(shell.getRunningProgram())
	return print("No password file found.\nRun '"..progname.." addpass <password>' to add a password.")
end

setBackgroundColor(colors.black)
term.clear()

local parafunky = { --it looks kinda funky, but it tastes funKAY!
	sine,
	lock,
}

if not beWavey then table.remove(parafunky,1) end --not funky, man
local staytis, errawr
while keepLooping do
	kaykaycoolcool = true
	staytis, errawr = pcall(parallel.waitForAny,unpack(parafunky))
	if keepLooping == false then break else
		if terminateMode == 2 then
			kaykaycoolcool = false
			if not isTerminable then
				sillyTerminate()
			else
				keepLooping = false
				setBackgroundColor(colors.black)
				term.clear()
				setTextColor(colors.white)
				setCursorPos(1,1)
				break
			end
		else
			keepLooping = false
			setBackgroundColor(colors.black)
			term.clear()
			setTextColor(colors.white)
			setCursorPos(1,1)
			if not staytis then
				printError(errawr)
			end
			break
		end
	end
end
if runProgram and (runProgram ~= "") then
	shell.run(runProgram)
end