# oop_design1

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
    name = nil
    prompt "Please enter your name."
    loop do
      name = gets.chomp
      break unless name.empty?
      prompt "Please enter a valid name."
    end
    self.name = name
  end

  def choose
    player_choice = nil
    loop do
      prompt "Choose one: (R)ock, (P)aper or (S)cissors"
      player_choice = gets.chomp.to_s.downcase
      break if %w(r p s).include?(player_choice[0])
      prompt "Invalid choice, please try again."
    end
    self.move = player_choice
  end
end

class Computer < Player
  def set_name
    self.name = ["Hal", "R2D2", "CP3O", "Chappie", "Marvin"].sample
  end

  def choose
    self.move = %w(r p s).sample
  end
end

class RPSGame
  include Display
  attr_accessor :human, :computer
  RPS_choices = {'r' => 'Rock', 'p' => 'Paper', 's' => 'Scissors'}

  def initialize
    clear_screen
    display_message("Welcome to the Rock, Paper Scissors, game!")
    self.human = Human.new
    self.computer = Computer.new
    @winner = nil
  end

  def display_goodbye_message
    prompt "Thanks for playing Rock, Paper, Scissors. Good bye!"
  end

  def compare_moves
    if human.move == computer.move
      @winner = nil
    elsif self.human.move == 'r' && computer.move == 's' ||
          self.human.move == 'p' && computer.move == 'r' ||
          self.human.move == 's' && computer.move == 'p'
      @winner = human.name
    else
      @winner = computer.name
    end
  end

  def display_winner
    prompt
    prompt "#{self.human.name} chose: #{RPS_choices[human.move]}."
    prompt "#{self.computer.name} chose: #{RPS_choices[computer.move]}."
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
      display_winner
      break unless play_again_2?
    end
    display_goodbye_message
  end
end

RPSGame.new.play

# 1. Is this design, with Human and Computer sub-classes, better? Why, or why not?
## Yes, it is better. The 'set_name' and 'choose' methods in each sub-class is much simpler than the combined methods of the Player class on its own.

# 2. What is the primary improvement of this new design?
## Simplifies Player class and simplifies 'set_name' and 'choose' methods in the corresponding two sub-classes (Human and Computer).

# 3. What is the primary drawback of this new design?
## Two new sub-classes had to be created (Human and Computer) with the same methods.
