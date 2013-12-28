Block = {}
Block.__index = Block

BLOCK_WIDTH = 64
BLOCK_HEIGHT = 32

function Block.create(type, height)
   local block = {}             -- our new object
   setmetatable(block,Block)  
   block.type = type      -- initialize our object
   block.height = height
   return block
end
