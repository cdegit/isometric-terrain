require "isoTerrain"
require "block"
require "isoCreator"

t = {}
userInput = ""

function love.load()
	love.graphics.setBackgroundColor(100, 100, 100)
	local grid = {}
	t = Terrain.create(grid, 300, 228)
	t:loadGrid("grid1.txt")
	t:addBlock(5, 6, BLOCKTYPE["rock"], 2)

  --t:saveGrid("grid1.txt")
  userInput = "Type something!"

  t:addBlockType("cube", "cube.png")
end

function love.draw()
	t:draw()

  love.graphics.print(userInput, 0, 40)
end

function love.keypressed(key, unicode)
  if key == "left" then
    t:rotate("left")
  elseif key == "right" then
    t:rotate("right")
  elseif key == "return" then
    -- try to add new block type with current name and fileName
    -- will have to have 2 "textboxes"
    --t:addBlock(1, 2, BLOCKTYPE["cube"], 1)
    return
  end

  if unicode > 31 and unicode < 127 then
    userInput = userInput .. string.char(unicode)
  end
end

function love.quit()
  print("Thanks for playing! Come back soon!")
end
