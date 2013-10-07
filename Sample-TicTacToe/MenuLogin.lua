--module(..., package.seeall)
local BaseState = require("BaseState")
local together = require("plugin.together");

local MenuLogin = {}
local super = BaseState	--Inherit from BaseState
setmetatable(MenuLogin, { __index = super } )
local mt = { __index = MenuLogin }

-----------------
-- Constructor --
-----------------

function MenuLogin:New()
	local self = BaseState:New()
	setmetatable(self, mt)
    self.type = BaseState.State_Login

    self.ServerIPLabel = nil

	return self
end

----------------------
-- Instance Methods --
----------------------

function MenuLogin:Enter()
	local TextButton = require("TextButton")
	local ImageButton = require("ImageButton")

	local displayGroup = self.displayGroup

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight)
	background:setFillColor(70, 50, 150)

    local loginButton


    local function onLoginButtonClicked()
    	self:OnLoginButtonClicked()
    end


   
    local topY = display.contentHeight * 0.1
    
    local appTitle = display.newText(displayGroup, "TogetherTest", 0, 0, native.systemFontBold, 50)
    appTitle.x = display.contentCenterX
    appTitle.y = topY
    topY = topY + 130


    self.ServerIPLabel = display.newText(displayGroup, "Server = " .. g_Together.TogetherServerIP, 0, 0, native.systemFontBold, 32)
    self.ServerIPLabel.x = display.contentCenterX
    self.ServerIPLabel.y = topY
    topY = topY + 100        
        
	
    local title = display.newText(displayGroup, "Login", 0, 0, native.systemFontBold, 42)
    title.x = display.contentCenterX
    title.y = topY

	topY = topY + 200

    loginButton = TextButton:New(displayGroup, "Login", onLoginButtonClicked, 20)
    loginButton:SetPos(display.contentCenterX, topY)

    unrequire("ImageButton")
    unrequire("TextButton")
end

function MenuLogin:Update(elapsedTime)

end

function MenuLogin:Draw()

end

function MenuLogin:Exit()
	super.Exit(self)
end

function MenuLogin:HandleKeyEvent(event)
	return false
end



------------------------------------------------
-- Events.
------------------------------------------------
function MenuLogin:OnLocalServerButtonClicked()
	print("OnLocalServerButtonClicked()")
	
	together.TogetherServerIP = "http://10.0.1.12:225"
	
	self.ServerIPLabel.text = "Server = " .. together.TogetherServerIP
end

function MenuLogin:OnAmazonEC2ServerButtonClicked()
	print("OnAmazonEC2ServerButtonClicked()")

	together.TogetherServerIP = "http://50.16.125.130"

	self.ServerIPLabel.text = "Server = " .. together.TogetherServerIP
end

function MenuLogin:OnLoginButtonClicked()
	
	local function onRegisterPushEnabledDevice(callback)
		print("onRegisterPushEnabledDevice(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			ChangeState(BaseState.State_Main);
		else
			showAlert("Uh Oh", callback.Description);
		end
	end

	local function onLoginUser(callback)
		print("onLoginUser(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			if (	( g_Together.ApnsDeviceToken ~= "" and g_Together.ApnsDeviceToken ~= nil ) or
					( g_Together.GCMDeviceToken ~= "" and  g_Together.GCMDeviceToken ~= nil ) ) then
				g_Together:RegisterPushEnabledDevice(onRegisterPushEnabledDevice);
			else
				ChangeState(BaseState.State_Main);
			end
		else
			showAlert("Uh Oh", callback.Description);
		end
	end

	-- Log in the User.
	g_Together:LoginUser(onLoginUser);
end

    
return MenuLogin




