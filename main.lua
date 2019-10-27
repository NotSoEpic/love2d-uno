-- papyrus would be proud of this spaghetti
love.graphics.setDefaultFilter( "linear", "nearest" )
card = dofile "lib/card.lua"
player = dofile "lib/player.lua"
deck = dofile "lib/deck.lua"
dofile "lib/misc.lua"

local rand = math.random
if love and love.math then rand = love.math.random end

function love.load()

	draw_list = {}
	game_print = {}
	debug_print = {}

	game = deck.new({ player.new( "Uno", false ), player.new( "Dos", true ), player.new( "Tres", true ), player.new( "Cuatro", true )})
	game:restart()

	progress = 0
	inputs = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f" } -- if you need more... rip
	card_input = ""
	awaiting_input = false
	played_index = 0

	delay = 75
	count = 0

	function always_do_pre()
		draw_list = {}
		game_print = {}
		debug_print = {}
	end

	function always_do_post()
		local test_sprite, test_print = game.card:sprite( 350, 200, 2, true )
		table.insert( draw_list, test_sprite )
		table.insert( debug_print, test_print )

		table.insert( game_print, { text = game:get_current_player().name, x = 350, y = 320 })

		local player_list = game:get_player_order()
		for i = 2, #player_list do
			local x_start = map( 3, #player_list * 2, 25, 675, i * 2 - 1 )
			local x_end = map( 3, #player_list * 2, 25, 675, i * 2 )
			table.insert( game_print, { text = player_list[i].name, x = x_start, y = 5 })
			local player_cards = player_list[i]:show_hand( x_start, 20, x_end, 20, 1, false)
			for i = 1, #player_cards do
				table.insert( draw_list, player_cards[i] )
			end
		end
	end
end

function love.draw()
	if game:get_current_player().ai then
		count = count + 1
		if count >= delay then
			count = 0
			progress = progress + 1
		end
	else
		count = 0
	end

	if progress == 0 then -- show current hand
		progress = progress + 1
		always_do_pre()

		local can_play, playable_cards = game:get_current_player():can_play( game.card )
		if can_play then
			progress = progress + 2
		end

		local lis, deb = game:get_current_player():show_hand( 25, 400, 675, 400, 2, not game:get_current_player().ai )
		for i = 1, #lis do
			table.insert( draw_list, lis[i] )
		end

		for i = 1, #deb do
			table.insert( debug_print, deb[i] )
		end

		always_do_post()
	end



	if progress == 2 then -- draw card if you cant play
		progress = progress + 1
		always_do_pre()		

		local can_play, playable_cards = game:get_current_player():can_play( game.card )
		if not can_play then
			game:get_current_player():add_random_card()
		end

		--[[local can_play, playable_cards = game:get_current_player():can_play( game.card )
						if not can_play then
							progress = progress + 2
						end]]

		local lis, deb = game:get_current_player():show_hand( 25, 400, 675, 400, 2, not game:get_current_player().ai, game.card, function( player, filter_card, current_card, x, y )
			if current_card:can_play( filter_card ) then
				y = y - 30
			end
			return x, y
		end )
		for i = 1, #lis do
			table.insert( draw_list, lis[i] )
		end

		for i = 1, #deb do
			table.insert( debug_print, deb[i] )
		end

		always_do_post()
	end



	if progress == 3 then -- play card
		always_do_pre()
		local can_play, playable_cards = game:get_current_player():can_play( game.card )

		awaiting_input = not game:get_current_player().ai

		if awaiting_input and can_play then
			local available_inputs = {}
			for i = 1, #playable_cards do
				table.insert( available_inputs, { inp = inputs[i], out = playable_cards[i] })
				table.insert( game_print, { text = inputs[i], x = map( 1, #game:get_current_player().cards, 25, 675, playable_cards[i]), y = 350 })
			end
			for i = 1, #available_inputs do
				if card_input == available_inputs[i].inp then
					card_input = ""
					awaiting_input = false
					played_index = available_inputs[i].out
				end
			end
		end
		if not awaiting_input then
			progress = progress + 1
			
			if can_play then
				if game:get_current_player().ai then
					played_index = playable_cards[rand( #playable_cards )]
				end
				local played_card, winning_move = game:play( played_index )
				local played_index = 0
				if winning_move then
					game:restart()
				end
			end
		end
		local lis, deb = game:get_current_player():show_hand( 25, 400, 675, 400, 2, not game:get_current_player().ai, game.card, function( player, filter_card, current_card, x, y )
			if current_card:can_play( filter_card ) and not player.ai then
				y = y - 30
			end
			return x, y
		end )
		for i = 1, #lis do
			table.insert( draw_list, lis[i] )
		end

		for i = 1, #deb do
			table.insert( debug_print, deb[i] )
		end

		always_do_post()
	end



	if progress == 4 then -- just show remaining hand
		progress = progress + 1
		always_do_pre()

		if awaiting_input then
			game:get_current_player():add_random_card()
		end

		local lis, deb = game:get_current_player():show_hand( 25, 400, 675, 400, 2, false )
		for i = 1, #lis do
			table.insert( draw_list, lis[i] )
		end

		for i = 1, #deb do
			table.insert( debug_print, deb[i] )
		end

		always_do_post()
	end
	


	if progress == 6 then
		game:advance_player()
	end



	progress = progress % 6

	love.graphics.setColor(1, 1, 1, 1)
	for i = 1, #draw_list do
		love.graphics.draw( draw_list[i].image, draw_list[i].quad, draw_list[i].x, draw_list[i].y, 0, draw_list[i].scale, draw_list[i].scale )
	end
	love.graphics.setColor(0.5, 0.5, 0.5, 1)
	for i = 1, #game_print do
		love.graphics.print( game_print[i].text, game_print[i].x, game_print[i].y )
	end
	for i = 1, #debug_print do
		--love.graphics.print( debug_print[i].text, debug_print[i].x, debug_print[i].y - 10 )
	end

	--love.graphics.print( card_input, 10, 10 )
	--love.graphics.print( progress, 10, 20 )
end

function love.keypressed( key, scancode, isrepeat ) 
	if key == "space" and not game:get_current_player().ai then
		progress = progress + 1
	end
end

function love.textinput(t)
    card_input = t
end