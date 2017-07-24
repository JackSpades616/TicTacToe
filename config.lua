--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;
core.Config = {}; -- adds Config table to addon namespace

--------------------------------------
-- Defaults (usually a database!)
--------------------------------------
local defaults = {
	theme = {
		r = 0, 
		g = 0.8, -- 204/255
		b = 1,
		hex = "00ccff"
	} 
}

local xPositionDefault, yPositionDefault = UIParent:GetCenter();
xPositionDefault = xPositionDefault * 1.5;
yPositionDefault = yPositionDefault / 2;


--------------------------------------
-- Initializing Variables
--------------------------------------
local Config = core.Config;
local MainFrame;
local ConfigFrame;

local Title = "Tic Tac Toe";
local xPosition = xPositionDefault;
local yPosition = yPositionDefault;
local playerOne = UnitName("player");
local playerTwo = "";
local myTurn = true;
local playerX = true;
local singleplayer = false;
local counter = 0;
local win = false;
local blackList = "";


---------------------------------
-- Main Frame
---------------------------------
function Config:CreateMenu() -- creates the Main Frame
	MainFrame = CreateFrame("Frame", "TicTacToe_MainFrame", UIParent, "BasicFrameTemplateWithInset");
	MainFrame:SetSize(240, 240); -- width, height
	MainFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", xPosition, yPosition); -- point, relativeFrame, relativePoint, xOffset, yOffset
	MainFrame.title = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	MainFrame.title:SetPoint("LEFT", MainFrame.TitleBg, "LEFT", 5, 0);
	MainFrame.title:SetText(Title);
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
	MainFrame.field = {
		self:CreateButton(1, "TOPLEFT",		MainFrame,	"TOPLEFT",		12,		-24, "");
		self:CreateButton(2, "TOP", 		MainFrame,	"TOP",			0,		-24, "");
		self:CreateButton(3, "TOPRIGHT", 	MainFrame,	"TOPRIGHT",		-12,	-24, "");
		self:CreateButton(4, "LEFT",		MainFrame,	"LEFT",			12,		-6,	"");
		self:CreateButton(5, "CENTER",		MainFrame,	"CENTER",		0,		-6, "");
		self:CreateButton(6, "RIGHT",		MainFrame,	"RIGHT",		-12,	-6, "");
		self:CreateButton(7, "BOTTOMLEFT", 	MainFrame,	"BOTTOMLEFT",	12,		12, "");
		self:CreateButton(8, "BOTTOM", 		MainFrame,	"BOTTOM",		0,		12, "");
		self:CreateButton(9, "BOTTOMRIGHT", MainFrame,	"BOTTOMRIGHT",	-12,	12, "");
	}  

	Config.CreateConfigMenu();

	 MainFrame:Hide();
	 return MainFrame;
end

function Config:CreateConfigMenu()
	-- Creates the ConfigFrame
	ConfigFrame = CreateFrame("Frame", "TicTacToe_ConfigFrame", MainFrame, "BasicFrameTemplateWithInset");
	ConfigFrame:SetSize(MainFrame:GetWidth(), 80); -- width, height
	ConfigFrame:SetPoint("TOP", MainFrame, "BOTTOM"); -- point, relativeFrame, relativePoint, xOffset, yOffset
	ConfigFrame.title = ConfigFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	ConfigFrame.title:SetPoint("LEFT", ConfigFrame.TitleBg, "LEFT", 5, 0);
	ConfigFrame.title:SetText("Configuration");
	ConfigFrame:Hide();

	-- this is for the CheckBox if you want to play a solo game
	ConfigFrame.soloCheckBox = CreateFrame("CheckButton", nil, ConfigFrame, "UICheckButtonTemplate");
	ConfigFrame.soloCheckBox:ClearAllPoints();
	ConfigFrame.soloCheckBox:SetSize(30, 30); -- width, height
	ConfigFrame.soloCheckBox.text = ConfigFrame.soloCheckBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	ConfigFrame.soloCheckBox.text:SetPoint("TOPLEFT", ConfigFrame, "TOPLEFT", 12, -32);
	ConfigFrame.soloCheckBox.text:SetText("Singleplayer");
	ConfigFrame.soloCheckBox:SetPoint("LEFT", ConfigFrame.soloCheckBox.text, "RIGHT", 0, 0);

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
end

--------------------------------------
-- Config functions
--------------------------------------
function Config:Exit()
	if (not singleplayer and playerTwo ~= "") then
		SendChatMessage("has quit the game.", "EMOTE");
	end
	myTurn = true;
	playerTwo = "";
	playerX = true;
	--singleplayer = false;
	blackList = "";
	counter = 0;
	win = false;
	MainFrame:Hide();
	ConfigFrame:Hide();
	ConfigFrame = nil;
	MainFrame.title:SetText(Title);
	MainFrame = nil;
end

function Config:Reset()
	core.Config.Exit();
	core.Config.Toggle();
end

function Config:ResetPosition()
	xPosition = xPositionDefault;
	yPosition = yPositionDefault;
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
	local c = defaults.theme;
	return c.r, c.g, c.b, c.hex;
end

function Config:Toggle()
	local menu = MainFrame or Config:CreateMenu();
	menu:SetShown(not menu:IsShown());
end

-- this function disables all Buttons
local function DisableFields()
	for i = 1, #MainFrame.field do
		MainFrame.field[i]:Disable();
	end
end

-- this function enables all Buttons
local function EnableFields()
	for i = 1, #MainFrame.field do
		MainFrame.field[i]:Enable();
	end
end

-- this function is for multiplayer. It sends a Message which Button the player has clicked as an emote.
local function Field_Onclick(self)
	if (singleplayer == false) then
		if (playerX) then
			SendChatMessage("has put an X on the field : " .. self:GetID(), "EMOTE");
		else
			SendChatMessage("has put an O on the field : " .. self:GetID(), "EMOTE");
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



--------------------------------------
-- Functions
--------------------------------------
function SelectField(key)
	if (string.find(blackList, tostring(key))) then
	else
		MainFrame.field[tonumber(key)]:Disable();
		counter = counter + 1;
		if (playerX == true) then
			MainFrame.field[key]:SetText("X");
			playerX = false;
		else
			MainFrame.field[key]:SetText("O");
			playerX = true;
		end

		blackList = blackList .. key;

		-- This is in case you win or lose. It disables all buttons, highlight them and do an emote.
		if (counter >= 5) then
			--[[
			local btnOne = MainFrame.field[1];
			local btnTwo = MainFrame.field[2];
			local btnThree = MainFrame.field[3]:LockHighlight();
			local btnFour = MainFrame.field[4]:LockHighlight();
			local btnFive = MainFrame.field[5]:LockHighlight();
			local btnSix = MainFrame.field[6]:LockHighlight();
			local btnSeven = MainFrame.field[7]:LockHighlight();
			local btnEight = MainFrame.field[8]:LockHighlight();
			local btnNine = MainFrame.field[9]:LockHighlight();
			]]

			if ((MainFrame.field[1]:GetText() == MainFrame.field[2]:GetText()) and (MainFrame.field[1]:GetText() == MainFrame.field[3]:GetText()) and (MainFrame.field[1]:GetText() ~= nil)) then
				MainFrame.field[1]:LockHighlight();
				MainFrame.field[2]:LockHighlight();
				MainFrame.field[3]:LockHighlight();
				if (myTurn == true) and (singleplayer == false) then
					SendChatMessage("won the game!", "EMOTE");
					DoEmote("DANCE", none);
				elseif (myTurn == false) and (singleplayer == false) then
					DoEmote("CRY", playerTwo);
				end
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[4]:GetText() == MainFrame.field[5]:GetText()) and (MainFrame.field[4]:GetText() == MainFrame.field[6]:GetText()) and (MainFrame.field[4]:GetText() ~= nil)) then
				MainFrame.field[4]:LockHighlight();
				MainFrame.field[5]:LockHighlight();
				MainFrame.field[6]:LockHighlight();
				if (myTurn == true) and (singleplayer == false) then
					SendChatMessage("won the game!", "EMOTE");
					DoEmote("DANCE", none);
				elseif (myTurn == false) and (singleplayer == false) then
					DoEmote("CRY", playerTwo);
				end
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[7]:GetText() == MainFrame.field[8]:GetText()) and (MainFrame.field[7]:GetText() == MainFrame.field[9]:GetText()) and (MainFrame.field[7]:GetText() ~= nil)) then
				MainFrame.field[7]:LockHighlight();
				MainFrame.field[8]:LockHighlight();
				MainFrame.field[9]:LockHighlight();
				if (myTurn == true) and (singleplayer == false) then
					SendChatMessage("won the game!", "EMOTE");
					DoEmote("DANCE", none);
				elseif (myTurn == false) and (singleplayer == false) then
					DoEmote("CRY", playerTwo);
				end
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[1]:GetText() == MainFrame.field[4]:GetText()) and (MainFrame.field[1]:GetText() == MainFrame.field[7]:GetText()) and (MainFrame.field[1]:GetText() ~= nil)) then
				MainFrame.field[1]:LockHighlight();
				MainFrame.field[4]:LockHighlight();
				MainFrame.field[7]:LockHighlight();
				if (myTurn == true) and (singleplayer == false) then
					SendChatMessage("won the game!", "EMOTE");
					DoEmote("DANCE", none);
				elseif (myTurn == false) and (singleplayer == false) then
					DoEmote("CRY", playerTwo);
				end
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[2]:GetText() == MainFrame.field[5]:GetText()) and (MainFrame.field[2]:GetText() == MainFrame.field[8]:GetText()) and (MainFrame.field[2]:GetText() ~= nil)) then
				MainFrame.field[2]:LockHighlight();
				MainFrame.field[5]:LockHighlight();
				MainFrame.field[8]:LockHighlight();
				if (myTurn == true) and (singleplayer == false) then
					SendChatMessage("won the game!", "EMOTE");
					DoEmote("DANCE", none);
				elseif (myTurn == false) and (singleplayer == false) then
					DoEmote("CRY", playerTwo);
				end
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[3]:GetText() == MainFrame.field[6]:GetText()) and (MainFrame.field[3]:GetText() == MainFrame.field[9]:GetText()) and (MainFrame.field[3]:GetText() ~= nil)) then
				MainFrame.field[3]:LockHighlight();
				MainFrame.field[6]:LockHighlight();
				MainFrame.field[9]:LockHighlight();
				if (myTurn == true) and (singleplayer == false) then
					SendChatMessage("won the game!", "EMOTE");
					DoEmote("DANCE", none);
				elseif (myTurn == false) and (singleplayer == false) then
					DoEmote("CRY", playerTwo);
				end
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[1]:GetText() == MainFrame.field[5]:GetText()) and (MainFrame.field[1]:GetText() == MainFrame.field[9]:GetText()) and (MainFrame.field[1]:GetText() ~= nil)) then
				MainFrame.field[1]:LockHighlight();
				MainFrame.field[5]:LockHighlight();
				MainFrame.field[9]:LockHighlight();
				if (myTurn == true) and (singleplayer == false) then
					SendChatMessage("won the game!", "EMOTE");
					DoEmote("DANCE", none);
				elseif (myTurn == false) and (singleplayer == false) then
					DoEmote("CRY", playerTwo);
				end
				DisableFields();
				win = true;
			end

			if ((MainFrame.field[3]:GetText() == MainFrame.field[5]:GetText()) and (MainFrame.field[3]:GetText() == MainFrame.field[7]:GetText()) and (MainFrame.field[3]:GetText() ~= nil)) then
				MainFrame.field[3]:LockHighlight();
				MainFrame.field[5]:LockHighlight();
				MainFrame.field[7]:LockHighlight();
				if (myTurn == true) and (singleplayer == false) then
					SendChatMessage("won the game!", "EMOTE");
					DoEmote("DANCE", none);
				elseif (myTurn == false) and (singleplayer == false) then
					DoEmote("CRY", playerTwo);
				end
				DisableFields();
				win = true;
			end
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
	if (singleplayer == false) then
		local argsMsg = {};
		for _, arg in ipairs({ string.split(' : ', message) }) do
			if (#arg > 0) then
				table.insert(argsMsg, arg);
			end
		end

		if (#argsMsg[#argsMsg] ~= 1) then
			return
		end
		
		local argsSnd = {};
		for _, arg in ipairs({ string.split('-', sender) }) do
			if (#arg > 0) then
				table.insert(argsSnd, arg);
			end
		end

		if (argsMsg[#argsMsg] == "at-x0g") then
			EnableFields();
			for i = 1, #blackList do
				local c = blackList:sub(i,i)
				MainFrame.field[tonumber(c)]:Disable();
			end
		end


		if (argsSnd[1] ~= UnitName("player")) then
			if (#playerTwo > 0) then
			else
				playerTwo = argsSnd[1];
				MainFrame.title:SetText(playerOne .. " VS " .. playerTwo);
			end

			EnableFields();

			for i = 1, #blackList do
				local c = blackList:sub(i,i)
				MainFrame.field[tonumber(c)]:Disable();
			end

			
			SelectField(tonumber(argsMsg[#argsMsg]));
			myTurn = true;
		end
	end
end


---------------------------------
-- Events
---------------------------------
local msg = CreateFrame("Frame");
msg:RegisterEvent("CHAT_MSG_EMOTE");
msg:SetScript("OnEvent", ReceiveInput);





