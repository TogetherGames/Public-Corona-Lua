--module(..., package.seeall)

local BaseState = require("BaseState");

local MenuViewAllItems = {};
local super = BaseState	--Inherit from BaseState
setmetatable(MenuViewAllItems, { __index = super } );
local mt = { __index = MenuViewAllItems };

-----------------
-- Constructor --
-----------------

function MenuViewAllItems:New()
	local self = BaseState:New();
	setmetatable(self, mt);

   	self.type = BaseState.State_ItemLobby;

   	self.DisableInput = false;
   	self.ItemButtons = {};

   	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuViewAllItems:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	print("MenuViewAllItems:Enter()");

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

    local backButton;

    local function onBackButtonClicked()
   		ChangeState(BaseState.State_Main);
   	end

    
   	local topY = display.contentHeight * 0.1;


   	local title = display.newText(displayGroup, "Items", 0, 0, native.systemFontBold, 42);
   	title.x = display.contentCenterX;
   	title.y = topY;

   	backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
   	backButton:SetPos(80, 30);


   	unrequire("ImageButton");
    unrequire("TextButton");


	self:GetAllItems();
end

function MenuViewAllItems:Draw()
end

function MenuViewAllItems:Exit()
	super.Exit(self);
end

function MenuViewAllItems:HandleKeyEvent(event)
	return false;
end



function MenuViewAllItems:GetAllItems()

   	local function onGotAllItems(callback)
		print("onGotAllItems(" .. callback.Status .. ", " .. callback.Description .. ")")
		self.DisableInput = false;
		if (callback.Success) then
			self:AllItemsRetrieved()
		end
	end
	
	self.DisableInput = true;
    g_Together.ItemManager:GetAll(onGotAllItems)
end




------------------------------------------------
-- Events.
------------------------------------------------
function MenuViewAllItems:AllItemsRetrieved()
	g_Together.ItemManager:Dump();

	self:DestroyItemButtons();
	self:CreateItemButtons();
	
	self.DisableInput = false;
end

function MenuViewAllItems:BuildItemButtonLabel(item)
	local theButtonLabel = "ID=" .. item.ItemID ..
		", Name=" .. item.Name;
	
	return theButtonLabel;
end

function MenuViewAllItems:ItemButtonClicked(index)
	print("MenuViewAllItems:ItemButtonClicked(" .. index .. ")");
	if (self.DisableInput == true) then
		print("   Input disabled.");
		return;
	end

	g_CurrentItem = g_Together.ItemManager:Get(index);
	
	ChangeState(BaseState.State_ViewItem);
end


function MenuViewAllItems:CreateItemButtons()
	local TextButton = require("TextButton");

    local function onItemButtonClicked(event, button)
   		self:ItemButtonClicked(button.buttonIndex);
   	end


   	local itemCount = g_Together.ItemManager:GetCount();
	local item;
   	local buttonY = 200;
   	local theButtonLabel = "";
   	local theButton = nil;

   	if (itemCount > 9) then
   		itemCount = 9;
   	end

   	self.ItemButtons = {};

   	for i=1, itemCount do
   		item = g_Together.ItemManager:Get(i);
    	
   		theButtonLabel = self:BuildItemButtonLabel(item);
    
   		theButton = TextButton:New(self.displayGroup, theButtonLabel, onItemButtonClicked, 20);
   		theButton.buttonIndex = i;
   		theButton:SetPos(display.contentCenterX, buttonY);
   		buttonY = buttonY + 80;

		table.insert(self.ItemButtons, theButton);
   	end

   	unrequire("TextButton");
end

function MenuViewAllItems:DestroyItemButtons()
	local buttonCount = table.getn(self.ItemButtons);
	local itemButton;

    for i=1, buttonCount do
   		itemButton = self.ItemButtons[i];
   		itemButton:CleanUp();
   		self.displayGroup:remove(itemButton.displayGroup);
   	end

   	self.ItemButtons = {};
end


return MenuViewAllItems;



