You are calling the `range` method up the ancestry chain from the current
object/class. That method returns a range and is being saved into a variable.
Consider this example:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Animal
  def move
    "walk"
  end
end

class Fish < Animal
  def move
    "Many animals #{super}, but I swim."
  end
end

freddie = Fish.new
freddie.move # => "Many animals walk, but I swim."
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hopefully that helps to clarify.
