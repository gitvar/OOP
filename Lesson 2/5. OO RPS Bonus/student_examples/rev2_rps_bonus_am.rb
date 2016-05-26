# frozen_string_literal: true
# Track history of moves
class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
    self.score = 0
    @history = []
  end

  def update_history
    size = @history.length
    @history[size - 1] = @history[size - 1].upcase
  end

  def history_size
    @history.size
  end

  def history_value(i)
    @history[i]
  end
end # end Player

class Human < Player
  def set_name
    puts "Your name?"
    n = ''
    loop do
      n = gets.chomp.strip
      break unless n == ""
      puts "please enter a name"
    end
    self.name = n
  end

  def choose
    choice = nil
    self.move = Move.new
    loop do
      puts "Choose r (rock), p (paper) sc (scissors) l (lizard) or s (spock)"
      choice = gets.chomp.downcase.strip
      break if move.valid?(choice)
    end
    move.value = move.value_for_human(choice)
    @history << move.value
  end
end # end Human

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Rover', 'Kit'].sample
    puts "You will be playing against #{name}"
    sleep 0.5
  end

  def choose
    self.move = Move.new
    move.value = move.value_for_computer
    @history << move.value
  end
end

class Move
  VALUES = ['rock', 'paper', 'scissors', 'spock', 'lizard'].freeze
  VALID_SHORT_FORMS = { "r" => "rock",
                        "p" => "paper",
                        "sc" => "scissors",
                        "s" => "spock",
                        "l" => "lizard" }.freeze
  ENCOUNTER_RULES = { rock: [:scissors, :lizard],
                      paper: [:rock, :spock],
                      scissors: [:paper, :lizard],
                      lizard: [:spock, :paper],
                      spock: [:scissors, :rock] }.freeze
  attr_accessor :value

  def initialize
    @value = nil
  end

  def valid?(input)
    return true if VALID_SHORT_FORMS.key? input
    false
  end

  def value_for_human(input)
    VALID_SHORT_FORMS[input]
  end

  def value_for_computer
    VALUES.sample
  end

  def >(other_move)
    ENCOUNTER_RULES[value.to_sym].include? other_move.value.to_sym
  end

  def <(other_move)
    ENCOUNTER_RULES[other_move.value.to_sym].include? value.to_sym
  end

  def to_s
    @value
  end
end # end Move

class RPSGame
  attr_accessor :human, :computer

  def initialize
    display_welcome_message
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "WELCOME to Rock, Paper, Scissors, Lizard & Spock!"
    puts "First one to 5 wins is the winner!"
  end

  def display_goodbye_message
    puts "Thanks for playing.  Good Bye!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def game_winner
    if human.move > computer.move
      :human
    elsif human.move < computer.move
      :computer
    end
  end

  def increment_score
    case game_winner
    when :human
      human.score += 1
    when :computer
      computer.score += 1
    end
  end

  def display_winner
    case game_winner
    when :human
      puts "#{human.name} won"
    when :computer
      puts "#{computer.name} won"
    else
      puts "It's a tie"
    end
    display_scores
    change_winner_display
    display_history
  end

  def display_scores
    puts ""
    puts "SCORE: #{human.name} -> #{human.score} and "\
          "#{computer.name} -> #{computer.score}"
    puts ""
    puts "-------------------------------"
  end

  def change_winner_display
    case game_winner
    when :human
      human.update_history
    when :computer
      computer.update_history
    else
      return
    end
  end

  def display_history
    puts " #{human.name.capitalize.ljust(15)}  #{computer.name}"
    puts "-------------------------------"
    human.history_size.times do |i|
      puts " #{human.history_value(i).ljust(15)}  #{computer.history_value(i)}"
    end
    puts "-------------------------------"
  end

  def win_condition?
    human.score == 5 || computer.score == 5
  end

  def play_again?
    puts ""
    puts ">>>PLAY AGAIN? y or n? First to score 5 wins <<<"
    choice = nil
    loop do
      choice = gets.chomp.downcase
      break if choice.start_with?('y', 'n')
      puts "Please select from y or n"
    end
    choice == 'y' ? true : false
  end

  def add_all_moves
    human.history_size * 2
  end

  def clear_screen
    (system 'clear' || 'cls') if add_all_moves % 6 == 0
  end

  def play
    loop do
      human.choose
      computer.choose
      display_moves
      increment_score
      display_winner
      if win_condition?
        break
      end
      clear_screen
    end
    display_goodbye_message
  end
end

RPSGame.new.play
