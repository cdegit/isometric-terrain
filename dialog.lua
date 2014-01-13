require "textbox"

Dialog = {}
Dialog.__index = Dialog

function Dialog.create(x, y)
   	local dialog = {}             -- our new object
   	setmetatable(dialog,Dialog) 
   	dialog.x = x
   	dialog.y = y
      dialog.nameTextbox = Textbox.create("Type Name: ", 0, 0)
      dialog.fileTextbox = Textbox.create("File Name: ", 0, 50)
      dialog.visible = false
      dialog.selectedTextbox = dialog.nameTextbox

      dialog.closeButtonX = 30
      dialog.addButtonX = 140
      dialog.buttonY = 100
      dialog.buttonWidth = 60
      dialog.buttonHeight = 25

   	return dialog
end

function Dialog:draw()
   local r, g, b, a = love.graphics.getColor()
   
   -- grey out the background so the user knows they can't interact with it currently
   love.graphics.setColor(0, 0, 0, 150)
   love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
   love.graphics.setColor(r, g, b, a)

   love.graphics.push()
   love.graphics.translate(self.x, self.y)

  -- draw dialog background
  love.graphics.setColor(70, 70, 70)
  love.graphics.rectangle("fill", -10, -10, 250, 150)
  love.graphics.setColor(r, g, b, a)

  -- draw Textboxes
   self.nameTextbox:draw()
   self.fileTextbox:draw()

  -- draw add and close buttons
  love.graphics.rectangle("fill", self.closeButtonX, self.buttonY, self.buttonWidth, self.buttonHeight)
  love.graphics.rectangle("fill", self.addButtonX, self.buttonY, self.buttonWidth, self.buttonHeight)

  love.graphics.setColor(0, 0, 0)
  love.graphics.print("Add", self.addButtonX + 18, self.buttonY + 6)
  love.graphics.print("Close", self.closeButtonX + 13, self.buttonY + 6)
  love.graphics.setColor(r, g, b, a)

  love.graphics.pop()
end

function Dialog:mousepressed(x, y)
   -- check if the textboxes have been clicked and if so, select them
   if self.nameTextbox:mousepressed(x - self.x, y - self.y) then
      self.selectedTextbox = self.nameTextbox
   end
   if self.fileTextbox:mousepressed(x - self.x, y - self.y) then
      self.selectedTextbox = self.fileTextbox
   end

   if y >= self.y + self.buttonY and y <= self.y + self.buttonY + self.buttonHeight then
    -- if add button clicked
    if x >= self.x + self.addButtonX and x <= self.x + self.addButtonX + self.buttonWidth then
      self:addBlockType()
    end

    if x >= self.x + self.closeButtonX and x <= self.x + self.closeButtonX + self.buttonWidth then
      self.visible = false
      self.nameTextbox.content = ""
      self.fileTextbox.content = ""
    end
  end
end

function Dialog:addBlockType()
  if Terrain:addBlockType(self.nameTextbox.content, self.fileTextbox.content) then
    self.visible = false
    self.nameTextbox.content = ""
    self.fileTextbox.content = ""
    alert = "File added successfully!"
  else
    -- report error to the user and prompt them to try again
    alert = "Couldn't find a file with this name. Please try again."
  end
end

function Dialog:keypressed(key, unicode)
  if key == "backspace" then
    if self.selectedTextbox ~= nil then
      self.selectedTextbox.content = string.sub(self.selectedTextbox.content, 1, string.len(self.selectedTextbox.content) - 1)
    end
  end

  if key == "tab" then
    if self.selectedTextbox == self.nameTextbox then
      self.selectedTextbox = self.fileTextbox
    end
  end

  if key == "return" then
    if self.nameTextbox.content ~= "" and self.fileTextbox.content ~= "" then
      self:addBlockType()
    end
  end

  if unicode > 31 and unicode < 127 then
    if self.selectedTextbox ~= nil then
      self.selectedTextbox.content = self.selectedTextbox.content .. string.char(unicode)
    end
  end
end