require "block"
require "avatar"

BLOCKTYPE = {["empty"] = 0, ["grass"] = 1, ["rock"] = 2, ["blueprint"] = 3} -- allows you to easily create the new block based on name
BLOCKFILE = {[1] = "grass.png", [2] = "dirt.png", [3] = "blueprint.png"}		 -- stores the file names for the blocks to be drawn

Terrain = {}
Terrain.__index = Terrain

-- make an accompanying terrain creation tool
-- that writes a file that can be read by the terrain manager and drawn in game
function Terrain.create(grid, x, y)
   	local terr = {}             -- our new object
   	setmetatable(terr,Terrain)  -- make Terrain handle lookup
   	terr.x = x
   	terr.y = y

   	terr.grid = {}
   	terr.grid = grid
   	terr.selected = {0, 0}

   	terr.avatarModel = {}

   	return terr
end

function Terrain:draw()	
	grid = self.grid 

	-- set up default tile type
	tile = love.graphics.newImage("grass.png")

	love.graphics.push()
	love.graphics.translate(self.x, self.y)
	love.graphics.setLineWidth(3)

	for x = 1,table.getn(grid) do
	   for y = 1,table.getn(grid[1]) do
	   		block = grid[x][y]
	   		
	   		empty = false
	    	
	   		if grid[x][y].type == BLOCKTYPE["empty"] then
	      		empty = true
	    	else 
	    		local tempType = grid[x][y].type
	    		tile = love.graphics.newImage(BLOCKFILE[tempType])
	    	end

	      	-- draw block
	  		if grid[x][y].height >= 1 then
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

	  		if empty == false then
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
	end
	self:drawAvatars()
	love.graphics.pop()
end

function Terrain:drawAvatars()
	for i = 1, table.getn(self.avatarModel) do
		local avatar = self.avatarModel[i]
		avatar:draw((avatar.y - avatar.x) * (BLOCK_WIDTH / 2), 
			((avatar.x+avatar.y) * (BLOCK_IMGHEIGHT / 4)) - ((BLOCK_IMGHEIGHT / 2) * (table.getn(self.grid) / 2)) - (BLOCK_IMGHEIGHT / 2)* (self.grid[avatar.x][avatar.y].height + avatar.height))
	end
end

function Terrain:loadGrid(fileName)
	file = love.filesystem.newFile(fileName)
	file:open("r")

	grid = {}

	data = {}
	splitData = {}

	j = 1
	for line in file:lines() do
		data[j] = line
		j = j + 1
	end

	for key, value in pairs(data) do
		grid[key] = {}
		splitData[key] = {}
		splitData[key] = string.split(value, ",")

		for k, v in pairs(splitData[key]) do
			splitData[key][k] = {}
			splitData[key][k] = string.split(v, " ")

			for a, b in pairs(splitData[key][k]) do
				bl = Block.create(tonumber(splitData[key][k][1]), tonumber(splitData[key][k][2])) 
				grid[key][k] = bl

				-- key and k are x and y respectively, so look at those
			end
		end
	end

	-- TODO: ensure that the grid built is always of equal width and height to avoid hell bug
	-- Or fix hell bug

	self.grid = grid

	file:close()
end

-- saves instance's grid to a file with the given name
-- this file is saved in the game's save directory 
function Terrain:saveGrid(fileName)
	file = love.filesystem.newFile(fileName)
	file:open("w")
	
	for x = 1, table.getn(self.grid) do
		for y = 1, table.getn(self.grid[1]) do
			file:write(self.grid[x][y].type)
			file:write(" ")
			file:write(self.grid[x][y].height)
			if y ~= table.getn(self.grid[1]) then
				file:write(",")
			end
		end
		if x ~= table.getn(self.grid) then
			file:write("\n")
		end
	end
	
	file:close()
end

-- In future, have both Grid and Avatars written to same file maybe? Two lines in between to separate?
function Terrain:saveAvatars(filename)
	file = love.filesystem.newFile(filename)
	file:open("w")

	for i = 1, table.getn(self.avatarModel) do
		-- write filename, x and y, height. Add other attributes later.
		local avatar = self.avatarModel[i]
		file:write(avatar.imgName)
		file:write(" ")
		file:write(avatar.x)
		file:write(" ")
		file:write(avatar.y)
		file:write(" ")
		file:write(avatar.height)

		-- one record per line
		file:write("\n")
	end

	file:close()
end

function Terrain:addBlock(x, y, blockType, height)
	-- check if x and y are already within the bounds of the grid
	if x >= 1 and x <= table.getn(self.grid) and y >= 1 and y <= table.getn(self.grid[1]) then
			-- if this is the case, only replace the existing block if the height or type is different
			if height ~= self.grid[x][y].height or blockType ~= self.grid[x][y].type then
				self.grid[x][y] = Block.create(blockType, height)
			end
	end

	-- Old code when adding new columns and rows was allowed
		-- add new columns
		--[[local newGrid = {}
		for gx = 1, math.max(table.getn(self.grid), x) do
			newGrid[gx] = {}
			for gy = 1, math.max(table.getn(self.grid[1]), y) do
				if (gx <= table.getn(self.grid)) and (gy <= table.getn(self.grid[1])) then -- if exists already, just transfer
					newGrid[gx][gy] = self.grid[gx][gy]
				elseif gx == x and gy == y then -- if we're on the new block we want to add
					newGrid[gx][gy] = Block.create(blockType, height)
				else
					newGrid[gx][gy] = Block.create(0, 0)
				end
			end
		end
		self.grid = newGrid
		--self:recenter() ]]
end

function Terrain:removeBlock(x, y)
	if x >= 1 and x <= table.getn(self.grid) and y >= 1 and y <= table.getn(self.grid[1]) then
		self.grid[x][y] = Block.create(BLOCKTYPE["empty"], 0)
	end
end

function Terrain:addBlockType(name, fileName)
	-- first, check if file exists
	-- provide user with an error if not

	if love.filesystem.isFile(fileName) == false then
		return false
	end

	-- append to BLOCKTYPE and BLOCKFILE
	-- number will be current size + 1

	local number = table.getn(BLOCKFILE) + 1
	BLOCKTYPE[name] = number
	BLOCKFILE[number] = fileName

	return true
end

function Terrain:clickCheckHeight()
	if table.getn(self.grid) == 0 then
		return
	end
  	-- make sure we don't get out of bounds results
  	if self.selected[1] < 1 or self.selected[1] > table.getn(self.grid) then
  		return
  	elseif self.selected[2] < 1 or self.selected[2] > table.getn(self.grid[1]) then
  		return
  	end
  	
  	--self.selected[1] = math.clamp(self.selected[1], 1, table.getn(self.grid))
  	--self.selected[2] = math.clamp(self.selected[2], 1, table.getn(self.grid[1]))

	diffX = table.getn(self.grid) - self.selected[1]
	diffY = table.getn(self.grid[1]) - self.selected[2]
	diff = math.min(diffX, diffY)

	-- check if a tile overlaps the currently selected tile; will overlap if its height is equal to its x AND y distance from current
	for i = 1, diff do
		if self.grid[self.selected[1] + i][self.selected[2] + i].height == i then
			self.selected[1] = self.selected[1] + i
			self.selected[2] = self.selected[2] + i
			break
		end 
	end
end

function Terrain:rotate(angle)
	-- want to rotate the underlying array, then drawing should take care of everything
	-- initialize the new grid so we have something to work with
	newGrid = {}
	for i = 1, table.getn(self.grid[1]) do
		newGrid[i] = {}
		for j = 1, table.getn(self.grid) do
			newGrid[i][j] = 0 
		end
	end

	for x = 1, table.getn(self.grid) do
		for y = 1, table.getn(self.grid[1]) do
			mat = {x, y, 1} -- matrix representing current index
			c = math.round(math.cos(math.pi/2))
			s = math.round(math.sin(math.pi/2))

			rotMat = {}
			if (angle == "left") then
				rotMat = {{c, s, 0}, {-s, c, 0}, {0, 0, 1}}
				transMat = {{1, 0, 0}, {0, 1, table.getn(self.grid) + 1}, {0, 0, 1}}
			elseif angle == "right" then
				rotMat = {{c, -s, 0}, {s, c, 0}, {0, 0, 1}}
				transMat = {{1, 0, table.getn(self.grid[1]) + 1}, {0, 1, 0}, {0, 0, 1}}
			end

			res = self:multiplyMatrices(rotMat, mat) -- multiply the index matrix and the rotation matrix

			-- this will leave you outside of the bounds of the array
			-- use a translation matrix to return to the correct position

			res = self:multiplyMatrices(transMat, res)

			tx = res[1] -- new x index
			ty = res[2] -- new y index

			newGrid[tx][ty] = self.grid[x][y] -- take the value from the original location in grid and put it into the new grid
		end
	end

	self.grid = newGrid -- set the rotated grid to be the grid
end

function Terrain:translate(xDist, yDist)
	-- check to make sure we haven't translated too far. Don't want to be able to let the map off of the screen entirely, regardless of size.
	self.x = self.x + xDist
	self.y = self.y + yDist
end

function Terrain:multiplyMatrices(m1, m2)
	result = {}
	tempres = 0

	for i = 1, table.getn(m1) do
		for j = 1, table.getn(m1[1]) do
			tempres = tempres + m1[i][j] * m2[j]
		end
		result[i] = tempres
		tempres = 0
	end

	return result
end

-- TODO: fix bug introduced by changing center of grid (adding new blocks)
function Terrain:selectTileFromMouse(x, y)
	-- from http://laserbrainstudios.com/2010/08/the-basics-of-isometric-programming/
	-- TODO: strongly consider switching height to 1 indexed to match everything else
	x = x - (self.x + BLOCK_WIDTH) 
	y = y - (self.y - BLOCK_WIDTH) + (BLOCK_HEIGHT / 2) 

	TileX = math.floor((y / BLOCK_HEIGHT) + (x / BLOCK_WIDTH))
		TileY = math.floor((y / BLOCK_HEIGHT) - (x / BLOCK_WIDTH))

		self.selected = {TileY, TileX + 1}
		self:clickCheckHeight()
end

function Terrain:addAvatar(avatar)
	table.insert(self.avatarModel, avatar)
end

function Terrain:moveAvatar(avatar, x, y)
	for i = 1, table.getn(self.avatarModel) do
		if self.avatarModel[i] == avatar then
			self.avatarModel[i]:move(x, y)
		end
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

function math.round(input)
	lower = math.floor(input)
	if input - lower >= 0.5 then
		return math.ceil(input)
	else
		return lower
	end
end

-- from Stack Overflow: http://stackoverflow.com/questions/1426954/split-string-in-lua by krsk9999
function string:split(delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end