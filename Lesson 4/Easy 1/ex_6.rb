# What could we add to the class below to access the instance variable @volume?

class Cube

  attr_reader :volume # this line.

  def initialize(volume)
    @volume = volume
  end
end

small_cube = Cube.new(200)
puts small_cube.volume
