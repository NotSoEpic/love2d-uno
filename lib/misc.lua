-- gets random function or the cooler random function
local rand = math.random
if love and love.math then rand = love.math.random end

function weighted_choice( list )
	local total_weight, current_weight, target_weight = 0, 0
	for i = 1, #list do
		total_weight = total_weight + (list[i].weight or 0)
	end
	target_weight = rand( total_weight )
	for i = 1, #list do
		current_weight = current_weight + (list[i].weight or 0)
		if current_weight >= target_weight then
			return list[i]
		end
	end
	return list[1]
end

function map( a1, a2, b1, b2, inp )
	return b1 + (inp - a1) * (b2 - b1) / (a2 - a1)
end