--module(..., package.seeall)

local BaseState = require("BaseState");

local MenuViewUserAchievement = {};
local super = BaseState	--Inherit from BaseState
setmetatable(MenuViewUserAchievement, { __index = super } );
local mt = { __index = MenuViewUserAchievement };

-----------------
-- Constructor --
-----------------

function MenuViewUserAchievement:New()
	local self = BaseState:New();
	setmetatable(self, mt);

   	self.type = BaseState.State_Achievement;

   	self.DisableInput = false;
   	self.UserAchievement = nil;

   	self.AchievementPropertyLabels = {};

   	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuViewUserAchievement:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	-- Cache pointer to the selected UserAchievement.
	self.UserAchievement = g_CurrentUserAchievement;

	print("MenuViewUserAchievement:Enter()");

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

    local backButton = nil;
    local purchaseButton = nil;
	local sellButton = nil;
	local deleteButton = nil;
    
    local function onBackButtonClicked()
   		ChangeState(BaseState.State_ViewAllUserAchievements);
    end

    local function onModifyUserAchievementButtonClicked()
   		self:ModifyUserAchievement();
    end

    local function onSellUserAchievementButtonClicked()
   		self:SellUserAchievement();
    end

    local function onDeleteUserAchievementButtonClicked()
   		self:DeleteUserAchievement();
    end
    	
    
    local topY = display.contentHeight * 0.1;

   	local title = display.newText(displayGroup, "User Achievement", 0, 0, native.systemFontBold, 42);
   	title.x = display.contentCenterX;
   	title.y = topY;

   	backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
   	backButton:SetPos(80, 30);
    	
  
	local labelText = "";
	local userachUserAchievementID = nil;
	local userachAchievementID = nil;
	local userachActionNameLabel = nil;
	local userachNameLabel = nil;
	local userachDescriptionLabel = nil;
	local userachRequiredCountLabel = nil;
	local userachRequiredSequentialLabel = nil;
	local userachCompleted = nil;


	local labelX = display.contentCenterX;
	local labelY = 180;
	local labelYStep = 45;

	labelText = "UserAchievementID = " .. self.UserAchievement.UserAchievementID;
	userachUserAchievementIDLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	userachUserAchievementIDLabel.x = display.contentCenterX;
	userachUserAchievementIDLabel.y = labelY;
	labelY = labelY + labelYStep;

	labelText = "AchievementID = " .. self.UserAchievement.Achievement.AchievementID;
	userachAchievementIDLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	userachAchievementIDLabel.x = display.contentCenterX;
	userachAchievementIDLabel.y = labelY;
	labelY = labelY + labelYStep;

	labelText = "ActionName = " .. self.UserAchievement.Achievement.ActionName;
	achievementActionNameLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	achievementActionNameLabel.x = display.contentCenterX;
	achievementActionNameLabel.y = labelY;
	labelY = labelY + labelYStep;

	labelText = "Name = " .. self.UserAchievement.Achievement.Name;
	userachNameLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	userachNameLabel.x = display.contentCenterX;
	userachNameLabel.y = labelY;
	labelY = labelY + labelYStep;

	labelText = "Description = " .. self.UserAchievement.Achievement.Description;
	userachDescriptionLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	userachDescriptionLabel.x = display.contentCenterX;
	userachDescriptionLabel.y = labelY;
	labelY = labelY + labelYStep;

	labelText = "RequiredCount = " .. self.UserAchievement.RequiredCount .. " / " .. self.UserAchievement.Achievement.RequiredCount;
	userachRequiredCountLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	userachRequiredCountLabel.x = display.contentCenterX;
	userachRequiredCountLabel.y = labelY;
	labelY = labelY + labelYStep;

	labelText = "RequiredSequential = " .. tostring(self.UserAchievement.Achievement.RequiredSequential);
	userachRequiredSequentialLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	userachRequiredSequentialLabel.x = display.contentCenterX;
	userachRequiredSequentialLabel.y = labelY;
	labelY = labelY + labelYStep;

	labelText = "Completed = " .. tostring(self.UserAchievement.Completed);
	userachCompletedLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	userachCompletedLabel.x = display.contentCenterX;
	userachCompletedLabel.y = labelY;
	labelY = labelY + labelYStep;

	
	self:CreatePropertyLabels();


	labelX = display.contentCenterX;
	labelY = labelY + 280;

	modifyButton = TextButton:New(displayGroup, "Modify", onModifyUserAchievementButtonClicked, 20);
   	modifyButton:SetPos(display.contentCenterX, labelY);
   	labelY = labelY + 55;

	sellButton = TextButton:New(displayGroup, "Sell", onSellUserAchievementButtonClicked, 20);
   	sellButton:SetPos(display.contentCenterX, labelY);
   	labelY = labelY + 55;

	deleteButton = TextButton:New(displayGroup, "Delete", onDeleteUserAchievementButtonClicked, 20);
   	deleteButton:SetPos(display.contentCenterX, labelY);
   	labelY = labelY + 55;


   	unrequire("ImageButton");
   	unrequire("TextButton");
end

function MenuViewUserAchievement:Draw()
end

function MenuViewUserAchievement:Exit()
	super.Exit(self);
end

function MenuViewUserAchievement:HandleKeyEvent(event)
	return false;
end




function MenuViewUserAchievement:RefreshPropertyLabels()
	self:DestroyPropertyLabels();
	self:CreatePropertyLabels();
end

function MenuViewUserAchievement:DestroyPropertyLabels()
	local TextButton = require("TextButton");

	local labelCount = table.getn(self.AchievementPropertyLabels);
	local theLabel;

    for i=1, labelCount do
    	theLabel = self.AchievementPropertyLabels[i];
    	theLabel:CleanUp();
    	self.displayGroup:remove(theLabel.displayGroup);
    end

    self.AchievementPropertyLabels = {};

   	unrequire("TextButton");
end

function MenuViewUserAchievement:CreatePropertyLabels()
	local TextButton = require("TextButton");

	local achievementPropertyCount = self.UserAchievement.Achievement.Properties:GetCount();
	local achievementProperty = nil;
	local achievementPropertyLabel = nil;
	local labelText = "";
	local labelX = display.contentCenterX;
	local labelY = 560;
	local labelYStep = 50;	

	for i=1, achievementPropertyCount do
		achievementProperty = self.UserAchievement.Achievement.Properties:GetAt(i);

		labelText = achievementProperty.Name .. " = " .. achievementProperty.Value;

		achievementPropertyLabel = TextButton:New(self.displayGroup, labelText, nil, 20);
   		achievementPropertyLabel:SetPos(labelX, labelY);
		labelY = labelY + labelYStep;
		
		table.insert(self.AchievementPropertyLabels, achievementPropertyLabel);
	end

	labelY = labelY + 40;

	local userAchievementPropertyCount = self.UserAchievement.Properties:GetCount();
	local userAchievementProperty = nil;
	local userAchievementPropertyLabel = nil;
	
	for i=1, userAchievementPropertyCount do
		userAchievementProperty = self.UserAchievement.Properties:GetAt(i);

		labelText = userAchievementProperty.Name .. " = " .. userAchievementProperty.Value;

		achievementPropertyLabel = TextButton:New(self.displayGroup, labelText, nil, 20);
   		achievementPropertyLabel:SetPos(labelX, labelY);
		labelY = labelY + labelYStep;

		table.insert(self.AchievementPropertyLabels, userAchievementPropertyLabel);
	end

   	unrequire("TextButton");
end



------------------------------------------------
-- Events.
------------------------------------------------
function MenuViewUserAchievement:ModifyUserAchievement()
	print("MenuViewUserAchievement:ModifyUserAchievement()");
	if (self.DisableInput == true) then
		print("   Input disabled.");
		return;
	end

	local function onUserAchievementModified(callback)
		print("onUserAchievementModified(" .. callback.Status .. ", " .. callback.Description .. ")");
		self.DisableInput = false;
		self:RefreshPropertyLabels();
	end

	local counterValue = self.UserAchievement.Properties:GetEx("Counter", "0");
	self.UserAchievement.Properties:Set("Counter", tostring(tonumber(counterValue) + 1));

	self.DisableInput = true;
	self.UserAchievement:Modify(onUserAchievementModified);
end

function MenuViewUserAchievement:SellUserAchievement()
	print("MenuViewUserAchievement:SellUserAchievement()");
	if (self.DisableInput == true) then
		print("   Input disabled.");
		return;
	end

	local function onUserAchievementSold(callback)
		print("onUserAchievementSold(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self.DisableInput = false;
			ChangeState(BaseState.State_ViewAllUserAchievements);
		else
			self.DisableInput = false;
			showAlert("Un Oh", callback.Description);
		end
	end

	self.DisableInput = true;


	-- Sell the Achievement.
	local costPropertyName = "";
	local coinCost = self.UserAchievement.Achievement.Properties:Get("Coins");
	local cashCost = self.UserAchievement.Achievement.Properties:Get("Cash");

	if (cashCost ~= nil) then
		costPropertyName = "Cash";
	else
		costPropertyName = "Coins";
	end

	g_Together.TogetherUser.UserAchievementManager:Sell(self.UserAchievement.UserAchievementID, 	-- userAchievementID
														costPropertyName,							-- costPropertyName
										   				false,										-- useGameUserProfileProperties
										   				onUserAchievementSold);						-- callbackFunc
end

function MenuViewUserAchievement:DeleteUserAchievement()
	print("MenuViewUserAchievement:DeleteUserAchievement()");
	if (self.DisableInput == true) then
		print("   Input disabled.");
		return;
	end

	local function onUserAchievementDeleted(callback)
		print("onUserAchievementDeleted(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self.DisableInput = false;
			ChangeState(BaseState.State_ViewAllUserAchievements);
		else
			self.DisableInput = false;
			showAlert("Un Oh", callback.Description);
		end
	end

	self.DisableInput = true;
	g_Together.TogetherUser.UserAchievementManager:Delete(self.UserAchievement.UserAchievementID,	-- userAchievementID
														  onUserAchievementDeleted);				-- callbackFunc
end


return MenuViewUserAchievement;



