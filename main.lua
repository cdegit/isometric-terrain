require "isoTerrain"
require "block"
require "isoCreator"

t = {}

function love.load()
	love.graphics.setBackgroundColor(100, 100, 100)
	local grid = {}
	t = Terrain.create(grid, 300, 228)
	t:loadGrid("grid1.txt")
	t:addBlock(5, 6, BLOCK_TYPE_ROCK, 2)

  --t:saveGrid("grid1.txt")
end

function love.draw()
	t:draw()
  love.graphics.print(math.round(math.cos(-math.pi / 2)), 0, 0)
  love.graphics.print(math.round(math.sin(-math.pi / 2)), 0, 20)
end

function love.keypressed(key, unicode)
  if key == "left" then
    t:rotate("left")
  elseif key == "right" then
    t:rotate("right")
  end
end

function love.quit()
  print("Thanks for playing! Come back soon!")
end
