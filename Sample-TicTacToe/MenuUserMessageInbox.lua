--module(..., package.seeall)

local BaseState = require("BaseState");

local MenuUserMessageInbox = {};
local super = BaseState	--Inherit from BaseState
setmetatable(MenuUserMessageInbox, { __index = super } );
local mt = { __index = MenuUserMessageInbox };

-----------------
-- Constructor --
-----------------

function MenuUserMessageInbox:New()
	local self = BaseState:New();
	setmetatable(self, mt);

   	self.type = BaseState.State_UserMessageInbox;

   	self.ShouldPoll = true;
   	self.TimeInc = 0;
   	self.PollInterval = 7.0;

   	self.UserMessageButtons = {};

   	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuUserMessageInbox:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	print("MenuUserMessageInbox:Enter()");

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

    local function onBackButtonClicked()
   		ChangeState(BaseState.State_Main);
    end

    local function onCreateMessageButtonClicked()
    	self:onCreateUserMessageButtonClicked();
    end
    
    local function onMarkLastButtonClicked()
    	self:OnMarkLastButtonClicked();
    end
    
    local function onDeleteLastButtonClicked()
    	self:OnDeleteLastButtonClicked();
    end
    
    local topY = display.contentHeight * 0.1;


   	local title = display.newText(displayGroup, "User Messages", 0, 0, native.systemFontBold, 42);
    title.x = display.contentCenterX;
   	title.y = topY;

   	local backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
    backButton:SetPos(80, 30);

    local createMessageButton = TextButton:New(displayGroup, "Create Message", onCreateMessageButtonClicked, 20);
    createMessageButton:SetPos(130, 140);
    
    local markLastMessage = TextButton:New(displayGroup, "Mark Last As Read", onMarkLastButtonClicked, 20);
    markLastMessage:SetPos(430, 140);
    
    local deleteLastMessage = TextButton:New(displayGroup, "Delete Last", onDeleteLastButtonClicked, 20);
    deleteLastMessage:SetPos(130, 200);

    unrequire("ImageButton");
    unrequire("TextButton");

	self:ForceUpdate();
end


function MenuUserMessageInbox:ForceUpdate()
	self.TimeInc = 0.0;
			
	self:GetAllUserMessages();
end

function MenuUserMessageInbox:Update(elapsedTime)
	if (self.ShouldPoll == true) then
		self.TimeInc = self.TimeInc + elapsedTime;
		if (self.TimeInc >= self.PollInterval) then
			self.TimeInc = self.TimeInc - self.PollInterval;
			self:GetAllUserMessages();
		end
	end
end

function MenuUserMessageInbox:Draw()
end

function MenuUserMessageInbox:Exit()
	super.Exit(self);
end

function MenuUserMessageInbox:HandleKeyEvent(event)
	return false;
end



function MenuUserMessageInbox:GetAllUserMessages()
    local function onGotAllUserMessages(callback)
		print("onGotAllUserMessages(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:AllUserMessagesRetrieved();
		end
	end

	g_Together.UserMessageManager:GetAll(1,		-- UnreadOnly
										0,		-- StartID
										50,		-- Count
										onGotAllUserMessages);
end

function MenuUserMessageInbox:onCreateUserMessageButtonClicked()
	print("CreateMessage Button clicked.");
	
	g_PreviousMenu = BaseState.State_UserMessageInbox;
	ChangeState(BaseState.State_FriendLobby);
end

function MenuUserMessageInbox:OnMarkLastButtonClicked()
	print("MarkLastAsRead Button clicked.");
	
	local function onMessageMarked(callback)
		print("onMessageMarked(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:ForceUpdate();
		else
			showAlert("Uh Oh", callback.Description);
		end
	end
	
	if (g_Together.UserMessageManager:GetCount() == 0) then
		return;
	end
	
	local userMessage = g_Together.UserMessageManager:Get(g_Together.UserMessageManager:GetCount());

    -- Mark user message as read.
	g_Together.UserMessageManager:MarkMessageAsRead(userMessage.UserMessageID, 	-- UserMessageID
											  onMessageMarked);					-- callbackFunc
end

function MenuUserMessageInbox:OnDeleteLastButtonClicked()
	print("DeleteLast Button clicked.");
	
	local function onMessageDeleted(callback)
		print("onMessageDeleted(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:ForceUpdate();
		else
			showAlert("Uh Oh", callback.Description);
		end
	end
	
	if (g_Together.UserMessageManager:GetCount() == 0) then
		return;
	end
		
	local userMessage = g_Together.UserMessageManager:Get(g_Together.UserMessageManager:GetCount());

    -- Delete user message.
	g_Together.UserMessageManager:DeleteMessage(userMessage.UserMessageID, 		-- UserMessageID
											  onMessageDeleted);				-- callbackFunc
end


------------------------------------------------
-- Events.
------------------------------------------------
function MenuUserMessageInbox:AllUserMessagesRetrieved()
	g_Together.UserMessageManager:Dump();

	self:DestroyUserMessageButtons();
	self:CreateUserMessageButtons();
end

function MenuUserMessageInbox:BuildUserMessageButtonLabel(userMessage)
	local theButtonLabel = "ID=" .. userMessage.UserMessageID ..
		", Title=" .. userMessage.Title;
	
	return theButtonLabel;
end

function MenuUserMessageInbox:UserMessageButtonClicked(index)
	print("MenuUserMessageInbox:UserMessageButtonClicked(" .. index .. ")");

	--g_CurrentChatRoom = g_Together.ChatRoomManager:Get(index);

--	native.showAlert("Info", "Should enter ChatRoom", { "OK" } )
	--ChangeState(BaseState.State_ChatRoom);
end


function MenuUserMessageInbox:CreateUserMessageButtons()
	local TextButton = require("TextButton");

    local function onUserMessageButton1Clicked(event)
    	self:UserMessageButtonClicked(1);
   	end
   	local function onUserMessageButton2Clicked(event)
   		self:UserMessageButtonClicked(2);
   	end
    local function onUserMessageButton3Clicked(event)
   		self:UserMessageButtonClicked(3);
   	end
    local function onUserMessageButton4Clicked(event)
   		self:UserMessageButtonClicked(4);
   	end
    local function onUserMessageButton5Clicked(event)
   		self:UserMessageButtonClicked(5);
   	end
    local function onUserMessageButton6Clicked(event)
   		self:UserMessageButtonClicked(6);
   	end
    local function onUserMessageButton7Clicked(event)
   		self:UserMessageButtonClicked(7);
   	end
    local function onUserMessageButton8Clicked(event)
   		self:UserMessageButtonClicked(8);
   	end
    local function onUserMessageButton9Clicked(event)
   		self:UserMessageButtonClicked(9);
   	end

   	local userMessageCount = g_Together.UserMessageManager:GetCount();
	local userMessage;
   	local buttonY = 260;
   	local theButtonLabel = "";
   	local theButton = nil;

   	if (userMessageCount > 9) then
   		userMessageCount = 9;
   	end

   	self.UserMessageButtons = {};

   	print("userMessageCount = " .. userMessageCount);

   	for i=1, userMessageCount do
   		userMessage = g_Together.UserMessageManager:Get(i);

   		userMessage:Dump();

   		theButtonLabel = self:BuildUserMessageButtonLabel(userMessage);
    
   		if (i == 1) then
   			theButton = TextButton:New(self.displayGroup, theButtonLabel, onUserMessageButton1Clicked, 20);
   		elseif (i == 2) then
   			theButton = TextButton:New(self.displayGroup, theButtonLabel, onUserMessageButton2Clicked, 20);
   		elseif (i == 3) then
   			theButton = TextButton:New(self.displayGroup, theButtonLabel, onUserMessageButton3Clicked, 20);
   		elseif (i == 4) then
   			theButton = TextButton:New(self.displayGroup, theButtonLabel, onUserMessageButton4Clicked, 20);
   		elseif (i == 5) then
   			theButton = TextButton:New(self.displayGroup, theButtonLabel, onUserMessageButton5Clicked, 20);
   		elseif (i == 6) then
   			theButton = TextButton:New(self.displayGroup, theButtonLabel, onUserMessageButton6Clicked, 20);
   		elseif (i == 7) then
   			theButton = TextButton:New(self.displayGroup, theButtonLabel, onUserMessageButton7Clicked, 20);
   		elseif (i == 8) then
   			theButton = TextButton:New(self.displayGroup, theButtonLabel, onUserMessageButton8Clicked, 20);
   		elseif (i == 9) then
   			theButton = TextButton:New(self.displayGroup, theButtonLabel, onUserMessageButton9Clicked, 20);
   		end

   		theButton:SetPos(display.contentCenterX, buttonY);
   		buttonY = buttonY + 80;

		table.insert(self.UserMessageButtons, theButton);
   	end

   	unrequire("TextButton");
end

function MenuUserMessageInbox:DestroyUserMessageButtons()
	local buttonCount = table.getn(self.UserMessageButtons);
	local userMessageButton;

    for i=1, buttonCount do
   		userMessageButton = self.UserMessageButtons[i];
  		userMessageButton:CleanUp();
   		self.displayGroup:remove(userMessageButton.displayGroup);
   	end

   	self.UserMessageButtons = {};
end


return MenuUserMessageInbox;


