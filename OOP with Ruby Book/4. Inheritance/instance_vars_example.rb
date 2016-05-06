# instance_vars_example.rb

class Car
  def initialize(year, model, color)
    @color = color    # Instance variables defined and assigned.
    @year = year      # These vars are NOT accessible from the
    @model = model    # outside, except via getter methods.
  end

  # Manual getter method:
  def color         # getter method with same name as instance
    @color          # variable, as is the programmers convention.
  end

  # Manual setter method:
  def color=(new_color) # Could also have defined: def color=new_color
    @color = new_color  #                          end
  end

  def to_s
    "The vehicle is a #{@color}, #{@year} #{@model}."
  end
end

my_car = Car.new(2007, "Toyota Yaris Hatchback", "silver")

#puts my_car.color  # This code was run before the getter method was defined.
                    # Cannot access the color instance var this way!
                    # undefined method `color' for #<Car:0...> (NoMethodError)

puts my_car.color   # getter method now defined. Must have a getter method.
# => "silver"       # Output with getter method defined.

#my_car.color = "white" # Attempt to run this code without setter method
                        # defined. An error is the result!
                        # undefined method `color=' for #<Car:0...>
                        # (NoMethodError)
my_car.color = "white"  # setter method now defined. Code working.
puts my_car
# output:
# $ ruby instance_vars_example.rb
# silver
# The vehicle is a white, 2007 Toyota Yaris Hatchback.
