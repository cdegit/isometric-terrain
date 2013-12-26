Block = {}
Block.__index = Block

function Block.create(type, height)
   local block = {}             -- our new object
   setmetatable(block,Block)  
   block.type = type      -- initialize our object
   block.height = height
   return block
end
