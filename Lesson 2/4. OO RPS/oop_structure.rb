# oop_structure

# The classical approach to object oriented programming is:
# 1. Write a textual description of the problem or exercise.
# 2. Extract the major nouns and verbs from the description.
# 3. Organize and associate the verbs with the nouns.
# 4. The nouns are the classes and the verbs are the behaviors or methods.

# Step 1: Write out the 'story':
# a. RPS is a 2 player game played in a single turn.
# b. A player can choose one of 3 moves.
# c. The player moves are: Rock, Paper and Scissors.
# d. Each player chooses one of the move in secret.
# e. The moves are compared and the winner is selected as per the game rules.
# f. The game rules are:
# f1. Rock beats Scissors.
# f2. Scissors beats Paper.
# f3. Paper beats Rock.
# g. A winner is declared.
# h. If the moves were the same, the game is declared a tie.
# i. A new game can start again, or not, depending on player choice.

# Step 2: Identify Nouns and Verbs
# Major Nouns: Player, Game, Move, Rule
# Major Verbs: Choose, Compare

# Step 3: Group Verbs with Nouns
# a. Player
# a1. Choose (a Move)
# b. Move
# c. Game
# c1. Compare (and apply rules)
# d. Rule

 # Launch School's answer:
    # Player
    #  - choose
    # Move
    # Rule
    #
    # - compare

module Display

  def clear_screen
    system('clear') || system('cls')
  end

  def prompt(str = "")
    puts "=> #{str}"
  end

end

class Player

  include Display

  attr_accessor :move, :name

  def initialize(player_type = :human)
    @player_type = player_type
    @move = nil
    set_name
  end

  def set_name
    n = nil
    if human?
      loop do
        prompt "Please enter your name."
        n = gets.chomp
        break unless n.empty?
        prompt "Please enter a valid name."
      end
      self.name = n
    else
      self.name = ["Hal", "R2D2", "CP3O", "Chappie", "Marvin"].sample
    end
  end

  def human?
    @player_type == :human
  end

  def choose
    if human?
      player_choice = nil
      loop do
        prompt "Choose one: (R)ock, (P)aper or (S)cissors"
        player_choice = gets.chomp.to_s.downcase
        break if %w(r p s).include?(player_choice[0])
        prompt "Invalid choice, please try again."
      end
      self.move = player_choice
    else
      self.move = %w(r p s).sample
    end
  end

end

class Move

  def initialize

  end

end

class Rule

  def initialize

  end

end

class RPSGame

  include Display

  attr_accessor :human, :computer
  RPS_choices = { 'r' => 'Rock', 'p' => 'Paper', 's' => 'Scissors'}

  def initialize
    @human = Player.new(:human)
    @computer = Player.new(:computer)
    @winner = nil
  end

  def display_welcome_message
    prompt
    prompt "Welcome to the Rock, Paper Scissors, Game!"
    prompt
  end

  def display_goodbye_message
    prompt "Thanks for playing Rock, Paper, Scissors. Good bye!"
  end

  def compare_moves
    if human.move == computer.move
      @winner = nil
    elsif human.move == 'r' && computer.move == 's' ||
          human.move == 'p' && computer.move == 'r' ||
          human.move == 's' && computer.move == 'p'
      @winner = human.name
    else
      @winner = computer.name
    end
  end

  def display_winner
    prompt
    prompt "#{human.name} chose: #{RPS_choices[human.move]}."
    prompt "#{computer.name} chose: #{RPS_choices[computer.move]}."
    compare_moves
    if @winner
      prompt
      prompt "#{@winner} wins!"
    else
      prompt
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
    clear_screen
    display_welcome_message
    loop do
      display_game_screen
      human.choose
      computer.choose
      display_winner
      break unless play_again_2?
    end
    display_goodbye_message
  end

end

RPSGame.new.play
