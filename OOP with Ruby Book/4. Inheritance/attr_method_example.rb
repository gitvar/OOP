# attr_method_example.rb

class Car

  attr_accessor :color # Definition
  attr_reader :year
  attr_writer :model

  def initialize(year, model, color)
    self.color = color    # Calling the color setter method.
    @year = year          # @year has no setter method. Assign with @var=
    self.model = model    # @model has setter method.
  end

  # Manual getter method not needed now. attr_accessor will define it now.
  # def color
  #   @color
  # end
  # Manual setter method not needed now. attr_accessor will define it now.
  # def color=(new_color)
  #   @color = new_color
  # end

  def to_s
    "The vehicle is a #{color}, #{self.year} #{@model}."
    # Above, @color and @year has getter methods, but NOT @model.
    # So use the instance var directly if needed.
    # Better way would have been to make both @year and @model
    # attr_accessor instance vars with the required getters and setters.
  end
end

my_car = Car.new(2007, "Toyota Yaris Hatchback", "silver")

puts my_car.color       # getter method now defined by attr_accessor.
                        # => "silver"

my_car.color = "white"  # setter method now defined. Code working.
puts my_car             # The vehicle is a white, 2007 Toyota Yaris Hatchback.
