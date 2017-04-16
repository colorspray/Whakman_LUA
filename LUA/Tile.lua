local constFileNames = {}
constFileNames[1] = "placeHolder.png"
constFileNames[2] = "wall_cross.png"
constFileNames[3] = "wall_end.png"
constFileNames[4] = "wall_straight.png"
constFileNames[5] = "wall_t.png"
constFileNames[6] = "wall_turn.png"


local constTableLinkage = {}
constTableLinkage[constFileNames[1]] = {false, false, false, false}
constTableLinkage[constFileNames[2]] = {true, true, true, true}
constTableLinkage[constFileNames[3]] = {true, false, false, false}
constTableLinkage[constFileNames[4]] = {false, true, false, true}
constTableLinkage[constFileNames[5]] = {true, false, true, true}
constTableLinkage[constFileNames[6]] = {false, true, true, false}


Tile = class(Actor)

function Tile:init(tileInfo, i, j)
  self.width = 64
  self.tileInfo = tileInfo  
  
  self.picFile = constFileNames[tileInfo[1] + 1]

  self.turn = tileInfo[2]
  if self.picFile == "" or  self.picFile == constFileNames[2] then
    self.angle = 0
  else
    self.angle = 90 * (self.turn)
  end
  
  if self.picFile ~= constFileNames[1] then
    self.initCoin = true
  else
    self.initCoin = false
  end
  
  self.linkage = {}
  self.linkage[1], self.linkage[2], self.linkage[3], self.linkage[4] = constTableLinkage[self.picFile][1],constTableLinkage[self.picFile][2],constTableLinkage[self.picFile][3],constTableLinkage[self.picFile][4]
  
  if self.turn ~= 0 then
    for i = 0, self.turn - 1 do
      self:shiftClockwise()
    end
  end  
  
  self:initActor(i, j)
  self:initNode()
end

function Tile:generateCoin()
  if self.initCoin then
    self.coinGen = CoinClass:new() 
    self.coinGen.x = self.x
    self.coinGen.y = self.y
  else
    self.coinGen = nil
  end
  return self.coinGen
end

function Tile:EatCoin()
  if self.coinGen ~= nil then 
    self.coinGen:Eaten()
  end
end

function Tile:shiftClockwise()
  self.linkage[1], self.linkage[2], self.linkage[3], self.linkage[4] = self.linkage[4], self.linkage[1], self.linkage[2], self.linkage[3]
end

function Tile:initActor(i, j)
  Actor:init(Image(self.picFile, self.angle))
  self.image = Image(self.picFile, self.angle)
  self.x = (j - 1) * self.width
  self.y = (i - 1) * self.width   
end

function Tile:initNode()
  self.nodex = self.x
  self.nodey = self.y
  self.nodeup, self.nodedown, self.nodeleft, self.nodedown = nil, nil, nil, nil
end

--[[
local tile = Tile:new({2, 2})
print(tile.picFile)
print(tile.turn)
print(tile.angle)
print(tile.linkage)
]]--


  