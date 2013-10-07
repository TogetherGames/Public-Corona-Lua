--module(..., package.seeall)

local facebook = require("facebook");
local BaseState = require("BaseState");

local MenuFacebookWallPost = {};
local super = BaseState;	--Inherit from BaseState
setmetatable(MenuFacebookWallPost, { __index = super } );
local mt = { __index = MenuFacebookWallPost };

-----------------
-- Constructor --
-----------------

function MenuFacebookWallPost:New()
    local self = BaseState:New();
	setmetatable(self, mt);

	self.type = BaseState.State_FacebookWallPost;

  	self.FacebookAppID 				= "380670285349853";

   	self.WallPostNameText 			= nil;
   	self.WallPostDescriptionText 	= nil;
   	self.WallPostMessageText 		= nil;
   	self.WallPostPictureLinkText 	= nil;
   	self.WallPostCaptionText 		= nil;

    self.WallPostName 				= "Spell Them Out!";
    self.WallPostDescription 		= "Spell words bla bla bla";
    self.WallPostMessage 			= "I just scored 24 points in the game.";
    self.WallPostPictureLink 		= "http://www.gamesbycandlelight.com";
    self.WallPostCaption 			= "Spell Them Out by Games By Candlelight";

--   	self.WallPostName = "Name section of wall post";
--   	self.WallPostPictureLink = "http://www.google.com";
--   	self.WallPostCaption = "Link caption";
--   	self.WallPostDescription = "Hello, this is the wall post message.";
--   	self.WallPostPicture = "http://50.16.125.130:400/Images/post1.png";
   	
   	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuFacebookWallPost:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	print("MenuFacebookWallPost:Enter()");

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

    local backButton;
    local submitButton;


    local function onBackButtonClicked()
		ChangeState(BaseState.State_Main);
    end

    local function onSubmitWallPostButtonClicked()
    		self:SubmitWallPost();
    end


    local topY = display.contentHeight * 0.1;

   	topY = topY + 100;

   	local title = display.newText(displayGroup, "Facebook Wall Post", 0, 0, native.systemFontBold, 42);
   	title.x = display.contentCenterX;
   	title.y = topY;

   	backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
   	backButton:SetPos(80, 30);

   	topY = topY + 100;

   	self.WallPostNameText = display.newText(displayGroup, "", 0, 0, native.systemFontBold, 24);
   	self.WallPostNameText.x = display.contentCenterX;
   	self.WallPostNameText.y = topY;
   	topY = topY + 50;

   	self.WallPostDescriptionText = display.newText(displayGroup, "", 0, 0, native.systemFontBold, 24);
   	self.WallPostDescriptionText.x = display.contentCenterX;
   	self.WallPostDescriptionText.y = topY;
   	topY = topY + 50;
   	
   	self.WallPostMessageText = display.newText(displayGroup, "", 0, 0, native.systemFontBold, 24);
   	self.WallPostMessageText.x = display.contentCenterX;
   	self.WallPostMessageText.y = topY;
   	topY = topY + 50;
   	
   	self.WallPostPictureLinkText = display.newText(displayGroup, "", 0, 0, native.systemFontBold, 24);
   	self.WallPostPictureLinkText.x = display.contentCenterX;
   	self.WallPostPictureLinkText.y = topY;
   	topY = topY + 50;
   	
   	self.WallPostCaptionText = display.newText(displayGroup, "", 0, 0, native.systemFontBold, 24);
   	self.WallPostCaptionText.x = display.contentCenterX;
   	self.WallPostCaptionText.y = topY;
   	topY = topY + 50;
   	
   	
	local buttonY = topY + 80;

   	submitWallPostButton = TextButton:New(displayGroup, "Submit", onSubmitWallPostButtonClicked, 20);
   	submitWallPostButton:SetPos(display.contentCenterX, buttonY);
   	buttonY = buttonY + 80;


	unrequire("ImageButton");
   	unrequire("TextButton");

--   	self.WallPostName = "Developing a Facebook Connect app using the Corona SDK!";
--   	self.WallPostPictureLink = "http://www.google.com";
--   	self.WallPostCaption = "Link caption";
--   	self.WallPostDescription = "Hello, this is the wall post message.";
--   	self.WallPostPicture = "http://developer.anscamobile.com/demo/Corona90x90.png";
   	
   	self:SynchWallPostComponents();
end

function MenuFacebookWallPost:SynchWallPostComponents()
	self.WallPostNameText.text = "Name = " .. self.WallPostName;
	self.WallPostDescriptionText.text = "Description = " .. self.WallPostDescription;
	self.WallPostMessageText.text = "Message = " .. self.WallPostMessage;
	self.WallPostPictureLinkText.text = "Link = " .. self.WallPostPictureLink;
   	self.WallPostCaptionText.text = "Caption = " .. self.WallPostCaption;
end

function MenuFacebookWallPost:Update(elapsedTime)
end

function MenuFacebookWallPost:Draw()
end

function MenuFacebookWallPost:Exit()
	super.Exit(self);
end

function MenuFacebookWallPost:HandleKeyEvent(event)
	return false;
end





------------------------------------------------
-- Events.
------------------------------------------------
function MenuFacebookWallPost:SubmitWallPost()
	local function onSendPost(callback)
		print("onSendPost(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			ChangeState(BaseState.State_Main);
		else
			showAlert(callback.Status, callback.Description);
		end
	end


	-- Send a wall post to Facebook.
	g_Together.Social.Facebook:SendPost(self.WallPostName,
    									self.WallPostDescription,
    									self.WallPostMessage,
    									self.WallPostPictureLink,
    									self.WallPostCaption, 
    									onSendWallPost);
end


function MenuFacebookWallPost:SubmitWallPost2()
	print("MenuFacebookWallPost:SubmitWallPost()");

	local function facebookListener(event)
		print("facebooklistener()");
		if (event.type ~= nil) then
			print("   event.type = " .. event.type);
		end
		if (event.phase ~= nil) then
			print("   event.phase = " .. event.phase);
		end
--		print("facebooklistener(type=" .. event.type .. ", phase=" .. event.phase .. ")");
    	if (event.type == "session") then
        	if (event.phase == "login") then
            	postMsg = {
--[[
                	message = "I just scored "..tostring(PLAYERDATA.SCORE).. 
                    	" in Spell Them Out!",
                	link = "http://www.gamesbycandlelight.com",
                	name = "Spell Them Out!",
                	caption = "Spell Them Out by Games By Candlelight",
                	description = "Spell words bla bla bla"
--]]

	   				name = self.WallPostName,
    				description = self.WallPostDescription,
    				message = self.WallPostMessage,
    				link = self.WallPostLink,
    				caption = self.WallPostCaption
              	}
              	
              	print("Sending wall post to facebook.");
            	facebook.request("me/feed", "POST", postMsg)
        	else
            	showAlert("Login Error", "Error logging into Facebook");
			end
		return
    	end
          
    	-- this handles the message received after a POST command
    	if (event.type == "request") then    
        	if (event.isError) then
            	showAlert("Message Not Posted", "Sorry, there was a problem posting to Facebook");      
        	else
            	showAlert("Message Posted", "High score posted to Facebook");
            end
        end
    end

--[[
	showAlert("Info", "Should submit the wall post");
	
    local attachment =
    {
    		name = "Developing a Facebook Connect app using the Corona SDK!",
        	link = "http://www.google.com",
        	caption = "Link caption",
        	description = "Hello, this is the wall post message.",
        	picture = "http://developer.anscamobile.com/demo/Corona90x90.png",
        actions = json.encode( { { name = "Learn More", link = "http://anscamobile.com" } } )
    }
                
    facebook.request( "me/feed", "POST", attachment )
--]]
--    showAlert("Info", "Should submit wall post to facebook.");

	facebook.login(self.FacebookAppID, facebookListener, {"publish_stream"})
end


return MenuFacebookWallPost;


