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
		y = yCenter / 1.3,
	},
}


--------------------------------------
-- Initializing Variables
--------------------------------------
local Config = core.Config;
local MainFrame;
local ConfigFrame;

local xPosition = default.position.x;
local yPosition = default.position.y;

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


--------------------------------------
-- Config functions
--------------------------------------
function Config:Exit()
	if (not singleplayer and curPlayerTwo ~= "") then
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
	ConfigFrame:Hide();
	ConfigFrame = nil;
	MainFrame.title:SetText(default.title);
	MainFrame = nil;
end

function Config:Reset()
	SendChatMessage("has reseted the game.", chatType);
	core.Config.Exit();
	core.Config.Toggle();
end

function Config:ResetPosition()
	xPosition = default.position.x;
	yPosition = default.position.y;
end

function Config:Singleplayer()
	if (singleplayer == false) then
		if (ConfigFrame) then
			ConfigFrame.soloCheckBox:SetChecked(true);
		end
		singleplayer = true;
	else
		if (ConfigFrame) then
			ConfigFrame.soloCheckBox:SetChecked(false);
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

-- this function disables all Buttons
local function DisableFields()
	for i = 1, #MainFrame.gameFrame.field do
		MainFrame.gameFrame.field[i]:Disable();
	end
end

local function DisableBlacklistedFields()
	for i = 1, #blackList do
		local c = blackList:sub(i,i)
		MainFrame.gameFrame.field[tonumber(c)]:Disable();
	end
end

-- this function enables all Buttons
local function EnableFields()
	for i = 1, #MainFrame.gameFrame.field do
		MainFrame.gameFrame.field[i]:Enable();
	end
end

local function InvitePlayer()
	if ConfigFrame.inviteEditBox ~= "" then
		SendChatMessage("has invited " ..ConfigFrame.inviteEditBox:GetText().. " to play Tic Tac Toe.", chatType, nil, whisperTarget);
	end
end

-- this function is for multiplayer. It sends a Message which Button the player has clicked as an emote.
local function Field_Onclick(self)
	if (singleplayer == false) then
		if (playerX) then
			SendChatMessage("has put an X on the field : " .. self:GetID(), chatType, nil, whisperTarget);
		else
			SendChatMessage("has put an O on the field : " .. self:GetID(), chatType, nil, whisperTarget);
		end
	end

	-- if it is not your turn, this disables for you the Buttons
	SelectField(self:GetID());
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

local function checkIfWon(frst, scnd, thrd)
	if ((MainFrame.gameFrame.field[frst]:GetText() == MainFrame.gameFrame.field[scnd]:GetText()) and (MainFrame.gameFrame.field[frst]:GetText() == MainFrame.gameFrame.field[thrd]:GetText()) and (MainFrame.gameFrame.field[frst]:GetText() ~= nil)) then
		MainFrame.gameFrame.field[frst]:LockHighlight();
		MainFrame.gameFrame.field[scnd]:LockHighlight();
		MainFrame.gameFrame.field[thrd]:LockHighlight();
		if (myTurn == true) and (singleplayer == false) then
			SendChatMessage("won the game!", chatType);
			DoEmote("DANCE", none);
		elseif (myTurn == false) and (singleplayer == false) then
			DoEmote("CRY", curPlayerTwo);
		end
		DisableFields();
		return true;
	end
end

--------------------------------------
-- Functions
--------------------------------------
function SelectField(key)
	if (not string.find(blackList, tostring(key))) then
		MainFrame.gameFrame.field[tonumber(key)]:Disable();
		counter = counter + 1;
		if (playerX == true) then
			MainFrame.gameFrame.field[key]:SetText("X");
			playerX = false;
		else
			MainFrame.gameFrame.field[key]:SetText("O");
			playerX = true;
		end

		blackList = blackList .. key;

		-- This is in case you win or lose. It disables all buttons, highlight them and do an emote.
		if (counter >= 5) then
			win = checkIfWon(1, 2, 3);
			win = checkIfWon(4, 5, 6);
			win = checkIfWon(7, 8, 9);
			win = checkIfWon(1, 4, 7);
			win = checkIfWon(2, 5, 8);
			win = checkIfWon(3, 6, 9);
			win = checkIfWon(1, 5, 9);
			win = checkIfWon(3, 5, 7);
		end
	end

	-- If it is undecided, both player applaud.
	if (counter >= 9) and (win == false) then
		if (singleplayer == false) then
			DoEmote("APPLAUD");
		end
	end
end


---------------------------------
-- Buttons
---------------------------------
local function SetButtons(frame, numButtons)
	frame.numButtons = numButtons;
	
	local contents = {};
	local frameName = frame:GetName();
	
	for i = 1, numButtons do	
		local button = CreateFrame("Button", frameName.."_Button"..i, frame, "GameMenuButtonTemplate");
		
		button:SetID(i);
		button:SetText(i);
		bottom:SetSize(70, 70);
		bottom:SetNormalFontObject("GameFontNormalLarge");
		bottom:SetHighlightFontObject("GameFontHighlightLarge");

		button:SetScript("OnClick", Button_OnClick);
		
		-- just for tutorial only:
		button.content.bg = button.content:CreateTexture(nil, "BACKGROUND");
		button.content.bg:SetAllPoints(true);
		button.content.bg:SetColorTexture(math.random(), math.random(), math.random(), 0.6);
		
		table.insert(contents);
		
		if 		(i == 1) then button:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -24);
		elseif	(i == 2) then button:SetPoint("TOP", frame, "TOP", 0, -24);
		elseif	(i == 3) then button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -24);
		elseif	(i == 4) then button:SetPoint("LEFT", frame, "LEFT", 12, -6);
		elseif	(i == 5) then button:SetPoint("CENTER", frame, "CENTER", 0, -6);
		elseif	(i == 6) then button:SetPoint("RIGHT", frame, "RIGHT", -12, -6);
		elseif	(i == 7) then button:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 12, 12);
		elseif	(i == 8) then button:SetPoint("BOTTOM", frame, "BOTTOM", 0, 12);
		elseif	(i == 9) then button:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 12);
		end
	end
	
	-- Tab_OnClick(_G[frameName.."Tab1"]);
	
	return unpack(contents);
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
		if (senderName ~= UnitName("player") and argsMsg[6] == (UnitName("player") .. ".")) then
			-- Here needs to be what happens, when the invitation gets accepted.
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
		if (fieldId == ("1" or "2" or "3" or "4" or "5" or "6" or "7" or "8" or "9")) then
			-- Senders name mustn't be the own player name.
			if (senderName ~= UnitName("player")) then
				-- If there is no player two, it will be set here.
				if (curPlayerTwo == "") then
					curPlayerTwo = senderName;
					-- MainFrame.title:SetText(curPlayerOne .. " VS " .. curPlayerTwo);
				end

				-- To avoid people spoiling the game, it will be checked, if the senders name is correct.
				if (curPlayerTwo == senderName) then
					EnableFields();
					DisableBlacklistedFields();
					
					SelectField(tonumber(fieldId));
					myTurn = true;
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

local function AcceptingInvitation()
	SendChatMessage("has accepted the invitation of " .. invitationSender .. ".", chatType);
	core.Config.Toggle()
end

local function DecliningInvitation()
	SendChatMessage("has declined the invitation of" .. invitationSender .. ".", chatType);
end

---------------------------------
-- Main Frame
---------------------------------
function Config:CreateMainMenu() -- creates the Main Frame
	MainFrame = CreateFrame("Frame", "TicTacToe_MainFrame", UIParent, "BasicFrameTemplate");
	MainFrame:ClearAllPoints();
	MainFrame:SetSize(250, 390); -- width, height
	MainFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", xPosition, yPosition); -- point, relativeFrame, relativePoint, xOffset, yOffset
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
	   local xOffset, yOffset = self:GetCenter();
	   xPosition = xOffset;
	   yPosition = yOffset;
	  end
	end)
	MainFrame:SetScript("OnHide", function(self)
	  if On( self.isMoving ) then
	   self:StopMovingOrSizing();
	   self.isMoving = false;
	  end
	  core.Config.Exit();
	end)
	MainFrame:SetScript("OnHide", function(self) ConfigFrame:Hide(); end)

	MainFrame.gameFrame = CreateFrame("Frame", "TicTacToe_MainFrame_GameFrame", MainFrame, "InsetFrameTemplate");
	MainFrame.gameFrame:ClearAllPoints();
	MainFrame.gameFrame:SetSize(240, 205);
	MainFrame.gameFrame:SetPoint("TOP", MainFrame, "TOP", 0, -25);


	MainFrame.configBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
	MainFrame.configBtn:ClearAllPoints();
	MainFrame.configBtn:SetWidth(50); -- width, height
	MainFrame.configBtn:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", -24, 0);
	MainFrame.configBtn:SetScript("OnClick", function(self) if (ConfigFrame:IsShown()) then ConfigFrame:Hide(); else ConfigFrame:Show(); end end);
	MainFrame.configBtn.title = MainFrame.configBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.configBtn.title:SetPoint("LEFT", MainFrame.configBtn, "LEFT", 5, 0);
	MainFrame.configBtn.title:SetText("Config");

	MainFrame.resetBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
	MainFrame.resetBtn:ClearAllPoints();
	MainFrame.resetBtn:SetWidth(50); -- width, height
	MainFrame.resetBtn:SetPoint("RIGHT", MainFrame.configBtn, "LEFT", 0, 0);
	MainFrame.resetBtn:SetScript("OnClick", Config.Reset);
	MainFrame.resetBtn.title = MainFrame.resetBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.resetBtn.title:SetPoint("LEFT", MainFrame.resetBtn, "LEFT", 5, 0);
	MainFrame.resetBtn.title:SetText("Reset");

	-- Creates the 9 Buttons in the MainFrame
	MainFrame.gameFrame.field = {
		self:CreateButton(1, "TOPLEFT",		MainFrame.gameFrame,	"TOPLEFT",		4,	-2, "");
		self:CreateButton(2, "TOP", 		MainFrame.gameFrame,	"TOP",			0,	-2, "");
		self:CreateButton(3, "TOPRIGHT", 	MainFrame.gameFrame,	"TOPRIGHT",		-4,	-2, "");
		self:CreateButton(4, "LEFT",		MainFrame.gameFrame,	"LEFT",			4,	0,	"");
		self:CreateButton(5, "CENTER",		MainFrame.gameFrame,	"CENTER",		0,	0, "");
		self:CreateButton(6, "RIGHT",		MainFrame.gameFrame,	"RIGHT",		-4,	0, "");
		self:CreateButton(7, "BOTTOMLEFT", 	MainFrame.gameFrame,	"BOTTOMLEFT",	4,	2, "");
		self:CreateButton(8, "BOTTOM", 		MainFrame.gameFrame,	"BOTTOM",		0,	2, "");
		self:CreateButton(9, "BOTTOMRIGHT", MainFrame.gameFrame,	"BOTTOMRIGHT",	-4,	2, "");
	}

	Config.CreateConfigMenu();

	MainFrame:Hide();
	return MainFrame;
end

function Config:CreateConfigMenu()
	-- Creates the ConfigFrame
	ConfigFrame = CreateFrame("Frame", "TicTacToe_ConfigFrame", MainFrame, "InsetFrameTemplate");
	ConfigFrame:SetSize(MainFrame.gameFrame:GetWidth(), 150); -- width, height
	ConfigFrame:SetPoint("TOP", MainFrame.gameFrame, "BOTTOM"); -- point, relativeFrame, relativePoint, xOffset, yOffset
	ConfigFrame.title = ConfigFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	ConfigFrame.title:SetPoint("TOPLEFT", MainFrame.gameFrame, "BOTTOMLEFT", 10, -10);
	ConfigFrame.title:SetText("Configuration");
	ConfigFrame:Hide();

	-- this is for the CheckBox if you want to play a solo game
	ConfigFrame.soloCheckBox = CreateFrame("CheckButton", nil, ConfigFrame, "UICheckButtonTemplate");
	ConfigFrame.soloCheckBox:ClearAllPoints();
	ConfigFrame.soloCheckBox:SetSize(30, 30); -- width, height
	ConfigFrame.soloCheckBox:SetPoint("TOPLEFT", ConfigFrame, "TOPLEFT", 8, -32);
	ConfigFrame.soloCheckBox.text = ConfigFrame.soloCheckBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	ConfigFrame.soloCheckBox.text:SetPoint("LEFT", ConfigFrame.soloCheckBox, "RIGHT", 0, 0);
	ConfigFrame.soloCheckBox.text:SetText("Singleplayer");
	ConfigFrame.soloCheckBox:SetScript("OnClick", function(self)
			if (self:GetChecked()) then
				singleplayer = true;
			else
				singleplayer = false;
			end
		end);

	if (singleplayer) then
		ConfigFrame.soloCheckBox:SetChecked(true);
	else
		ConfigFrame.soloCheckBox:SetChecked(false);
	end

	-- this CheckBox is if you want to play in whisper Mode
	ConfigFrame.whisperCheckBox = CreateFrame("CheckButton", nil, ConfigFrame, "UICheckButtonTemplate");
	ConfigFrame.whisperCheckBox:ClearAllPoints();
	ConfigFrame.whisperCheckBox:SetSize(30, 30); -- width, height
	ConfigFrame.whisperCheckBox:SetPoint("TOP", ConfigFrame.soloCheckBox, "BOTTOM", 0, 0);
	ConfigFrame.whisperCheckBox.text = ConfigFrame.whisperCheckBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	ConfigFrame.whisperCheckBox.text:SetPoint("LEFT", ConfigFrame.whisperCheckBox, "RIGHT", 0, 0);
	ConfigFrame.whisperCheckBox.text:SetText("Whisper Mode");
	-- ConfigFrame.whisperCheckBox:SetPoint("LEFT", ConfigFrame.whisperCheckBox.text, "RIGHT", 0, 0);
	ConfigFrame.whisperCheckBox:SetScript("OnClick", function(self)
			if (self:GetChecked()) then
				chatType = "WHISPER";
				whisperMode = true;
			else
				chatType = "EMOTE";
				whisperMode = false;
			end

			if (whisperMode) then
				ConfigFrame.whisperEditBox:Enable();
			else
				ConfigFrame.whisperEditBox:Disable();
			end
		end);

	if (whisperMode) then
		ConfigFrame.whisperCheckBox:SetChecked(true);
	else
		ConfigFrame.whisperCheckBox:SetChecked(false);
	end


	ConfigFrame.whisperEditBox = CreateFrame("EditBox", nil, ConfigFrame, "InputBoxTemplate");
	ConfigFrame.whisperEditBox:ClearAllPoints();
	ConfigFrame.whisperEditBox:SetSize(80, 30);
	ConfigFrame.whisperEditBox:SetPoint("LEFT", ConfigFrame.whisperCheckBox.text, "RIGHT", 10, 0);
	ConfigFrame.whisperEditBox:SetAutoFocus(false);
	ConfigFrame.whisperEditBox:SetScript("OnTextChanged", function(self)
			if (self:GetText() == "") then
				whisperTarget = nil;
			else
				whisperTarget = self:GetText();
			end
		end);
	if (whisperMode) then
		ConfigFrame.whisperEditBox:Enable();
	else
		ConfigFrame.whisperEditBox:Disable();
	end
	ConfigFrame.whisperEditBox:SetScript("OnEnterPressed", function(self) self:ClearFocus(); end);
		
	-- this Button invites another Player to the game
	ConfigFrame.inviteButton = CreateFrame("Button", nil, ConfigFrame, "GameMenuButtonTemplate");
	ConfigFrame.inviteButton:ClearAllPoints();
	ConfigFrame.inviteButton:SetSize(120, 30); -- width, height
	ConfigFrame.inviteButton:SetPoint("TOPLEFT", ConfigFrame.whisperCheckBox, "BOTTOMLEFT", 0,0);
	ConfigFrame.inviteButton.text = ConfigFrame.inviteButton:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	ConfigFrame.inviteButton.text:SetPoint("CENTER", ConfigFrame.inviteButton, "CENTER", 0,0);
	ConfigFrame.inviteButton.text:SetText("Invite");
	
	ConfigFrame.inviteEditBox = CreateFrame("EditBox", nil, ConfigFrame, "InputBoxTemplate");
	ConfigFrame.inviteEditBox:ClearAllPoints();
	ConfigFrame.inviteEditBox:SetSize(80, 30);
	ConfigFrame.inviteEditBox:SetPoint("TOPLEFT", ConfigFrame.whisperEditBox, "BOTTOMLEFT", 0, 0);
	ConfigFrame.inviteEditBox:SetAutoFocus(false);
	ConfigFrame.inviteEditBox:SetScript("OnEnterPressed", function(self) self:ClearFocus(); InvitePlayer(self); end);
	ConfigFrame.inviteEditBox:SetScript("OnTextChanged", function(self)
			if (self:GetText() ~= "") then
				ConfigFrame.inviteButton:Enable();
			else
				ConfigFrame.inviteButton:Disable();
			end
		end);
	
	ConfigFrame.inviteButton:SetScript("OnClick", function(self)
			if (ConfigFrame.inviteEditBox:GetText() == "") then
				ConfigFrame.inviteEditBox:SetFocus();
			else
				InvitePlayer();
			end
		end);
	if (ConfigFrame.inviteEditBox:GetText() == "") then
		ConfigFrame.inviteButton:Disable();
	else
		ConfigFrame.inviteButton:Enable();
	end

	ConfigFrame.targetButton = CreateFrame("Button", nil, ConfigFrame, "GameMenuButtonTemplate");
	ConfigFrame.targetButton:ClearAllPoints();
	ConfigFrame.targetButton:SetSize(90, 30);
	ConfigFrame.targetButton:SetPoint("BOTTOM", ConfigFrame.whisperEditBox, "TOP", -2, 0);
	ConfigFrame.targetButton.text = ConfigFrame.targetButton:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	ConfigFrame.targetButton.text:SetPoint("CENTER", ConfigFrame.targetButton, "CENTER", 0,0);
	ConfigFrame.targetButton.text:SetText("Target");
	ConfigFrame.targetButton:SetScript("OnEnter", function(self)
			if (UnitName("target")) then
				self.text:SetText(UnitName("target"));
			end
		end);
	ConfigFrame.targetButton:SetScript("OnLeave", function(self)
			self.text:SetText("Target");
		end);
	ConfigFrame.targetButton:SetScript("OnClick", function(self)
			local target = UnitName("target")
			if (target ~= UnitName("player")) then
				if (target) then
					ConfigFrame.whisperEditBox:SetText(target);
					ConfigFrame.inviteEditBox:SetText(target);
				else
					ConfigFrame.whisperEditBox:SetText("");
					ConfigFrame.inviteEditBox:SetText("");
				end
			end
		end);
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





