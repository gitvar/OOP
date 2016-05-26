# Add Rock Paper Scissors Lizard Spock classes
class Player
  attr_accessor :move, :name, :score, :total_moves

  def initialize
    set_name
    self.score = 0
    self.total_moves = 0
  end
end # end Player

class Human < Player
  def set_name
    puts "Your name?"
    n = ''
    loop do
      n = gets.chomp
      break unless n == ""
      puts "please enter a name"
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Choose r (rock), p (paper) sc (scissors) l (lizard) or s (spock)"
      choice = gets.chomp

      if Move::VALID_SHORT_FORMS.key? choice
        choice = Move::VALID_SHORT_FORMS[choice]
      end

      break if Move::VALUES.include? choice
    end
    self.move = Object.const_get(choice.capitalize).new
    self.total_moves += 1
  end
end # end Human

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Rover', 'Kit'].sample
    puts "You will be playing against #{name}"
    sleep 0.5
  end

  def choose
    self.move = Object.const_get(Move::VALUES.sample.capitalize).new
    self.total_moves += 1
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
  attr_reader :value

  def initialize(value)
    @value = value
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

class Rock < Move
  def initialize
    @value = 'rock'
  end
end

class Paper < Move
  def initialize
    @value = 'paper'
  end
end

class Scissors < Move
  def initialize
    @value = 'scissors'
  end
end

class Lizard < Move
  def initialize
    @value = 'lizard'
  end
end

class Spock < Move
  def initialize
    @value = 'spock'
  end
end

class Rule
  def initialize
    # not sure what the "state" of a rule object should be
  end
end

# not sure where "compare" goes yet
def compare(move1, move2)
end

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
    puts "Thanks for playing. First one to score 5 is the winner.  Good Bye!"
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
    winner = game_winner
    if winner == :human
      human.score += 1
    elsif winner == :computer
      computer.score += 1
    end
  end

  def display_winner
    winner = game_winner
    if winner == :human
      puts "#{human.name} won"
    elsif winner == :computer
      puts "#{computer.name} won"
    else
      puts "It's a tie"
    end
    display_scores
  end

  def display_scores
    puts "SCORE: #{human.name} -> #{human.score} and "\
          "#{computer.name} -> #{computer.score}"
  end

  def win_condition?
    return true if human.score == 5 || computer.score == 5
    false
  end

  def play_again?
    puts ""
    puts ">>>PLAY AGAIN? y or n? First to score 5 wins <<<"
    choice = nil
    loop do
      choice = gets.chomp
      break if choice.downcase.start_with?('y', 'n')
      puts "Please select from y or n"
    end
    choice == 'y' ? true : false
  end

  def add_all_moves
    human.total_moves + computer.total_moves
  end

  def clear_screen
    system 'clear' || 'cls' if add_all_moves % 6 == 0
  end

  def play
    loop do
      human.choose
      computer.choose
      display_moves
      increment_score
      display_winner
      if win_condition? || (add_all_moves % 6 == 0 ? !play_again? : false)
        break
      end
      clear_screen
    end
    display_goodbye_message
  end
end

RPSGame.new.play
