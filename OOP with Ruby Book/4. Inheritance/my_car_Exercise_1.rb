# my_car+exercise_1.rb

class Vehicle

  attr_accessor :color              # accessor instance var & method def.
  attr_reader :year, :model, :type  # reader instance var & method def.
                                    # Ruby will define these getter
                                    # and setter methods implicitly.

  def initialize(model, year, color, type)
    self.color = color      # Call accessor (setter) method.
    @year = year            # Only time and way to assign an attr_reader.
    @model = model          # Instance variables defined and assigned
    @speed = 0              # here in the initialization method.
    @engine_running = false
    @status = "Engine switched off and vehicle stationary"
    @type = type
    @@first_time = 0
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
    puts "Applying the breaks."
    if @speed > 0
      @speed -= 30
      @status = "Decelerating to #{@speed} km/h"
    else
      @status = "Vehicle now stationary"
    end
  end

  # Chapter 3: Exercise 1:
  # Class method. Do not use class variables (or instance variables)!
  # It does not make sense to use class variables in this case.
  # We want to calc milage of any vehicle (more than 1).
  def self.calculate_gas_milage(kilometers, liters)
    puts "#{format "%.2f", kilometers.to_f / liters.to_f} km/l."
  end

  # Chapter 3: Exercise 2:
  # Changed model to also be of type attr_reader so it is not just an instance variable, but also has getter and setter methods.
  def to_s
    if @@first_time == 0
      @@first_time = 1
      "My vehicle is a #{color}, #{year} model #{model} #{type}."
    else
      "Another vehicle of mine is a #{color}, #{year} model #{model} #{type}."
    end
  end

  def spray_paint(new_color)
    puts "The vehicle has been sent off to be spray painted #{new_color}."
    self.color = new_color
  end
end

class MyCar < Vehicle
  NUMBER_OF_DOORS = 4
  TYPE = "car"
  # No need for initialize method in this class - done in superclass.
  def number_of_doors
    NUMBER_OF_DOORS
  end
end

class MyTruck < Vehicle
  NUMBER_OF_DOORS = 2
  TYPE = "truck"
  # No need for initialize method in this class - done in superclass.
  def number_of_doors
    NUMBER_OF_DOORS
  end
end

# system 'clear'
puts
car1 = MyCar.new("Toyota Yaris", "2007", "silver", "hatchback")
puts car1
car1.status_check
MyCar.calculate_gas_milage(400, 26)
puts "My car has #{car1.number_of_doors} doors."

puts

truck1 = MyTruck.new("Hino", "1996", "white", "truck")
puts truck1
truck1.status_check
MyTruck.calculate_gas_milage(500, 80)
puts "My truck has #{truck1.number_of_doors} doors."
