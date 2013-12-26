require "block"

BLOCK_TYPE_GRASS = 1
BLOCK_TYPE_ROCK = 2

Terrain = {}
Terrain.__index = Terrain

-- make an accompanying terrain creation tool
-- that writes a file that can be read by the terrain manager and drawn in game
function Terrain.create(grid, x, y, size)
   local terr = {}             -- our new object
   setmetatable(terr,Terrain)  -- make Account handle lookup
   terr.x = x
   terr.y = y
   terr.size = size
   terr.grid = {}
   terr.grid = grid

   return terr
end

function Terrain:draw()	

	grid = self.grid 

	-- set up default tile type
	tile = love.graphics.newImage("grass.png")

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
	         		self.x + ((y-x) * (tile:getWidth() / 2)),
	            	self.y + ((x+y) * (tile:getHeight() / 4)) - ((tile:getHeight() / 2) * (table.getn(grid) / 2)) - (tile:getHeight() / 2)*i)
	  			end
	  			-- restore original tile type
	  			tile = tempTile
	  		end 

	  		-- draw block
	  		love.graphics.draw(tile,
	            	self.x + ((y-x) * (tile:getWidth() / 2)),
	            	self.y + ((x+y) * (tile:getHeight() / 4)) - ((tile:getHeight() / 2) * (table.getn(grid) / 2)) - (tile:getHeight() / 2)*grid[x][y].height)
	   end
	end
end