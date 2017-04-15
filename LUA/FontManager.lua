--[[-----------------------------------------------------------------------------------------------

Public variables:
	

Public functions:
	___________________

	LoadFont()			Loads a font through SDL_ttf
	- In parameters:	
		file_name		String. Font must reside in Whakman\fonts folder
		size			Integer. The size of the font.
	- Returns			
		Font			Use the returned Font instance to print to screen
	___________________

	Font:print()		Print text with the loaded font and size.
	- In parameters:	
		x,y				Integers. The pixel positions on screen where the text should be rendered
		col				SDL_Color. The color the font should be printed with.
		...				
	- Returns			
	___________________

-----------------------------------------------------------------------------------------------]]--

--
FONTMAN_FONTS = {}

--
function font_table_id(identifier, size)
	return tostring(identifier)..tostring(size)
end

--
function LoadFont(file_name, size)
	local table_id = font_table_id(file_name, size)

	if FONTMAN_FONTS[table_id] then
		error("Font "..tostring(file_name).." with size "..tostring(size).." have already been loaded in FontManager")
	end

	local font = SDL.TTF_OpenFont("fonts\\"..file_name, size)
	if not font then
		error("Failed to open font "..tostring(file_name))
	end

	FONTMAN_FONTS[table_id] = font
	return Font:new(table_id)
end

---------------------------------------------------------------------------------------------------

Font = Font or class()

function Font:init(table_id)
	self.table_id = table_id
	self.cache = {}
end

function Font:print(x, y, col, ...)
	local str = string.format(...)
	local text_surface = SDL.TTF_RenderText_Blended(FONTMAN_FONTS[self.table_id], str, col)
	if not text_surface then
		error("failed to render text")
	else
		local rect = SDL.SDL_Rect_local()
		rect.x, rect.y = x,y
		rect.w, rect.h = text_surface.w, text_surface.h
		SDL.SDL_BlitSurface(text_surface, nil, SYS_SCREEN, rect)
	end

	return text_surface
end
