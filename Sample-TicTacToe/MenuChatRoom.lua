--module(..., package.seeall)

local BaseState = require("BaseState");

local MenuChatRoom = {};
local super = BaseState	--Inherit from BaseState
setmetatable(MenuChatRoom, { __index = super } );
local mt = { __index = MenuChatRoom };

-----------------
-- Constructor --
-----------------

function MenuChatRoom:New()
	local self = BaseState:New();
	setmetatable(self, mt);

   	self.type = BaseState.State_ChatRoom;

   	self.ShouldPoll = true;
   	self.TimeInc = 0;
   	self.PollInterval = 7.0;

   	self.ChatRoomUserLabels = {};
   	self.ChatMessageLabels = {};

	self.User = nil;
	self.ChatRoom = nil;

   	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuChatRoom:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	print("MenuChatRoom:Enter()");

	self.User = g_Together.TogetherUser;
	self.ChatRoom = g_CurrentChatRoom;

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

    local backButton;
    local deleteRoomButton;
    local createMessageButton;
    local joinMessageButton;
    local leaveMessageButton;
    local deleteTopMessageButton;
    local markTopMessageAsReadButton;
	local inviteFriendButton;

    local chatRoomUsersLabel;
    local chatRoomUserLabel;
    local chatMessagesLabel;
    local chatMessageLabel;

    local function onBackButtonClicked()
   		ChangeState(BaseState.State_ChatRoomLobby);
    end

    local function onDeleteRoomButtonClicked()
    	self:OnDeleteRoomButtonClicked();
    end

    local function onModifyRoomButtonClicked()
    	self:OnModifyRoomButtonClicked();
    end

    local function onJoinRoomButtonClicked()
    	self:OnJoinRoomButtonClicked();
    end

    local function onLeaveRoomButtonClicked()
    	self:OnLeaveRoomButtonClicked();
    end

    local function onCreateMessageButtonClicked()
    	self:OnCreateMessageButtonClicked();
    end

    local function onDeleteLastMessageButtonClicked()
    	self:OnDeleteLastMessageButtonClicked();
    end

    local function onMarkLastMessageAsReadButtonClicked()
    	self:OnMarkLastMessageAsReadButtonClicked();
    end

    local function onInviteFriendButtonClicked()
    	self:OnInviteFriendButtonClicked();
    end


    local topY = display.contentHeight * 0.1;


   	local title = display.newText(displayGroup, "Chat Room", 0, 0, native.systemFontBold, 42);
    title.x = display.contentCenterX;
   	title.y = topY;

   	backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
    backButton:SetPos(80, 30);

   	deleteRoomButton = TextButton:New(displayGroup, "Delete", onDeleteRoomButtonClicked, 20);
   	deleteRoomButton:SetPos(120, 150);

   	modifyRoomButton = TextButton:New(displayGroup, "Modify", onModifyRoomButtonClicked, 20);
   	modifyRoomButton:SetPos(300, 150);

   	joinMessageButton = TextButton:New(displayGroup, "Join", onJoinRoomButtonClicked, 20);
   	joinMessageButton:SetPos(120, 210);

    leaveMessageButton = TextButton:New(displayGroup, "Leave", onLeaveRoomButtonClicked, 20);
   	leaveMessageButton:SetPos(120, 270);

   	createMessageButton = TextButton:New(displayGroup, "Create Message", onCreateMessageButtonClicked, 20);
    createMessageButton:SetPos(200, 330);

   	deleteLastMessageButton = TextButton:New(displayGroup, "Delete Last Message", onDeleteLastMessageButtonClicked, 20);
    deleteLastMessageButton:SetPos(200, 390);

   	markLastMessageAsReadButton = TextButton:New(displayGroup, "Mark Last Message As Read", onMarkLastMessageAsReadButtonClicked, 20);
    markLastMessageAsReadButton:SetPos(200, 450);

   	inviteFriendButton = TextButton:New(displayGroup, "Invite Friend", onInviteFriendButtonClicked, 20);
    inviteFriendButton:SetPos(300, 210);


  	topY = 140;
	chatRoomUsersLabel = display.newText(displayGroup, "Users", 0, 0, native.systemFontBold, 28);
	chatRoomUsersLabel.x = display.contentCenterX + 200;
	chatRoomUsersLabel.y = topY;
    topY = topY + 48;

  	for i=1, 7 do
    	chatRoomUserLabel = display.newText(displayGroup, "", 0, 0, native.systemFontBold, 24);
    	chatRoomUserLabel.x = display.contentCenterX + 200;
    	chatRoomUserLabel.y = topY;

    	table.insert(self.ChatRoomUserLabels, chatRoomUserLabel);

    	topY = topY + 45;
	end


  	topY = 530;
    chatMessagesLabel = display.newText(displayGroup, "Messages", 0, 0, native.systemFontBold, 28);
    chatMessagesLabel.x = display.contentCenterX;
    chatMessagesLabel.y = topY;
    topY = topY + 56;
 
  	for i=1, 9 do
    	chatMessageLabel = display.newText(displayGroup, "", 0, 0, native.systemFontBold, 24);
    	chatMessageLabel.x = display.contentCenterX;
    	chatMessageLabel.y = topY;

    	table.insert(self.ChatMessageLabels, chatMessageLabel);

    	topY = topY + 48;
	end
    
    unrequire("ImageButton");
    unrequire("TextButton");


	self:ForceUpdate();
end


function MenuChatRoom:ForceUpdate()
	self.TimeInc = 0.0;
			
	self:GetChatRoomDetails();
end

function MenuChatRoom:Update(elapsedTime)
	if (self.ShouldPoll == true) then
		self.TimeInc = self.TimeInc + elapsedTime;
		if (self.TimeInc >= self.PollInterval) then
			self.TimeInc = self.TimeInc - self.PollInterval;
			self:GetChatRoomDetails();
		end
	end
end

function MenuChatRoom:Draw()
end

function MenuChatRoom:Exit()
	super.Exit(self);
end

function MenuChatRoom:HandleKeyEvent(event)
	return false;
end





function MenuChatRoom:GetChatRoomDetails()
   	local function onGotChatRoomDetails(callback)
		print("onGotChatRoomDetails(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:RoomDetailsRetrieved();
		elseif (callback.Status == "Deleted") then
			ChangeState(BaseState.State_ChatRoomLobby);
		end
	end
	
	self.ChatRoom:GetDetails(self.ChatRoom.ChatRoomID, 0, onGotChatRoomDetails);
end

function MenuChatRoom:OnDeleteRoomButtonClicked()
	print("MenuChatRoom:OnDeleteRoomButtonClicked()");

   	local function onDeletedChatRoom(callback)
		print("onDeletedChatRoom(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			ChangeState(BaseState.State_ChatRoomLobby);
		end
	end
	
  	g_Together.ChatRoomManager:Delete(self.ChatRoom.ChatRoomID,
    								  onDeletedChatRoom);
end

function MenuChatRoom:OnJoinRoomButtonClicked()
	print("MenuChatRoom:OnJoinRoomButtonClicked()");

   	local function onJoinedRoom(callback)
		print("onJoinedRoom(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:GetChatRoomDetails();
		else
			showAlert("Uh Oh", description);
		end
	end
	
	self.ChatRoom:Join(onJoinedRoom);	
end

function MenuChatRoom:OnLeaveRoomButtonClicked()
	print("MenuChatRoom:OnLeaveRoomButtonClicked()");

    local function onLeftChatRoom(callback)
		print("onLeftChatRoom(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			ChangeState(BaseState.State_ChatRoomLobby);
		else
			showAlert("Uh Oh", description);
		end
	end
	
	local myChatRoomUser = self.ChatRoom:FindChatRoomUserByUserID(self.User.UserID);
   	if (myChatRoomUser == nil) then
   		showAlert("Uh Oh", "User not already a member of the chat room");
   		return;
   	end   		
   		
   	self.ChatRoom:Leave(onLeftChatRoom);
end

function MenuChatRoom:OnCreateMessageButtonClicked()
	print("MenuChatRoom:OnCreateMessageButtonClicked()");
	
	if (self.ChatRoom:FindChatRoomUserByUserID(self.User.UserID) == nil) then
		showAlert("Uh Oh", "Must be a member in order to submit messages!");
		return;
	end

	ChangeState(BaseState.State_ChatCreateMessage);
end

function MenuChatRoom:OnDeleteLastMessageButtonClicked()
	print("MenuChatRoom:OnDeleteLastMessageButtonClicked()");

    local function onMessageDeleted(callback)
		print("onLeftRoom(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:GetChatRoomDetails();
		else
			showAlert("Uh Oh", description);
		end
	end

	if (self.ChatRoom:GetChatMessageCount() > 0) then
		local chatMessage = self.ChatRoom:GetChatMessage(self.ChatRoom:GetChatMessageCount());

		self.ChatRoom:DeleteMessage(chatMessage.ChatMessageID, onMessageDeleted);
	end
end

function MenuChatRoom:OnMarkLastMessageAsReadButtonClicked()
	print("MenuChatRoom:OnMarkLastMessageAsReadButtonClicked()");

    local function onMarkedMessageAsRead(callback)
		print("onLeftRoom(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:GetChatRoomDetails();
		else
			showAlert("Uh Oh", description);
		end
	end

	if (self.ChatRoom:GetChatMessageCount() > 0) then
		local chatMessage = self.ChatRoom:GetChatMessage(self.ChatRoom:GetChatMessageCount());

		self.ChatRoom:MarkMessageAsRead(chatMessage.ChatMessageID, onMarkedMessageAsRead);
	end
end

function MenuChatRoom:OnInviteFriendButtonClicked()
	print("MenuChatRoom:OnInviteFriendButtonClicked()");
	g_PreviousMenu = BaseState.State_ChatRoom;	
	ChangeState(BaseState.State_FriendLobby);
end


------------------------------------------------
-- Events.
------------------------------------------------
function MenuChatRoom:RoomDetailsRetrieved()
	self:DestroyChatRoomUserLabels();
	self:CreateChatRoomUserLabels();
	
	self:DestroyChatMessageLabels();
	self:CreateChatMessageLabels();
end

function MenuChatRoom:BuildChatRoomUserLabelText(chatRoomUser)
	local labelText = "";
	if (chatRoomUser.UserID ~= 0) then
		labelText = chatRoomUser.UserID .. " - " .. chatRoomUser.Name;
	else
		labelText = chatRoomUser.SocialType .. " - " .. chatRoomUser.Name;
	end
	return labelText;
end

function MenuChatRoom:CreateChatRoomUserLabels()
	print("MenuChatRoom:CreateChatRoomUserLabels()");    
	local chatRoomUserCount = self.ChatRoom:GetChatRoomUserCount();
	local chatRoomUser;
   	local theLabelText = "";
   	local theLabel = nil;

   	if (chatRoomUserCount > 9) then
    	chatRoomUserCount = 9;
    end

    for i=1, chatRoomUserCount do
    	chatRoomUser = self.ChatRoom:GetChatRoomUser(i);
    
    	theLabelText = self:BuildChatRoomUserLabelText(chatRoomUser);
    
    	self.ChatRoomUserLabels[i].text = theLabelText;
    end
end

function MenuChatRoom:DestroyChatRoomUserLabels()
	local labelCount = table.getn(self.ChatRoomUserLabels);
	local chatRoomUserLabel;

    for i=1, labelCount do
    	chatRoomUserLabel = self.ChatRoomUserLabels[i];

    	chatRoomUserLabel.text = "";
    end
end



function MenuChatRoom:BuildChatMessageLabelText(chatMessage)
	local labelText = chatMessage.Name .. " - " .. chatMessage.Message;
	if (chatMessage.Read == true) then
		labelText = "* " .. labelText;
	end
	return labelText;
end

function MenuChatRoom:CreateChatMessageLabels()
	print("MenuChatRoom:CreateChatMessageLables()");    
	local chatMessageCount = self.ChatRoom:GetChatMessageCount();
	local chatMessage;
	local theLabelIndex = 1;
   	local theLabelText = "";
   	local theLabel = nil;
   	local messageIndex = chatMessageCount;

   	if (chatMessageCount > 9) then
    	chatMessageCount = 9;
    end

    theLabelIndex = 9;--chatMessageCount
   	for i=1, chatMessageCount do
    	chatMessage = self.ChatRoom:GetChatMessage(messageIndex);
    	
    	theLabelText = self:BuildChatMessageLabelText(chatMessage);
    
    	self.ChatMessageLabels[theLabelIndex].text = theLabelText;
    		
    	messageIndex = messageIndex - 1;
    	theLabelIndex = theLabelIndex - 1;
    end
end

function MenuChatRoom:DestroyChatMessageLabels()
	local labelCount = table.getn(self.ChatMessageLabels);
	local chatMessageLabel;

    for i=1, labelCount do
    	chatMessageLabel = self.ChatMessageLabels[i];
    	chatMessageLabel.text = "";
    end
end

function MenuChatRoom:OnModifyRoomButtonClicked()
	print("MenuChatRoom:OnModifyRoomButtonClicked()");
	if (self.DisableInput == true) then
		print("   Input disabled.");
		return;
	end

	local function onChatRoomModified(callback)
		print("onChatRoomModified(" .. callback.Status .. ", " .. callback.Description .. ")");
		self.DisableInput = false;
--		self:RefreshPropertyLabels();
	end

	local counterValue = self.ChatRoom.Properties:GetEx("Counter", "0");
	self.ChatRoom.Properties:Set("Counter", tostring(tonumber(counterValue) + 1));

	self.DisableInput = true;
	self.ChatRoom:Modify(onChatRoomModified);
end


return MenuChatRoom;



