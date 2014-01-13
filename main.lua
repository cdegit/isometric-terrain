require "isoTerrain"
require "block"
require "isoCreator"

t = {}
ic = {}
alert = ""

function love.load()
	love.graphics.setBackgroundColor(100, 100, 100)
	local grid = {{}}
	t = Terrain.create(grid, 300, 228)
  ic = IsoCreator.create()

	t:loadGrid("grid1.txt")
	t:addBlock(5, 6, BLOCKTYPE["rock"], 2)

  --t:saveGrid("grid1.txt")

  --t:addBlockType("cube", "cube.png")

  ic:creatorLoad()
end

function love.draw()
	--t:draw()
  ic:creatorDraw()
  love.graphics.print(alert, 0, 100)
end

function love.keypressed(key, unicode)
  if key == "left" then
    ic.blueprint:translate(-100, 0)
    ic.newTerrain:translate(-100, 0)
  elseif key == "right" then
    ic.blueprint:translate(100, 0)
    ic.newTerrain:translate(100, 0)
  elseif key == "up" then
    ic.blueprint:translate(0, -100)
    ic.newTerrain:translate(0, -100)
  elseif key == "down" then
    ic.blueprint:translate(0, 100)
    ic.newTerrain:translate(0, 100)
  end

  ic:creatorKeypressed(key, unicode)
end

function love.mousepressed(x, y, button)
    ic:creatorMousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  ic:creatorMousereleased(x, y, button)
end 

function love.quit()
  print("Thanks for playing! Come back soon!")
end
