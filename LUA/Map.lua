require "Mapdata"
require "Tile"

Map = class()

function Map:init()
  self.mapdataObj = Mapdata:new()
  self.mapdata = self.mapdataObj:Getdata()
  self.height, self.width = self.mapdataObj:Shape()
  
  local tiles = {}
  for i = 1, self.height do
    tiles[i] = {}
    for j = 1, self.width do
      local data = self.mapdata[i][j]        
      tiles[i][j] = Tile:new(self:Decode(data), i, j)
    end
  end
  self.tiles = tiles
  self:generatePath()
end

function Map:generatePath()
  for i = 1, self.height do
    for j = 1, self.width do
      local tile = self.tiles[i][j]
      -- up
      if i == 1 then
        tile.nodeup = nil
      elseif tile.linkage[1] then 
        local neighbourTile = self.tiles[i - 1][j]
        if neighbourTile.linkage[3] == true then
          tile.nodeup = neighbourTile
        end
      end
        
      -- down
      if i == self.height then
        tile.nodedown = nil
      elseif tile.linkage[3] then
        local neighbourTile = self.tiles[i + 1][j]
        if neighbourTile.linkage[1] == true then
          tile.nodedown = neighbourTile
        end
      end
        
      -- left
      if j == 1 then 
        tile.nodeleft = nil
      elseif tile.linkage[4] == true and self.tiles[i][j - 1].linkage[2] == true then
        tile.nodeleft = self.tiles[i][j - 1]
      end
      
      --right
      if j == self.width then
        tile.noderight = nil
      elseif tile.linkage[2] == true and self.tiles[i][j + 1].linkage[4] == true then
        tile.noderight = self.tiles[i][j + 1]
      end
    end
  end
end

function Map:MoveActor(actor, direction, speed)
  local i = math.floor(actor.y / 64 + 0.5) + 1
  local j = math.floor(actor.x / 64 + 0.5) + 1
  local currentTile = self.tiles[i][j]
  
  if direction == 1 then
    actor.y = actor.y - speed
    if currentTile.nodeup ~= nil then
      actor.x = currentTile.nodex
    elseif actor.y < currentTile.nodey then
      actor.y = currentTile.nodey
    end
  elseif direction == 2 then
    actor.x = actor.x + speed
    if currentTile.noderight ~= nil then
      actor.y = currentTile.nodey
    elseif actor.x > currentTile.nodex then      
      actor.x = currentTile.nodex
    end
  elseif direction == 3 then
    actor.y = actor.y + speed
    if currentTile.nodedown ~= nil then
      actor.x = currentTile.nodex
    elseif actor.y > currentTile.nodey then
      actor.y = currentTile.nodey
    end
  elseif direction == 4 then
    actor.x = actor.x - speed
    if currentTile.nodeleft ~= nil then
      actor.y = currentTile.nodey
    elseif actor.x < currentTile.nodex then
      actor.x = currentTile.nodex
    end
  end
end

function Map:Decode(data)
  i = math.floor(data / 4)
  j = data % 4
  return {i, j}
end

function Map:Encode(code)
  return code[1] * 4 + code[2]
end

function Map:EditMap(operation)
  local i, j = operation.y + 1, operation.x + 1
  local tile = self.tiles[i][j]
  
  local tileInfo = tile.tileInfo
  if operation.left == true then
    tileInfo[1] = tileInfo[1] + 1
    if tileInfo[1] > 5 then
      tileInfo[1] = 0
    end
  else
    tileInfo[2] = tileInfo[2] + 1
    if tileInfo[2] > 3 then
      tileInfo[2] = 0
    end
  end
  tile:init(tileInfo, i, j)
end

function Map:Save()
  for i = 1, self.height do
    for j = 1, self.width do     
      self.mapdata[i][j] = Map:Encode(self.tiles[i][j].tileInfo)
    end
  end
  self.mapdataObj:Save()
end

--[[
local map = Map:new()
]]--





  