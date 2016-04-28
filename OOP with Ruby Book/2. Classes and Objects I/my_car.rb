# my_car.rb

class MyCar

  attr_accessor :model, :color
  attr_reader :year

  def initialize(model, year, color)
    system 'clear'
    @year = year
    @color = color
    @model = model
    @speed = 0
    @engine_running = false
    @status = "Engine switched off and vehicle stationary"
  end

  def info
    "My car is a #{year} #{model} and is #{color} of color."
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
