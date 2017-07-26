--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;
core.Config = {}; -- adds Config table to addon namespace

--------------------------------------
-- Defaults (usually a database!)
--------------------------------------
local xCenter, yCenter = UIParent:GetCenter();

local default = {
	title = "Tic Tac Toe",

	theme = {
		r = 0, 
		g = 0.8, -- 204/255
		b = 1,
		hex = "00ccff",
	},

	position = {
		x = xCenter * 1.5,
		y = yCenter * 1.1,
	},
	
	size = {
		width = 230,
		height = 270,
		expanded = {
			height = 160,
		},
	},
}


--------------------------------------
-- Initializing Variables
--------------------------------------
local Config = core.Config;
local MainFrame;

local xPosition = default.position.x;
local yPosition = default.position.y;

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
local playerSelf = "";
local curPlayerOne = UnitName("player");
local curPlayerTwo = "";
local invitationSender = "";
local myTurn = true;
local playerX = true;
local singleplayer = false;
local chatType = "EMOTE";
local whisperMode = false;
local whisperTarget = nil;
local counter = 0;
local win = false;
local blackList = "";
local lastMsg = "";

local expandedMainFrame = false;


local function UpdateStatsFrame(id)
	Config:CreateStats(id, "name", 			"Player Two");
	Config:CreateStats(id, "wins", 			"Wins:         ");
	Config:CreateStats(id, "defeats", 		"Defeats:      ");
	Config:CreateStats(id, "playedGames", 	"Total:        ");
end

local function UpdatePlayerStats(id, played, win, lose)
	if (win) 	then player[id].wins				= player[id].wins 			+ 1;	end
	if (lose)	then player[id].defeats			= player[id].defeats 			+ 1;	end
	if (played) then player[id].playedGames	= player[id].playedGames	+ 1;	end
	UpdateStatsFrame(id);
end

local function SetPlayers(playerOne, playerTwo)
	if (playerOne) then
		player[1].name = playerOne;
		player[1].wins = 0;
		player[1].defeats = 0;
		player[1].playedGames = 0;
		UpdateStatsFrame(1);
	end
	if (playerTwo) then
		player[2].name = playerTwo;
		player[2].wins = 0;
		player[2].defeats = 0;
		player[2].playedGames = 0;
		UpdateStatsFrame(2);
	end
end


--------------------------------------
-- Config functions
--------------------------------------
function Config:Exit()
	if (player[1].name ~= "" and player[2].name ~= "" and not singleplayer) then
		SendChatMessage("has quit the game.", chatType);
	end
	myTurn = true;
	curPlayerTwo = "";
	playerX = true;
	--singleplayer = false;
	blackList = "";
	counter = 0;
	win = false;
	chatType = "EMOTE";
	whisperMode = false;
	whisperTarget = nil;
	MainFrame:Hide();
	MainFrame.ScrollFrame.ConfigFrame:Hide();
	MainFrame.ScrollFrame.ConfigFrame = nil;
	MainFrame.title:SetText(default.title);
	expandedMainFrame = false;
	MainFrame = nil;
end

function Config:Reset()
	if (player[1].name ~= "" and player[2].name ~= "" and not singleplayer) then
		SendChatMessage("has reset the game.", chatType);
	end
	core.Config.Exit();
	core.Config.Toggle();
end

function Config:ResetPosition()
	xPosition = default.position.x;
	yPosition = default.position.y;
end

function Config:Singleplayer()
	if (singleplayer == false) then
		if (MainFrame.ScrollFrame.ConfigFrame) then
			MainFrame.ScrollFrame.ConfigFrame.soloCheckBox:SetChecked(true);
		end
		singleplayer = true;
	else
		if (MainFrame.ScrollFrame.ConfigFrame) then
			MainFrame.ScrollFrame.ConfigFrame.soloCheckBox:SetChecked(false);
		end
		singleplayer = false;
	end
end

function Config:GetThemeColor()
	local c = default.theme;
	return c.r, c.g, c.b, c.hex;
end

function Config:Toggle()
	local menu = MainFrame or Config:CreateMainMenu();
	menu:SetShown(not menu:IsShown());
end

function Config:PrintPlayerStats()
	print("-------------------------");
	print("Player 1: " .. player[1].name);
	print("Wins: " .. player[1].wins);
	print("Defeats: " .. player[1].defeats);
	print("Played Games: " .. player[1].playedGames);
	print("-------------------------");
	print("Player 2: " .. player[2].name);
	print("Wins: " .. player[2].wins);
	print("Defeats: " .. player[2].defeats);
	print("Played Games: " .. player[2].playedGames);
	print("-------------------------");
end

-- this function disables all Buttons
local function DisableFields()
	for i = 1, #MainFrame.ScrollFrame.gameFrame.field do
		MainFrame.ScrollFrame.gameFrame.field[i]:Disable();
	end
end

local function DisableBlacklistedFields()
	for i = 1, #blackList do
		local c = blackList:sub(i,i)
		MainFrame.ScrollFrame.gameFrame.field[tonumber(c)]:Disable();
	end
end

-- this function enables all Buttons
local function EnableFields()
	for i = 1, #MainFrame.ScrollFrame.gameFrame.field do
		MainFrame.ScrollFrame.gameFrame.field[i]:Enable();
	end
end

local function InvitePlayer()
	if MainFrame.ScrollFrame.ConfigFrame.inviteEditBox ~= "" then
		SendChatMessage("has invited " ..MainFrame.ScrollFrame.ConfigFrame.inviteEditBox:GetText().. " to play Tic Tac Toe.", chatType, nil, whisperTarget);
	end
end

-- this function is for multiplayer. It sends a Message which Button the player has clicked as an emote.
local function Field_Onclick(self)
	if (player[1].name == "") then
		SetPlayers(UnitName("player"), nil);
		if (playerSelf == "") then
			playerSelf = 1;
		elseif (singleplayer) then
			playerSelf = 2;
		end
	elseif (player[2].name == "") then
		SetPlayers(nil, UnitName("player"));
		if (playerSelf == "") then
			playerSelf = 2;
		elseif (singleplayer) then
			playerSelf = 1;
		end
	end
	if (player[1].name == UnitName("player")) then
		playerSelf = 1;
	elseif (player[2].name == UnitName("player")) then
		playerSelf = 2;
	end

	if (singleplayer == false) then
		if (playerSelf == 1) then
			lastMsg = "has put an X on the field : " .. self:GetID();
			SendChatMessage(lastMsg, chatType, nil, whisperTarget);
		elseif (playerSelf == 2) then
			lastMsg = "has put an O on the field : " .. self:GetID();
			SendChatMessage(lastMsg, chatType, nil, whisperTarget);
		end
	end
	
	-- if it is not your turn, this disables for you the Buttons
	SelectField(self:GetID(), playerSelf);
	if (singleplayer == false) then
		myTurn = false;
	end

	if (singleplayer == false) then
		DisableFields();
	end
end

function Config:CreateButton(id, point, relativeFrame, relativePoint, xOffset, yOffset, text)
	local btn = CreateFrame("Button", nil, relativeFrame, "GameMenuButtonTemplate");
	btn:SetID(id);
	btn:SetPoint(point, relativeFrame, relativePoint, xOffset, yOffset);
	btn:SetSize(70, 70);
	btn:SetText(text);
	btn:SetNormalFontObject("GameFontNormalLarge");
	btn:SetHighlightFontObject("GameFontHighlightLarge");
	btn:SetScript("OnClick", function(self) Field_Onclick(self) end);

	--btn:SetScript("OnClick", function(self));

	return btn;
end

local function checkIfWon(frst, scnd, thrd, curPlayer)
	if ((MainFrame.ScrollFrame.gameFrame.field[frst]:GetText() == MainFrame.ScrollFrame.gameFrame.field[scnd]:GetText()) and (MainFrame.ScrollFrame.gameFrame.field[frst]:GetText() == MainFrame.ScrollFrame.gameFrame.field[thrd]:GetText()) and (MainFrame.ScrollFrame.gameFrame.field[frst]:GetText() ~= nil)) then
		MainFrame.ScrollFrame.gameFrame.field[frst]:LockHighlight();
		MainFrame.ScrollFrame.gameFrame.field[scnd]:LockHighlight();
		MainFrame.ScrollFrame.gameFrame.field[thrd]:LockHighlight();
		if (curPlayer == playerSelf) and (singleplayer == false) then
			SendChatMessage("won the game!", chatType);
			DoEmote("DANCE", none);
		elseif (curPlayer ~= playerSelf) and (singleplayer == false) then
			DoEmote("CRY", curPlayerTwo);
		end

		if (curPlayer == 1) then
			UpdatePlayerStats(1, true, true, false);
			UpdatePlayerStats(2, true, false, true);
		elseif (curPlayer == 2) then
			UpdatePlayerStats(2, true, true, false);
			UpdatePlayerStats(1, true, false, true);
		end
		DisableFields();
		return true;
	else
		return false;
	end
end

--------------------------------------
-- Functions
--------------------------------------
function SelectField(key, curPlayer)
	if (not string.find(blackList, tostring(key))) then
		MainFrame.ScrollFrame.gameFrame.field[tonumber(key)]:Disable();
		counter = counter + 1;
		if (curPlayer == 1) then
			MainFrame.ScrollFrame.gameFrame.field[key]:SetText("X");
		elseif (curPlayer == 2) then
			MainFrame.ScrollFrame.gameFrame.field[key]:SetText("O");
		end

		blackList = blackList .. key;

		-- This is in case you win or lose. It disables all buttons, highlight them and do an emote.
		if (counter >= 5) then
			win = checkIfWon(1, 2, 3, curPlayer);
			win = checkIfWon(4, 5, 6, curPlayer);
			win = checkIfWon(7, 8, 9, curPlayer);
			win = checkIfWon(1, 4, 7, curPlayer);
			win = checkIfWon(2, 5, 8, curPlayer);
			win = checkIfWon(3, 6, 9, curPlayer);
			win = checkIfWon(1, 5, 9, curPlayer);
			win = checkIfWon(3, 5, 7, curPlayer);
		end
	end

	-- If it is undecided, both player applaud.
	if (counter >= 9) and (win == false) then
		if (singleplayer == false) then
			DoEmote("APPLAUD");
		end
	end
end


local function AcceptingInvitation()
	SendChatMessage("has accepted the invitation of " .. invitationSender .. ".", chatType);
	SetPlayers(invitationSender, UnitName("player"));
	core.Config.Toggle()
end

local function DecliningInvitation()
	SendChatMessage("has declined the invitation of " .. invitationSender .. ".", chatType);
end

-- this function is for splitting the Emote Messages. The AddOn of the other player can take over the move of the first player
local function ReceiveInput(event, _, message, sender, language, channelString, target, flags, unknown, channelNumber, channelName, unknown, counter)
	-- Getting the name of the sender without the addition of the realm
	local argsSnd = {};
	for _, arg in ipairs({ string.split('-', sender) }) do
		if (#arg > 0) then
			table.insert(argsSnd, arg);
		end
	end
	local senderName = argsSnd[1]; -- Setting the sendername in its variable for further processing.
	
	-- The invitation looks like this: "ABC has invited XYZ to play Tic Tac Toe."
	-- ABC is the senders name.
	-- XYZ is the recipients name.
	-- The message-string ("has invited XZY to play Tic Tac Toe.") is split by the spaces (" ").
	-- the recipients name becomes index three of the array (argsMsg[3]).
	local argsMsg = {};
	for _, arg in ipairs({ string.split(' ', message) }) do
		if (#arg > 0) then
			table.insert(argsMsg, arg);
		end
	end

	-- Check if the second word is the keyword "invited".
	if (argsMsg[2] == "invited") then
		-- If I get an invitation, the recipient (me) must have my name and the sender mustn't be myself as well.
		if (senderName ~= UnitName("player") and argsMsg[3] == UnitName("player")) then
			invitationSender = senderName;
			StaticPopup_Show ("TICTACTOE_INVITATION");
		end
	end
	
	-- Check if the second word is the keyword "accepted".
	if (argsMsg[2] == "accepted") then
		-- If I get an invitation, the sender (me) must have my name and the recipient mustn't be myself as well.
		if (senderName ~= UnitName("player")) then
			local argsInv = {};
			for _, arg in ipairs({ string.split('.', argsMsg[6]) }) do
				if (#arg > 0) then
					table.insert(argsInv, arg);
				end
			end
			local inviteSender = argsInv[1];
			SetPlayers(inviteSender, senderName);
		end
	end
	
	if (singleplayer == false) then
		local mark
		if ((argsMsg[2] == "put") and (argsMsg[4] == "X" or "O")) then
			mark = argsMsg[4];
		end

		local argsFieldId = {};
		for _, arg in ipairs({ string.split(' : ', message) }) do
			if (#arg > 0) then
				table.insert(argsFieldId, arg);
			end
		end
		local fieldId = argsFieldId[#argsFieldId];

		-- Check if the id is a valid number from 1 to 9.
		-- To avoid errors it will not be converted into a number.
		if (fieldId == "1" or fieldId == "2" or fieldId == "3" or fieldId == "4" or fieldId == "5" or fieldId == "6" or fieldId == "7" or fieldId == "8" or fieldId == "9") then
			-- Senders name mustn't be the own player name.
			if (senderName ~= UnitName("player")) then
				-- If there is no player two, it will be set here.
				if (player[1].name == "") then
					SetPlayers(senderName, nil);
				elseif (player[2].name == "") then
					SetPlayers(nil, senderName);
				end

				-- To avoid people spoiling the game, it will be checked, if the senders name is correct.
				if (senderName == player[1].name or senderName == player[2].name) then
					EnableFields();
					DisableBlacklistedFields();
					
					if (senderName == player[1].name) then
						SelectField(tonumber(fieldId), 1);
					else
						SelectField(tonumber(fieldId), 2);
					end
				end
			end
		end

		-- This is a cheat code to enable the fields. For testing purposes.
		if (fieldId == "at-x0g") then
			EnableFields();
			DisableBlacklistedFields();
		end
	end
end

---------------------------------
-- Main Frame
---------------------------------
function Config:CreateMainMenu() -- creates the Main Frame
	MainFrame = CreateFrame("Frame", "TicTacToe_MainFrame", UIParent, "BasicFrameTemplate");
	MainFrame:ClearAllPoints();
	MainFrame:SetSize(default.size.width, default.size.height); -- width, height
	MainFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", xPosition, yPosition); -- point, relativeFrame, relativePoint, xOffset, yOffset
	MainFrame.title = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.title:SetPoint("LEFT", MainFrame.TitleBg, "LEFT", 5, 0);
	MainFrame.title:SetText(default.title);
	MainFrame:SetMovable(true)
	MainFrame:EnableMouse(true)
	MainFrame:SetScript("OnMouseDown", function(self, button)
	  if button == "LeftButton" and not self.isMoving then
	   self:StartMoving();
	   self.isMoving = true;
	  end
	end)
	MainFrame:SetScript("OnMouseUp", function(self, button)
	  if button == "LeftButton" and self.isMoving then
	   self:StopMovingOrSizing();
	   self.isMoving = false;
	   xPosition = self:GetLeft();
	   yPosition = self:GetTop();
	  end
	end)
	MainFrame:SetScript("OnHide", function(self)
	  if On( self.isMoving ) then
	   self:StopMovingOrSizing();
	   self.isMoving = false;
	  end
	  core.Config.Exit();
	end)
	MainFrame:SetScript("OnHide", function(self) MainFrame.ScrollFrame.ConfigFrame:Hide(); end)
	
	MainFrame.ScrollFrame = CreateFrame("ScrollFrame", nil, MainFrame, "UIPanelScrollFrameTemplate");
	MainFrame.ScrollFrame:ClearAllPoints();
	MainFrame.ScrollFrame:SetSize(MainFrame:GetWidth() - 10, MainFrame:GetHeight() - 30);
	MainFrame.ScrollFrame:SetPoint("TOP", MainFrame, "TOP", -2, -25);
	MainFrame.ScrollFrame:SetClipsChildren(true);
	
	MainFrame.ScrollFrame.gameFrame = CreateFrame("Frame", "TicTacToe_GameFrame", MainFrame, "InsetFrameTemplate");
	MainFrame.ScrollFrame.gameFrame:ClearAllPoints();
	MainFrame.ScrollFrame.gameFrame:SetSize(MainFrame.ScrollFrame:GetWidth(), 205);
	MainFrame.ScrollFrame.gameFrame:SetPoint("TOP", MainFrame, "TOP", 0, -25);

	MainFrame.ScrollFrame.SpaceFrame = CreateFrame("Frame", nil, MainFrame.ScrollFrame, "InsetFrameTemplate");
	MainFrame.ScrollFrame.SpaceFrame:ClearAllPoints();
	MainFrame.ScrollFrame.SpaceFrame:SetSize(MainFrame.ScrollFrame:GetWidth(), 30);
	MainFrame.ScrollFrame.SpaceFrame:SetPoint("TOP", MainFrame.ScrollFrame.gameFrame, "BOTTOM", 0, -5);
	
	MainFrame.ScrollFrame.SpaceFrame.StatsBtnFrame = CreateFrame("Button", nil, MainFrame.ScrollFrame.SpaceFrame, "GameMenuButtonTemplate");
	MainFrame.ScrollFrame.SpaceFrame.StatsBtnFrame:ClearAllPoints();
	MainFrame.ScrollFrame.SpaceFrame.StatsBtnFrame:SetSize(MainFrame:GetWidth() / 2 - 4, 30);
	MainFrame.ScrollFrame.SpaceFrame.StatsBtnFrame:SetPoint("LEFT", MainFrame.ScrollFrame.SpaceFrame, "LEFT", -1, 0);
	MainFrame.ScrollFrame.SpaceFrame.StatsBtnFrame.statTitle = MainFrame.ScrollFrame.SpaceFrame.StatsBtnFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.ScrollFrame.SpaceFrame.StatsBtnFrame.statTitle:SetPoint("LEFT", MainFrame.ScrollFrame.SpaceFrame.StatsBtnFrame, "LEFT", 10, 0);
	MainFrame.ScrollFrame.SpaceFrame.StatsBtnFrame.statTitle:SetText("Statistics");
	MainFrame.ScrollFrame.SpaceFrame.StatsBtnFrame:SetScript("OnClick", function(self)
		if (expandedMainFrame and MainFrame.ScrollFrame.StatsFrame:IsShown()) then
			local animation = CreateFrame("Frame");
			animation:SetScript("OnUpdate", function()
				local h = MainFrame:GetHeight();
				if (h >= default.size.height) then
					h = h - 4;
					MainFrame:SetHeight(h);
					MainFrame.ScrollFrame:SetSize(MainFrame:GetWidth() - 10, h - 30);
				else
					animation:SetScript("OnUpdate", nil);
				end
			end);
			--MainFrame:SetHeight(default.size.height);
			--MainFrame.ScrollFrame:SetSize(MainFrame:GetWidth() - 10, MainFrame:GetHeight() - 30);
			MainFrame:ClearAllPoints();
			MainFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", xPosition, yPosition); -- point, relativeFrame, relativePoint, xOffset, yOffset
			expandedMainFrame = false;
		elseif (expandedMainFrame) then
			MainFrame.ScrollFrame.StatsFrame:Show();
			MainFrame.ScrollFrame.ConfigFrame:Hide();
		else
			MainFrame.ScrollFrame.StatsFrame:Show();
			MainFrame.ScrollFrame.ConfigFrame:Hide();
			local animation = CreateFrame("Frame");
			animation:SetScript("OnUpdate", function()
				local h = MainFrame:GetHeight();
				if (h <= (default.size.height + default.size.expanded.height)) then
					h = h + 4;
					MainFrame:SetHeight(h);
					MainFrame.ScrollFrame:SetSize(MainFrame:GetWidth() - 10, h - 30);
				else
					animation:SetScript("OnUpdate", nil);
				end
			end);
			-- MainFrame:SetHeight(MainFrame:GetHeight() + MainFrame.ScrollFrame.StatsFrame:GetHeight());
			-- MainFrame.ScrollFrame:SetSize(MainFrame:GetWidth() - 10, MainFrame:GetHeight() - 30);
			MainFrame:ClearAllPoints();
			MainFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", xPosition, yPosition); -- point, relativeFrame, relativePoint, xOffset, yOffset
			expandedMainFrame = true;
		end
	end);
	
	MainFrame.ScrollFrame.SpaceFrame.ConfigBtnFrame = CreateFrame("Button", nil, MainFrame.ScrollFrame.SpaceFrame, "GameMenuButtonTemplate");
	MainFrame.ScrollFrame.SpaceFrame.ConfigBtnFrame:ClearAllPoints();
	MainFrame.ScrollFrame.SpaceFrame.ConfigBtnFrame:SetSize(MainFrame:GetWidth() / 2 - 4, 30);
	MainFrame.ScrollFrame.SpaceFrame.ConfigBtnFrame:SetPoint("RIGHT", MainFrame.ScrollFrame.SpaceFrame, "RIGHT", -1, 0);
	MainFrame.ScrollFrame.SpaceFrame.ConfigBtnFrame.configTitle = MainFrame.ScrollFrame.SpaceFrame.ConfigBtnFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.ScrollFrame.SpaceFrame.ConfigBtnFrame.configTitle:SetPoint("RIGHT", MainFrame.ScrollFrame.SpaceFrame.ConfigBtnFrame, "RIGHT", -10, 0);
	MainFrame.ScrollFrame.SpaceFrame.ConfigBtnFrame.configTitle:SetText("Configuration");
	MainFrame.ScrollFrame.SpaceFrame.ConfigBtnFrame:SetScript("OnClick", function(self)
		if (expandedMainFrame and MainFrame.ScrollFrame.ConfigFrame:IsShown()) then
			local animation = CreateFrame("Frame");
			animation:SetScript("OnUpdate", function()
				local h = MainFrame:GetHeight();
				if (h >= default.size.height) then
					h = h - 4;
					MainFrame:SetHeight(h);
					MainFrame.ScrollFrame:SetSize(MainFrame:GetWidth() - 10, h - 30);
				else
					animation:SetScript("OnUpdate", nil);
				end
			end);
			-- MainFrame:SetHeight(default.size.height);
			-- MainFrame.ScrollFrame:SetSize(MainFrame:GetWidth() - 10, MainFrame:GetHeight() - 30);
			MainFrame:ClearAllPoints();
			MainFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", xPosition, yPosition); -- point, relativeFrame, relativePoint, xOffset, yOffset
			expandedMainFrame = false;
		elseif (expandedMainFrame) then
			MainFrame.ScrollFrame.ConfigFrame:Show();
			MainFrame.ScrollFrame.StatsFrame:Hide();
		else
			MainFrame.ScrollFrame.ConfigFrame:Show();
			MainFrame.ScrollFrame.StatsFrame:Hide();
			local animation = CreateFrame("Frame");
			animation:SetScript("OnUpdate", function()
				local h = MainFrame:GetHeight();
				if (h <= (default.size.height + default.size.expanded.height)) then
					h = h + 4;
					MainFrame:SetHeight(h);
					MainFrame.ScrollFrame:SetSize(MainFrame:GetWidth() - 10, h - 30);
				else
					animation:SetScript("OnUpdate", nil);
				end
			end);
			-- MainFrame:SetHeight(MainFrame:GetHeight() + MainFrame.ScrollFrame.ConfigFrame:GetHeight());
			-- MainFrame.ScrollFrame:SetSize(MainFrame:GetWidth() - 10, MainFrame:GetHeight() - 30);
			MainFrame:ClearAllPoints();
			MainFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", xPosition, yPosition); -- point, relativeFrame, relativePoint, xOffset, yOffset
			expandedMainFrame = true;
		end
	end);

	--[[MainFrame.configBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate")
	MainFrame.configBtn:ClearAllPoints();
	MainFrame.configBtn:SetWidth(50); -- width, height
	MainFrame.configBtn:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", -24, 0);
	MainFrame.configBtn:SetScript("OnClick", function(self)
			if (MainFrame.ScrollFrame.ConfigFrame:IsShown()) then
				MainFrame.ScrollFrame.ConfigFrame:Hide();
			else
				MainFrame.ScrollFrame.ConfigFrame:Show();
			end
			
	MainFrame.configBtn.title = MainFrame.configBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.configBtn.title:SetPoint("LEFT", MainFrame.configBtn, "LEFT", 5, 0);
	MainFrame.configBtn.title:SetText("Config");
	]]
	MainFrame.resetBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
	MainFrame.resetBtn:ClearAllPoints();
	MainFrame.resetBtn:SetWidth(50); -- width, height
	MainFrame.resetBtn:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", -24, 0);
	MainFrame.resetBtn:SetScript("OnClick", Config.Reset);
	MainFrame.resetBtn.title = MainFrame.resetBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.resetBtn.title:SetPoint("LEFT", MainFrame.resetBtn, "LEFT", 5, 0);
	MainFrame.resetBtn.title:SetText("Reset");

	-- Creates the 9 Buttons in the MainFrame.ScrollFrame
	MainFrame.ScrollFrame.gameFrame.field = {
		self:CreateButton(1, "TOPLEFT",		MainFrame.ScrollFrame.gameFrame,	"TOPLEFT",		4,	-2, "");
		self:CreateButton(2, "TOP", 		MainFrame.ScrollFrame.gameFrame,	"TOP",			0,	-2, "");
		self:CreateButton(3, "TOPRIGHT", 	MainFrame.ScrollFrame.gameFrame,	"TOPRIGHT",		-4,	-2, "");
		self:CreateButton(4, "LEFT",		MainFrame.ScrollFrame.gameFrame,	"LEFT",			4,	0,	"");
		self:CreateButton(5, "CENTER",		MainFrame.ScrollFrame.gameFrame,	"CENTER",		0,	0, "");
		self:CreateButton(6, "RIGHT",		MainFrame.ScrollFrame.gameFrame,	"RIGHT",		-4,	0, "");
		self:CreateButton(7, "BOTTOMLEFT", 	MainFrame.ScrollFrame.gameFrame,	"BOTTOMLEFT",	4,	2, "");
		self:CreateButton(8, "BOTTOM", 		MainFrame.ScrollFrame.gameFrame,	"BOTTOM",		0,	2, "");
		self:CreateButton(9, "BOTTOMRIGHT", MainFrame.ScrollFrame.gameFrame,	"BOTTOMRIGHT",	-4,	2, "");
	}
	Config.CreateStatsMenu();
	Config.CreateConfigMenu();

	MainFrame:Hide();
	return MainFrame;
end

function Config:CreateStatsMenu()
	-- Creates the MainFrame.ScrollFrame.StatsFrame
	MainFrame.ScrollFrame.StatsFrame = CreateFrame("Frame", "TicTacToe_StatsFrame", MainFrame.ScrollFrame)
	MainFrame.ScrollFrame.StatsFrame:ClearAllPoints();
	MainFrame.ScrollFrame.StatsFrame:SetSize(MainFrame.ScrollFrame:GetWidth(), default.size.expanded.height); -- width, height
	MainFrame.ScrollFrame.StatsFrame:SetPoint("TOP", MainFrame.ScrollFrame.SpaceFrame, "BOTTOM"); -- point, relativeFrame, relativePoint, xOffset, yOffset
	
	-- this creates the Frame for Player One
	MainFrame.ScrollFrame.StatsFrame.plOneFrame = CreateFrame("Frame", nil, MainFrame.ScrollFrame.StatsFrame, "InsetFrameTemplate");
	MainFrame.ScrollFrame.StatsFrame.plOneFrame:ClearAllPoints();
	MainFrame.ScrollFrame.StatsFrame.plOneFrame:SetSize(MainFrame.ScrollFrame.StatsFrame:GetWidth() / 2 - 1, MainFrame.ScrollFrame.StatsFrame:GetHeight()); -- width, height
	MainFrame.ScrollFrame.StatsFrame.plOneFrame:SetPoint("TOPLEFT", MainFrame.ScrollFrame.StatsFrame, "TOPLEFT");
	
	-- this sets the TextFrame for the Name of the first Player
	MainFrame.ScrollFrame.StatsFrame.plOneFrame.textPl = MainFrame.ScrollFrame.StatsFrame.plOneFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.ScrollFrame.StatsFrame.plOneFrame.textPl:SetPoint("TOPLEFT", MainFrame.ScrollFrame.StatsFrame.plOneFrame, "TOPLEFT", 10, -10);
	Config:CreateStats(1, "name", 			"Player Two");
	
	-- This gives the number of victories from the first player
	MainFrame.ScrollFrame.StatsFrame.plOneFrame.textWins = MainFrame.ScrollFrame.StatsFrame.plOneFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.ScrollFrame.StatsFrame.plOneFrame.textWins:SetPoint("TOPLEFT", MainFrame.ScrollFrame.StatsFrame.plOneFrame.textPl, "BOTTOMLEFT", 0, -10);
	Config:CreateStats(1, "wins", 			"Wins:          ");
	
	-- This gives the number of defeats from the first player
	MainFrame.ScrollFrame.StatsFrame.plOneFrame.textDefeats = MainFrame.ScrollFrame.StatsFrame.plOneFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.ScrollFrame.StatsFrame.plOneFrame.textDefeats:SetPoint("TOPLEFT", MainFrame.ScrollFrame.StatsFrame.plOneFrame.textWins, "BOTTOMLEFT", 0, -10);
	Config:CreateStats(1, "defeats", 		"Defeats:      ");
	
	-- This gives the number of games from the first player
	MainFrame.ScrollFrame.StatsFrame.plOneFrame.textGames = MainFrame.ScrollFrame.StatsFrame.plOneFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.ScrollFrame.StatsFrame.plOneFrame.textGames:SetPoint("TOPLEFT", MainFrame.ScrollFrame.StatsFrame.plOneFrame.textDefeats, "BOTTOMLEFT", 0, -10);
	Config:CreateStats(1, "playedGames", 	"Total:          ");
	
	MainFrame.ScrollFrame.StatsFrame.plTwoFrame = CreateFrame("Frame", nil, MainFrame.ScrollFrame.StatsFrame, "InsetFrameTemplate");
	MainFrame.ScrollFrame.StatsFrame.plTwoFrame:ClearAllPoints();
	MainFrame.ScrollFrame.StatsFrame.plTwoFrame:SetSize(MainFrame.ScrollFrame.StatsFrame:GetWidth() / 2 - 1, MainFrame.ScrollFrame.StatsFrame:GetHeight()); -- width, height
	MainFrame.ScrollFrame.StatsFrame.plTwoFrame:SetPoint("TOPRIGHT", MainFrame.ScrollFrame.StatsFrame, "TOPRIGHT");
	
	-- this sets the TextFrame for the Name of the second Player
	MainFrame.ScrollFrame.StatsFrame.plTwoFrame.textPl = MainFrame.ScrollFrame.StatsFrame.plTwoFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.ScrollFrame.StatsFrame.plTwoFrame.textPl:SetPoint("TOPLEFT", MainFrame.ScrollFrame.StatsFrame.plTwoFrame, "TOPLEFT", 10, -10);
	Config:CreateStats(2, "name", 			"Player Two");
	
	-- This gives the number of victories from the second player
	MainFrame.ScrollFrame.StatsFrame.plTwoFrame.textWins = MainFrame.ScrollFrame.StatsFrame.plTwoFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.ScrollFrame.StatsFrame.plTwoFrame.textWins:SetPoint("TOPLEFT", MainFrame.ScrollFrame.StatsFrame.plTwoFrame.textPl, "BOTTOMLEFT", 0, -10);
	Config:CreateStats(2, "wins", 			"Wins:          ");
	
	-- This gives the number of defeats from the second player
	MainFrame.ScrollFrame.StatsFrame.plTwoFrame.textDefeats = MainFrame.ScrollFrame.StatsFrame.plTwoFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.ScrollFrame.StatsFrame.plTwoFrame.textDefeats:SetPoint("TOPLEFT", MainFrame.ScrollFrame.StatsFrame.plTwoFrame.textWins, "BOTTOMLEFT", 0, -10);
	Config:CreateStats(2, "defeats", 		"Defeats:      ");
	
	-- This gives the number of games from the first player
	MainFrame.ScrollFrame.StatsFrame.plTwoFrame.textGames = MainFrame.ScrollFrame.StatsFrame.plTwoFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.ScrollFrame.StatsFrame.plTwoFrame.textGames:SetPoint("TOPLEFT", MainFrame.ScrollFrame.StatsFrame.plTwoFrame.textDefeats, "BOTTOMLEFT", 0, -10);
	Config:CreateStats(2, "playedGames", 	"Total:          ");
	--[[
	if (player[1].name == "") then
		MainFrame.ScrollFrame.StatsFrame.plTwoFrame.textGames:SetText("Total:         0");
	else
		MainFrame.ScrollFrame.StatsFrame.plTwoFrame.textGames:SetText("Total:         " ..player[2].playedGames);
	end
	]]
	--[[print("Player 1: " .. player[1].name);
	print("Wins: " .. player[1].wins);
	print("Defeats: " .. player[1].defeats);
	print("Played Games: " .. player[1].playedGames);
	print("-------------------------");
	print("Player 2: " .. player[2].name);
	print("Wins: " .. player[2].wins);
	print("Defeats: " .. player[2].defeats);
	print("Played Games: " .. player[2].playedGames);
	print("-------------------------");
	]]
end

function Config:CreateStats(id, data, text)
	if (data == "name") then
		if (player[id].name == "") then
			if (id == 1) then
				MainFrame.ScrollFrame.StatsFrame.plOneFrame.textPl:SetText(text);
			elseif (id == 2) then
				MainFrame.ScrollFrame.StatsFrame.plTwoFrame.textPl:SetText(text);
			end
		else
			if (id == 1) then
				MainFrame.ScrollFrame.StatsFrame.plOneFrame.textPl:SetText(player[1].name);
			elseif (id == 2) then
				MainFrame.ScrollFrame.StatsFrame.plTwoFrame.textPl:SetText(player[2].name);
			end
		end
	elseif (data == "wins") then
		if (id == 1) then
			MainFrame.ScrollFrame.StatsFrame.plOneFrame.textWins:SetText(text .. player[1].wins);
		elseif (id == 2) then
			MainFrame.ScrollFrame.StatsFrame.plTwoFrame.textWins:SetText(text .. player[2].wins);
		end
	elseif (data == "defeats") then
		if (id == 1) then
			MainFrame.ScrollFrame.StatsFrame.plOneFrame.textDefeats:SetText(text .. player[1].defeats);
		elseif (id == 2) then
			MainFrame.ScrollFrame.StatsFrame.plTwoFrame.textDefeats:SetText(text .. player[2].defeats);
		end
	elseif (data == "playedGames") then
		if (id == 1) then
			MainFrame.ScrollFrame.StatsFrame.plOneFrame.textGames:SetText(text .. player[1].playedGames);
		elseif (id == 2) then
			MainFrame.ScrollFrame.StatsFrame.plTwoFrame.textGames:SetText(text .. player[2].playedGames);
		end
	end
end

function Config:CreateConfigMenu()
	-- Creates the MainFrame.ScrollFrame.ConfigFrame
	MainFrame.ScrollFrame.ConfigFrame = CreateFrame("Frame", "TicTacToe_ConfigFrame", MainFrame.ScrollFrame, "InsetFrameTemplate");
	MainFrame.ScrollFrame.ConfigFrame:ClearAllPoints();
	MainFrame.ScrollFrame.ConfigFrame:SetSize(MainFrame.ScrollFrame:GetWidth(), default.size.expanded.height); -- width, height
	MainFrame.ScrollFrame.ConfigFrame:SetPoint("TOP", MainFrame.ScrollFrame.SpaceFrame, "BOTTOM"); -- point, relativeFrame, relativePoint, xOffset, yOffset

	-- this is for the CheckBox if you want to play a solo game
	MainFrame.ScrollFrame.ConfigFrame.soloCheckBox = CreateFrame("CheckButton", nil, MainFrame.ScrollFrame.ConfigFrame, "UICheckButtonTemplate");
	MainFrame.ScrollFrame.ConfigFrame.soloCheckBox:ClearAllPoints();
	MainFrame.ScrollFrame.ConfigFrame.soloCheckBox:SetSize(30, 30); -- width, height
	MainFrame.ScrollFrame.ConfigFrame.soloCheckBox:SetPoint("TOPLEFT", MainFrame.ScrollFrame.ConfigFrame, "TOPLEFT", 5, -10);
	MainFrame.ScrollFrame.ConfigFrame.soloCheckBox.text = MainFrame.ScrollFrame.ConfigFrame.soloCheckBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.ScrollFrame.ConfigFrame.soloCheckBox.text:SetPoint("LEFT", MainFrame.ScrollFrame.ConfigFrame.soloCheckBox, "RIGHT", 0, 0);
	MainFrame.ScrollFrame.ConfigFrame.soloCheckBox.text:SetText("Singleplayer");
	MainFrame.ScrollFrame.ConfigFrame.soloCheckBox:SetScript("OnClick", function(self)
			if (self:GetChecked()) then
				singleplayer = true;
			else
				singleplayer = false;
			end
		end);

	if (singleplayer) then
		MainFrame.ScrollFrame.ConfigFrame.soloCheckBox:SetChecked(true);
	else
		MainFrame.ScrollFrame.ConfigFrame.soloCheckBox:SetChecked(false);
	end

	-- this CheckBox is if you want to play in whisper Mode
	MainFrame.ScrollFrame.ConfigFrame.whisperCheckBox = CreateFrame("CheckButton", nil, MainFrame.ScrollFrame.ConfigFrame, "UICheckButtonTemplate");
	MainFrame.ScrollFrame.ConfigFrame.whisperCheckBox:ClearAllPoints();
	MainFrame.ScrollFrame.ConfigFrame.whisperCheckBox:SetSize(30, 30); -- width, height
	MainFrame.ScrollFrame.ConfigFrame.whisperCheckBox:SetPoint("TOP", MainFrame.ScrollFrame.ConfigFrame.soloCheckBox, "BOTTOM", 0, 0);
	MainFrame.ScrollFrame.ConfigFrame.whisperCheckBox.text = MainFrame.ScrollFrame.ConfigFrame.whisperCheckBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.ScrollFrame.ConfigFrame.whisperCheckBox.text:SetPoint("LEFT", MainFrame.ScrollFrame.ConfigFrame.whisperCheckBox, "RIGHT", 0, 0);
	MainFrame.ScrollFrame.ConfigFrame.whisperCheckBox.text:SetText("Whisper Mode");
	-- MainFrame.ScrollFrame.ConfigFrame.whisperCheckBox:SetPoint("LEFT", MainFrame.ScrollFrame.ConfigFrame.whisperCheckBox.text, "RIGHT", 0, 0);
	MainFrame.ScrollFrame.ConfigFrame.whisperCheckBox:SetScript("OnClick", function(self)
			if (self:GetChecked()) then
				chatType = "WHISPER";
				whisperMode = true;
			else
				chatType = "EMOTE";
				whisperMode = false;
			end

			if (whisperMode) then
				MainFrame.ScrollFrame.ConfigFrame.whisperEditBox:Enable();
			else
				MainFrame.ScrollFrame.ConfigFrame.whisperEditBox:Disable();
			end
		end);

	if (whisperMode) then
		MainFrame.ScrollFrame.ConfigFrame.whisperCheckBox:SetChecked(true);
	else
		MainFrame.ScrollFrame.ConfigFrame.whisperCheckBox:SetChecked(false);
	end

	-- this creates the TextBox in which you can write the Targe Name for whispering
	MainFrame.ScrollFrame.ConfigFrame.whisperEditBox = CreateFrame("EditBox", nil, MainFrame.ScrollFrame.ConfigFrame, "InputBoxTemplate");
	MainFrame.ScrollFrame.ConfigFrame.whisperEditBox:ClearAllPoints();
	MainFrame.ScrollFrame.ConfigFrame.whisperEditBox:SetSize(75, 30);
	MainFrame.ScrollFrame.ConfigFrame.whisperEditBox:SetPoint("LEFT", MainFrame.ScrollFrame.ConfigFrame.whisperCheckBox.text, "RIGHT", 10, 0);
	MainFrame.ScrollFrame.ConfigFrame.whisperEditBox:SetAutoFocus(false);
	MainFrame.ScrollFrame.ConfigFrame.whisperEditBox:SetScript("OnTextChanged", function(self)
			if (self:GetText() == "") then
				whisperTarget = nil;
			else
				whisperTarget = self:GetText();
			end
		end);
	if (whisperMode) then
		MainFrame.ScrollFrame.ConfigFrame.whisperEditBox:Enable();
	else
		MainFrame.ScrollFrame.ConfigFrame.whisperEditBox:Disable();
	end
	MainFrame.ScrollFrame.ConfigFrame.whisperEditBox:SetScript("OnEnterPressed", function(self) self:ClearFocus(); end);
		
	-- this Button invites another Player to the game
	MainFrame.ScrollFrame.ConfigFrame.inviteButton = CreateFrame("Button", nil, MainFrame.ScrollFrame.ConfigFrame, "GameMenuButtonTemplate");
	MainFrame.ScrollFrame.ConfigFrame.inviteButton:ClearAllPoints();
	MainFrame.ScrollFrame.ConfigFrame.inviteButton:SetSize(120, 30); -- width, height
	MainFrame.ScrollFrame.ConfigFrame.inviteButton:SetPoint("TOPLEFT", MainFrame.ScrollFrame.ConfigFrame.whisperCheckBox, "BOTTOMLEFT", 0,0);
	MainFrame.ScrollFrame.ConfigFrame.inviteButton.text = MainFrame.ScrollFrame.ConfigFrame.inviteButton:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.ScrollFrame.ConfigFrame.inviteButton.text:SetPoint("CENTER", MainFrame.ScrollFrame.ConfigFrame.inviteButton, "CENTER", 0,0);
	MainFrame.ScrollFrame.ConfigFrame.inviteButton.text:SetText("Invite");
	
	MainFrame.ScrollFrame.ConfigFrame.inviteEditBox = CreateFrame("EditBox", nil, MainFrame.ScrollFrame.ConfigFrame, "InputBoxTemplate");
	MainFrame.ScrollFrame.ConfigFrame.inviteEditBox:ClearAllPoints();
	MainFrame.ScrollFrame.ConfigFrame.inviteEditBox:SetSize(75, 30);
	MainFrame.ScrollFrame.ConfigFrame.inviteEditBox:SetPoint("TOPLEFT", MainFrame.ScrollFrame.ConfigFrame.whisperEditBox, "BOTTOMLEFT", 0, 0);
	MainFrame.ScrollFrame.ConfigFrame.inviteEditBox:SetAutoFocus(false);
	MainFrame.ScrollFrame.ConfigFrame.inviteEditBox:SetScript("OnEnterPressed", function(self) self:ClearFocus(); InvitePlayer(self); end);
	MainFrame.ScrollFrame.ConfigFrame.inviteEditBox:SetScript("OnTextChanged", function(self)
			if (self:GetText() ~= "") then
				MainFrame.ScrollFrame.ConfigFrame.inviteButton:Enable();
			else
				MainFrame.ScrollFrame.ConfigFrame.inviteButton:Disable();
			end
		end);
	
	MainFrame.ScrollFrame.ConfigFrame.inviteButton:SetScript("OnClick", function(self)
			if (MainFrame.ScrollFrame.ConfigFrame.inviteEditBox:GetText() == "") then
				MainFrame.ScrollFrame.ConfigFrame.inviteEditBox:SetFocus();
			else
				InvitePlayer();
			end
		end);
	if (MainFrame.ScrollFrame.ConfigFrame.inviteEditBox:GetText() == "") then
		MainFrame.ScrollFrame.ConfigFrame.inviteButton:Disable();
	else
		MainFrame.ScrollFrame.ConfigFrame.inviteButton:Enable();
	end

	MainFrame.ScrollFrame.ConfigFrame.targetButton = CreateFrame("Button", nil, MainFrame.ScrollFrame.ConfigFrame, "GameMenuButtonTemplate");
	MainFrame.ScrollFrame.ConfigFrame.targetButton:ClearAllPoints();
	MainFrame.ScrollFrame.ConfigFrame.targetButton:SetSize(84, 30);
	MainFrame.ScrollFrame.ConfigFrame.targetButton:SetPoint("BOTTOM", MainFrame.ScrollFrame.ConfigFrame.whisperEditBox, "TOP", -2, 0);
	MainFrame.ScrollFrame.ConfigFrame.targetButton.text = MainFrame.ScrollFrame.ConfigFrame.targetButton:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.ScrollFrame.ConfigFrame.targetButton.text:SetPoint("CENTER", MainFrame.ScrollFrame.ConfigFrame.targetButton, "CENTER", 0,0);
	MainFrame.ScrollFrame.ConfigFrame.targetButton.text:SetText("Target");
	MainFrame.ScrollFrame.ConfigFrame.targetButton:SetScript("OnEnter", function(self)
			if (UnitName("target")) then
				self.text:SetText(UnitName("target"));
			end
		end);
	MainFrame.ScrollFrame.ConfigFrame.targetButton:SetScript("OnLeave", function(self)
			self.text:SetText("Target");
		end);
	MainFrame.ScrollFrame.ConfigFrame.targetButton:SetScript("OnClick", function(self)
			local target = UnitName("target")
			if (target ~= UnitName("player")) then
				if (target) then
					MainFrame.ScrollFrame.ConfigFrame.whisperEditBox:SetText(target);
					MainFrame.ScrollFrame.ConfigFrame.inviteEditBox:SetText(target);
				else
					MainFrame.ScrollFrame.ConfigFrame.whisperEditBox:SetText("");
					MainFrame.ScrollFrame.ConfigFrame.inviteEditBox:SetText("");
				end
			end
		end);
		
		-- this is for testing the DropDown Menu
	MainFrame.ScrollFrame.ConfigFrame.DropDownMenu = CreateFrame("Button", "DropDownMenu", MainFrame.ScrollFrame.ConfigFrame, "UIDropDownMenuTemplate");
	MainFrame.ScrollFrame.ConfigFrame.DropDownMenu:ClearAllPoints();
	MainFrame.ScrollFrame.ConfigFrame.DropDownMenu:SetSize(100, 30);
	MainFrame.ScrollFrame.ConfigFrame.DropDownMenu:SetPoint("TOPLEFT", MainFrame.ScrollFrame.ConfigFrame.inviteButton, "BOTTOMLEFT", -17, -10);
	
	local items = {
		"Alpha",
		"Beta",
		"Gamma",
		"Delta",
	}

	MainFrame.ScrollFrame.ConfigFrame.DropDownMenu:SetScript("OnClick", function(self)
		UIDropDownMenu_SetSelectedID(MainFrame.ScrollFrame.ConfigFrame.DropDownMenu, self:GetID();
	end);
	
	local function initialize(self, level)
		local info = UIDropDownMenu_CreateInfo();
		for k,v in pairs(items) do
			info = UIDropDownMenu_CreateInfo();
			info.text = v;
			info.value = v;
			info.func = OnClick;
			UIDropDownMenu_AddButton(info, level);
		end
	end

	UIDropDownMenu_Initialize(MainFrame.ScrollFrame.ConfigFrame.DropDownMenu, initialize);
	UIDropDownMenu_SetWidth(MainFrame.ScrollFrame.ConfigFrame.DropDownMenu, 100);
	UIDropDownMenu_SetButtonWidth(MainFrame.ScrollFrame.ConfigFrame.DropDownMenu, 124);
	UIDropDownMenu_SetSelectedID(MainFrame.ScrollFrame.ConfigFrame.DropDownMenu, 1);
	UIDropDownMenu_JustifyText(MainFrame.ScrollFrame.ConfigFrame.DropDownMenu, "LEFT");
end

---------------------------------
-- PopUps
---------------------------------
StaticPopupDialogs["TICTACTOE_INVITATION"] = {
	text = "You have been invited to play Tic Tac Toe. Do you want to accept this invitation?",
	button1 = "Accept",
	button2 = "Decline",
	OnAccept = function()
		AcceptingInvitation();
	end,
	OnCancel = function()
		DecliningInvitation();
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}
	
---------------------------------
-- Events
---------------------------------
local msgEmote = CreateFrame("Frame");
msgEmote:RegisterEvent("CHAT_MSG_EMOTE");
msgEmote:SetScript("OnEvent", ReceiveInput);

local msgWhisper = CreateFrame("Frame");
msgWhisper:RegisterEvent("CHAT_MSG_WHISPER");
msgWhisper:SetScript("OnEvent", ReceiveInput);





