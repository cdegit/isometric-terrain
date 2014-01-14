Avatar = {}
Avatar.__index = Avatar

-- User will be able to use or extend Avatar class to place objects on the Terrain
-- Terrain will have a function to add a new avatar to it
-- Terrain will call Avatar's draw function; Avatar decides how it's drawn but not when
function Avatar.create(imageName, x, y, height)
   	local av = {}             -- our new object
   	setmetatable(av, Avatar)  -- make Avatar handle lookup

   	av.x = x
   	av.y = y

   	av.height = height

   	-- TODO: create a generic sprite for this
   	av.sprite = love.graphics.newImage(imageName)
   	-- will also want different sprites depending on their orientation, and when the Terrain is rotated

   	return av
end

function Avatar:draw(x, y)
	-- don't draw based on self.x and self.y, but the coordinates given by the Terrain
	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.draw(self.sprite, 0, 0)
	--love.graphics.rectangle("fill", 0, 0, 30, 30)
	love.graphics.pop()
end

-- dx and dy are the displacement on the grid
function Avatar:move(dx, dy)
   self.x = self.x + dx
   self.y = self.y + dy
end