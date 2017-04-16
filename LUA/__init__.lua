
zbsPath = "f:/ZeroBraneStudio1_30"
package.path = package.path .. ";"..zbsPath.."/lualibs/?/?.lua;"..zbsPath.."/lualibs/?.lua"
package.cpath = package.cpath..";"..zbsPath.."/bin/?.dll;"..zbsPath.."/bin/clibs/?.dll;"
require('mobdebug').start('127.0.0.1')

require "System"
require "FontManager"
require "Actors"
require "Coin"
require "Map"
require "Game"


---------------------------------------------------------------------------------------------------

KEYS = {} -- This array is filled in by HandleEvent and can be read at any time to check if a key is pressed
Mouse = nil

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
  
  if c == SDL.SDL_MOUSEBUTTONUP then
    Mouse = event.button
  end

	return false
end

---------------------------------------------------------------------------------------------------

-- Class for something drawn on the screen





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
  local game = Game:new()
  game:InitGame()
  game:Run() 
	SystemQuit()
end

main()
