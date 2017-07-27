--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...
core.Config = {} -- adds Config table to addon namespace
local Config = core.Config

--------------------------------------
-- Defaults
--------------------------------------

local xCenter, yCenter = UIParent:GetCenter()

local default = {
	title = "Tic Tac Toe",

	theme = {
		r = 0, 
		g = 0.8, -- 204/255
		b = 1,
		hex = "ff7d00",
	},

	position = {
		x = xCenter * 1.5,
		y = yCenter * 1.1,
	},
	
	size = {
		width = 230,
		height = 275,
		expanded = {
			height = 120,
		},
	},

	chatTypes = {
		"EMOTE",
		"WHISPER",
		"PARTY",
        "GUILD",
	},
}


--------------------------------------
-- Initializing Variables
--------------------------------------

local MainFrame
local ScrollFrame
local GameFrame
local SpaceFrame
local StatsFrame
local ConfigFrame
local DropDownChatType

local xPosition = default.position.x
local yPosition = default.position.y

local player = {
	{
		name = "",
		wins = 0,
		defeats = 0,
		playedGames = 0,
	},
	{
		name = "",
		wins = 0,
		defeats = 0,
		playedGames = 0,
	},
}
local playerSelf = ""
local singleplayer = false
local invitationChatType = ""
local invitationSender = ""
local chatType = "EMOTE"
local whisperTarget = nil
local lastMsg = ""

local counter = 0
local win = false
local blackList = ""

local expandedMainFrame = false

--------------------------------------
-- Functions
--------------------------------------

-- Updates the statistics in the statistic frame.
local function UpdateStatsFrame(id)
	Config:CreateStats(id, "name", 			"Player Two")
	Config:CreateStats(id, "wins", 			"Wins:         ")
	Config:CreateStats(id, "defeats", 		"Defeats:      ")
	Config:CreateStats(id, "playedGames", 	"Total:        ")
end

-- Updates the players statistics by adding 1 to any of the fields.
local function UpdatePlayerStats(id, played, win, lose)
	if (win) 	then player[id].wins				= player[id].wins 			+ 1	end
	if (lose)	then player[id].defeats			= player[id].defeats 			+ 1	end
	if (played) then player[id].playedGames	= player[id].playedGames	+ 1	end
	UpdateStatsFrame(id)
end

-- Initializes the players.
local function SetPlayers(playerOne, playerTwo)
	if (playerOne) then
		player[1].name = playerOne
		player[1].wins = 0
		player[1].defeats = 0
		player[1].playedGames = 0
		UpdateStatsFrame(1)
	end
	if (playerTwo) then
		player[2].name = playerTwo
		player[2].wins = 0
		player[2].defeats = 0
		player[2].playedGames = 0
		UpdateStatsFrame(2)
	end
end

-- Updates the state of the singleplayer checkbox.
local function UpdateSingleplayer(solo)
	if (solo == nil) then solo = false end
	singleplayer = solo
    if (MainFrame) then
	    ConfigFrame.soloCheckBox:SetChecked(solo)
    end
end

-- Disables all buttons.
local function DisableFields()
	for i = 1, #GameFrame.field do
		GameFrame.field[i]:Disable()
	end
end

-- Disables the black listed Fields.
local function DisableBlacklistedFields()
	for i = 1, #blackList do
		local c = blackList:sub(i,i)
		GameFrame.field[tonumber(c)]:Disable()
	end
end

-- Enables all buttons.
local function EnableFields()
	for i = 1, #GameFrame.field do
		GameFrame.field[i]:Enable()
	end
end

-- Invites an other player.
local function InvitePlayer(name)
	if (chatType == "WHISPER" and (not whisperTarget or whisperTarget == "")) then
		core:Print("No whisper target chosen!")
	else
		SendChatMessage("has invited " ..name.. " to play Tic Tac Toe.", chatType, nil, whisperTarget)
	end
end

-- Check if a player has won.
local function checkIfWon(frst, scnd, thrd, curPlayer)
	if ((GameFrame.field[frst]:GetText() == GameFrame.field[scnd]:GetText()) and (GameFrame.field[frst]:GetText() == GameFrame.field[thrd]:GetText()) and (GameFrame.field[frst]:GetText() ~= nil)) then
		GameFrame.field[frst]:LockHighlight()
		GameFrame.field[scnd]:LockHighlight()
		GameFrame.field[thrd]:LockHighlight()
		if (curPlayer == playerSelf) and (singleplayer == false) then
			if (chatType == "WHISPER" and (not whisperTarget or whisperTarget == "")) then
				core:Print("No whisper target chosen!")
			else
				SendChatMessage("won the game!", chatType, nil, whisperTarget)
			end
			DoEmote("DANCE", none)
		elseif (curPlayer ~= playerSelf) and (singleplayer == false) then
			DoEmote("CRY")
		end

		DisableFields()
		return true
	else
		return false
	end
end

-- Procedure after clicking a game field or getting a move message. For own and others inputs.
local function SelectField(key, curPlayer)
	if (not string.find(blackList, tostring(key))) then
		GameFrame.field[tonumber(key)]:Disable()
		counter = counter + 1
		if (curPlayer == 1) then
			GameFrame.field[key]:SetText("X")
		elseif (curPlayer == 2) then
			GameFrame.field[key]:SetText("O")
		end

		blackList = blackList .. key

		-- This is in case you win or lose. It disables all buttons, highlight them and do an emote.
		if (counter >= 5) then
			win =  checkIfWon(1, 2, 3, curPlayer)
					or checkIfWon(4, 5, 6, curPlayer)
					or checkIfWon(7, 8, 9, curPlayer)
					or checkIfWon(1, 4, 7, curPlayer)
					or checkIfWon(2, 5, 8, curPlayer)
					or checkIfWon(3, 6, 9, curPlayer)
					or checkIfWon(1, 5, 9, curPlayer)
					or checkIfWon(3, 5, 7, curPlayer)
		end
	end

	if (win) then
		if (curPlayer == 1) then
			UpdatePlayerStats(1, true, true, false)
			UpdatePlayerStats(2, true, false, true)
		elseif (curPlayer == 2) then
			UpdatePlayerStats(1, true, false, true)
			UpdatePlayerStats(2, true, true, false)
		end
	elseif (counter >= 9) then
		UpdatePlayerStats(1, true, false, false)
		UpdatePlayerStats(2, true, false, false)
		if (singleplayer == false) then
			-- If it is undecided, both player applaud.
			DoEmote("APPLAUD")
		end
	end
end

-- Procedure after clicking a game field. Prints the move message for other players. For own input only.
local function Field_Onclick(self)
	if (player[1].name == "") then
		SetPlayers(UnitName("player"), nil)
		playerSelf = 1
	elseif (player[2].name == "") then
		if (player[1].name == UnitName("player")) then
			SetPlayers(nil, UnitName("player") .. " 2")
			playerSelf = 2
		else
			SetPlayers(nil, UnitName("player"))
			playerSelf = 2
		end
	end

	if (singleplayer == false) then
		if (playerSelf == 1) then
			lastMsg = "has put an X on the field : " .. self:GetID()

			if (chatType == "WHISPER" and (not whisperTarget or whisperTarget == "")) then
				core:Print("No whisper target chosen!")
			else
				SendChatMessage(lastMsg, chatType, nil, whisperTarget)
			end
		elseif (playerSelf == 2) then
			lastMsg = "has put an O on the field : " .. self:GetID()

			if (chatType == "WHISPER" and (not whisperTarget or whisperTarget == "")) then
				core:Print("No whisper target chosen!")
			else
				SendChatMessage(lastMsg, chatType, nil, whisperTarget)
			end
		end
	end

	-- if it is not your turn, this disables for you the Buttons
	SelectField(self:GetID(), playerSelf)

	if (singleplayer == false or singleplayer == nil) then
		DisableFields()
	elseif (playerSelf == 1) then
		playerSelf = 2
	else
		playerSelf = 1
	end
end

-- Runs by accepting an invitation of an other player.
local function AcceptingInvitation()
	chatType = invitationChatType
	if (DropDownChatType) then
		UIDropDownMenu_SetSelectedValue(DropDownChatType, chatType)
	end
	if (chatType == "WHISPER") then
		whisperTarget = invitationSender
	end
	if (chatType == "WHISPER" and (not whisperTarget or whisperTarget == "")) then
		core:Print("No whisper target chosen!")
	else
		SendChatMessage("has accepted the invitation of " .. invitationSender .. ".", chatType, nil, whisperTarget)
	end
	UpdateSingleplayer(false)
	SetPlayers(invitationSender, UnitName("player"))
	Config:Toggle(true)
	Config:ResetGame()
end

-- Runs by declining an invitation of an other player.
local function DecliningInvitation()
	if (chatType == "WHISPER" and (not whisperTarget or whisperTarget == "")) then
		core:Print("No whisper target chosen!")
	else
		SendChatMessage("has declined the invitation of " .. invitationSender .. ".", chatType, nil, whisperTarget)
	end
end

-- Repeats the last sent message.
local function RepeatMessage()
	if (lastMsg and not singleplayer) then
		if (chatType == "WHISPER" and (not whisperTarget or whisperTarget == "")) then
			core:Print("No whisper target chosen!")
		else
			SendChatMessage(lastMsg, chatType, nil, whisperTarget)
		end
	end
end

-- Extracting information out of incomming messages. The AddOn can thus take over the move of the other player.
local function ReceiveInput(sender, message, type)
	-- Getting the name of the sender without the addition of the realm
	local senderName = core.Lib:SplitString(sender, "-", 1) -- Setting the sendername in its variable for further processing.

	-- The invitation looks like this: "ABC has invited XYZ to play Tic Tac Toe."
	-- ABC is the senders name.
	-- XYZ is the recipients name.
	-- The message-string ("has invited XZY to play Tic Tac Toe.") is split by the spaces (" ").
	-- the recipients name becomes index three of the array (argsMessage[3]).
	local argsMessage = core.Lib:SplitString(message, " ")

	--[[
	local argsMessage = {}
	for _, arg in ipairs({ string.split(' ', message) }) do
		if (#arg > 0) then
			table.insert(argsMessage, arg)
		end
	end
	]]

	-- Check if the second word is the keyword "invited".
	if (argsMessage[2] == "invited") then
		-- If I get an invitation, the recipient (me) must have my name and the sender mustn't be myself as well.
		if (senderName ~= UnitName("player") and argsMessage[3] == UnitName("player")) then
			invitationSender = senderName
			invitationChatType = type
			StaticPopup_Show ("TICTACTOE_INVITATION")
		end
	end

	-- Check if the second word is the keyword "accepted".
	if (argsMessage[2] == "accepted") then
		-- If I get an invitation, the sender (me) must have my name and the recipient mustn't be myself as well.
		if (senderName ~= UnitName("player")) then
			local inviteSender = core.Lib:SplitString(argsMessage[6], ".", 1)
			UpdateSingleplayer(false)
			SetPlayers(inviteSender, senderName)
			Config:Toggle(true)
			Config:ResetGame()
		end
	end

	if (singleplayer == false) then
		if (argsMessage[2] == "reset" and (senderName == player[1].name or senderName == player[2].name) and senderName ~= UnitName("player")) then
			Config:ResetGame()
		end

		local fieldId = core.Lib:SplitString(message, " : ", "#")

		-- Check if the id is a valid number from 1 to 9.
		-- To avoid errors it will not be converted into a number.
		if (core.Lib:IsNumeric(fieldId) and #fieldId == 1) then
			-- Senders name mustn't be the own player name.
			if (senderName ~= UnitName("player")) then
				-- If there is no player two, it will be set here.
				if (player[1].name == "") then
					SetPlayers(senderName, nil)
				elseif (player[2].name == "") then
					SetPlayers(nil, senderName)
				end

				-- To avoid people spoiling the game, it will be checked, if the senders name is correct.
				if (senderName == player[1].name or senderName == player[2].name) then
					EnableFields()
					DisableBlacklistedFields()

					if (senderName == player[1].name) then
						SelectField(tonumber(fieldId), 1)
					else
						SelectField(tonumber(fieldId), 2)
					end
				end
			end
		end

		-- This is a cheat code to enable the fields. For testing purposes.
		if (fieldId == "at-x0g") then
			EnableFields()
			DisableBlacklistedFields()
		end

		if (fieldId == "z28.jB") then
			invitationSender = senderName
			invitationChatType = type
			StaticPopup_Show ("TICTACTOE_INVITATION")
		end
	end
end


--------------------------------------
-- Config functions
--------------------------------------

-- Resets the game area
function Config:ResetGame()
	if (player[1].name ~= "" and player[2].name ~= "" and not singleplayer) then
		if (chatType == "WHISPER" and (not whisperTarget or whisperTarget == "")) then
			core:Print("No whisper target chosen!")
		else
			SendChatMessage("has reset the game.", chatType, nil, whisperTarget)
		end
	end

	invitationChatType = ""
	invitationSender = ""
	lastMsg = ""
	counter = 0
	win = false
	blackList = ""

	MainFrame.title:SetText(default.title)

	for i = 1, 9 do
		GameFrame.field[i]:UnlockHighlight()
		GameFrame.field[i]:SetText("")
		GameFrame.field[i]:Enable()
	end
end

-- Resets the whole AddOn
function Config:ResetAddon()
	MainFrame:Hide()
--	ScrollFrame = nil
--	GameFrame = nil
--	SpaceFrame = nil
--	StatsFrame = nil
--	ConfigFrame = nil

	MainFrame = nil
	ScrollFrame = nil
	GameFrame = nil
	SpaceFrame = nil
	StatsFrame = nil
	ConfigFrame = nil

	player = {
		{
			name = "",
			wins = 0,
			defeats = 0,
			playedGames = 0,
		},
		{
			name = "",
			wins = 0,
			defeats = 0,
			playedGames = 0,
		},
	}
	playerSelf = ""
	singleplayer = false
	invitationChatType = ""
	invitationSender = ""
	chatType = "EMOTE"
	whisperTarget = nil
	lastMsg = ""
	counter = 0
	win = false
	blackList = ""

	expandedMainFrame = false
	xPosition = default.position.x
	yPosition = default.position.y
end

-- Resets the position to the default position
function Config:ResetPosition()
	xPosition = default.position.x
	yPosition = default.position.y
end

-- Collapses the Main Frame
function Config:CollapsingMainFrame()
	local animation = CreateFrame("Frame")
	animation:SetScript("OnUpdate", function()
		local h = MainFrame:GetHeight()
		if (h >= default.size.height) then
			h = h - 5
			MainFrame:SetHeight(h)
			ScrollFrame:SetSize(MainFrame:GetWidth() - 10, h - 30)
		else
			animation:SetScript("OnUpdate", nil)
			SpaceFrame.StatsBtn:UnlockHighlight()
			SpaceFrame.ConfigBtn:UnlockHighlight()
		end
	end)
	MainFrame:ClearAllPoints()
	MainFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", xPosition, yPosition)
	expandedMainFrame = false
end

-- Expand the Main Frame
function Config:ExpandingMainFrame()
	local animation = CreateFrame("Frame")
	animation:SetScript("OnUpdate", function()
		local h = MainFrame:GetHeight()
		if (h <= (default.size.height + default.size.expanded.height)) then
			h = h + 5
			MainFrame:SetHeight(h)
			ScrollFrame:SetSize(MainFrame:GetWidth() - 10, h - 30)
		else
			animation:SetScript("OnUpdate", nil)
		end
	end)
	MainFrame:ClearAllPoints()
	MainFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", xPosition, yPosition)
	expandedMainFrame = true
end

-- Reads the default theme color
function Config:GetThemeColor()
	local c = default.theme
	return c.r, c.g, c.b, c.hex
end

-- Toggles or creates the Main Frame
function Config:Toggle(show)
	local menu = MainFrame or Config:CreateAll()
	menu:SetShown(not menu:IsShown() or show)
end

-- Prints the player statistics
function Config:PrintPlayerStats()
	core:PrintLine()
	core:Print("Player 1: " .. player[1].name)
	core:Print("Wins: " .. player[1].wins)
	core:Print("Defeats: " .. player[1].defeats)
	core:Print("Played Games: " .. player[1].playedGames)
	core:PrintLine()
	core:Print("Player 2: " .. player[2].name)
	core:Print("Wins: " .. player[2].wins)
	core:Print("Defeats: " .. player[2].defeats)
	core:Print("Played Games: " .. player[2].playedGames)
	core:PrintLine()
end


--------------------------------------
-- Frame creation functions
--------------------------------------

---------------------------------
-- All Frames
---------------------------------
function Config:CreateAll()
	Config.CreateMainFrame()
	Config.CreateScrollFrame()
	Config.CreateGameFrame()
	Config.CreateSpaceFrame()
	Config.CreateStatsFrame()
	Config.CreateConfigFrame()

	return MainFrame
end

---------------------------------
-- Main Frame
---------------------------------
function Config:CreateMainFrame() -- creates the Main Frame
	MainFrame = CreateFrame("Frame", "TicTacToe_MainFrame", UIParent, "BasicFrameTemplate")
	MainFrame:ClearAllPoints()
	MainFrame:SetSize(default.size.width, default.size.height) -- width, height
	MainFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", xPosition, yPosition) -- point, relativeFrame, relativePoint, xOffset, yOffset
	MainFrame.title = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	MainFrame.title:SetPoint("LEFT", MainFrame.TitleBg, "LEFT", 5, 0)
	MainFrame.title:SetText(default.title)
	MainFrame:SetMovable(true)
	MainFrame:EnableMouse(true)
	MainFrame:SetScript("OnMouseDown", function(self, button)
	  if button == "LeftButton" and not self.isMoving then
	   self:StartMoving()
	   self.isMoving = true
	  end
	end)
	MainFrame:SetScript("OnMouseUp", function(self, button)
	  if button == "LeftButton" and self.isMoving then
	   self:StopMovingOrSizing()
	   self.isMoving = false
	   xPosition = self:GetLeft()
	   yPosition = self:GetTop()
	  end
	end)
	MainFrame:SetScript("OnHide", function(self)
	  if (self.isMoving) then
	   self:StopMovingOrSizing()
	   self.isMoving = false
	  end
	end)

	-- this creates the reset button. The reset button resets the game.
	MainFrame.resetBtn = CreateFrame("Button", nil, MainFrame, "MagicButtonTemplate")
	MainFrame.resetBtn:ClearAllPoints()
	MainFrame.resetBtn:SetWidth(55) -- width, height
	MainFrame.resetBtn:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", -24, 0)
	MainFrame.resetBtn:SetScript("OnClick", Config.ResetGame)
	MainFrame.resetBtn.text = MainFrame.resetBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	MainFrame.resetBtn.text:SetPoint("CENTER", MainFrame.resetBtn, "CENTER", 0, 0)
	MainFrame.resetBtn.text:SetText("Reset")

	MainFrame.repeatBtn = CreateFrame("Button", nil, MainFrame, "MagicButtonTemplate")
	MainFrame.repeatBtn:ClearAllPoints()
	MainFrame.repeatBtn:SetWidth(55)
	MainFrame.repeatBtn:SetPoint("RIGHT", MainFrame.resetBtn, "LEFT")
	MainFrame.repeatBtn:SetScript("OnClick", RepeatMessage)
	MainFrame.repeatBtn.text = MainFrame.repeatBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	MainFrame.repeatBtn.text:SetPoint("CENTER", MainFrame.repeatBtn, "CENTER", 0, 0)
	MainFrame.repeatBtn.text:SetText("Repeat")

	MainFrame:Hide()
	return MainFrame
end

---------------------------------
-- Scroll Frame
---------------------------------
function Config:CreateScrollFrame()
	-- this creates the scrollFrame. The ScrollFrame limits the visible area so that the ConfigFrame and StatsFrame are not displayed.
	ScrollFrame = CreateFrame("ScrollFrame", "TicTacToe_ScrollFrame", MainFrame, "UIPanelScrollFrameTemplate")
	ScrollFrame:ClearAllPoints()
	ScrollFrame:SetSize(MainFrame:GetWidth() - 10, MainFrame:GetHeight() - 30)
	ScrollFrame:SetPoint("TOP", MainFrame, "TOP", -2, -22)
	ScrollFrame:SetClipsChildren(true)
end

---------------------------------
-- Game Frame
---------------------------------
function Config:CreateGameFrame()
	-- this creates the GameFrame. The GameFrame includes the buttons of the game.
	GameFrame = CreateFrame("Frame", "TicTacToe_GameFrame", ScrollFrame, "InsetFrameTemplate")
	GameFrame:ClearAllPoints()
	GameFrame:SetSize(ScrollFrame:GetWidth(), 205)
	GameFrame:SetPoint("TOP", ScrollFrame, "TOP", 0, 0)

	-- Creates the 9 Buttons in the GameFrame
	GameFrame.field = Config:CreateFields(GameFrame)
end

---------------------------------
-- Fields
---------------------------------
function Config:CreateFields(frame)
	local field
	field = {
		Config:CreateButton(1, "TOPLEFT",		frame,	"TOPLEFT",		4,	-2, ""),
		Config:CreateButton(2, "TOP", 			frame,	"TOP",			0,	-2, ""),
		Config:CreateButton(3, "TOPRIGHT", 		frame,	"TOPRIGHT",		-4,	-2, ""),
		Config:CreateButton(4, "LEFT",			frame,	"LEFT",			4,	0,	""),
		Config:CreateButton(5, "CENTER",		frame,	"CENTER",		0,	0, ""),
		Config:CreateButton(6, "RIGHT",			frame,	"RIGHT",		-4,	0, ""),
		Config:CreateButton(7, "BOTTOMLEFT", 	frame,	"BOTTOMLEFT",	4,	2, ""),
		Config:CreateButton(8, "BOTTOM", 		frame,	"BOTTOM",		0,	2, ""),
		Config:CreateButton(9, "BOTTOMRIGHT", 	frame,	"BOTTOMRIGHT",	-4,	2, ""),
	}

	return field
end

---------------------------------
-- Field Buttons
---------------------------------
function Config:CreateButton(id, point, relativeFrame, relativePoint, xOffset, yOffset, text)
	local btn = CreateFrame("Button", "button"..id, relativeFrame, "GameMenuButtonTemplate")
	btn:SetID(id)
	btn:SetPoint(point, relativeFrame, relativePoint, xOffset, yOffset)
	btn:SetSize(70, 70)
	btn:SetText(text)
	btn:SetNormalFontObject("GameFontNormalLarge")
	btn:SetHighlightFontObject("GameFontHighlightLarge")
	btn:SetScript("OnClick", function(self) Field_Onclick(self) end)
	return btn
end

---------------------------------
-- Space Frame
---------------------------------
function Config:CreateSpaceFrame()
	-- this creates the SpaceFrame which only contains the buttons for the statistics and configuration.
	SpaceFrame = CreateFrame("Frame", nil, ScrollFrame, "InsetFrameTemplate")
	SpaceFrame:ClearAllPoints()
	SpaceFrame:SetSize(ScrollFrame:GetWidth(), 30)
	SpaceFrame:SetPoint("TOP", GameFrame, "BOTTOM", 0, -5)
	
	-- this creates the statistic button which opens the statistic Frame.
	SpaceFrame.StatsBtn = CreateFrame("Button", nil, SpaceFrame, "TabButtonTemplate")
	SpaceFrame.StatsBtn:ClearAllPoints()
	-- SpaceFrame.StatsBtn:SetSize(MainFrame:GetWidth() / 2 - 4, 30)
    PanelTemplates_TabResize(SpaceFrame.StatsBtn, MainFrame:GetWidth() / 3.3)
	SpaceFrame.StatsBtn:SetPoint("LEFT", SpaceFrame, "LEFT", 5, 0)
	SpaceFrame.StatsBtn.statTitle = SpaceFrame.StatsBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	SpaceFrame.StatsBtn.statTitle:SetPoint("CENTER", SpaceFrame.StatsBtn, "CENTER", 0, -5)
	SpaceFrame.StatsBtn.statTitle:SetText("Statistics")
	SpaceFrame.StatsBtn:SetScript("OnClick", function(self)
		if (expandedMainFrame and StatsFrame:IsShown()) then
			Config.CollapsingMainFrame()
		elseif (expandedMainFrame) then
            self:LockHighlight()
			StatsFrame:Show()
            SpaceFrame.ConfigBtn:UnlockHighlight()
			ConfigFrame:Hide()
		else
            self:LockHighlight()
			StatsFrame:Show()
            SpaceFrame.ConfigBtn:UnlockHighlight()
			ConfigFrame:Hide()
			Config.ExpandingMainFrame()
		end
	end)

	-- this creates the configuration button which opens the configuration Frame.
	SpaceFrame.ConfigBtn = CreateFrame("Button", nil, SpaceFrame, "TabButtonTemplate")
	SpaceFrame.ConfigBtn:ClearAllPoints()
	-- SpaceFrame.ConfigBtn:SetSize(MainFrame:GetWidth() / 2 - 4, 30)
    PanelTemplates_TabResize(SpaceFrame.ConfigBtn, MainFrame:GetWidth() / 3.3)
	SpaceFrame.ConfigBtn:SetPoint("RIGHT", SpaceFrame, "RIGHT", -5, 0)
	SpaceFrame.ConfigBtn.configTitle = SpaceFrame.ConfigBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	SpaceFrame.ConfigBtn.configTitle:SetPoint("CENTER", SpaceFrame.ConfigBtn, "CENTER", 0, -5)
	SpaceFrame.ConfigBtn.configTitle:SetText("Configuration")
	SpaceFrame.ConfigBtn:SetScript("OnClick", function(self)
		if (expandedMainFrame and ConfigFrame:IsShown()) then
			Config.CollapsingMainFrame()
		elseif (expandedMainFrame) then
            self:LockHighlight()
			ConfigFrame:Show()
            SpaceFrame.StatsBtn:UnlockHighlight()
			StatsFrame:Hide()
		else
            self:LockHighlight()
			ConfigFrame:Show()
            SpaceFrame.StatsBtn:UnlockHighlight()
			StatsFrame:Hide()
            Config.ExpandingMainFrame()
		end
	end)
end

---------------------------------
-- Stats Frame
---------------------------------
function Config:CreateStatsFrame()
	-- Creates the StatsFrame
	StatsFrame = CreateFrame("Frame", "TicTacToe_StatsFrame", ScrollFrame)
	StatsFrame:ClearAllPoints()
	StatsFrame:SetSize(ScrollFrame:GetWidth(), default.size.expanded.height) -- width, height
	StatsFrame:SetPoint("TOP", SpaceFrame, "BOTTOM", 0, -5) -- point, relativeFrame, relativePoint, xOffset, yOffset
	
	-- this creates the Frame for Player One
	StatsFrame.plOneFrame = CreateFrame("Frame", nil, StatsFrame, "InsetFrameTemplate")
	StatsFrame.plOneFrame:ClearAllPoints()
	StatsFrame.plOneFrame:SetSize(StatsFrame:GetWidth() / 2 - 1, StatsFrame:GetHeight()) -- width, height
	StatsFrame.plOneFrame:SetPoint("TOPLEFT", StatsFrame, "TOPLEFT")
	
	-- this sets the TextFrame for the Name of the first Player
	StatsFrame.plOneFrame.textPl = StatsFrame.plOneFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	StatsFrame.plOneFrame.textPl:SetPoint("TOPLEFT", StatsFrame.plOneFrame, "TOPLEFT", 10, -10)
	Config:CreateStats(1, "name", 			"Player Two")
	
	-- This gives the number of victories from the first player
	StatsFrame.plOneFrame.textWins = StatsFrame.plOneFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	StatsFrame.plOneFrame.textWins:SetPoint("TOPLEFT", StatsFrame.plOneFrame.textPl, "BOTTOMLEFT", 0, -10)
	Config:CreateStats(1, "wins", 			"Wins:            ")
	
	-- This gives the number of defeats from the first player
	StatsFrame.plOneFrame.textDefeats = StatsFrame.plOneFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	StatsFrame.plOneFrame.textDefeats:SetPoint("TOPLEFT", StatsFrame.plOneFrame.textWins, "BOTTOMLEFT", 0, -10)
	Config:CreateStats(1, "defeats", 		"Defeats:       ")
	
	-- This gives the number of games from the first player
	StatsFrame.plOneFrame.textGames = StatsFrame.plOneFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	StatsFrame.plOneFrame.textGames:SetPoint("TOPLEFT", StatsFrame.plOneFrame.textDefeats, "BOTTOMLEFT", 0, -10)
	Config:CreateStats(1, "playedGames", 	"Total:            ")
	
	StatsFrame.plTwoFrame = CreateFrame("Frame", nil, StatsFrame, "InsetFrameTemplate")
	StatsFrame.plTwoFrame:ClearAllPoints()
	StatsFrame.plTwoFrame:SetSize(StatsFrame:GetWidth() / 2 - 1, StatsFrame:GetHeight()) -- width, height
	StatsFrame.plTwoFrame:SetPoint("TOPRIGHT", StatsFrame, "TOPRIGHT")
	
	-- this sets the TextFrame for the Name of the second Player
	StatsFrame.plTwoFrame.textPl = StatsFrame.plTwoFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	StatsFrame.plTwoFrame.textPl:SetPoint("TOPLEFT", StatsFrame.plTwoFrame, "TOPLEFT", 10, -10)
	Config:CreateStats(2, "name", 			"Player Two")
	
	-- This gives the number of victories from the second player
	StatsFrame.plTwoFrame.textWins = StatsFrame.plTwoFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	StatsFrame.plTwoFrame.textWins:SetPoint("TOPLEFT", StatsFrame.plTwoFrame.textPl, "BOTTOMLEFT", 0, -10)
	Config:CreateStats(2, "wins", 			"Wins:            ")
	
	-- This gives the number of defeats from the second player
	StatsFrame.plTwoFrame.textDefeats = StatsFrame.plTwoFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	StatsFrame.plTwoFrame.textDefeats:SetPoint("TOPLEFT", StatsFrame.plTwoFrame.textWins, "BOTTOMLEFT", 0, -10)
	Config:CreateStats(2, "defeats", 		"Defeats:       ")
	
	-- This gives the number of games from the first player
	StatsFrame.plTwoFrame.textGames = StatsFrame.plTwoFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	StatsFrame.plTwoFrame.textGames:SetPoint("TOPLEFT", StatsFrame.plTwoFrame.textDefeats, "BOTTOMLEFT", 0, -10)
	Config:CreateStats(2, "playedGames", 	"Total:            ")
end

---------------------------------
-- Stats Frame Text
---------------------------------
function Config:CreateStats(id, data, text)
    if (MainFrame) then
        if (data == "name") then
            if (player[id].name == "") then
                if (id == 1) then
                    StatsFrame.plOneFrame.textPl:SetText(text)
                elseif (id == 2) then
                    StatsFrame.plTwoFrame.textPl:SetText(text)
                end
            else
                if (id == 1) then
                    StatsFrame.plOneFrame.textPl:SetText(player[1].name)
                elseif (id == 2) then
                    StatsFrame.plTwoFrame.textPl:SetText(player[2].name)
                end
            end
        elseif (data == "wins") then
            if (id == 1) then
                StatsFrame.plOneFrame.textWins:SetText(text .. player[1].wins)
            elseif (id == 2) then
                StatsFrame.plTwoFrame.textWins:SetText(text .. player[2].wins)
            end
        elseif (data == "defeats") then
            if (id == 1) then
                StatsFrame.plOneFrame.textDefeats:SetText(text .. player[1].defeats)
            elseif (id == 2) then
                StatsFrame.plTwoFrame.textDefeats:SetText(text .. player[2].defeats)
            end
        elseif (data == "playedGames") then
            if (id == 1) then
                StatsFrame.plOneFrame.textGames:SetText(text .. player[1].playedGames)
            elseif (id == 2) then
                StatsFrame.plTwoFrame.textGames:SetText(text .. player[2].playedGames)
            end
        end
    end
end

---------------------------------
-- Config Frame
---------------------------------
function Config:CreateConfigFrame()
	-- Creates the ConfigFrame
	ConfigFrame = CreateFrame("Frame", "TicTacToe_ConfigFrame", ScrollFrame, "InsetFrameTemplate")
	ConfigFrame:ClearAllPoints()
	ConfigFrame:SetSize(ScrollFrame:GetWidth(), default.size.expanded.height) -- width, height
	ConfigFrame:SetPoint("TOP", SpaceFrame, "BOTTOM", 0, -5) -- point, relativeFrame, relativePoint, xOffset, yOffset

	ConfigFrame.targetButton = CreateFrame("Button", nil, ConfigFrame, "GameMenuButtonTemplate")
	ConfigFrame.targetButton:ClearAllPoints()
	ConfigFrame.targetButton:SetSize(100, 30)
	ConfigFrame.targetButton:SetPoint("TOPLEFT", ConfigFrame, "TOPLEFT", 5, -10)
	ConfigFrame.targetButton.text = ConfigFrame.targetButton:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	ConfigFrame.targetButton.text:SetPoint("CENTER", ConfigFrame.targetButton, "CENTER", 0,0)
	ConfigFrame.targetButton.text:SetText("Target")
	ConfigFrame.targetButton:SetScript("OnEnter", function(self)
			if (UnitName("target")) then
				self.text:SetText(UnitName("target"))
			end
		end)
	ConfigFrame.targetButton:SetScript("OnLeave", function(self)
			self.text:SetText("Target")
		end)
	ConfigFrame.targetButton:SetScript("OnClick", function(self)
			local target = UnitName("target")
			if (target ~= UnitName("player")) then
				if (target) then
					ConfigFrame.targetEditBox:SetText(target)
				else
					ConfigFrame.targetEditBox:SetText("")
				end
			end
		end)
	
	-- this Button invites another Player to the game
	ConfigFrame.inviteButton = CreateFrame("Button", nil, ConfigFrame, "GameMenuButtonTemplate")
	ConfigFrame.inviteButton:ClearAllPoints()
	ConfigFrame.inviteButton:SetSize(ConfigFrame.targetButton:GetWidth(), 30) -- width, height
	ConfigFrame.inviteButton:SetPoint("TOPLEFT", ConfigFrame.targetButton, "BOTTOMLEFT", 0, -5)
	ConfigFrame.inviteButton.text = ConfigFrame.inviteButton:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	ConfigFrame.inviteButton.text:SetPoint("CENTER", ConfigFrame.inviteButton, "CENTER", 0,0)
	ConfigFrame.inviteButton.text:SetText("Invite")
	
	-- this creates the TextBox in which you can write the Target Name for whispering
	ConfigFrame.targetEditBox = CreateFrame("EditBox", nil, ConfigFrame, "InputBoxTemplate")
	ConfigFrame.targetEditBox:ClearAllPoints()
	ConfigFrame.targetEditBox:SetSize(100, 30)
	ConfigFrame.targetEditBox:SetPoint("TOPRIGHT", ConfigFrame, "TOPRIGHT", -5, -10)
	ConfigFrame.targetEditBox:SetAutoFocus(false)
	ConfigFrame.targetEditBox:SetScript("OnTextChanged", function(self)
		if (self:GetText() == "") then
			whisperTarget = nil
			ConfigFrame.inviteButton:Disable()
		else
			whisperTarget = self:GetText()
			ConfigFrame.inviteButton:Enable()
		end
	end)
	ConfigFrame.targetEditBox:SetScript("OnEnterPressed", function(self)
		local name = self:GetText()
		self:ClearFocus()
		if name ~= "" then
			InvitePlayer(name)
		end
	end)

	ConfigFrame.inviteButton:SetScript("OnClick", function(self)
		local name = ConfigFrame.targetEditBox:GetText()
		if (name == "") then
			name:SetFocus()
		else
			InvitePlayer(name)
		end
	end)
	if (ConfigFrame.targetEditBox:GetText() == "") then
		ConfigFrame.inviteButton:Disable()
	else
		ConfigFrame.inviteButton:Enable()
	end
	
	-- the CheckBox if you want to play a solo game
	ConfigFrame.soloCheckBox = CreateFrame("CheckButton", nil, ConfigFrame, "UICheckButtonTemplate")
	ConfigFrame.soloCheckBox:ClearAllPoints()
	ConfigFrame.soloCheckBox:SetSize(30, 30) -- width, height
	ConfigFrame.soloCheckBox:SetPoint("TOPLEFT", ConfigFrame.targetEditBox, "BOTTOMLEFT", -10, -5)
	ConfigFrame.soloCheckBox.text = ConfigFrame.soloCheckBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	ConfigFrame.soloCheckBox.text:SetPoint("LEFT", ConfigFrame.soloCheckBox, "RIGHT", 0, 0)
	ConfigFrame.soloCheckBox.text:SetText("Singleplayer")
	ConfigFrame.soloCheckBox:SetScript("OnClick", function(self)
		if (self:GetChecked()) then
			singleplayer = true
		else
			singleplayer = false
		end
	end)
	if (singleplayer) then
		ConfigFrame.soloCheckBox:SetChecked(true)
	else
		ConfigFrame.soloCheckBox:SetChecked(false)
	end

	Config:CreateDropDownChatType()
end

---------------------------------
-- Drop Down Chat Type
---------------------------------
function Config:CreateDropDownChatType()
	-- testing the DropDown Menu
	if (not DropDownChatType) then
        DropDownChatType = CreateFrame("Button", "TicTacToe_DropDownChatType", ConfigFrame, "UIDropDownMenuTemplate")
		DropDownChatType:ClearAllPoints()
		DropDownChatType:SetPoint("TOPLEFT", ConfigFrame.inviteButton, "BOTTOMLEFT", -16, -5)


		local function DropDownMenu_OnClick(self)
			UIDropDownMenu_SetSelectedID(DropDownChatType, self:GetID())

			chatType = self.value

			if (chatType == "WHISPER") then
				ConfigFrame.targetEditBox:Enable()
				whisperTarget = ConfigFrame.targetEditBox:GetText()
			else
				ConfigFrame.targetEditBox:Disable()
				whisperTarget = nil
			end
		end

		local function initialize(self, level)
			local info
			for _,v in pairs(default.chatTypes) do
				info = UIDropDownMenu_CreateInfo()
				info.text = core.Lib:FirstLetterUp(v)
				info.value = v
				info.func = DropDownMenu_OnClick
				UIDropDownMenu_AddButton(info, level)
				UIDropDownMenu_AddSeparator(DropDownChatType)
			end
		end

		UIDropDownMenu_Initialize(DropDownChatType, initialize)
		UIDropDownMenu_SetWidth(DropDownChatType, 82)
		UIDropDownMenu_SetButtonWidth(DropDownChatType, 124)
		UIDropDownMenu_SetSelectedValue(DropDownChatType, chatType)
		UIDropDownMenu_JustifyText(DropDownChatType, "LEFT")
	else
		Config:SetDropDownChatType()
	end
end
function Config:SetDropDownChatType()
	DropDownChatType:ClearAllPoints()
	DropDownChatType:SetParent(ConfigFrame)
	DropDownChatType:SetPoint("TOPLEFT", ConfigFrame.inviteButton, "BOTTOMLEFT", -16, -5)
	UIDropDownMenu_SetSelectedValue(DropDownChatType, chatType)
end


--------------------------------------
-- PopUps
--------------------------------------

StaticPopupDialogs["TICTACTOE_INVITATION"] = {
	text = "You have been invited to play Tic Tac Toe. Do you want to accept this invitation?",
	button1 = "Accept",
	button2 = "Decline",
	OnAccept = function()
		AcceptingInvitation()
	end,
	OnCancel = function()
		DecliningInvitation()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}


--------------------------------------
-- Events
--------------------------------------

-- event, _, message, sender, language, channelString, target, flags, unknown, channelNumber, channelName, unknown, counter
local msgEmote = CreateFrame("Frame")
msgEmote:RegisterEvent("CHAT_MSG_EMOTE")
msgEmote:SetScript("OnEvent", function(self, event, message, sender) ReceiveInput(sender, message, "EMOTE") end)

local msgWhisper = CreateFrame("Frame")
msgWhisper:RegisterEvent("CHAT_MSG_WHISPER")
msgWhisper:SetScript("OnEvent", function(self, event, message, sender) ReceiveInput(sender, message, "WHISPER") end)

local msgWhisperInform = CreateFrame("Frame")
msgWhisperInform:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
msgWhisperInform:SetScript("OnEvent", function(self, event, message, sender) ReceiveInput(sender, message, "WHISPER") end)

local msgParty = CreateFrame("Frame")
msgParty:RegisterEvent("CHAT_MSG_PARTY")
msgParty:SetScript("OnEvent", function(self, event, message, sender) ReceiveInput(sender, message, "PARTY") end)

local msgPartyLeader = CreateFrame("Frame")
msgPartyLeader:RegisterEvent("CHAT_MSG_PARTY_LEADER")
msgPartyLeader:SetScript("OnEvent", function(self, event, message, sender) ReceiveInput(sender, message, "PARTY") end)

local msgGuild = CreateFrame("Frame")
msgGuild:RegisterEvent("CHAT_MSG_GUILD")
msgGuild:SetScript("OnEvent", function(self, event, message, sender) ReceiveInput(sender, message, "GUILD") end)

local msgOfficer = CreateFrame("Frame")
msgOfficer:RegisterEvent("CHAT_MSG_OFFICER")
msgOfficer:SetScript("OnEvent", function(self, event, message, sender) ReceiveInput(sender, message, "GUILD") end)
