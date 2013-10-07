--module(..., package.seeall)

local ImageButton = {}
local mt = { __index = ImageButton }

local abs = math.abs

-----------------
-- Constructor --
-----------------

function ImageButton:New(parentGroup, image, tapHandler, downImage)
	local imageButton = {}
	setmetatable(imageButton, mt)
	imageButton.displayGroup = display.newGroup()
	parentGroup:insert(imageButton.displayGroup)

	imageButton.image = display.newImage(imageButton.displayGroup, image)
    if downImage ~= nil then
        imageButton.downImage = display.newImage(imageButton.displayGroup, downImage)
        imageButton.downImage.isVisible = false
    end
	
	imageButton.tapHandler = tapHandler
	imageButton.displayGroup:addEventListener("touch", imageButton)
	
	return imageButton
end

----------------------
-- Instance Methods --
----------------------

function ImageButton:touch(event)
    if event.phase == "began" then
        self.touched = true
        if self.downImage ~= nil then
            self.downImage.isVisible = true
            self.image.isVisible = false

            local function RevertImage()
                self.image.isVisible = true
                self.downImage.isVisible = false
            end
            timer.performWithDelay(150, RevertImage)
        end
		self.startX = event.x
		self.startY = event.y
    elseif event.phase == "ended"  then
        if self.touched == true then
            --if self.downImage ~= nil then
            --    self.image.isVisible = true
            --    self.downImage.isVisible = false
            --end
			
			if abs(self.startX - event.x) < 50 and abs(self.startY - event.y) < 50 then
				self:tapHandler(event)
			end
        end
    end

    return true
end

function ImageButton:SetPos(x, y)
	self.displayGroup.x = x - self.displayGroup.width * 0.5
	self.displayGroup.y = y - self.displayGroup.height * 0.5
end

function ImageButton:CleanUp()
	--self.displayGroup:removeEventListener("tap", self.tapHandler)
    self.displayGroup:removeSelf()
    self.displayGroup = nil
end

return ImageButton