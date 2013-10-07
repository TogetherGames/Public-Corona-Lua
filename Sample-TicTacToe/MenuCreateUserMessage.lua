--module(..., package.seeall)

local BaseState = require("BaseState");
local together = require("plugin.together");

local MenuCreateUserMessage = {};
local super = BaseState;	--Inherit from BaseState
setmetatable(MenuCreateUserMessage, { __index = super } );
local mt = { __index = MenuCreateUserMessage };

-----------------
-- Constructor --
-----------------

function MenuCreateUserMessage:New()
	local self = BaseState:New();
	setmetatable(self, mt);

   	self.type = BaseState.State_CreateUserMessage;
   	self.TitleTextField = nil;
   	self.MessageTextField = nil;
   	self.SendMessageButton = nil;

   	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuCreateUserMessage:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	print("MenuCreateUserMessage:Enter()");

	self.ChatRoom = g_CurrentChatRoom;

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

    local backButton;

    local function onBackButtonClicked()
   		ChangeState(BaseState.State_UserMessageInbox);
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

	local lineY = 210;
	local textFieldWidth = display.contentWidth - 200;


   	local title = display.newText(displayGroup, "Create User Message", 0, 0, native.systemFontBold, 42);
   	title.x = display.contentCenterX;
   	title.y = topY;
   	
   	local user = display.newText(displayGroup, "To: " .. g_StateParameters.Name .. " (" .. g_StateParameters.UserID .. ")",
   								 0, 0, native.systemFontBold, 32);
   	user.x = display.contentCenterX;
   	user.y = lineY;
   	lineY = lineY + 50;

   	backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
   	backButton:SetPos(80, 30);

--  self.MessageTextField = display.newText("Hello Corona User\nHope you're having a great day.", 300, 200, "Helvetica", 18 )
--  self.MessageTextField:setTextColor(0)

	local titleLabel = display.newText(displayGroup, "Title:", 0, 0, native.systemFontBold, 32);
   	titleLabel.x = 50;
   	titleLabel.y = lineY+35;

	self.TitleTextField = native.newTextField(100, lineY, textFieldWidth, 70);
	self.TitleTextField:addEventListener('userInput', onMessageTextFieldClicked);
	self.TitleTextField.inputType = "default";
	lineY = lineY + 100;
    
    local bodyLabel = display.newText(displayGroup, "Body:", 0, 0, native.systemFontBold, 32);
   	bodyLabel.x = 50;
   	bodyLabel.y = lineY+35;
    
    self.MessageTextField = native.newTextField(100, lineY, textFieldWidth, 200);
    self.MessageTextField:addEventListener('userInput', onMessageTextFieldClicked);
    self.MessageTextField.inputType = "default";
    lineY = lineY + 130;
    
    self.SendMessageButton = TextButton:New(displayGroup, "Send Message", onSendMessageButtonClicked, 20);
    self.SendMessageButton:SetPos(display.contentCenterX, display.contentHeight-100);


    unrequire("ImageButton");
    unrequire("TextButton");
end

function MenuCreateUserMessage:Draw()
end

function MenuCreateUserMessage:Exit()
	self.TitleTextField:removeSelf();
	self.TitleTextField = nil;
	
	self.MessageTextField:removeSelf();
	self.MessageTextField = nil;

	super.Exit(self);
end

function MenuCreateUserMessage:HandleKeyEvent(event)
	return false;
end




------------------------------------------------
-- Events.
------------------------------------------------

function MenuCreateUserMessage:OnSendMessageButtonClicked()
	print("SendMessage Button clicked.");
	print("   UserID = " .. g_StateParameters.UserID);
	print("   Title = " .. self.TitleTextField.text);
	print("   Message = " .. self.MessageTextField.text);

	local function onMessageSent(callback)
		print("onMessageSent(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			ChangeState(BaseState.State_UserMessageInbox);
		else
			showAlert("Uh Oh", description);
		end
	end

    -- Create a UserMessage.
	local messageProperties = together.PropertyCollection:New();
	messageProperties:Set("SomeData", "Created");

	g_Together.UserMessageManager:CreateMessage(g_StateParameters.UserID, 	-- destinationUserID
											  self.TitleTextField.text,		-- title
											  self.MessageTextField.text,	-- message
											  true,							-- isGameIndependent
											  messageProperties,			-- messageProperties
											  onMessageSent);				-- callbackFunc
end


return MenuCreateUserMessage;



