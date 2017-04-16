CoinClass = class(Actor)

function CoinClass:init()
  local ran = (math.random(5) - 1) * 90
	Actor:init(Image("coin.png", ran))
  self.image = Image("coin.png", ran)
end

function CoinClass:Eaten()
  for i = 1, table.getn(draw_list) do
    if draw_list[i] == self then
      table.remove(draw_list, i)
      return
    end
  end
end