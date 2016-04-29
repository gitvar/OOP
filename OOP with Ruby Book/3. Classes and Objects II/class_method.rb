# class_method.rb

class Car

  attr_accessor :color  # accessor method definition.
  attr_reader :year     # Ruby will define these implicitly.

  def initialize(model, year, color)
    self.color = color      # Call accessor (setter) method.
    @year = year            # Only time and way to assign an attr_reader.
    @model = model          # Instance variables defined and assigned
  end

  def info    # year and color accessed via accessor methods.
    "My car is a #{year} #{@model} and is #{color} of color."
  end

  def self.what_am_i
    "I am a Car class"
  end

end

system 'clear'
puts
car1 = Car.new("Toyota Yaris", "2007", "Silver")
puts car1.info
puts
puts Car.what_am_i
