# frozen_string_literal: false
class Deck
  attr_reader :deck

  def initialize
    @deck = shuffled_deck
  end

  def shuffled_deck
    card_types = %w(Hearts Diamonds Spades Clubs)
    card_values = %w(1 2 3 4 5 6 7 8 9 10 Jack Queen King Ace)
    card_values.product(card_types).shuffle
  end

  def deal_card
    @deck.pop
  end
end

class Hand
  require 'pry'
  attr_accessor :card, :cards, :name, :points

  def initialize(deck, name)
    @cards = []
    @name = name
    @deck = deck
    @points = 0
  end

  def value_of(card)
    return card[0].to_i if (1..10).include?(card[0].to_i)
    return 10 if %w(Jack Queen King).include?(card[0])
    return 11 if card[0] == 'Ace'
  end

  def card=(new_card)
    @cards << new_card
    @points = @points + value_of(new_card)
  end

  def hit
    puts "#{@name} chose to receive a new card!"
    self.card = @deck.deal_card
  end

  def stay
    puts "#{@name} chose to stay."
  end

  def busted?
    @points > 21
  end

  def total
    @points
  end

  def format_for_display(arr)
    array = arr.dup
    array.map! { |card| "#{card[0]} of #{card[1]}" }
  end

  def show_cards
    heading = "#{name}'s cards:"
    puts
    puts heading
    heading.size.times { |_| print "=" }
    puts
    puts format_for_display(cards)
    puts
    puts "#{@name}'s total is: #{total}"
  end
end

class Human < Hand
  # def valid?(answer)
  #   !!(answer =~ /^[hs]?$/)
  # end
  #
  # def turn_choice
  #   answer = nil
  #
  #   loop do
  #     puts
  #     puts "(H)it or (S)tay?"
  #     answer = gets.chomp.downcase
  #     break if valid?(answer)
  #     puts "Sorry, that is not a valid choice! Please try again."
  #   end
  #   answer
  # end
  #
  # def turn
  #   loop do
  #     break if turn_choice == 's'
  #     hit
  #     game.display_game_screen
  #   end
  # end
end

class Dealer < Hand
  def turn
    loop do
      break if points >= 17
      hit
    end
  end
end

module Display
  def clear_screen
    system('clear') || system('cls')
  end

  def blank_lines(n)
    n.times { puts }
  end

  def display_welcome_message
    clear_screen
    blank_lines(2)
    puts "Welcome to 'TwentyOne', the game."
    puts
  end

  def display_game_heading
    clear_screen
    blank_lines(2)
    puts " TwentyOne "
    puts "==========="
  end

  def display_game_screen
    display_game_heading
    player.show_cards
  end

  def display_results
    display_game_screen
    dealer.show_cards
  end
end

class TwentyOne
  require 'pry'
  include Display

  attr_accessor :deck, :player, :dealer

  def initialize
    @human_name = human_player_name
    reset_game
  end

  def start
    loop do
      display_game_heading
      deal_initial_cards
      player.show_cards
      player_turn
      dealer.turn
      someone_busted? || someone_won?
      break unless play_again?
      reset_game
    end
    puts
    puts "Thanks for playing 'TwentyOne'! Goodbye."
  end

  def valid?(answer)
    !!(answer =~ /^[hs]?$/)
  end

  def turn_choice
    answer = nil

    loop do
      puts
      puts "(H)it or (S)tay?"
      answer = gets.chomp.downcase
      break if valid?(answer)
      puts "Sorry, that is not a valid choice! Please try again."
    end
    answer
  end

  def player_turn
    loop do
      break if turn_choice == 's'
      player.hit
      display_game_screen
      break if player.busted?
    end
  end

  def play_again?
    answer = nil
    puts

    loop do
      puts "Do you want to play another game? (Y)es or (N)o?"
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)
      puts "Sorry, that is not a valid answer! Please try again."
    end
    answer == 'y'
  end

  def reset_game
    @deck = Deck.new
    @player = Human.new(@deck, @human_name)
    @dealer = Dealer.new(@deck, "Dealer")
  end

  def someone_won?
      display_results
      puts
    if player.points == 21
      puts "You got 21, you win!"
    elsif dealer.points == 21
      puts "Dealer got 21, and wins!"
    elsif player.points > dealer.points
      puts "You win!"
    elsif dealer.points > player.points
      puts "Dealer wins!"
    else
      puts "It's a tie!"
    end
  end

  def someone_busted?
    if player.busted?
      display_game_screen
      puts
      puts "You went bust, Dealer wins!"
      true
    elsif dealer.busted?
      display_results
      puts
      puts "Dealer went bust, you win!"
      true
    else
      false
    end
  end

  def someone_got_21?
    player.points == 21 || dealer.points == 21
  end

  def deal_initial_cards
    2.times do
      player.card = deck.deal_card
      dealer.card = deck.deal_card
    end
  end

  def valid_name?(name) # Hyphenated names are also valid: "Jean-Claude".
    !!(name =~ /^[A-Z][a-zA-Z]*(-[A-Z][a-zA-Z]*)?$/)
  end

  def human_player_name
    # display_welcome_message
    # human_name = nil
    #
    # loop do
    #   puts
    #   puts "Please enter your name:"
    #   human_name = gets.chomp
    #   break if valid_name?(human_name)
    #   puts "Sorry, that is not a valid name! Please try again."
    # end
    # human_name
    "Ben"
  end
end

game = TwentyOne.new
game.start
