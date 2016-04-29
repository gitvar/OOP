# good_dog.rb

class GoodDog

  DOG_YEARS = 7

  attr_accessor :name, :age

  def initialize(n, a)
    self.name = n
    self.age = a * DOG_YEARS
  end

end

sparky = GoodDog.new("Sparky", 12)
puts sparky.name
puts sparky.age

sparky.name = "Spartacus"
puts sparky.name

# output:
# =======
# Sparky
# 84
# Spartacus
