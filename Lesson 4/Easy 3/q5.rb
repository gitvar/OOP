# If I have the following class:

class Television
  def self.manufacturer
    # method logic
  end

  def model
    # method logic
  end
end

# What would happen if I called the methods like shown below?

tv = Television.new
tv.manufacturer
# => undefined method `manufacturer' for #<Television:0x007fb631855540> (NoMethodError) /// undefined method for Television OBJECT.
tv.model

Television.manufacturer
Television.model
# => undefined method `model' for Television:Class (NoMethodError)
# undefined method for Television CLASS.
