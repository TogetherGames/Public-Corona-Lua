 --module(..., package.seeall)

local BaseState = require("BaseState");
local together = require("plugin.together");

local MenuGameInstance = {};
local super = BaseState;	--Inherit from BaseState
setmetatable(MenuGameInstance, { __index = super } );
local mt = { __index = MenuGameInstance };



-----------------
-- Constructor --
-----------------

function MenuGameInstance:New()
	local self = BaseState:New();
	setmetatable(self, mt);

    self.type = BaseState.State_GameInstance;

    self.ShouldPoll = true;
    self.TimeInc = 0;
    self.PollInterval = 7.0;

    self.TurnLabel = nil;

    self.GameInstanceIDLabel = nil;
    self.UserIndexLabel = nil;
    self.TurnIndexLabel = nil;
    self.PlayCountLabel = nil;

    self.UserTitle = nil;
    self.UserLabels = {};

    self.BoardImage = nil;
    self.BoardData = "";
    self.BoardPieces = nil;

	self.User = nil;
	self.GameInstanceManager = nil;
	self.GameInstance = nil;

	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuGameInstance:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	print("MenuGameInstance:Enter()");

	self.User = g_Together.TogetherUser;
	self.GameInstanceManager = g_Together.GameInstanceManager;
	self.GameInstance = g_CurrentGameInstance;

	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

    local gameLobbyButton;
    local leaveGameButton;
    local forfeitGameButton;
    local inviteFriendButton;
   	local clearBoardButton
    local makeTurnButton;
    local winButton;


    local function onGameLobbyButtonClicked()
    	ChangeState(BaseState.State_GameLobby);
    end

    local function onLeaveGameButtonClicked()
    	self:LeaveGame();
    end

    local function onForfeitGameButtonClicked()
    	self:ForfeitGame();
    end

    local function onInviteFriendButtonClicked()
    	self:InviteFriend();
    end

    local function onClearBoardButtonClicked()
    	self:ClearGameBoard();
    end

    local function onPollButtonClicked()
   		self:PollGame();
    end


    self.BoardImage = display.newImage(displayGroup, "Board.png", 128, display.contentHeight-512-32);


	local userIndex = self.GameInstance:IndexOfGameInstanceUserByUserID(self.User.UserID);
    
   	local topY = display.contentHeight * 0.1 - 40;

   	gameLobbyButton = TextButton:New(displayGroup, "Game Lobby", onGameLobbyButtonClicked, 20);
   	gameLobbyButton:SetPos(120, 30);

   	leaveGameButton = TextButton:New(displayGroup, "Leave Game", onLeaveGameButtonClicked, 20);
   	leaveGameButton:SetPos(120, 90);

   	inviteFriendGameButton = TextButton:New(displayGroup, "Invite Friend", onInviteFriendButtonClicked, 20);
   	inviteFriendGameButton:SetPos(120, 220);

   	clearGameButton = TextButton:New(displayGroup, "Clear Board", onClearBoardButtonClicked, 20);
   	clearGameButton:SetPos(120, 280);

   	forfeitGameButton = TextButton:New(displayGroup, "Forfeit Game", onForfeitGameButtonClicked, 20);
   	forfeitGameButton:SetPos(120, 340);

   	local title = display.newText(displayGroup, "Game Instance", 0, 0, native.systemFontBold, 42);
   	title.x = display.contentCenterX + 90;
   	title.y = topY;


   	self.TurnLabel = display.newText(displayGroup, "Your Turn", 0, 0, native.systemFontBold, 36);
   	self.TurnLabel.x = display.contentCenterX - 100;
   	self.TurnLabel.y = topY + 110;

        
   	topY = 120;
    
   	self.GameInstanceIDLabel = display.newText(displayGroup, "GameInstanceID = ", 0, 0, native.systemFontBold, 30);
   	self.GameInstanceIDLabel.x = display.contentWidth - 150;
   	self.GameInstanceIDLabel.y = topY;
   	topY = topY + 40;

   	self.UserIndexLabel = display.newText(displayGroup, "UserIndex = " .. userIndex, 0, 0, native.systemFontBold, 30);
   	self.UserIndexLabel.x = display.contentWidth - 150;
   	self.UserIndexLabel.y = topY;
   	topY = topY + 40;
    
   	self.TurnIndexLabel = display.newText(displayGroup, "TurnIndex = ", 0, 0, native.systemFontBold, 30);
   	self.TurnIndexLabel.x = display.contentWidth - 150;
   	self.TurnIndexLabel.y = topY;
   	topY = topY + 40;

   	self.PlayCountLabel = display.newText(displayGroup, "PlayCount = ", 0, 0, native.systemFontBold, 30);
   	self.PlayCountLabel.x = display.contentWidth - 150;
   	self.PlayCountLabel.y = topY;
   	topY = topY + 40;


   	self.UsersTitle = display.newText(displayGroup, "Users Playing Game", 0, 0, native.systemFontBold, 38);
   	self.UsersTitle.x = display.contentCenterX + 80;
   	self.UsersTitle.y = topY + 10;


   	self.BoardPieces = {};

   	local function boardImage_TouchListener(event) 
    	if (event.phase == "ended") then
    		self:BoardTouched(event.x, event.y);
    	end
    	return true;
    end 

    self.BoardImage:addEventListener("touch", boardImage_TouchListener);

    self:CreateUserLabels();

    self:GameInstanceUpdated();

    unrequire("ImageButton");
    unrequire("TextButton");
end

--  (134, 486) x (296, 650)
--  (296, 486) x (468, 650)
--  (468, 486) x (640, 650)

--  (134, 650) x (296, 824)
--  (296, 650) x (468, 824)
--  (468, 650) x (640, 824)

--  (134, 824) x (296, 990)
--  (296, 824) x (468, 990)
--  (468, 824) x (640, 990)

function MenuGameInstance:Update(elapsedTime)
	if (self.ShouldPoll == true) then
		self.TimeInc = self.TimeInc + elapsedTime;
		if (self.TimeInc >= self.PollInterval) then
			self.TimeInc = self.TimeInc - self.PollInterval;
			self:PollGame();
		end
	end
end

function MenuGameInstance:Draw()
end

function MenuGameInstance:Exit()
	super.Exit(self);
end

function MenuGameInstance:HandleKeyEvent(event)
	return false;
end




-- Checks to see if you can make a move in the game.
function MenuGameInstance:CanMakeMoveInGame()
	local dataLength = string.len(self.BoardData);
	
	if (dataLength == 0) then
		return true;
	end

	local emptyPieceCount = 0;
	local pieceIndex = 0;
	for pieceIndex=1, dataLength do
		if (self:GetBoardCell(pieceIndex) == "_") then
			emptyPieceCount = emptyPieceCount + 1;
		end
	end
	
	if (emptyPieceCount == 0) then
		return false;
	end

	return true;
end

-- Checks for winning/losing conditions.
function MenuGameInstance:CheckForWinCondition()
	local myPieceValue = "M";
	local opposingPieceValue = "O";

	if (self.GameInstance:IndexOfGameInstanceUserByUserID(self.User.UserID) ~= 1) then
		myPieceValue = "O";
		opposingPieceValue = "M";
	end
	
	-- Check to see if I won in a horizontal row.
	if (self:GetBoardCell(1) == myPieceValue and self:GetBoardCell(2) == myPieceValue and self:GetBoardCell(3) == myPieceValue) then
		return "won";
	elseif (self:GetBoardCell(4) == myPieceValue and self:GetBoardCell(5) == myPieceValue and self:GetBoardCell(6) == myPieceValue) then
		return "won";
	elseif (self:GetBoardCell(7) == myPieceValue and self:GetBoardCell(8) == myPieceValue and self:GetBoardCell(9) == myPieceValue) then
		return "won";
	end

	-- Check to see if I won in a vertical row.
	if (self:GetBoardCell(1) == myPieceValue and self:GetBoardCell(4) == myPieceValue and self:GetBoardCell(7) == myPieceValue) then
		return "won";
	elseif (self:GetBoardCell(2) == myPieceValue and self:GetBoardCell(5) == myPieceValue and self:GetBoardCell(8) == myPieceValue) then
		return "won";
	elseif (self:GetBoardCell(3) == myPieceValue and self:GetBoardCell(6) == myPieceValue and self:GetBoardCell(9) == myPieceValue) then
		return "won";
	end

	-- Check diagonals.
	if (self:GetBoardCell(1) == myPieceValue and self:GetBoardCell(5) == myPieceValue and self:GetBoardCell(9) == myPieceValue) then
		return "won";
	elseif (self:GetBoardCell(3) == myPieceValue and self:GetBoardCell(5) == myPieceValue and self:GetBoardCell(7) == myPieceValue) then
		return "won";
	end
		
	-- Check to see if the opposer won in a horizontal row.
	if (self:GetBoardCell(1) == opposingPieceValue and self:GetBoardCell(2) == opposingPieceValue and self:GetBoardCell(3) == opposingPieceValue) then
		return "lost";
	elseif (self:GetBoardCell(4) == opposingPieceValue and self:GetBoardCell(5) == opposingPieceValue and self:GetBoardCell(6) == opposingPieceValue) then
		return "lost";
	elseif (self:GetBoardCell(7) == opposingPieceValue and self:GetBoardCell(8) == opposingPieceValue and self:GetBoardCell(9) == opposingPieceValue) then
		return "lost";
	end

	-- Check to see if the opposer won in a vertical row.
	if (self:GetBoardCell(1) == opposingPieceValue and self:GetBoardCell(4) == opposingPieceValue and self:GetBoardCell(7) == opposingPieceValue) then
		return "lost";
	elseif (self:GetBoardCell(2) == opposingPieceValue and self:GetBoardCell(5) == opposingPieceValue and self:GetBoardCell(8) == opposingPieceValue) then
		return "lost";
	elseif (self:GetBoardCell(3) == opposingPieceValue and self:GetBoardCell(6) == opposingPieceValue and self:GetBoardCell(9) == opposingPieceValue) then
		return "lost";
	end

	-- Check diagonals.
	if (self:GetBoardCell(1) == opposingPieceValue and self:GetBoardCell(5) == opposingPieceValue and self:GetBoardCell(9) == opposingPieceValue) then
		return "lost";
	elseif (self:GetBoardCell(3) == opposingPieceValue and self:GetBoardCell(5) == opposingPieceValue and self:GetBoardCell(7) == opposingPieceValue) then
		return "lost";
	end

	-- Checks to see if you can make a move in the game.
	if (self:CanMakeMoveInGame() == false) then
		return "tied";	
	end

	return "";
end

function MenuGameInstance:SynchBoardPieces()
	print("------------------------------------------------------");
	print("MenuGameInstance:synchBoardPieces()");
	local boardData = self.GameInstance.Properties:GetEx("Data", "");
    print("   self.BoardData = " .. boardData);
    print("   boardData = " .. boardData);

--  if (self.BoardData ~= boardData) then
		self:DestroyBoardPieces();
		self:CreateBoardPieces();
--	end
	print("------------------------------------------------------");
end

function MenuGameInstance:DestroyBoardPieces()
	local pieceCount = table.getn(self.BoardPieces);
	local pieceIndex;
	local boardPiece = nil;

	for pieceIndex=1, pieceCount do
		boardPiece = self.BoardPieces[pieceIndex];
		boardPiece:removeSelf();
	end

	self.BoardPieces = {};
end

function MenuGameInstance:CreateBoardPieces()
	local boardPiece = nil;
	local pieceIndex = 1;
	local pieceX = 120;
   	local pieceY = 470;
   	local pieceStepX = 173;
   	local pieceStepY = 173;
   	local boardCell = "";
   	local boardCellImage = "";
   	
   	
   	self.BoardData = self.GameInstance.Properties:GetEx("Data", "");
   	if (self.BoardData == nil) then
   		print("   self.BoardData = nil");
   	end

   	print("self.BoardData = " .. self.BoardData);

   	for pieceIndex=1, string.len(self.BoardData) do
   		boardCell = self.BoardData:sub(pieceIndex, pieceIndex);

   		print("boardCell = '" .. boardCell .. "'");

   		if (boardCell ~= "_") then
   			boardCellImage = "Board_X.png";
   			if (boardCell == "O") then
   				boardCellImage = "Board_O.png";
   			end

   			boardPiece = display.newImage(self.displayGroup, boardCellImage, pieceX, pieceY);
   			table.insert(self.BoardPieces, boardPiece);
   	    end

   	    pieceX = pieceX + pieceStepX;
   		
   		if (pieceIndex == 3 or pieceIndex == 6) then
   			pieceX = 120;
   			pieceY = pieceY + pieceStepY;   		
   		end
    end
end



------------------------------------------------
-- Events.
------------------------------------------------
function MenuGameInstance:BoardTouched(touchX, touchY)
	print("MenuGameInstance:BoardTouched(" .. touchX .. ", " .. touchY .. ")");

	local pieceIndex = self:GetBoardPieceIndex(touchX, touchY);

	local pieceValue = "O";
	if (self.GameInstance:IndexOfGameInstanceUserByUserID(self.User.UserID) == 1) then
		pieceValue = "M";
	end
	
	local winCondition = "";

	if (self:SetBoardCell(pieceIndex, pieceValue) == true) then
--		print("Move made on the board.");
		print("   self.BoardData = " .. self.BoardData);

		winCondition = self:CheckForWinCondition();
		print("   winCondition = " .. winCondition);
		
		if (winCondition == "won") then
			self:WinGame();
		elseif (winCondition == "tied") then
			self:TieGame();
		else			
			self:MakeTurnInGame();
		end
	end
end

function MenuGameInstance:GetBoardPieceIndex(touchX, touchY)
	local pieceIndex = -1;

	-- First row
	if (touchY >= 486 and touchY < 650) then
		-- Piece0
		if (touchX >= 134 and touchX < 296) then
			pieceIndex = 1;
		-- Piece1
		elseif (touchX >= 296 and touchX < 468) then
			pieceIndex = 2;
		-- Piece2
		elseif (touchX >= 468 and touchX < 640) then
			pieceIndex = 3;
		end

	-- Second row
	elseif (touchY >= 650 and touchY < 824) then
		-- Piece3
		if (touchX >= 134 and touchX < 296) then
			pieceIndex = 4;
		-- Piece4
		elseif (touchX >= 296 and touchX < 468) then
			pieceIndex = 5;
		-- Piece5
		elseif (touchX >= 468 and touchX < 640) then
			pieceIndex = 6;
		end

	-- Third row
	elseif (touchY >= 824 and touchY < 990) then
		-- Piece6
		if (touchX >= 134 and touchX < 296) then
			pieceIndex = 7;
		-- Piece7
		elseif (touchX >= 296 and touchX < 468) then
			pieceIndex = 8;
		-- Piece8
		elseif (touchX >= 468 and touchX < 640) then
			pieceIndex = 9;
		end
	end

	return pieceIndex;
end

function MenuGameInstance:GetBoardCell(pieceIndex)
	local boardCell = self.BoardData:sub(pieceIndex, pieceIndex);
   		
	return boardCell;
end

function MenuGameInstance:SetBoardCell(pieceIndex, pieceValue)
	local newBoardData = "";
	local boardData = self.BoardData;

	local pieceChar = boardData:sub(pieceIndex, pieceIndex);

	if (pieceChar == "_") then
		if (pieceIndex > 1) then
			newBoardData = boardData:sub(1, pieceIndex-1);
		end
		newBoardData = newBoardData .. pieceValue;
			
		if ((string.len(boardData) - pieceIndex) > 0) then
			newBoardData = newBoardData .. boardData:sub(pieceIndex+1);
		end
		
		self.BoardData = newBoardData;
		self.GameInstance.Properties:Set("Data", self.BoardData);
		return true;
	end

	return false;
end

function MenuGameInstance:MakeTurnInGame()
	
	local function onTurnMade(callback)
		print("onTurnMade(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:GameInstanceUpdated();
			self.GameInstance:Dump();
		end
	end

	local myGameInstanceUser = self.GameInstance:FindGameInstanceUserByUserID(self.User.UserID);
	
	
--	if (self.GameInstance.State == GAME_STATE_WAITING_FOR_PLAYERS) then
--		showAlert("Uh Oh", "Still waiting for users to join the game.");
	if (self.GameInstance.TurnUserID ~= self.User.UserID) then
		showAlert("Uh Oh", "It's not your turn.");
	else
	    local myGameInstanceUser = self.GameInstance:FindGameInstanceUserByUserID(self.User.UserID);
	    local userScore = myGameInstanceUser.Properties:Get("Score");
	    if (userScore == nil) then
	    	userScore = 10;
	    else
	    	userScore = tonumber(userScore) + 10;
	    end
	    	
	    myGameInstanceUser.Properties:Set("Score", userScore);

		self.GameInstance:MakeMove(onTurnMade);
	end
end
 
function MenuGameInstance:WinGame()
	local function onGameWon(callback)
		print("onGameWon(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self.GameInstance:Dump();

			-- Check if the game is finished.
			if (self.GameInstance.State == 4) then
				self:GameInstanceUpdated();
				self:GameCompleted();
			end
		end
	end
	
	
	if (self.GameInstance.State == GAME_STATE_WAITING_FOR_PLAYERS) then
		showAlert("Uh Oh", "Still waiting for users to join the game.");
	elseif (self.GameInstance.TurnUserID ~= self.User.UserID) then
		showAlert("Uh Oh", "It's not your turn.");
	else
		local myGameInstanceUser = self.GameInstance:FindGameInstanceUserByUserID(self.User.UserID);
	    local userScore = myGameInstanceUser.Properties:Get("Score");
	    if (userScore == nil) then
	    	userScore = 40;
	    else
	    	userScore = tonumber(userScore) + 40;
	    end
	    	
	    myGameInstanceUser.Properties:Set("Score", userScore);

	    self.GameInstance:Finish(g_Together:GetUserID(), onGameWon);
	end
end

function MenuGameInstance:TieGame()
	local function onGameTied(status, description)
		print("onGameTied(" .. status .. ", " .. description .. ")");
		if (status == "Success") then
			self.GameInstance:Dump();

			-- Check if the game is finished.
			if (self.GameInstance.State == 4) then
				print("Calling self:GameCompleted()");
				self:GameInstanceUpdated();
				self:GameCompleted();
			end
		end
	end


	if (self.GameInstance.State == GAME_STATE_WAITING_FOR_PLAYERS) then
		showAlert("Uh Oh", "Still waiting for users to join the game.");
	elseif (self.GameInstance.TurnUserID ~= self.User.UserID) then
		showAlert("Uh Oh", "It's not your turn.");
	else
		self.GameInstance:Finish(0, 0, onGameTied);
	end
end

function MenuGameInstance:PollGame()
	local function onGamePolled(callback)
		if (callback.Success) then
			self.GameInstance:Dump();
			self:GameInstanceUpdated();

			-- Check if the game is finished.
			if (self.GameInstance.State == GAME_STATE_FINISHED) then
				self:GameCompleted();
			elseif (self.GameInstance.State == GAME_STATE_FORFEIT) then
				self:GameForfeited();			
			end
		end
	end

	self.GameInstance:GetDetails(self.GameInstance.GameInstanceID,
								 onGamePolled);
end


function MenuGameInstance:CreateUserLabels()
   	local TextButton = require("TextButton");

   	local function onUserLabelButton1Clicked(event)
		self:UserLabelButtonClicked(1);
   	end
   	local function onUserLabelButton2Clicked(event)
   		self:UserLabelButtonClicked(2);
   	end

   	local gameInstanceUserCount = self.GameInstance:GetGameInstanceUserCount();
	local gameInstanceUser;
   	local userText;
	local gameInstanceUserLabel;
   	local labelY = 330;
   	local userScore = "";

   	for i=1, gameInstanceUserCount do
    	gameInstanceUser = self.GameInstance:GetGameInstanceUser(i);
    	
    	userScore = gameInstanceUser.Properties:Get("Score");
    	if (userScore == nil) then
    		print("   userScore is nil");
    		userScore = "0";
    	else
    		print("   userScore = " .. userScore);
    	end
    		
    	userText = gameInstanceUser.Name .. ", Score=" .. userScore;
    
    	if (i == 1) then
    		gameInstanceUserLabel = TextButton:New(self.displayGroup, userText, onUserLabelButton1Clicked, 20);
    	elseif (i == 2) then
    		gameInstanceUserLabel = TextButton:New(self.displayGroup, userText, onUserLabelButton2Clicked, 20);
    	end
    	gameInstanceUserLabel:SetPos(display.contentCenterX+80, labelY);
    	labelY = labelY + 60;

    	table.insert(self.UserLabels, userLabel);
    end

    unrequire("TextButton");
end

function MenuGameInstance:DestroyUserLabels()
	local labelCount = table.getn(self.UserLabels);
	local userLabel;

    for i=1, labelCount do
    	userLabel = self.UserLabels[i];
    	userLabel:CleanUp();
    	self.displayGroup:remove(userLabel.displayGroup);
    end

    self.UserLabels = {};
end

function MenuGameInstance:SynchUserLabels()
	self:DestroyUserLabels();
	self:CreateUserLabels();
end

function MenuGameInstance:UserLabelButtonClicked(userIndex)
	print("MenuGameInstance:UserLabelButtonClicked(" .. userIndex .. ")");


end

function MenuGameInstance:GameInstanceUpdated()
   	if (self.GameInstance.TurnUserID == self.User.UserID) then
   		self.TurnLabel.text = "Your Turn!";
    else
    	self.TurnLabel.text = "Not Your Turn";
    end    

    self.GameInstanceIDLabel.text = "ID = " .. self.GameInstance.GameInstanceID;
   	self.UserIndexLabel.text = "UserIndex = " .. tostring(self.GameInstance:IndexOfGameInstanceUserByUserID(self.User.UserID));
   	self.TurnIndexLabel.text = "TurnIndex = " .. tostring(self.GameInstance.TurnIndex);
   	self.PlayCountLabel.text = "PlayCount = " .. tostring(self.GameInstance.PlayCount);

   	self:SynchUserLabels();
   	self:SynchBoardPieces();   	
end


function MenuGameInstance:GameCompleted()
	self.ShouldPoll = false;

	local function onAlertComplete(buttonIndex)
		print("onAlertComplete(" .. buttonIndex .. ")");
		-- Ok button clicked.
		if (buttonIndex == 1) then
			self:CreateRematch();
		else	
	   		ChangeState(BaseState.State_GameLobby);
	   	end
	end	

	local gameInstance = self.GameInstance:FindGameInstanceUserByUserID(self.User.UserID);

	local myUser = self.GameInstance:FindGameInstanceUserByUserID(self.User.UserID);
	print("MyUser:");
	myUser:Dump();


	if (self.GameInstance.WinningUserID == g_Together:GetUserID()) then
		showAlertEx("Congratulations", "You won!  Rematch?", {"Yes", "No"}, onAlertComplete);
	elseif (self.GameInstance.WinningUserID == 0) then
		showAlertEx("Arghh", "The game was a tie.  Rematch?", {"Yes", "No"}, onAlertComplete);
	else
		showAlertEx("Bummer", "You lost!  Rematch?", {"Yes", "No"}, onAlertComplete);
	end
end

function MenuGameInstance:GameForfeited()
	self.ShouldPoll = false;

	local function onAlertComplete(buttonIndex)
		print("onAlertComplete(" .. buttonIndex .. ")");
		-- Ok button clicked.
   		ChangeState(BaseState.State_GameLobby);
	end	

	showAlertEx("Hmmm", "The game was forfeited!", {"Ok"}, onAlertComplete);
end

function MenuGameInstance:CreateRematch()
	print("MenuGameInstance:CreateRematch()");

	if (self.GameInstance ~= nil) then
		self.GameInstance:Dump();
	else
		print("   self.GameInstance = nil");
	end

	local function onGameRematchCreated(callback)
		print("onGameRematchCreated(" .. callback.Status .. ", " .. callback.Description .. ")");

		if (callback.Success) then
			self.GameInstance.PlayCount = self.GameInstance.PlayCount + 1;
			--g_Together:Award(0, "rematchgame", nil);
			ChangeState(BaseState.State_GameLobby);
		else
			showAlert("Uh Oh", callback.Description);
		end
	end




	local gameInstanceUserCount = self.GameInstance:GetGameInstanceUserCount();
	local gameInstanceUser = nil;
	local otherGameInstanceUserUserID = 0;

   	for i=1, self.GameInstance:GetGameInstanceUserCount() do
    	if (self.GameInstance:GetGameInstanceUser(i).UserID ~= self.User.UserID) then
			otherGameInstanceUserUserID = self.GameInstance:GetGameInstanceUser(i).UserID;
			break;
		end
    end




    local myGameInstanceUser = self.GameInstance:FindGameInstanceUserByUserID(self.User.UserID);
    local rematchMessage = myGameInstanceUser.Name .. " wants a rematch.";

    local rematchGameProperties = together.PropertyCollection:New();
    rematchGameProperties:Set("Data", "_________");
    
    self.GameInstance:Dump();

	self.GameInstanceManager:CreateRematch(self.GameInstance.GameInstanceID,			-- originalGameInstanceID
										   self.GameInstance.GameInstanceType,			-- gameInstanceType
										   self.GameInstance.GameInstanceSubType,		-- gameInstanceSubType
										   self.GameInstance.RoomID,					-- roomID
										   self.GameInstance.MaxUsers,					-- maxUsers
										   self.GameInstance.WinningUserID,				-- winningUserID
										   otherGameInstanceUserUserID,--self.User.UserID,							-- turnUserID
										   true,										-- includeLeftGameUsers
										   rematchMessage,								-- rematchMessage
										   self.GameInstance.Properties,				-- originalGameProps
										   myGameInstanceUser.Properties,				-- originalWinningGameUserProps
										   rematchGameProperties,						-- rematchGameProps
										   onGameRematchCreated);						-- callbackFunc
end

function MenuGameInstance:LeaveGame()
	local function onGameInstanceLeft(callback)
		print("onGameInstanceLeft(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			ChangeState(BaseState.State_GameLobby);
		end
	end

	-- Leave the GameInstance.
	self.GameInstance:Leave(onGameInstanceLeft);				-- callbackFunc
end

function MenuGameInstance:ForfeitGame()
	local function onGameInstanceForfeited(callback)
		print("onGameInstanceForfeited(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			ChangeState(BaseState.State_GameLobby);
		end
	end

	-- Forfeit the GameInstance.
	self.GameInstance:Forfeit(onGameInstanceForfeited);			-- callbackFunc
end

function MenuGameInstance:InviteFriend()
	print("MenuGameInstance:InviteFriend()");
	g_PreviousMenu = BaseState.State_GameInstance;	
	ChangeState(BaseState.State_FriendLobby);
end

function MenuGameInstance:ClearGameBoard()
	print("MenuGameInstance:ClearGameBoard()");

	local function onGameInstanceModified(callback)
		print("onGameInstanceModified(" .. callback.Status .. ", " .. callback.Description .. ")");
		if (callback.Success) then
			self:GameInstanceUpdated();
		end
	end

	-- Modify the GameInstance.
	local boardData = self.GameInstance.Properties:Get("Data");
	boardData = "_________";
	self.GameInstance.Properties:Set("Data", boardData);
	
	self.GameInstance:Modify(-1, 							-- indexOfUserToModify
							 onGameInstanceModified);		-- callbackFunc
end


return MenuGameInstance;



