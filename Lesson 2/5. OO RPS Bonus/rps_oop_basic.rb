# rps_oop_basic.rb
# frozen_string_literal: false

class String
  def pure_string?
    !!(self =~ /^([A-z])*$/)
  end
end

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
    n = ''
    prompt "Please enter your name, or just press RETURN and be called 'Master'"
    loop do
      n = gets.chomp
      if n.empty?
        n = "Master"
        break
      elsif n.pure_string?
        break
      else
        prompt "Please enter a valid name."
      end
    end
    self.name = n
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
    self.move = Move.new(Move.format_choice(player_choice))
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
  @format_choices = { 'r' => 'Rock', 'p' => 'Paper', 's' => 'Scissors' }

  def initialize(value)
    @value = value
  end

  def self.format_choice(value)
    @format_choices[value[0].downcase]
  end

  def rock?
    @value == 'Rock'
  end

  def paper?
    @value == 'Paper'
  end

  def scissors?
    @value == 'Scissors'
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
    @value
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
    prompt
    if @winner
      prompt "#{@winner} wins!"
    else
      prompt "It's a tie!"
    end
  end

  def play_again?
    prompt
    prompt "Play again? (N or n) for No, any other key to play again."
    user_choice = gets.chomp.downcase
    user_choice[0] == 'n' ? false : true
  end

  def display_game_screen
    clear_screen
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
      display_game_screen
      human.choose
      display_game_screen
      computer.choose
      determine_winner
      display_moves
      display_winner
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play
