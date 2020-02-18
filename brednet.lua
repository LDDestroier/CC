-- brednet - better rednet
-- if you're going to be using rednet, at least use this

local brednet = {}

if ccemux and not peripheral.find("modem") then
	ccemux.attach("top", "wireless_modem")
end

-- stores the last 'maxUsed' amount of received messages
local maxUsed = 1000
local USED = {}

local computerID = os.getComputerID()

local cycleIntoUsed = function(msgID)
	USED[msgID] = maxUsed
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

	session.send = function(message, recipient, channel)
		local msgID = math.random(1, 2^31-1)
		cycleIntoUsed(msgID)
		if channel then
			modem.open(channel)
		end
		modem.transmit(
			channel or session.channel,
			channel or session.channel,
			{
				msg = message,
				msgID = msgID,
				id = computerID,
				recipient = recipient,
				time = os.time()
			}
		)
	end

	session.check = function(input)
		-- check types
		if type(input) == "table" then
			if type(input.id) == "number" and type(input.msgID) == "number" and input.msg then
				if not USED[input.msgID] then
					return input
				end
			end
		end
	end

	session.receive = function(senderID, channel)
		local evt, output
		if channel then
			modem.open(channel)
		end
		-- keep receiving and repeating all messages, regardless of recipient
		while true do
			-- only return if you ARE the recipient
			output = nil
			while not output do
				evt = {os.pullEvent("modem_message")}
				output = session.check(evt[5])
			end
			cycleIntoUsed(output.msgID)
			modem.transmit(
				channel or session.channel,
				channel or session.channel,
				{
					msg = output.msg,
					msgID = output.msgID,
					id = output.id,
					recipient = output.recipient,
					time = output.time,
				}
			)
			if (
				((not output.recipient) or (output.recipient == computerID)) and
				((not senderID) or (output.id == senderID))
			) then
				return output.msg, output.id
			end
		end
	end

	modem.open(session.channel)

	return session
end

return brednet
