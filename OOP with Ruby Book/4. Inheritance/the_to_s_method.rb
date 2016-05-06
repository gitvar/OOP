# the_to_s_method.rb

class Car

  attr_accessor :color # Definition
  attr_reader :year
  attr_writer :model

  def initialize(year, model, color)
    color = color    # Calling the color setter method (not assignment!!!).
    @year = year     # @year has no setter method. Assign with @var = new_var.
    model = model    # @model has setter method since it is an attr_writer.
  end

  # def to_s
  #   "The vehicle is a #{color}, #{year} #{@model}."
  # end
end

my_car = Car.new(2007, "Toyota Yaris Hatchback", "silver")
puts my_car
