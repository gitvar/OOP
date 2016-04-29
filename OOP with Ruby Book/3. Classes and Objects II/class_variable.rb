# class_variable.rb

class Car

  attr_accessor :color  # accessor method definition.
  attr_reader :year     # Ruby will define these implicitly.

  # Class Variables:
  @@number_of_cars = 0  # Class var defined with 2x @ symbols.

  def initialize(model, year, color)
    self.color = color      # Call accessor (setter) method.
    @year = year            # Only time and way to assign an attr_reader.
    @model = model          # Instance variables defined and assigned
    @@number_of_cars += 1   # Class var incremented each time init is called.
  end

  def info    # year and color accessed via accessor methods.
    "My car is a #{year} #{@model} and is #{color} of color."
  end

  def self.total_number_of_cars   # Class var accessed via Class method.
    @@number_of_cars
  end
end

system 'clear'
car1 = Car.new("Toyota Yaris", "2007", "Silver")
puts car1.info
car2 = Car.new("Honda Brio", "2013", "White")
puts car2.info
puts "Number of cars already instantiated: #{Car.total_number_of_cars}"

# My car is a 2007 Toyota Yaris and is Silver of color.
# My car is a 2013 Honda Brio and is White of color.
# Number of cars already instantiated: 2
