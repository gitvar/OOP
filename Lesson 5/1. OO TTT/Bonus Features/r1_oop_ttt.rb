# frozen_string_literal: false

module Constants
  DELIMITER = ', '.freeze
  SEPARATOR = 'or'.freeze
  HUMAN_MOVES_FIRST = 1
  COMPUTER_MOVES_FIRST = 2
  CHOOSE_WHO_MOVES_FIRST = 3
  FIRST_TO_MOVE = CHOOSE_WHO_MOVES_FIRST
  NO_OF_ROUNDS_TO_WIN_THE_GAME = 2
end

module Misc
  def valid_string?(string) # Hyphenated names are also valid.
    !!(string =~ /^[A-Z][a-zA-Z]*(-[A-Z][a-zA-Z]*)?$/)
  end
end

module Display
  include Constants

  def display_board_static_info
    puts
    puts "      Tic Tac Toe"
    puts "     ============="
    puts
    puts "#{@human.name} is a #{human.marker}.  " \
         "#{@computer.name} is a #{computer.marker}."
    puts
    puts "First one to win #{NO_OF_ROUNDS_TO_WIN_THE_GAME} rounds, wins the" \
         " game!"
    puts
  end

  def display_board
    display_board_static_info

    puts "Rounds Won: #{@human.name}: #{@human.points}  " \
         "#{@computer.name} : #{@computer.points}"
    puts
    puts "Round Number: #{@round}"
    puts
    board.draw
    puts
  end

  def display_result
    clear_screen_and_display_board
    puts case board.winning_marker
         when human.marker
           determine_round_or_game_winning_message_for(human)
         when computer.marker
           determine_round_or_game_winning_message_for(computer)
         else
           "It's a tie!"
         end
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end

  def clear_screen_and_display_board
    clear_screen
    display_board
  end

  def clear_screen
    system "clear"
  end
end

class Board
  include Constants

  attr_reader :squares, :available_markers

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals
  AVAILABLE_MARKERS = %w(O X H # @ * 0 +).freeze

  def initialize
    @squares = {} # { 1 => ' ', 2 => 'X', 3 => 'X', ... }
    @available_markers = AVAILABLE_MARKERS.dup
    reset
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def valid_unmarked_key?(key)
    unmarked_keys.include?(key)
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

  def decide_best_key_for_move(computer_marker, human_marker)
    # Offensive
    offensive_move_keys = keys_for_best_move(computer_marker)
    return offensive_move_keys.sample unless offensive_move_keys.empty?

    # Defensive
    key_to_block = best_key_for_blocking(human_marker)
    return key_to_block if key_to_block

    # Square 5 available?
    return 5 if @squares[5].unmarked?

    # None of the above? Ok, pick a random unmarked square
    unmarked_keys.sample
  end

  private

  def unmarked_key_for(line)
    index = nil
    line.each_index { |i| index = line[i] if @squares[line[i]].unmarked? }
    index
  end

  def keys_for_best_move(marker)
    best_offensive_move_keys = []
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line) # [sq1_obj, sq2_obj, ...]
      if two_identical_markers?(squares, marker)
        key = unmarked_key_for(line)
        best_offensive_move_keys << key unless !key # Don't want nil.
      end
    end
    best_offensive_move_keys
  end

  def best_key_for_blocking(human_marker)
    keys_for_best_move(human_marker).sample
  end

  def two_identical_markers?(squares, the_marker)
    markers = squares.select(&:marked?).collect(&:marker) # ['X', 'O']
    markers.keep_if { |v| v == the_marker } # Check for same marker (select!).
    return false if markers.size != 2
    true
  end

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " ".freeze

  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def equal?(passed_in_marker)
    marker == passed_in_marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end

  def to_s
    @marker
  end
end

class Player
  attr_accessor :name, :marker, :points

  def initialize
    @name = nil
    @marker = nil
    @points = 0
  end

  def increment_points
    @points += 1
  end
end

class Human < Player
  include Misc

  def initialize
    super
    request_human_name
  end

  def request_human_name
    human_name = nil

    loop do
      puts
      puts "Please enter your name:"
      human_name = gets.chomp
      break if valid_string?(human_name)
      puts "Sorry, that is not a valid name. Please try again."
    end
    @name = human_name
  end
end

class Computer < Player
  COMPUTER_NAMES = %w(Hal Twiki R2D2 Wall-E Skynet).freeze

  def initialize
    super
    @name = choose_new_name
  end

  def choose_new_name
    COMPUTER_NAMES.sample
  end
end

class TTTGame
  include Constants
  include Display

  attr_reader :board, :human, :computer

  def initialize
    clear_screen
    display_welcome_message
    @board = Board.new
    @human = Human.new
    @computer = Computer.new
    @human.marker = ask_for_human_marker
    @computer.marker = choose_computer_marker(@human.marker)
    @first_to_move = who_moves_first
    @current_marker = @first_to_move
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

      display_result
      increment_round_number
      break unless play_again?
      reset_round_or_game
    end

    display_goodbye_message
  end

  private

  def who_moves_first
    case FIRST_TO_MOVE
    when HUMAN_MOVES_FIRST
      @human.marker
    when COMPUTER_MOVES_FIRST
      @computer.marker
    when CHOOSE_WHO_MOVES_FIRST
      ask_who_moves_first
    else
      [@human.marker, @computer.marker].sample
    end
  end

  def ask_who_moves_first
    choice = nil

    loop do
      puts
      puts "Please choose who will move first: 1. Human Player," \
           " or 2. Computer Player"
      choice = gets.chomp.to_i
      break if [1, 2].include?(choice)
      puts "Sorry, that is not a valid choice. Please try again."
    end

    if choice == 1
      @human.marker
    else
      @computer.marker
    end
  end

  def human_turn?
    @current_marker == @human.marker
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = @computer.marker
    else
      computer_moves
      @current_marker = @human.marker
    end
  end

  def determine_round_or_game_winning_message_for(player)
    player.increment_points
    winning_message = if player.points < NO_OF_ROUNDS_TO_WIN_THE_GAME
                        "#{player.name} won the round!"
                      else
                        "#{player.name} won the game!"
                      end
    winning_message
  end

  def increment_round_number
    @round += 1
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be 'y' or 'n'."
    end

    answer == 'y'
  end

  def reset_round_or_game
    board.reset
    clear_screen
    @current_marker = @first_to_move
    reset_game if @human.points == NO_OF_ROUNDS_TO_WIN_THE_GAME ||
                  @computer.points == NO_OF_ROUNDS_TO_WIN_THE_GAME
  end

  def reset_game
    @first_to_move = who_moves_first
    @current_marker = @first_to_move
    clear_screen
    display_play_again_message
    @computer.name = @computer.choose_new_name
    @computer.points = 0
    @human.points = 0
    @round = 1
  end

  

  def format_array_for_display(array)
    array[-1] = "#{SEPARATOR} #{array.last}" if array.size > 1
    array.size == 2 ? array.join(' ') : array.join(DELIMITER)
  end

  def ask_for_human_marker
    marker = nil

    loop do
      board_markers = format_array_for_display(@board.available_markers)
      puts
      puts "Please choose which marker to use: #{board_markers}"
      marker = gets.chomp
      break if board_markers.include?(marker)
      puts "Sorry, that is not a valid choice. Please try again."
    end
    marker
  end

  def choose_computer_marker(human_marker)
    available_markers = @board.available_markers
    available_markers.delete_at(available_markers.find_index(human_marker))
    available_markers.sample
  end

  def human_moves
    square_numbers = format_array_for_display(@board.unmarked_keys)
    puts "Choose a square number (#{square_numbers}): "
    key = nil

    loop do
      key = gets.chomp.to_i
      # break if board.unmarked_keys.include?(key)
      break if board.valid_unmarked_key?(key)
      puts "Sorry, that's not a valid choice."
    end
    board[key] = human.marker
  end

  def computer_moves
    best_key = board.decide_best_key_for_move(@computer.marker, @human.marker)
    board[best_key] = computer.marker
  end
end

game = TTTGame.new
game.play
