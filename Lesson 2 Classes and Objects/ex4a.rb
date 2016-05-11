# exercise 4

# If we're trying to determine whether the two objects contain the same name, how can we compare the two objects?

class Person

  attr_accessor :first_name, :last_name

  @@object_array = []

  def initialize(str)
    parse_name(str)

    if @@object_array.empty?
      @@object_array << self
    else
      compare
    end

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

  def compare
    puts "Comparing"
    @@object_array.each do |person_object|
      if person_object.name == self.name
         puts "Self: #{self} has same first and last name as: #{person_object}."
      end
    end
    @@object_array << self
  end

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

# bob.name = "John Adams"
# puts bob.first_name            # => 'John'
# puts bob.last_name             # => 'Adams'

bob = Person.new('Robert Smith')
rob = Person.new('Robert Smith')

puts bob.name
puts rob.name
