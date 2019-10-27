dofile( "lib/misc.lua" )

card = {}
card.__index = card

local variants = { 
	{ name = "basic", weight = 19, color = true, number = true },
	{ name = "draw two", weight = 2, color = true, number = false, func = function( deck, player, next_player)
		next_player:add_random_card( 2 )
		deck.direction = deck.direction * 2
	end},
	{ name = "block", weight = 2, color = true, number = false, func = function( deck, player, next_player)
		deck.direction = deck.direction * 2
	end},
	{ name = "reverse", weight = 2, color = true, number = false, func = function( deck, player, next_player)
		deck.direction = deck.direction * -1
	end},
	{ name = "draw four", weight = 1, color = false, number = false, wild = true, func = function( deck, player, next_player)
		next_player:add_random_card( 4 )
		deck.direction = deck.direction * 2
		card.color = card.pick_color()
	end},
	{ name = "wild", weight = 1, color = false, number = false, wild = true, func = function( deck, player, next_player)
		card.color = card.pick_color()
	end},
}

local colors = { "red", "yellow", "green", "blue" }
local numbers = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }

local rand = math.random
if love and love.math then rand = love.math.random end

function card.new( variant, color, number )
	if variant == nil then
		variant = variants[1]
	elseif type( variant ) == "number" then
		variant = variants[variant]
	end
	local col, num
	if variant.color then
		col = color
	end
	if variant.number then
		num = number
	end
	if variant.wild then
		col = nil
	end

	return setmetatable({ color = col, number = tonumber( num ), func = variant.func, wild = variant.wild, name = variant.name }, card )
end

function card.random()
	return card.new( weighted_choice( variants ), colors[rand( #colors )], tonumber( numbers[rand( #numbers )]))
end

function card.random_basic()
	return card.new( nil, colors[rand( #colors )], tonumber( numbers[rand( #numbers )]))
end

function card.pick_color()
	--[[local col -- user input machine broke
			while col == nil do
				print( "Pick a color: " )
				local inp = string.lower( io.read("*l") )
				for i = 1, #colors do
					if inp == colors[i] then return inp end
				end
			end
			return colors[1]
			]]
	local col = colors[rand( #colors )]
	return( col )
end
--[[
function card:clone()
	return new( self.color, self.number )
end]]

function card:set_color( color )
	self.color = color
	return self
end

function card:set_number( number )
	self.number = tostring( number )
	return self
end

function card:can_play( existing_card )
	if existing_card.wild and existing_card.color == nil then
		existing_card.color = card.pick_color()
	end
	local col_match = (existing_card.color or "a") == (self.color or "b")
	local num_match = (existing_card.number or -1) == (self.number or -2)
	local typ_match = ((existing_card.name or "a") == (self.name or "b") and (self.name == "draw two" or self.name == "block" or self.name == "reverse"))
	local wil_match = (self.wild or false)
	return col_match or
		num_match or
		typ_match or
		wil_match
end

function card:__tostring()
	local str = self.name
	if self.color ~= nil then
		str = str .. " " .. self.color
	end
	if self.number ~= nil then
		str = str .. " " .. self.number
	end
	return str
end

function card:equals( existing_card )
	return (existing_card.color or "a") == (self.color or "b") and
		(existing_card.number or -1) == (self.number or -2) and
		(existing_card.name or "a") == (self.name or "b")
end

--- LOVE FUNCTIONS ---

function card:sprite( x_pos, y_pos, s, revealed )
	revealed = revealed or false

	local image, quad = love.graphics.newImage( "sprites/cards.png" )
	local x, y = 0, 0
	local w, h = 32, 48

	if self.number ~= nil then
		x = self.number % 2 * 136
		y = math.floor(self.number / 2) * 50
	end
	if self.name == "block" then
		x = 0
		y = 250
	end
	if self.name == "reverse" then
		x = 136
		y = 250
	end
	if self.name == "draw two" then
		x = 0
		y = 300
	end
	if self.color ~= nil then
		local col_number = 0
		if self.color == "yellow" then col_number = 1 end
		if self.color == "green" then col_number = 2 end
		if self.color == "blue" then col_number = 3 end
		x = x + col_number * 34
	elseif self.wild then
		x = 136
	end
	if self.name == "wild" then
		y = 400
	elseif self.name == "draw four" then
		y = 450
	end

	if not revealed then
		x = 0
		y = 500
	end

	quad = love.graphics.newQuad(x, y, w, h, image:getDimensions())
	local debug_print = { text = tostring(self), x = x_pos, y = y_pos }
	local d_l = {
		image = image,
		quad = quad,
		x = x_pos,
		y = y_pos,
		scale = s
	}
	return d_l, debug_print
end

return card