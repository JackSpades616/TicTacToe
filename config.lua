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
		"RAID",
        "GUILD",
	},
	
	singlePlayerModes = {
		"self",
		"easy",
		"medium",
	},
}


--------------------------------------
-- Initializing Variables
--------------------------------------

local MainFrame
local HelpFrame
local ScrollFrame
local GameFrame
local SpaceFrame
local StatsFrame
local ConfigFrame
local mainHelpButton
local DropDownChatType
local DropDownSinglePlayerMode

local xPosition = default.position.x
local yPosition = default.position.y

local player = {
	{
		name = "",
		wins = 0,
		defeats = 0,
		total = 0,
	},
	{
		name = "",
		wins = 0,
		defeats = 0,
		total = 0,
	},
}
local playerSelf = 0
local singleplayer = true
local invitationChatType = ""
local invitationSender = ""
local chatType = "EMOTE"
local whisperTarget = nil
local lastMsg = ""
local invitationSent = false
local singlePlayerMode = "medium"

local counter = 0
local beginner = 0
local win = false
local blackList = ""
local cheatUsed = false

local expandedMainFrame = false

local TicTacToe_HelpPlate = {
	FramePos = { 
		x = 0,	
		y = 0
	},
	FrameSize = { 
		width = default.size.width, 
		height = default.size.height	
	},
	[1] = { 
		ButtonPos = { 
			x = ((default.size.width - 10) / 2) -20 ,	
			y = -(205 / 2)}, 
		HighLightBox = { 
			x = 4, 
			y = -22, 
			width = default.size.width -10, 
			height = 205 }, 
			ToolTipDir = "DOWN", 
			ToolTipText = "Test"
		},
	[2] = { 
		ButtonPos = { 
			x = default.size.width - 105 ,	
			y = 12}, 
		HighLightBox = { 
			x = default.size.width - 134, 
			y = 0, 
			width = 110, 
			height = 24}, 
			ToolTipDir = "UP", 
			ToolTipText = "Test"
		},
	[3] = { 
		ButtonPos = { 
			x = 60,	
			y = - (default.size.height) + 45}, 
		HighLightBox = { 
			x = 30, 
			y = - (default.size.height) + 15, 
			width = default.size.width / 2 -10, 
			height = 24}, 
			ToolTipDir = "LEFT", 
			ToolTipText = "Test"
		},
	[4] = { 
		ButtonPos = { 
			x = 130 + 35 / 2,	
			y = - (default.size.height) + 45}, 
		HighLightBox = { 
			x = 115, 
			y = - (default.size.height) + 35, 
			width = default.size.width / 2 -10, 
			height = 24}, 
			ToolTipDir = "RIGHT", 
			ToolTipText = "Test"
		},
	
}

--------------------------------------
-- Functions
--------------------------------------

-- Updates the statistics in the statistic frame.
local function UpdateStatsFrame(id)
	if (StatsFrame) then
		Config:CreateStats(id, "name", StatsFrame.player[id].name)
		Config:CreateStats(id, "wins", StatsFrame.player[id].wins)
		Config:CreateStats(id, "defeats", StatsFrame.player[id].defeats)
		Config:CreateStats(id, "total", StatsFrame.player[id].total)
	end
end

-- Updates the players statistics by adding 1 to any of the fields.
local function UpdatePlayerStats(id, total, win, lose)
	if (win) then player[id].wins = player[id].wins + 1 end
	if (lose) then player[id].defeats = player[id].defeats + 1 end
	if (total) then player[id].total = player[id].total + 1 end
	UpdateStatsFrame(id)
end

-- Initializes the players.
local function SetPlayer(id, name, wins, defeats, total)
	if (id) then
		player[id].name = name or ""
		player[id].wins = wins or 0
		player[id].defeats = defeats or 0
		player[id].total = total or 0

		if (player[id].name == UnitName("player")) then
			playerSelf = id
		end

		UpdateStatsFrame(id)
	end
end

local function SetBothPlayers(newOne, newTwo)
	local oldOne = {
		name = player[1].name,
		wins = player[1].wins,
		defeats = player[1].defeats,
		total = player[1].total
	}

	local oldTwo = {
		name = player[2].name,
		wins = player[2].wins,
		defeats = player[2].defeats,
		total = player[2].total
	}

	if (newOne == oldOne.name) then
		SetPlayer(1, oldOne.name, oldOne.wins, oldOne.defeats, oldOne.total)
	elseif (newOne == oldTwo.name) then
		SetPlayer(1, oldTwo.name, oldTwo.wins, oldTwo.defeats, oldTwo.total)
	else
		SetPlayer(1, newOne)
	end

	if (newTwo == oldOne.name) then
		SetPlayer(2, oldOne.name, oldOne.wins, oldOne.defeats, oldOne.total)
	elseif (newTwo == oldTwo.name) then
		SetPlayer(2, oldTwo.name, oldTwo.wins, oldTwo.defeats, oldTwo.total)
	else
		SetPlayer(2, newTwo)
	end
end

local function ClearPlayer(id, other)
	if (other) then
		if (singleplayer) then
			if (singlePlayerMode == "self") then
				SetPlayer(id, UnitName("player") .. " 2")
			else
				SetPlayer(id, "AI " .. core.Lib:FirstLetterUp(singlePlayerMode))
			end
		else
			SetPlayer(id)
		end
	else
		SetPlayer(id)
	end
end

-- Disables all buttons.
local function DisableFields()
	if (GameFrame) then
		for i = 1, #GameFrame.field do
			GameFrame.field[i]:Disable()
		end
	end
end

-- Disables the black listed Fields.
local function DisableBlacklistedFields()
	if (GameFrame) then
		for i = 1, #blackList do
			local c = blackList:sub(i,i)
			GameFrame.field[tonumber(c)]:Disable()
		end
	end
end

-- Enables all buttons.
local function EnableFields()
	if (GameFrame) then
		for i = 1, #GameFrame.field do
			GameFrame.field[i]:Enable()
		end
	end
end

-- Invites an other player.
local function InvitePlayer(name)
	if (chatType == "WHISPER" and (not whisperTarget or whisperTarget == "")) then
		core:Print("No whisper target chosen!")
	else
		SendChatMessage("has invited " ..name.. " to play Tic Tac Toe.", chatType, nil, whisperTarget)
	end

	invitationSent = true
	ConfigFrame.inviteButton:LockHighlight()
	C_Timer.After(30, function(self)
		invitationSent = false
		ConfigFrame.inviteButton:UnlockHighlight()
	end)
end

-- Check if a player has won.
local function checkIfWon(frst, scnd, thrd, curPlayer)
	if ((GameFrame.field[frst]:GetText() == GameFrame.field[scnd]:GetText()) and (GameFrame.field[frst]:GetText() == GameFrame.field[thrd]:GetText()) and (GameFrame.field[frst]:GetText() ~= nil)) then
		GameFrame.field[frst]:LockHighlight()
		GameFrame.field[scnd]:LockHighlight()
		GameFrame.field[thrd]:LockHighlight()
		if (player[1].name ~= UnitName("player") and player[2].name ~= UnitName("player")) then
			DoEmote("APPLAUD", "none")
		elseif (curPlayer == playerSelf) and (singleplayer == false) then
			if (chatType == "WHISPER" and (not whisperTarget or whisperTarget == "")) then
				core:Print("No whisper target chosen!")
			else
				SendChatMessage("won the game!", chatType, nil, whisperTarget)
			end
			DoEmote("LAUGH", "none")
		elseif (curPlayer ~= playerSelf) and (singleplayer == false) and playerSelf then
			if (player[playerSelf].name == UnitName("player")) then
				DoEmote("CRY", "none")
			end
		end


		DisableFields()
		return true
	else
		return false
	end
end

-- Procedure after clicking a game field or getting a move message. For own and others inputs.
local function SelectField(key, curPlayer)
	if ((not string.find(blackList, tostring(key)) or cheatUsed) and GameFrame) then
		GameFrame.field[tonumber(key)]:Disable()
		counter = counter + 1
		if (curPlayer == 1) then
			GameFrame.field[key]:SetText("X")
		elseif (curPlayer == 2) then
			GameFrame.field[key]:SetText("O")
		end

		if (counter == 1) then
			beginner = curPlayer
		end

		blackList = blackList .. key
	end

	-- This is in case you win or lose. It disables all buttons, highlight them and do an emote.
	if (counter >= 3) then
		win =  checkIfWon(1, 2, 3, curPlayer)
				or checkIfWon(4, 5, 6, curPlayer)
				or checkIfWon(7, 8, 9, curPlayer)
				or checkIfWon(1, 4, 7, curPlayer)
				or checkIfWon(2, 5, 8, curPlayer)
				or checkIfWon(3, 6, 9, curPlayer)
				or checkIfWon(1, 5, 9, curPlayer)
				or checkIfWon(3, 5, 7, curPlayer)
	end
	
	if (win) then
		if (curPlayer == 1) then
			UpdatePlayerStats(1, true, true, false)
			UpdatePlayerStats(2, true, false, true)
		elseif (curPlayer == 2) then
			UpdatePlayerStats(1, true, false, true)
			UpdatePlayerStats(2, true, true, false)
		end
	elseif (#blackList >= 9) then
		UpdatePlayerStats(1, true, false, false)
		UpdatePlayerStats(2, true, false, false)
		if (singleplayer == false) then
			-- If it is undecided, both player applaud.
			DoEmote("APPLAUD", "none")
		end
	end

	if (win or #blackList >= 9) then
		C_Timer.After(2, function(self)
			if (singleplayer and singlePlayerMode == "self") then
				Config:ResetGame(false, false)
			elseif (singleplayer and playerSelf == beginner) then
				Config:ResetGame(true, true)
			elseif (singleplayer) then
				Config:ResetGame(false, false)
			elseif (playerSelf == beginner) then
				Config:ResetGame(true, false)
			else
				Config:ResetGame(false, false)
			end
		end)
	end
end

--------------------------------------
-- AI
--------------------------------------

local function CheckLine(frst, scnd, thrd, value)
	local key
	if ((GameFrame.field[frst]:GetText() == value) and (GameFrame.field[scnd]:GetText() == value) and (GameFrame.field[thrd]:GetText() == nil)) then
		key = thrd
	elseif ((GameFrame.field[frst]:GetText() == value) and (GameFrame.field[scnd]:GetText() == nil) and (GameFrame.field[thrd]:GetText() == value)) then
		key = scnd
	elseif ((GameFrame.field[frst]:GetText() == nil) and (GameFrame.field[scnd]:GetText() == value) and (GameFrame.field[thrd]:GetText() == value)) then
		key = frst
	end
	
	return key
end

local function CheckAllLines(value)
	local key
	key = CheckLine(1, 2, 3, value)
		or CheckLine(4, 5, 6, value)
		or CheckLine(7, 8, 9, value)
		or CheckLine(1, 4, 7, value)
		or CheckLine(2, 5, 8, value)
		or CheckLine(3, 6, 9, value)
		or CheckLine(1, 5, 9, value)
		or CheckLine(3, 5, 7, value)
	return key
end

local function AIInput(mode)
	mode = mode or singlePlayerMode
	local key
	local valid = false

	if (player[1].name == "") then
		SetPlayer(1, "AI " .. core.Lib:FirstLetterUp(singlePlayerMode))
	elseif (player[2].name == "") then
		SetPlayer(2, "AI " .. core.Lib:FirstLetterUp(singlePlayerMode))
	end

	if (mode == "easy") then
		while (not valid) do
			if (#blackList < 9) then
				key = random(1, 9)
			else
				valid = true
			end
			if (not string.find(blackList, tostring(key))) then
				valid = true
			end
		end
	elseif (mode == "medium") then
		key = CheckAllLines("O") or CheckAllLines("X")
		if (not key) then
			while (not valid) do
				if (#blackList < 9) then
					key = random(1, 9)
				else
					valid = true
				end
				if (not string.find(blackList, tostring(key))) then
					valid = true
				end
			end
		end
	elseif (mode == "hard") then

	end
	if ((not win) and #blackList < 9) then
		SelectField(key, 2)
		if ((not win) and #blackList < 9) then
			EnableFields()
			DisableBlacklistedFields()
		end
	end
end

-- Procedure after clicking a game field. Prints the move message for other players. For own input only.
local function Field_Onclick(self)
	if (player[1].name == "") then
		if (player[2].name == UnitName("player")) then
			SetPlayer(1, UnitName("player") .. " 2")
		else
			SetPlayer(1, UnitName("player"))
		end
	elseif (player[2].name == "") then
		if (player[1].name == UnitName("player")) then
			SetPlayer(2, UnitName("player") .. " 2")
		else
			SetPlayer(2, UnitName("player"))
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

	if (singleplayer) then
		if (singlePlayerMode == "self") then
			if (playerSelf == 1) then
				playerSelf = 2
			else
				playerSelf = 1
			end
		else
			DisableFields()
			C_Timer.After(1, AIInput)
		end
	else
		DisableFields()
	end
end

-- Runs by accepting an invitation of an other player.
local function AcceptingInvitation()
	Config:Toggle(true)
	chatType = invitationChatType
	-- if (DropDownChatType) then UIDropDownMenu_SetSelectedValue(DropDownChatType, chatType) end
	Config:UpdateSingleplayer(false)

	if (chatType == "WHISPER") then
		whisperTarget = invitationSender
	end
	if (chatType == "WHISPER" and (not whisperTarget or whisperTarget == "")) then
		core:Print("No whisper target chosen!")
	else
		SendChatMessage("has accepted the invitation of " .. invitationSender .. ".", chatType, nil, whisperTarget)
	end

	SetBothPlayers(invitationSender, UnitName("player"))
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

	-- Check if the second word is the keyword "invited".
	if (argsMessage[2] == "invited") then
		-- If I get an invitation, the recipient (me) must have my name and the sender mustn't be myself as well.
		if (senderName ~= UnitName("player") and argsMessage[3] == UnitName("player")) then
			invitationSender = senderName
			invitationChatType = type
			StaticPopup_Show ("TICTACTOE_INVITATION")
			C_Timer.After(30, function(self) StaticPopup_Hide ("TICTACTOE_INVITATION") end)
		end
	end

	-- Check if the second word is the keyword "accepted".
	if (argsMessage[2] == "accepted" and (invitationSent)) then
		-- If I get an invitation, the sender (me) must have my name and the recipient mustn't be myself as well.
		if (senderName ~= UnitName("player")) then
			Config:Toggle(true)
			invitationSent = false
			ConfigFrame.inviteButton:UnlockHighlight()

			local inviteSender = core.Lib:SplitString(argsMessage[6], ".", 1)

			-- if (DropDownChatType) then UIDropDownMenu_SetSelectedValue(DropDownChatType, chatType) end
			Config:UpdateSingleplayer(false)

			SetBothPlayers(inviteSender, senderName)
			Config:ResetGame()
		end
	end

	-- Check if the second word is the keyword "declined".
	if (argsMessage[2] == "declined" and (invitationSent)) then
		-- If I get an invitation, the sender (me) must have my name and the recipient mustn't be myself as well.
		if (senderName ~= UnitName("player")) then
			invitationSent = false
			ConfigFrame.inviteButton:UnlockHighlight()
		end
	end

	if (singleplayer == false) then
		if (argsMessage[2] == "reset" and (senderName == player[1].name or senderName == player[2].name) and senderName ~= UnitName("player")) then
			Config:ResetGame()
		end

		local mark
		if ((argsMessage[2] == "put") and (argsMessage[4] == "X" or "O")) then
			mark = argsMessage[4]
		end

		local fieldId = core.Lib:SplitString(message, " : ", "#")

		-- Check if the id is a valid number from 1 to 9.
		-- To avoid errors it will not be converted into a number.
		if (core.Lib:IsNumeric(fieldId) and #fieldId == 1) then
			-- Senders name mustn't be the own player name.
			if (senderName ~= UnitName("player")) then
				-- If there is no player two, it will be set here.
				if (player[1].name == "" and mark == "X") then
					SetPlayer(1, senderName)
				elseif (player[2].name == "" and mark == "O") then
					SetPlayer(2, senderName)
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
	end

	--------------------------------------
	-- Cheat Codes ;)
	--------------------------------------

	-- This cheat code lets you place your sign wherever you want. Even on your oponents fields.
	if (argsMessage[1] == "doesn't" and argsMessage[2] == "even" and argsMessage[3] == "care.") then
		cheatUsed = true
		if (senderName == UnitName("player")) then
			EnableFields()
		end
	end

	if (senderName == UnitName("player")) then
		-- This cheat code lets you make a move before the oponent has done that himself.
		if (argsMessage[1] == "is" and argsMessage[2] == "getting" and argsMessage[3] == "really" and argsMessage[4] == "bored.") then
			EnableFields()
			DisableBlacklistedFields()
		end

		-- This cheat code lets you invite yourself. Once for testing purposes. Perhaps you find some use to it...
		if (argsMessage[1] == "likes" and argsMessage[2] == "to" and argsMessage[3] == "play" and argsMessage[4] == "with" and argsMessage[5] == "himself.") then
			invitationSender = senderName
			invitationChatType = type
			StaticPopup_Show ("TICTACTOE_INVITATION")
		end
	end
end


--------------------------------------
-- Config functions
--------------------------------------

function Config:UpdateHelpPlate()
	TicTacToe_HelpPlate = {
		FramePos = {
			x = 0,
			y = 0
		},
		FrameSize = {
			width = MainFrame:GetWidth(),
			height = MainFrame:GetHeight()
		},
		[1] = {
			ButtonPos = {
				-- The button has a size of 46 * 46. The '+/- 23' is used to find the center of the button.
				-- core.Lib:GetCenter(get, frame)
				x = core.Lib:GetCenter("x", GameFrame) - MainFrame:GetLeft() - 23,
				y = core.Lib:GetCenter("y", GameFrame) - MainFrame:GetTop() + 23
			},
			HighLightBox = {
				x = GameFrame:GetLeft() - MainFrame:GetLeft(),
				y = GameFrame:GetTop() - MainFrame:GetTop(),
				width = GameFrame:GetWidth(),
				height = GameFrame:GetHeight()
			},
			ToolTipDir = "DOWN",
			ToolTipText = "This is the game field. Here you play Tic Tac Toe."
		},
		[2] = {
			ButtonPos = {
				x = MainFrame.repeatBtn:GetRight() - MainFrame:GetLeft() - 23,
				y = core.Lib:GetCenter("y", MainFrame.resetBtn) - MainFrame:GetTop() + 23
			},
			HighLightBox = {
				x = MainFrame.repeatBtn:GetLeft() - MainFrame:GetLeft(),
				y = MainFrame.repeatBtn:GetTop() - MainFrame:GetTop(),
				width = MainFrame.repeatBtn:GetWidth() + MainFrame.resetBtn:GetWidth(),
				height = MainFrame.repeatBtn:GetHeight()
			},
			ToolTipDir = "UP",
			ToolTipText = "The Reset Button resets only the game. The Repeat Button allows you in multiplayer games to repeat the last move you did."
		},
		[3] = {
			ButtonPos = {
				x = SpaceFrame.StatsBtn:GetLeft() - MainFrame:GetLeft() - 15,
				y = core.Lib:GetCenter("y", SpaceFrame.StatsBtn) - MainFrame:GetTop() + 19
			},
			HighLightBox = {
				x = SpaceFrame.StatsBtn:GetLeft() - MainFrame:GetLeft(),
				y = SpaceFrame.StatsBtn:GetTop() - MainFrame:GetTop() - 8,
				width = SpaceFrame.StatsBtn:GetWidth(),
				height = SpaceFrame.StatsBtn:GetHeight() - 8
			},
			ToolTipDir = "LEFT",
			ToolTipText = "This button opens the statistics where you can see the names of the players and their amount of wins, defeats and total played games."
		},
		[4] = {
			ButtonPos = {
				x = SpaceFrame.ConfigBtn:GetRight() - MainFrame:GetLeft() - 26,
				y = core.Lib:GetCenter("y", SpaceFrame.StatsBtn) - MainFrame:GetTop() + 19
			},
			HighLightBox = {
				x = SpaceFrame.ConfigBtn:GetLeft() - MainFrame:GetLeft(),
				y = SpaceFrame.ConfigBtn:GetTop() - MainFrame:GetTop() - 8,
				width = SpaceFrame.ConfigBtn:GetWidth(),
				height = SpaceFrame.ConfigBtn:GetHeight() - 8
			},
			ToolTipDir = "RIGHT",
			ToolTipText = "This button opens the configuration where you can change the options."
		},
	}
end

function Config:ToggleHelpPlate()
	local helpPlate = TicTacToe_HelpPlate;

	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) and MainFrame:IsShown()) then
		HelpPlate_Show( helpPlate, MainFrame, MainFrame.mainHelpButton );
		SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME );
	else
		HelpPlate_Hide(true);
	end
end

-- Resets the game area
function Config:ResetGame(keepDisabled, AITurn)
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
		if (not keepDisabled) then
			GameFrame.field[i]:Enable()
		end
	end

	if (AITurn) then
		C_Timer.After(1, AIInput)
	end
end

-- Resets the whole AddOn
function Config:ResetAddon()
	MainFrame:Hide()

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
			total = 0,
		},
		{
			name = "",
			wins = 0,
			defeats = 0,
			total = 0,
		},
	}
	playerSelf = 0
	singleplayer = true
	invitationChatType = ""
	invitationSender = ""
	chatType = "EMOTE"
	whisperTarget = nil
	lastMsg = ""
	invitationSent = false
	singlePlayerMode = "medium"


	counter = 0
	beginner = 0
	win = false
	blackList = ""
	cheatUsed = false

	expandedMainFrame = false

	Config:ResetPosition()
end

-- Resets the position to the default position
function Config:ResetPosition()
	xPosition = default.position.x
	yPosition = default.position.y
end

-- Updates the state of the singleplayer checkbox.
function Config:UpdateSingleplayer(solo, pOne, pTwo)
	if (solo == nil) then solo = false end
	singleplayer = solo
	if (MainFrame) then
		ConfigFrame.soloCheckBox:SetChecked(solo)
	end
	if (solo) then
		if (DropDownSinglePlayerMode) then 
		UIDropDownMenu_EnableDropDown(DropDownSinglePlayerMode) 
		end
		pOne = pOne or UnitName("player")
		MainFrame.repeatBtn:Disable()

			if (singlePlayerMode == "self") then
				pTwo = pTwo or UnitName("player") .. " 2"
			else
				pTwo = pTwo or "AI " .. core.Lib:FirstLetterUp(singlePlayerMode)
			end

		SetBothPlayers(pOne, pTwo)
	else
		if (DropDownSinglePlayerMode) then UIDropDownMenu_DisableDropDown(DropDownSinglePlayerMode) end
		MainFrame.repeatBtn:Enable()
	end
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
	core:Print("Played Games: " .. player[1].total)
	core:PrintLine()
	core:Print("Player 2: " .. player[2].name)
	core:Print("Wins: " .. player[2].wins)
	core:Print("Defeats: " .. player[2].defeats)
	core:Print("Played Games: " .. player[2].total)
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
	
	Config:UpdateHelpPlate()
	Config:ToggleHelpPlate()
	print("mainHelpButton")
	print("Width: " .. MainFrame.mainHelpButton:GetWidth() .. ", Height: " .. MainFrame.mainHelpButton:GetHeight())
	print("X: " .. MainFrame.mainHelpButton:GetLeft() .. ", Y: " .. MainFrame.mainHelpButton:GetTop())
	print("MainFrame")
	print("Width: " .. MainFrame:GetWidth() .. ", Height: " .. MainFrame:GetHeight())
	print("GameFrame")
	print("Width: " .. GameFrame:GetWidth() .. ", Height: " .. GameFrame:GetHeight())
	
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
	   Config:UpdateHelpPlate()
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
	MainFrame.resetBtn:SetScript("OnClick", function(self)
		Config.ResetGame()
		if (player[1].name ~= "" and player[2].name ~= "" and not singleplayer) then
			if (chatType == "WHISPER" and (not whisperTarget or whisperTarget == "")) then
				core:Print("No whisper target chosen!")
			else
				SendChatMessage("has reset the game.", chatType, nil, whisperTarget)
			end
		end
	end)
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
	
	
	MainFrame.mainHelpButton = CreateFrame("Button", "TicTacToe_HelpBtn", MainFrame, "MainHelpPlateButton")
	MainFrame.mainHelpButton:ClearAllPoints()
	MainFrame.mainHelpButton:SetPoint("TOPRIGHT", MainFrame, "TOPLEFT", 20, 15)
	MainFrame.mainHelpButton.initialTutorial = false
	MainFrame.mainHelpButton:SetScript("OnClick", function(self)
		Config:ToggleHelpPlate()
	end)
	

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

	StatsFrame.player = {
		Config:CreateStatsSubs(StatsFrame, 1, "TOPLEFT"), -- Creates the Frame for Player One
		Config:CreateStatsSubs(StatsFrame, 2, "TOPRIGHT"),
	}
end

function Config:CreateStatsSubs(frame, id, point)
	local player = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
	player:ClearAllPoints()
	player:SetSize(frame:GetWidth() / 2 - 1, frame:GetHeight()) -- width, height
	player:SetPoint(point, frame, point)
	player.name = Config:CreateStatsFrameData(player, id, "name", nil, "TOPLEFT", "TOPLEFT", player, 10, -10) -- Sets the text/value frame with the name.

	player.wins = Config:CreateStatsFrameData(player, id, "wins", nil, "TOPRIGHT", "TOPRIGHT", player, -10, -30) -- Sets the value frame with the amount of victories.
	player.defeats = Config:CreateStatsFrameData(player, id, "defeats", nil, "TOPRIGHT", "BOTTOMRIGHT", player.wins, 0, -10) -- Sets the value frame with the amount of defeats.
	player.total = Config:CreateStatsFrameData(player, id, "total", nil, "TOPRIGHT", "BOTTOMRIGHT", player.defeats, 0, -10) -- Sets the value frame with the amount of total played games.

	player.winsText = Config:CreateStatsFrameData(player, id, "text", "Wins:", "TOPLEFT", "TOPLEFT", player, 10, -30) -- Sets the text frame for wins.
	player.defeatsText = Config:CreateStatsFrameData(player, id, "text", "Defeats:", "TOPLEFT", "BOTTOMLEFT", player.winsText, 0, -10) -- Sets the text frame for defeats.
	player.totalText = Config:CreateStatsFrameData(player, id, "text", "Total:", "TOPLEFT", "BOTTOMLEFT", player.defeatsText, 0, -10) -- Sets the text frame for total played games.

	player.resetBtn = CreateFrame("Button", nil, player, "GameMenuButtonTemplate")
	player.resetBtn:ClearAllPoints()
	player.resetBtn:SetWidth(player:GetWidth() - 4)
	player.resetBtn:SetPoint("BOTTOM", player, "BOTTOM", 0, 2)
	player.resetBtn.text = player.resetBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	player.resetBtn.text:SetPoint("CENTER", player.resetBtn, "CENTER", 0, 0)
	player.resetBtn.text:SetText("Clear")
	if (id == 1) then
		player.resetBtn:SetScript("OnClick", function(self) ClearPlayer(1) end)
	elseif (id == 2) then
		player.resetBtn:SetScript("OnClick", function(self) ClearPlayer(2, true) end)
	end

	return player
end

function Config:CreateStatsFrameData(self, id, data, text, point, relativePoint, relativeFrame, xOffset, yOffset)
	local rtn = self:CreateFontString(data..id, "OVERLAY", "GameFontHighlight")
	rtn:SetPoint(point, relativeFrame, relativePoint, xOffset, yOffset)
	if (data == "text") then
		rtn:SetText(text)
	else
		Config:CreateStats(id, data, rtn)
	end

	return rtn
end

---------------------------------
-- Stats Frame Text
---------------------------------
function Config:CreateStats(id, data, frame)
    if (MainFrame) then
        if (data == "name") then
            if (player[id].name == "") then
                if (id == 1) then
					frame:SetText("Player One")
                elseif (id == 2) then
					frame:SetText("Player Two")
                end
            else
				frame:SetText(player[id].name)
            end
        elseif (data == "wins") then
			frame:SetText(player[id].wins)
        elseif (data == "defeats") then
			frame:SetText(player[id].defeats)
        elseif (data == "total") then
			frame:SetText(player[id].total)
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
			Config:UpdateSingleplayer(true)
		else
			Config:UpdateSingleplayer(false)
		end
	end)
	if (singleplayer) then
		ConfigFrame.soloCheckBox:SetChecked(true)
	else
		ConfigFrame.soloCheckBox:SetChecked(false)
	end

	Config:CreateDropDownChatType()
	Config:CreateDropDownSinglePlayerMode()
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


		local function DropDownMenuChatType_OnClick(self)
			UIDropDownMenu_SetSelectedID(DropDownChatType, self:GetID())

			chatType = self.value

			if (chatType == "WHISPER") then
				whisperTarget = ConfigFrame.targetEditBox:GetText()
			else
				whisperTarget = nil
			end
		end

		local function initialize(self, level)
			local info
			for _,v in pairs(default.chatTypes) do
				info = UIDropDownMenu_CreateInfo()
				info.text = core.Lib:FirstLetterUp(v)
				info.value = v
				info.func = DropDownMenuChatType_OnClick
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

---------------------------------
-- Drop Down Single Player Mode
---------------------------------
function Config:CreateDropDownSinglePlayerMode()
	-- testing the DropDown Menu
	if (not DropDownSinglePlayerMode) then
        DropDownSinglePlayerMode = CreateFrame("Button", "TicTacToe_DropDownSinglePlayerMode", ConfigFrame, "UIDropDownMenuTemplate")
		DropDownSinglePlayerMode:ClearAllPoints()
		DropDownSinglePlayerMode:SetPoint("TOPLEFT", ConfigFrame.soloCheckBox, "BOTTOMLEFT", -16, -5)


		local function DropDownSinglePlayerMode_OnClick(self)
			UIDropDownMenu_SetSelectedID(DropDownSinglePlayerMode, self:GetID())
			singlePlayerMode = self.value
			Config:UpdateSingleplayer(true)
		end

		local function initialize(self, level)
			local info
			for _,v in pairs(default.singlePlayerModes) do
				info = UIDropDownMenu_CreateInfo()
				info.text = core.Lib:FirstLetterUp(v)
				info.value = v
				info.func = DropDownSinglePlayerMode_OnClick
				UIDropDownMenu_AddButton(info, level)
				UIDropDownMenu_AddSeparator(DropDownSinglePlayerMode)
			end
		end

		UIDropDownMenu_Initialize(DropDownSinglePlayerMode, initialize)
		UIDropDownMenu_SetWidth(DropDownSinglePlayerMode, 82)
		UIDropDownMenu_SetButtonWidth(DropDownSinglePlayerMode, 124)
		UIDropDownMenu_SetSelectedValue(DropDownSinglePlayerMode, singlePlayerMode)
		UIDropDownMenu_JustifyText(DropDownSinglePlayerMode, "LEFT")

		if (singleplayer) then
			UIDropDownMenu_EnableDropDown(DropDownSinglePlayerMode)
		else
			UIDropDownMenu_DisableDropDown(DropDownSinglePlayerMode)
		end
	else
		Config:SetDropDownSinglePlayerMode()
	end
end
function Config:SetDropDownSinglePlayerMode()
	DropDownSinglePlayerMode:ClearAllPoints()
	DropDownSinglePlayerMode:SetParent(ConfigFrame)
	DropDownSinglePlayerMode:SetPoint("TOPLEFT", ConfigFrame.soloCheckBox, "BOTTOMLEFT", -16, -5)
	UIDropDownMenu_SetSelectedValue(DropDownSinglePlayerMode, singlePlayerMode)

	if (singleplayer) then
		UIDropDownMenu_EnableDropDown(DropDownSinglePlayerMode)
	else
		UIDropDownMenu_DisableDropDown(DropDownSinglePlayerMode)
	end
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

local msgParty = CreateFrame("Frame")
msgParty:RegisterEvent("CHAT_MSG_PARTY")
msgParty:SetScript("OnEvent", function(self, event, message, sender) ReceiveInput(sender, message, "PARTY") end)

local msgPartyLeader = CreateFrame("Frame")
msgPartyLeader:RegisterEvent("CHAT_MSG_PARTY_LEADER")
msgPartyLeader:SetScript("OnEvent", function(self, event, message, sender) ReceiveInput(sender, message, "PARTY") end)

local msgGuild = CreateFrame("Frame")
msgGuild:RegisterEvent("CHAT_MSG_GUILD")
msgGuild:SetScript("OnEvent", function(self, event, message, sender) ReceiveInput(sender, message, "GUILD") end)

local msgRaid = CreateFrame("Frame")
msgRaid:RegisterEvent("CHAT_MSG_RAID")
msgRaid:SetScript("OnEvent", function(self, event, message, sender) ReceiveInput(sender, message, "RAID") end)

local msgRaidLeader = CreateFrame("Frame")
msgRaidLeader:RegisterEvent("CHAT_MSG_RAID_LEADER")
msgRaidLeader:SetScript("OnEvent", function(self, event, message, sender) ReceiveInput(sender, message, "RAID") end)