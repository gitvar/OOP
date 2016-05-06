# my_car_exercise_6.rb

require 'time'                                         # Exercise_6

module Towable                                         # Exercise_3
  def can_tow?(pounds)
    pounds < 2000 ? "Yes" : "No"
  end
end

class Vehicle
  attr_accessor :color
  attr_reader :model, :prod_date, :age
  @@number_of_vehicles = 0                             # Exercise_2

  def initialize(prod_date, model, color)
    @prod_date = prod_date
    @model = model
    @color = color
    @current_speed = 0
    @@number_of_vehicles += 1                          # Exercise_2
  end

  def speed_up(number)
    @current_speed += number
    puts "You push the gas and accelerate by #{number} mph."
  end

  def brake(number)
    if @current_speed > number
      @current_speed -= number
      puts "You push the brakes and decelerate by #{number} mph."
    elsif @current_speed > 0 && @current_speed <= number
      puts "You push the brakes and come to a halt."
    else
      puts "You are already stationary."
    end
  end

  def stop
    @current_speed = 0
    puts "You stop the car by applying the breaks."
  end

  def current_speed
    puts "You are now going #{@current_speed} mph."
  end

  def shut_down
    if @current_speed == 0
      puts "Parked with engine shut down."
      true
    else
      puts "Attempting to shut down the engine."
      puts "First bring your vehicle to a stand still please!"
      false
    end
  end

  def spray_paint(color)
    self.color = color
    puts "Your new #{color} paint job looks great!"
  end

  def self.gas_mileage(gallons, miles)
    puts "#{miles / gallons} miles per gallon of gas"
  end

  def self.number_of_vehicles_instantiated                # Exercise_2
    @@number_of_vehicles
  end

  def age_of_vehicle
    calc_age    # Cannot use self.calc_age, as calc_age is a private method.
  end

  private

  def calc_age                                            # Exercise_6
    yrs = Time.now.year - prod_date
    mnths = Time.now.month
    "The vehicle is #{yrs} years and #{mnths} months old."
  end
end

class MyTruck < Vehicle
  include Towable                                         # Exercise_3

  NUMBER_OF_DOORS = 2

  def to_s
    "My truck  is a #{self.color}, #{self.prod_date}, #{self.model}!"
  end
end

class MyCar < Vehicle
  NUMBER_OF_DOORS = 4

  def to_s
    "My car is a #{self.color}, #{self.prod_date}, #{self.model}!"
  end
end

lumina = MyCar.new(1997, 'chevy lumina', 'white')
puts lumina
# lumina.speed_up(20)
# lumina.current_speed
# lumina.speed_up(20)
# lumina.current_speed
# lumina.brake(20)
# lumina.current_speed
# if !lumina.shut_down
#   lumina.stop
# end
# lumina.shut_down
MyCar.gas_mileage(13, 351)
puts lumina.age_of_vehicle
