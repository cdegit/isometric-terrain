require "isoTerrain"
require "block"
require "avatar"
require "isoCreator"

ic = {}
alert = ""
c = {}

function love.load()
	love.graphics.setBackgroundColor(100, 100, 100)
  ic = IsoCreator.create()
  ic:creatorLoad()

  ic.newTerrain:loadGridAndAvatars("grid2.txt", "avatars.txt")
  
  local spritesheet = love.graphics.newImage("spritesheet.png");
  local anim = newAnimation(spritesheet, 62, 66, 0.2, 0)

  c = ic.newTerrain:getAvatarById(1)
  c:addAnimation("test", anim)
  c.animating = true
end

function love.update(dt)
  c = ic.newTerrain:getAvatarById(1)
  c:update(dt)
end

function love.draw()
  ic:draw()
  love.graphics.print(alert, 0, 100)

  if (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") ) and love.keyboard.isDown("s") then
    -- save the grid and avatars
    ic.newTerrain:saveGridAndAvatars("grid2.txt", "avatars.txt")
  end

  -- getting a duplicate value which is stopping the rest from drawing!!!
  for i = 1, table.getn(ic.newTerrain.avatarModel) do
    love.graphics.print(ic.newTerrain.avatarModel[i].x, i * 20, 300)
    love.graphics.print(ic.newTerrain.avatarModel[i].y, i * 20, 350)
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
