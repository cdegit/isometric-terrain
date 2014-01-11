Textbox = {}
Textbox.__index = Textbox

function Textbox.create(label, x, y)
   	local text = {}             -- our new object
   	setmetatable(text,Textbox) 
   	text.x = x
   	text.y = y
   	text.label = label

   	text.labelOffset = 100 -- TODO: calculate based on length of label
   	text.width = 130
   	text.height = 25
   	text.content = ""

   	return text
end

function Textbox:draw()
	love.graphics.push()
	love.graphics.translate(self.x, self.y)

	love.graphics.print(self.label, 0, 0)
	love.graphics.rectangle("fill", self.labelOffset, 0, self.width, self.height)
	
	love.graphics.setColor(0, 0, 0)
	love.graphics.print(self.content, self.labelOffset + 5, 0)
	love.graphics.setColor(255, 255, 255)

	love.graphics.pop()
end

function Textbox:mousepressed(x, y)
	-- check if within bounds of text box
	if x >= self.x + self.labelOffset and x <= self.x + self.width + self.labelOffset then
		if y >= self.y and y <= self.y + self.height then
			--selectedTextbox = self
			return true
		end
	end
end