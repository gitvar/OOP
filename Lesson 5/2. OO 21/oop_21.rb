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

  attr_accessor :name, :points, :cards, :games_won, :deck

  def initialize(deck, name)
    @cards = []
    @name = name
    @deck = deck
    @points = 0
    @games_won = 0
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
    puts " Twenty-One "
    puts "============"
  end

  def display_game_info
    puts
    puts "Total games played: #{@total_games}"
    puts "Games won by #{player.name}: #{player.games_won}"
    puts "Games won by the Dealer: #{dealer.games_won}"
    puts "Total games tied: #{@total_tied}"
    puts
  end

  def display_player_hand
    display_game_heading
    display_game_info
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
    @deck = Deck.new
    @player = Human.new(@deck, @human_name)
    @dealer = Dealer.new(@deck, "Dealer")
    @total_games = 0
    @total_tied = 0
    @inc_score = false
    setup_new_game
  end

  def setup_new_game
    @winner = nil
    if @total_games >= 1
      @deck = Deck.new
      @player.deck = @deck
      @dealer.deck = @deck
      @player.points = 0
      @dealer.points = 0
      @player.cards = []
      @dealer.cards = []
    end
  end

  def start
    loop do
      display_game_heading
      display_game_info
      deal_initial_cards
      player.show_cards
      player_turn
      dealer_turn
      determine_result
      break unless play_again?
      setup_new_game
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

  def update_scores(winner = nil)
    return if @inc_score == false
    if winner == :player
      player.games_won += 1
    elsif winner == :dealer
      dealer.games_won += 1
    else
      @total_tied += 1
    end
  end

  def display_result(winner = nil, message = nil)
    message = "#{player.name.upcase}, " + message if winner == :player
    puts message
  end

  def player_got_21?
    return false unless player.got_21?
    update_scores(:player)
    display_player_hand
    display_result(:player, "YOU GOT 21, YOU ARE THE WINNER!")
    true
  end

  def dealer_got_21?
    return false unless dealer.got_21?
    update_scores(:dealer)
    display_both_hands
    display_result(:dealer, "DEALER GOT 21, AND WINS!")
    true
  end

  def player_win?
    return false unless player.total > dealer.total
    update_scores(:player)
    display_both_hands
    display_result(:player, "YOU WIN!")
    true
  end

  def dealer_win?
    return false unless dealer.total > player.total
    update_scores(:dealer)
    display_both_hands
    display_result(:dealer, "DEALER WINS!")
    true
  end

  def tie?
    return false unless dealer.total == player.total
    update_scores
    display_both_hands
    display_result(nil, "IT'S A TIE!")
    true
  end

  def busted?
    if player.busted? && dealer.busted?
      update_scores
      display_both_hands
      display_result(nil, "SORRY, YOU BOTH WENT BUST!")
      return true
    elsif player.busted?
      update_scores(:dealer)
      display_player_hand
      display_result(:dealer, "YOU WENT BUST, THE DEALER WINS!")
      return true
    elsif dealer.busted?
      update_scores(:player)
      display_both_hands
      display_result(:player, "THE DEALER WENT BUST, YOU WIN!")
      return true
    end
    false
  end

  def inc_no_of_games
    @total_games += 1
  end

  def determine_result
    inc_no_of_games
    @inc_score = true
    player_got_21? || busted? || dealer_got_21? || player_win? || dealer_win? || tie?
    @inc_score = false
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
