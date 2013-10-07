local together = require("plugin.together");
local json = require "json"

-- corona includes
local storyboard = require( "storyboard" )


local AND = "android";
local IOS = "ios";
local WIN = "windows";

platform = IOS;
g_Together = nil;

BG_COLOR = {r=0, b=0, g=0};

--CONSTANTS
STATUS_BAR_HEIGHT = display.statusBarHeight;
_W = display.actualContentWidth;
_H = display.actualContentHeight;

print(system.getInfo("platformName"));
if system.getInfo("platformName") == "Android" then
	platform = AND;
end

local function initialize()
	--Creates a Global Instance of the together table.
	g_Together = together:GetInstance();

	-- Initialize the global Together object.
	g_Together:Initialize("29A642F67FD84298866D82F29F150C17",			-- ClientPublicKey
						  "6F4CCCF2D4E8470AB5768A3CAA8239BE",			-- ClientPrivateKey
						  "D367096C5E8B404BB45D16DD50323E16",			-- GameKey
						  platform);										-- PlatformName
	--This will set what version of the API and what server you will be using for the remainder of the program					  
	g_Together:SetServerAddress("http://api.v1.playstogether.com");		-- (Version 2)
	--do not print logs from the together plugin.
	g_TogetherPrintEnabled = false;
end

local function login()
	--Callback function that will be called when
	--the login either succeeds or fails.
	local function onLoginUser(callback)
		print("onLoginUser(" .. callback.Status .. ", " .. callback.Description .. ")");
		--If Succeeded go ahead and move to the main scene of the game
		if (callback.Success) then
			storyboard.gotoScene("MainMenuScene");
		else
			--Put any alerts or other messages you would want to show the user here
			print("Error: " .. callback.Description);
		end
	end

	-- Log in the User.
	g_Together:LoginUser(onLoginUser);

end

local function main()
	initialize();
	login();
end

--Helper function we use to dump the contents of a table
--to the logs
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


main();