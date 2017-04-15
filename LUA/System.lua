--[[-----------------------------------------------------------------------------------------------

Public variables:
	SYS_SCREEN			The screen surface to blir onto

Public functions:
	___________________

	SystemInit()		Set up SDL, system variables etc..
	- In parameters:	none
	- Returns			nothing
	___________________

	SystemQuit()		Shut down SDL..
	- In parameters:	none
	- Returns			nothing
	___________________

	SystemUpdate()		Will poll all events and ask game to process them, makes sure the screen is
						rendered, lock frame rate to 60 FPS, and check how many seconds have passed
						since last SystemUpdate
	- In parameters:
						none
	- Returns
		1: boolean that if true should stop game execution, otherwise game should continue
		2: float value for how many seconds have passed since last SystemUpdate
	___________________

	class()				Sets up metatables for class hierarchy. Add an Init function to your class
						if you want to set default variables etc.
	- In parameters:
		super			The super class for this class. Nothing if class should have no super class
	- Returns
		1: A table that can be used as a class
	___________________

	Image()				A function that will load an image from disk and rotate/flip
						it according to input parameters
	- In parameters:
		file_name		A string containing the file name, excluding path. "wall_straight.png" for example
		rotation		An integer that is the rotation in degrees. Allowed rotations are 0, 90, 180, 270
		flip			A string continaing "H" for horizontal flip and "V" for vertical flip. Can be "HV"
	- Returns
		1: The SDL_Surface created, or nil of image couldn't be found on disk
	___________________

-----------------------------------------------------------------------------------------------]]--

SYS_SCREEN = nil
SYS_IMAGE_CACHE = {}
SYS_LAST_TIME = nil
SYS_EVENT = nil

--
function SystemInit()
	-- Initialize SDL
	if SDL.SDL_Init(SDL.SDL_INIT_EVERYTHING) < 0 then
		error("Couldn't initialize SDL: "..SDL.SDL_GetError().."\n")
		os.exit(1)
	end

	SDL.SDL_WM_SetCaption("Whakman", "Whakman")

	SYS_SCREEN = SDL.SDL_SetVideoMode(640, 640, 32, 0)
	if not SYS_SCREEN then
		SDL.SDL_Quit()
		error("Couldn't set video mode: "..SDL.SDL_GetError().."\n")
		os.exit(1)
	end

	-- True type font	
	if SDL.TTF_Init() ~= 0 then
		error("SDL_ttf didn't init")
	end
end

--
function SystemQuit()
	SDL.SDL_Quit()
end

--
function ImageCacheKey(file_name, rotation, flip)
	-- Give default parameters of none were provided
	rotation = rotation or 0
	flip = flip or ""

	-- Key for image wall_straight.png with horizontal flip and 270 deg rotation will be "wall_straight.png:270:H"
	local key = file_name
	key = key .. ":" .. tostring(rotation)
	if string.find(flip, "H") then key = key..":H" end
	if string.find(flip, "V") then key = key..":V" end

	return key
end

-- Class system
function class(...)
	local super = ...
	if select('#', ...) >= 1 and super == nil then
		error("trying to inherit from nil", 2)
	end
    local class_table = {}
    
    class_table.super = super
    class_table.__index = class_table
    setmetatable(class_table, super)
    
    class_table.new = function (klass, ...)
        local object = {}
        setmetatable(object, class_table)
        if object.init then
            object:init(...)
        end
        return object
    end
    return class_table
end

--
function Image(file_name, rotation, flip)
	local key = ImageCacheKey(file_name, rotation, flip)
	local img = SYS_IMAGE_CACHE[key]
	if img then
		-- Image was cached
		return img
	end

	-- Image wasn't cached. See if unmodified image is in cache
	local src_img_key = ImageCacheKey(file_name)
	local src_img = SYS_IMAGE_CACHE[src_img_key]
	if not src_img then
		-- Unmodified image not in cache. Load it from disk and stick it in cache.
		src_img = SDL.IMG_Load("images/"..file_name)
		if src_img then
			SYS_IMAGE_CACHE[src_img_key] = src_img
		else
			-- Failed to load image from disk.
			print("failed to load image '"..file_name.."'")
			return nil
		end
	end

	-- Create a new surface
	local format = src_img.format -- const SDL_PixelFormat *
	local dst_img = SDL.SDL_CreateRGBSurface(src_img.flags, src_img.w, src_img.h,
	format.BitsPerPixel, format.Rmask, format.Gmask, format.Bmask, format.Amask) -- SDL_Surface *

	if dst_img == nil then
		error("failed to create new surface")
		return nil
	end

	-- Origos and coefficients for rotation and flip
	local ox, oy
	local a,b,c,d

	-- Defaults, if no fip or rotation
	a,b,c,d = 1,0,0,1
	ox,oy = 0,0

	-- Rotation (only multiples of 90)
	if rotation then
		if rotation == 90 then
			a,b,c,d = 0,1,-1,0
			ox,oy = 0,src_img.h
		elseif rotation == 180 then
			a,b,c,d = -1,0,0,-1
			ox,oy = src_img.w,src_img.h
		elseif rotation == 270 then
			a,b,c,d = 0,-1,1,0
			ox,oy = src_img.w,0
		end
	end

	-- If we're flipping we need to adjust coeffs and origos
	if flip then
		if string.find(flip, "H") then
			ox = src_img.w-ox
			a,b = -a,-b
		end
		if string.find(flip, "V") then
			oy = src_img.h-oy
			c,d = -c,-d
		end
	end

	-- To properly copy alpha information from source to destination image
	SDL.SDL_SetAlpha(src_img, 0, SDL.SDL_ALPHA_OPAQUE)

	-- Copy image
	local x, y
	local src_rect = SDL.SDL_Rect_local()
	local dst_rect = SDL.SDL_Rect_local()
	src_rect.w = 1
	src_rect.h = 1
	dst_rect.w = 1
	dst_rect.h = 1
	for y=0,src_img.h do
		for x=0,src_img.w do
			src_rect.x = ox+(a*x + b*y)
			src_rect.y = oy+(c*x + d*y)
			dst_rect.x = x
			dst_rect.y = y
			SDL.SDL_BlitSurface(src_img, src_rect, dst_img, dst_rect)
		end
	end

	-- Stick rotated and flipped image in cache
	SYS_IMAGE_CACHE[key] = dst_img

	-- Set proper alpha settings for blitting
	SDL.SDL_SetAlpha(src_img, SDL.SDL_SRCALPHA, SDL.SDL_ALPHA_OPAQUE)
	SDL.SDL_SetAlpha(dst_img, SDL.SDL_SRCALPHA, SDL.SDL_ALPHA_OPAQUE)

	-- Done
	return dst_img
end

--
function SystemUpdate()
	SYS_LAST_TIME = SYS_LAST_TIME or SDL.SDL_GetTicks()
	SYS_EVENT = SYS_EVENT or SDL.SDL_Event_local()

	-- Handle all events for this frame
	local stop_game = false
	while SDL.SDL_PollEvent(SYS_EVENT) ~= 0 do
		stop_game = HandleEvent(SYS_EVENT) or stop_game
	end

	-- Draw screen
	SDL.SDL_UpdateRect(SYS_SCREEN, 0, 0, 0, 0)

	-- Lock frame rate to 60 fps and check how much time has passed since last update
	local time_now = SDL.SDL_GetTicks()
	local time_passed = time_now - SYS_LAST_TIME
	local wait_time = (1000/60)-time_passed
	if wait_time > 0 then
		SDL.SDL_Delay(wait_time)
	end
	time_now = SDL.SDL_GetTicks()
	time_passed = time_now-SYS_LAST_TIME
	SYS_LAST_TIME = time_now
	local delta_time = time_passed/1000

	-- Return values
	return stop_game, delta_time
end
