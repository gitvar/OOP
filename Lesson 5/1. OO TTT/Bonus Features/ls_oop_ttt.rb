# frozen_string_literal: false
class Board
  require 'pry'

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals
  DELIMITER = ', '.freeze
  SEPARATOR = 'or'.freeze

  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def join_unmarked_keys
    keys = unmarked_keys
    keys[-1] = "#{SEPARATOR} #{keys.last}" if keys.size > 1
    keys.size == 2 ? keys.join(' ') : keys.join(DELIMITER)
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

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
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
  end
  # rubocop:enable Metrics/AbcSize

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " ".freeze

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

# Player = Struct.new(:marker, :points)
class Player
  attr_reader :marker
  attr_accessor :points, :name

  def initialize(marker)
    @marker = marker
    @points = 0
    @name = ''
  end

  def increment_points
    @points += 1
  end

  # Below not needed as we have defined the attr_accessor above.
  # def name=(name)
  #   $name = name
  # end
end

module Misc
  def valid_string?(string)
    !!(string =~ /^[A-Z][a-zA-Z]*(-[A-Z][a-zA-Z]*)?$/) # Hyphenated names also.
  end
end

class TTTGame
  require 'pry'
  include Misc

  HUMAN_MARKER = "X".freeze
  COMPUTER_MARKER = "O".freeze
  FIRST_TO_MOVE = HUMAN_MARKER
  NO_OF_ROUNDS_TO_WIN_THE_GAME = 3

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
    obtain_player_names
    @current_marker = FIRST_TO_MOVE
    @round = 1
  end

  def play
    clear_screen
    display_welcome_message

    loop do
      display_board

      loop do
        current_player_moves
        break if board.someone_won? || board.full?
        clear_screen_and_display_board if human_turn?
      end

      display_result_and_increment_round_number
      break unless play_again?
      reset_round_or_game
      # display_play_again_message
    end

    display_goodbye_message
  end

  private

  def define_new_computer_name
    @computer.name = %w(Hal Twiki R2D2 Wall-E Skynet).sample
  end

  def obtain_player_names
    name = nil
    clear_screen
    display_welcome_message
    define_new_computer_name

    loop do
      puts
      puts "Please enter your name:"
      name = gets.chomp
      break if valid_string?(name)
      puts "Sorry, that is not a valid name. Please try again."
    end
    @human.name = name
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def clear_screen_and_display_board
    clear_screen
    display_board
  end

  def human_turn?
    @current_marker == HUMAN_MARKER
  end

  def display_board_static_info
    puts
    puts "      Tic Tac Toe"
    puts "     ============="
    puts
    puts "#{@human.name} is a #{human.marker}.  " \
         "#{@computer.name} is a #{computer.marker}."
    puts
    puts "First one to win #{NO_OF_ROUNDS_TO_WIN_THE_GAME} rounds, wins the " \
         " game!"
    puts
  end

  def display_board
    display_board_static_info
    puts "#{@human.name}'s points: #{@human.points}  " \
         "#{@computer.name}'s points: #{@computer.points}"
    puts
    puts "Round Number: #{@round}"
    puts
    board.draw
    puts
  end

  def human_moves
    puts "Choose a square (#{board.join_unmarked_keys}): "
    # puts "Choose a square (#{board.join_unmarked_keys}): "

    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def computer_moves
    board[board.unmarked_keys.sample] = computer.marker
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = COMPUTER_MARKER
    else
      computer_moves
      @current_marker = HUMAN_MARKER
    end
  end

  def determine_round_or_game_winning_message(player)
    player.increment_points
    winning_message = if player.points < NO_OF_ROUNDS_TO_WIN_THE_GAME
                        "#{player.name} won the round!"
                      else
                        "#{player.name} won the game!"
                      end
    winning_message
  end

  def display_result_and_increment_round_number
    winning_message = case board.winning_marker
                      when human.marker
                        determine_round_or_game_winning_message(human)
                      when computer.marker
                        determine_round_or_game_winning_message(computer)
                      else
                        "It's a tie!"
                      end
    clear_screen_and_display_board
    puts winning_message
    @round += 1
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def clear_screen
    system "clear"
  end

  def reset_round_or_game
    board.reset
    clear_screen
    @current_marker = FIRST_TO_MOVE
    reset_game if @human.points == NO_OF_ROUNDS_TO_WIN_THE_GAME ||
                  @computer.points == NO_OF_ROUNDS_TO_WIN_THE_GAME
  end

  def reset_game
    define_new_computer_name
    @computer.points = 0
    @human.points = 0
    @round = 1
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end
end

game = TTTGame.new
game.play
