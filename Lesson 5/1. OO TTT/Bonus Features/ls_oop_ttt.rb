# frozen_string_literal: false
class Board
  require 'pry'

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals
  DELIMITER = ', '.freeze
  SEPARATOR = 'or'.freeze

  def initialize
    @squares = {} # { 1 => ' ', 2 => 'X', 3 => 'X', ... }
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

  def the_same_markers?(arr, the_marker)
    count = 0
    arr.each do |mark|
      count += 1 if mark == the_marker
    end
    return false if count != 2
    true
  end

  def two_identical_markers?(squares, the_marker)
    markers = squares.select(&:marked?).collect(&:marker) # ['X', 'O']
    return false if markers.size != 2
    return false unless the_same_markers?(markers, the_marker)
    # binding.pry
    true
  end

  def unmarked_key_for(line)
    index = nil
    line.each_index do |i|
      # binding.pry
      index = line[i] if @squares[line[i]].unmarked?
    end
    index
  end

  def keys_for_best_move(marker)
    best_offensive_move_keys = []
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if two_identical_markers?(squares, marker)
        best_offensive_move_keys << unmarked_key_for(line)
      end
    end
    best_offensive_move_keys
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

# Player = Struct.new(:marker, :points)
class Player
  attr_reader :marker
  attr_accessor :points, :name

  def initialize(name, marker)
    @marker = marker
    @name = name
    @points = 0
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

  HUMAN_MOVES_FIRST = 1
  COMPUTER_MOVES_FIRST = 2
  CHOOSE_WHO_MOVES_FIRST = 3
  FIRST_TO_MOVE = CHOOSE_WHO_MOVES_FIRST

  NO_OF_ROUNDS_TO_WIN_THE_GAME = 2

  attr_reader :board, :human, :computer

  def initialize
    @available_markers = %w(O X H # @ * 0 +)
    @computer_names = %w(Hal Twiki R2D2 Wall-E Skynet)
    computer_name, human_name = obtain_player_names
    human_marker = ask_for_human_marker
    computer_marker = choose_computer_marker(human_marker)
    @board = Board.new
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

      display_result_and_increment_round_number
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

  def ask_for_human_marker
    marker = nil

    loop do
      puts
      puts "Please choose which marker to use: #{@available_markers}."
      marker = gets.chomp
      break if @available_markers.include?(marker)
      puts "Sorry, that is not a valid name. Please try again."
    end
    marker
  end

  def choose_computer_marker(human_marker)
    index = @available_markers.find_index(human_marker)
    @available_markers.delete_at(index)
    @available_markers.sample
  end

  def choose_new_computer_name
    @computer_names.sample
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
    # board[board.unmarked_keys.sample] = computer.marker
    arr = board.keys_for_best_move(computer.marker)
    if arr.empty?
      board[board.unmarked_keys.sample] = computer.marker
    else
      # binding.pry
      board[arr.sample] = computer.marker
    end
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
