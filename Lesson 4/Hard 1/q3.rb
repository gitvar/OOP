# frozen_string_literal: false

# Building on the prior vehicles question, we now must also track a basic motorboat. A motorboat has a single propeller and hull, but otherwise behaves similar to a catamaran. Therefore, creators of Motorboat instances don't need to specify number of hulls or propellers. How would you modify the vehicles code to incorporate a new Motorboat class?

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

class Boats
  include Vehicle

  attr_accessor :propeller_count, :hull_count

  def initialize(num_propellers, num_hulls, km_traveled_per_liter, \
                 liters_of_fuel_capacity)
    @propeller_count = num_propellers
    @hull_count = num_hulls
    @fuel_capacity = liters_of_fuel_capacity
    @fuel_efficiency = km_traveled_per_liter
  end
end

class Catamaran < Boats
  def initialize(num_propellers, num_hulls, km_traveled_per_liter, \
                 liters_of_fuel_capacity)
    super
    # ... rest of the code omitted ...
  end
end

class Motorboat < Boats
  def initialize(km_traveled_per_liter, liters_of_fuel_capacity)
    super(1, 1, km_traveled_per_liter, liters_of_fuel_capacity)
    # @propeller_count = num_propellers
    # @hull_count = num_hulls
  end
end
