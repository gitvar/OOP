# my_car.rb

class Vehicle
  attr_accessor :color          # accessor instance var & method def.
  attr_reader :year, :model     # reader instance var & method def.
                                # Ruby will define these getter
                                # and setter methods implicitly.

  def initialize(model, year, color)
    self.color = color      # Call accessor (setter) method.
    @year = year        # Only time and way to assign an attr_reader.
    @model = model          # Instance variables defined and assigned
    @speed = 0              # here in the initialization method.
    @engine_running = false
    @status = "Engine switched off and vehicle stationary"
  end

  def info    # year and color accessed via accessor methods.
    "My car is a #{year} #{model}, and is #{color} of color."
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


  # Exercise 1:
  # Class method. Do not use class variables (or instance variables)!
  # It does not make sense to use class variables in this case.
  # We want to calc milage of any car (more than 1).
  def self.calculate_gas_milage(kilometers, liters)
    puts "#{format "%.2f", kilometers.to_f / liters.to_f} km/l."
  end

  # Exercise 2:
  # Changed model to also be of type attr_reader so it is not just an instance variable, but also has getter and setter methods.
  def to_s
    "My car is a #{color}, #{year} model, #{model}"
  end
end

class MyCar < Vehicle

  def initialize(model, year, color)
    super(model, year, color)
  end

  def spray_paint(new_color)
    puts "The car has been sent off to be spray painted #{new_color}"
    self.color = new_color
  end
end


system 'clear'
car1 = MyCar.new("Toyota Yaris", "2007", "silver")
# puts car1.info
car1.status_check
MyCar.calculate_gas_milage(400, 26)
puts car1
