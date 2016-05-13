# exercise 2
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

teddy = Dog.new
puts teddy.speak
puts teddy.swim
puts teddy
puts
bully = Bulldog.new
puts bully.speak
puts bully.swim
puts bully
puts
kitty = Cat.new
puts kitty.speak
puts kitty.fetch
puts kitty.jump
puts kitty.run
puts kitty.swim
puts kitty
