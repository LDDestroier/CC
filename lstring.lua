-- Lengthed string API
--  by LDDestroier

local LString = {}

local default_key_size = 1
local default_value_size = 1

function LString.Error( sMsg, tContext )
	LString.__error = {
		message = sMsg,
		context = tContext
	}
	error(sMsg, 1)
end

-- converts number to a string of byte characters
function LString.NumToBytes( number, length )
	length = length or default_value_size
	assert(type(length) == "number", "must specify byte length")
	local output = ""
	for i = 1, length do
		output = output .. string.char(
			math.floor(number / 2^(8 * (i - 1))) % 256
		)
	end
	return output
end

-- converts a string of bytes back into a number
function LString.BytesToNum( bytes, length )
	assert( type(bytes) == "string", "bytes must be represented as string" )
	length = length or #bytes
	local output = 0
	for i = 1, length do
		output = output + (string.byte(bytes:sub(i, i)) * 2 ^ (8 * (i - 1)))
	end
	return output
end

-- returns lengthed string, and whether or not it was truncated to the byte limit
function LString.MakeLString( sInput, nSize )
	local limit = 2^(nSize * 8) - 1
	return LString.NumToBytes(math.min(tostring(sInput):len(), limit), nSize) .. tostring(sInput):sub(1, limit),
	tostring(sInput):len() > limit
end

local tAbbr = {
	string = "s",
	number = "n",
	table = "t",
	boolean = "b"
}

function LString.GetLString( sInput, nSize, nIterator )
	nIterator = nIterator or 1
	nSize = nSize or default_value_size
	local len = LString.BytesToNum(sInput:sub(nIterator), nSize)
	return sInput:sub(nSize + nIterator, nSize + len + nIterator - 1), nIterator + len + nSize
end

function LString.GetLTypeString( sInput, nSize, nIterator, tTypeSizeOverride )
	nIterator = nIterator or 1
	local ltype = sInput:sub(nIterator, nIterator)
	if (tTypeSizeOverride[ltype]) then
		nSize = tTypeSizeOverride[ltype]
	end
	local output
	nIterator = nIterator + 1
	output, nIterator = LString.GetLString(sInput, nSize, nIterator)
	return output, nIterator, ltype
end

-- serializes a table of strings, numbers, and tables containing them

function LString.serialize( tInput, nKeySize, nValueSize, bOmitType )
	local output = ""
	local count = 0

	nKeySize = nKeySize or default_key_size
	nValueSize = nValueSize or default_value_size

	for k,v in pairs(tInput) do
		if ( not tAbbr[type(k)] ) then
			LString.Error("bad serialize! key must be string, number, boolean, or a table containing only them", {
				tInput = tInput,
				key = k,
				value = v
			})

		elseif ( not tAbbr[type(v)] ) then
			LString.Error("bad serialize! key must be string, number, boolean, or a table containing only them", {
				tInput = tInput,
				key = k,
				value = v
			})
		end
		
		if (bOmitType) then
			if ( type(k) == "table" ) then
				LString.Error("cannot use table as key if omitting type", {
					tInput = tInput,
					key = k,
					value = v
				})
			else
				output = output .. LString.MakeLString(k, nKeySize)
			end

			if ( type(v) == "table" ) then
				LString.Error("cannot use table as value if omitting type", {
					tInput = tInput,
					key = k,
					value = v
				})

			else
				output = output .. LString.MakeLString(v, nValueSize)
			end

		else
			output = output .. tAbbr[type(k)]
			if ( type(k) == "table" ) then
				-- table values must have a length of 32 bits
				output = output .. LString.MakeLString(LString.serialize(k, nKeySize, nValueSize), 4)

			elseif ( type(k) == "boolean" ) then
				output = output .. LString.MakeLString(k and "T" or "F", 1)
			
			else
				output = output .. LString.MakeLString(k, nKeySize)
			end

			output = output .. tAbbr[type(v)]
			if ( type(v) == "table" ) then
				-- table values must have a length of 32 bits
				output = output .. LString.MakeLString(LString.serialize(v, nKeySize, nValueSize), 4)

			elseif ( type(v) == "boolean" ) then
				output = output .. LString.MakeLString(v and "T" or "F", 1)
			
			else
				output = output .. LString.MakeLString(v, nValueSize)
			end
		end

		count = count + 1
	end

	output = LString.NumToBytes(count, 2) .. output

	return output
end
LString.serialise = LString.serialize

-- will assume every key and value are strings
function LString.serializeTypeless(sInput, nKeySize, nValueSize)
	return LString.serialize(sInput, nKeySize, nValueSize, 1, true)
end
LString.serialiseTypeless = LString.serializeTypeless

function LString.unserialize( sInput, nKeySize, nValueSize, nIterator, bOmitType )
	nKeySize = nKeySize or default_key_size
	nValueSize = nValueSize or default_value_size

	local tOutput = {}
	nIterator = nIterator or 1
	local count = LString.BytesToNum(sInput:sub(nIterator), 2)
	nIterator = nIterator + 2
	local lkey, lval, ltype

	for i = 1, count do
		if (bOmitType) then
			ltype = "s"
			lkey, nIterator = LString.GetLString(sInput, nKeySize, nIterator)
		else
			lkey, nIterator, ltype = LString.GetLTypeString(sInput, nKeySize, nIterator, {['t'] = 4, ['b'] = 1})
		end

		if (ltype == "n") then
			lkey = tonumber(lkey)

		elseif (ltype == "t") then
			lkey = LString.unserialize(lkey, nKeySize, nValueSize)
		
		elseif (ltype == "b") then
			lkey = lkey == "T"
		end
		
		if (bOmitType) then
			ltype = "s"
			lval, nIterator = LString.GetLString(sInput, nValueSize, nIterator)
		else
			lval, nIterator, ltype = LString.GetLTypeString(sInput, nValueSize, nIterator, {['t'] = 4, ['b'] = 1})
		end

		if (ltype == "n") then
			lval = tonumber(lval)

		elseif (ltype == "t") then
			lval = LString.unserialize(lval, nKeySize, nValueSize, 1, bOmitType)
		
		elseif (ltype == "b") then
			lval = lval == "T"
		end

		tOutput[lkey] = lval
	end

	return tOutput, nIterator
end
LString.unserialise = LString.unserialize

function LString.unserializeTypeless(sInput, nKeySize, nValueSize)
	return LString.unserialize(sInput, nKeySize, nValueSize, 1, true)
end
LString.unserialiseTypeless = LString.unserializeTypeless

return LString
