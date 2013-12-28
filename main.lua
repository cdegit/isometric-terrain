require "isoTerrain"
require "block"

t = {}

function love.load()
	love.graphics.setBackgroundColor(100, 100, 100)

	file = love.filesystem.newFile("grid.txt")
	file:open("r")

	local grid = {}

	data = {}
	splitData = {}

	j = 1
	for line in file:lines() do
		data[j] = line
		j = j + 1
	end

	for key, value in pairs(data) do
		grid[key] = {}
		splitData[key] = {}
		splitData[key] = string.split(value, ",")

		for k, v in pairs(splitData[key]) do
			splitData[key][k] = {}
			splitData[key][k] = string.split(v, " ")

			for a, b in pairs(splitData[key][k]) do
				bl = Block.create(tonumber(splitData[key][k][1]), tonumber(splitData[key][k][2])) 
				grid[key][k] = bl
			end
		end
	end

	file:close()

	t = Terrain.create(grid, 200, 128)
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