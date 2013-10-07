--module(..., package.seeall)

local BaseState = require("BaseState");
local together = require("plugin.together");

local MenuMain = {};
local super = BaseState	--Inherit from BaseState
setmetatable(MenuMain, { __index = super } );
local mt = { __index = MenuMain };

-----------------
-- Constructor --
-----------------

function MenuMain:New()
	local self = BaseState:New();
	setmetatable(self, mt);
	self.type = BaseState.State_Main;

   	self.UserIDLabel = nil;
   	self.UsernameLabel = nil;
   	self.RegistrationLabel = nil;
   	self.UserCoinsLabel = nil;
   	self.UserCashLabel = nil;
   	self.UserStarsLabel = nil;
   	self.UserScoreLabel = nil;

	self.MicrophoneIconButton = nil;
   	self.FacebookIconButton = nil;

   	self.ShouldPoll = true;
   	self.TimeInc = 0;
   	self.PollInterval = 10.0;

   	self.DisplayingUserNotification = false;

	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuMain:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	print("MenuMain:Enter()")

	if (g_Together.TogetherUser.ClientUserProfile ~= nil) then
		print("    g_Together.TogetherUser.ClientUserProfile is not null");
	else
		print("    g_Together.TogetherUser.ClientUserProfile is null");
	end

	if (g_Together.TogetherUser.GameUserProfile ~= nil) then
		print("    g_Together.TogetherUser.GameUserProfile is not null");
	else
		print("    g_Together.TogetherUser.GameUserProfile is null");
	end
	

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(70, 50, 150);

    local logoutButton;
    local registerButton;
    local addStatsButton;
    local sendPushButton;
    local friendsButton;
    local userMessagesButton;
    local gameLobbyButton;
    local leaderboardsButton;
    local achievementsButton;
    local userAchievementsButton;
    local itemsButton;
    local userItemsButton;
    local chatRoomsButton;
    local createNotificationButton;
    local getAllGamesInDuelButton;

    local function onLogoutButtonClicked()
    	self:OnLogoutButtonClicked();
    end

    local function onRegisterUserButtonClicked()
    	self:OnRegisterUserButtonClicked();
    end

    local function onAddStatsButtonClicked()
    	self:OnAddStatsButtonClicked();
    end

    local function onSendPushButtonClicked()
    	self:OnSendPushButtonClicked();
    end

    local function onFriendsButtonClicked()
    	self:OnFriendsButtonClicked();
    end
    
    local function onUserMessagesButtonClicked()
		self:OnUserMessagesButtonClicked();
	end

    local function onGameLobbyButtonClicked()
    	self:OnGameLobbyButtonClicked();
    end

    local function onLeaderboardsButtonClicked()
    	self:OnLeaderboardsButtonClicked();
    end

    local function onAchievementsButtonClicked()
    	self:OnAchievementsButtonClicked();
    end

    local function onUserAchievementsButtonClicked()
    	self:OnUserAchievementsButtonClicked();
    end

    local function onItemsButtonClicked()
    	self:OnItemsButtonClicked();
    end

    local function onUserItemsButtonClicked()
    	self:OnUserItemsButtonClicked();
    end

    local function onChatRoomsButtonClicked()
    	self:OnChatRoomsButtonClicked();
    end

	local function onCreateNotificationButtonClicked()
		self:OnCreateNotificationButtonClicked();
	end

	local function onGetAllGamesInDuelButtonClicked()
		self:OnGetAllGamesInDuelButtonClicked();
	end

	local function onMicrophoneIconButtonClicked()
		self:OnMicrophoneIconButtonClicked();
	end

	local function onFacebookIconButtonClicked()
		self:OnFacebookIconButtonClicked();
	end


    local topY = display.contentHeight * 0.1 - 20;

    local title = display.newText(displayGroup, "Main Menu", 0, 0, native.systemFontBold, 42);
    title.x = display.contentCenterX;
    title.y = topY - 15;

    logoutButton = TextButton:New(displayGroup, "Logout", onLogoutButtonClicked, 20);
    logoutButton:SetPos(80, 20);
    
 	registerUserButton = TextButton:New(displayGroup, "Register", onRegisterUserButtonClicked, 20);
    registerUserButton:SetPos(display.contentWidth-100, 30);
   	
    addStatsButton = TextButton:New(displayGroup, "Add Stats", onAddStatsButtonClicked, 20);
    addStatsButton:SetPos(display.contentWidth-130, 215);

    sendPushButton = TextButton:New(displayGroup, "Send Push", onSendPushButtonClicked, 20);
    sendPushButton:SetPos(display.contentWidth-130, 275);

    

    topY = topY + 55;
    local labelY = topY;

    self.UserIDLabel = display.newText(displayGroup, "UserID=" .. g_Together:GetUserID(), 0, 0, native.systemFontBold, 30);
    self.UserIDLabel.x = display.contentCenterX;
   	self.UserIDLabel.y = labelY;
   	labelY = labelY + 40;
   	
   	self.UsernameLabel = display.newText(displayGroup, "Username=" .. g_Together:GetUserViewName(), 0, 0, native.systemFontBold, 30);
    self.UsernameLabel.x = display.contentCenterX;
   	self.UsernameLabel.y = labelY;
   	labelY = labelY + 40;

   	self.RegistrationLabel = display.newText(displayGroup, "Unregistered", 0, 0, native.systemFontBold, 30);
    self.RegistrationLabel.x = display.contentCenterX;
   	self.RegistrationLabel.y = labelY;
   	labelY = labelY + 40;

   	self.UserCoinsLabel = display.newText(displayGroup, "Coins=", 0, 0, native.systemFontBold, 30);
    self.UserCoinsLabel.x = display.contentCenterX;
   	self.UserCoinsLabel.y = labelY;
   	labelY = labelY + 40;

   	self.UserCashLabel = display.newText(displayGroup, "Cash=", 0, 0, native.systemFontBold, 30);
    self.UserCashLabel.x = display.contentCenterX;
   	self.UserCashLabel.y = labelY;
  	labelY = labelY + 40;

   	self.UserStarsLabel = display.newText(displayGroup, "Stars=", 0, 0, native.systemFontBold, 30);
    self.UserStarsLabel.x = display.contentCenterX;
   	self.UserStarsLabel.y = labelY;
   	labelY = labelY + 40;

   	self.UserScoreLabel = display.newText(displayGroup, "Score=", 0, 0, native.systemFontBold, 30);
    self.UserScoreLabel.x = display.contentCenterX;
   	self.UserScoreLabel.y = labelY;
   	labelY = labelY + 40;


   	local buttonY = topY + 280;
   	
    friendsButton = TextButton:New(displayGroup, "Friends", onFriendsButtonClicked, 20);
    friendsButton:SetPos(display.contentCenterX, buttonY);
    
    userMessagesButton = TextButton:New(displayGroup, "User Messages", onUserMessagesButtonClicked, 20);
    userMessagesButton:SetPos(display.contentCenterX - 200, buttonY);
    buttonY = buttonY + 62;

    gameLobbyButton = TextButton:New(displayGroup, "Game Lobby", onGameLobbyButtonClicked, 20);
    gameLobbyButton:SetPos(display.contentCenterX, buttonY);
    buttonY = buttonY + 62;

    leaderboardsButton = TextButton:New(displayGroup, "Leaderboards", onLeaderboardsButtonClicked, 20);
    leaderboardsButton:SetPos(display.contentCenterX, buttonY);
    buttonY = buttonY + 62;

    achievementsButton = TextButton:New(displayGroup, "Achievements", onAchievementsButtonClicked, 20);
    achievementsButton:SetPos(display.contentCenterX, buttonY);
    buttonY = buttonY + 62;

    userAchievementsButton = TextButton:New(displayGroup, "User Achievements", onUserAchievementsButtonClicked, 20);
    userAchievementsButton:SetPos(display.contentCenterX, buttonY);
    buttonY = buttonY + 62;

    itemsButton = TextButton:New(displayGroup, "Items", onItemsButtonClicked, 20);
    itemsButton:SetPos(display.contentCenterX, buttonY);
    buttonY = buttonY + 70;

    userItemsButton = TextButton:New(displayGroup, "User Items", onUserItemsButtonClicked, 20);
    userItemsButton:SetPos(display.contentCenterX, buttonY);
    buttonY = buttonY + 62;

    chatRoomsButton = TextButton:New(displayGroup, "Chat Rooms", onChatRoomsButtonClicked, 20);
    chatRoomsButton:SetPos(display.contentCenterX, buttonY);
    buttonY = buttonY + 62 + 20;

    createNotificationButton = TextButton:New(displayGroup, "Create Notification", onCreateNotificationButtonClicked, 20);
    createNotificationButton:SetPos(display.contentCenterX-200, buttonY);
--    buttonY = buttonY + 70;

--    getAllGamesInDuelButton = TextButton:New(displayGroup, "Get All Games In Duel", onGetAllGamesInDuelButtonClicked, 20);
--    getAllGamesInDuelButton:SetPos(display.contentCenterX+200, buttonY);
--    buttonY = buttonY + 70;


    self.MicrophoneIconButton = ImageButton:New(displayGroup, "microphone_ipad.png", onMicrophoneIconButtonClicked);
    self.MicrophoneIconButton:SetPos(display.contentWidth-120, display.contentHeight-250);

    self.FacebookIconButton = ImageButton:New(displayGroup, "facebook_ipad.png", onFacebookIconButtonClicked);
    self.FacebookIconButton:SetPos(display.contentWidth-120, display.contentHeight-120);
    
    
   	self:RefreshStatLabels();

   	unrequire("ImageButton");
   	unrequire("TextButton");
    
-- 	if (refreshUserStats == true) then
--    	self:RefreshUserStats();
--  end
    
    self:GetUserDetails();
end

function MenuMain:ForceUpdate()
--	self.TimeInc = 0.0;
--	self:GetAllUserNotifications();
end

function MenuMain:Update(elapsedTime)
	if (self.ShouldPoll == true) then
		self.TimeInc = self.TimeInc + elapsedTime;
		if (self.TimeInc >= self.PollInterval) then
			self.TimeInc = self.TimeInc - self.PollInterval;
			
			if (self.DisplayingUserNotification == false) then
--				self:GetAllUserNotifications();
			end
		end
	end
end

function MenuMain:Draw()

end

function MenuMain:Exit()
	super.Exit(self);
end

function MenuMain:HandleKeyEvent(event)
	return false;
end



function MenuMain:RefreshStatLabels()
    local user = g_Together.TogetherUser;

	user:Dump();

	local coins = user.Properties:GetEx("Coins", "0");
	local cash = user.Properties:GetEx("Cash", "0.00");
   	local stars = user.Properties:GetEx("Stars", "0");
   	local score = user.Properties:GetEx("Score", "0");
    
	self.UserIDLabel.text = "UserID=" .. user.UserID;
	self.UsernameLabel.text = "Username=" .. user:GetViewName();
	self.UserCoinsLabel.text = "Coins=" .. coins;
	self.UserCashLabel.text = "Cash=" .. cash;
   	self.UserStarsLabel.text = "Stars=" .. stars;
   	self.UserScoreLabel.text = "Score=" .. score;
    	
   	if (g_Together.TogetherUser.ActiveUserAccountTypeID == 1) then
    	self.RegistrationLabel.text = "Facebook Registered";
    elseif (g_Together.TogetherUser.ActiveUserAccountTypeID == 2) then
    	self.RegistrationLabel.text = "Twitter Registered";
    elseif (g_Together.TogetherUser.ActiveUserAccountTypeID == 3) then
    	self.RegistrationLabel.text = "GooglePlus Registered";
    elseif (g_Together.TogetherUser.ActiveUserAccountTypeID == 4) then
    	self.RegistrationLabel.text = "GameCenter Registered";
    elseif (g_Together.TogetherUser.ActiveUserAccountTypeID == 5) then
    	self.RegistrationLabel.text = "Custom Registered";
    else
    	self.RegistrationLabel.text = "Not Registered";
    end
end

function MenuMain:RefreshUserStats()
	refreshUserStats = false;
	
	local function onUserStatsRetrieved(status, description)
		print("onUserStatsRetrieved(" .. status .. ", " .. description .. ")");
		if (status == "Success") then
			self.DisableInput = false;
			self:RefreshStatLabels();
		end
	end

	self.DisableInput = true;
	g_Together.TogetherUser:GetStats(onUserStatsRetrieved);
end
    	



function MenuMain:GetUserDetails()
	local function onGetUserDetails(callback)
		print("onGetUserDetails(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:RefreshStatLabels();
		end
	end

	g_Together.TogetherUser:GetDetails(onGetUserDetails);
end


function MenuMain:GetAllUserNotifications()

	local function onGotAllUserNotifications(callback)
		print("onGotAllUserNotifications(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:AllUserNotificationsRetrieved();
		end
	end
	
	self.TimeInc = 0.0;
	g_Together.UserNotificationManager:GetAll(false, onGotAllUserNotifications);
end

function MenuMain:AllUserNotificationsRetrieved()
	if (g_Together.UserNotificationManager:GetCount() > 0) then
		self.DisplayingUserNotification = true;
		self:DisplayNextUserNotification();
	end
end

function MenuMain:DisplayNextUserNotification()
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
    
		g_Together.UserNotificationManager:Process(userNotification.UserNotificationID, accepted,
			onUserNotificationProcessed);
--		g_Together.UserNotificationManager:Delete(userNotification.UserNotificationID, onUserNotificationProcessed);
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
function MenuMain:OnLogoutButtonClicked()
	
	local function onLogoutUser(callback)
		print("onLogoutUser(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			ChangeState(BaseState.State_Login);
		end
	end
	
	-- Log out the User.
	g_Together:Logout(onLogoutUser);
end

function MenuMain:OnRegisterUserButtonClicked()
	ChangeState(BaseState.State_RegisterUser);
end

function MenuMain:OnAddStatsButtonClicked()
	local function onModifyUser(callback)
		print("onModifyUser(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:RefreshStatLabels();
		end
	end

    local user = g_Together.TogetherUser;

	local coins = tonumber(user.Properties:GetEx("Coins", "0"));
	local cash = tonumber(user.Properties:GetEx("Cash", "0.00"));
   	local stars = tonumber(user.Properties:GetEx("Stars", "0"));
   	local score = tonumber(user.Properties:GetEx("Score", "0"));

	coins = coins + 10;
	cash = cash + 10.00;
	stars = stars + 10;
	score = score + 10;

	cash = "" .. cash .. ".00";

	user.Properties:Set("Coins", coins);
	user.Properties:Set("Cash", cash);
   	user.Properties:Set("Stars", stars);
   	user.Properties:Set("Score", score);

	g_Together.TogetherUser:Modify(onModifyUser);
end

function MenuMain:OnSendPushButtonClicked()
	local function onSendPushNotification(callback)
		print("onSendPushNotification(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
--			showAlert("Success", "Push notification sent.");
		else
			showAlert("Uh Oh", callback.Description);
		end
	end

	local notification = together.TogetherNotification.New("Notification Message", nil, nil, {e="test"});
	g_Together:SendPushNotification(g_Together:GetUserID(), nil, platform, notification, onSendPushNotification);
end

function MenuMain:OnFriendsButtonClicked()
	g_Together:AddAnalytic("EnterMode", "Friends", "");
	g_PreviousMenu = BaseState.State_Main;
	ChangeState(BaseState.State_FriendLobby);
end

function MenuMain:OnUserMessagesButtonClicked()
	g_Together:AddAnalytic("EnterMode", "UserMessages", "");
	ChangeState(BaseState.State_UserMessageInbox);
end

function MenuMain:OnGameLobbyButtonClicked()
	g_Together:AddAnalytic("EnterMode", "GameLobby", "");
	ChangeState(BaseState.State_GameLobby);
end

function MenuMain:OnLeaderboardsButtonClicked()
	g_Together:AddAnalytic("EnterMode", "LeaderboardLobby", "");
	ChangeState(BaseState.State_LeaderboardLobby);
end

function MenuMain:OnAchievementsButtonClicked()
	g_Together:AddAnalytic("EnterMode", "ViewAllAchievements", "");
	ChangeState(BaseState.State_ViewAllAchievements);
end

function MenuMain:OnUserAchievementsButtonClicked()
	g_Together:AddAnalytic("EnterMode", "ViewAllUserAchievements", "");
	ChangeState(BaseState.State_ViewAllUserAchievements);
end

function MenuMain:OnItemsButtonClicked()
	g_Together:AddAnalytic("EnterMode", "ViewAllItems", "");
	ChangeState(BaseState.State_ViewAllItems);
end

function MenuMain:OnUserItemsButtonClicked()
	g_Together:AddAnalytic("EnterMode", "ViewItems", "");
	ChangeState(BaseState.State_ViewAllUserItems);
end

function MenuMain:OnChatRoomsButtonClicked()
	g_Together:AddAnalytic("EnterMode", "ViewChatRoos", "");
	ChangeState(BaseState.State_ChatRoomLobby);
end

function MenuMain:OnCreateNotificationButtonClicked()

	local function onCreatedUserNotification(callback)
		print("onCreatedUserNotification(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
--			self:RefreshStatLabels();
		else
			showAlert("Uh Oh", callback.Description);
		end
	end

	g_Together.UserNotificationManager:Create(g_Together.TogetherUser.UserID, 		-- destUserID
											  "Query",								-- type
											  "Notification sent from MainMenu.",	-- message
											   0, 									-- originalGameInstanceID
											   0,									-- gameInstanceID
											   0,									-- achievementID
											   0,									-- chatRoomID
											   0,									-- itemID
											   0,									-- itemCount
											   "",									-- socialType
											   "",									-- SocialID
											   onCreatedUserNotification);



--[[
	local playerNumMulligans = 0;
	local numMulligans = g_Together.TogetherUser.GameUserProfile.Properties:Get("mulligans");
	print(numMulligans);

	if numMulligans ~= nil then
		playerNumMulligans = numMulligans;
	else
   		playerNumMulligans = 10;
   	end

   	g_Together.TogetherUser.GameUserProfile.Properties:Set("mulligans", playerNumMulligans);            
   	g_Together.TogetherUser:Modify();
--]]


--[[
	local function onGetAllUserMessages(callback)
		print("onGetAllUserMessages(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			showAlert("Info", "'Get all user messages");
		else
			showAlert("Uh Oh", callback.Description);
		end
	end

--	g_Together.UserMessageManager:GetAll(0, 0, 50,  onGetAllUserMessages);

--	g_Together.UserMessageManager:CreateMessage(1247, "Test Title", "This is a test message.",
--	 	false, nil, onGetAllUserMessages);

--	g_Together.UserMessageManager:MarkMessageAsRead(5, onGetAllUserMessages);

	g_Together.UserMessageManager:DeleteMessage(5, onGetAllUserMessages);
--]]
end

function MenuMain:OnGetAllGamesInDuelButtonClicked()

	local function onGameInstanceDuelRetrieved(callback)
		print("onGameInstanceDuelRetrieved(" .. callback.Status .. ", " .. callback.Description .. ")");
	end

	g_Together.GameInstanceManager:GetAllInDuel(409, onGameInstanceDuelRetrieved);
end

function MenuMain:OnMicrophoneIconButtonClicked()
	ChangeState(BaseState.State_AudioRecorder);
end

function MenuMain:OnFacebookIconButtonClicked()
	ChangeState(BaseState.State_FacebookWallPost);
--[[
	local function onGetFriends(callback)
		print("onGetFriends(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
--			self:RefreshStatLabels();
		else
			showAlert("Uh Oh", callback.Description);
		end
	end

--	g_Together.FriendManager:GetAll(onGetFreinds);
	g_Together.FriendManager:RemoveFriend(531, onGetFreinds);
--]]
end


return MenuMain;