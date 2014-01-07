Block = {}
Block.__index = Block

BLOCK_WIDTH = 64
BLOCK_HEIGHT = 32
BLOCK_IMGHEIGHT = 66

function Block.create(blockType, height)
   local block = {}             -- our new object
   setmetatable(block,Block)  
   block.type = blockType      -- initialize our object
   block.height = height
   return block
end
