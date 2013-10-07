--module(..., package.seeall)

local BaseState = require("BaseState");
local together = require("plugin.together");

local MenuFriendLobby = {};
local super = BaseState;	--Inherit from BaseState
setmetatable(MenuFriendLobby, { __index = super } );
local mt = { __index = MenuFriendLobby };


local function onScreenTouch(event)
	currentState:OnScreenTouch(event);
end


-----------------
-- Constructor --
-----------------

function MenuFriendLobby:New()
	local self = BaseState:New();
	setmetatable(self, mt);

   	self.type = BaseState.State_FriendLobby;

	self.Background				= nil;
	self.ScrollDisplayGroup		= nil;
	self.PrevTouchX				= -1;
	self.PrevTouchY				= -1;

	self.FriendManager 			= nil;

   	self.TogetherFriendButtons 	= {};
   	self.FriendSeparationLabelY = 0;
   	self.FriendSeparationLabel	= nil;
	self.FacebookFriendButtons 	= {};

   	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuFriendLobby:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	local displayGroup = self.displayGroup;

	self.Background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	self.Background:setFillColor(50, 50, 150);

	self.ScrollDisplayGroup = display.newGroup();
--	self.ScrollDisplayGroup:insert(self.ScrollGroup);

    local backButton;
    local facebookButton;


--	self.ScrollDisplayGroup.y = -80;

    local function onBackButtonClicked()
    	if (g_PreviousMenu == BaseState.State_Main) then
    	   	ChangeState(BaseState.State_Main);
    	elseif (g_PreviousMenu == BaseState.State_GameInstance) then
    		ChangeState(BaseState.State_GameInstance);
    	elseif (g_PreviousMenu == BaseState.State_ChatRoom) then
    		ChangeState(BaseState.State_ChatRoom);
		elseif (g_PreviousMenu == BaseState.State_UserMessageInbox) then
			ChangeState(BaseState.State_UserMessageInbox);
    	end
	end    	

    local function onFacebookIconButtonClicked()
    	print("onFacebookIconButtonClicked()");
    	self:GetFacebookFriendsList();
    end


	local menuTitle = "Friends";
   	if (g_PreviousMenu == BaseState.State_GameInstance) then
   		menuTitle = "Select Friend to Invite to Game";
	elseif (g_PreviousMenu == BaseState.State_ChatRoom) then
		menuTitle = "Select Friend to Invite to ChatRoom";
	end
	

    local topY = display.contentHeight * 0.1 + 30;

   	local title = display.newText(self.ScrollDisplayGroup, menuTitle, 0, 0, native.systemFontBold, 42);
    title.x = display.contentCenterX;
   	title.y = topY;

   	backButton = TextButton:New(self.ScrollDisplayGroup, "Back", onBackButtonClicked, 20);
    backButton:SetPos(80, 30);

    facebookButton = ImageButton:New(displayGroup, "facebook_ipad.png", onFacebookIconButtonClicked);
    facebookButton:SetPos(display.contentWidth-70, 70);
    

  
    unrequire("ImageButton");
    unrequire("TextButton");


	self.FriendManager = g_Together.FriendManager;    



	-- begin listening for screen touches
	self.Background:addEventListener("touch", onScreenTouch);

	self:GetTogetherFriends();
end

function MenuFriendLobby:Exit()
	self.Background:removeEventListener("touch", onScreenTouch);
	self.ScrollDisplayGroup:removeSelf(); 
	self.ScrollDisplayGroup = nil;
--[[
	self.displayGroup:removeEventListener("tap", Block);
	self.displayGroup:removeEventListener("touch", Block);
	self.displayGroup:removeSelf();
	self.displayGroup = nil;
--]]
	super.Exit(self);
end

function MenuFriendLobby:OnScreenTouch(event)
	-- Touch has began
	if (event.phase == "began") then
   		self.PrevTouchX = event.x;
  		self.PrevTouchY = event.y;
    	
   	-- User has moved their finger, while touching
   	elseif (event.phase == "moved") then
   		local deltaX = event.x - self.PrevTouchX;
   		local deltaY = event.y - self.PrevTouchY;
		print("Delta: " .. deltaX .. ", " .. deltaY);
	   	
   		self.ScrollDisplayGroup.y = self.ScrollDisplayGroup.y + deltaY;
   	
		self.PrevTouchX = event.x;
		self.PrevTouchY = event.y;
        
	-- Touch has ended; user has lifted their finger
    elseif (event.phase == "ended" or event.phase == "cancelled") then

	end
end
	


function MenuFriendLobby:GetFacebookFriendsList()
	print("MenuFriendLobby:GetFacebookFriendsList()");
    local function onGetFriends(callback)
		print("onGetFriends(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:AllFacebookFriendsRetrieved();
		else
			showAlert("Uh Oh", callback.Description);
		end
	end

	print("Getting friends from Facebook");
	g_Together.Social.Facebook:GetFriends(onGetFriends)
end

function MenuFriendLobby:AllFacebookFriendsRetrieved()
	print("MenuFriendLobby:AllFacebookFriendsRetrieved()");

	self:GetTogetherFriends();
--[[
	self:DestroyTogetherFriendButtons();
	self:CreateTogetherFriendButtons();
	
	self:SetupFriendSeparationLabel();

	self:DestroyFacebookFriendButtons();
	self:CreateFacebookFriendButtons();
--]]
end


function MenuFriendLobby:GetTogetherFriends()
    local function onGetTogetherFriends(callback)
		print("onGetFriends(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:AllTogetherFriendsRetrieved();
		end
	end
	
    self.FriendManager:GetAll(onGetTogetherFriends);
end

function MenuFriendLobby:AllTogetherFriendsRetrieved()
	self:DestroyTogetherFriendButtons();
	self:CreateTogetherFriendButtons();
	
	self:SetupFriendSeparationLabel();

	self:DestroyFacebookFriendButtons();
	self:CreateFacebookFriendButtons();
end

function MenuFriendLobby:BuildTogetherFriendButtonLabel(friend)
	local theButtonLabel = "UserID=" .. friend.UserID .. ", Name=" .. friend.Name;
	return theButtonLabel;
end

function MenuFriendLobby:BuildFacebookFriendButtonLabel(facebookFriend)
	local theButtonLabel = "FriendID=" .. facebookFriend.FriendID .. ", Name=" .. facebookFriend.Name;
	return theButtonLabel;
end

function MenuFriendLobby:CreateTogetherFriendButtons()
	print("MenuFreindLobby:CreateTogetherFriendButtons()");
	local TextButton = require("TextButton");

	local function onTogetherFriendButtonClicked(event, button)
    	self:InviteTogetherFriendToGame(button.buttonIndex);
    end


    local friendCount = self.FriendManager:GetCount();
	local friend = nil;
   	local buttonY = 230;
   	local friendButtonLabel = "";
   	local friendButton = nil;

--   	if (friendCount > 8) then
--    	friendCount = 8;
--    end

    self.TogetherFriendButtons = {};
	for i=1, friendCount do
    	friend = self.FriendManager:Get(i);

    	friendButtonLabel = self:BuildTogetherFriendButtonLabel(friend);
    
   		friendButton = TextButton:New(self.ScrollDisplayGroup, friendButtonLabel, onTogetherFriendButtonClicked, 20);
   		friendButton.buttonIndex = i;
    	friendButton:SetPos(display.contentCenterX, buttonY);
    	buttonY = buttonY + 80;

		table.insert(self.TogetherFriendButtons, friendButton);
    end

   	self.FriendSeparationLabelY = buttonY;
   	
    unrequire("TextButton");
end

function MenuFriendLobby:DestroyTogetherFriendButtons()
	print("MenuFreindLobby:DestroyTogetherFriendButtons()");
	local buttonCount = table.getn(self.TogetherFriendButtons);
	local friendButton;

    for i=1, buttonCount do
    	friendButton = self.TogetherFriendButtons[i];
    	friendButton:CleanUp();
    	self.ScrollDisplayGroup:remove(friendButton.displayGroup);
    end

    self.TogetherFriendButtons = {};
end

    
function MenuFriendLobby:SetupFriendSeparationLabel()
	if (self.FriendSeparationLabel == nil) then	
   		self.FriendSeparationLabel = display.newText(self.ScrollDisplayGroup, "-----------------------------", 0, 0, native.systemFontBold, 20);
   	end
    self.FriendSeparationLabel.x = display.contentCenterX;
   	self.FriendSeparationLabel.y = self.FriendSeparationLabelY;
end


function MenuFriendLobby:CreateFacebookFriendButtons()
	print("MenuFriendLobby:CreateFacebookFriendButtons()");
	local TextButton = require("TextButton");

	local function onFacebookFriendButtonClicked(event, button)
    	self:InviteFacebookFriendToGame(button.buttonIndex);
    end


	local facebookFriends = g_Together.Social.Facebook.FacebookFriends;
    local facebookFriendCount = table.getn(facebookFriends);
	local facebookFriend = nil;
   	local buttonY = self.FriendSeparationLabelY + 40;
   	local friendButtonLabel = "";
   	local friendButton = nil;

--   	if (facebookFriendCount > 8) then
--    	facebookFriendCount = 8;
--    end

    self.FacebookFriendButtons = {};
	for i=1, facebookFriendCount do
    	facebookFriend = facebookFriends[i];

    	friendButtonLabel = self:BuildFacebookFriendButtonLabel(facebookFriend);

    	friendButton = TextButton:New(self.ScrollDisplayGroup, friendButtonLabel, onFacebookFriendButtonClicked, 20);
    	friendButton.buttonIndex = i;
    	friendButton:SetPos(display.contentCenterX, buttonY);
    	buttonY = buttonY + 80;

		table.insert(self.FacebookFriendButtons, friendButton);
    end
   	
    unrequire("TextButton");
end

function MenuFriendLobby:DestroyFacebookFriendButtons()
	print("MenuFriendLobby:DestroyFacebookFriendButtons()");
	local buttonCount = table.getn(self.FacebookFriendButtons);
	local friendButton;

    for i=1, buttonCount do
    	friendButton = self.FacebookFriendButtons[i];
    	friendButton:CleanUp();
    	self.ScrollDisplayGroup:remove(friendButton.displayGroup);
    end

    self.FacebookFriendButtons = {};
end



------------------------------------------------
-- Events.
------------------------------------------------
function MenuFriendLobby:InviteTogetherFriendToGame(friendIndex)
	print("MenuFriendLobby:InviteTogetherFriendToGame(" .. friendIndex .. ")");
	
	local friend = self.FriendManager:Get(friendIndex);
			
	if (g_PreviousMenu == BaseState.State_Main) then
		print("Should create a new GameInstance and invite the friend to it.");
		self:CreateGameAndInviteTogetherFriend(friend);
	elseif (g_PreviousMenu == BaseState.State_GameInstance) then
		self:InviteTogetherFriendToCurrentGame(friend);
	elseif (g_PreviousMenu == BaseState.State_ChatRoom) then
		self:InviteTogetherFriendToCurrentChatRoom(friend);
	elseif (g_PreviousMenu == BaseState.State_UserMessageInbox) then
		print("Should go to CreateMessage with the friend's UserID.");
		g_StateParameters = friend;
		ChangeState(BaseState.State_CreateUserMessage);
	end
end

function MenuFriendLobby:CreateGameAndInviteTogetherFriend(friend)

	local function onInviteUserToGame(callback)
		print("onInviteUserToGame(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			ChangeState(BaseState.State_Main);
			--ChangeState(BaseState.State_GameLobby);
		else
			showAlert("Uh Oh", callback.Description);
		end
	end

	local function onCreateGame(callback)
		print("onCreateGame(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			local gameInstanceUserProperties = together.PropertyCollection:New();
			gameInstanceUserProperties:Set("Score", "31");

			local notificationMessage = '';

			-- Invite the friend User to the current GameInstance.
			g_CurrentGameInstance:InviteUser(friend.UserID,					-- inviteeUserID
											 "",							-- inviteeSocialType
											 "",							-- inviteeSocialID
											 gameInstanceUserProperties, 	-- gameUserProperties
											 notificationMessage, 			-- notificationMessage
											 onInviteUserToGame);			-- callbackFunc
		else
			showAlert("Uh Oh", callback.Description);
		end
	end


	local gameInstanceProperties = together.PropertyCollection:New();
	gameInstanceProperties:Set("Data", "_________");

	local gameInstanceUserProperties = together.PropertyCollection:New();
	gameInstanceUserProperties:Set("Score", "12");

	-- Create a new GameInstance.
	g_Together.GameInstanceManager:Create("", 							-- gameInstanceType
										  nil,							-- gameInstanceSubType
										  0,							-- roomID
										  2,							-- maxUsers
										  false,						-- passTurn
										  gameInstanceProperties, 		-- gameInstanceProperties
										  gameInstanceUserProperties,	-- gameInstanceUserProperties
										  onCreateGame);				-- callbackFunc
end

function MenuFriendLobby:InviteTogetherFriendToCurrentGame(friend)
	local function onInviteUserToGame(callback)
		print("onInviteUserToGame(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			ChangeState(BaseState.State_GameInstance);
		else
			showAlert("Uh Oh", callback.Description);
		end
	end

	local gameInstanceUserProperties = together.PropertyCollection:New();
	gameInstanceUserProperties:Set("Score", "31");

	local notificationMessage = '';

	-- Invite the friend User to the current GameInstance.
	g_CurrentGameInstance:InviteUser(friend.UserID,					-- inviteeUserID
									 "",							-- inviteeSocialType
									 "",							-- inviteeSocialID
									 gameInstanceUserProperties,
									 	-- gameUserProperties
									 notificationMessage, 			-- notificationMessage
									 onInviteUserToGame);			-- callbackFunc
end
	


function MenuFriendLobby:InviteTogetherFriendToCurrentChatRoom(friend)
	local function onInviteUserToChatRoom(callback)
		print("onInviteUserToChatRoom(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			ChangeState(BaseState.State_ChatRoom);
		else
			showAlert("Uh Oh", callback.Description);
		end
	end

	local notificationMessage = g_Together:GetUserViewName() .. " has invited you to a chat room!";

	-- Invite the friend User to the current ChatRoom.
	g_CurrentChatRoom:InviteUser(friend.UserID,						-- inviteeUserID
								 "",								-- inviteeSocialType
								 "",								-- inviteeSocialID
								 notificationMessage, 				-- notificationMessage
								 onInviteFacebookFriendToChatRoom);	-- callbackFunc
end







function MenuFriendLobby:InviteFacebookFriendToGame(facebookFriendIndex)
	print("MenuFriendLobby:InviteFacebookFriendToGame(" .. facebookFriendIndex .. ")");

	local facebookFriend = 	g_Together.Social.Facebook:GetFacebookFriend(facebookFriendIndex);
			
	if (g_PreviousMenu == BaseState.State_Main) then
		print("Should create a new GameInstance and invite the friend to it.");
		self:CreateGameAndInviteFacebookFriend(facebookFriend);
	elseif (g_PreviousMenu == BaseState.State_GameInstance) then
		print("Should invite facebook friend to an existing GameInstance.");
		self:InviteFacebookFriendToCurrentGame(facebookFriend);
	elseif (g_PreviousMenu == BaseState.State_ChatRoom) then
		print("Should invite facebook friend to a ChatRoom.");
		self:InviteFacebookFriendToCurrentChatRoom(facebookFriend);
	end
end


function MenuFriendLobby:CreateGameAndInviteFacebookFriend(facebookFriend)

	local function onSendPostToFacebookUser(callback)
		print("onSendPostToFacebookUser(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			ChangeState(BaseState.State_Main);
		elseif (callback.Status ~= "Canceled") then
			showAlert("Uh Oh", callback.Description);
		end
	end

	local function onInviteFacebookFriendToGame(callback)
		print("onInviteFacebookFriendToGame(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			local postMessage = g_Together:GetUserViewName() .. " has invited you to play a game!";

    		g_Together.Social.Facebook:SendPostToFacebookUser(facebookFriend.FriendID,
													   "Together Tic-Tac-Toe",
        				  							   postMessage,
        				  							   "http://www.google.com",
        				  							   "http://api.playstogether.com/Images/TicTacToe/Icon-72.png",
        				  							   onSendPostToFacebookUser);
		end
	end

	local function onCreateGame(callback)
		print("onCreateGame(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			local notificationMessage = '';

			local gameInstanceUserProperties = together.PropertyCollection:New();
			gameInstanceUserProperties:Set("Score", "31");
	
			-- Invite the facebook friend to the current GameInstance.
			g_CurrentGameInstance:InviteUser(0,						-- inviteeUserID
									 "FB",							-- inviteeSocialType
								 	 facebookFriend.FriendID,		-- inviteeSocialID
									 gameInstanceUserProperties,	-- gameUserProperties
									 notificationMessage, 			-- notificationMessage
									 onInviteFacebookFriendToGame);	-- callbackFunc
		else
			showAlert("Uh Oh", callback.Description);
		end
	end


	local gameInstanceProperties = together.PropertyCollection:New();
	gameInstanceProperties:Set("Data", "_________");

	local gameInstanceUserProperties = together.PropertyCollection:New();
	gameInstanceUserProperties:Set("Score", "12");

	-- Create a new GameInstance.
	g_Together.GameInstanceManager:Create("", 							-- gameInstanceType
										  0,							-- roomID
										  2,							-- maxUsers
										  false,						-- passTurn
										  gameInstanceProperties, 		-- gameInstanceProperties
										  gameInstanceUserProperties,	-- gameInstanceUserProperties
										  onCreateGame);				-- callbackFunc
end

function MenuFriendLobby:InviteFacebookFriendToCurrentGame(facebookFriend)
	local function onSendPostToFacebookUser(callback)
		print("onSendPostToFacebookUser(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			ChangeState(BaseState.State_GameInstance);
		elseif (callback.Status ~= "Canceled") then
			showAlert("Uh Oh", callback.Description);
		end
	end

	local function onInviteFacebookFriendToCurrentGame(callback)
		print("onInviteFacebookFriendToCurrentGame(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			local postMessage = g_Together:GetUserViewName() .. " has invited you to play a game!";

    		g_Together.Social.Facebook:SendPostToFacebookUser(facebookFriend.FriendID,
													   "Together Tic-Tac-Toe",
        				  							   postMessage,
        				  							   "http://www.google.com",
        				  							   "http://api.playstogether.com/Images/TicTacToe/Icon-72.png",
        				  							   onSendPostToFacebookUser);
		end
	end


	local gameInstanceUserProperties = together.PropertyCollection:New();
	gameInstanceUserProperties:Set("Score", "12");

	local notificationMessage = '';

	-- Invite the facebook friend to the current GameInstance.
	g_CurrentGameInstance:InviteUser(0,										-- inviteeUserID
									 "FB",									-- inviteeSocialType
								 	 facebookFriend.FriendID,				-- inviteeSocialID
									 gameInstanceUserProperties,--nil,									-- gameUserProperties
									 notificationMessage, 					-- notificationMessage
									 onInviteFacebookFriendToCurrentGame);	-- callbackFunc
end

function MenuFriendLobby:InviteFacebookFriendToCurrentChatRoom(facebookFriend)
	print("MenuFriendLobby:InviteFacebookFriendToCurrentChatRoom()");

	local function onSendPostToFacebookUser(callback)
		print("onSendPostToFacebookUser(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			ChangeState(BaseState.State_ChatRoom);
		elseif (callback.Status ~= "Canceled") then
			showAlert("Uh Oh", callback.Description);
		end
	end

	local function onInviteFacebookFriendToChatRoom(callback)
		print("onInviteFacebookFriendToChatRoom(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			local postMessage = g_Together:GetUserViewName() .. " has invited you to a chat room!";
										
    		g_Together.Social.Facebook:SendPostToFacebookUser(facebookFriend.FriendID,
													   "Together Tic-Tac-Toe",
        				  							   postMessage,
        				  							   "http://www.google.com",
        				  							   "http://api.playstogether.com/Images/TicTacToe/Icon-72.png",
        				  							   onSendPostToFacebookUser);
		else
			showAlert("Uh Oh", callback.Description);
		end
	end


	local notificationMessage = g_Together:GetUserViewName() .. " has invited you to a chat room!";
	notificationMessage = "";

	-- Invite the friend User to the current ChatRoom.
	g_CurrentChatRoom:InviteUser(0, 								-- inviteeUserID
								 "FB",								-- inviteeSocialType
								 facebookFriend.FriendID,			-- inviteeSocialID
								 notificationMessage, 				-- notificationMessage
								 onInviteFacebookFriendToChatRoom);	-- callbackFunc
end


return MenuFriendLobby;


