# Exercise 3

class Person
  # attr_reader :name
  # Change the attr type to:
  attr_accessor :name # Now you can change the instance variable :name.

  def initialize(name)
    @name = name
  end
end

bob = Person.new("Steve")
bob.name = "Bob"

# Error when trying to modify the variable :name. The attr_reader only creates a getter method and not a setter method.
#
# exercise_3.rb:11:in `<main>': undefined method `name=' for #<Person:0x007fb2bc069b10 @name="Steve"> (NoMethodError)
# Did you mean?  name
