# rpsls_bonus_features.rbv
# frozen_string_literal: false

module Display
  def clear_screen
    system('clear') || system('cls')
  end

  def prompt(str = "")
    puts "=> #{str}"
  end

  def display_message(message)
    prompt
    prompt message
    prompt
  end
end

class Player
  include Display
  attr_accessor :move, :name

  def initialize
    set_name
  end
end

class Human < Player
  def set_name
    n = nil
    prompt "Please enter your name."
    loop do
      n = gets.chomp
      break unless n.empty?
      prompt "Please enter a valid name."
    end
    self.name = n
  end

  def correct_player_choice(choice)
    if choice.length > 1
      choice.downcase.capitalize
    else
      choice.downcase
    end
  end

  def choose
    player_choice = nil
    loop do
      prompt "Choose one: (R)ock, (P)aper or (S)cissors"
      player_choice = gets.chomp.to_s
      break if Move::VALUES.include?(player_choice.downcase.capitalize) ||
               Move::SINGLE_VALUES.include?(player_choice.downcase)
      prompt "Invalid choice, please try again."
    end
    player_choice = correct_player_choice(player_choice)
    self.move = Move.new(player_choice)
  end
end

class Computer < Player
  def set_name
    self.name = ["Hal", "R2D2", "CP3O", "Chappie", "Marvin"].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

class Move
  include Display
  attr_reader :rps_strings

  VALUES = ['Rock', 'Paper', 'Scissors'].freeze
  SINGLE_VALUES = ['r', 'p', 's'].freeze

  def initialize(value)
    @value = value
  end

  def rock?
    @value == 'Rock' || @value == 'r'
  end

  def paper?
    @value == 'Paper' || @value == 'p'
  end

  def scissors?
    @value == 'Scissors' || @value == 's'
  end

  def >(other_move)
    rock? && other_move.scissors? ||
      paper? && other_move.rock? ||
      scissors? && other_move.paper?
  end

  def <(other_move)
    scissors? && other_move.rock? ||
      rock? && other_move.paper? ||
      paper? && other_move.scissors?
  end

  def to_s
    if @value.length > 1
      @value
    else
      case @value
      when 'r'
        'Rock'
      when 'p'
        'Paper'
      when 's'
        'Scissors'
      end
    end
  end
end

class RPSGame
  include Display
  attr_accessor :human, :computer

  def initialize
    clear_screen
    display_message("Welcome to the Rock, Paper, Scissors game!")
    self.human = Human.new
    self.computer = Computer.new
    @winner = nil
  end

  def display_goodbye_message
    prompt "Thanks for playing Rock, Paper, Scissors. Good bye!"
  end

  def determine_winner
    @winner = if human.move > computer.move
                human.name
              elsif human.move < computer.move
                computer.name
              end
  end

  def display_moves
    prompt "#{human.name} chose: #{human.move}."
    prompt "#{computer.name} chose: #{computer.move}."
  end

  def display_winner
    determine_winner
    prompt
    if @winner
      prompt "#{@winner} wins!"
    else
      prompt "It's a tie!"
    end
  end

  def play_again_1?
    prompt
    prompt "Play again? (S) to Stop, any other key to continue."
    user_choice = gets.chomp.downcase
    user_choice[0] == 's' ? false : true
  end

  def play_again_2?
    user_choice = nil
    loop do
      prompt
      prompt "Want to play again? (y/n)."
      user_choice = gets.chomp
      break if ['y', 'n'].include?(user_choice.downcase)
      prompt "Sorry, only 'y' or 'n'are valid inputs."
    end
    user_choice == 'y' ? true : false
  end

  def display_game_screen
    prompt
    prompt " Rock, Paper, Scissors"
    prompt "======================="
    prompt
    prompt "Player 1: #{human.name}"
    prompt "Player 2: #{computer.name}"
    prompt
  end

  def play
    loop do
      clear_screen
      display_game_screen
      human.choose
      computer.choose
      display_moves
      display_winner
      break unless play_again_2?
    end
    display_goodbye_message
  end
end

RPSGame.new.play

# 1. What is the primary improvement of this new design?
# The simplification of the decision of who wins method:
# def compare_moves
#   @winner = if human.move > computer.move
#               human.name
#             elsif human.move < computer.move
#               computer.name
#             else
#               nil
#             end
# end
# 2. What is the primary drawback of this new design?
# Addition of an extra class Move, to the four previously existing classes (RPS_Game, Player, Human and Computer).
