require "isoTerrain"
require "block"
require "isoCreator"

t = {}
alert = ""

function love.load()
	love.graphics.setBackgroundColor(100, 100, 100)
	local grid = {{}}
	t = Terrain.create(grid, 300, 228)

	t:loadGrid("grid1.txt")
	t:addBlock(5, 6, BLOCKTYPE["rock"], 2)

  --t:saveGrid("grid1.txt")

  --t:addBlockType("cube", "cube.png")

  creatorLoad()
end

function love.draw()
	--t:draw()
  creatorDraw()
  love.graphics.print(alert, 0, 100)
end

function love.keypressed(key, unicode)
  if key == "left" then
    --t:rotate("left")
    --blueprint:rotate("left")
    --newTerrain:rotate("left")

    blueprint:translate(-100, 0)
    newTerrain:translate(-100, 0)
  elseif key == "right" then
    --t:rotate("right")
    --blueprint:rotate("right")
    --newTerrain:rotate("right")

    blueprint:translate(100, 0)
    newTerrain:translate(100, 0)
  elseif key == "up" then
    blueprint:translate(0, -100)
    newTerrain:translate(0, -100)
  elseif key == "down" then
    --blueprintVisible = not blueprintVisible

    blueprint:translate(0, 100)
    newTerrain:translate(0, 100)
  elseif key == "return" then
    -- try to add new block type with current name and fileName
    -- will need to add more checking and stuff but
    --newTerrain:addBlockType(nameTextbox.content, fileTextbox.content)
    --addBlockTypeVisible = false
    return
  end

  creatorKeypressed(key, unicode)
end

function love.mousepressed(x, y, button)
    creatorMousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  creatorMousereleased(x, y, button)
end 

function love.quit()
  print("Thanks for playing! Come back soon!")
end
