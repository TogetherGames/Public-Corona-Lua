--module(..., package.seeall)

local TextButton = {}
local mt = { __index = TextButton }

local function CreateMultilineText(displayGroup, text, startX, startY, fontSize, color)
    local pieces = {}
    local foundAt = text:find("\n")
    while foundAt ~= nil do
        pieces[#pieces + 1] = text:sub(1, foundAt - 1)
        text = text:sub(foundAt + 1)
        foundAt = text:find("\n")
    end
    pieces[#pieces + 1] = text

    for i,str in ipairs(pieces) do
        local textLine = display.newText(displayGroup, str, 0, 0, native.systemFontBold, fontSize)
        if color ~= nil then
            textLine:setTextColor(color.r, color.g, color.b)
        else
            textLine:setTextColor(0, 0, 0)
        end
        textLine.x, textLine.y = startX, startY + (i-1) * textLine.height
    end
end

-----------------
-- Constructor --
-----------------

function TextButton:New(parentGroup, text, tapHandler, fontSize)
	local textButton = {}
	setmetatable(textButton, mt)
	local displayGroup = display.newGroup()
	parentGroup:insert(displayGroup)

	textButton.displayGroup = displayGroup
	textButton.enabled = true
	textButton.buttonIndex = 0;

    fontSize = fontSize or 28
    if _G.deviceIsIPad then
        fontSize = math.floor(fontSize * 1.4)
    end

    local textGroup = display.newGroup()
    displayGroup:insert(textGroup)
    CreateMultilineText(textGroup, text, 0, 0, fontSize)
    textGroup:setReferencePoint(display.CenterReferencePoint)
    textGroup.x, textGroup.y = 0, 0

    local box = display.newRect(displayGroup, 0, 0, textGroup.width + 20, textGroup.height + 10)
    box:setFillColor(255, 255, 255)
    box.x = 0
    box.y = 0
	displayGroup:insert(1, box)

	displayGroup:addEventListener("touch", textButton)
	textButton.tapHandler = tapHandler
	
	textButton.displayGroup = displayGroup
	
	return textButton
end

----------------------
-- Instance Methods --
----------------------

function TextButton:touch(event)
   	if event.phase == "ended" or event.phase == "cancelled" then
   		if self.enabled == true then
   			if (self.buttonIndex == 0) then
   				self:tapHandler(event)
   			else
   				self.tapHandler(event, self)
    		end
    	end
    end

    return true
end

function TextButton:SetPos(x, y)
	self.displayGroup:setReferencePoint(display.TopLeftReferencePoint)

    self.displayGroup.x = x - self.displayGroup.width * 0.5
	self.displayGroup.y = y
end

function TextButton:CleanUp()
	self.displayGroup:removeEventListener("touch", self)
end

return TextButton

