local json = require "json";
require("GameBoard");

Game = {};
Game.__index = Game;

function Game.new(userID)
	local game = {};
	setmetatable(game, Game);
	game.board = GameBoard.new();
	game.players = {};
	game.players[userID] = 
	{
		score = 0;
	}
	
	game.usedTiles = {};
		
	return game;
end

function Game.fromJson(gameJson)
	local game = json.decode(gameJson);
	setmetatable(game, Game);
	
	if(game.usedTiles == nil) then
		game.usedTiles = {};
	end
	
	local temp = game.usedTiles;
	game.usedTiles = {};
	
	for k,v in pairs(temp) do
		game.usedTiles[tonumber(k)] = tonumber(v);
	end
	local tempPlayers = game.players;
	game.players = {};
	for k,v in pairs(tempPlayers) do
		game.players[tonumber(k)] = v;
	end
	return game;
end

function Game:isMatch(tile1, tile2)
	return self.board[tile1] == self.board[tile2];
end

function Game:setMatched(userID, tile1, tile2)
	if(tile1 ~= tile2) then
		self.usedTiles[tile1] = userID;
		self.usedTiles[tile2] = userID;
	end
end

function Game:getTileValue(tileIndex)
	return self.board[tileIndex];
end

function Game:getTileOwner(tileIndex)
	return self.usedTiles[tileIndex];
end

function Game:addScore(userID, toAdd)
	self.players[userID].score = self.players[userID].score + toAdd;
end

function Game:addUser(userID)
	if(self.players[userID] ~= nil) then
		self.players[userID] = {score = 0};
	end
end

function Game:getScore(userID)
	if(self.players[userID] == nil) then
		return nil;
	end
	return self.players[userID].score;
end

function Game:allTilesUsed()
	--tried just doing return #self.usedTiles == #self.board
	--but if numeric indices are used for usedTiles #self.usedTiles will return the last one.
	-- ie. 1,2,3,16 were added to usedTiles and #self.usedTiles would report 16
	local usedCount = 0;
	for i= 1, #self.board do
		if(self.usedTiles[i] ~= nil) then
			usedCount = usedCount + 1;
		end
	end
	print(usedCount);
	return usedCount == #self.board;
end

function GameBoard:hasTileMatched(tileIndex)
	return self.usedTiles == tileIndex;
end

return Game