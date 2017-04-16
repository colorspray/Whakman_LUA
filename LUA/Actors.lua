---------------------------------------------------------------------------------------------------

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

-- Class for Whakman, inherits from Actor

Whakman = class(Actor)

Whakman.MOUTH_TIMER_FRAME_LENGTH = 0.3
Whakman.ImageNames = {"whakman_01.png", "whakman_02.png"}

function Whakman:init()
  self:initImages()
	Actor:init(self.images[2][1])
	self.image_index = 1
	self.mouth_timer = 1
  self.direction = 2
end

function Whakman:update(dt)
	self:update_mouth(dt)
	self:update_keys(dt)
  map:CheckEatCoin(self)
end

function Whakman:update_mouth(dt)
	self.mouth_timer = self.mouth_timer + dt
	if self.mouth_timer >= Whakman.MOUTH_TIMER_FRAME_LENGTH then
		self.mouth_timer = self.mouth_timer - Whakman.MOUTH_TIMER_FRAME_LENGTH
		self:flip_mouth()
	end
end

function Whakman:update_keys(dt)
	local move_speed = 200*dt	-- 200 pixels per second
	if KEYS[SDL.SDLK_UP] == true then 
    map:MoveActor(self, 1, move_speed)
    self.direction = 1
  elseif KEYS[SDL.SDLK_RIGHT] == true then
    map:MoveActor(self, 2, move_speed)
    self.direction = 2
  elseif KEYS[SDL.SDLK_DOWN] == true then
    map:MoveActor(self, 3, move_speed)
    self.direction = 3
  elseif KEYS[SDL.SDLK_LEFT] == true then
    map:MoveActor(self, 4, move_speed) 
    self.direction = 4
  end
  self:updateDirection()
end

function Whakman:initImages()
  self.images = {}
  self.images[1] = {}
  self.images[2] = {}
  self.images[3] = {}
  self.images[4] = {}
  
  for i = 1, 2 do
    self.images[1][i] = Image(Whakman.ImageNames[i], 270)
    self.images[2][i] = Image(Whakman.ImageNames[i])
    self.images[3][i] = Image(Whakman.ImageNames[i], 90)
    self.images[4][i] = Image(Whakman.ImageNames[i], 0, "H")
  end
end

function Whakman:updateDirection()
  self.image = self.images[self.direction][self.image_index]
end

function Whakman:flip_mouth()
	self.image_index = (self.image_index % #self.images[1]) + 1
	self.image = self.images[self.direction][self.image_index]
end
