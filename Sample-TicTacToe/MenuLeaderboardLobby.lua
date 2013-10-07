--module(..., package.seeall)

local BaseState = require("BaseState");

local MenuLeaderboardLobby = {};
local super = BaseState	--Inherit from BaseState
setmetatable(MenuLeaderboardLobby, { __index = super } );
local mt = { __index = MenuLeaderboardLobby };

-----------------
-- Constructor --
-----------------

function MenuLeaderboardLobby:New()
	local self = BaseState:New();
	setmetatable(self, mt);
    self.type = BaseState.State_LeaderboardLobby;

    self.LeaderboardButtons = {};

	self.LeaderboardManager = nil;
	
	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuLeaderboardLobby:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	print("MenuLeaderboardLobby:Enter()");

	self.LeaderboardManager = g_Together.LeaderboardManager;
	
	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

    local backButton;

    local function onBackButtonClicked()
    	print("onBackButtonClicked()");
    	ChangeState(BaseState.State_Main);
    end
    local function onLeaderboardButtonClicked()
    	print("onLeaderboardButtonClicked()");
    end

    
    local topY = display.contentHeight * 0.1;

    local userIDLabel = display.newText(displayGroup, "UserID=" .. g_Together:GetUserID(), 0, 0, native.systemFontBold, 30);
    userIDLabel.x = display.contentCenterX;
   	userIDLabel.y = topY - 55;
   	
   	local usernameLabel = display.newText(displayGroup, "Username=" .. g_Together:GetUserViewName(), 0, 0, native.systemFontBold, 30);
    usernameLabel.x = display.contentCenterX;
   	usernameLabel.y = topY - 10;

   	topY = topY + 100;

   	local title = display.newText(displayGroup, "Leaderboards", 0, 0, native.systemFontBold, 42);
    title.x = display.contentCenterX;
   	title.y = topY;

   	backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
    backButton:SetPos(80, 30);


    local buttonY = 140;

    
    self.LeaderboardButtons = {};

    unrequire("ImageButton");
    unrequire("TextButton");


	self:GetAllLeaderboards();
end


function MenuLeaderboardLobby:Update(elapsedTime)
end

function MenuLeaderboardLobby:Draw()
end

function MenuLeaderboardLobby:Exit()
	super.Exit(self);
end

function MenuLeaderboardLobby:HandleKeyEvent(event)
	return false;
end


function MenuLeaderboardLobby:GetAllLeaderboards()
    local function onGotAllLeaderboards(callback)
		print("onGotAllLeaderboards(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self.LeaderboardManager:Dump();

			self:AllLeaderboardsRetrieved();
		end
	end
	
	self.LeaderboardManager:GetAll(g_Together:GetUserID(), onGotAllLeaderboards);
end


------------------------------------------------
-- Events.
------------------------------------------------
function MenuLeaderboardLobby:AllLeaderboardsRetrieved()
	local TextButton = require("TextButton");
		
	self.LeaderboardManager:Dump();

	self:DestroyLeaderboardButtons();

    local function onLeaderboardButtonClicked(event, button)
    	self:LeaderboardButtonClicked(button.buttonIndex);
    end


    local leaderboardCount = self.LeaderboardManager:GetCount();
	local leaderboard;
   	local buttonY = 260;
   	local leaderboardButtonLabel = "";
   	local leaderboardButton = nil;

   	if (leaderboardCount > 9) then
    	leaderboardCount = 9;
    end

    self.LeaderboardButtons = {};
	local leaderboardButton;
   	for i=1, leaderboardCount do
    	leaderboard = self.LeaderboardManager:Get(i);
    	
    	leaderboardButtonLabel = self:BuildLeaderboardButtonLabel(leaderboard);
    
   		leaderboardButton = TextButton:New(self.displayGroup, leaderboardButtonLabel, onLeaderboardButtonClicked, 20);
   		leaderboardButton.buttonIndex = i;
    	leaderboardButton:SetPos(display.contentCenterX, buttonY);
    	buttonY = buttonY + 80;

		table.insert(self.LeaderboardButtons, leaderboardButton);
    end

    unrequire("TextButton");
end

function MenuLeaderboardLobby:BuildLeaderboardButtonLabel(leaderboard)
--	local winningLeaderboardUser = leaderboard:GetWinningLeaderboardUser("Score");
	local theButtonLabel = "";
	
	if (leaderboard.WinningUserID ~= 0) then
		theButtonLabel = "ID=" .. leaderboard.LeaderboardID ..
		", WinningUser=" .. leaderboard.WinningUserID;
	else
		theButtonLabel = "ID=" .. leaderboard.LeaderboardID ..
		", No Winner";
	end
	
	return theButtonLabel;
end

function MenuLeaderboardLobby:LeaderboardButtonClicked(index)
	print("MenuLeaderboardLobby:LeaderboardButtonClicked(" .. index .. ")");
	local leaderboard = self.LeaderboardManager:Get(index);
	self:DisplayLeaderboard(leaderboard);
end

function MenuLeaderboardLobby:DisplayLeaderboard(leaderboard)
	local function onGetLeaderboardDetails(callback)
		if (callback.Success) then
			g_CurrentLeaderboard = leaderboard;	
			ChangeState(BaseState.State_Leaderboard);
		end
	end
	
	leaderboard:GetDetails(onGetLeaderboardDetails);
end

function MenuLeaderboardLobby:DestroyLeaderboardButtons()
	local buttonCount = table.getn(self.LeaderboardButtons);
	local leaderboardButton;

    for i=1, buttonCount do
    	leaderboardButton = self.LeaderboardButtons[i];
    	leaderboardButton:CleanUp();
    	self.displayGroup:remove(leaderboardButton.displayGroup);
    end

    self.LeaderboardButtons = {};
end


return MenuLeaderboardLobby;


