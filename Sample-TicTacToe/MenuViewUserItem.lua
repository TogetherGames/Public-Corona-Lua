--module(..., package.seeall)

local BaseState = require("BaseState");

local MenuViewUserItem = {};
local super = BaseState	--Inherit from BaseState
setmetatable(MenuViewUserItem, { __index = super } );
local mt = { __index = MenuViewUserItem };

-----------------
-- Constructor --
-----------------

function MenuViewUserItem:New()
	local self = BaseState:New();
	setmetatable(self, mt);

   	self.type = BaseState.State_Item;

   	self.DisableInput = false;
   	self.UserItem = nil;

   	self.ItemPropertyLabels = {};
   	
   	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuViewUserItem:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	-- Cache pointer to the selected UserItem.
	self.UserItem = g_CurrentUserItem;

	print("MenuViewUserItem:Enter()");

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

	local backButton = nil;
	local sellButton = nil;
	local deleteButton = nil;
	local modifyButton = nil;


    local function onBackButtonClicked()
   		ChangeState(BaseState.State_ViewAllUserItems);
    end

    local function onSellUserItemButtonClicked()
   		self:SellUserItem();
    end

    local function onDeleteUserItemButtonClicked()
   		self:DeleteUserItem();
    end

    local function onModifyUserItemButtonClicked()
   		self:ModifyUserItem();
    end


    local topY = display.contentHeight * 0.1;

   	local title = display.newText(displayGroup, "User Item", 0, 0, native.systemFontBold, 42);
   	title.x = display.contentCenterX;
   	title.y = topY;

   	backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
   	backButton:SetPos(80, 30);


   	local labelText = "";
	local userItemIDLabel = nil;
	local userItemNameLabel = nil;
	local userItemDescriptionLabel = nil;

	self.UserItemID				= 0;
	self.Name					= "";
	self.Description			= "";

	
	local labelX = display.contentCenterX;
	local labelY = 180;
	local labelYStep = 45;

	labelText = "UserItemID = " .. self.UserItem.UserItemID;
	userItemIDLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	userItemIDLabel.x = display.contentCenterX;
	userItemIDLabel.y = labelY;
	labelY = labelY + labelYStep;

	labelText = "" .. "Name = " .. self.UserItem.Item.Name;
	userItemNameLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	userItemNameLabel.x = display.contentCenterX;
	userItemNameLabel.y = labelY;
	labelY = labelY + labelYStep;

	labelText = "" .. "Description = " .. self.UserItem.Item.Description;
	userItemDescriptionLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	userItemDescriptionLabel.x = display.contentCenterX;
	userItemDescriptionLabel.y = labelY;
	labelY = labelY + labelYStep;


	self:RefreshPropertyLabels();


	labelY = 600;

	labelX = display.contentCenterX;
	labelY = labelY + 60;

   	sellButton = TextButton:New(displayGroup, "Sell", onSellUserItemButtonClicked, 20);
	sellButton:SetPos(display.contentCenterX, labelY);
   	labelY = labelY + 55;

   	deleteButton = TextButton:New(displayGroup, "Delete", onDeleteUserItemButtonClicked, 20);
   	deleteButton:SetPos(display.contentCenterX, labelY);
   	labelY = labelY + 55;

   	modifyButton = TextButton:New(displayGroup, "Modify", onModifyUserItemButtonClicked, 20);
   	modifyButton:SetPos(display.contentCenterX, labelY);
   	labelY = labelY + 55;
    

   	unrequire("ImageButton");
   	unrequire("TextButton");
end

function MenuViewUserItem:Draw()
end

function MenuViewUserItem:Exit()
	super.Exit(self);
end

function MenuViewUserItem:HandleKeyEvent(event)
	return false;
end



function MenuViewUserItem:RefreshPropertyLabels()
	self:DestroyPropertyLabels();
	self:CreatePropertyLabels();
end

function MenuViewUserItem:DestroyPropertyLabels()
	local labelCount = table.getn(self.ItemPropertyLabels);
	local theLabel;

    for i=1, labelCount do
    	theLabel = self.ItemPropertyLabels[i];
    	theLabel:CleanUp();
    	self.displayGroup:remove(theLabel.displayGroup);
    end

    self.ItemPropertyLabels = {};
end

function MenuViewUserItem:CreatePropertyLabels()
	local TextButton = require("TextButton");

	local itemPropertyCount = self.UserItem.Item.Properties:GetCount();
	local itemProperty = nil;
	local itemPropertyLabel = nil;
	local labelText = "";
	local labelX = display.contentCenterX;
	local labelY = 320;
	local labelYStep = 45;
	
	for i=1, itemPropertyCount do
		itemProperty = self.UserItem.Item.Properties:GetAt(i);

		labelText = itemProperty.Name .. " = " .. itemProperty.Value;

    	itemPropertyLabel = TextButton:New(self.displayGroup, labelText, nil, 24);
    	itemPropertyLabel:SetPos(labelX, labelY);
   		labelY = labelY + labelYStep;
    		
--		itemPropertyLabel = display.newText(self.displayGroup, labelText, 0, 0, native.systemFontBold, 30);
--		itemPropertyLabel.x = labelX;
--		itemPropertyLabel.y = labelY;
--		labelY = labelY + labelYStep;
		
		table.insert(self.ItemPropertyLabels, itemPropertyLabel);
	end

	labelY = labelY + 20;

	local userItemPropertyCount = self.UserItem.Properties:GetCount();
	local userItemProperty = nil;
	local userItemPropertyLabel = nil;
	
	for i=1, userItemPropertyCount do
		userItemProperty = self.UserItem.Properties:GetAt(i);

		labelText = userItemProperty.Name .. " = " .. userItemProperty.Value;

    	userItemPropertyLabel = TextButton:New(self.displayGroup, labelText, nil, 24);
    	userItemPropertyLabel:SetPos(labelX, labelY);
   		labelY = labelY + labelYStep;

		table.insert(self.ItemPropertyLabels, userItemPropertyLabel);
	end

   	unrequire("TextButton");
end


------------------------------------------------
-- Events.
------------------------------------------------
function MenuViewUserItem:ModifyUserItem()
	print("MenuViewUserItem:ModifyUserItem()");
	if (self.DisableInput == true) then
		print("   Input disabled.");
		return;
	end

	local function onUserItemModified(callback)
		print("onUserItemModified(" .. callback.Status .. ", " .. callback.Description .. ")");
		self.DisableInput = false;
		self:RefreshPropertyLabels();
	end


	local counterValue = self.UserItem.Properties:GetEx("Counter", "0");
	self.UserItem.Properties:Set("Counter", tostring(tonumber(counterValue) + 1));

	self.DisableInput = true;
	self.UserItem:Modify(onUserItemModified);
end

function MenuViewUserItem:SellUserItem()
	print("MenuViewUserItem:SellUserItem()");
	if (self.DisableInput == true) then
		print("   Input disabled.");
		return;
	end

	local function onUserItemSold(callback)
		print("onUserItemSold(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self.DisableInput = false;
			ChangeState(BaseState.State_ViewAllUserItems);
		else
			self.DisableInput = true;
			showAlert("Un Oh", callback.Description);
		end
	end

	self.DisableInput = true;


	-- Sell the Item.
	local costPropertyName = "";
	local coinCost = self.UserItem.Item.Properties:Get("Coins");
	local cashCost = self.UserItem.Item.Properties:Get("Cash");

	if (cashCost ~= nil) then
		costPropertyName = "Cash";
	else
		costPropertyName = "Coins";
	end

	g_Together.TogetherUser.UserItemManager:Sell(self.UserItem.UserItemID, 	-- userItemID
												 costPropertyName,			-- costPropertyName
												 false,						-- useGameUserProfileProperties
												 onUserItemSold);			-- callbackFunc
end

function MenuViewUserItem:DeleteUserItem()
	print("MenuViewUserItem:DeleteUserItem()");
	if (self.DisableInput == true) then
		print("   Input disabled.");
		return;
	end
			
	local function onUserItemDeleted(callback)
		print("onUserItemDeleted(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self.DisableInput = false;
			ChangeState(BaseState.State_ViewAllUserItems);
		else
			self.DisableInput = true;
			showAlert("Un Oh", callback.Description);
		end
	end

	self.DisableInput = true;
	g_Together.TogetherUser.UserItemManager:Delete(self.UserItem.UserItemID,		-- userItemID
	 											   onUserItemDeleted);				-- callbackFunc
end


return MenuViewUserItem;



