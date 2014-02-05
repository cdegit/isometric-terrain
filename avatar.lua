require("AnAL")

Avatar = {}
Avatar.__index = Avatar

-- User will be able to use or extend Avatar class to place objects on the Terrain
-- Terrain will have a function to add a new avatar to it
-- Terrain will call Avatar's draw function; Avatar decides how it's drawn but not when
-- Maybe when loading in avatars, check if they have any animation names stored after the default image name
function Avatar.create(imageName, x, y, height)
   	local av = {}             -- our new object
   	setmetatable(av, Avatar)  -- make Avatar handle lookup

      av.id = 0

   	av.x = x
   	av.y = y

   	av.height = height

      av.imgName = imageName
   	av.sprite = love.graphics.newImage(imageName)
   	-- will also want different sprites depending on their orientation, and when the Terrain is rotated

      -- associative array, name of animation as key, animation object as val
      av.animations = {}
      av.activeAnimation = ""

      -- should change to false
      av.animating = false

      av.jumpLimit = 1
   	return av
end

function Avatar:update(dt)
   -- update all animations in animations
   for key, value in pairs(self.animations) do
      local animation = value
      animation:update(dt)
   end
end

function Avatar:draw(x, y)
	-- don't draw based on self.x and self.y, but the coordinates given by the Terrain
	love.graphics.push()
	love.graphics.translate(x, y)

   if self.activeAnimation ~= "" and self.animating then
      -- draw active animation
      local currentAnim = self.animations[self.activeAnimation]
      currentAnim:draw(0, 0)
   else 
      -- if no animation, just draw the sprite
	   love.graphics.draw(self.sprite, 0, 0)
   end
	love.graphics.pop()
end

-- dx and dy are the displacement on the grid
function Avatar:move(dx, dy)
   self.x = self.x + dx
   self.y = self.y + dy
end

-- Accepts animation object itself, allows the user to configure things without us having to pass params
function Avatar:addAnimation(name, animation)
   -- check if an animation with this name already exists
   if self:animationExists(name) then
      return false
   end

   self.animations[name] = animation

   -- if this is the first animation added, it is active
   if self.activeAnimation == "" then
      self.activeAnimation = name
   end
end

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

-- for now, add function to save animations here
-- in the end, will probably be done in isoTerrain or something, once animations are working for blocks too
-- TODO: get name of the spritesheet, get delay. For now maybe just assume a default delay and write that. 
function Avatar:saveAnimations(filename)
   file = love.filesystem.newFile(filename)
   file:open("w")

   for key, value in pairs(self.animations) do
      -- write name of animation, spritesheet, framesize, speed
      local animation = value
      file:write(key)
      file:write(" ")
      --file:write(animation.image) -- image name. Could also just get the image data as a string, I guess, but that's super gross. 
      -- could also enforce that name of animation is same as name of file
      file:write(" ")
      file:write(animation.fw)
      file:write(" ")
      file:write(animation.fh)
      file:write(" ")
      file:write("0.1") -- default animation speed for now
      file:write(" ")
      file:write("") -- number of frames
      -- maybe also include mode? 

      -- one record per line
      file:write("\n")
   end

   file:close()
end
