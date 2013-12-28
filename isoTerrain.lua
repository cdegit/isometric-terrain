require "block"

BLOCK_TYPE_GRASS = 1
BLOCK_TYPE_ROCK = 2

selectedX = 0
selectedY = 0

offsetX = 0
offsetY = 0

Terrain = {}
Terrain.__index = Terrain

-- make an accompanying terrain creation tool
-- that writes a file that can be read by the terrain manager and drawn in game
function Terrain.create(grid, x, y)
   local terr = {}             -- our new object
   setmetatable(terr,Terrain)  -- make Account handle lookup
   terr.x = x
   terr.y = y
   terr.grid = {}
   terr.grid = grid
   terr.selected = {}

   offsetX = x
   offsetY = y - BLOCK_WIDTH

   return terr
end

function Terrain:draw()	
	grid = self.grid 
	self:clickCheckHeight() -- check if the currently selected block is actually overlapped by another
	self.selected = {selectedX, selectedY}

	-- set up default tile type
	tile = love.graphics.newImage("grass.png")

	love.graphics.push()
	love.graphics.translate(self.x, self.y)
	love.graphics.setLineWidth(3)

	for x = 1,table.getn(grid) do
	   for y = 1,table.getn(grid[1]) do
	   		block = grid[x][y]
	    	if block.type == BLOCK_TYPE_GRASS then
	      		-- set image to be drawn
	      		tile = love.graphics.newImage("grass.png")
	    	elseif grid[x][y].type == BLOCK_TYPE_ROCK then
	      		tile = love.graphics.newImage("dirt.png")
	    	end

	      	-- draw block
	  		if grid[x][y].height > 1 then
	  			-- draw blocks under top
	  			-- store previous tile type
	  			tempTile = tile 
	  			-- draw tiles under top as the default "underground" tile
	  			tile = love.graphics.newImage("dirt.png")
	  			
	  			-- draw all blocks under the height of the current block (so it doesn't float)
	  			for i=0, (grid[x][y].height - 1) do
				love.graphics.draw(tile,
	         		((y-x) * (tile:getWidth() / 2)),
	            	((x+y) * (tile:getHeight() / 4)) - ((tile:getHeight() / 2) * (table.getn(grid) / 2)) - (tile:getHeight() / 2)*i)
	  			end
	  			-- restore original tile type
	  			tile = tempTile
	  		end 

	  		-- draw block
	  		love.graphics.draw(tile,
	            	((y-x) * (tile:getWidth() / 2)),
	            	((x+y) * (tile:getHeight() / 4)) - ((tile:getHeight() / 2) * (table.getn(grid) / 2)) - (tile:getHeight() / 2)*grid[x][y].height)
	   
	  		-- if this block is selected, draw a white quad to indicate selection
	  		-- TODO: animate, slowly flash
	  		if x == self.selected[1] and y == self.selected[2] then
	  			love.graphics.push()
	  			love.graphics.translate((y-x) * (tile:getWidth() / 2), ((x+y) * (tile:getHeight() / 4)) - ((tile:getHeight() / 2) * (table.getn(grid) / 2)) - (tile:getHeight() / 2)*grid[x][y].height)
	  			love.graphics.quad("line", 0, (BLOCK_HEIGHT / 2), BLOCK_HEIGHT, 0, BLOCK_WIDTH, (BLOCK_HEIGHT / 2), BLOCK_HEIGHT, BLOCK_HEIGHT)
	  			love.graphics.pop()

				
	  		end
	   end
	end
	love.graphics.pop()
end

function Terrain:clickCheckHeight()

  	-- make sure we don't get out of bounds results
  	selectedX = math.clamp(selectedX, 1, table.getn(self.grid))
  	selectedY = math.clamp(selectedY, 1, table.getn(self.grid[1]))

	diffX = table.getn(self.grid) - selectedX
	diffY = table.getn(self.grid[1]) - selectedY
	diff = math.min(diffX, diffY)

	-- check if a tile overlaps the currently selected tile; will overlap if its height is equal to its x AND y distance from current
	for i = 1, diff do
		if self.grid[selectedX + i][selectedY + i].height == i then
			selectedX = selectedX + i
			selectedY = selectedY + i
			break
		end 
	end
end 

function love.mousepressed(x, y, button)
	if button == "l" then
		
		-- from http://laserbrainstudios.com/2010/08/the-basics-of-isometric-programming/
		-- TODO: strongly consider switching height to 1 indexed to match everything else
		x = x - (offsetX + BLOCK_WIDTH) 
		y = y - offsetY + (BLOCK_HEIGHT / 2) 

		TileX = math.floor((y / BLOCK_HEIGHT) + (x / BLOCK_WIDTH))
  		TileY = math.floor((y / BLOCK_HEIGHT) - (x / BLOCK_WIDTH))

  		selectedX = TileY
  		selectedY = TileX + 1
    end
end


-- Utility Functions

-- from http://www.programmer-tutorials.com/lua-tutorial-clamp-number-inbetween-ranges/
function math.clamp(input, min_val, max_val)
	if input < min_val then
		input = min_val
	elseif input > max_val then
		input = max_val
	end
	return input
end