# frozen_string_literal: false
class Board
  require 'pry'

  attr_reader :squares, :available_markers

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals
  DELIMITER = ', '.freeze
  SEPARATOR = 'or'.freeze
  AVAILABLE_MARKERS = %w(O X H # @ * 0 +).freeze

  def initialize
    @squares = {} # { 1 => ' ', 2 => 'X', 3 => 'X', ... }
    @available_markers = AVAILABLE_MARKERS
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

  def initialize(marker=INITIAL_MARKER)
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
  attr_reader :marker
  attr_accessor :name, :points

  def initialize(name, marker)
    @marker = marker
    @name = name
    @points = 0
  end

  def increment_points
    @points += 1
  end
end

module Misc
  def valid_string?(string) # Hyphenated names are also valid.
    !!(string =~ /^[A-Z][a-zA-Z]*(-[A-Z][a-zA-Z]*)?$/)
  end
end

class TTTGame
  require 'pry'
  include Misc

  HUMAN_MOVES_FIRST = 1
  COMPUTER_MOVES_FIRST = 2
  CHOOSE_WHO_MOVES_FIRST = 3
  FIRST_TO_MOVE = CHOOSE_WHO_MOVES_FIRST

  NO_OF_ROUNDS_TO_WIN_THE_GAME = 2
  COMPUTER_NAMES = %w(Hal Twiki R2D2 Wall-E Skynet).freeze

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    computer_name, human_name = obtain_player_names
    human_marker = ask_for_human_marker
    computer_marker = choose_computer_marker(human_marker)
    @human = Player.new(human_name, human_marker)
    @computer = Player.new(computer_name, computer_marker)
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

  def board_marker_list
    markers = @board.available_markers.dup
    markers[-1] = "#{Board::SEPARATOR} #{markers.last}" if markers.size > 1
    markers.size == 2 ? markers.join(' ') : markers.join(Board::DELIMITER)
  end

  def ask_for_human_marker
    marker = nil

    loop do
      board_markers = board_marker_list
      puts
      puts "Please choose which marker to use: #{board_markers}"
      marker = gets.chomp
      break if board_markers.include?(marker)
      puts "Sorry, that is not a valid choice. Please try again."
    end
    marker
  end

  def choose_computer_marker(human_marker)
    available_markers = @board.available_markers.dup
    available_markers.delete_at(available_markers.find_index(human_marker))
    available_markers.sample
  end

  def choose_new_computer_name
    COMPUTER_NAMES.sample
  end

  def obtain_player_names
    human_name = nil
    clear_screen
    display_welcome_message

    loop do
      puts
      puts "Please enter your name:"
      human_name = gets.chomp
      break if valid_string?(human_name)
      puts "Sorry, that is not a valid name. Please try again."
    end
    [choose_new_computer_name, human_name]
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
    @current_marker == @human.marker
  end

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

  def human_moves
    puts "Choose a square (#{board.join_unmarked_keys}): "
    square = nil

    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end
    board[square] = human.marker
  end

  def computer_moves
    best_key = board.decide_best_key_for_move(@computer.marker, @human.marker)
    board[best_key] = computer.marker
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

  def increment_round_number
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
    @current_marker = @first_to_move
    reset_game if @human.points == NO_OF_ROUNDS_TO_WIN_THE_GAME ||
                  @computer.points == NO_OF_ROUNDS_TO_WIN_THE_GAME
  end

  def reset_game
    @first_to_move = who_moves_first
    @current_marker = @first_to_move
    clear_screen
    display_play_again_message
    @computer.name = choose_new_computer_name
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
