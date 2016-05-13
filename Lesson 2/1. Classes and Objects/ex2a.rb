# exercise 2

# Modify the class definition from above to facilitate the following methods.
# Note that there is no name= setter method now.

# Hint:
# 1. Let first_name and last_name be "states".
# 2. Create an instance method called 'name' that uses those states.

class Person

  attr_accessor :first_name, :last_name

  def initialize(str)
      names = str.split                 # Array => ["first", "last"]
      self.first_name = names.first
      self.last_name = (names.size > 1 ? names.last : '')
  end

  def name
    "#{first_name} #{last_name}".strip  # Add .strip so that if
                                        # last_name = '', the white
                                        # spaces will be stripped away.
  end
end

bob = Person.new('Robert')
puts bob.name                  # => 'Robert'
puts bob.first_name            # => 'Robert'
puts bob.last_name             # => ''
bob.last_name = 'Smith'
puts bob.name                  # => 'Robert Smith'
