# What is used in this class but doesn't add any value?

class Light
  attr_accessor :brightness, :color

  def initialize(brightness, color)
    @brightness = brightness
    @color = color
  end

  def self.information
    # return "I want to turn on the light with a brightness level of super high and a colour of green"
    brightness = 'super low'
    color = 'blue'
    "I want to turn on the light with a brightness level of #{brightness} and a colour of #{color}"
  end

end

# => state variables: brightness and color.
# Also, the 'return' statement is not needed.

puts Light.information
