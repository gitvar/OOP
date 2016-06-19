~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def three_identical_markers?(squares)
    markers = squares.reject(&:unmarked?).collect(&:marker)
    squares.none?(&:unmarked?) && markers.min == markers.max
  end
  
  def two_identical_markers(squares)
    markers = squares.reject(&:unmarked?).collect(&:marker)
    squares.one?(&:unmarked?) && markers.min == markers.max
  end
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

 

def identical\_markers?(squares, number\_of\_markers, search\_marker = nil)

markers = squares.select(&:marked?).collect(&:marker)

search\_marker \|\|= markers[0] \# same as: a = b if !a

markers.keep\_if { \|m\| m == search\_marker }

return true if markers.size == number\_of\_markers

false

end
