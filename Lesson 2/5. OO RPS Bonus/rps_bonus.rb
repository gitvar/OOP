# classes_rps_bonus_features.rb
# frozen_string_literal: false

module Misc
  def pure_string?(string)
    !!(string =~ /^[A-Z][a-zA-Z]*(-[A-Z][a-zA-Z]*)?$/) # Hyphenated names also.
    # !!(string =~ /^[A-z]*$/) # No hyphens allowed in string.
  end
end

module Display
  # The 'clear_screen' method below courtesy of Pete Hanson,
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

  attr_accessor :move, :name, :score

  def initialize
    set_name
    @score = 0
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
  end
end

class Computer < Player
  # require 'pry'

  HMOVE = 0
  CMOVE = 1
  RESULT = 2
  PERSONALITY_MOVE_CHOICE = { 'Hal' => 'Spock', 'T1000' => 'Rock',
                              'C3PO' => 'Paper', 'Marvin' => 'Lizard',
                              'Twiki' => 'Paper', 'EVE' => 'Scissors' }.freeze

  INVERSE_RULES = { 'Rock' => ['Paper', 'Spock'],
                    'Paper' => ['Scissors', 'Lizard'],
                    'Scissors' => ['Rock', 'Spock'],
                    'Lizard' => ['Scissors', 'Rock'],
                    'Spock' => ['Lizard', 'Paper'] }.freeze

  attr_accessor :opponent, :history, :final_weights

  def initialize
    super
    @history = {}
    @opponent = nil
    @losing_move_counter_hash = {}
    init_losing_move_counter_hash
  end

  def set_name
    self.name = ['Hal', 'C3PO', 'Marvin', 'T-1000', 'Twiki', 'EVE'].sample
  end

  def init_losing_move_counter_hash
    VALID_MOVES.each do |a_move|
      @losing_move_counter_hash[a_move] = 1 # Not zero!
    end
  end

  # Look for human wins and corresponding computer moves.
  # -----------------------------------------------------
  # History Hash Structure: {Game No => [Human move, Computer move, Result]}.
  # Result can be one of the following: 'human, 'computer', 'tie'
  # Example after game zero: history = {0 => ["Scissors", "Paper", "human"]}
  def update_losing_move_counters
    init_losing_move_counter_hash
    (0...history.size).each do |i|
      if history[i][RESULT] == "human"
        @losing_move_counter_hash[history[i][CMOVE]] += 1
      end
    end
  end

  def decide_final_move(pre_previous_human_move, previous_human_move, \
                        inverse_move, chosen_move)
    if pre_previous_human_move == previous_human_move
      inverse_move
    else
      chosen_move
    end
  end

  def choose_final_move(chosen_move)
    index = history.size - 1
    previous_human_move = history[index][HMOVE]
    pre_previous_human_move = history[index - 1][HMOVE]
    # previous_comp_move = history[index][CMOVE]
    inverse_move = INVERSE_RULES[previous_human_move][rand(0..1)]
    decide_final_move(pre_previous_human_move, previous_human_move, \
                      inverse_move, chosen_move)
  end

  def inject_personality_prejudice(bad_move, next_move)
    prejudiced_move = PERSONALITY_MOVE_CHOICE[name]
    final_move = if next_move == bad_move && prejudiced_move != bad_move
                   prejudiced_move
                 else
                   choose_final_move(next_move)
                 end
    (VALID_MOVES.index(final_move) + 1)
  end

  def calc_weights(losing_move_counters, max)
    weights = {}
    losing_move_counters.each do |item, weight|
      weights[item] = if weight != 0
                        max / weight
                      else
                        1
                      end
    end
    puts "Weights = #{weights}"
    weights
  end

  def determine_weighed_move(losing_move_counters)
    counter_max = losing_move_counters.values.reduce(:+)
    weights = calc_weights(losing_move_counters, counter_max)
    weight_max = weights.values.reduce(:+)
    random_value = rand(1..weight_max)
    puts "RAND = #{random_value}"
    sum_of_weights = 0
    weights.each do |item, weight|
      sum_of_weights += weight
      return item if random_value <= sum_of_weights
    end
  end

  def select_best_move_for(bad_move, losing_move_counters)
    next_move = determine_weighed_move(losing_move_counters)
    puts "Next Move = #{next_move}"
    inject_personality_prejudice(bad_move, next_move)
  end

  def next_move
    return rand(1..5) if history.size < 2
    bad_move = ''
    update_losing_move_counters
    biggest_losing_move_total = @losing_move_counter_hash.values.max
    return rand(1..5) if biggest_losing_move_total == 0
    @losing_move_counter_hash.each do |key, value|
      bad_move = key if value == biggest_losing_move_total
    end
    select_best_move_for(bad_move, @losing_move_counter_hash)
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
  end
end

class RPSGame
  include Display

  MAX_SCORE = 10
  attr_accessor :human, :computer, :symbol

  def initialize
    self.human = Human.new
    self.computer = Computer.new
    computer.opponent = human
    @winner = nil
    @symbol = []
    @game_number = 0
  end

  def display_goodbye_message
    prompt "Thanks for playing Rock, Paper, Scissors, Lizard, Spock. Good bye!"
  end

  def determine_winner
    @winner = if human.move == computer.move
                "tie"
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
    elsif @winner == computer.name
      computer.score
    end
  end

  def loser_score
    if @winner == human.name
      computer.score
    elsif @winner == computer.name
      human.score
    end
  end

  def display_winner
    prompt
    if human.score == MAX_SCORE || computer.score == MAX_SCORE
      prompt "#{@winner.upcase} wins the MATCH #{winner_score} games" \
             " to #{loser_score}!"
    else
      if @winner != "tie"
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
    end # else it is a tie and there is no winner.
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

  def display_line(number, array)
    print "=>"
    num = (number + 1).to_s
    print num.rjust(6, " ")
    print symbol[number].to_s
    print " ".ljust(10, " ")
    print array[0].to_s.ljust(15, " ")
    puts array[1]
  end

  def display_history_lines
    arr = []
    (0..computer.history.size - 1).each do |num|
      arr[0] = computer.history[num][0]
      arr[1] = computer.history[num][1]
      display_line(num, arr)
    end
  end

  def display_name_line
    print "=>  Game No.".ljust(15, " ")
    print "#{human.name}(#{human.score})".center(14, " ")
    print "  "
    puts "#{computer.name}(#{computer.score})".center(13, " ")
  end

  def update_game_screen_body
    display_name_line
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
    puts
    puts
    display_message("Welcome to the Rock, Paper, Scissors, Lizard, Spock game!")
  end

  def play_intro
    display_game_screen_heading
    update_game_screen_body
  end

  def reset_for_new_game
    @game_number = 0
    human.score = 0
    self.symbol = []
    self.computer = Computer.new
    computer.opponent = human
  end

  def human_wins_match?
    human.score == MAX_SCORE
  end

  def computer_wins_match?
    computer.score == MAX_SCORE
  end

  def test_for_match_end
    if human_wins_match? || computer_wins_match?
      reset_for_new_game
    end
  end

  def update_history
    result = if @winner == human.name
               'human'
             elsif @winner == computer.name
               'computer'
             else
               'tie'
             end
    computer.history[@game_number] =
      [human.move.name, computer.move.name, result]
    @game_number += 1
  end

  def play
    play_intro
    loop do
      human.choose
      computer.choose
      determine_winner
      update_history
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
