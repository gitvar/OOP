users  = { rock: 4, paper: 1, scissors: 2, lizard: 1, spock: 2 }
raffle = []

system 'clear'

users.map do |name, tickets|
  tickets.times { raffle << name }
end

p raffle

counter = 0
loop do
  p raffle.sample
  break if counter > 10
  counter += 1
end

users_total = users.values.reduce(:+)
p users_total
users_max = users.values.max
p users_max
users_min = users.values.min
p users_min
