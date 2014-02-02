require "block"
require "avatar"

BLOCKTYPE = {["empty"] = 0, ["grass"] = 1, ["rock"] = 2, ["blueprint"] = 3} -- allows you to easily create the new block based on name
BLOCKFILE = {[1] = "grass.png", [2] = "dirt.png", [3] = "blueprint.png"}		 -- stores the file names for the blocks to be drawn

Terrain = {}
Terrain.__index = Terrain

-- TODO: will maintain the ids of the avatars.
-- user is able to get an avatar by its id

function Terrain.create(grid, x, y)
   	local terr = {}             -- our new object
   	setmetatable(terr,Terrain)  -- make Terrain handle lookup
   	terr.x = x
   	terr.y = y

   	terr.grid = {}
   	terr.grid = grid
   	terr.selected = {0, 0}

   	terr.avatarModel = {}
   	terr.currentAvatar = 0
   	terr.nextAvId = 1

   	return terr
end

function Terrain:draw()	
	grid = self.grid 

	-- set up default tile type
	tile = love.graphics.newImage("grass.png")

	if table.getn(self.avatarModel) > 0 then
		self.currentAvatar = 1
	end

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
	   		end

  			-- draw any avatars on top of the block
  			if self.currentAvatar > 0 then
	  			if self.avatarModel[self.currentAvatar].x == x and self.avatarModel[self.currentAvatar].y == y then
	  				if empty == false then
	  					local avatar = self.avatarModel[self.currentAvatar]
						avatar:draw((avatar.y - avatar.x) * (BLOCK_WIDTH / 2), 
							((avatar.x+avatar.y) * (BLOCK_IMGHEIGHT / 4)) - ((BLOCK_IMGHEIGHT / 2) * (table.getn(self.grid) / 2)) - (BLOCK_IMGHEIGHT / 2)* (self.grid[avatar.x][avatar.y].height + avatar.height))
	  				end
	  				-- still need to check and increment this, even if empty, so that we still go through the rest of the array
	  				if self.currentAvatar < table.getn(self.avatarModel) then
	  					self.currentAvatar = self.currentAvatar + 1
	  				end
	  			end
  			end

	  		if empty == false then	
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
	love.graphics.pop()
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

function Terrain:saveGridAndAvatars(gridFile, avatarFile)
	self:saveGrid(gridFile);
	self:saveAvatars(avatarFile);
end

function Terrain:loadGridAndAvatars(gridFile, avatarFile)
	self:loadGrid(gridFile);
	self:loadAvatars(avatarFile);
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

-- TODO: In future, have both Grid and Avatars written to same file maybe? Two lines in between to separate?
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

function Terrain:loadAvatars(filename)
	file = love.filesystem.newFile(filename)
	file:open("r")

	local avatars = {}

	j = 1
	for line in file:lines() do
		avatars[j] = line
		j = j + 1
	end

	-- unlike grid, each line is own avatar
	for key, value in pairs(avatars) do
		avTable = string.split(value, " ")
		av = {}

		-- create new avatar
		-- data intentionally written to file in same order as args
		av = Avatar.create(avTable[1], tonumber(avTable[2]), tonumber(avTable[3]), tonumber(avTable[4]))
		
		-- add avatar to the model
		self:addAvatar(av)
		--table.insert(self.avatarModel, av)
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

	self:rotateAvatars(angle)
end

function Terrain:rotateAvatars(angle)
	-- easiest way to maintain sort is just to readd everything
	-- so, get a copy of what is in arrayModel, then empty arrayModel and readd everything with the new coordinates
	local oldModel = self.avatarModel
	self.avatarModel = {}

	for i = 1, table.getn(oldModel) do
		local avatar = oldModel[i]
		local mat = {avatar.x, avatar.y, 1}

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

		local newAvatar = Avatar.create(avatar.imgName, tx, ty, avatar.height)
		newAvatar.id = avatar.id
		newAvatar.activeAnimation = avatar.activeAnimation
		newAvatar.animating = avatar.animating

		self:addAvatar(newAvatar)
	end
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
	-- check if the avatar has an id other equal to 0 - it's new and we need to give it a new id
	if avatar.id == 0 then
		avatar.id = self.nextAvId
		self.nextAvId = self.nextAvId + 1
	end

	-- if this is the first avatar, just add it
	if table.getn(self.avatarModel) > 0 then
		self:insertAvatarSorted(avatar)
	else -- otherwise, add at correct position to maintain sorted array
		table.insert(self.avatarModel, avatar)
	end
end

function Terrain:insertAvatarSorted(avatar)
	-- rememeber, we can assume that the current array is already sorted
	for i = 1, table.getn(self.avatarModel) do
		local current = self.avatarModel[i]
		if avatar.x == current.x then
			-- compare y's
			if avatar.y == current.y then
				table.insert(self.avatarModel, i, avatar)
				return
			elseif avatar.y < current.y then
				table.insert(self.avatarModel, i, avatar)
				return
			end
		elseif avatar.x < current.x then
			-- place here
			table.insert(self.avatarModel, i, avatar)
			return
		end -- if greater, just move on to next in loop
	end

	table.insert(self.avatarModel, avatar)
end

-- TODO: if the grid is rotated, deleting avatar. Need to write get avatar by name function. 
-- TODO: when one avatar moves onto the space occupied by another avatar, stuff breaks. We will need this later so make it work. 
-- TODO: issue when moving past other avatars by x + 1. Jumps over all the rows containing another avatar.
-- y only seems to be an issue when walking directly into them
function Terrain:moveAvatar(avatar, x, y)
	-- make sure we're only accepting integer input
	x = math.floor(x)
	y = math.floor(y)

	for i = 1, table.getn(self.avatarModel) do
		if self.avatarModel[i] == avatar then

			-- ensure that x and y are within the bounds of the grid
			--if self.avatarModel[i].x + x < 1 or self.avatarModel[i].x + x > table.getn(self.grid) or self.avatarModel[i].y + y < 1 or self.avatarModel[i].y + y > table.getn(self.grid[1]) then
			--	return
			--end

			if not self:withinGridBounds(self.avatarModel[i].x + x, self.avatarModel[i].y + y) then
				return
			end

			-- make sure that this block is actually at a height that the avatar can move to
			-- and that they are adjacent. Avatars will be able to move in a path later. 
			if math.abs(x) <= 1 and math.abs(y) <= 1 then -- check adjacent
				local currentLocation = self.grid[self.avatarModel[i].x][self.avatarModel[i].y]
				if math.abs(self.grid[self.avatarModel[i].x + x][self.avatarModel[i].y + y].height - currentLocation.height) <= self.avatarModel[i].jumpLimit then -- check jump distance
					self.avatarModel[i]:move(x, y)

					-- to maintain sort, should actually remove and readd avatar
					local tempAvatar = self.avatarModel[i]
					table.remove(self.avatarModel, i)
					self:addAvatar(tempAvatar)
				end
			end
		end
	end
end

-- returns the avatar, which can then be used to move it
-- will be used to fix the issue with rotating messing with avatar movement
function Terrain:getAvatarById(id) 
	if id > table.getn(self.avatarModel) then
		return false
	end

	for i = 1, table.getn(self.avatarModel) do
		local av = self.avatarModel[i]
		if av.id == id then
			return av
		end
	end
end

function Terrain:withinGridBounds(x, y) 
	return x >= 1 and x <= table.getn(self.grid) and y >= 1 and y <= table.getn(self.grid[1])
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
