SLASH_RELOADUI1 = "/rl" -- For quicker reloading
SlashCmdList.RELOADUI = ReloadUI

SLASH_FRAMESTK1 = "/fs" -- For quicker access to frame stack
SlashCmdList.FRAMESTK = function()
	LoadAddOn('Blizzard_DebugTools')
	FrameStackTooltip_Toggle()
end

--[[
	-- to be able to use the left and right arrows in the edit box
	-- without rotating your character!
	for i=1, NUM_CHAT_WINDOWS do
		_G["ChatFrame" .. i .. "EditBox"]:SetAltArrowKeyMode(false)
	end
	---------------------------------------------------------------
]]

--[[
	CreateFrame Arguments
	1. The type of frame - "Frame"
	2. The gloal frame name - "TicTacToe_MainFrame"
	3. The parent frame (NOT a string!)
	4. A comma separated LIST (string list) of XML templates to inherit from - "BasicFrameTemplateWithInset"
		- this does NOT need to e a comma separated list however
]]
--[[
	local OuterFrame = CreateFrame("Frame", "TicTacToe_OuterFrame", UIParent, "BasicFrameTemplateWithInset")
	OuterFrame:SetSize(300, 300) -- width, height
	OuterFrame:SetPoint("CENTER", UIParent, "CENTER") -- point, relativeFrame, relativePoint, xOffset, yOffset

	local MainFrame = CreateFrame("Frame", "TicTacToe_MainFrame", OuterFrame, "BasicFrameTemplateWithInset")
	MainFrame:SetSize(250, 250) -- width, height
	MainFrame:SetPoint("BOTTOM", OuterFrame, "BOTTOM") -- point, relativeFrame, relativePoint, xOffset, yOffset

	local TopLeftFrame = CreateFrame("Frame", "TicTacToe_TopLeftFrame", MainFrame, "BasicFrameTemplateWithInset")
	TopLeftFrame:SetSize(80, 80)
	TopLeftFrame:SetPoint("TOPLEFT", MainFrame, "TOPLEFT")
]]

-- point and relativePoint ("CENTER") could have een any of the following options: 
--[[
	"TOPLEFT"
	"TOP"
	"TOPRIGHT"
	"LEFT"
	"CENTER"
	"RIGHT"
	"BOTTOMLEFT"
	"BOTTOM"
	"BOTTOMRIGHT"
]]




--[[
---------------------------------
-- Buttons
---------------------------------
-- TOPLEFT:
MainFrame.topLeftBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
MainFrame.topLeftBtn:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 12, -24);
MainFrame.topLeftBtn:SetSize(70, 70);
MainFrame.topLeftBtn:SetText("");
MainFrame.topLeftBtn:SetNormalFontObject("GameFontNormalLarge");
MainFrame.topLeftBtn:SetHighlightFontObject("GameFontHighlightLarge");
MainFrame.topLeftBtn:SetScript("OnClick", function(self, button, down)
	self:Disable();
	if (playerOne == true) then
		self:SetText("X");
		playerOne = false;
	else
		self:SetText("O");
		playerOne = true;
	end
end);

-- TOP:
MainFrame.topBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
MainFrame.topBtn:SetPoint("TOP", MainFrame, "TOP", 0, -24);
MainFrame.topBtn:SetSize(70, 70);
MainFrame.topBtn:SetText("");
MainFrame.topBtn:SetNormalFontObject("GameFontNormalLarge");
MainFrame.topBtn:SetHighlightFontObject("GameFontHighlightLarge");
MainFrame.topBtn:SetScript("OnClick", function(self, button, down)
	self:Disable();
	if (playerOne == true) then
		self:SetText("X");
		playerOne = false;
	else
		self:SetText("O");
		playerOne = true;
	end
end);

-- TOPRIGHT:
MainFrame.toprightBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
MainFrame.toprightBtn:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", -12, -24);
MainFrame.toprightBtn:SetSize(70, 70);
MainFrame.toprightBtn:SetText("");
MainFrame.toprightBtn:SetNormalFontObject("GameFontNormalLarge");
MainFrame.toprightBtn:SetHighlightFontObject("GameFontHighlightLarge");
MainFrame.toprightBtn:SetScript("OnClick", function(self, button, down)
	self:Disable();
	if (playerOne == true) then
		self:SetText("X");
		playerOne = false;
	else
		self:SetText("O");
		playerOne = true;
	end
end);

-- LEFT:
MainFrame.leftBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
MainFrame.leftBtn:SetPoint("LEFT", MainFrame, "LEFT", 12, -6);
MainFrame.leftBtn:SetSize(70, 70);
MainFrame.leftBtn:SetText("");
MainFrame.leftBtn:SetNormalFontObject("GameFontNormalLarge");
MainFrame.leftBtn:SetHighlightFontObject("GameFontHighlightLarge");
MainFrame.leftBtn:SetScript("OnClick", function(self, button, down)
	self:Disable();
	if (playerOne == true) then
		self:SetText("X");
		playerOne = false;
	else
		self:SetText("O");
		playerOne = true;
	end
end);

-- CENTER:
MainFrame.centerBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
MainFrame.centerBtn:SetPoint("CENTER", MainFrame, "CENTER", 0, -6);
MainFrame.centerBtn:SetSize(70, 70);
MainFrame.centerBtn:SetText("");
MainFrame.centerBtn:SetNormalFontObject("GameFontNormalLarge");
MainFrame.centerBtn:SetHighlightFontObject("GameFontHighlightLarge");
MainFrame.centerBtn:SetScript("OnClick", function(self, button, down)
	self:Disable();
	if (playerOne == true) then
		self:SetText("X");
		playerOne = false;
	else
		self:SetText("O");
		playerOne = true;
	end
end);

-- RIGHT:
MainFrame.rightBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
MainFrame.rightBtn:SetPoint("RIGHT", MainFrame, "RIGHT", -12, -6);
MainFrame.rightBtn:SetSize(70, 70);
MainFrame.rightBtn:SetText("");
MainFrame.rightBtn:SetNormalFontObject("GameFontNormalLarge");
MainFrame.rightBtn:SetHighlightFontObject("GameFontHighlightLarge");
MainFrame.rightBtn:SetScript("OnClick", function(self, button, down)
	self:Disable();
	if (playerOne == true) then
		self:SetText("X");
		playerOne = false;
	else
		self:SetText("O");
		playerOne = true;
	end
end);

-- BOTTOMLEFT:
MainFrame.bottomLeftBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
MainFrame.bottomLeftBtn:SetPoint("BOTTOMLEFT", MainFrame, "BOTTOMLEFT", 12, 12);
MainFrame.bottomLeftBtn:SetSize(70, 70);
MainFrame.bottomLeftBtn:SetText("");
MainFrame.bottomLeftBtn:SetNormalFontObject("GameFontNormalLarge");
MainFrame.bottomLeftBtn:SetHighlightFontObject("GameFontHighlightLarge");
MainFrame.bottomLeftBtn:SetScript("OnClick", function(self, button, down)
	self:Disable();
	if (playerOne == true) then
		self:SetText("X");
		playerOne = false;
	else
		self:SetText("O");
		playerOne = true;
	end
end);

-- BOTTOM:
MainFrame.bottomBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
MainFrame.bottomBtn:SetPoint("BOTTOM", MainFrame, "BOTTOM", 0, 12);
MainFrame.bottomBtn:SetSize(70, 70);
MainFrame.bottomBtn:SetText("");
MainFrame.bottomBtn:SetNormalFontObject("GameFontNormalLarge");
MainFrame.bottomBtn:SetHighlightFontObject("GameFontHighlightLarge");
MainFrame.bottomBtn:SetScript("OnClick", function(self, button, down)
	self:Disable();
	if (playerOne == true) then
		self:SetText("X");
		playerOne = false;
	else
		self:SetText("O");
		playerOne = true;
	end
end);

-- BOTTOMRIGHT:
MainFrame.bottomRightBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
MainFrame.bottomRightBtn:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", -12, 12);
MainFrame.bottomRightBtn:SetSize(70, 70);
MainFrame.bottomRightBtn:SetText("");
MainFrame.bottomRightBtn:SetNormalFontObject("GameFontNormalLarge");
MainFrame.bottomRightBtn:SetHighlightFontObject("GameFontHighlightLarge");
MainFrame.bottomRightBtn:SetScript("OnClick", function(self, button, down)
	self:Disable();
	if (playerOne == true) then
		self:SetText("X");
		playerOne = false;
	else
		self:SetText("O");
		playerOne = true;
	end
end);
]]
