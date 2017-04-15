require "Mapdata"

Map = class()

local mapdata
local mapIndicator = {}
mapIndicator[1] = {"wall_cross.png", 0}
mapIndicator[2] = {"wall_end.png", 0}
mapIndicator[3] = {"wall_end.png", 90}
mapIndicator[4] = {"wall_end.png", 180}
mapIndicator[5] = {"wall_end.png", 270}
mapIndicator[6] = {"wall_straight.png", 0}
mapIndicator[7] = {"wall_straight.png", 90}
mapIndicator[8] = {"wall_t.png", 0}
mapIndicator[9] = {"wall_t.png", 90}
mapIndicator[10] = {"wall_t.png", 180}
mapIndicator[11] = {"wall_t.png", 270}
mapIndicator[12] = {"wall_turn.png", 0}
mapIndicator[13] = {"wall_turn.png", 90}
mapIndicator[14] = {"wall_turn.png", 180}
mapIndicator[15] = {"wall_turn.png", 270}

function Map:init()
  mapdata = Mapdata:new()
end


local map = Map:new()





  