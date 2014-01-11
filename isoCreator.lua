require "dialog"

-- TODO: make into proper class, more independant of main

blockTypesX = 0
blockTypesY = 0

rotateButtonsX = 650
rotateButtonsY = 130

rotL = love.graphics.newImage("rotateLeft.png")
rotR = love.graphics.newImage("rotateRight.png")

currentType = BLOCKTYPE["grass"] -- default type when creating blocks

blueprint = {}
newTerrain = {}

creatingBlock = false

blueprintVisible = true

addBlockTypeVisible = false

dialog = {}

function creatorLoad()
  dialog = Dialog.create(love.graphics.getWidth()/2 - 130, love.graphics.getHeight()/2 - 75)

	blueprint = Terrain.create(makeGrid("blueprint", 7, 7), 300, 228)
  newTerrain = Terrain.create(makeGrid("empty", 7, 7), 300, 228)
end

function creatorDraw()
  drawTerrains()
  drawBlockTypes()
  drawRotateButtons()

  if creatingBlock then
    updateBlockHeight()
  end

  if dialog.visible then
    dialog:draw()
  end
end

-- draws 2 terrains: the blueprint terrain and the actual terrain being built
function drawTerrains()
  newTerrain:draw()
  if blueprintVisible then
    blueprint:draw()
  end
end

function creatorMousepressed(x, y, button)
  -- if the dialog is being displayed, disable mouse clicks on the background
  -- this stops the user from accidentally creating or deleting blocks
  if dialog.visible then
    dialog:mousepressed(x, y)
    return
  end

  clickBlockTypes(x, y)
	blueprint:selectTileFromMouse(x, y)

  if button == "l" then 
      creatingBlock = true
      newTerrain:addBlock(blueprint.selected[1], blueprint.selected[2], currentType, 0)
  else
      creatingBlock = false
      newTerrain:removeBlock(blueprint.selected[1], blueprint.selected[2])
  end

  clickRotateButtons(x, y)
end

function updateBlockHeight()
  -- get original height from blueprint.selected
  -- for every amount greater than the height by BLOCK_HEIGHT
  -- increment height of block
  -- on release, stop changing it
  local y = love.mouse.getY()
  local bx = blueprint.selected[1]
  local by = blueprint.selected[2]

-- need to take into account offset
  local blockY = blueprint.y + (bx+by) * (BLOCK_IMGHEIGHT / 4) - ((BLOCK_IMGHEIGHT / 2) * (table.getn(blueprint.grid) / 2)) - (BLOCK_IMGHEIGHT / 2)*0

  local height = math.floor((blockY - y) / BLOCK_HEIGHT)

  -- restrict to positive height only
  if height < 0 then
    height = 0
  end

  newTerrain:addBlock(blueprint.selected[1], blueprint.selected[2], currentType, height)
end

function creatorMousereleased(x, y, button)
  creatingBlock = false
end

function creatorKeypressed(key, unicode)
  dialog:keypressed(key, unicode)
end

function drawRotateButtons()
  love.graphics.push()
  love.graphics.translate(rotateButtonsX, rotateButtonsY)
  love.graphics.draw(rotL, 0, 0)
  love.graphics.draw(rotR, rotL:getWidth(), 0)
  love.graphics.pop()
end

function clickRotateButtons(x, y)
  -- y is shared, so check that first
  if y >= rotateButtonsY and y <= rotateButtonsY + rotL:getHeight() then

    -- if clicking rotL
    if x >= rotateButtonsX and x <= rotateButtonsX + rotL:getWidth() then
      blueprint:rotate("left")
      newTerrain:rotate("left")
    end

    -- if clicking rotR
     if x >= rotateButtonsX + rotL:getWidth() and x <= rotateButtonsX + (rotL:getWidth() * 2) then
      blueprint:rotate("right")
      newTerrain:rotate("right")
    end   
  end
end

function drawBlockTypes()
  love.graphics.push()
  love.graphics.translate(blockTypesX, blockTypesY)
  love.graphics.scale(0.5, 0.5)

  for k, v in pairs(BLOCKFILE) do
    local block = love.graphics.newImage(v)
    love.graphics.draw(block, BLOCK_WIDTH*(k-1), 0)

    if k == currentType then
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

function clickBlockTypes(x, y)
 for k,v in pairs(BLOCKFILE) do
  if x >= blockTypesX + BLOCK_WIDTH*(k-1)/2 and x <= blockTypesX + BLOCK_WIDTH*k/2 then
    if y >= blockTypesY and y <= blockTypesY + BLOCK_IMGHEIGHT/2 then
      currentType = k
    end
  end
 end

 -- if click on the add new button
  if x >= blockTypesX + BLOCK_WIDTH*table.getn(BLOCKFILE)/2 and x <= blockTypesX + BLOCK_WIDTH*table.getn(BLOCKFILE) then
    if y >= blockTypesY and y <= blockTypesY + BLOCK_IMGHEIGHT/2 then
      -- open dialog to add a new block type
      dialog.visible = true
    end
  end
end

-- simple function to generate a uniform grid
function makeGrid(type, width, height)
  local grid = {}
  yempty = 0
  xempty = 0

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