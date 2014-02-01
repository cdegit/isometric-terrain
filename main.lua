require "isoTerrain"
require "block"
require "avatar"
require "isoCreator"

ic = {}
alert = ""
a = {}

function love.load()
	love.graphics.setBackgroundColor(100, 100, 100)
  ic = IsoCreator.create()
  ic:creatorLoad()

  ic.newTerrain:loadGridAndAvatars("grid2.txt", "avatars.txt")

  a = Avatar.create("sprite.png", 1, 1, 2)
  ic.newTerrain:addAvatar(a)
  
  c = ic.newTerrain:getAvatarById(1)
  c:addAnimation("test", {"cube.png", "grass.png"})
end

function love.draw()
  ic:draw()
  love.graphics.print(alert, 0, 100)

  if love.keyboard.isDown("lctrl") and love.keyboard.isDown("s") then
    -- save the grid and avatars
    ic.newTerrain:saveGridAndAvatars("grid2.txt", "avatars.txt")
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

  if table.getn(ic.newTerrain.avatarModel) >= 1 then
    local avatar = ic.newTerrain.avatarModel[1]
    if key == "w" then
      ic.newTerrain:moveAvatar(a, 0, -1)
    elseif key == "a" then
      ic.newTerrain:moveAvatar(a, 1, 0)
    elseif key == "s" then
      ic.newTerrain:moveAvatar(a, 0, 1)
    elseif key == "d" then
      ic.newTerrain:moveAvatar(a, -1, 0)
    end
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
