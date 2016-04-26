# good_dog.rb

module Speak
  def speak(sound)
    puts "#{sound}"
  end
end

class GoodDog
  include Speak         # This is called a module "mixin"
end

class HumanBeing
  include Speak         # This is called a module "mixin"
end

sparky = GoodDog.new
sparky.speak("Woof!")

bob = HumanBeing.new
bob.speak("Hello!")

puts
puts GoodDog.ancestors
puts
puts HumanBeing.ancestors
puts
puts sparky.class
puts
puts bob.class
