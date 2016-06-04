# If we have this code:

class Greeting
  def self.greet(message) # Add self here AND
    puts message
  end
end

class Hello < Greeting
  def self.hi             # Add self here.
    greet("Hello")
  end
end

class Goodbye < Greeting
  def bye
    greet("Goodbye")
  end
end

# If we call Hello.hi we get an error message. How would you fix this?

Hello.hi
