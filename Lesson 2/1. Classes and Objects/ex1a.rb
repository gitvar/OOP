# exercise 1

class Person

  attr_accessor :name

  def initialize(name)
    self.name = name
  end

end

bob = Person.new('bob')
puts bob.name                  # => 'bob'
bob.name = 'Robert'
puts bob.name                  # => 'Robert'
