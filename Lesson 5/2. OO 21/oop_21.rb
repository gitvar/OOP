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

  def deal_card
    @deck.pop
  end

  private

  def shuffled_deck
    new_deck = CARD_VALUES.product(CARD_SUITS)
    new_deck.map! { |card| Card.new(card[0], card[1]) }.shuffle
  end
end

class Card
  attr_accessor :value, :suit

  def initialize(value, suit)
    @value = value
    @suit = suit
  end
end

class Contestant
  include Constants

  attr_accessor :name, :deck, :cards, :games_won

  def initialize(deck, name)
    @name = name
    @deck = deck
    @cards = []
    @games_won = 0
  end

  def total
    change_aces if new_total > WINNING_TOTAL
    new_total
  end

  def hit
    cards << deck.deal_card
    total
  end

  def busted?
    total > WINNING_TOTAL
  end

  def got_21?
    total == WINNING_TOTAL
  end

  def show_cards(show_full_or_partial_dealer_hand = :full)
    heading = "#{name}'s cards:"
    puts heading
    heading.size.times { |_| print "=" }
    puts
    if show_full_or_partial_dealer_hand == :partial
      show_first_card_only
    else
      puts format_cards_for_display
      puts
      puts "#{name}'s total is: #{total}"
    end
    puts
    puts
  end

  private

  def show_first_card_only
    puts format_first_card
    puts
    puts "#{name}'s total is: #{value_of(cards[0])}"
  end

  def new_total
    cards.map { |card| value_of(card) }.reduce(:+)
  end

  def value_of(card)
    return card.value.to_i if (1..10).cover?(card.value.to_i)
    return 11 if card.value == 'Ace'
    return 1 if card.value == 'Ace_1'
    10
  end

  def format_first_card
    card_value = cards[0].value
    card_value = "Ace" if cards[0].value == "Ace_1"
    "#{card_value} of #{cards[0].suit}"
  end

  def format_cards_for_display
    cards.map do |card|
      card_value = card.value
      card_value = "Ace" if card.value == "Ace_1"
      "#{card_value} of #{card.suit}"
    end
  end

  def change_aces
    cards.each do |card|
      card.value = "Ace_1" if card.value == "Ace"
      break if new_total <= WINNING_TOTAL
    end
  end
end

class Human < Contestant
  def stay?
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

class Dealer < Contestant; end

module Display
  def clear_screen
    system('clear') || system('cls')
  end

  def display_welcome_message
    clear_screen
    puts
    puts "Welcome to 'Twenty-One', the game."
    puts
  end

  def display_game_heading
    clear_screen
    puts
    puts " Twenty-One "
    puts "============"
  end

  def display_game_numbers_info
    puts
    puts "Games played so far: #{@number_of_games}"
    puts "Games won by #{player.name}: #{player.games_won}"
    puts "Games won by the Dealer: #{dealer.games_won}"
    puts "Games tied so far: #{@number_of_tied_games}"
    puts
  end

  def display_player_hand
    display_game_heading
    display_game_numbers_info
    player.show_cards
  end

  def display_both_hands(full_or_partial_dealer_hand)
    display_player_hand
    dealer.show_cards(full_or_partial_dealer_hand)
  end

  def display_goodbye_message
    puts
    puts "Thanks for playing 'Twenty-One'! Goodbye."
  end
end

class TwentyOne
  include Display
  include Constants

  FULL_DEALER_HAND = :full
  PARTIAL_DEALER_HAND = :partial

  attr_accessor :deck, :player, :dealer

  def initialize
    @human_name = name
    @deck = Deck.new
    @player = Human.new(@deck, @human_name)
    @dealer = Dealer.new(@deck, "Dealer")
    @number_of_games = 0
    @number_of_tied_games = 0
    setup_new_game
  end

  def start
    loop do
      display_game_heading
      display_game_numbers_info
      deal_initial_cards
      display_both_hands(PARTIAL_DEALER_HAND)
      player_turn
      dealer_turn
      determine_result
      break unless play_again?
      setup_new_game
    end
    display_goodbye_message
  end

  private

  def setup_new_game
    @winner = nil
    if @number_of_games >= 1
      deck = Deck.new
      player.deck = deck
      dealer.deck = deck
      player.cards = []
      dealer.cards = []
    end
  end

  def player_turn
    loop do
      break if player.got_21? || player.busted? || player.stay?
      player.hit
      display_both_hands(PARTIAL_DEALER_HAND)
    end
  end

  def dealer_turn
    loop do
      break if dealer.busted? || dealer.got_21? || dealer.total >= DEALER_MAX
      dealer.hit
    end
  end

  def update_number_of_games_won(increment_games_won = false, winner = nil)
    return unless increment_games_won
    if winner == :player
      player.games_won += 1
    elsif winner == :dealer
      dealer.games_won += 1
    else
      @number_of_tied_games += 1
    end
  end

  def display_result(winner = nil, message = nil)
    message = "#{player.name.upcase}, " + message if winner == :player
    puts message
  end

  # def player_got_21?(inc_wins)
  #   return false unless player.got_21?
  #   update_number_of_games_won(inc_wins, :player)
  #   display_both_hands(PARTIAL_DEALER_HAND)
  #   display_result(:player, "YOU GOT 21, YOU ARE THE WINNER!")
  #   true
  # end
  #
  # def dealer_got_21?(inc_wins)
  #   return false unless dealer.got_21?
  #   update_number_of_games_won(inc_wins, :dealer)
  #   display_both_hands(FULL_DEALER_HAND)
  #   display_result(:dealer, "DEALER GOT 21, AND WINS!")
  #   true
  # end

  # def busted?(inc_wins = false)
  #   if player.busted?
  #     update_number_of_games_won(inc_wins, :dealer)
  #     display_both_hands(PARTIAL_DEALER_HAND)
  #     display_result(:dealer, "YOU WENT BUST, THE DEALER WINS!")
  #     true
  #   elsif dealer.busted?
  #     update_number_of_games_won(inc_wins, :player)
  #     display_both_hands(FULL_DEALER_HAND)
  #     display_result(:player, "THE DEALER WENT BUST, YOU WIN!")
  #     true
  #   else
  #     false
  #   end
  # end

  def update_and_display(participant, inc_wins, part_of_dealer_hand, message)
    update_number_of_games_won(inc_wins, participant)
    display_both_hands(part_of_dealer_hand)
    display_result(participant, message)
    true
  end

  def results_part_1(inc_wins = false)
    case
    when player.got_21?
      message = "YOU GOT 21, YOU ARE THE WINNER!"
      return update_and_display(:player, inc_wins, PARTIAL_DEALER_HAND, message)
    when player.busted?
      message = "YOU WENT BUST, THE DEALER WINS!"
      return update_and_display(:dealer, inc_wins, PARTIAL_DEALER_HAND, message)
    when dealer.busted?
      message = "THE DEALER WENT BUST, YOU WIN!"
      return update_and_display(:player, inc_wins, FULL_DEALER_HAND, message)
    when dealer.got_21?
      message = "DEALER GOT 21, AND WINS!"
      return update_and_display(:player, inc_wins, FULL_DEALER_HAND, message)
    end
    false
  end

  # def player_win?(inc_wins)
  #   return false unless player.total > dealer.total
  #   update_number_of_games_won(inc_wins, :player)
  #   display_both_hands(FULL_DEALER_HAND)
  #   display_result(:player, "YOU WIN!")
  #   true
  # end
  #
  # def dealer_win?(inc_wins)
  #   return false unless dealer.total > player.total
  #   update_number_of_games_won(inc_wins, :dealer)
  #   display_both_hands(FULL_DEALER_HAND)
  #   display_result(:dealer, "DEALER WINS!")
  #   true
  # end
  #
  # def tie?(inc_wins)
  #   return false unless dealer.total == player.total
  #   update_number_of_games_won(inc_wins, nil)
  #   display_both_hands(FULL_DEALER_HAND)
  #   display_result(nil, "IT'S A TIE!")
  #   true
  # end

  def results_part_2(inc_wins = false)
    case
    when player.total > dealer.total
      message = "YOU WIN!"
      return update_and_display(:player, inc_wins, FULL_DEALER_HAND, message)
    when dealer.total > player.total
      message = "DEALER WINS!"
      return update_and_display(:dealer, inc_wins, FULL_DEALER_HAND, message)
    when dealer.total == player.total
      message = "IT'S A TIE!"
      return update_and_display(:nil, inc_wins, FULL_DEALER_HAND, message)
    end
    false
  end

  def increment_number_of_games
    @number_of_games += 1
  end
  #
  # def results_part_1_comparison?(inc_wins = false)
  #   player_got_21?(inc_wins) || busted?(inc_wins) || dealer_got_21?(inc_wins)
  # end
  #
  # def results_part_2_comparison?(inc_wins = false)
  #   player_win?(inc_wins) || dealer_win?(inc_wins) || tie?(inc_wins)
  # end

  def determine_result
    increment_number_of_games
    inc_wins = true
    # results_part_1_comparison?(inc_wins) || results_part_2_comparison?(inc_wins)
    results_part_1(inc_wins) || results_part_2(inc_wins)
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
end

game = TwentyOne.new
game.start
