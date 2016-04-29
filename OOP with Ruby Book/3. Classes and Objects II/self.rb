# self.rb

class GoodDog

  DOG_YEARS = 7

  attr_accessor :name, :age

  @@total_number_of_dogs = 0

  def initialize(n, a)
    self.name = n
    self.age = a * DOG_YEARS
    @@total_number_of_dogs += 1
  end

  def GoodDog.total_number_of_dogs
    "Total GoodDog instances: #{@@total_number_of_dogs}"
  end
end

sparky = GoodDog.new("Sparky", 12)
puts sparky.name
puts sparky.age
puts GoodDog.total_number_of_dogs
# Sparky
# 84
# Total GoodDog instances: 1
