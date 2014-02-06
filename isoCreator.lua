require "dialog"

IsoCreator = {}
IsoCreator.__index = IsoCreator

function IsoCreator.create()
  local iso = {}             -- our new object
  setmetatable(iso,IsoCreator) 

  iso.blockTypesX = 0
  iso.blockTypesY = 0

  iso.rotateButtonsX = 650
  iso.rotateButtonsY = 130

  iso.rotL = love.graphics.newImage("rotateLeft.png")
  iso.rotR = love.graphics.newImage("rotateRight.png")

  iso.currentType = BLOCKTYPE["grass"] -- default type when creating blocks

  iso.blueprint = {}
  iso.newTerrain = {}

  iso.creatingBlock = false

  iso.blueprintVisible = true

  iso.addBlockTypeVisible = false

  iso.dialog = {}

  iso.promptVisible = true

  iso.startScreen = false

  return iso
end


function IsoCreator:creatorLoad()
  self.dialog = Dialog.create("addBlockType", love.graphics.getWidth()/2 - 130, love.graphics.getHeight()/2 - 75)

	self.blueprint = Terrain.create(self:makeGrid("blueprint", 7, 7), 300, 228)
  self.blueprintVisible = false
  self.newTerrain = Terrain.create(self:makeGrid("grass", 7, 7), 300, 228)
end

-- Prompt the user to either load an existing file to edit, or create a new one
function IsoCreator:loadPrompt()
  -- draw a simple dialog box with two buttons, no text boxes
end

function IsoCreator:draw()
  if self.startScreen then
    -- display the start screen and don't draw anything behind it
    -- draw a dialog, prompt the user to either load grid and avatar files or create a new terrain

    return
  end

  self:drawTerrains()
  self:drawBlockTypes()
  self:drawRotateButtons()

  if self.creatingBlock then
    self:updateBlockHeight()
  end

  if self.dialog.visible then
    self.dialog:draw()
  end

  if self.promptVisible then
    self:loadPrompt()
  end
end

function IsoCreator:startNew()
  self.blueprint = Terrain.create(self:makeGrid("blueprint", 7, 7), 300, 228)
  self.blueprintVisible = true
  self.newTerrain = Terrain.create(self:makeGrid("empty", 7, 7), 300, 228)  
end

function IsoCreator:loadExisting()
  -- draw a new dialog prompting the user to enter the file names for avatars and grid
end

-- draws 2 terrains: the blueprint terrain and the actual terrain being built
function IsoCreator:drawTerrains()
  self.newTerrain:draw()
  if self.blueprintVisible then
   self.blueprint:draw()
  end
end

function IsoCreator:mousepressed(x, y, button)
  if self.startScreen then
    -- check for mouse events on start screen only
    return
  end

  -- if the dialog is being displayed, disable mouse clicks on the background
  -- this stops the user from accidentally creating or deleting blocks
  if self.dialog.visible then
    self.dialog:mousepressed(x, y)
    return
  end

  self:clickBlockTypes(x, y)
	self.blueprint:selectTileFromMouse(x, y)

  if button == "l" then 
    self.creatingBlock = true
    self.newTerrain:addBlock(self.blueprint.selected[1], self.blueprint.selected[2], self.currentType, 0)
  else
    self.creatingBlock = false
    self.newTerrain:removeBlock(self.blueprint.selected[1], self.blueprint.selected[2])
  end

  self:clickRotateButtons(x, y)
end

function IsoCreator:updateBlockHeight()
  -- get original height from blueprint.selected
  -- for every amount greater than the height by BLOCK_HEIGHT
  -- increment height of block
  -- on release, stop changing it
  local y = love.mouse.getY()
  local bx = self.blueprint.selected[1]
  local by = self.blueprint.selected[2]

-- need to take into account offset
  local blockY = self.blueprint.y + (bx+by) * (BLOCK_IMGHEIGHT / 4) - ((BLOCK_IMGHEIGHT / 2) * (table.getn(self.blueprint.grid) / 2)) - (BLOCK_IMGHEIGHT / 2)*0

  local height = math.floor((blockY - y) / BLOCK_HEIGHT)

  -- restrict to positive height only
  if height < 0 then
    height = 0
  end

  self.newTerrain:addBlock(self.blueprint.selected[1], self.blueprint.selected[2], self.currentType, height)
end

function IsoCreator:mousereleased(x, y, button)
  self.creatingBlock = false
end

function IsoCreator:keypressed(key, unicode)
  self.dialog:keypressed(key, unicode)
end

function IsoCreator:drawRotateButtons()
  love.graphics.push()
  love.graphics.translate(self.rotateButtonsX, self.rotateButtonsY)
  love.graphics.draw(self.rotL, 0, 0)
  love.graphics.draw(self.rotR, self.rotL:getWidth(), 0)
  love.graphics.pop()
end

function IsoCreator:clickRotateButtons(x, y)
  -- y is shared, so check that first
  if y >= self.rotateButtonsY and y <= self.rotateButtonsY + self.rotL:getHeight() then

    -- if clicking rotL
    if x >= self.rotateButtonsX and x <= self.rotateButtonsX + self.rotL:getWidth() then
      self.blueprint:rotate("left")
      self.newTerrain:rotate("left")
    end

    -- if clicking rotR
     if x >= self.rotateButtonsX + self.rotL:getWidth() and x <= self.rotateButtonsX + (self.rotL:getWidth() * 2) then
      self.blueprint:rotate("right")
      self.newTerrain:rotate("right")
    end   
  end
end

function IsoCreator:drawBlockTypes()
  love.graphics.push()
  love.graphics.translate(self.blockTypesX, self.blockTypesY)
  love.graphics.scale(0.5, 0.5)

  for k, v in pairs(BLOCKFILE) do
    local block = love.graphics.newImage(v)
    love.graphics.draw(block, BLOCK_WIDTH*(k-1), 0)

    if k == self.currentType then
      local width = love.graphics.getLineWidth()
      local r, g, b, a = love.graphics.getColor()

      love.graphics.setLineWidth(3)
      love.graphics.setColor(255, 255, 255)

      love.graphics.line(BLOCK_WIDTH*(k-1), 70, BLOCK_WIDTH*k, 70)

      love.graphics.setLineWidth(width)
      love.graphics.setColor(r, g, b, a)
    end
  end

  local add = love.graphics.newImage("addnew.png")
  love.graphics.draw(add, table.getn(BLOCKFILE) * BLOCK_WIDTH, 0)

  love.graphics.pop()
end

function IsoCreator:clickBlockTypes(x, y)
 for k,v in pairs(BLOCKFILE) do
  if x >= self.blockTypesX + BLOCK_WIDTH*(k-1)/2 and x <= self.blockTypesX + BLOCK_WIDTH*k/2 then
    if y >= self.blockTypesY and y <= self.blockTypesY + BLOCK_IMGHEIGHT/2 then
      self.currentType = k
    end
  end
 end

 -- if click on the add new button
  if x >= self.blockTypesX + BLOCK_WIDTH*table.getn(BLOCKFILE)/2 and x <= self.blockTypesX + BLOCK_WIDTH*table.getn(BLOCKFILE) then
    if y >= self.blockTypesY and y <= self.blockTypesY + BLOCK_IMGHEIGHT/2 then
      -- open dialog to add a new block type
      self.dialog.visible = true
    end
  end
end

-- simple function to generate a uniform grid
function IsoCreator:makeGrid(type, width, height)
  local grid = {}
  local yempty = 0
  local xempty = 0

  if width > height then
    yempty = width - height
  elseif height > width then
    xempty = height - width
  end

  for x = 1, width + xempty do
    grid[x] = {}
    for y = 1, height + yempty do
      if y > height or x > width then
        grid[x][y] = Block.create(BLOCKTYPE["empty"], 0)
      else
        grid[x][y] = Block.create(BLOCKTYPE[type], 0)
      end
    end
  end

  return grid
end

function IsoCreator:makeRandomGrid(width, height)
  local grid = {}
  local yempty = 0
  local xempty = 0

  if width > height then
    yempty = width - height
  elseif height > width then
    xempty = height - width
  end

  for x = 1, width + xempty do
    grid[x] = {}
    for y = 1, height + yempty do
      if y > height or x > width then
        grid[x][y] = Block.create(BLOCKTYPE["empty"], 0)
      else
        -- select a random block type and height 
        local randomType = math.random(table.getn(BLOCKFILE))
        local randomHeight = math.random(5) -- arbitrary max height
        grid[x][y] = Block.create(randomType, randomHeight)
      end
    end
  end

  return grid
end

function IsoCreator:makeSmartRandomGrid(width, height)
  local grid = {}
  local yempty = 0
  local xempty = 0

  if width > height then
    yempty = width - height
  elseif height > width then
    xempty = height - width
  end

  local lastHeight = 0

  for x = 1, width + xempty do
    grid[x] = {}
    for y = 1, height + yempty do
      if y > height or x > width then
        grid[x][y] = Block.create(BLOCKTYPE["empty"], 0)
      else
        -- select a random block type and height 
        -- ensure that the height of a block is no more than 1 away from the block prior to it
        local randomType = math.random(table.getn(BLOCKFILE))
        local randomHeight = math.random(lastHeight - 1, lastHeight + 1)
        randomHeight = math.max(0, randomHeight)

        local besideHeight = 0

        if x > 1 then
          besideHeight = grid[x - 1][y].height
        
          if randomHeight > besideHeight + 2 then
            randomHeight = besideHeight + 1
          elseif randomHeight < besideHeight - 2 then
            randomHeight = besideHeight - 1
          end
        end



        grid[x][y] = Block.create(randomType, randomHeight)
        lastHeight = randomHeight
      end
    end
  end

  return grid
end