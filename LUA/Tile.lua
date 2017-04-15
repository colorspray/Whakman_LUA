require "System"

local constFileNames = {}
constFileNames[1] = "wall_cross.png"
constFileNames[2] = "wall_end.png"
constFileNames[3] = "wall_straight.png"
constFileNames[4] = "wall_t.png"
constFileNames[5] = "wall_turn.png"

local constTableLinkage = {}
constTableLinkage[constFileNames[1]] = {true, true, true, true}
constTableLinkage[constFileNames[2]] = {true, false, false, false}
constTableLinkage[constFileNames[3]] = {false, true, false, true}
constTableLinkage[constFileNames[4]] = {true, false, true, true}
constTableLinkage[constFileNames[5]] = {false, true, true, false}

Tile = class()

function Tile:init(tileInfo)
  self.width = 64
  
  self.picFile = constFileNames[tileInfo[1] + 1]
  self.turn = tileInfo[2]
  if tileInfo[1] == 0 then
    self.angle = 0
  else
    self.angle = 90 * (self.turn)
  end
  
  self.linkage = constTableLinkage[self.picFile]
  
  if self.turn ~= 0 then
    for i = 0, self.turn - 1 do
      self:shiftClockwise()
    end
  end  
end

function Tile:shiftClockwise()
  self.linkage[1], self.linkage[2], self.linkage[3], self.linkage[4] = self.linkage[4], self.linkage[1], self.linkage[2], self.linkage[3]
end

function Tile:initActor(i, j)
  self.actor = Actor:new(Image(self.picFile, self.angle))
  self.actor.y = (i - 1) * self.width
  self.actor.x = (j - 1) * self.width
end

--[[
local tile = Tile:new({2, 2})
print(tile.picFile)
print(tile.turn)
print(tile.angle)
print(tile.linkage)
]]--


  