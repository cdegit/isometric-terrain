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

  t:rotate()
  --t:rotate()
  --t:saveGrid("grid1.txt")
end

function love.draw()
	t:draw()


end

function love.quit()
  print("Thanks for playing! Come back soon!")
end
