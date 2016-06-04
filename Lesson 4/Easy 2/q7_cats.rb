# Explain what the @@cats_count variable does and how it works. What code would you need to write to test your theory?

class Cat
  @@cats_count = 0

  def initialize(type)
    @type = type
    @age  = 0
    @@cats_count += 1
  end

  def self.cats_count
    @@cats_count
  end
end

# @@cats_count is a class variable. Single instance available over all instances of the class (objects). Used to keep track of how many Car objects were created.

puts Cat.cats_count
kitty = Cat.new("House Cat")
puts kitty
puts Cat.cats_count
blob = Cat.new("Fat Cat")
puts blob
puts Cat.cats_count
