--module(..., package.seeall)

local BaseState = require("BaseState");

local MenuViewAllAchievements = {};
local super = BaseState	--Inherit from BaseState
setmetatable(MenuViewAllAchievements, { __index = super } );
local mt = { __index = MenuViewAllAchievements };

-----------------
-- Constructor --
-----------------

function MenuViewAllAchievements:New()
	local self = BaseState:New();
	setmetatable(self, mt);

   	self.type = BaseState.State_AchievementLobby;

	self.DisableInput = false;
   	self.AchievementButtons = {};

   	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuViewAllAchievements:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	print("MenuViewAllAchivements:Enter()");

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

    local backButton;

    local function onBackButtonClicked()
   		ChangeState(BaseState.State_Main);
    end

    local function onAchievementButtonClicked()
   		print("onAchievementButtonClicked()");
    end

    
    local topY = display.contentHeight * 0.1;

   	local title = display.newText(displayGroup, "Achievements", 0, 0, native.systemFontBold, 42);
   	title.x = display.contentCenterX;
   	title.y = topY;

   	backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
   	backButton:SetPos(80, 30);
    	
  
    unrequire("ImageButton");
    unrequire("TextButton");


	self:GetAllAchievements();
end

function MenuViewAllAchievements:Draw()
end

function MenuViewAllAchievements:Exit()
	super.Exit(self);
end

function MenuViewAllAchievements:HandleKeyEvent(event)
	return false;
end



function MenuViewAllAchievements:GetAllAchievements()

	local function onGotAllAchievements(callback)
		print("onGotAllAchievements(" .. callback.Status .. ", " .. callback.Description .. ")")
		self.DisableInput = false;
		if (callback.Success) then
			self:AllAchievementsRetrieved()
		end
	end

	self.DisableInput = true;
    g_Together.AchievementManager:GetAll(onGotAllAchievements)
--	self:AllAchievementsRetrieved();    
end




------------------------------------------------
-- Events.
------------------------------------------------
function MenuViewAllAchievements:AllAchievementsRetrieved()
	g_Together.AchievementManager:Dump();

	self:DestroyAchievementButtons();
	self:CreateAchievementButtons();

	self.DisableInput = false;
end

function MenuViewAllAchievements:BuildAchievementButtonLabel(achievement)
	local theButtonLabel = "";

	if (achievement.LinkedUserAchievement ~= nil and
		achievement.LinkedUserAchievement.Completed == "True") then
		theButtonLabel = "UserAch, ";
	end

	theButtonLabel = theButtonLabel .. "ID=" .. achievement.AchievementID .. ", Name=" ..
		achievement.Name .. ", Action=" .. achievement.ActionName;

	return theButtonLabel;
end

function MenuViewAllAchievements:AchievementButtonClicked(index)
	print("MenuviewAllAchievements:AchievementButtonClicked(" .. index .. ")");
	if (self.DisableInput == true) then
		print("   Input disabled.");
		return;
	end

	g_CurrentAchievement = g_Together.AchievementManager:Get(index);

	ChangeState(BaseState.State_ViewAchievement);
end

function MenuViewAllAchievements:CreateAchievementButtons()
	local TextButton = require("TextButton");


    local function onAchievementButtonClicked(event, button)
    	self:AchievementButtonClicked(button.buttonIndex);
    end


    local achievementCount = g_Together.AchievementManager:GetCount();
	local achievement;
   	local buttonY = 200;
   	local theButtonLabel = "";
   	local theButton = nil;

   	if (achievementCount > 9) then
    	achievementCount = 9;
    end

    self.AchievementButtons = {};

   	for i=1, achievementCount do
    	achievement = g_Together.AchievementManager:Get(i);
    	
    	theButtonLabel = self:BuildAchievementButtonLabel(achievement);
    
    	theButton = TextButton:New(self.displayGroup, theButtonLabel, onAchievementButtonClicked, 20);
    	theButton.buttonIndex = i;
    	theButton:SetPos(display.contentCenterX, buttonY);
    	buttonY = buttonY + 80;

		table.insert(self.AchievementButtons, theButton);
    end

    unrequire("TextButton");
end

function MenuViewAllAchievements:DestroyAchievementButtons()
	local buttonCount = table.getn(self.AchievementButtons);
	local achievementButton;

    for i=1, buttonCount do
    	achievementButton = self.AchievementButtons[i];
    	achievementButton:CleanUp();
    	self.displayGroup:remove(achievementButton.displayGroup);
    end

    self.AchievementButtons = {};
end


return MenuViewAllAchievements;



