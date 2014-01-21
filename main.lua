require "isoTerrain"
require "block"
require "avatar"
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

  a = {}
  a = Avatar.create("sprite.png", 1, 1, 2)
  ic.newTerrain:addAvatar(a)

  --ic.newTerrain:moveAvatar(a, 1, 2)

  b = {}
  b = Avatar.create("sprite.png", 3, 5, 2)
 -- ic.newTerrain:addAvatar(b)

  ic.newTerrain:loadAvatars("avatars.txt")
end

function love.draw()
	--t:draw()
  ic:draw()
  love.graphics.print(alert, 0, 100)

  for i = 1, table.getn(ic.newTerrain.avatarModel) do
    love.graphics.print(ic.newTerrain.avatarModel[i].x, 20 * i, 200)
    love.graphics.print(ic.newTerrain.avatarModel[i].y, 20 * i, 220)
  end
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

  ic:keypressed(key, unicode)
end

function love.mousepressed(x, y, button)
    ic:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  ic:mousereleased(x, y, button)
end 

function love.quit()
  print("Thanks for playing! Come back soon!")
end
