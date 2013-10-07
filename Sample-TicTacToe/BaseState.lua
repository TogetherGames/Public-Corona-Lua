--module(..., package.seeall)

local BaseState = {};
local mt = { __index = BaseState };

BaseState.State_Login						= 1;
BaseState.State_Main 						= 2;
BaseState.State_GameLobby 					= 3;
BaseState.State_RegisterUser 				= 4;
BaseState.State_RegisterCustomUser 			= 5;
BaseState.State_GameInstance 				= 6;
BaseState.State_LeaderboardLobby 			= 7;
BaseState.State_Leaderboard 				= 8;
BaseState.State_ViewAllAchievements			= 9;
BaseState.State_ViewAchievement				= 10;
BaseState.State_ViewAllUserAchievements		= 11;
BaseState.State_ViewUserAchievement			= 12;
BaseState.State_ViewAllItems 				= 13;
BaseState.State_ViewItem					= 14;
BaseState.State_ViewAllUserItems			= 15;
BaseState.State_ViewUserItem				= 16;
BaseState.State_ChatRoomLobby				= 17;
BaseState.State_ChatRoom					= 18;
BaseState.State_ChatCreateMessage			= 19;
BaseState.State_FacebookWallPost			= 20;
BaseState.State_AudioRecorder				= 21;
BaseState.State_FriendLobby					= 22;
BaseState.State_CreateUserMessage			= 23;
BaseState.State_UserMessageInbox			= 24;

local Block;

-----------------
-- Constructor --
-----------------

function BaseState:New()
	local baseState = {};
	setmetatable(baseState, mt);
	
	baseState.type = nil;
	baseState.displayGroup = display.newGroup();
	baseState.displayGroup:addEventListener("tap", Block);
	baseState.displayGroup:addEventListener("touch", Block);

    timer.performWithDelay(1, function() collectgarbage("collect") end);

	return baseState;
end

----------------------
-- Instance Methods --
----------------------

function BaseState:Enter()

end

function BaseState:Update(elapsedTime)

end

function BaseState:Draw()

end

function BaseState:Exit()
	self.displayGroup:removeEventListener("tap", Block);
	self.displayGroup:removeEventListener("touch", Block);
	self.displayGroup:removeSelf();
	self.displayGroup = nil;

    timer.performWithDelay(1, function() collectgarbage("collect") end);
end

function BaseState:SaveState(file)
	file:write(self.type .. ":" .. "0");
end

function BaseState:ResumeState(data)
end

function BaseState:HandleKeyEvent(event)
	return true;
end

Block = function(event)
	return true;
end

return BaseState;


