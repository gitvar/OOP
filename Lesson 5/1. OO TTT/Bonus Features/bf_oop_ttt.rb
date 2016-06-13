# frozen_string_literal: false
class Board
  attr_reader :squares, :available_markers

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {} # { 1 => ' ', 2 => 'X', 3 => 'X', ... }
    @available_markers = %w(O X H # 0 +)
    @player_markers = []
    initialize_squares
  end

  def valid_marker?(marker)
    available_markers.include?(marker)
  end

  def random_marker
    @player_markers[1] = available_markers.sample
  end

  def make_marker_unavailable(marker)
    @player_markers << marker
    @available_markers.delete_at(available_markers.find_index(marker))
  end

  def []=(key, marker)
    squares[key].marker = marker
  end

  def unmarked_keys
    squares.keys.select { |key| squares[key].unmarked? }
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
      if identical_markers?(squares, 3)
        return squares.first.marker
      end
    end
    nil
  end

  def initialize_squares
    (1..9).each { |key| squares[key] = Square.new }
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

  def keys_for_best_move(marker)
    best_offensive_move_keys = []
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line) # [sq1_obj, sq2_obj, ...]
      if identical_markers?(squares, 2, marker)
        key = unmarked_key_for(line)
        best_offensive_move_keys << key unless !key # Don't want nil.
      end
    end
    best_offensive_move_keys
  end

  def best_key_for_blocking
    keys_for_best_move(@player_markers[0]).sample
  end

  private

  def identical_markers?(squares, number_of_markers, search_marker = nil)
    markers = squares.select(&:marked?).collect(&:marker)
    search_marker ||= markers[0] # same as: a = b if !a
    markers.keep_if { |m| m == search_marker }
    return false if markers.size != number_of_markers
    true
  end

  def unmarked_key_for(line)
    index = nil
    line.each_index { |i| index = line[i] if squares[line[i]].unmarked? }
    index
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
  attr_accessor :name, :marker, :points, :board

  def initialize(board)
    @name = nil
    @marker = nil
    @points = 0
    @board = board
  end

  def increment_points
    @points += 1
  end
end

module Misc
  def valid_string?(name) # Hyphenated names are also valid: "Jean-Claude".
    !!(name =~ /^[A-Z][a-zA-Z]*(-[A-Z][a-zA-Z]*)?$/)
  end
end

class Human < Player
  include Misc

  DELIMITER = ', '.freeze
  SEPARATOR = 'or'.freeze

  def initialize(board)
    super
    self.name = request_human_name
    self.marker = request_human_marker
  end

  def format_for_display(arr)
    array = arr.dup
    array[-1] = "#{SEPARATOR} #{array.last}" if array.size > 1
    array.size == 2 ? array.join(' ') : array.join(DELIMITER)
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
    self.name = human_name
  end

  def request_human_marker
    marker = nil
    board_markers = format_for_display(board.available_markers)
    puts

    loop do
      puts "Please choose which marker to use: #{board_markers}"
      marker = gets.chomp
      if board.valid_marker?(marker)
        board.make_marker_unavailable(marker)
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
      break if board.valid_unmarked_key?(key)
      puts "Sorry, that's not a valid choice."
    end
    board[key] = marker
  end
end

class Computer < Player
  COMPUTER_NAMES = %w(Hal Twiki R2D2 Wall-E Skynet).freeze

  def initialize(board)
    super
    self.name = choose_new_name
    self.marker = choose_marker
  end

  def choose_new_name
    COMPUTER_NAMES.sample
  end

  def choose_marker
    board.random_marker
  end

  def move
    board[decide_best_key_for_move] = marker
  end

  def decide_best_key_for_move
    # Offensive
    offensive_move_keys = board.keys_for_best_move(marker)
    return offensive_move_keys.sample unless offensive_move_keys.empty?

    # Defensive
    key_to_block = board.best_key_for_blocking # human_marker
    return key_to_block if key_to_block

    # Square 5 available?
    return 5 if board.valid_unmarked_key?(5)

    # None of the above? Ok, pick a random unmarked square
    board.unmarked_keys.sample
  end
end

module Display
  def display_board_static_info
    rounds = TTTGame::NO_OF_ROUNDS_TO_WIN_THE_GAME
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

  NO_OF_ROUNDS_TO_WIN_THE_GAME = 3
  HUMAN_MOVES_FIRST = 1
  COMPUTER_MOVES_FIRST = 2
  CHOOSE_WHO_MOVES_FIRST = 3
  FIRST_TO_MOVE = CHOOSE_WHO_MOVES_FIRST

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
    winning_message = if player.points < NO_OF_ROUNDS_TO_WIN_THE_GAME
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
    reset_game if human.points == NO_OF_ROUNDS_TO_WIN_THE_GAME ||
                  computer.points == NO_OF_ROUNDS_TO_WIN_THE_GAME
  end

  def reset_game
    @first_to_move = who_moves_first
    @current_marker = @first_to_move
    clear_screen
    display_play_again_message
    computer.name = computer.choose_new_name
    computer.points = 0
    human.points = 0
    @round = 1
  end
end

game = TTTGame.new
game.play
