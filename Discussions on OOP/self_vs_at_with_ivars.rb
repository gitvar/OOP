# self_vs_at_with_ivars.rb
# frozen_string_literal: false

class Shoe
  attr_accessor :condition

  # we're initializing the attribute @condition, so we need to call the instance
  # variable directly
  def initialize(condition="new")
    @condition = condition
  end

  # we're changing the value of @condition, so we call the writer method, which
  # needs to be called on self or else Ruby thinks we're just setting a local
  # variable
  def wear
    self.condition = "worn"
    # OR
    # @condition = "worn"
  end

  def cobble
    @condition = "new"
    # OR
    # self.condition = "new"
  end

  # we're just reading the value of @condition, so we can call the reader method
  # (whose implicit receiver is self)
  def report_condition
    if condition == "new"
      "This shoe is in perfect condition!"
    elsif condition == "worn"
      "This shoe needs to be cobbled!"
    else
      "The condition of this shoe is #{condition}."
    end
  end
end

fancy_shoe = Shoe.new
puts fancy_shoe.report_condition
fancy_shoe.wear
puts fancy_shoe.report_condition
fancy_shoe.cobble
puts fancy_shoe.report_condition
