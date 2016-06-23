# frozen_string_literal: false
module Constants
  WINNING_TOTAL = 21
  DEALER_MAX = 17
  CARD_SUITS = %w(Hearts Diamonds Spades Clubs).freeze
  CARD_VALUES = %w(1 2 3 4 5 6 7 8 9 10 Jack Queen King Ace).freeze
end

class Deck
  include Constants

  def initialize
    @deck = shuffled_deck
  end

  def shuffled_deck
    new_deck = CARD_VALUES.product(CARD_SUITS)
    new_deck.map! { |card| Card.new(card[0], card[1]) }.shuffle
  end

  def deal_card
    @deck.pop
  end
end

class Card
  attr_accessor :value, :suit

  def initialize(value, suit)
    @value = value
    @suit = suit
  end
end

class Hand
  include Constants

  attr_accessor :name

  def initialize(deck, name)
    @cards = []
    @name = name
    @deck = deck
    @points = 0
  end

  def change_aces
    @cards.each do |card|
      card.value = "Ace_1" if card.value == "Ace"
      break if sum_of_points <= WINNING_TOTAL
    end
  end

  def value_of(card)
    return card.value.to_i if (1..10).cover?(card.value.to_i)
    return 11 if card.value == 'Ace'
    return 1 if card.value == 'Ace_1'
    10
  end

  def sum_of_points
    @points = 0
    @cards.each { |card| @points += value_of(card) }
    @points
  end

  def total
    change_aces if sum_of_points > WINNING_TOTAL
    @points
  end

  def hit
    @cards << @deck.deal_card
    total
  end

  def busted?
    total > WINNING_TOTAL
  end

  def got_21?
    total == WINNING_TOTAL
  end

  def format_cards_for_display
    @cards.map do |card|
      card_value = card.value
      card_value = "Ace" if card.value == "Ace_1"
      "#{card_value} of #{card.suit}"
    end
  end

  def show_cards
    heading = "#{name}'s cards:"
    puts heading
    heading.size.times { |_| print "=" }
    puts
    puts format_cards_for_display
    puts
    puts "#{name}'s total is: #{total}"
    puts
    puts
  end
end

class Human < Hand
  def stay
    answer = nil

    loop do
      puts
      puts "(H)it or (S)tay?"
      answer = gets.chomp.downcase
      break if %w(h s).include?(answer)
      puts "Sorry, that is not a valid choice! Please try again."
    end
    answer == 's'
  end
end

class Dealer < Hand
end

module Display
  def clear_screen
    system('clear') || system('cls')
  end

  def display_welcome_message
    clear_screen
    puts
    puts
    puts "Welcome to 'Twenty-One', the game."
    puts
  end

  def display_game_heading
    clear_screen
    puts
    puts
    puts " TwentyOne "
    puts "==========="
  end

  def display_player_hand
    display_game_heading
    player.show_cards
  end

  def display_both_hands
    display_player_hand
    dealer.show_cards
  end
end

class TwentyOne
  include Display
  include Constants

  attr_accessor :deck, :player, :dealer

  def initialize
    @human_name = name
    reset_game
  end

  def start
    loop do
      display_game_heading
      deal_initial_cards
      player.show_cards
      player_turn
      dealer_turn
      determine_result
      break unless play_again?
      reset_game
    end
    puts
    puts "Thanks for playing 'Twenty-One'! Goodbye."
  end

  def player_turn
    loop do
      break if player.got_21? || player.busted? || player.stay
      player.hit
      display_player_hand
    end
  end

  def dealer_turn
    loop do
      break if busted? || dealer.got_21? || dealer.total >= DEALER_MAX
      dealer.hit
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

  def player_got_21?
    return false unless player.got_21?
    display_player_hand
    puts "YOU GOT 21, YOU WIN!"
    true
  end

  def dealer_got_21?
    return false unless dealer.got_21?
    display_both_hands
    puts "DEALER GOT 21, AND WINS!"
    true
  end

  def player_win?
    return false unless player.total > dealer.total
    display_both_hands
    puts "YOU WIN!"
    true
  end

  def dealer_win?
    return false unless dealer.total > player.total
    display_both_hands
    puts "DEALER WINS!"
    true
  end

  def tie?
    return false unless dealer.total == player.total
    display_both_hands
    puts "IT'S A TIE!"
    true
  end

  def determine_result
    return if player_got_21?
    return if busted? || dealer_got_21?
    return if player_win? || dealer_win?
    tie?
  end

  def busted?
    if player.busted?
      display_player_hand
      puts
      puts "YOU WENT BUST, DEALER WINS!"
      return true
    elsif dealer.busted?
      display_both_hands
      puts
      puts "DEALER WENT BUST, YOU WIN!"
      return true
    end
    false
  end

  def deal_initial_cards
    2.times do
      player.hit
      dealer.hit
    end
  end

  def valid_name?(name) # Hyphenated names are also valid: "Jean-Claude".
    !!(name =~ /^[A-Z][a-zA-Z]*(-[A-Z][a-zA-Z]*)?$/)
  end

  def name
    display_welcome_message
    human_name = nil

    loop do
      puts
      puts "Please enter your name:"
      human_name = gets.chomp
      break if valid_name?(human_name)
      puts "Sorry, that is not a valid name! Please try again."
    end
    human_name
  end
end

game = TwentyOne.new
game.start
