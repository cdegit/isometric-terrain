require "textbox"

-- TODO:
-- create button to add new tile type
-- once clicked, draw checkboxes and check if they are clicked

-- TODO: make into proper class, more independant of main
-- TODO: display and allow selection of a tile type

nameTextbox = {}

fileTextbox = {}

selectedTextbox = nil

textboxX = 500
textboxY = 20

blockTypesX = 0
blockTypesY = 0

currentType = BLOCKTYPE["grass"] -- default type when creating blocks

blueprint = {}
newTerrain = {}

creatingBlock = false

function creatorLoad()
	nameTextbox = Textbox.create("Type Name: ", textboxX, textboxY)
	fileTextbox = Textbox.create("File Name: ", textboxX, textboxY + 50)

	blueprint = Terrain.create(makeGrid("blueprint", 7, 7), 300, 228)
  newTerrain = Terrain.create(makeGrid("empty", 7, 7), 300, 228)
end

function creatorDraw()
  drawTextboxes()
  drawTerrains()
  drawBlockTypes()

  if creatingBlock then
    updateBlockHeight()
  end
end

-- draws 2 terrains: the blueprint terrain and the actual terrain being built
function drawTerrains()
  newTerrain:draw()
  blueprint:draw()
end

function creatorMousepressed(x, y, button)
  clickBlockTypes(x, y)
  nameTextbox:mousepressed(x, y)
	fileTextbox:mousepressed(x, y)
	blueprint:selectTileFromMouse(x, y)

  if button == "l" then 
      creatingBlock = true
      newTerrain:addBlock(blueprint.selected[1], blueprint.selected[2], currentType, 0)
  else
      creatingBlock = false
      newTerrain:removeBlock(blueprint.selected[1], blueprint.selected[2])
  end
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
  if unicode > 31 and unicode < 127 then
    if selectedTextbox ~= nil then
      selectedTextbox.content = selectedTextbox.content .. string.char(unicode)
    end
  end
end

function drawAddBlockTypeButton()

end

function addBlockTypeClicked()

end

function drawTextboxes()
	nameTextbox:draw()
	fileTextbox:draw()
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
      -- TODO: open dialog to add a new block type
      -- for now, add the cube type
      newTerrain:addBlockType("cube", "cube.png")
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