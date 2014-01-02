require "textbox"

-- create button to add new tile type
-- once clicked, draw checkboxes and check if they are clicked

nameTextbox = {}
--nameTextbox = Textbox.create("Type Name: ", 0, 0)

fileTextbox = {}
--fileTextbox = Textbox.create("File Name: ", 0, 50)

selectedTextbox = nil

textboxX = 500
textboxY = 20

function creatorLoad()
	nameTextbox = Textbox.create("Type Name: ", textboxX, textboxY)
	fileTextbox = Textbox.create("File Name: ", textboxX, textboxY + 50)
end

function creatorMousepressed(x, y)
	nameTextbox:mousepressed(x, y)
	fileTextbox:mousepressed(x, y)
end

function drawAddBlockTypeButton()

end

function addBlockTypeClicked()

end

function drawTextboxes()
	nameTextbox:draw()
	fileTextbox:draw()
end