# frozen_string_literal: false
# Ben and Alyssa are working on a vehicle management system. So far, they have created classes called Auto and Motorcycle to represent automobiles and motorcycles. After having noticed common information and calculations they were performing for each type of vehicle, they decided to break out the commonality into a separate class called WheeledVehicle. This is what their code looks like so far:

module Vehicle
  # I did not know modules could also have attr_* methods!
  attr_accessor :speed, :heading
  attr_writer :fuel_capacity, :fuel_efficiency

  def range
    @fuel_capacity * @fuel_efficiency
  end

  #  Part of my original answer below:
  # ==================================
  # def speed(s_par_1, s_par_2)
  #   # some code to work out the speed
  # end
  #
  # def heading(h_par_1, h_par_2)
  #   # some code to work out the heading
  # end
end

class WheeledVehicle
  include Vehicle
  # attr_accessor :speed, :heading # My original answer here - correct.

  def initialize(tire_array, km_traveled_per_liter, liters_of_fuel_capacity)
    @tires = tire_array
    @fuel_efficiency = km_traveled_per_liter
    @fuel_capacity = liters_of_fuel_capacity
  end

  def tire_pressure(tire_index)
    @tires[tire_index]
  end

  def inflate_tire(tire_index, pressure)
    @tires[tire_index] = pressure
  end
end

class Auto < WheeledVehicle
  def initialize
    # 4 tires at various tire pressures
    super([30, 30, 32, 32], 50, 25.0)
  end
end

class Motorcycle < WheeledVehicle
  def initialize
    # 2 tires at various tire pressures along with
    super([20, 20], 80, 8.0)
  end
end

# Now Alan has asked them to incorporate a new type of vehicle into their system - a Catamaran defined as follows:

class Catamaran
  include Vehicle

  attr_accessor :propeller_count, :hull_count

  def initialize(num_propellers, num_hulls, km_traveled_per_liter, liters_of_fuel_capacity)
    @fuel_capacity = liters_of_fuel_capacity
    @fuel_efficiency = km_traveled_per_liter
    @propeller_count = num_propellers
    @hull_count = num_hulls
    # ... rest of the code omitted ...
  end
end

# This new class does not fit well with the object hierarchy defined so far. Catamarans don't have tires. But we still want common code to track fuel efficiency and range. Modify the class definitions and move code into a Module, as necessary, to share code among the Catamaran and the wheeled vehicles.
