--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...
core.Lib = {} -- adds Lib table to addon namespace
local Lib = core.Lib

function Lib:FirstLetterUp(str)
    local rtn = ""
    for i = 1, #str do
        local c = str:sub(i,i)
        if (i == 1) then
            rtn = rtn .. string.upper(c)
        else
            rtn = rtn .. string.lower(c)
        end
    end
    return rtn
end

function Lib:SplitString(str, separator, index)
    local rtn = {}
    for _, arg in ipairs({ string.split(separator, str) }) do
        if (#arg > 0) then
            table.insert(rtn, arg)
        end
    end
    if (index == "#") then
        return rtn[#rtn]
    elseif (index) then
        return rtn[index]
    else
        return rtn
    end
end

function Lib:IsNumeric(str)
    local rtn
    if (str) then
        for i = 1, #str do
            local c = str:sub(i,i)
            if (not((c == "0" and i ~= 1) or c == "1" or c == "2" or c == "3" or c == "4" or c == "5" or c == "6" or c == "7" or c == "8" or c == "9")) then
                return false
            end
        end
        return true
    else
        return false
    end
end

function Lib:GetCenter(get,frame)
	local x, y = frame:GetCenter()
	
	if (get == string.lower("x")) then
		return x
	elseif (get == string.lower("y")) then
		return y
	else
		return 0
	end
end





