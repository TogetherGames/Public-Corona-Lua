--module(..., package.seeall)

local BaseState = require("BaseState");
local together = require("plugin.together");

local MenuChatRoomLobby = {};
local super = BaseState	--Inherit from BaseState
setmetatable(MenuChatRoomLobby, { __index = super } );
local mt = { __index = MenuChatRoomLobby };

-----------------
-- Constructor --
-----------------

function MenuChatRoomLobby:New()
	local self = BaseState:New();
	setmetatable(self, mt);

   	self.type = BaseState.State_ChatRoomLobby;

   	self.ShouldPoll = true;
   	self.TimeInc = 0;
   	self.PollInterval = 7.0;

   	self.ChatRoomButtons = {};

   	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuChatRoomLobby:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	print("MenuChatRoomLobby:Enter()");

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

    local backButton;
    local createRoomButton;

    local function onBackButtonClicked()
   		ChangeState(BaseState.State_Main);
    end

    local function onCreateRoomButtonClicked()
    	self:OnCreateRoomButtonClicked();
    end
    
    local topY = display.contentHeight * 0.1;


   	local title = display.newText(displayGroup, "Chat Rooms", 0, 0, native.systemFontBold, 42);
    title.x = display.contentCenterX;
   	title.y = topY;

   	backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
    backButton:SetPos(80, 30);

    createRoomButton = TextButton:New(displayGroup, "Create Room", onCreateRoomButtonClicked, 20);
    createRoomButton:SetPos(130, 140);
    	

    unrequire("ImageButton");
    unrequire("TextButton");

	self:ForceUpdate();
end


function MenuChatRoomLobby:ForceUpdate()
	self.TimeInc = 0.0;
			
	self:GetAllChatRooms();
end

function MenuChatRoomLobby:Update(elapsedTime)
	if (self.ShouldPoll == true) then
		self.TimeInc = self.TimeInc + elapsedTime;
		if (self.TimeInc >= self.PollInterval) then
			self.TimeInc = self.TimeInc - self.PollInterval;
			self:GetAllChatRooms();
		end
	end
end

function MenuChatRoomLobby:Draw()
end

function MenuChatRoomLobby:Exit()
	super.Exit(self);
end

function MenuChatRoomLobby:HandleKeyEvent(event)
	return false;
end



function MenuChatRoomLobby:GetAllChatRooms()
    local function onGotAllChatRooms(callback)
		print("onGotAllChatRooms(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:AllChatRoomsRetrieved();
		end
	end

	g_Together.ChatRoomManager:GetAll(0, onGotAllChatRooms);
end

function MenuChatRoomLobby:OnCreateRoomButtonClicked()
	print("CreateRoom Button clicked.");

    local function onCreateChatRoom(callback)
		print("onCreateChatRoom(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:GetAllChatRooms();
		end
	end


	-- Create a ChatRoom.
	local chatRoomProperties = together.PropertyCollection:New();
	chatRoomProperties:Set("SomeData", "Created");

	g_Together.ChatRoomManager:Create("Hello", 				-- name
									  "Hello ChatRoom",		-- description
									  0,					-- roomID
									  0,					-- gameInstanceID
									  true,					-- joinChatRoom
									  chatRoomProperties,	-- chatRoomProperties
									  onCreateChatRoom);	-- callbackFunc
end



------------------------------------------------
-- Events.
------------------------------------------------
function MenuChatRoomLobby:AllChatRoomsRetrieved()
	g_Together.ChatRoomManager:Dump();

	self:DestroyChatRoomButtons();
	self:CreateChatRoomButtons();
end

function MenuChatRoomLobby:BuildChatRoomButtonLabel(chatRoom)
	local theButtonLabel = "ID=" .. chatRoom.ChatRoomID ..
		", Name=" .. chatRoom.Name;
	
	return theButtonLabel;
end

function MenuChatRoomLobby:ChatRoomButtonClicked(index)
	print("MenuChatRoomLobby:ChatRoomButtonClicked(" .. index .. ")");

	g_CurrentChatRoom = g_Together.ChatRoomManager:Get(index);

--	native.showAlert("Info", "Should enter ChatRoom", { "OK" } )
	ChangeState(BaseState.State_ChatRoom);
end


function MenuChatRoomLobby:CreateChatRoomButtons()
	local TextButton = require("TextButton");

    local function onChatRoomButtonClicked(event, button)
    	self:ChatRoomButtonClicked(button.buttonIndex);
   	end


   	local chatRoomCount = g_Together.ChatRoomManager:GetCount();
	local chatRoom;
   	local buttonY = 240;
   	local theButtonLabel = "";
   	local theButton = nil;

   	if (chatRoomCount > 9) then
   		chatRoomCount = 9;
   	end

   	self.ChatRoomButtons = {};

   	print("chatRoomCount = " .. chatRoomCount);

   	for i=1, chatRoomCount do
   		chatRoom = g_Together.ChatRoomManager:Get(i);

   		chatRoom:Dump();

   		theButtonLabel = self:BuildChatRoomButtonLabel(chatRoom);
    
   		theButton = TextButton:New(self.displayGroup, theButtonLabel, onChatRoomButtonClicked, 20);
   		theButton.buttonIndex = i;
   		theButton:SetPos(display.contentCenterX, buttonY);
   		buttonY = buttonY + 80;

		table.insert(self.ChatRoomButtons, theButton);
   	end

   	unrequire("TextButton");
end

function MenuChatRoomLobby:DestroyChatRoomButtons()
	local buttonCount = table.getn(self.ChatRoomButtons);
	local chatRoomButton;

    for i=1, buttonCount do
   		chatRoomButton = self.ChatRoomButtons[i];
  		chatRoomButton:CleanUp();
   		self.displayGroup:remove(chatRoomButton.displayGroup);
   	end

   	self.ChatRoomButtons = {};
end


return MenuChatRoomLobby;


