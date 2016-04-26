# MyModule.rb

module Move
  def move(movement_type)
    puts "#{movement_type}"
  end
end

class Horse
  include Move         # This is called a module "mixin"
end

class Human
  include Move         # This is called a module "mixin"
end

shadowfax = Horse.new
shadowfax.move("gallop")

bob = Human.new
bob.move("sprint")
