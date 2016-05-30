def calc_weight_inverse(weights, max)
  inverse_weights = {}
  weights.each do |item, weight|
    inverse_weights[item] = max / weight
  end
  inverse_weights
end

def weighed_move(weights)
  max = weights.values.reduce(:+)
  inverse_weights = calc_weight_inverse(weights, max)
  inverse_max = inverse_weights.values.reduce(:+)
  random_value = rand(1..inverse_max)
  sum_of_weights = 0
  inverse_weights.each do |item, weight|
    sum_of_weights += weight
    return item if random_value <= sum_of_weights
  end
end

current_state = { Rock: 3, Paper: 1, Scissors: 2, Lizard: 1, Spock: 3 }
move_counter_hash = { Rock: 0, Paper: 0, Scissors: 0, Lizard: 0, Spock: 0 }
i = 0
while (i < 50000) do
  move = weighed_move(current_state)
  move_counter_hash[move] += 1
  i += 1
end

p current_state
p move_counter_hash
