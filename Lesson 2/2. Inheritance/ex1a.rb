# exercise 1

class Dog
  def speak
    'bark!'
  end

  def swim
    'swimming!'
  end

  def fetch
    'fetching!'
  end
end

class Bulldog < Dog
  def swim
    'Sorry, don\'t want to swim!'
  end
end

teddy = Dog.new
puts teddy.speak          # => "bark!"
puts teddy.swim           # => "Bulldogs can't swim!"  /   # => "swimming!"
puts
bully = Bulldog.new
puts bully.speak
puts bully.swim
puts bully
