# MyModule.rb

module Move
  def move(movement_type)
    puts "#{movement_type}"
  end
end

class Horse
  include Move        # This is called a module "mixin"
end

module BiPed          # Second use of modules: Name Spaces
  class Human
    include Move      # This is called a module "mixin"
  end
  class Horse
    include Move
  end
end

shadowfax = Horse.new
shadowfax.move("gallop")

bob = BiPed::Human.new
bob.move("sprint")

binky = BiPed::Horse.new
binky.move("canter")
