# frozen_string_literal: false
module Constants
  WINNING_TOTAL = 21
  DEALER_MAX = 17
end

class Deck
  attr_reader :deck

  CARD_SUITS = %w(Hearts Diamonds Spades Clubs).freeze
  CARD_VALUES = %w(1 2 3 4 5 6 7 8 9 10 Jack Queen King Ace).freeze

  def initialize
    @deck = shuffled_deck
  end

  def shuffled_deck
    new_deck = CARD_VALUES.product(CARD_SUITS)
    new_deck.map! { |card| Card.new(card[0], card[1]) }
    new_deck.shuffle
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

  attr_accessor :card, :cards, :name, :points

  def initialize(deck, name)
    @cards = []
    @name = name
    @deck = deck
    @points = 0
  end

  def change_aces
    cards.each do |card|
      if card.value == "Ace"
        card.value = "Ace_1"
        break if total <= WINNING_TOTAL
      end
    end
  end

  def update_total
    @points = 0
    cards.each { |card| @points += value_of(card) }
  end

  def total
    update_total
    @points
  end

  def value_of(card)
    return card.value.to_i if (1..10).cover?(card.value.to_i)
    return 10 if %w(Jack Queen King).include?(card.value)
    return 11 if card.value == 'Ace'
    return 1 if card.value == 'Ace_1'
  end

  def card=(new_card)
    @cards << new_card
    update_total
  end

  def busted?
    @points > WINNING_TOTAL
  end

  def format_for_display(array)
    array.map do |card|
      card_value = card.value
      card_value = "Ace" if card.value == "Ace_1"
      "#{card_value} of #{card.suit}"
    end
  end

  def show_cards
    heading = "#{name}'s cards:"
    puts
    puts heading
    heading.size.times { |_| print "=" }
    puts
    puts format_for_display(cards)
    puts
    puts "#{name}'s total is: #{total}"
    puts
  end
end

class Human < Hand
  def valid?(answer)
    !!(answer =~ /^[hs]?$/)
  end

  def stay
    answer = nil

    loop do
      puts
      puts "(H)it or (S)tay?"
      answer = gets.chomp.downcase
      break if valid?(answer)
      puts "Sorry, that is not a valid choice! Please try again."
    end
    answer == 's'
  end

  def hit
    self.card = @deck.deal_card
    change_aces if total > WINNING_TOTAL
  end
end

class Dealer < Hand
  def hit
    loop do
      change_aces if total > WINNING_TOTAL
      break if total >= DEALER_MAX
      self.card = @deck.deal_card
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
  include Constants
  include Display

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
      someone_busted? || someone_won?
      break unless play_again?
      reset_game
    end
    puts
    puts "Thanks for playing 'TwentyOne'! Goodbye."
  end

  def player_turn
    loop do
      break if someone_got_21? || player.busted?
      break if player.stay
      player.hit
      display_game_screen
    end
  end

  def dealer_turn
    loop do
      break if someone_got_21? || player.busted?
      break if dealer.total >= DEALER_MAX
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

  def someone_won?
    if player.total == WINNING_TOTAL
      display_game_screen
      puts "YOU GOT 21, YOU WIN!"
    else
      check_other_win_permutations
    end
  end

  def check_other_win_permutations
    player_total = player.total
    dealer_total = dealer.total
    display_results
    if dealer.total == WINNING_TOTAL
      puts "DEALER GOT 21, AND WINS!"
    elsif player_total > dealer_total
      puts "YOU WIN!"
    elsif dealer_total > player_total
      puts "DEALER WINS!"
    elsif dealer_total == player_total
      puts "IT'S A TIE!"
    end
  end

  def someone_busted?
    if player.busted?
      display_game_screen
      puts
      puts "YOU WENT BUST, DEALER WINS!"
      true
    elsif dealer.busted?
      display_results
      puts
      puts "DEALER WENT BUST, YOU WIN!"
      true
    else
      false
    end
  end

  def someone_got_21?
    player.points == WINNING_TOTAL || dealer.points == WINNING_TOTAL
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
