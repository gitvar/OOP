# class_method.rb

class GoodDog
  attr_accessor :name, :weight, :height

  def initialize(n, w, h)   # Initialize the object's instance variables
    @name = n
    @weight = w
    @height = h
  end

  def change_info(n, w, h)    # Call the accessor methods when changing the instance variable
    self.name = n             # setter method is called
    self.weight = w
    self.height = h
  end

    def speak
      "#{name} says 'Arf!'"   # name here is actually self.name (getter method)
    end
  def info
    "#{name} weighs #{weight} and is #{height} tall."
  end

end

my_dog = GoodDog.new("Sparky", "8kg", "21.5cm")

my_dog.change_info("Brindle", "8.3kg", "19cm")
puts my_dog.name
puts my_dog.weight
puts my_dog.height
puts
puts my_dog.speak
puts my_dog.info

# Brindle
# 8.3kg
# 19cm
#
# Brindle says 'Arf!'
# Brindle weighs 8.3kg and is 19cm tall.
