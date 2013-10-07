--module(..., package.seeall)

local BaseState = require("BaseState");

local MenuRegisterCustomUser = {};
local super = BaseState	--Inherit from BaseState
setmetatable(MenuRegisterCustomUser, { __index = super } );
local mt = { __index = MenuRegisterCustomUser };

-----------------
-- Constructor --
-----------------

function MenuRegisterCustomUser:New()
	local self = BaseState:New();
	setmetatable(self, mt);

    self.type = BaseState.State_RegisterCustomUser;

    self.DisableInput = false;
    self.emailTextField = nil;
    self.passwordTextField = nil;
    self.nameTextField = nil;
    
	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuRegisterCustomUser:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	print("MenuRegisterCustomUser:Enter()");

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

    local backButton;
    local emailLabel;
    local passwordLabel;
    local nameLabel;
    local createUserButton;


    local function onBackButtonClicked()
    	ChangeState(BaseState.State_RegisterUser);
    end

    local function onEmailTextFieldClicked(getObj)
		self:EmailTextFieldClicked();    		
    end

    local function onPasswordTextFieldClicked(getObj)
		self:PasswordTextFieldClicked();    		
    end

    local function onNameTextFieldClicked(getObj)
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

    local function onCreateUserButtonClicked()
		self:CreateUser();    		
    end



    local topY = display.contentHeight * 0.1;
    
    local title = display.newText(displayGroup, "Create Custom User", 0, 0, native.systemFontBold, 42);
    title.x = display.contentCenterX;
    title.y = topY;

    backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
    backButton:SetPos(80, 30);

	local lineY = 240;
	local textFieldWidth = display.contentWidth - 200;


    -- Email Label/TextField.
    emailLabel = display.newText(displayGroup, "Email", 0, 0, native.systemFontBold, 28);
    emailLabel.x = 100 + 40;
    emailLabel.y = lineY;
    lineY = lineY + 40;

    self.emailTextField = native.newTextField(100, lineY, textFieldWidth, 36);
    self.emailTextField:addEventListener('userInput', onEmailTextFieldClicked);
    self.emailTextField.inputType = "email";
    lineY = lineY + 110;


    -- Password Label/TextField.
    passwordLabel = display.newText(displayGroup, "Password", 0, 0, native.systemFontBold, 28);
    passwordLabel.x = 100 + 68;
    passwordLabel.y = lineY;
    lineY = lineY + 40;

    self.passwordTextField = native.newTextField(100, lineY, textFieldWidth, 36);
    self.passwordTextField:addEventListener('userInput', onPasswordTextFieldClicked);
    self.passwordTextField.inputType = "default";
    self.passwordTextField.isSecure = true;
    lineY = lineY + 110;


    -- Name Label/TextField.
    nameLabel = display.newText(displayGroup, "Name", 0, 0, native.systemFontBold, 28);
    nameLabel.x = 100 + 40;
    nameLabel.y = lineY;
    lineY = lineY + 40;

    self.nameTextField = native.newTextField(100, lineY, textFieldWidth, 36);
    self.nameTextField:addEventListener('userInput', onNameTextFieldClicked);
    self.nameTextField.inputType = "default";
    lineY = lineY + 130;

    
    -- CreateUser Button.
    createUserButton = TextButton:New(displayGroup, "Create User", onCreateUserButtonClicked, 20);
    createUserButton:SetPos(display.contentCenterX, lineY);
    lineY = lineY + 80;


    unrequire("ImageButton");
    unrequire("TextButton");
end

function MenuRegisterCustomUser:Update(elapsedTime)

end

function MenuRegisterCustomUser:Draw()

end

function MenuRegisterCustomUser:Exit()
    self.emailTextField:removeSelf();
    self.emailTextField = nil;
    self.passwordTextField:removeSelf();
    self.passwordTextField = nil;
    self.nameTextField:removeSelf();
    self.nameTextField = nil;

	super.Exit(self);
end

function MenuRegisterCustomUser:HandleKeyEvent(event)

	return false;
end




function MenuRegisterCustomUser:EmailTextFieldClicked()
--	print("MenuRegisterCustomUser:EmailTextFieldClicked()");
end

function MenuRegisterCustomUser:PasswordTextFieldClicked()
--	print("MenuRegisterCustomUser:PasswordTextFieldClicked()");
end

function MenuRegisterCustomUser:NameTextFieldClicked()
--	print("MenuRegisterCustomUser:NameTextFieldClicked()");
end
    
function MenuRegisterCustomUser:CreateUser()
	print("MenuRegisterCustomUser:CreateUser()");
	if (self.DisableInput == true) then
		print("   Input disabled.");
		return;
	end

	print("   Email = " .. self.emailTextField.text);
	print("   Password = " .. self.passwordTextField.text);
	print("   Name = " .. self.nameTextField.text);

	local function onCustomUserRegistered(callback)
		print("onCustomUserRegistered(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			g_Together.TogetherUser:Dump();
			print("CustomUser successfully registered.");
			
			g_Together:SaveTogetherCache();
			self.DisableInput = false;
			ChangeState(BaseState.State_RegisterUser);
		else
			self.DisableInput = false;
			showAlert("Uh Oh", callback.Description);		
		end
	end

	self.DisableInput = true;
	g_Together:RegisterCustom(self.emailTextField.text,
							  self.passwordTextField.text,
							  self.nameTextField.text,
							  onCustomUserRegistered);
end


return MenuRegisterCustomUser;



