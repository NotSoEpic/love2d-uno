local card = dofile "lib/card.lua"

deck = {}
deck.__index = deck

function deck.new( players, starting_cards )
	return setmetatable({ players = players, current_player = 0, direction = 1, card = card.random_basic(), starting_cards = starting_cards or 7 }, deck)
end

function deck:get_current_player()
	return self.players[self.current_player % #self.players + 1] -- arrays starting at one doesnt like modulus :/
end

function deck:get_next_player()
	return self.players[(self.current_player + 1) % #self.players + 1]
end

function deck:set_top_card( card )
	self.card = card
end

function deck:play( index )
	local player = self:get_current_player()
	local next_player = self:get_next_player()
	if player.cards[index]:can_play( self.card ) then
		local card = player:remove_card( index )
		if card.wild and card.color == nil then
			self.color = card.pick_color()
		end
		self:set_top_card( card )
		if card.func ~= nil then
			card.func( self, player, next_player )
		end
		if #player.cards == 0 then
			player:win()
			return card, true
		end
		return card, false
	end
end

function deck:restart()
	self.card = card.random_basic()
	for i = 1, #self.players do
		self.players[i]:clear_cards()
		self.players[i]:add_random_card( self.starting_cards )
	end
end

function deck:advance_player()
	self.current_player = (self.current_player + self.direction) % #self.players
	self.direction = self.direction / math.abs(self.direction)
end

function deck:get_player_order()
	local player_list = {}
	local i = self.current_player
	while #player_list < #self.players do
		table.insert( player_list, self.players[i + 1] )
		if i == self.current_player then
			i = (i + self.direction) % #self.players
		else
			i = (i + (self.direction / math.abs( self.direction ))) % #self.players
		end
		
	end
	return player_list
end

return deck