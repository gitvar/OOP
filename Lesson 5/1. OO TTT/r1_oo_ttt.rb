# frozen_string_literal: false

load 'display.rb'
load 'board.rb'
load 'square.rb'
load 'player.rb'

class TTTGame
  include Display

  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
  end

  def human_moves
    square = 0
    puts "Choose a square between #{board.unmarked_keys}: "
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that is not a valid option."
    end
    # board.set_square_at(square, human.marker)
    board[square] = human.marker
  end

  def computer_moves
    board[board.unmarked_keys.sample] = computer.marker
  end

  def display_result
    clear_screen_and_display_board
    case board.winning_marker
    when HUMAN_MARKER
      puts "You won!"
    when COMPUTER_MARKER
      puts "The computer won!"
    else
      puts "It's a tie!"
    end
  end

  def play_again?
    answer = nil
    puts
    loop do
      puts "Play again (y, n)?"
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)
      puts "Not a valid option!"
    end
    answer == 'y'
  end

  def reset
    board.reset
    clear
  end

  def display_play_again_message
    puts "Let's play again!"
    puts
  end

  def play
    clear
    display_welcome_message
    loop do
      # display_board(clear_screen: false)
      display_board
      loop do
        human_moves
        break if board.someone_won? || board.full?
        computer_moves
        break if board.someone_won? || board.full?
        clear_screen_and_display_board
      end
      display_result
      break if !play_again?
      reset
      display_play_again_message
    end
    display_goodbye_message
  end
end

game = TTTGame.new
game.play
