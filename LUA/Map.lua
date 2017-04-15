require "Mapdata"
require "Tile"

Map = class()

function Map:init()
  local mapdataObj = Mapdata:new()
  self.mapdata = mapdataObj:Getdata()
  self.height, self.width = mapdataObj:Shape()
  
  local tiles = {}
  for i = 1, self.height do
    tiles[i] = {}
    for j = 1, self.width do
      local data = self.mapdata[i][j]  
      
      tiles[i][j] = Tile:new(self:Decode(data))
      tiles[i][j]:initActor(i, j)
    end
  end
  self.tiles = tiles
end

function Map:Decode(data)
  i = math.floor(data / 4)
  j = data % 4
  return {i, j}
end

--[[
local map = Map:new()
]]--





  