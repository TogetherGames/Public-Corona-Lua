--module(..., package.seeall)

local BaseState = require("BaseState");

local MenuViewAllUserAchievements = {};
local super = BaseState	--Inherit from BaseState
setmetatable(MenuViewAllUserAchievements, { __index = super } );
local mt = { __index = MenuViewAllUserAchievements };

-----------------
-- Constructor --
-----------------

function MenuViewAllUserAchievements:New()
	local self = BaseState:New();
	setmetatable(self, mt);

   	self.type = BaseState.State_UserAchievementLobby;

   	self.DisableInput = false;
   	self.UserAchievementButtons = {};

   	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuViewAllUserAchievements:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	print("MenuViewAllUserAchivements:Enter()");

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

    local backButton;

    local function onBackButtonClicked()
   		ChangeState(BaseState.State_Main);
    end

    
    local topY = display.contentHeight * 0.1;

   	local title = display.newText(displayGroup, "User Achievements", 0, 0, native.systemFontBold, 42);
   	title.x = display.contentCenterX;
   	title.y = topY;

   	backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
   	backButton:SetPos(80, 30);

  
    unrequire("ImageButton");
    unrequire("TextButton");


	self:GetAllUserAchievements();
end

function MenuViewAllUserAchievements:Draw()
end

function MenuViewAllUserAchievements:Exit()
	super.Exit(self);
end

function MenuViewAllUserAchievements:HandleKeyEvent(event)
	return false;
end



function MenuViewAllUserAchievements:GetAllUserAchievements()

    local function onGotAllUserAchievements(callback)
		print("onGotAllUserAchievements(" .. callback.Status .. ", " .. callback.Description .. ")")
		self.DisableInput = false;
		if (callback.Success) then
			self:AllUserAchievementsRetrieved()
		end
	end

	self.DisableInput = true;
    g_Together.TogetherUser.UserAchievementManager:GetAll(onGotAllUserAchievements)
end




------------------------------------------------
-- Events.
------------------------------------------------
function MenuViewAllUserAchievements:AllUserAchievementsRetrieved()
	g_Together.TogetherUser.UserAchievementManager:Dump();

	self:DestroyUserAchievementButtons();
	self:CreateUserAchievementButtons();

	self.DisableInput = false;
end

function MenuViewAllUserAchievements:BuildUserAchievementButtonLabel(userAchievement)
	local theButtonLabel = "ID=" .. userAchievement.UserAchievementID ..
		", Name=" .. userAchievement.Achievement.Name ..
		", " .. userAchievement.RequiredCount .. "/" .. userAchievement.Achievement.RequiredCount ..
		", Compl=" .. tostring(userAchievement.Completed);
	
	return theButtonLabel;
end

function MenuViewAllUserAchievements:UserAchievementButtonClicked(index)
	print("MenuViewAllUserAchievements:UserAchievementButtonClicked(" .. index .. ")");
	if (self.DisableInput == true) then
		print("   Input disabled.");
		return;
	end

	g_CurrentUserAchievement = g_Together.TogetherUser.UserAchievementManager:Get(index);

	ChangeState(BaseState.State_ViewUserAchievement);
end


function MenuViewAllUserAchievements:CreateUserAchievementButtons()
	print("MenuViewAllUserAchievements:CreateUserAchievementButtons()");

	local TextButton = require("TextButton");

    local function onUserAchievementButtonClicked(event, button)
   		self:UserAchievementButtonClicked(button.buttonIndex);
   	end


   	local userAchievementCount = g_Together.TogetherUser.UserAchievementManager:GetCount();
	local userAchievement;
   	local buttonY = 200;
   	local theButtonLabel = "";
   	local theButton = nil;

   	if (userAchievementCount > 9) then
   		userAchievementCount = 9;
   	end

   	self.UserAchievementButtons = {};

   	print("   UserAchievementCount = " .. userAchievementCount);

   	for i=1, userAchievementCount do
   		userAchievement = g_Together.TogetherUser.UserAchievementManager:Get(i);
    	

   		-- Only show completed UserAchievements.
--   		if (userAchievement.Completed == true) then
			theButtonLabel = self:BuildUserAchievementButtonLabel(userAchievement);
    
   			theButton = TextButton:New(self.displayGroup, theButtonLabel, onUserAchievementButtonClicked, 20);
   			theButton.buttonIndex = i;
    		theButton:SetPos(display.contentCenterX, buttonY);
    		buttonY = buttonY + 80;

    		table.insert(self.UserAchievementButtons, theButton);
--    	end
    end

    unrequire("TextButton");
end

function MenuViewAllUserAchievements:DestroyUserAchievementButtons()
	local buttonCount = table.getn(self.UserAchievementButtons);
	local userAchievementButton;

    for i=1, buttonCount do
    	userAchievementButton = self.UserAchievementButtons[i];
    	userAchievementButton:CleanUp();
    	self.displayGroup:remove(userAchievementButton.displayGroup);
    end

    self.UserAchievementButtons = {};
end


return MenuViewAllUserAchievements;



