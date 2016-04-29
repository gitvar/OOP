# my_car.rb

class MyCar

  attr_accessor :color  # accessor method definition.
  attr_reader :year     # Ruby will define these implicitly.

  def initialize(model, year, color)
    self.color = color      # Call accessor (setter) method.
    @year = year        # Only time and way to assign an attr_reader.
    @model = model          # Instance variables defined and assigned
    @speed = 0              # here in the initialization method.
    @engine_running = false
    @status = "Engine switched off and vehicle stationary"
  end

  def info    # year and color accessed via accessor methods.
    "My car is a #{year} #{@model} and is #{color} of color."
  end

  def engine_on
    puts "Engine started"
    @engine_running = true
    @status = "Stationary with engine idling"
  end

  def engine_off
    @engine_running = false
    @status = "Engine off"
    puts "Engine switched off"
  end

  def status_check
    puts "Status = #{@status}."
    puts "Current Speed = #{@speed} km/h."
  end

  def speed_up
    puts "Attempting to speed up!"
    if @engine_running
      if @speed < 160
        @speed += 30
        @status = "Accelerating to #{@speed} km/h"
      else
        @speed = 160
        @status = "Traveling at a maximum of #{@speed} km/h"
      end
    end
  end

  def slow_down
    puts "Applying breaks."
    if @speed > 0
      @speed -= 30
      @status = "Decelerating to #{@speed} km/h"
    else
      @status = "Vehicle now stationary"
    end
  end

  def spray_paint(new_color)
    puts "The car has been sent off to be spray painted #{new_color}"
    self.color = new_color
  end

end

system 'clear'
puts
car1 = MyCar.new("Toyota Yaris", "2007", "Silver")
puts car1.info
puts
car1.status_check
puts
car1.engine_on
car1.status_check
puts
car1.speed_up
car1.speed_up
car1.status_check
puts
car1.slow_down
car1.slow_down
car1.status_check
puts
car1.slow_down
car1.status_check
puts
car1.color = "Blue"
puts "The car is now painted #{car1.color}"
puts "The car as a #{car1.year} model."
puts
car1.spray_paint("Gold")
puts "The color of the car is now #{car1.color}"

# My car is a 2007 Toyota Yaris and is Silver of color.
#
# Status = Engine switched off and vehicle stationary.
# Current Speed = 0 km/h.
#
# Engine started
# Status = Stationary with engine idling.
# Current Speed = 0 km/h.
#
# Attempting to speed up!
# Attempting to speed up!
# Status = Accelerating to 60 km/h.
# Current Speed = 60 km/h.
#
# Applying breaks.
# Applying breaks.
# Status = Decelerating to 0 km/h.
# Current Speed = 0 km/h.
#
# Applying breaks.
# Status = Vehicle now stationary.
# Current Speed = 0 km/h.
#
# The car is now painted Blue
# The car as a 2007 model.
#
# The car has been sent off to be spray painted Gold
# The color of the car is now Gold
