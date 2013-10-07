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



local buttonProperties = 
	{
		height = 75;
		width = 75;
		textSize = 15;
		padding = 10;
	}

local gameInstance = nil;
local boardData = nil;
local boardButtons = {};
local boardOverlays = {};
local updateTimer = nil;
local isMyTurn = false;

local click1 = nil;
local click2 = nil;
local onNoMatchTimer = nil;

local disableInput = true;

local turnText;

local myColor = 
	{
		r=88,
		g=110,
		b=237
	}
local theirColor = 
{
	r=242,
	g=65,
	b=65
}

--BEGIN MemoryGame Functions
--forward declaration for a function
local sendGameUpdate;

--check if the selected tiles are a match
local function checkMatch(index1, index2)
	local isMatch = false;
	if(boardData:isMatch(index1, index2)) then
		boardData:addScore(g_Together.TogetherUser.UserID, 10);
		boardData:setMatched(g_Together.TogetherUser.UserID, index1, index2);
		isMatch = true;
	end
	return isMatch;	
end

--hide the tile information and allow a user to now select parts.
local function hideTiles()
	for i = 1, #boardButtons do
		if(boardData:getTileOwner(i) == nil) then
			boardButtons[i]:setLabel("");
		end
	end
	disableInput = false
end

local function getPosition(index)
	-- This code is a work around to issues being faced when working with display groups for button and overlay positioning
	-- this is not suggested.
	-- Calculates the X and Y coordinates of a given button or overlay to ensure that the set
	-- of buttons will be in the center of the screen.
	local offsetX = (_W/2) - ((2 * (buttonProperties.width + buttonProperties.padding) + buttonProperties.width)/2);
	local offsetY = (_H/2) - ((2 * (buttonProperties.height + buttonProperties.padding) + buttonProperties.height)/2);
	local x = (index-1)%4 * (buttonProperties.width + buttonProperties.padding) + offsetX;
	local y = math.floor((index-1)/4) * (buttonProperties.height + buttonProperties.padding) + offsetY;
	return x,y;
end

local function addOverlay(index)
	local owner = boardData:getTileOwner(index);
	local color = myColor;
	
	if(owner == nil or boardOverlays[index] ~= nil) then
		return;
	end
	
	local x,y = getPosition(index);	
	if(owner ~= g_Together.TogetherUser.UserID) then
		color = theirColor;
	end
	
	boardOverlays[index] = display.newRect(0, 
		0, buttonProperties.width, buttonProperties.height);
	boardOverlays[index].x = x;
	boardOverlays[index].y = y;
	boardOverlays[index]:setFillColor(color.r, color.g, color.b);
	boardOverlays[index].blendMode = "multiply";
	scene.view:insert(boardOverlays[index]);
end

local function checkForWinner()
	local winner = nil;
	local scoreMax = nil;
	for i = 1, #gameInstance.GameInstanceUsers do
		local score = boardData:getScore(gameInstance.GameInstanceUsers[i].UserID);
		if(scoreMax == nil) then
			scoreMax = score;
			winner = gameInstance.GameInstanceUsers[i].UserID;
		elseif(score ~= nil and scoreMax < score) then
			scoreMax = score;
			winner = gameInstance.GameInstanceUsers[i].UserID;
		end
	end
	return winner;
end

local function onClick(i)
	if(disableInput == false and isMyTurn == true) then
		if(boardData:getTileOwner(i) ~= nil) then
			return;
		end
		if(click1 == nil) then
			click1 = i;
			boardButtons[i]:setLabel(boardData.board[i]);
		elseif(click2 == nil and i ~= click1) then
			click2 = i;
			boardButtons[i]:setLabel(boardData.board[i]);
			if(true == checkMatch(click1, click2)) then
				addOverlay(click1);
				addOverlay(click2);
				click2 = nil;
				click1 = nil;
				if(boardData:allTilesUsed() == true) then
					local winner = checkForWinner();
					if(winner ~= nil) then
						table.print(boardData);
						--if there is a winner send the updated information to
						--the together servers.
						sendGameUpdate();
						--Now tell together that the game has finished and who won.
						gameInstance:Finish(winner,
							function(response)
								if(response.Success == true) then
									--create the appropriate text to display the alery.
									local text = "Better Luck Next Time";
									if(winner == g_Together.TogetherUser.UserID) then
										text = "Congratulations on Winning!";
									end
									native.showAlert("Game Over", text, {"OK"},
										function()
											storyboard.gotoScene(storyboard.getPrevious());
										end);	--alery listener
								else
									--could not complete request code here.
								end
							end);
					end
				end
			else
				disableInput = true;
				isMyTurn = false;
				sendGameUpdate();
				onNoMatchTimer = timer.performWithDelay(1000,
					function()
						disableInput = false;
						boardButtons[click1]:setLabel("");
						boardButtons[click2]:setLabel("");
						click2 = nil;
						click1 = nil;
					end);
			end
		end
	end --endif disableinput
end

--called anytime the board is retrieved from the server and
--something has updated the data game. ie. a move or a player joining.
local function setupBoard()
	if(gameInstance.State == 4) then
		local winner = checkForWinner();
		if(winner ~= nil) then
			local text = "Better Luck Next Time";
			if(winner == g_Together.TogetherUser.UserID) then
				text = "Congratulations on Winning!";
			end
			native.showAlert("Game Over", text, {"OK"},
				function()
					storyboard.gotoScene(storyboard.getPrevious());
				end);	--alery listener
		end
	end
	--clear out the overlays to make new ones.
	for i,overlay in pairs(boardOverlays) do
		scene.view:remove(overlay);
		overlay = nil;
	end
	boardOverlays = {};
	
	isMyTurn = gameInstance.TurnUserID == g_Together.TogetherUser.UserID;
	
	if(isMyTurn == true) then
		turnText.text = "Your Turn";
		turnText:setTextColor(myColor.r, myColor.g, myColor.b);
	else
		turnText.text = "Waiting On Opponent";
		turnText:setTextColor(theirColor.r, theirColor.g, theirColor.b);
	end
	
	--pull the data out that we put into the game instance properties
	--when the game was created.
	boardData = Game.fromJson(gameInstance.Properties:Get("game"));
	
	--set the user's information.
	if(boardData.players[g_Together.TogetherUser.UserID] == nil) then
		boardData.players[g_Together.TogetherUser.UserID] =
		{
			score = 0;
			seen = false;
		}
	end
	--this could be a constant of 4, but this is added in case the board 
	--size is ever changed.
	local boardWidth = math.sqrt(#boardData.board);
	--create the buttons for the board.
	for i = 1, #boardData.board do
		local x,y = getPosition(i);
		
		--if the button hasn't been created before go ahead and create it
		if(boardButtons[i] == nil) then
			boardButtons[i] = widget.newButton(
				{
					width= buttonProperties.width, 
					height= buttonProperties.height, 
					label=boardData.board[i], 
					onRelease=
						function(event)
							onClick(i);
						end
				});
			boardButtons[i].x = x;
			boardButtons[i].y = y;
			scene.view:insert(boardButtons[i]);
		else	--else just change the label. button can be reused.
			boardButtons[i]:setLabel(boardData.board[i]);
		end
		--checks if an overlay is needed and adds if necessary.
		addOverlay(i);
	end
	
	--if we are going to hide the table after it is shown
	--we don't want to hide the 2 items clicked early.
	if(nil ~= onNoMatchTimer) then
		timer.cancel(onNoMatchTimer);
		onNoMatchTimer = nil;
		disableInput = false;
		click2 = nil;
		click1 = nil;
	end
	--remove any clicks that may have occured in that 4 seconds
	timer.performWithDelay(4000,
		function()
			click2 = nil;
			click1 = nil;
			hideTiles();
		end);
			
end

sendGameUpdate = function()
	--set the game properties to the updated board.
	gameInstance.Properties:Set("game", json.encode(boardData));
	--tell together that I want to make a move.
	gameInstance:MakeMove(
		function(event)
			if(event.Success == true) then
				--grab the updated game instance from the manager.
				gameInstance = g_Together.GameInstanceManager:FindByGameInstanceID(gameInstance.GameInstanceID);
				setupBoard();
			else
				--on call failure do something here
			end
		end);
end

---END MemoryGame functions

-- Called when the scene's view does not exist:
function scene:createScene( event )
        local group = self.view
		
        -----------------------------------------------------------------------------

        --      CREATE display objects and add them to 'group' here.
        --      Example use-case: Restore 'group' from previously saved state.

        -----------------------------------------------------------------------------
		local backButton = widget.newButton(
			{
				top=STATUS_BAR_HEIGHT + 30;
				left = 10;
				width= buttonProperties.width, 
				height= buttonProperties.height, 
				label="back", 
				onRelease=
					function(event)
						storyboard.gotoScene(storyboard.getPrevious());
					end
			});
		self.view:insert(backButton);
		
		turnText = display.newText("Your Turn", 0,STATUS_BAR_HEIGHT + 15, native.systemFont, 40);
		turnText.x = _W/2;
		self.view:insert(turnText);
		
		-- this will continually grab the game from the together server
		-- This has the potential to make a lot of calls to the together server
		-- so an exponential backoff or a change of delay over time would
		-- probably be a better practice. Saves you calls and our server 
		-- from processing calls that give you little information
		updateTimer = timer.performWithDelay(4000, 
			function()
				--get the last modified time stamp so we can check if the game has changed since we last tried.
				local lastTimeStamp = gameInstance.LastModifyTimestamp;
				--grab the details.
				gameInstance:GetDetails(gameInstance.GameInstanceID,
					function(event)
						--get the updated game instance from the manager
						gameInstance = g_Together.GameInstanceManager:FindByGameInstanceID(gameInstance.GameInstanceID);
						--now if the game has actually changed setup the board.
						if(lastTimeStamp ~= gameInstance.LastModifyTimestamp) then
							setupBoard();
						end
					end);
			end, 0);
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
		if(updateTimer ~= nil) then
			timer.resume(updateTimer);
		end
		if(event.params == nil) then
			if(gameInstance == nil) then
				storyboard.gotoScene(storyboard.getPrevious());
			end
		else
			gameInstance = event.params.game;
		end
		
		setupBoard();
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
        local group = self.view

        -----------------------------------------------------------------------------

        --      INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)

        -----------------------------------------------------------------------------
		timer.pause(updateTimer);
		print("exit");
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