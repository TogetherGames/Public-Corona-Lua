--module(..., package.seeall)

local BaseState = require("BaseState");
local together = require("plugin.together");

local MenuViewAchievement = {};
local super = BaseState	--Inherit from BaseState
setmetatable(MenuViewAchievement, { __index = super } );
local mt = { __index = MenuViewAchievement };

-----------------
-- Constructor --
-----------------

function MenuViewAchievement:New()
	local self = BaseState:New();
	setmetatable(self, mt);

   	self.type = BaseState.State_Achievement;

	self.DisableInput = false;
   	self.Achievement = nil;

   	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuViewAchievement:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	-- Cache pointer to the selected Achievement.
	self.Achievement = g_CurrentAchievement;

	print("MenuViewAchievement:Enter()");

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

    local backButton = nil;
    local awardButton = nil;
	local purchaseButton = nil;
	
    
    local function onBackButtonClicked()
   		ChangeState(BaseState.State_ViewAllAchievements);
    end

    local function onAwardAchievementButtonClicked()
   		self:AwardAchievement();
    end

    local function onPurchaseAchievementButtonClicked()
   		self:PurchaseAchievement();
    end

    	
   	local topY = display.contentHeight * 0.1;

   	local title = display.newText(displayGroup, "Achievement", 0, 0, native.systemFontBold, 42);
   	title.x = display.contentCenterX;
   	title.y = topY;

   	backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
   	backButton:SetPos(80, 30);
    	
  
	local labelText = "";
	local achievementActionNameLabel = nil;
	local achievementNameLabel = nil;
	local achievementDescriptionLabel = nil;
	local achievementRequiredCountLabel = nil;
	local achievementRequiredSequentialLabel = nil;
	local achievementRequiredItemIDLabel = nil;
	local achievementRequiredItemCountLabel = nil;
	local achievementAwardItemIDLabel = nil;
	local achievementAwardItemCountLabel = nil;


	local labelX = display.contentCenterX;
	local labelY = 180;
	local labelYStep = 45;

	labelText = "ActionName = " .. self.Achievement.ActionName;
	achievementActionNameLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	achievementActionNameLabel.x = display.contentCenterX;
	achievementActionNameLabel.y = labelY;
	labelY = labelY + labelYStep;

	labelText = "Name = " .. self.Achievement.Name;
	achievementNameLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	achievementNameLabel.x = display.contentCenterX;
	achievementNameLabel.y = labelY;
	labelY = labelY + labelYStep;

	labelText = "Description = " .. self.Achievement.Description;
	achievementDescriptionLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	achievementDescriptionLabel.x = display.contentCenterX;
	achievementDescriptionLabel.y = labelY;
	labelY = labelY + labelYStep;

	labelText = "RequiredCount = " .. self.Achievement.RequiredCount;
	achievementRequiredCountLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	achievementRequiredCountLabel.x = display.contentCenterX;
	achievementRequiredCountLabel.y = labelY;
	labelY = labelY + labelYStep;

	labelText = "RequiredSequential = " .. tostring(self.Achievement.RequiredSequential);
	achievementRequiredSequentialLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	achievementRequiredSequentialLabel.x = display.contentCenterX;
	achievementRequiredSequentialLabel.y = labelY;
	labelY = labelY + labelYStep;

	labelText = "RequiredItemID = " .. tostring(self.Achievement.RequiredItemID);
	achievementRequiredItemIDLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	achievementRequiredItemIDLabel.x = display.contentCenterX;
	achievementRequiredItemIDLabel.y = labelY;
	labelY = labelY + labelYStep;

	labelText = "RequiredItemCount = " .. tostring(self.Achievement.RequiredItemCount);
	achievementRequiredItemCountLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	achievementRequiredItemCountLabel.x = display.contentCenterX;
	achievementRequiredItemCountLabel.y = labelY;
	labelY = labelY + labelYStep;
	
	labelText = "AwardItemID = " .. tostring(self.Achievement.AwardItemID);
	achievementAwardItemIDLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	achievementAwardItemIDLabel.x = display.contentCenterX;
	achievementAwardItemIDLabel.y = labelY;
	labelY = labelY + labelYStep;
	
	labelText = "AwardItemCount = " .. tostring(self.Achievement.RequiredItemID);
	achievementAwardItemCountLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	achievementAwardItemCountLabel.x = display.contentCenterX;
	achievementAwardItemCountLabel.y = labelY;
	labelY = labelY + labelYStep;


	local achievementPropertyCount = self.Achievement.Properties:GetCount();
	local achievementProperty = nil;
	local achievementPropertyLabel = nil;
	
	for i=1, achievementPropertyCount do
		achievementProperty = self.Achievement.Properties:GetAt(i);

		labelText = achievementProperty.Name .. " = " .. achievementProperty.Value;

		achievementPropertyLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
		achievementPropertyLabel.x = labelX;
		achievementPropertyLabel.y = labelY;
		labelY = labelY + labelYStep;
	end
	
	
	labelX = display.contentCenterX;
	labelY = labelY + 60;

   	awardButton = TextButton:New(displayGroup, "Award", onAwardAchievementButtonClicked, 20);
   	awardButton:SetPos(display.contentCenterX, labelY);
   	labelY = labelY + 55;

   	purchaseButton = TextButton:New(displayGroup, "Purchase", onPurchaseAchievementButtonClicked, 20);
   	purchaseButton:SetPos(display.contentCenterX, labelY);
   	labelY = labelY + 55;

   	unrequire("ImageButton");
   	unrequire("TextButton");
end

function MenuViewAchievement:Draw()

end

function MenuViewAchievement:Exit()
	super.Exit(self);
end

function MenuViewAchievement:HandleKeyEvent(event)
	return false
end




------------------------------------------------
-- Events.
------------------------------------------------
function MenuViewAchievement:AwardAchievement()
	print("MenuViewAchievement:AwardAchievement()");
	if (self.DisableInput == true) then
		print("   Input disabled.");
		return;
	end

	local function onAchievementAwarded(callback)
		print("onAchievementAwarded(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self.DisableInput = false;
			ChangeState(BaseState.State_ViewAllAchievements);
		else
			self.DisableInput = false;
			showAlert("Un Oh", callback.Description);
		end
	end

	self.DisableInput = true;

	-- Award a UserAchievement.
	local userAchievementProperties = together.PropertyCollection:New();
	userAchievementProperties:Set("SomeData", "Awarded");

	g_Together.TogetherUser.UserAchievementManager:Award(self.Achievement.AchievementID,		-- achievementID
														 "",									-- actionName
														 0,										-- roomID
														 userAchievementProperties,				-- userAchievementProperties
														 "Just awarded myself an Achievement", 	-- notificationMessage
														 onAchievementAwarded);					-- callbackFunc
end

function MenuViewAchievement:PurchaseAchievement()
	print("MenuViewAchievement:PurchaseAchievement()");
	if (self.DisableInput == true) then
		print("   Input disabled.");
		return;
	end

	local function onAchievementPurchased(callback)
		print("onAchievementPurchased(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self.DisableInput = false;
			ChangeState(BaseState.State_ViewAllAchievements);
		else
			self.DisableInput = false;
			showAlert("Un Oh", callback.Description);
		end
	end

	self.DisableInput = true;


	-- Purchase the Achievement.
	local costPropertyName = "";
	local coinCost = self.Achievement.Properties:Get("Coins");
	local cashCost = self.Achievement.Properties:Get("Cash");

	if (cashCost ~= nil) then
		costPropertyName = "Cash";
	else
		costPropertyName = "Coins";
	end

	
	local userAchievementProperties = together.PropertyCollection:New();
	userAchievementProperties:Set("SomeData", "Purchased");

	g_Together.TogetherUser.UserAchievementManager:Purchase(self.Achievement.AchievementID, 	-- achievementID
															0,									-- roomID
											   				userAchievementProperties, 			-- userItemProperties
											   				false,								-- useGameUserProfileProperties
											   				onAchievementPurchased);			-- callbackFunc	
end


return MenuViewAchievement;



