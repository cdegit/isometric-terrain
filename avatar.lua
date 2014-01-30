Avatar = {}
Avatar.__index = Avatar

-- User will be able to use or extend Avatar class to place objects on the Terrain
-- Terrain will have a function to add a new avatar to it
-- Terrain will call Avatar's draw function; Avatar decides how it's drawn but not when
function Avatar.create(imageName, x, y, height)
   	local av = {}             -- our new object
   	setmetatable(av, Avatar)  -- make Avatar handle lookup

      av.id = 0

   	av.x = x
   	av.y = y

   	av.height = height

      av.imgName = imageName
   	-- TODO: create a generic sprite for this
   	av.sprite = love.graphics.newImage(imageName)
   	-- will also want different sprites depending on their orientation, and when the Terrain is rotated

      -- associative array, name of animation as key, set of frames as value
      av.animations = {}
      av.activeAnimation = ""

      av.currentFrameNumber = 1
      av.currentFrame = love.graphics.newImage(imageName)
      av.counter = 30

      av.animating = true
      -- want a set of sprites for each direction - store seperately or as 2D array?
      -- add an animation and give it a name, providing it with a set of file names? 

      av.jumpLimit = 1
   	return av
end

function Avatar:draw(x, y)
	-- don't draw based on self.x and self.y, but the coordinates given by the Terrain
	love.graphics.push()
	love.graphics.translate(x, y)

   if self.activeAnimation ~= "" and self.animating then
      if self.counter <= 0 then
         -- change frame number
         local anim = self.animations[self.activeAnimation]
         if self.currentFrameNumber == table.getn(anim) then
            -- wrap around to first frame
            self.currentFrameNumber = 1
         else 
            -- increment frame
            self.currentFrameNumber = self.currentFrameNumber + 1
         end

         -- load new frame image
         self.currentFrame = anim[self.currentFrameNumber]
         
         -- reset counter  
         self.counter = 30

      end

      self.counter = self.counter - 1
   end

	love.graphics.draw(self.currentFrame, 0, 0)
	
	love.graphics.pop()
end

-- dx and dy are the displacement on the grid
function Avatar:move(dx, dy)
   self.x = self.x + dx
   self.y = self.y + dy
end

-- TODO: should be able to set frame rate for each animation
-- Also, should probably make new class for that. Do that later. 
-- Will also allow for animations on blocks!
function Avatar:addAnimation(name, frames)
   -- check if an animation with this name already exists
   if self:animationExists(name) then
      return false
   end

   -- frames is a set of file names
   -- we want to store the actual love images to reduce file IO
   local frameImgs = {}
   for i = 1, table.getn(frames) do
      local frame = love.graphics.newImage(frames[i])
      table.insert(frameImgs, frame)
   end

   self.animations[name] = frameImgs

   -- if this is the first animation added, it is active
   if self.activeAnimation == "" then
      self.activeAnimation = name
   end
end

-- don't have a function to draw the animation directly, as it will be handled in draw
function Avatar:chooseActiveAnimation(name)
   if animationExists(name) then
      self.activeAnimation = name
   end
end

function Avatar:animationExists(name)
   for key, value in pairs(self.animations) do
      if key == name then
         return true
      end
   end
   return false
end

function Avatar:stopActiveAnimation()
   self.animating = false
end

function Avatar:startActiveAnimation()
   self.animating = true
end