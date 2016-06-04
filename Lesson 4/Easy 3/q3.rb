# Given the class below, how do we create two different instances of this class, both with separate names and ages?

class AngryCat
  def initialize(age, name)
    @age  = age
    @name = name
  end

  def age
    puts @age
  end

  def name
    puts @name
  end

  def hiss
    puts "Hisssss!!!"
  end
end

kitty = AngryCat.new(4, "Kitty")
kitty.hiss

puts

lady = AngryCat.new(6, "Lady")
lady.age
