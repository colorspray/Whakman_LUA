zbsPath = "f:/ZeroBraneStudio1_30"
package.path = package.path .. ";"..zbsPath.."/lualibs/?/?.lua;"..zbsPath.."/lualibs/?.lua"
package.cpath = package.cpath..";"..zbsPath.."/bin/?.dll;"..zbsPath.."/bin/clibs/?.dll;"
require('mobdebug').start('127.0.0.1')

require "System"
require "FontManager"
require "Map"

---------------------------------------------------------------------------------------------------

KEYS = {} -- This array is filled in by HandleEvent and can be read at any time to check if a key is pressed

-- Return true from this function when game should stop
function HandleEvent(event)
	local c = event.type
	if c == SDL.SDL_KEYDOWN then
		local key = event.key.keysym.sym
		if key == SDL.SDLK_ESCAPE then
			return true
		else
			KEYS[key] = true
		end
	elseif c == SDL.SDL_KEYUP then
		local key = event.key.keysym.sym
		KEYS[key] = false
	elseif c == SDL.SDL_QUIT then
		return true
	end

	return false
end

---------------------------------------------------------------------------------------------------

-- Class for something drawn on the screen

Actor = class()

function Actor:init(image)
	self.image = image

	-- Position on screen
	self.x = 0
	self.y = 0

	-- Draw rect
	self.rect = SDL.SDL_Rect_local()
	self.rect.x,self.rect.y = 0,0
	self.rect.w,self.rect.h = self.image.w,self.image.h
end

function Actor:draw()
	-- Get position on screen
	self.rect.x = self.x
	self.rect.y = self.y

	-- Blit
	SDL.SDL_BlitSurface(self.image, nil, SYS_SCREEN, self.rect)
end

---------------------------------------------------------------------------------------------------

-- Class for Whakman, inherits from Actor

Whakman = class(Actor)

Whakman.MOUTH_TIMER_FRAME_LENGTH = 0.3

function Whakman:init(images)
	Actor:init(images[1])
	self.images = images
	self.image_index = 1
	self.mouth_timer = 1
end

function Whakman:update(dt)
	self:update_mouth(dt)
	self:update_keys(dt)
end

function Whakman:update_mouth(dt)
	self.mouth_timer = self.mouth_timer + dt
	if self.mouth_timer >= Whakman.MOUTH_TIMER_FRAME_LENGTH then
		self.mouth_timer = self.mouth_timer - Whakman.MOUTH_TIMER_FRAME_LENGTH
		self:flip_mouth()
	end
end

function Whakman:update_keys(dt)
	local move_speed = 120*dt	-- 120 pixels per second
	if KEYS[SDL.SDLK_UP] == true then self.y = self.y-move_speed end
	if KEYS[SDL.SDLK_DOWN] == true then self.y = self.y+move_speed end
	if KEYS[SDL.SDLK_LEFT] == true then self.x = self.x-move_speed end
	if KEYS[SDL.SDLK_RIGHT] == true then self.x = self.x+move_speed end
end

function Whakman:flip_mouth()
	self.image_index = (self.image_index % #self.images) + 1
	self.image = self.images[self.image_index]
end

---------------------------------------------------------------------------------------------------

-- OSD items must have at least a value, and can also have a picture and a label

OSDItem = class()

function OSDItem:init(image, font, color, label, value, x, y)
	self.image = image
	self.font = font
	self.color = color
	self.label = label
	self.value = value
	self.x = x
	self.y = y

	-- Draw rect for image
	if image then
		self.rect = SDL.SDL_Rect_local()
		self.rect.x,self.rect.y = x,y
		self.rect.w,self.rect.h = self.image.w,self.image.h
	end
end

function OSDItem:draw()
	local spacing = 5

	-- Draw image if we have one. Draw it at x,y
	local x = self.x
	if self.image then
		SDL.SDL_BlitSurface(self.image, nil, SYS_SCREEN, self.rect)
		x = x + self.image.w + spacing
	end

	-- Draw label if we have one. Draw it to the right of what's previously drawn.
	if self.label and self.font then
		local blitted_surface = self.font:print(x, self.y, self.color, self.label)
		x = x + blitted_surface.w + spacing
	end

	-- Draw the value. Draw it to the right of what's previously drawn. An OSD item must have a value.
	self.font:print(x, self.y, self.color, "%i", self.value)
end

function OSDItem:set_value(value)
	self.value = value
end

---------------------------------------------------------------------------------------------------

function main()
	-- Initialize SDL
	SystemInit()

	--
	local font_size_osd = 24
	local font_osd = LoadFont("LondonBetween.ttf", font_size_osd)

	-- Create Whakman
	local whak = Whakman:new({Image("whakman_01.png"), Image("whakman_02.png")})
	whak.x,whak.y = 100,100

	-- Create Ghost
	local ghost = Actor:new(Image("ghost_01.png"))
	ghost.x,ghost.y = 200,200

	-- Create OSD item
	local col_osd = SDL.SDL_Color_local()
	col_osd.r,col_osd.g,col_osd.b = 0xff,0xff,0xff
	local osd_x,osd_y = 10, SYS_SCREEN.h-font_size_osd-10
	local osd_lives = OSDItem:new(Image("osd_whakman.png"), font_osd, col_osd, "Whakmans:", 0, osd_x, osd_y)

	-- Add actors to relevant list
	local draw_list = {ghost, whak, osd_lives}
	local update_list = {whak}

  local map = Map:new()
  for x=1, table.getn(map.tiles) do
    dataList = map.tiles[x]
    for y = 1, table.getn(dataList) do
      table.insert(draw_list, 1, dataList[y].actor)
    end
  end
  
	-- Create a sample maze. You will want to replace this with a better maze
  --[[
	local x,y
	for y=0,10 do
		for x=0,10 do
			local xtile = (y % 2) == 0
			local ytile = (x % 3) == 0
			local tile = nil
			if xtile and ytile then
				tile = Actor:new(Image("wall_cross.png"))
			elseif xtile then
				tile = Actor:new(Image("wall_straight.png"))
			elseif ytile then
				tile = Actor:new(Image("wall_straight.png", 90))
			end

			if tile then
				tile.x = x*64
				tile.y = y*64
				table.insert(draw_list, 1, tile)
			end
		end
	end
  ]]--

	-- Main loop
	local delta_time = 0
	local stop_game
	repeat
		-- Fill screen, otherwise SDL alpha blending doesn't work very well. Almost black.
		SDL.SDL_FillRect(SYS_SCREEN, nil, 0x101010)

		-- Update and draw all objects that have been registered
		for _,v in pairs(update_list)	do v:update(delta_time) end
		for _,v in pairs(draw_list)		do v:draw() end

		--
		stop_game, delta_time = SystemUpdate()
	until stop_game == true

	--
	SystemQuit()
end

main()
