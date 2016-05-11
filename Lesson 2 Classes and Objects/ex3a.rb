# exercise 3

# Now create a smart name= method that can take just a first name or a full name, and knows how to set the first_name and last_name appropriately.

class Person

  attr_accessor :first_name, :last_name

  def initialize(str)
    parse_name(str)
  end

  def name
    "#{first_name} #{last_name}".strip  # Add .strip so that if
                                        # last_name = '', the white
                                        # spaces will be stripped away.
  end

  def name=(str)
    parse_name(str)
  end

  private

  def parse_name(str)
    names = str.split                   # Array => ["first", "last"]
    self.first_name = names.first
    self.last_name = (names.size > 1 ? names.last : '')
  end
end

bob = Person.new('Robert')
puts bob.name                  # => 'Robert'
puts bob.first_name            # => 'Robert'
puts bob.last_name             # => ''
bob.last_name = 'Smith'
puts bob.name                  # => 'Robert Smith'

bob.name = "John Adams"
puts bob.first_name            # => 'John'
puts bob.last_name             # => 'Adams'
