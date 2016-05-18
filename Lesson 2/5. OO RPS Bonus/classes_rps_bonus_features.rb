# classes_rps_bonus_features.rb
# frozen_string_literal: false

# I have tried to add an extra method to the String class which checks to see that only valid alphabetic characters are allowed in the string.
class String
  def pure_string?
    !!(self =~ /^([A-z])*$/)
  end
end

module Display
  # The 'clear_screen' method below by way of feedback given by Pete Hanson to another student. Thanks Pete!
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
    nm = ''
    prompt "Please enter your name, or just press RETURN and be called 'The Master'"
    loop do
      nm = gets.chomp
      if nm.empty?
        nm = "The Master"
        break
      elsif nm.pure_string? # See above for this method's definition.
        break
      else
        prompt "Please enter a valid name."
      end
    end
    self.name = nm
  end

  def create_move(choice)
    case choice
    when 'Rock'
      Rock.new
    when 'Paper'
      Paper.new
    else # 'Scissors'
      Scissors.new
    end
  end

  # Method 'choose' allows the player to enter a 'move' as a capitalized word (e.g. Rock), or a lowercase word (e.g. rock). Fully uppercase words for a move (e.g. ROCK), and camelcase words like SciSsorS, are vaild entries as well. It also allows for the player to only enter the first letter of a move,  again, in upper or lower case (e.g. r or R).
  def choose
    player_choice = nil
    loop do
      prompt "Choose one: (R)ock, (P)aper or (S)cissors"
      player_choice = gets.chomp.to_s
      break if Move::MOVE_WORDS.include?(player_choice.downcase.capitalize) ||
               Move::MOVE_LETTERS.include?(player_choice.downcase)
      prompt "Invalid choice, please try again."
    end
    self.move = create_move(Move.format_choice(player_choice))
  end
end

class Computer < Player
  def set_name
    self.name = ['Hal', 'R2D2', 'CP3O', 'Chappie', 'Marvin', 'T-800', 'T-1000', 'Twiki', 'Dr. Theopolis', 'Wall·E', 'EVE'].sample
  end

  def choose
    self.move = case (1 + rand(3))
                when 1
                  Rock.new
                when 2
                  Paper.new
                else
                  Scissors.new
                end
  end
end

class Move
  include Display
  attr_reader :rps_strings

  MOVE_WORDS = ['Rock', 'Paper', 'Scissors'].freeze
  MOVE_LETTERS = ['r', 'p', 's'].freeze
  @format_choices = { 'r' => 'Rock', 'p' => 'Paper', 's' => 'Scissors' }

  def self.format_choice(value)
    @format_choices[value[0].downcase]
  end
end

class Rock < Move
  def to_s
    'Rock'
  end

  def >(opponent_move)
    opponent_move.class.to_s == 'Scissors'
  end

  def <(opponent_move)
    opponent_move.class.to_s == 'Paper'
  end
end

class Paper < Move
  def to_s
    'Paper'
  end

  def >(opponent_move)
    opponent_move.class.to_s == 'Rock'
  end

  def <(opponent_move)
    opponent_move.class.to_s == 'Scissors'
  end
end

class Scissors < Move
  def to_s
    'Scissors'
  end

  def >(opponent_move)
    opponent_move.class.to_s == 'Paper'
  end

  def <(opponent_move)
    opponent_move.class.to_s == 'Rock'
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

  # My version of the 'play_again?' method will only stop the game if the player enters 'N' or 'n'. Otherwise it will play again. This makes it comvenient and FAST, as you can just press the RETURN key to play again.
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
      display_game_screen # Method called again to erase actual player input.
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
