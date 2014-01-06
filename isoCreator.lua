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
      newTerrain:addBlock(blueprint.selected[1], blueprint.selected[2], currentType, 0)
  else
      newTerrain:removeBlock(blueprint.selected[1], blueprint.selected[2])
  end

  -- for each block, check if mouse is within its bounds... will want to use code form isoTerrain actually I guess
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

  love.graphics.pop()
end

function clickBlockTypes(x, y)
 -- 62 x 66
 for k,v in pairs(BLOCKFILE) do
  if x >= blockTypesX + BLOCK_WIDTH*(k-1) and x <= blockTypesX + BLOCK_WIDTH*k then
    if y >= blockTypesY and y <= blockTypesY + 66 then
      currentType = k
    end
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