--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...

--------------------------------------
-- Custom Slash Command
--------------------------------------
core.commands = {
	["start"] = core.Config.Toggle, -- this is a function (no knowledge of Config object)
	
	["help"] = function()
		local color = "fffb00"
		print(" ")
		core:Print("List of slash commands:")
		core:Print("|cff"..color.."/ttt start|r - start the game")
		core:Print("|cff"..color.."/ttt reset|r - reset the AddOn configuration")
		core:Print("|cff"..color.."/ttt solo|r  - enables singleplayer mode")
		core:Print("|cff"..color.."/ttt help|r  - shows help info")
		core:Print("|cff"..color.."/ttt stats|r - shows the player statistics")
		print(" ")
	end,
	
	["example"] = {
		["test"] = function(...)
			core:Print("My Value:", tostringall(...))
		end
	},

	["reset"] = core.Config.ResetAddon,

	["solo"] = core.Config.Singleplayer,

	["stats"] = core.Config.PrintPlayerStats,
}

local function HandleSlashCommands(str)	
	if (#str == 0) then	
		-- User just entered "/ttt" with no additional args.
		core.Config.Toggle()
		return		
	end	
	
	local args = {}
	for _, arg in ipairs({ string.split(' ', str) }) do
		if (#arg > 0) then
			table.insert(args, arg)
		end
	end
	
	local path = core.commands -- required for updating found table.
	
	for id, arg in ipairs(args) do
		if (#arg > 0) then -- if string length is greater than 0.
			arg = arg:lower()			
			if (path[arg]) then
				if (type(path[arg]) == "function") then				
					-- all remaining args passed to our function!
					path[arg](select(id + 1, unpack(args))) 
					return					
				elseif (type(path[arg]) == "table") then				
					path = path[arg] -- another sub-table found!
				end
			else
				-- does not exist!
				core.commands.help()
				return
			end
		end
	end
end

function core:Print(...)
    local hex = select(4, self.Config:GetThemeColor())
    local prefix = string.format("|cff%s%s|r", hex:upper(), "TicTacToe")
    DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...))
end

-- WARNING: self automatically becomes events frame!
function core:init(event, name)

	-- allows using left and right buttons to move through chat 'edit' box
	for i = 1, NUM_CHAT_WINDOWS do
		_G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false)
	end
	
	----------------------------------
	-- Register Slash Commands!
	----------------------------------
	SLASH_TicTacToe1 = "/ttt"
	SlashCmdList.TicTacToe = HandleSlashCommands
	
	-- Needs to be removed, once developing is finished!
	-- core.Config.Toggle()
end



local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", core.init)