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
    t:rotate("left")
  elseif key == "right" then
    t:rotate("right")
  elseif key == "return" then
    -- try to add new block type with current name and fileName
    -- will need to add more checking and stuff but
    t:addBlockType(nameTextbox.content, fileTextbox.content)
    return
  end

  creatorKeypressed(key, unicode)
end

function love.mousepressed(x, y, button)
  --if button == "l" then
    creatorMousepressed(x, y, button)
  --end
end

function love.quit()
  print("Thanks for playing! Come back soon!")
end
