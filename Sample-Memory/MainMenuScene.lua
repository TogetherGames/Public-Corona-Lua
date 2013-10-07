local storyboard = require( "storyboard" )
local widget = require( "widget" )
local scene = storyboard.newScene();
local json = require("json");

--Together Includes
local together = require("plugin.together");

-- Memory includes
require("Game");

----------------------------------------------------------------------------------
-- 
--      NOTE:
--      
-- This template for this file is pulled straight from the Corona Docs.
-- http://docs.coronalabs.com/api/library/storyboard/index.html#scenetemplate.lua
-- CreateScene will be called when a scene is initialy created
-- EnterScene is entered anytime that the scene is navigated to and the
-- scene has already been created.
--
--
---------------------------------------------------------------------------------


local gameButtonList = {};
local getGamesTimer = nil;
local gamesScrollView = nil;

local buttonProperties = 
	{
		height = 75;
		width = 250;
		textSize = 15;
		bottomPadding = 10;
	}

--BEGIN MemoryGame Functions

-- The Callback function after receiving games from the server
local function onGotAllGames(event)
	-- Get the response and check that the call has succeeded
	local response = event.ResponseObj;
	if(event.Success ~= true) then
		print("Error: " .. response.description);
		--add any code to deal with the error here.
		return;		--early return
	end
	-- The game instances from the response
	-- These are raw tables (created from the json) and not tables with the
	-- TogetherGameInstance meta table data.
	local gameInstances = response.GameInstances;
	while(gamesScrollView._view.numChildren > 0) do
		gamesScrollView._view:remove(1);
	end
	--clear out button list to repopulate.
	for i = #gameButtonList, 1, -1 do
		gameButtonList[i]:removeSelf();
		gameButtonList[i] = nil;
		table.remove(gameButtonList, i);
	end
	gameButtonList = {};
	local y = 0;
	for i = 1, #gameInstances do
		--since the table of game instances we pulled from the response
		--do not have the meta table information go ahead and grab the
		--full table from the game instance manager using the ID.
		local game = g_Together.GameInstanceManager:FindByGameInstanceID(gameInstances[i].GameInstanceID);
		local button = widget.newButton(
		{
			top=y, 
			width= buttonProperties.width, 
			height= buttonProperties.height, 
			label="ID: " .. game.GameInstanceID .. " " .. game.GameInstanceType, 
			onRelease=
				function(event)
					if(game.IsUserMemberOf == true) then
						storyboard.gotoScene("GameScene", {params={game=game}});
					else
						--Join the game 
						g_Together.GameInstanceManager:Join(game.GameInstanceID, nil,
							function(event)
								--joined game
								if(event.Success) then
									print("JOINING GAME");
									--send the game to the game scene to be used to populate the board.
									storyboard.gotoScene("GameScene", {params={game=game}});
								else
									--put code to deal with a failed join here.
								end
							end);
					end
				end
		});
		button.x = _W/2;
		gameButtonList[#gameButtonList + 1] = button;
		gamesScrollView:insert(button);
		y = y + buttonProperties.height + buttonProperties.bottomPadding;
	end
	
end

local function onCreateGameTouch(event)
	--Creation of the game table to be sent to the server as part
	-- of the game instance properties.
	local game = Game.new(g_Together.TogetherUser.UserID);
	local gameProperties = together.PropertyCollection:New();
	--Turn the game table into a JSON string for ease of retrieving in code later
	--and then add it to the game properties.
	gameProperties:Set("game", json.encode(game));
	
	--Go ahead and tell together that a new game instance has been created.
	g_Together.GameInstanceManager:Create("Memory", "", 0, 2, false, gameProperties, nil,
		function(e)	--inline callback function
			if(e.Success == true) then
				--Any code to handle success here
				--Since I constantly poll the server for game instances
				--I will just ignore this for now
				--but you could easily have the user automatically sent to the
				--GameScene with the data.
			else
				--Any code to handle not being able to create the game should go here
			end
		end);
end

---END MemoryGame functions

function scene:createScene( event )
        local group = self.view
		
        -----------------------------------------------------------------------------

        --      CREATE display objects and add them to 'group' here.
        --      Example use-case: Restore 'group' from previously saved state.

        -----------------------------------------------------------------------------
		
		-- Need to start with a new GameInstanceManager for together to use.
		g_Together.GameInstanceManager = together.GameInstanceManager:New(); 
		
		local button = widget.newButton({top=STATUS_BAR_HEIGHT + 20, width= 200, height= 75, label="Create Game", onRelease=onCreateGameTouch});
		button.x = _W / 2;
		scene.view:insert(button);
			
		--scrollview
		button:setReferencePoint(display.BottomCenterReferencePoint);
		local bgRect = display.newRect(0,0, _W, button.y+15);
		bgRect:setFillColor(BG_COLOR.r, BG_COLOR.g, BG_COLOR.b);
		
		gamesScrollView = widget.newScrollView(
			{
				width=_W, 
				top=button.y + 15, 
				height= _H - button.y+15,
				scrollWidth= _W,
				scrollHeight=button.y + 15,
				hideBackground=true
			});
			
		self.view:insert(gamesScrollView);
		self.view:insert(bgRect);
		self.view:insert(button);
		
		table.print(gamesScrollView);
end


-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
        local group = self.view

        -----------------------------------------------------------------------------

        --      This event requires build 2012.782 or later.

        -----------------------------------------------------------------------------

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
        local group = self.view

        -----------------------------------------------------------------------------

        --      INSERT code here (e.g. start timers, load audio, start listeners, etc.)

        -----------------------------------------------------------------------------
		--create the timer to retrieve the gameslist from the servers if it has not already been created.
		if(getGamesTimer == nil) then
			getGamesTimer = timer.performWithDelay(3000, 
				function(event)
					--  State Values:
					--		1 - waitingForPlayers
					--		2 - inProgress
					--		4 - finished
					--		8 - possibleRematch
					--		16 - forfeit
					--creates the statemask for what types of games I will
					--receive from the server
					--NOTE: keep in this order.
					local stateMasks = 
						{ 
							waitingForPlayers=true, 
							inProgress=true, 
							finished = false, 
							possibleRematch = false, 
							forfeit = false 
						};
					--Retrieves all of the games that the statemask applies to and also all that have the specified
					-- userID attached, set userID to 0 to show all games.
					g_Together.GameInstanceManager:GetAll(0,			-- userID, set to zero, want all games not just ones the user is part of
											  stateMasks, 			-- stateMasks
											  15,					-- maxCount
											  true,					-- getGameInstanceProperties
											  false,				-- friendsOnly,
											  nil,					-- type
											  nil,					-- subtype
											  onGotAllGames);		-- callbackFunc
				end,
				0);	-- putting zero here ensures that this timer will constantly repeat.
		else
			timer.resume(getGamesTimer);
		end
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
        local group = self.view

        -----------------------------------------------------------------------------

        --      INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)

        -----------------------------------------------------------------------------
		--stop retrieving the gamelist while this scene is not active.
		timer.pause(getGamesTimer);
end


-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
        local group = self.view

        -----------------------------------------------------------------------------

        --      This event requires build 2012.782 or later.

        -----------------------------------------------------------------------------

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
        local group = self.view

        -----------------------------------------------------------------------------

        --      INSERT code here (e.g. remove listeners, widgets, save state, etc.)

        -----------------------------------------------------------------------------

end


-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
        local group = self.view
        local overlay_name = event.sceneName  -- name of the overlay scene

        -----------------------------------------------------------------------------

        --      This event requires build 2012.797 or later.

        -----------------------------------------------------------------------------

end


-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
        local group = self.view
        local overlay_name = event.sceneName  -- name of the overlay scene

        -----------------------------------------------------------------------------

        --      This event requires build 2012.797 or later.

        -----------------------------------------------------------------------------

end



---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener( "willEnterScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "didExitScene" event is dispatched after scene has finished transitioning out
scene:addEventListener( "didExitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-- "overlayBegan" event is dispatched when an overlay scene is shown
scene:addEventListener( "overlayBegan", scene )

-- "overlayEnded" event is dispatched when an overlay scene is hidden/removed
scene:addEventListener( "overlayEnded", scene )

---------------------------------------------------------------------------------

return scene