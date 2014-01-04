require "textbox"

-- TODO:
-- create button to add new tile type
-- once clicked, draw checkboxes and check if they are clicked

-- TODO: make into proper class, more independant of main

nameTextbox = {}

fileTextbox = {}

selectedTextbox = nil

textboxX = 500
textboxY = 20

blueprint = {}
newTerrain = {}

function creatorLoad()
	nameTextbox = Textbox.create("Type Name: ", textboxX, textboxY)
	fileTextbox = Textbox.create("File Name: ", textboxX, textboxY + 50)

	blueprint = Terrain.create(makeGrid("blueprint", 7, 7), 300, 228)
  	newTerrain = Terrain.create(makeGrid("empty", 7, 7), 300, 228)
end

-- draws 2 terrains: the blueprint terrain and the actual terrain being built
function drawTerrains()
  newTerrain:draw()
  blueprint:draw()
end

function creatorMousepressed(x, y)
	nameTextbox:mousepressed(x, y)
	fileTextbox:mousepressed(x, y)

	blueprint:selectTileFromMouse(x, y)

	if blueprint.selected[1] >= 1 and blueprint.selected[2] >= 1 then
      newTerrain:addBlock(blueprint.selected[1], blueprint.selected[2], BLOCKTYPE["grass"], 0)
    end
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