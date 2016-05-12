# ex1a.rb

class Pet
  def run
    'running!'
  end

  def jump
    'jumping!'
  end

  def to_s
    'Pet Object.'
  end
end

class Dog < Pet
  def speak
    'bark!'
  end

  def swim
    'swimming!'
  end

  def fetch
    'fetching!'
  end

  def to_s
    'Dog Object.'
  end
end

class Bulldog < Dog
  def swim
    'Sorry, bulldogs can\'t swim!'
  end
end

class Cat < Pet
  def speak
    'Meeoww!'
  end

  def swim
    'Sorry, cats don\'t swim!'
  end

  def fetch
    'Sorry, cats don\'t play fetch at all!'
  end

  def to_s
    'Cat Object.'
  end
end

class Person
  attr_accessor :name, :pets

  def initialize(name)
    @name = name
    @pets = []
  end

  def to_s
    "Person Object: #{name}"
  end
end

bob = Person.new("Robert")
kitty = Cat.new
bud = Bulldog.new
bob.pets << kitty
bob.pets << bud

puts bob
puts kitty
puts bud
p bob.pets
bob.pets.each { |pet| puts pet.jump }
