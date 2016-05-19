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

class Move
  MOVE_WORDS = ['Rock', 'Paper', 'Scissors', 'Lizard', 'Spock'].freeze
  MOVE_LETTERS = ['r', 'p', 's', 'l', 'c'].freeze
  @format_choices = { 'r' => 'Rock', 'p' => 'Paper', 's' => 'Scissors', 'l' => 'Lizard', 'c' => 'Spock' }

  def initialize
  end

  def self.format_choice(value)
    @format_choices[value[0].downcase]
  end

  def beats?(opponent)
    rock? && opponent.scissors? ||
      rock? && opponent.lizard? ||

      paper? && opponent.rock? ||
      paper? && opponent.spock? ||

      scissors? && opponent.paper? ||
      scissors? && opponent.lizard? ||

      lizard? && opponent.spock? ||
      lizard? && opponent.paper? ||

      spock? && opponent.scissors? ||
      spock? && opponent.rock?
  end

  def equals?(opponent)
    name == opponent.name
  end

  def to_s
    self.class.to_s
  end

  def rock?
    name == 'Rock'
  end

  def paper?
    name == 'Paper'
  end

  def scissors?
    name == 'Scissors'
  end

  def lizard?
    name == 'Lizard'
  end

  def spock?
    name == 'Spock'
  end

  def name
    to_s
  end
end

class Rock < Move
end

class Paper < Move
end

class Scissors < Move
end

class Lizard < Move
end

class Spock < Move
end

class Player
  include Display
  attr_accessor :move, :name, :score, :history

  def initialize
    set_name
    @score = 0
    @history = []
  end

  def <<(string)
    history << string
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
    when 'Scissors'
      Scissors.new
    when 'Lizard'
      Lizard.new
    else # 'Spock'
      Spock.new
    end
  end

  # Method 'choose' allows the player to enter a 'move' as a capitalized word (e.g. Rock), or a lowercase word (e.g. rock). Fully uppercase words for a move (e.g. ROCK), and camelcase words like SciSsorS, are vaild entries as well. It also allows for the player to only enter the first letter of a move,  again, in upper or lower case (e.g. r or R).
  def choose
    player_choice = nil
    loop do
      prompt
      prompt "Choose one: (R)ock, (P)aper, (S)cissors, (L)izard, Spo(c)k"
      player_choice = gets.chomp.to_s
      break if Move::MOVE_WORDS.include?(player_choice.downcase.capitalize) ||
               Move::MOVE_LETTERS.include?(player_choice.downcase)
      prompt "Invalid choice, please try again."
    end
    self.move = create_move(Move.format_choice(player_choice))
    history << move.name
  end
end

class Computer < Player
  def set_name
    self.name = ['Hal', 'R2D2', 'CP3O', 'Chappie', 'Marvin', 'T-800', 'T-1000', 'Twiki', 'Wall·E', 'EVE'].sample
  end

  def choose
    self.move = case (1 + rand(5))
                when 1
                  Rock.new
                when 2
                  Paper.new
                when 3
                  Scissors.new
                when 4
                  Lizard.new
                else
                  Spock.new
                end
    history << move.name
  end
end

class RPSGame
  include Display

  MAX_SCORE = 3
  attr_accessor :human, :computer

  def initialize
    clear_screen
    display_message("Welcome to the Rock, Paper, Scissors, Lizard, Spock game!")
    self.human = Human.new
    self.computer = Computer.new
    @winner = nil
  end

  def display_goodbye_message
    prompt "Thanks for playing Rock, Paper, Scissors, Lizard, Spock. Good bye!"
  end

  def determine_winner
    @winner = if human.move.equals?(computer.move)
                nil
              elsif human.move.beats?(computer.move)
                human.name
              else
                computer.name
              end
  end

  def display_moves
    prompt
    prompt "#{human.name} chose: #{human.move}."
    prompt "#{computer.name} chose: #{computer.move}."
  end

  def comentary
    prompt
    if human.score == computer.score
      prompt "Scores are level at this stage."
    elsif human.score > computer.score
      prompt "#{human.name} is leading!"
    else
      prompt "#{human.name} is currently behind."
    end
  end

  def display_winner
    prompt
    if human.score == MAX_SCORE || computer.score == MAX_SCORE
      prompt "#{@winner.upcase} WINS THE MATCH!"
    else
      if @winner
        prompt "#{@winner} won the last game."
      else
        prompt "It's a tie!"
      end
      comentary
    end
  end

  # My version of the 'play_again?' method will only stop the game if the player enters 'N' or 'n'. Otherwise it will play again. This makes it comvenient and FAST, as you can just press the RETURN key to play again.
  def play_again?
    prompt
    prompt "Play again? (N or n) for No, any other key to play again."
    user_choice = gets.chomp.downcase
    user_choice[0] == 'n' ? false : true
  end

  def display_game_results
    return if human.history.empty?
    (0..human.history.size - 1).each do |n|
      if n < 9
        print "=>     #{n + 1} "
      else
        print "=>     #{n + 1}"
      end
      print " ".ljust(10, " ")
      print human.history[n].to_s.ljust(14, " ")
      puts computer.history[n].to_s.ljust(12, " ")
    end
  end

  def display_game_screen
    clear_screen
    prompt
    prompt " Rock, Paper, Scissors, Lizard, Spock"
    prompt "======================================"
    prompt
    print "=>  Game No.".ljust(15, " ")
    print "#{human.name}(#{human.score})".center(14, " ")
    puts "#{computer.name}(#{computer.score})".center(13, " ")
    prompt
    display_game_results
  end

  def update_scores
    if @winner == human.name
      human.score += 1
    elsif @winner == computer.name
      computer.score += 1
    end
  end

  def reset_for_new_game
    human.score = 0
    human.history = []
    self.computer = Computer.new
  end

  def play
    loop do
      display_game_screen
      human.choose
      computer.choose
      display_game_screen # Call again to erase unformatted player input.
      determine_winner
      update_scores
      display_game_screen
      display_winner
      if human.score == MAX_SCORE || computer.score == MAX_SCORE
        reset_for_new_game
      end
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play
