Item = class(Actor)

function Item:init()
  local ran = math.random(10) 
  local angle = 0
  local itemPicName = "coin.png"
  if ran <= 5 then
    angle = (math.random(5) - 1) * 90
    itemPicName = "coin.png"
  elseif ran == 6 then
    itemPicName = "rocket.png"
  elseif ran == 7 then
    itemPicName = "glove.png"
  elseif ran == 8 then
    itemPicName = "spring.png"
  elseif ran == 9 then
    itemPicName = "rollerskates.png"
  end
	Actor:init(Image(itemPicName, angle))
  self.image = Image(itemPicName, angle)
end

function Item:Eaten()
  for i = 1, table.getn(draw_list) do
    if draw_list[i] == self then
      table.remove(draw_list, i)
      return
    end
  end
end