# classes_rps_bonus_features.rb
# frozen_string_literal: false

module Misc
  def pure_string?(string)
    !!(string =~ /^([A-z])*$/)
  end
end

module Display
  # The 'clear_screen' method below by way of feedback given by
  # Pete Hanson to another student. Thanks Pete!
  def clear_screen
    system('clear') || system('cls')
  end

  def display_welcome_screen
    clear_screen
    display_message("Welcome to the Rock, Paper, Scissors, Lizard, Spock game!")
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
  require 'pry'
  MOVE_WORDS = ['Rock', 'Paper', 'Scissors', 'Lizard', 'Spock'].freeze
  MOVE_LETTERS = ['r', 'p', 's', 'l', 'c'].freeze
  FORMAT_CHOICES = { 'r' => 'Rock', 'p' => 'Paper', 's' => 'Scissors',
                     'l' => 'Lizard', 'c' => 'Spock' }.freeze

  def self.format_choice(value)
    return 'Spock' if value.capitalize == 'Spock'
    FORMAT_CHOICES[value[0].downcase]
  end

  def self.valid?(a_move)
    MOVE_WORDS.include?(a_move.capitalize) ||
      MOVE_LETTERS.include?(a_move.downcase)
  end

  def ==(opponent)
    name == opponent.name
  end

  def rock?
    false
  end

  def paper?
    false
  end

  def scissors?
    false
  end

  def lizard?
    false
  end

  def spock?
    false
  end

  def name
    to_s
  end

  def to_s
    self.class.to_s
  end
end

class Rock < Move
  def rock?
    true
  end

  def beats?(opponent)
    opponent.scissors? || opponent.lizard?
  end
end

class Paper < Move
  def paper?
    true
  end

  def beats?(opponent)
    opponent.rock? || opponent.spock?
  end
end

class Scissors < Move
  def scissors?
    true
  end

  def beats?(opponent)
    opponent.paper? || opponent.lizard?
  end
end

class Lizard < Move
  def lizard?
    true
  end

  def beats?(opponent)
    opponent.spock? || opponent.paper?
  end
end

class Spock < Move
  def spock?
    true
  end

  def beats?(opponent)
    opponent.scissors? || opponent.rock?
  end
end

class Player
  include Display
  VALID_MOVES = ['Rock', 'Paper', 'Scissors', 'Lizard', 'Spock'].freeze
  attr_accessor :move, :name, :score, :history, :analysis_history, :opponent

  def initialize
    set_name
    @score = 0
    @history = []
    @analysis_history = []
    @opponent = nil
    @move_counter_hash = {}
    @move_percentage_hash = {}
    init_move_hashes
  end

  def init_move_hashes
    VALID_MOVES.each do |the_move|
      @move_counter_hash[the_move] = 0
      @move_percentage_hash[the_move] = 0
    end
  end

  def <<(string)
    history << string
  end
end

class Human < Player
  include Misc

  def set_name_intro
    clear_screen
    display_welcome_screen
    prompt "Please enter your name, or just press RETURN and be" \
           " called 'The Master'"
  end

  def set_name
    set_name_intro
    name = ''
    loop do
      name = gets.chomp
      if name.empty?
        name = "The Master"
        break
      elsif pure_string?(name)
        break
      else
        prompt "Please enter a valid name."
      end
    end
    self.name = name
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

  def choose
    player_choice = nil
    loop do
      prompt
      prompt "Choose one: (R)ock, (P)aper, (S)cissors, (L)izard, Spo(c)k"
      player_choice = gets.chomp.to_s
      break if Move.valid?(player_choice)
      prompt "Invalid choice, please try again."
    end
    self.move = create_move(Move.format_choice(player_choice))
    history << move.name
  end
end

class Computer < Player
  def set_name
    self.name = ['Hal', 'R2D2', 'CP3O', 'Chappie', 'Marvin', 'T-800',
                 'T-1000', 'Twiki', 'Wall·E', 'EVE'].sample
  end

  def update_move_counters
    # Look for human wins and corresponding own moves.
    init_move_hashes
    step = 2
    counter = 0
    loop do
      if analysis_history[step] == "human"
        @move_counter_hash[analysis_history[step - 2]] += 1
      end
      step += 3
      counter += 1
      break if counter >= analysis_history.size / 3
    end
  end

  def analyse_history
    update_move_counters
    total = @move_counter_hash.values.reduce(:+) # Total human wins thus far
    if total > 0
      @move_counter_hash.each do |key, value|
        @move_percentage_hash[key] = (value.to_f / total.to_f * 100).to_i
      end
    end
  end

  def select_move(weights)
    new_random_move_percentage = 1 + rand(100)

    prompt "New_random_move_percentage = #{new_random_move_percentage}"

    case new_random_move_percentage
    when weights[0]..weights[1]
      1
    when weights[2]..weights[3]
      2
    when weights[4]..weights[5]
      3
    when weights[6]..weights[7]
      4
    when weights[8]..weights[9]
      5
    end
  end

  # 1----23-45----67----89----10, chance of "Paper" is small.
  # 1----23----45----67-89----10, chance of "Lizard" is small.
  def weights_for_move(gaps)
    n1 = 0
    n2 = n1 + gaps[1] # n1_gap
    n3 = n2 + 1
    n4 = n3 + gaps[2] # n3_gap
    n5 = n4 + 1
    n6 = n5 + gaps[3] # n5_gap
    n7 = n6 + 1
    n8 = n7 + gaps[4] # n7_gap
    n9 = n8 + 1
    n10 = n9 + gaps[5] # n9_gap
    [n1, n2, n3, n4, n5, n6, n7, n8, n9, n10]
  end

  def calc_new_weights(bad_move, gap)
    n1_gap = n3_gap = n5_gap = n7_gap = n9_gap = ((100 - gap) / 4)
    case bad_move
    when "Rock"
      n1_gap = gap
    when "Paper"
      n3_gap = gap
    when "Scissors"
      n5_gap = gap
    when "Lizard"
      n7_gap = gap
    when "Spock"
      n9_gap = gap
    end
    gaps = [gap, n1_gap, n3_gap, n5_gap, n7_gap, n9_gap]
    weights_for_move(gaps)
  end

  def calc_new_gap(percentage)
    case percentage
    when 40..101
      5
    else
      20
    end
  end

  def calc_weights_for_move(bad_move, percentage)
    gap = calc_new_gap(percentage)
    calc_new_weights(bad_move, gap)
  end

  def select_best_move_for(bad_move, percentage)
    weights = calc_weights_for_move(bad_move, percentage)
    select_move(weights)
  end

  def next_move
    bad_move = '-'
    analyse_history
    highest_percentage = @move_percentage_hash.values.max
    if highest_percentage == 0
      (1 + rand(5))
    else
      @move_percentage_hash.each do |key, value|
        bad_move = key if highest_percentage == value
      end
      select_best_move_for(bad_move, highest_percentage)
    end
  end

  def choose
    self.move = case next_move
                when 1
                  Rock.new
                when 2
                  Paper.new
                when 3
                  Scissors.new
                when 4
                  Lizard.new
                when 5
                  Spock.new
                end
    history << move.name
    analysis_history << move.name
    analysis_history << opponent.move.name
  end
end

class RPSGame
  require 'pry'
  include Display

  MAX_SCORE = 8
  attr_accessor :human, :computer, :symbol

  def initialize
    self.human = Human.new
    self.computer = Computer.new
    computer.opponent = human
    human.opponent = computer
    @winner = nil
    @symbol = []
  end

  def display_goodbye_message
    prompt "Thanks for playing Rock, Paper, Scissors, Lizard, Spock. Good bye!"
  end

  def determine_winner
    @winner = if human.move == computer.move
                computer.analysis_history << "tie"
                nil
              elsif human.move.beats?(computer.move)
                computer.analysis_history << "human"
                human.name
              else
                computer.analysis_history << "computer"
                computer.name
              end
  end

  def display_moves
    prompt
    prompt "#{human.name} chose: #{human.move}."
    prompt "#{computer.name} chose: #{computer.move}."
  end

  def human_score_equals?
    human.score == computer.score
  end

  def human_score_greater?
    human.score > computer.score
  end

  def commentary
    prompt
    if human_score_equals?
      prompt "Scores are level at this stage."
    elsif human_score_greater?
      prompt "#{human.name} is leading!"
    else
      prompt "#{human.name} is currently behind."
    end
  end

  def winner_score
    if @winner == human.name
      human.score
    else
      computer.score
    end
  end

  def loser_score
    if @winner == human.name
      computer.score
    else
      human.score
    end
  end

  def display_winner
    prompt
    prompt
    if human.score == MAX_SCORE || computer.score == MAX_SCORE
      prompt "#{@winner.upcase} wins the MATCH #{winner_score} games" \
             " to #{loser_score}!"
    else
      if @winner
        prompt "#{@winner} won the last game."
      else
        prompt "It's a tie!"
      end
      commentary
      @winner = nil
    end
  end

  def play_again?
    prompt
    loop do
      prompt "Play again? 'N' or 'n' for No, or press 'RETURN' to play again."
      user_choice = gets.chomp.downcase
      return true if user_choice == ''
      return false if user_choice[0] == 'n'
      prompt "Sorry, I did not understand your input. Try again."
    end
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
    human.analysis_history = []
    self.symbol = []
    self.computer = Computer.new
    computer.opponent = human
  end

  def winner_symbol
    if @winner == computer.name
      "#"
    elsif @winner == human.name
      '*'
    else
      ' '
    end
  end

  def update_winning_symbol
    symbol << winner_symbol
  end

  def display_line_number_with_symbol(line_numbers)
    if line_numbers < 9
      print "=>    #{line_numbers + 1}#{symbol[line_numbers]} "
    else
      print "=>    #{line_numbers + 1}#{symbol[line_numbers]}"
    end
  end

  def display_history_line(num)
    print " ".ljust(10, " ")
    print human.history[num].to_s.ljust(14, " ")
    puts computer.history[num].to_s.ljust(12, " ")
  end

  def display_history_lines
    (0..human.history.size - 1).each do |num|
      display_line_number_with_symbol(num)
      display_history_line(num)
    end
  end

  def display_name_score_line
    print "=>  Game No.".ljust(15, " ")
    print "#{human.name}(#{human.score})".center(14, " ")
    print "  "
    puts "#{computer.name}(#{computer.score})".center(13, " ")
  end

  def update_game_screen_body
    display_name_score_line
    display_history_lines
  end

  def display_game_screen_heading
    clear_screen
    prompt
    prompt " Rock, Paper, Scissors, Lizard, Spock"
    prompt "======================================"
    prompt
    prompt "First one to win #{MAX_SCORE} games, wins the match!"
    prompt
  end

  def display_welcome_screen
    clear_screen
    display_message("Welcome to the Rock, Paper, Scissors, Lizard, Spock game!")
  end

  def play_intro
    display_game_screen_heading
    update_game_screen_body
  end

  def test_for_match_end
    if human.score == MAX_SCORE || computer.score == MAX_SCORE
      reset_for_new_game
    end
  end

  def play
    play_intro
    loop do
      human.choose
      computer.choose
      determine_winner
      update_scores
      update_winning_symbol
      play_intro
      display_winner
      test_for_match_end
      break unless play_again?
      play_intro
    end
    display_goodbye_message
  end
end

RPSGame.new.play

# Main Loop Logic:
# 1. Display welcome screen
# 2. Ask for player name
# 3. Display game screen heading
# 4. Ask for player input:
# 4.1. Update player move history
# 5. Make computer choice:
# 5.1. Update computer move history
# 6. Determine winner
# 7. Update Scores
# 8. Update Game screen to:
# 8.1: Update Game screen to show new scores.
# 8.2: Update Game screen to show previous moves by both players.
# 9. If MAX_GAMES reached declare winner AND reset for new Match.
# 10. If MAX_SCORE reached, declare winner AND reset for new Game.
# 11. Ask to play again
# 12. If play again LOOP back to 3.
