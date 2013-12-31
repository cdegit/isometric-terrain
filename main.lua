require "isoTerrain"
require "block"

t = {}

function love.load()
	love.graphics.setBackgroundColor(100, 100, 100)
	local grid = {}
	t = Terrain.create(grid, 200, 128)
	t:loadGrid("grid.txt")
end

function love.draw()
	t:draw()
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