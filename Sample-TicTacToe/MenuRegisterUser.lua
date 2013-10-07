--module(..., package.seeall)

local json = require("json");
local facebook = require("facebook");
local BaseState = require("BaseState");

local MenuRegisterUser = {};
local super = BaseState	--Inherit from BaseState
setmetatable(MenuRegisterUser, { __index = super } );
local mt = { __index = MenuRegisterUser };

-----------------
-- Constructor --
-----------------

function MenuRegisterUser:New()
	local self = BaseState:New();
	setmetatable(self, mt);

   	self.type = BaseState.State_RegisterUser;

   	self.DisableInput 					= false;
    self.FacebookAppID 					= "380670285349853";

 	self.UserIDLabel 					= nil;
    self.UsernameLabel 					= nil;
   
 	self.RegisterFacebookUserButton 	= nil;
   	self.RegisterTwitterUserButton 		= nil;
   	self.RegisterGooglePlusUserButton 	= nil;
   	self.RegisterGameCenterUserButton 	= nil;
   	self.RegisterCustomUserButton		= nil;
   	
    return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuRegisterUser:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	print("MenuRegisterUser:Enter()");

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

    local backButton;


    local function onBackButtonClicked()
    	ChangeState(BaseState.State_Main);
    end

    local function onRegisterFacebookUserButtonClicked()
    	print("onRegisterFacebookUserButtonClicked()");
		self:LogIntoFacebook();
    end

    local function onRegisterTwitterUserButtonClicked()
    	print("onRegisterTwitterUserButtonClicked()");
		self:RegisterTwitterUser();
    end

    local function onRegisterGooglePlusUserButtonClicked()
    	print("onRegisterGooglePlusUserButtonClicked()");
		self:RegisterGooglePlusUser();
    end
    
    local function onRegisterGameCenterUserButtonClicked()
    	print("onRegisterGameCenterUserButtonClicked()");
		self:RegisterGameCenterUser();
    end

    local function onRegisterCustomUserButtonClicked()
    	print("onRegisterCustomUserButtonClicked()");
		self:RegisterCustomUser();
    end


    local topY = display.contentHeight * 0.1;

    self.UserIDLabel = display.newText(displayGroup, "UserID=" .. g_Together:GetUserID(), 0, 0, native.systemFontBold, 30);
   	self.UserIDLabel.x = display.contentCenterX;
   	self.UserIDLabel.y = topY - 55;
   	
   	self.UsernameLabel = display.newText(displayGroup, "Username=" .. g_Together:GetUserViewName(), 0, 0, native.systemFontBold, 30);
    self.UsernameLabel.x = display.contentCenterX;
   	self.UsernameLabel.y = topY - 10;

   	topY = topY + 100;

    local title = display.newText(displayGroup, "Register User", 0, 0, native.systemFontBold, 42);
    title.x = display.contentCenterX;
    title.y = topY;

    backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
    backButton:SetPos(80, 30);
    
   	local buttonY = 300;
   	self.RegisterFacebookUserButton = TextButton:New(displayGroup, "Facebook", onRegisterFacebookUserButtonClicked, 20);
   	self.RegisterFacebookUserButton:SetPos(display.contentCenterX-200, buttonY);
	if (g_Together.TogetherUser.FacebookUser ~= nil) then
	   	self.RegisterFacebookUserButton:SetPos(display.contentCenterX+200, buttonY);
	end
	buttonY = buttonY + 80;

   	self.RegisterTwitterUserButton = TextButton:New(displayGroup, "Twitter", onRegisterTwitterUserButtonClicked, 20);
   	self.RegisterTwitterUserButton:SetPos(display.contentCenterX-200, buttonY);
	self.RegisterTwitterUserButton.enabled = false;
   	self.RegisterTwitterUserButton.displayGroup.alpha = 0.3;
   	buttonY = buttonY + 80;

   	self.RegisterGooglePlusUserButton = TextButton:New(displayGroup, "Google Plus", onRegisterGooglePlusUserButtonClicked, 20);
   	self.RegisterGooglePlusUserButton:SetPos(display.contentCenterX-200, buttonY);
	self.RegisterGooglePlusUserButton.enabled = false;
   	self.RegisterGooglePlusUserButton.displayGroup.alpha = 0.3;
   	buttonY = buttonY + 80;

   	self.RegisterGameCenterUserButton = TextButton:New(displayGroup, "Game Center", onRegisterGameCenterUserButtonClicked, 20);
   	self.RegisterGameCenterUserButton:SetPos(display.contentCenterX-200, buttonY);
	self.RegisterGameCenterUserButton.enabled = false;
   	self.RegisterGameCenterUserButton.displayGroup.alpha = 0.3;
   	buttonY = buttonY + 80;
    
   	self.RegisterCustomUserButton = TextButton:New(displayGroup, "Custom", onRegisterCustomUserButtonClicked, 20);
   	self.RegisterCustomUserButton:SetPos(display.contentCenterX-200, buttonY);
	if (g_Together.TogetherUser.CustomUser ~= nil) then
	   	self.RegisterCustomUserButton:SetPos(display.contentCenterX+200, buttonY);
	end
   	buttonY = buttonY + 80;
    

    buttonY = buttonY + 80;


    unrequire("ImageButton");
    unrequire("TextButton");
end

function MenuRegisterUser:Update(elapsedTime)
end

function MenuRegisterUser:Draw()
end

function MenuRegisterUser:Exit()
	super.Exit(self);
end

function MenuRegisterUser:HandleKeyEvent(event)
	return false;
end


function MenuRegisterUser:RefreshUserLabels()
	self.UserIDLabel.text = "UserID=" .. g_Together:GetUserID();
   	self.UsernameLabel.text = "Username=" .. g_Together:GetUserViewName();
end

function MenuRegisterUser:RefreshUserButtons()
   	local buttonY = 300;
   	self.RegisterFacebookUserButton:SetPos(display.contentCenterX-200, buttonY);
	if (g_Together.TogetherUser.FacebookUser ~= nil) then
	   	self.RegisterFacebookUserButton:SetPos(display.contentCenterX+200, buttonY);
	end
	buttonY = buttonY + 80;

   	self.RegisterTwitterUserButton:SetPos(display.contentCenterX-200, buttonY);
	buttonY = buttonY + 80;

   	self.RegisterGooglePlusUserButton:SetPos(display.contentCenterX-200, buttonY);
	buttonY = buttonY + 80;

   	self.RegisterGameCenterUserButton:SetPos(display.contentCenterX-200, buttonY);
	buttonY = buttonY + 80;
    
   	self.RegisterCustomUserButton:SetPos(display.contentCenterX-200, buttonY);
	if (g_Together.TogetherUser.CustomUser ~= nil) then
	   	self.RegisterCustomUserButton:SetPos(display.contentCenterX+200, buttonY);
	end
   	buttonY = buttonY + 80;
end

function MenuRegisterUser:RegisterFacebookUser()

	local function onRegisterFacebookUser(callback)
		print("******   onRegisterFacebookUser(" .. callback.Status .. ", " .. callback.Description .. ")");
		print("******   onRegisterFacebookUser(" .. callback.Status .. ", " .. callback.Description .. ")");
		print("******   onRegisterFacebookUser(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:RefreshUserLabels();
			self:RefreshUserButtons();
--			ChangeState(BaseState.State_Main);
		else
			showAlert("Uh Oh", callback.Description);
		end
	end


	local togetherFacebookUser = g_Together.TogetherUser:GetTogetherFacebookUser();

	g_Together:RegisterFacebook(togetherFacebookUser.FacebookID,
	    	togetherFacebookUser.Name,
    		togetherFacebookUser.FirstName,
    		togetherFacebookUser.LastName,
	    	togetherFacebookUser.Link,
    		togetherFacebookUser.Username,
    		togetherFacebookUser.Gender,
	    	togetherFacebookUser.Locale,
    		onRegisterFacebookUser);
end


function MenuRegisterUser:LogIntoFacebook()

	local function onLogIntoFacebook(callback)
		print("onLogIntoFacebook(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:RefreshUserLabels();
			self:RefreshUserButtons();
--			ChangeState(BaseState.State_Main);
--			self:RegisterFacebookUser();
		else
			showAlert("Uh Oh", callback.Description);
		end
	end

	local togetherFacebookUser = g_Together.TogetherUser:GetTogetherFacebookUser();

	-- Attempt to log into Facebook.
	g_Together.Social.Facebook:Login(togetherFacebookUser, onLogIntoFacebook);
end


function MenuRegisterUser:LogOutOfFacebook()

	-- listener for "fbconnect" events
	local function onLoggedOutOfFacebook(event)
   		if ("session" == event.type) then
       		-- upon successful login, immediately logout
       		if ("login" == event.phase) then
            	facebook.logout();
            	ChangeState(BaseState.State_Main);
            end
        end
    end

	-- first argument is the app id that you get from Facebook
	facebook.login(self.FacebookAppID, onLoggedOutOfFacebook);    	
end



function MenuRegisterUser:RegisterTwitterUser()
	showAlert("Info", "Should register a Twitter user.");
end

function MenuRegisterUser:RegisterGooglePlusUser()
	showAlert("Info", "Should register a GooglePlus user.");
end

function MenuRegisterUser:RegisterGameCenterUser()
	showAlert("Info", "Should register a GameCenter user.");
end

function MenuRegisterUser:RegisterCustomUser()
	ChangeState(BaseState.State_RegisterCustomUser);
end


return MenuRegisterUser;



