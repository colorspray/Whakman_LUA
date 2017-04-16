Game = class()

draw_list = nil
update_list = nil
map = nil

local font_size_osd = 24
local font_osd

StateGame = "StateGame"
StateEditor = "StateEditor"

function Game:init()
  font_osd = LoadFont("LondonBetween.ttf", font_size_osd)
  math.randomseed(os.time())
end

function Game:InitGame()
  self.state = StateGame	

	-- Create Whakman
	local whak = Whakman:new()
	whak.x,whak.y = 0,0

	-- Create Ghost
	--local ghost = Actor:new(Image("ghost_01.png"))
	--ghost.x,ghost.y = 200,200

	-- Create OSD item
	local col_osd = SDL.SDL_Color_local()
	col_osd.r,col_osd.g,col_osd.b = 0xff,0xff,0xff
	local osd_x,osd_y = 10, SYS_SCREEN.h-font_size_osd-10
	local osd_lives = OSDItem:new(Image("osd_whakman.png"), font_osd, col_osd, "Whakmans:", 0, osd_x, osd_y)

	-- Add actors to relevant list
  draw_list = {whak, osd_lives}
  update_list = {whak}

  map = Map:new()
  for x=1, table.getn(map.tiles) do
    dataList = map.tiles[x]
    for y = 1, table.getn(dataList) do
      if dataList[y] ~= nil then
        table.insert(draw_list, 1, dataList[y])
      end
    end
  end
  
  coins = map:generateCoins()
  for x = 1, table.getn(coins) do
    table.insert(draw_list, #draw_list - 1, coins[x])
  end
end
  
function Game:InitEditor()
  Mouse = nil
  self.state = StateEditor
  map = Map:new()
  for x=1, table.getn(map.tiles) do
    dataList = map.tiles[x]
    for y = 1, table.getn(dataList) do
      if dataList[y] ~= nil then
        table.insert(draw_list, 1, dataList[y])
      end
    end
  end
end

function Game:Clear()
  draw_list = {}
  update_list = {}
end
  

function Game:Run()
  local delta_time = 0
	local stop_game
	repeat
		-- Fill screen, otherwise SDL alpha blending doesn't work very well. Almost black.
		SDL.SDL_FillRect(SYS_SCREEN, nil, 0x101010)
    self:UpdateKeys()
		-- Update and draw all objects that have been registered
		for _,v in pairs(update_list)	do 
      v:update(delta_time) 
    end
    
		for _,v in pairs(draw_list)	do 
      v:draw() 
    end

		--
		stop_game, delta_time = SystemUpdate()
	until stop_game == true
end

function Game:UpdateKeys()
  if KEYS[SDL.SDLK_e] == true and self.state == StateGame then 
    self:Clear()
    self:InitEditor()
  elseif  KEYS[SDL.SDLK_g] == true and self.state == StateEditor then
    map:Save()
    self:Clear()
    self:InitGame()
  end
  
  if self.state == StateEditor then
    self.UpdateEditorKeys()
  end
end

function Game:UpdateEditorKeys()
  if Mouse ~= nil then 
    buttonInfo = {}
    buttonInfo.x = math.floor(Mouse.x / 64)
    buttonInfo.y = math.floor(Mouse.y / 64)
    if Mouse.button == SDL.SDL_BUTTON_LEFT then
      buttonInfo.left = true
    end
    map:EditMap(buttonInfo)
    Mouse = nil
  end
end