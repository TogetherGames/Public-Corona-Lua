local launchArgs = ...

display.setStatusBar(display.HiddenStatusBar);

local BaseState = require("BaseState");
local together = require("plugin.together");
local json = require("json");

local AND = "android";
local IOS = "ios";
local WIN = "windows";

platform = IOS;

local deviceIsIPad = false;
if system.getInfo("model") == "iPad" then
    deviceIsIPad = true;
end
_G.deviceIsIPad = deviceIsIPad;

currentState = nil;

local previousStateType = 0;
local currentStateType = 0;
local refreshUserStats = false;

local lastTime = 0;
local stateStack = {};
local poppedState;
local messages = {};
local backMessageBuffer = {};
local resumingStates = false;
local resumeScreen;

local MaxElapsedTime = 0.04;        	--This number represents 20 FPS. If we dip below that, don't freak out.
local MaxTimeToResume = 60 * 60 * 8;	--How long we should wait before restarting at the splash screen

results = {};

local floor = math.floor;
local ceil = math.ceil;
local abs = math.abs;


table.print = function(t, n, cache)
    n = n or 0;
    cache = cache or {};
    if(nil ~= t)then
        local prefix = "";
        if(n > 0)then
            for i=1, n, 1 do
                prefix = prefix .. '  ';
            end
        end
        for k,v in pairs(t) do
            if(type(v) == 'table' and not cache[tostring(v)])then
                cache[tostring(v)] = true;
                print(prefix .. tostring(k) .. ':');
                table.print(v, n+1, cache);
            else
                print(prefix .. tostring(k) .. ': ' .. tostring(v) .. '(' .. type(v) .. ')');
            end
        end
    end
end


function unrequire(m)
    package.loaded[m] = nil;
    rawset(_G, m, nil);

    -- Search for the shared library handle in the registry and erase it
    local registry = debug.getregistry();
    local nMatches, mKey, mt = 0, nil, registry['_LOADLIB'];

    for key, ud in pairs(registry) do
        if type(key) == 'string' and type(ud) == 'userdata' and getmetatable(ud) == mt and string.find(key, "LOADLIB: .*" .. m) then
            nMatches = nMatches + 1;
            if nMatches > 1 then
                return false, "More than one possible key for module '" .. m .. "'. Can't decide which one to erase.";
            end
            mKey = key;
        end
    end

    if mKey then
        registry[mKey] = nil;
    end

    return true;
end

------------------
-- State System --
------------------

local function RemovePoppedState()
	if poppedState ~= nil then
		poppedState:Exit();
		poppedState = nil;
	end
end

function PushState(stateType, ...)
    if #stateStack > 0 and stateType == stateStack[#stateStack].type then
        return;
    end

    local loadStateFirst = false;
    if stateType == BaseState.State_Loading then
        loadStateFirst = true;
        stateType = arg[1];
        for i=2, #arg do
            arg[i-1] = arg[i];
        end
    end

	local newState;


	if (stateType == BaseState.State_Login) then
		local MenuLogin = require("MenuLogin");
		newState = MenuLogin:New();
		unrequire("MenuLogin");

	elseif (stateType == BaseState.State_Main) then
		local MenuMain = require("MenuMain");
		newState = MenuMain:New();
		unrequire("MenuMain");

	elseif (stateType == BaseState.State_GameLobby) then
		local MenuGameLobby = require("MenuGameLobby");
		newState = MenuGameLobby:New();
		unrequire("MenuGameLobby");

	elseif (stateType == BaseState.State_GameInstance) then
		local MenuGameInstance = require("MenuGameInstance");
		newState = MenuGameInstance:New();
		unrequire("MenuGameInstance");

	elseif (stateType == BaseState.State_RegisterUser) then
		local MenuRegisterUser = require("MenuRegisterUser");
		newState = MenuRegisterUser:New();
		unrequire("MenuRegisterUser");

	elseif (stateType == BaseState.State_RegisterCustomUser) then
		local MenuRegisterCustomUser = require("MenuRegisterCustomUser");
		newState = MenuRegisterCustomUser:New();
		unrequire("MenuRegisterCustomUser");

	elseif (stateType == BaseState.State_LeaderboardLobby) then
		local MenuLeaderboardLobby = require("MenuLeaderboardLobby");
		newState = MenuLeaderboardLobby:New();
		unrequire("MenuLeaderboardLobby");

	elseif (stateType == BaseState.State_Leaderboard) then
		local MenuLeaderboard = require("MenuLeaderboard");
		newState = MenuLeaderboard:New();
		unrequire("MenuLeaderboard");

	elseif (stateType == BaseState.State_ViewAllAchievements) then
		local MenuViewAllAchievements = require("MenuViewAllAchievements");
		newState = MenuViewAllAchievements:New();
		unrequire("MenuViewAllAchievements");

	elseif (stateType == BaseState.State_ViewAchievement) then
		local MenuViewAchievement = require("MenuViewAchievement");
		newState = MenuViewAchievement:New();
		unrequire("MenuViewAchievement");

	elseif (stateType == BaseState.State_ViewAllUserAchievements) then
		local MenuViewAllUserAchievements = require("MenuViewAllUserAchievements");
		newState = MenuViewAllUserAchievements:New();
		unrequire("MenuViewAllUserAchievements");

	elseif (stateType == BaseState.State_ViewUserAchievement) then
		local MenuViewUserAchievement = require("MenuViewUserAchievement");
		newState = MenuViewUserAchievement:New();
		unrequire("MenuViewUserAchievement");

	elseif (stateType == BaseState.State_ViewAllItems) then
		local MenuViewAllItems = require("MenuViewAllItems");
		newState = MenuViewAllItems:New();
		unrequire("MenuViewAllItems");

	elseif (stateType == BaseState.State_ViewItem) then
		local MenuViewItem = require("MenuViewItem");
		newState = MenuViewItem:New();
		unrequire("MenuViewItem");

	elseif (stateType == BaseState.State_ViewAllUserItems) then
		local MenuViewAllUserItems = require("MenuViewAllUserItems");
		newState = MenuViewAllUserItems:New();
		unrequire("MenuViewAllUserItems");

	elseif (stateType == BaseState.State_ViewUserItem) then
		local MenuViewUserItem = require("MenuViewUserItem");
		newState = MenuViewUserItem:New();
		unrequire("MenuViewUserItem");

	elseif (stateType == BaseState.State_ChatRoomLobby) then
		local MenuChatRoomLobby = require("MenuChatRoomLobby");
		newState = MenuChatRoomLobby:New();
		unrequire("MenuChatRoomLobby");

	elseif (stateType == BaseState.State_ChatRoom) then
		local MenuChatRoom = require("MenuChatRoom");
		newState = MenuChatRoom:New();
		unrequire("MenuChatRoom");

	elseif (stateType == BaseState.State_ChatCreateMessage) then
		local MenuChatCreateMessage = require("MenuChatCreateMessage");
		newState = MenuChatCreateMessage:New();
		unrequire("MenuChatCreateMessage");

	elseif (stateType == BaseState.State_FacebookWallPost) then
		local MenuFacebookWallPost = require("MenuFacebookWallPost");
		newState = MenuFacebookWallPost:New();
		unrequire("MenuFacebookWallPost");

	elseif (stateType == BaseState.State_AudioRecorder) then
		local MenuAudioRecorder = require("MenuAudioRecorder");
		newState = MenuAudioRecorder:New();
		unrequire("MenuAudioRecorder");

	elseif (stateType == BaseState.State_FriendLobby) then
		local MenuFriendLobby = require("MenuFriendLobby");
		newState = MenuFriendLobby:New();
		unrequire("MenuFriendLobby");
		
	elseif (stateType == BaseState.State_CreateUserMessage) then
		local MenuCreateUserMessage = require("MenuCreateUserMessage");
		newState = MenuCreateUserMessage:New();
		unrequire("MenuCreateUserMessage");
		
	elseif (stateType == BaseState.State_UserMessageInbox) then
		local MenuUserMessageInbox = require("MenuUserMessageInbox");
		newState = MenuUserMessageInbox:New();
		unrequire("MenuUserMessageInbox");
	end

	currentState = newState;

    if loadStateFirst == true and newState.PreLoad ~= nil then
		local LoadingState = require("LoadingState");
        stateStack[#stateStack + 1] = newState;
        newState = LoadingState:New(newState);
		unrequire("LoadingState");
    end
		
	stateStack[#stateStack + 1] = newState;
	stateStack[#stateStack]:Enter();
    if loadStateFirst == false and stateType ~= BaseState.State_SplashScreen then
	    stateStack[#stateStack].displayGroup.alpha = 0;
	    transition.to(stateStack[#stateStack].displayGroup, { time=250, alpha=1 });
    end
    
    previousStateType = currentStateType;
    currentStateType = stateType;
end

function PopState()
	--Call this here in order to be safe. Multiple rapid state changes could
	--	leak memory otherwise
	RemovePoppedState();
	poppedState = table.remove(stateStack, #stateStack);
	transition.to(poppedState.displayGroup, { time=250, alpha=0, onComplete=RemovePoppedState });
	
	--This throws an invisible blocking rectangle on the popped state to prevent double tapping buttons
	local function Block()
		return true;
	end

	local blockRect = display.newRect(poppedState.displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	blockRect:setFillColor(255, 255, 255, 1);
	blockRect:addEventListener("tap", Block);
	blockRect:addEventListener("touch", Block);
end

function ClearStates()
	while #stateStack > 0 do
		PopState();
	end
end

function ChangeState(state, ...)
	ClearStates();
	PushState(state, unpack(arg));
end

----------------------
-- Messaging System --
----------------------

--Messages have the following structure:
--	msg.id ... String identifier describing the message
--	msg.args ... Table of arguments needed for the message

local function ProcessMessage(msg)
	local id = msg.id;
end

local function ProcessAllMessages()
	for i=1, #messages do
		ProcessMessage(messages[i]);
        messages[i] = nil;
    end

    local swap = messages;
    messages = backMessageBuffer;
    backMessageBuffer = swap;
end

function SendMessage(msg)
	ProcessMessage(msg);
end

--A back buffer for messages is used to prevent adding to the message queue at
--  the same time message processing is happening.
function PostMessage(msg)
    backMessageBuffer[#backMessageBuffer + 1] = msg;
end

---------------
-- Game Loop --
---------------

local getTimer = system.getTimer;
local function GameLoop()
	local elapsedTime = (getTimer() - lastTime) / 1000;
	lastTime = getTimer();

    --If we exceed the max elapsed time, we are going slower than 20 FPS. In this case,
    --  slow the game down instead of trying to catch up.
    if elapsedTime > MaxElapsedTime then
        elapsedTime = MaxElapsedTime;
    end

	if #stateStack > 0 then
		stateStack[#stateStack]:Update(elapsedTime);
			
		for i=1, #stateStack do
			stateStack[i]:Draw();
		end
    end

	--If we run out of states, assume that we meant to go to the main menu
--	if #stateStack == 0 then
--		PushState(BaseState.State_CampaignOffice);
--	end
	
	ProcessAllMessages()
end


function showAlert(title, message)
	native.showAlert(title, message, { "OK" } );
end

function showAlertEx(title, message, buttons, callbackFunc)
	local function onComplete(event)
        if "clicked" == event.action then
        		callbackFunc(event.index);
        end
    end
	local alert = native.showAlert(title, message, buttons, onComplete);
end


------------------------------
-- Android Soft Key Handler --
------------------------------

local function HandleKeyEvent(event)
    if event.keyName == "volumeUp" or event.keyName == "volumeDown" then
        return false;
	end

	if #stateStack == 0 then
		return false;
	else
		return stateStack[#stateStack]:HandleKeyEvent(event);
	end
end

----------
-- Init --
----------

lastTime = getTimer();
Runtime:addEventListener("enterFrame", GameLoop);
Runtime:addEventListener("key", HandleKeyEvent);


function table.reverse(tab)
    local size = #tab;
    local newTable = {};
    for i,v in ipairs(tab) do
        newTable[size-i] = v;
    end
    return newTable;
end



if launchArgs and launchArgs.notification then
    native.showAlert( "launchArgs", json.encode( launchArgs.notification ), { "OK" } )
end
 
-- notification listener
local function onNotification( event )
	print("**** onNotification()");
    if event.type == "remoteRegistration" then
    	print("event.type = remoteRegistration");
    	g_Together:SetApnsDeviceToken(event.token);
 --       native.showAlert( "remoteRegistration", event.token, { "OK" } )
 
    elseif event.type == "remote" then
    	print("event.type = remote");
        native.showAlert( "remote", json.encode( event ), { "OK" } )
    end
end
 
Runtime:addEventListener( "notification", onNotification )




g_PreviousMenu = 0;

g_StateParameters = nil;

g_Together = together:GetInstance();

-- Initialize the global Together object.

g_Together:Initialize("29A642F67FD84298866D82F29F150C17",			-- ClientPublicKey
    				  "6F4CCCF2D4E8470AB5768A3CAA8239BE",			-- ClientPrivateKey
    				  "D59BF337D3C64A9CBDFBB5C689DD2FE0",			-- GameKey
    				  "IOS");										-- PlatformName

g_Together:SetFacebookAppID("380670285349853", {"publish_stream"});


--g_TogetherPrintEnabled = true;


-- Load up the initial State.
PushState(BaseState.State_Login);






