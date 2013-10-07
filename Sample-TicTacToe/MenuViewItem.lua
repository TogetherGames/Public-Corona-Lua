--module(..., package.seeall)

local BaseState = require("BaseState");
local together = require("plugin.together");

local MenuViewItem = {};
local super = BaseState	--Inherit from BaseState
setmetatable(MenuViewItem, { __index = super } );
local mt = { __index = MenuViewItem };

-----------------
-- Constructor --
-----------------

function MenuViewItem:New()
	local self = BaseState:New();
	setmetatable(self, mt);

   	self.type = BaseState.State_Item;

   	self.DisableInput = false;
   	self.Item = nil;

   	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuViewItem:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	-- Cache pointer to the selected Item.
	self.Item = g_CurrentItem;

	print("MenuViewItem:Enter()");

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

   	local backButton = nil;
   	local createItemButton = nil;	
   	local awardItemButton = nil;
   	local purchaseItemButton = nil;
	local sellItemButton = nil;
	
    
    local function onBackButtonClicked()
   		ChangeState(BaseState.State_ViewAllItems);
    end

    local function onAwardItemButtonClicked()
    	self:AwardItem();
    end

    local function onCreateItemButtonClicked()
   		self:CreateItem();
    end

    local function onPurchaseItemButtonClicked()
   		self:PurchaseItem();
    end

    
    local topY = display.contentHeight * 0.1;

   	local title = display.newText(displayGroup, "Item", 0, 0, native.systemFontBold, 42);
   	title.x = display.contentCenterX;
   	title.y = topY;

   	backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
   	backButton:SetPos(80, 30);


   	local labelText = "";
	local itemIDLabel = nil;
	local itemItemTypeLabel = nil;
	local itemNameLabel = nil;
	local itemDescriptionLabel = nil;


	local labelX = display.contentCenterX;
	local labelY = 180;
	local labelYStep = 45;

	labelText = "ItemID = " .. self.Item.ItemID;
	itemIDLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	itemIDLabel.x = display.contentCenterX;
	itemIDLabel.y = labelY;
	labelY = labelY + labelYStep;

	labelText = "ItemType = " .. self.Item.ItemType;
	itemItemTypeLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	itemItemTypeLabel.x = display.contentCenterX;
	itemItemTypeLabel.y = labelY;
	labelY = labelY + labelYStep;

	labelText = "" .. "Name = " .. self.Item.Name;
	itemNameLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	itemNameLabel.x = display.contentCenterX;
	itemNameLabel.y = labelY;
	labelY = labelY + labelYStep;

	labelText = "" .. "Description = " .. self.Item.Description;
	itemDescriptionLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
	itemDescriptionLabel.x = display.contentCenterX;
	itemDescriptionLabel.y = labelY;
	labelY = labelY + labelYStep;



	
	local itemPropertyCount = self.Item.Properties:GetCount();
	local itemProperty = nil;
	local itemPropertyLabel = nil;
	
	for i=1, itemPropertyCount do
		itemProperty = self.Item.Properties:GetAt(i);

		labelText = itemProperty.Name .. " = " .. itemProperty.Value;

		itemPropertyLabel = display.newText(displayGroup, labelText, 0, 0, native.systemFontBold, 30);
		itemPropertyLabel.x = labelX;
		itemPropertyLabel.y = labelY;
		labelY = labelY + labelYStep;
	end



	labelX = display.contentCenterX;
	labelY = labelY + 60;

   	awardItemButton = TextButton:New(displayGroup, "Award Item", onAwardItemButtonClicked, 20);
   	awardItemButton:SetPos(display.contentCenterX, labelY);
   	labelY = labelY + 55;

   	createItemButton = TextButton:New(displayGroup, "Create Item", onCreateItemButtonClicked, 20);
   	createItemButton:SetPos(display.contentCenterX, labelY);
   	labelY = labelY + 55;

   	purchaseItemButton = TextButton:New(displayGroup, "Purchase Item", onPurchaseItemButtonClicked, 20);
   	purchaseItemButton:SetPos(display.contentCenterX, labelY);
   	labelY = labelY + 55;


   	unrequire("ImageButton");
   	unrequire("TextButton");
end

function MenuViewItem:Draw()
end

function MenuViewItem:Exit()
	super.Exit(self);
end

function MenuViewItem:HandleKeyEvent(event)
	return false;
end




------------------------------------------------
-- Events.
------------------------------------------------
function MenuViewItem:AwardItem()
	print("MenuViewItem:AwardItem()");
	if (self.DisableInput == true) then
		print("   Input disabled.");
		return;
	end
	
	local function onUserItemAwarded(callback)
		print("onUserItemAwarded(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self.DisableInput = false;
			ChangeState(BaseState.State_ViewAllItems);
		else
			self.DisableInput = false;
			showAlert("Un Oh", callback.Description);
		end
	end

	self.DisableInput = true;
	g_Together.TogetherUser.UserItemManager:Award(self.Item.ItemID, 0, self.Item.Properties, onUserItemAwarded);
end

function MenuViewItem:CreateItem()
	print("MenuViewItem:CreateItem()");
	if (self.DisableInput == true) then
		print("   Input disabled.");
		return;
	end
	
	local function onUserItemCreated(callback)
		print("onUserItemCreated(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self.DisableInput = false;
			ChangeState(BaseState.State_ViewAllItems);
		else
			self.DisableInput = false;
			showAlert("Un Oh", callback.Description);
		end
	end

	self.DisableInput = true;

	-- Create a UserItem.
	local userItemProperties = together.PropertyCollection:New();
	userItemProperties:Set("Property Name", "Property Value");
	
	g_Together.TogetherUser.UserItemManager:Create(self.Item.ItemID, 0, userItemProperties, onUserItemCreated);
end

function MenuViewItem:PurchaseItem()
	print("MenuViewItem:PurchaseItem()");
	if (self.DisableInput == true) then
		print("   Input disabled.");
		return;
	end
	
	local function onItemPurchased(callback)
		print("onItemPurchased(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self.DisableInput = false;
			ChangeState(BaseState.State_ViewAllItems);
		else
			self.DisableInput = false;
			showAlert("Un Oh", callback.Description);
		end
	end

	self.DisableInput = true;


	-- Purchase the Item.
	local costPropertyName = "";
	local coinCost = self.Item.Properties:Get("Coins");
	local cashCost = self.Item.Properties:Get("Cash");

	if (cashCost ~= nil) then
		costPropertyName = "Cash";
	else
		costPropertyName = "Coins";
	end

	
	local userItemProperties = together.PropertyCollection:New();
	userItemProperties.Name = "Hello";
--	userItemProperties:Set("SomeData", "Purchased");

	g_Together.TogetherUser.UserItemManager:Purchase(self.Item.ItemID, 			-- itemID
													 0,							-- roomID
													 userItemProperties, 		-- userItemProperties
													 false,						-- useGameUserProfileProperties
													 onItemPurchased);			-- callbackFunc


--[[
	g_Together.UserPurchaseManager:Create(0,					-- roomID
										  0,					-- achievementID
										  self.Item.ItemID,		-- itemID
										  "Item Purchased",		-- description
										  1,					-- count
										  nil,					-- userPurchaseProperties
										  onItemPurchased);		-- callbackFunc

	local function onGetAllUserPurchases(callback)
		print("onGetAllUserPurchases(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self.DisableInput = false;
			g_Together.UserPurchaseManager:Dump();
		else
			self.DisableInput = false;
			showAlert("Un Oh", callback.Description);
		end
	end

	g_Together.UserPurchaseManager:GetAll(onGetAllUserPurchases);		-- callbackFunc
--]]
end


return MenuViewItem;



