# frozen_string_literal: false

class Board
  require 'pry'
  attr_reader :squares, :available_markers

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {} # { 1 => squares[0], 2 => squares[1], 3 => ... }
    @available_markers = %w(O X H # 0 +)
    @human_marker = nil
    @computer_marker = nil
    initialize_squares
  end

  def initialize_squares
    (1..9).each { |key| squares[key] = Square.new }
  end

  def valid?(object)
    if object.class == String
      available_markers.include?(object)
    else
      unmarked_keys.include?(object)
    end
  end

  def random_marker
    @computer_marker = available_markers.sample
  end

  def random_key
    unmarked_keys.sample
  end

  def assign(marker)
    @human_marker = marker
  end

  def remove(marker)
    @available_markers.delete_at(available_markers.find_index(marker))
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def unmarked_keys
    squares.keys.select { |key| squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |"
    puts "  #{@squares[1].marker}  |  #{@squares[2].marker}  | " \
         "#{@squares[3].marker}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4].marker}  |  #{@squares[5].marker}  | " \
         "#{@squares[6].marker}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7].marker}  |  #{@squares[8].marker}  | " \
         "#{@squares[9].marker}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize

  def three_identical_squares?(squares)
    markers = squares.reject(&:unmarked?).collect(&:marker)
    squares.none?(&:unmarked?) && markers.min == markers.max
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      return squares.first.marker if three_identical_squares?(squares)
    end
    nil
  end

  def two_identical_squares?(squares, mark)
    marks = squares.reject(&:unmarked?).collect(&:marker)
    squares.one?(&:unmarked?) && marks.min == mark && marks.max == mark
  end

  def best_move_for(marker)
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if two_identical_squares?(squares, marker)
        key = line[squares.index(&:unmarked?)] # NBNBNB
        return key if key
      else
        next
      end
    end
    nil
  end

  def defensive_key
    best_move_for(@human_marker)
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
    !unmarked?
  end
end

class Player
  attr_accessor :name, :marker, :points, :board

  def initialize(board)
    @board = board
    @name = obtain_name
    @marker = obtain_marker
    @points = 0
  end

  def increment_points
    @points += 1
  end
end

module NameCheck
  def valid_name?(name) # Hyphenated names are also valid: "Jean-Claude".
    !!(name =~ /^[A-Z][a-zA-Z]*(-[A-Z][a-zA-Z]*)?$/)
  end
end

class Human < Player
  include NameCheck

  DELIMITER = ', '.freeze
  SEPARATOR = 'or'.freeze

  def format_for_display(arr)
    array = arr.dup
    array[-1] = "#{SEPARATOR} #{array.last}" if array.size > 1
    array.size == 2 ? array.join(' ') : array.join(DELIMITER)
  end

  def obtain_name
    human_name = nil

    loop do
      puts
      puts "Please enter your name:"
      human_name = gets.chomp
      break if valid_name?(human_name)
      puts "Sorry, that is not a valid name. Please try again."
    end
    self.name = human_name
  end

  def obtain_marker
    marker = nil
    board_markers = format_for_display(board.available_markers)

    loop do
      puts
      puts "Please choose which marker to use: #{board_markers}"
      marker = gets.chomp
      if board.valid?(marker)
        board.assign(marker)
        board.remove(marker)
        break
      end
      puts "Sorry, that is not a valid choice. Please try again."
    end
    marker
  end

  def move
    key = nil
    square_numbers = format_for_display(board.unmarked_keys)
    loop do
      puts "Choose a square number (#{square_numbers}): "
      key = gets.chomp.to_i
      break if board.valid?(key)
      puts "Sorry, that's not a valid choice."
    end
    board[key] = marker
  end
end

class Computer < Player
  COMPUTER_NAMES = %w(Hal Twiki R2D2 Wall-E Skynet).freeze

  def obtain_name
    COMPUTER_NAMES.sample
  end

  def obtain_marker
    board.random_marker
  end

  def move
    board[best_key] = marker
  end

  def best_key
    # Offensive
    offensive_key = board.best_move_for(marker)
    return offensive_key unless !offensive_key

    # Defensive
    key_to_block = board.defensive_key
    return key_to_block unless !key_to_block

    # Square 5 available?
    key = 5
    return key if board.valid?(key)

    # None of the above? Ok, pick a random unmarked square
    board.random_key
  end
end

module Display
  def display_board_static_info
    rounds = TTTGame::NO_OF_ROUNDS_TO_WIN_A_GAME
    puts
    puts "      Tic Tac Toe"
    puts "     ============="
    puts
    puts "#{human.name} is a #{human.marker}.  " \
         "#{computer.name} is a #{computer.marker}."
    puts
    puts "First one to win #{rounds} rounds, wins the" \
         " game!"
    puts
  end

  def display_board
    display_board_static_info

    puts "Rounds Won: #{human.name}: #{human.points}  " \
         "#{computer.name} : #{computer.points}"
    puts
    puts "Round Number: #{@round}"
    puts
    board.draw
    puts
  end

  def display_result
    message = case board.winning_marker
              when human.marker
                determine_round_or_game_winning_message_for(human)
              when computer.marker
                determine_round_or_game_winning_message_for(computer)
              else
                "It's a tie!"
              end
    clear_screen_and_display_board
    puts message
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

class TTTGame
  include Display

  NO_OF_ROUNDS_TO_WIN_A_GAME = 3
  HUMAN_MOVES_FIRST = :human_first
  COMPUTER_MOVES_FIRST = :computer_first
  CHOOSE_WHO_MOVES_FIRST = :choose
  FIRST_TO_MOVE = :choose

  attr_reader :board, :human, :computer

  def initialize
    clear_screen
    display_welcome_message
    @board = Board.new
    @human = Human.new(board)
    @computer = Computer.new(board)
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
        current_player_move
        break if board.someone_won? || board.full?
        clear_screen_and_display_board if human_turn?
      end

      display_result
      break unless play_again?
      increment_the_round_number
      reset_round_or_game
    end

    display_goodbye_message
  end

  private

  def who_moves_first
    case FIRST_TO_MOVE
    when HUMAN_MOVES_FIRST
      human.marker
    when COMPUTER_MOVES_FIRST
      computer.marker
    when CHOOSE_WHO_MOVES_FIRST
      ask_who_moves_first
    else
      [human.marker, computer.marker].sample
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

    choice == 1 ? human.marker : computer.marker
  end

  def human_turn?
    @current_marker == human.marker
  end

  def current_player_move
    if human_turn?
      human.move
      @current_marker = computer.marker
    else
      computer.move
      @current_marker = human.marker
    end
  end

  def determine_round_or_game_winning_message_for(player)
    player.increment_points
    winning_message = if player.points < NO_OF_ROUNDS_TO_WIN_A_GAME
                        "#{player.name} won the round!"
                      else
                        "#{player.name} won the game!"
                      end
    winning_message
  end

  def increment_the_round_number
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
    board.initialize_squares
    clear_screen
    @current_marker = @first_to_move
    reset_game if human.points == NO_OF_ROUNDS_TO_WIN_A_GAME ||
                  computer.points == NO_OF_ROUNDS_TO_WIN_A_GAME
  end

  def reset_game
    @first_to_move = who_moves_first
    @current_marker = @first_to_move
    clear_screen
    display_play_again_message
    computer.name = computer.obtain_name
    computer.points = 0
    human.points = 0
    @round = 1
  end
end

game = TTTGame.new
game.play
