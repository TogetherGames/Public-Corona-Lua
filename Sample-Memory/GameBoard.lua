GameBoard = {}

GameBoard.__index = GameBoard;

local startChar = 65; 	--A
local endChar = 90;		--Z
local boardSize = 16;


function GameBoard.new()
	local gBoard = {};
	setmetatable(gBoard, GameBoard);
	local remainingSpots = {};
	for i = 1, boardSize, 1 do
		remainingSpots[ #remainingSpots + 1] = i;
	end
	--picks a random letter between A and Z, and then picks 2 random 
	--remaining places on the board to place these letters
	while #remainingSpots > 0 do
		local randIndex = math.random(1, #remainingSpots);
		local index1 = remainingSpots[randIndex];
		table.remove(remainingSpots, randIndex);
		randIndex = math.random(1, #remainingSpots);
		local index2 = remainingSpots[randIndex];
		table.remove(remainingSpots, randIndex);
		local value = string.char(math.random(startChar, endChar));
		gBoard[index1] = value;
		gBoard[index2] = value
		
	end
	
	return gBoard;
end


return GameBoard