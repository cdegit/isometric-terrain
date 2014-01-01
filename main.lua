require "isoTerrain"
require "block"

t = {}

function love.load()
	love.graphics.setBackgroundColor(100, 100, 100)
	local grid = {}
	t = Terrain.create(grid, 300, 228)
	t:loadGrid("grid.txt")
	t:addBlock(5, 6, BLOCK_TYPE_ROCK, 2)
	--t:addBlock(8, 1, BLOCK_TYPE_ROCK, 1)
end

function love.draw()
	t:draw()
	--t:rotate(math.pi/2)
  m1 = {{3, 1, 1}, {1, 1, 1}, {1, 1, 1}}
  m2 = {2, 2, 4}
  res = t:multiplyMatrices(m1, m2)

  for i = 1, table.getn(res) do
    love.graphics.print(res[i], 0, i * 10)
  end


end

function love.quit()
  print("Thanks for playing! Come back soon!")
end

-- from Stack Overflow: http://stackoverflow.com/questions/1426954/split-string-in-lua by krsk9999
function string:split(delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end