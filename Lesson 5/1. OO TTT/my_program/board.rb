class Board
  require 'pry'

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # columns
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {} # @squares = {1 => ' ', 2 => ' ', ...}
    reset
  end

  # This method is no longer needed. 
  # def get_square_at(key)
  #   @squares[key]
  # end

  # def set_square_at(key, marker)
  #   # @squares[key] = Square.new(marker) # creates a new object each time!
  #   @squares[key].marker = marker # Re-uses existing objects. Better!
  # end

  # This []= method replaces 'set_squares_at' for better readability at usage.
  def []=(num, marker)
    @squares[num].marker = marker # Re-uses existing objects. Better!
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end
  #
  # def marker_count(line_of_squares, mark)
  #   # line_of_squares.map { |square| mark if square.marker == mark }.count(mark)
  #   line_of_squares.map(&:marker).count(mark)
  # end

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.max == markers.min
  end

  # return winning marker or nil
  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line) # => [square_obj, square_obj, ...]
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
    puts ""
  end
end
