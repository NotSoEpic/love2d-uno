local card = dofile "lib/card.lua"
dofile "lib/misc.lua"

player = {}
player.__index = player

function player.new( name, is_ai )
	name = name or "Player"
	is_ai = is_ai or false
	return setmetatable({ cards = {}, name = name, deck = nil, wins = 0, ai = is_ai }, player )
end

function player:clear_cards()
	self.cards = {}
end

function player:add_card( card )
	if card[1] ~= nil then
		for i = 1, #card do
			table.insert( self.cards, card[i] )
		end
	else
		table.insert( self.cards, card )
	end
end

function player:add_random_card( number, basic )
	basic = basic or false
	number = number or 1
	for i = 1, number do
		if basic then
			self:add_card( card.random_basic() )
		else
			self:add_card( card.random() )
		end
	end
end

function player:remove_card( index )
	if type( index ) == "table" then
		for i = 1, #self.cards do
			if self.cards[i]:equals( index ) then
				local card = self.cards[i]
				table.remove( self.cards, i )
				return card
			end
		end
	else
		local card = self.cards[index]
		table.remove( self.cards, index )
		self.cards = self.cards
		return card
	end
end

function player:win()
	self.wins = self.wins + 1
end

function player:can_play( card )
	local can_play, playable_cards = false, {}
	for i = 1, #self.cards do
		if self.cards[i]:can_play( card ) then
			can_play = true
			table.insert( playable_cards, i )
		end
	end
	return can_play, playable_cards
end

function player:get_card_index( existing_card )
	for i = 1, #self.cards do
		if self.cards[i]:equals( existing_card ) then
			return i, false
		end
	end
	return nil, true
end

function player:__tostring()
	local str = self.name
	for i = 1, #self.cards do
		str = str .. "\n" .. tostring( self.cards[i] )
	end
	return str
end

--- LOVE FUNCTIONS ---

function player:show_hand( x1, y1, x2, y2, scale, revealed, filter, filter_function )
	revealed = revealed or false
	local sprites = {}
	local debug_prints = {}
	for i = 1, #self.cards do
		local x, y
		if #self.cards == 1 then
			x = map( 1, 3, x1, x2, 2 )
			y = map( 1, 3, y1, y2, 2 )
		else
			x = map( 1, #self.cards, x1, x2, i )
			y = map( 1, #self.cards, y1, y2, i )
		end
		if filter_function ~= nil then
			x, y = filter_function( self, filter, self.cards[i], x, y )
		end
		local sprite, debug_print = self.cards[i]:sprite( x, y, scale, revealed )
		table.insert( sprites, sprite )
		table.insert( debug_prints, debug_print )
	end
	return sprites, debug_prints
end

return player