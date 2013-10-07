--module(..., package.seeall)

local BaseState = require("BaseState");
local together = require("plugin.together");

local MenuGameLobby = {};
local super = BaseState;	--Inherit from BaseState
setmetatable(MenuGameLobby, { __index = super } );
local mt = { __index = MenuGameLobby };

-----------------
-- Constructor --
-----------------

function MenuGameLobby:New()
	local self = BaseState:New();
	setmetatable(self, mt);

   	self.type = BaseState.State_GameLobby;

   	self.ShouldPoll = true;
   	self.TimeInc = 0;
   	self.PollInterval = 7.0;

   	self.DisplayingUserNotification = false;
   	self.GameInstanceButtons = {};

   	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuGameLobby:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	print("MenuGameLobby:Enter()");

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

    local backButton;
    local registerUserButton;
    local createGameButton;
    local joinGameButton;


    local function onBackButtonClicked()
    	print("onBackButtonClicked()");
    	ChangeState(BaseState.State_Main);
    end

    local function onCreateGameButtonClicked()
    	print("onCreateGameButtonClicked()");
		self:CreateGame();
    end

    local function onJoinRandomGameButtonClicked()
    	print("onJoinRandomGameButtonClicked()");
    	self:JoinRandomGame();
    end


    local topY = display.contentHeight * 0.1;

    local userIDLabel = display.newText(displayGroup, "UserID=" .. g_Together:GetUserID(), 0, 0, native.systemFontBold, 30);
    userIDLabel.x = display.contentCenterX;
   	userIDLabel.y = topY - 55;
   	
   	local usernameLabel = display.newText(displayGroup, "Username=" .. g_Together:GetUserViewName(), 0, 0, native.systemFontBold, 30);
    usernameLabel.x = display.contentCenterX;
   	usernameLabel.y = topY - 10;

   	topY = topY + 100;

   	local title = display.newText(displayGroup, "Game Lobby", 0, 0, native.systemFontBold, 42);
    title.x = display.contentCenterX;
   	title.y = topY;

   	backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
    backButton:SetPos(80, 30);


	local buttonY = topY + 80;

    createGameButton = TextButton:New(displayGroup, "Create Game", onCreateGameButtonClicked, 20);
    createGameButton:SetPos(display.contentCenterX, buttonY);
    buttonY = buttonY + 80;

    joinRandomGameButton = TextButton:New(displayGroup, "Join Random Game", onJoinRandomGameButtonClicked, 20)
    joinRandomGameButton:SetPos(display.contentCenterX, buttonY)
    buttonY = buttonY + 80

  
    unrequire("ImageButton");
    unrequire("TextButton");


	g_Together.GameInstanceManager = together.GameInstanceManager:New();    
    
	self:ForceUpdate();
end


function MenuGameLobby:ForceUpdate()
	self.TimeInc = 0.0;

	self:GetAllGameInstances();
--	self:GetAllUserNotifications();
end

function MenuGameLobby:Update(elapsedTime)
	if (self.ShouldPoll == true) then
		self.TimeInc = self.TimeInc + elapsedTime;
		if (self.TimeInc >= self.PollInterval) then
			self.TimeInc = self.TimeInc - self.PollInterval;
			
			if (self.DisplayingUserNotification == false) then
				self:GetAllGameInstances();
				self:GetAllUserNotifications();
			end
		end
	end
end

function MenuGameLobby:Draw()
end

function MenuGameLobby:Exit()
	super.Exit(self);
end

function MenuGameLobby:HandleKeyEvent(event)
	return false;
end



function MenuGameLobby:GetAllGameInstances()

    local function onGotAllGames(callback)
		print("onGotAllGames(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:AllGameInstancesRetrieved();
		end
	end
	
	self.TimeInc = 0.0;
   	
--  State Values:
--		1 - waitingForPlayers
--		2 - inProgress
--		4 - finished
--		8 - possibleRematch
--		16 - forfeit
	local stateMasks = { waitingForPlayers=true, inProgress=true };--, finished=true, possibleRematch=true, forfeit=false }

    g_Together.GameInstanceManager:GetAll(g_Together:GetUserID(),			-- userID
    									  stateMasks, 			-- stateMasks
    									  15,					-- maxCount
    									  true,					-- getGameInstanceProperties
    									  false,				-- friendsOnly
										  nil,					-- instanceType
										  nil,					-- instanceSubtype
    									  onGotAllGames);		-- callbackFunc
end

function MenuGameLobby:GetAllUserNotifications()

	local function onGotAllUserNotifications(callback)
		print("onGotAllUserNotifications(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:AllUserNotificationsRetrieved();
		end
	end
	
	self.TimeInc = 0.0;
	g_Together.UserNotificationManager:GetAll(false, 						-- processed
											  onGotAllUserNotifications);	-- callbackFunc
end

function MenuGameLobby:AllUserNotificationsRetrieved()
	if (g_Together.UserNotificationManager:GetCount() > 0) then
		self.DisplayingUserNotification = true;
		self:DisplayNextUserNotification();
	end
end

function MenuGameLobby:DisplayNextUserNotification()
	local userNotification = g_Together.UserNotificationManager:Get(1);
	local yesNoNotification = "";

	local function onUserNotificationProcessed(callback)
		print("onUserNotificationProcessed(" .. callback.Status .. ", " .. callback.Description .. ")");

		if (g_Together.UserNotificationManager:GetCount() > 0) then
			self:DisplayNextUserNotification();
		else
			self.DisplayingUserNotification = false;
			self:ForceUpdate();
		end
	end

	local function onAlertComplete(buttonIndex)
		print("notification.onAlertComplete(" .. buttonIndex .. ")");
		local accepted = true;
		
		-- If the user didn't press the Ok or Yes buttons, then the didn't accept.
		if (buttonIndex ~= 1) then
			accepted = false;
		end

    	local userNotification = g_Together.UserNotificationManager:Get(1);
    
		g_Together.UserNotificationManager:Process(userNotification.UserNotificationID, 	-- userNotificationID
												   accepted,								-- accepted
												   onUserNotificationProcessed);			-- callbackFunc
	end
	

	print("userNotification.NotificationType = " .. userNotification.NotificationType);
--	local alertButtons = { "Ok" }
	if (userNotification.NotificationType == "query") then
		print("   Is RematchQuery.");
		showAlertEx("Notification", userNotification.Message, { "Yes", "No" }, onAlertComplete);
	else
		showAlertEx("Notification", userNotification.Message, { "Ok" }, onAlertComplete);
	end
end



------------------------------------------------
-- Events.
------------------------------------------------
function MenuGameLobby:CreateGame()
	local function onGameInstanceCreated(callback)
		print("onGameInstanceCreated(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:GetAllGameInstances();
--			ChangeState(BaseState.State_GameInstance);
		else
			showAlert("Uh Oh", description);
		end
	end

	local gameInstanceProperties = together.PropertyCollection:New();
	gameInstanceProperties:Set("Data", "_________");

	local gameInstanceUserProperties = together.PropertyCollection:New();
	gameInstanceUserProperties:Set("Score", "20");

	-- Create a new GameInstance.
	g_Together.GameInstanceManager:Create("", 							-- gameInstanceType
										  nil,
										  0,							-- roomID
										  2,							-- maxUsers
										  false,						-- passTurn
										  gameInstanceProperties,		-- gameInstanceProperties
										  gameInstanceUserProperties, 	-- gameInstanceUserProperties
										  onGameInstanceCreated);		-- callbackFunc
end

function MenuGameLobby:JoinGame(gameInstanceID)
	print("MenuGameLobby:JoinGame(" .. gameInstanceID .. ")");

	local function onGameInstanceJoined(callback)
		print("onGameInstanceJoined(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
--			self:GetAllGameInstances();
			ChangeState(BaseState.State_GameInstance);
		else
			showAlert("Error", callback.Description);
		end
	end

	-- Join an existing GameInstance.
	local gameInstanceUserProperties = together.PropertyCollection:New();
	gameInstanceUserProperties:Set("Score", "45");

	g_Together.GameInstanceManager:Join(gameInstanceID, 				-- gameInstanceID
										gameInstanceUserProperties, 	-- gameInstanceUserProperties
										onGameInstanceJoined);			-- callbackFunc
end


function MenuGameLobby:JoinRandomGame()
	print("MenuGameLobby:JoinRandomGame()");

	local function onRandomGameInstanceJoined(callback)
		print("onRandomGameInstanceJoined(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:GetAllGameInstances();
--			ChangeState(BaseState.State_GameInstance);
		else
			showAlert("Error", callback.Description);
		end
	end


	-- Join a random GameInstance.
	local gameInstanceUserProperties = together.PropertyCollection:New();
	gameInstanceUserProperties:Set("Score", "12");

	g_Together.GameInstanceManager:JoinRandom("", 							-- gameInstanceType
											  nil,							-- gameInstanceSubType
											  gameInstanceUserProperties, 	-- gameInstanceUserProperties,
											  onRandomGameInstanceJoined);	-- callbackFunc
end

function MenuGameLobby:PlayGameInstance(gameInstance)

	local function onGameInstanceReloaded(callback)
--		print("onGameInstanceReloaded(" .. callback.Status .. ", " .. callback.Description .. ")")
		if (callback.Success) then
			g_CurrentGameInstance = gameInstance;
			self.ShouldPoll = true;
			ChangeState(BaseState.State_GameInstance);
		end
	end
	
	self.ShouldPoll = false;

	-- Get the GameInstance's details so we have the latest.
	gameInstance:GetDetails(gameInstance.GameInstanceID, 			-- gameInstanceID
							onGameInstanceReloaded);				-- callbackFunc
end

function MenuGameLobby:AllGameInstancesRetrieved()
--	g_Together.GameInstanceManager:Dump();

	self:DestroyGameInstanceButtons();
	self:CreateGameInstanceButtons();
end

function MenuGameLobby:BuildGameButtonLabel(gameInstance)
	local theButtonLabel = "ID=" .. gameInstance.GameInstanceID ..
		", Users=" .. gameInstance.UserCount .. "/" .. gameInstance.MaxUsers;

	--  Game State Values:
	--		1 - Waiting for Players
	--		2 - In Progress
	--		4 - Finished
	--		8 - Possible Rematch
	if (gameInstance.GameInstanceID ~= gameInstance.GameInstanceDuelID) then
		theButtonLabel = theButtonLabel .. ", Duel";
	end

	
	if (gameInstance.State == 1) then
		theButtonLabel = theButtonLabel .. ", waiting for users";
	elseif (gameInstance.State == 2) then
		theButtonLabel = theButtonLabel .. ", in progress";
	elseif (gameInstance.State == 4) then
		theButtonLabel = theButtonLabel .. ", finished";
	elseif (gameInstance.State == 8) then
		theButtonLabel = theButtonLabel .. ", possible rematch";
	end

	return theButtonLabel;
end

function MenuGameLobby:GameInstanceButtonClicked(index)
	print("MenuGameLobby:GameInstanceButtonClicked(" .. index .. ")");

	local gameInstance = g_Together.GameInstanceManager:Get(index);

	if (gameInstance.State == 1) then
		self:JoinGame(gameInstance.GameInstanceID);
	elseif (gameInstance.State == 4) then
		showAlert("Uh oh", "Game has already been finished.");
	elseif (gameInstance.State == 8) then
		showAlert("Uh oh", "Still waiting for opposing users to accept rematch invitation.");
	else
		self:PlayGameInstance(gameInstance);
	end	
end

function MenuGameLobby:CreateGameInstanceButtons()
	local TextButton = require("TextButton");

	local function onGameInstanceButtonClicked(event, button)
    	self:GameInstanceButtonClicked(button.buttonIndex);
    end


    local gameInstanceCount = g_Together.GameInstanceManager:GetCount();
	local gameInstance;
   	local buttonY = 480;
   	local gameButtonLabel = "";
   	local gameInstanceButton = nil;

   	if (gameInstanceCount > 6) then
    	gameInstanceCount = 6;
    end

    self.GameInstanceButtons = {};
	local gameInstanceButton;
   	for i=1, gameInstanceCount do
    	gameInstance = g_Together.GameInstanceManager:Get(i);

    	gameButtonLabel = self:BuildGameButtonLabel(gameInstance);
    
    	gameInstanceButton = TextButton:New(self.displayGroup, gameButtonLabel, onGameInstanceButtonClicked, 20);
    	gameInstanceButton.buttonIndex = i;
    	gameInstanceButton:SetPos(display.contentCenterX, buttonY);
    	buttonY = buttonY + 80;

		table.insert(self.GameInstanceButtons, gameInstanceButton);
    end

    unrequire("TextButton");
end

function MenuGameLobby:DestroyGameInstanceButtons()
	local buttonCount = table.getn(self.GameInstanceButtons);
	local gameInstanceButton;

    for i=1, buttonCount do
    	gameInstanceButton = self.GameInstanceButtons[i];
    	gameInstanceButton:CleanUp();
    	self.displayGroup:remove(gameInstanceButton.displayGroup);
    end

    self.GameInstanceButtons = {};
end
    	

return MenuGameLobby;


