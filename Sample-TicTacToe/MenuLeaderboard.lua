--module(..., package.seeall)

local BaseState = require("BaseState");

local MenuLeaderboard = {};
local super = BaseState	--Inherit from BaseState
setmetatable(MenuLeaderboard, { __index = super } );
local mt = { __index = MenuLeaderboard };



-----------------
-- Constructor --
-----------------

function MenuLeaderboard:New()
	local self = BaseState:New();
	setmetatable(self, mt);

    self.type = BaseState.State_Leaderboard;

    self.UserLabels = {};

	self.Leaderboard = nil;
    
	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuLeaderboard:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	print("MenuLeaderboard:Enter()")

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

    local backButton = nil;


    local function onBackButtonClicked()
    	ChangeState(BaseState.State_LeaderboardLobby);
    end


    local topY = display.contentHeight * 0.1;
    
   	local title = display.newText(displayGroup, "Leaderboard", 0, 0, native.systemFontBold, 42);
   	title.x = display.contentCenterX;
   	title.y = topY;

   	backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
    backButton:SetPos(80, 30);
    	
   	
   	topY = topY + 100;

   	self.Leaderboard 				= g_CurrentLeaderboard;

   	local labelText					= "";
	local leaderboardIDLabel 		= nil;
	local creatorUserIDLabel 		= nil;
	local roomIDLabel 				= nil;
	local secondsSinceStartLabel 	= nil;
	local secondsSinceFinishLabel 	= nil;
	local maxUsersLabel 			= nil;
	local turnIndexLabel 			= nil;
	local winningUserIDLabel	 	= nil;
	local winningScoreLabel 		= nil;


	labelText = "LeaderboardID = " .. self.Leaderboard.LeaderboardID;
    leaderboardIDLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
    leaderboardIDLabel.x = display.contentCenterX;
    leaderboardIDLabel.y = topY;
    topY = topY + 50;

	labelText = "CreatorUserID = " .. self.Leaderboard.CreatorUserID;
    creatorUserIDLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
    creatorUserIDLabel.x = display.contentCenterX;
    creatorUserIDLabel.y = topY;
    topY = topY + 50;

	labelText = "RoomID = " .. self.Leaderboard.RoomID;
    roomIDLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
    roomIDLabel.x = display.contentCenterX;
    roomIDLabel.y = topY;
    topY = topY + 50;

	labelText = "SecondsSinceStart = " .. self.Leaderboard.SecondsSinceStart;
    secondsSinceStartLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
    secondsSinceStartLabel.x = display.contentCenterX;
    secondsSinceStartLabel.y = topY;
    topY = topY + 50;

	labelText = "SecondsSinceFinish = " .. self.Leaderboard.SecondsSinceFinish;
    secondsSinceFinishLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
    secondsSinceFinishLabel.x = display.contentCenterX;
    secondsSinceFinishLabel.y = topY;
    topY = topY + 50;    
    
   	labelText = "MaxUsers = " .. self.Leaderboard.MaxUsers;
    maxUsersLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
    maxUsersLabel.x = display.contentCenterX;
    maxUsersLabel.y = topY;
    topY = topY + 50;

	labelText = "TurnIndex = " .. self.Leaderboard.TurnIndex;
    turnIndexLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
    turnIndexLabel.x = display.contentCenterX;
    turnIndexLabel.y = topY;
    topY = topY + 50;

	labelText = "WinningUserID = " .. self.Leaderboard.WinningUserID;
    winningUserIDLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
    winningUserIDLabel.x = display.contentCenterX;
    winningUserIDLabel.y = topY;
    topY = topY + 50;

	if (self.Leaderboard.WinningUserID ~= 0) then
		local winningLeaderboardUser = self.Leaderboard:GetWinningLeaderboardUser();
    	local winningScore = winningLeaderboardUser.Properties:GetEx("Score", "0");

   		labelText = "WinningScore = " .. winningScore;
    	winningScoreLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
    	winningScoreLabel.x = display.contentCenterX;
    	winningScoreLabel.y = topY;
    	topY = topY + 50;
    end
    
    
    self:CreateUserLabels();
    
    unrequire("ImageButton");
    unrequire("TextButton");
end



function MenuLeaderboard:Update(elapsedTime)

end

function MenuLeaderboard:Draw()

end

function MenuLeaderboard:Exit()
	super.Exit(self);
end

function MenuLeaderboard:HandleKeyEvent(event)
	return false;
end



------------------------------------------------
-- Events.
------------------------------------------------
function MenuLeaderboard:CreateUserLabels()
	local TextButton = require("TextButton");
		

    local function onUserLabelButton1Clicked(event)
    end

   	local leaderboardUserCount = self.Leaderboard:GetLeaderboardUserCount();
	local leaderboardUser;
   	local userText;
	local leaderboardUserLabel;
   	local labelY = 660;

	for i=1, leaderboardUserCount do
   		leaderboardUser = self.Leaderboard:GetLeaderboardUser(i);
		local score = leaderboardUser.Properties:GetEx("Score", "0");
    	
   		if (leaderboardUser.UserAnonymous == false) then
   			userText = "Name=" .. leaderboardUser.Username ..
-- 				", Anon=" .. leaderboardUser.UserAnonymous ..
   				", Score=" .. score;
    
    		leaderboardUserLabel = TextButton:New(self.displayGroup, userText, onUserLabelButton1Clicked, 20);
    		leaderboardUserLabel:SetPos(display.contentCenterX, labelY);
    		labelY = labelY + 60;

    		table.insert(self.UserLabels, leaderboardUserLabel);
    	end
    end

    unrequire("TextButton");
end

function MenuLeaderboard:DestroyUserLabels()
	local labelCount = table.getn(self.UserLabels);
	local userLabel;

    for i=1, labelCount do
    	userLabel = self.UserLabels[i];
    	userLabel:CleanUp();
    	self.displayGroup:remove(userLabel.displayGroup);
    end

    self.UserLabels = {};
end


return MenuLeaderboard;



