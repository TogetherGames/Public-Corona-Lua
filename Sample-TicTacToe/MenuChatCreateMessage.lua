--module(..., package.seeall)

local BaseState = require("BaseState");

local MenuChatCreateMessage = {};
local super = BaseState;	--Inherit from BaseState
setmetatable(MenuChatCreateMessage, { __index = super } );
local mt = { __index = MenuChatCreateMessage };

-----------------
-- Constructor --
-----------------

function MenuChatCreateMessage:New()
	local self = BaseState:New();
	setmetatable(self, mt);

   	self.type = BaseState.State_ChatCreateMessage;
   	self.MessageTextField = nil;
   	self.SendMessageButton = nil;

	self.ChatRoom = nil;

   	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuChatCreateMessage:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	print("MenuChatCreateMessage:Enter()");

	self.ChatRoom = g_CurrentChatRoom;

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

    local backButton;

    local function onBackButtonClicked()
   		ChangeState(BaseState.State_ChatRoom);
    end

    local function onMessageTextFieldClicked(getObj)
        return function(event)
			print("TextField Object is: " .. tostring(getObj()));

			if ("began" == event.phase) then
				-- This is the "keyboard has appeared" event
			elseif ("ended" == event.phase) then
				-- This event is called when the user stops editing a field:
				-- for example, when they touch a different field or keyboard focus goes away

				print( "Text entered = " .. tostring(getObj().text));         -- display the text entered
			elseif ("submitted" == event.phase) then
				-- This event occurs when the user presses the "return" key
				-- (if available) on the onscreen keyboard

				-- Hide keyboard
				native.setKeyboardFocus(nil);
				print("onNameTextFieldClicked() - event=submitted");
			end
		end  		
    end
    
   	local function onSendMessageButtonClicked()
   		self:OnSendMessageButtonClicked();
   	end
    
   	local topY = display.contentHeight * 0.1;

	local lineY = 240;
	local textFieldWidth = display.contentWidth - 200;


   	local title = display.newText(displayGroup, "Create Chat Message", 0, 0, native.systemFontBold, 42);
   	title.x = display.contentCenterX;
   	title.y = topY;

   	backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
   	backButton:SetPos(80, 30);

--  self.MessageTextField = display.newText("Hello Corona User\nHope you're having a great day.", 300, 200, "Helvetica", 18 )
--  self.MessageTextField:setTextColor(0)
    
    self.MessageTextField = native.newTextField(100, lineY, textFieldWidth, 200);
    self.MessageTextField:addEventListener('userInput', onMessageTextFieldClicked);
    self.MessageTextField.inputType = "default";
    lineY = lineY + 130;
    
    self.SendMessageButton = TextButton:New(displayGroup, "Send Message", onSendMessageButtonClicked, 20);
    self.SendMessageButton:SetPos(display.contentCenterX, display.contentHeight-100);


    unrequire("ImageButton");
    unrequire("TextButton");
end

function MenuChatCreateMessage:Draw()
end

function MenuChatCreateMessage:Exit()
	self.MessageTextField:removeSelf();
	self.MessageTextField = nil;

	super.Exit(self);
end

function MenuChatCreateMessage:HandleKeyEvent(event)
	return false;
end




------------------------------------------------
-- Events.
------------------------------------------------

function MenuChatCreateMessage:OnSendMessageButtonClicked()
	print("SendMessage Button clicked.");
	print("   Message = " .. self.MessageTextField.text); 

	local function onMessageSent(callback)
		print("onMessageSent(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			ChangeState(BaseState.State_ChatRoom);
		else
			showAlert("Uh Oh", description);
		end
	end

    self.ChatRoom:CreateMessage(0, self.MessageTextField.text, onMessageSent);
end


return MenuChatCreateMessage;



