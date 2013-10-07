--module(..., package.seeall)

local BaseState = require("BaseState");

local MenuViewAllUserItems = {};
local super = BaseState	--Inherit from BaseState
setmetatable(MenuViewAllUserItems, { __index = super } );
local mt = { __index = MenuViewAllUserItems };

-----------------
-- Constructor --
-----------------

function MenuViewAllUserItems:New()
	local self = BaseState:New();
	setmetatable(self, mt);

   	self.type = BaseState.State_ViewAllUserItems;

   	self.DisableInput = false;
   	self.UserItemButtons = {};

   	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuViewAllUserItems:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	print("MenuViewAllUserItems:Enter()");

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

    local backButton;

    local function onBackButtonClicked()
   		ChangeState(BaseState.State_Main);
    end

    
    local topY = display.contentHeight * 0.1;

   	local title = display.newText(displayGroup, "User Items", 0, 0, native.systemFontBold, 42);
   	title.x = display.contentCenterX;
   	title.y = topY;

   	backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
   	backButton:SetPos(80, 30);

  
    unrequire("ImageButton");
    unrequire("TextButton");


    self:GetAllUserItems();
end

function MenuViewAllUserItems:Draw()
end

function MenuViewAllUserItems:Exit()
	super.Exit(self);
end

function MenuViewAllUserItems:HandleKeyEvent(event)
	return false;
end



function MenuViewAllUserItems:GetAllUserItems()
   	local function onGotAllUserItems(callback)
		print("onGotAllUserItems(" .. callback.Status .. ", " .. callback.Description .. ")");
		self.DisableInput = false;
		if (callback.Success) then
			self:AllUserItemsRetrieved();
		end
	end
	
	self.DisableInput = true;
    g_Together.TogetherUser.UserItemManager:GetAll(onGotAllUserItems);
end




------------------------------------------------
-- Events.
------------------------------------------------
function MenuViewAllUserItems:AllUserItemsRetrieved()
	g_Together.TogetherUser.UserItemManager:Dump();

	self:DestroyUserItemButtons();
	self:CreateUserItemButtons();
	
	self.DisableInput = false;
end

function MenuViewAllUserItems:BuildUserItemButtonLabel(userItem)
	local theButtonLabel = "ID=" .. userItem.UserItemID ..
		", Name=" .. userItem.Item.Name;

	return theButtonLabel;
end

function MenuViewAllUserItems:UserItemButtonClicked(index)
	print("MenuViewAllUserItems:UserItemButtonClicked(" .. index .. ")");
	if (self.DisableInput == true) then
		print("   Input disabled.");
		return;
	end

	g_CurrentUserItem = g_Together.TogetherUser.UserItemManager:Get(index);

	ChangeState(BaseState.State_ViewUserItem);
end


function MenuViewAllUserItems:CreateUserItemButtons()
	local TextButton = require("TextButton");

    local function onUserItemButtonClicked(event, button)
   		self:UserItemButtonClicked(button.buttonIndex);
   	end


   	local userItemCount = g_Together.TogetherUser.UserItemManager:GetCount();
	local userItem;
   	local buttonY = 200;
   	local theButtonLabel = "";
   	local theButton = nil;

   	if (userItemCount > 9) then
   		userItemCount = 9;
   	end

   	self.UserItemButtons = {};

   	for i=1, userItemCount do
   		userItem = g_Together.TogetherUser.UserItemManager:Get(i);
    	
   		theButtonLabel = self:BuildUserItemButtonLabel(userItem);
    
   		theButton = TextButton:New(self.displayGroup, theButtonLabel, onUserItemButtonClicked, 20);
   		theButton.buttonIndex = i;
   		theButton:SetPos(display.contentCenterX, buttonY);
   		buttonY = buttonY + 80;

		table.insert(self.UserItemButtons, theButton);
   	end

   	unrequire("TextButton");
end

function MenuViewAllUserItems:DestroyUserItemButtons()
	local buttonCount = table.getn(self.UserItemButtons);
	local userItemButton;

    for i=1, buttonCount do
   		userItemButton = self.UserItemButtons[i];
   		userItemButton:CleanUp();
   		self.displayGroup:remove(userItemButton.displayGroup);
   	end

   	self.UserItemButtons = {};
end


return MenuViewAllUserItems;



