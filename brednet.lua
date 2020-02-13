-- brednet - better rednet
-- if you're going to be using rednet, at least use this

local brednet = {}

ccemux.attach("top", "wireless_modem")

-- stores the last 1000 received messages
local USED = {}

local cycleIntoUsed = function(id)
	USED[id] = 1000
	for k,v in pairs(USED) do
		if v == 0 then
			USED[k] = nil
		else
			USED[k] = -1 + v
		end
	end
end

brednet.open = function(CHANNEL, MODEMS)
	local session = {
		channel = CHANNEL or 65530,
		modems = MODEMS or {},
	}

	-- make virtual modem that is, in fact, every modem in the list
	session.modem = {}
	local modem = session.modem
	for k,v in next, {"open", "close", "transmit"} do
		local list = (#session.modems ~= 0) and sessions.modems or {peripheral.find("modem")}
		modem[v] = function(...)
			for i = 1, #list do
				list[i][v](...)
			end
		end
	end

	session.send = function(message, channel)
		local msgID = math.random(1, 2^31-1)
		cycleIntoUsed(msgID)
		modem.transmit(
			channel or session.channel,
			channel or session.channel,
			{
				msg = message,
				id = msgID,
				time = os.time()
			}
		)
	end

	session.parse = function(input)
		-- check types
		if type(input) == "table" then
			if type(input.id) == "number" and input.msg then
				if not USED[input.id] then
					return input.id, input.msg
				end
			end
		end
	end

	session.receive = function()
		local evt, output = {}
		while not session.parse(evt[5]) do
			evt = {os.pullEvent("modem_message")}
		end
		cycleIntoUsed(evt[5].id)
		modem.transmit(
			channel or session.channel,
			channel or session.channel,
			{
				msg = evt[5].msg,
				id = evt[5].id,
				time = evt[5].time,
			}
		)
		return evt[5].id, evt[5].msg
	end

	modem.open(session.channel)

	return session
end

return brednet
