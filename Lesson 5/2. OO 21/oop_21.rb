# frozen_string_literal: false
class Deck
  CARD_SUITS = %w(Hearts Diamonds Spades Clubs).freeze
  CARD_FACES = %w(1 2 3 4 5 6 7 8 9 10 Jack Queen King Ace).freeze

  def initialize
    @deck = new_shuffled_deck
  end

  def deal_card
    @deck.pop
  end

  private

  def new_shuffled_deck
    new_deck = CARD_SUITS.product(CARD_FACES)
    new_deck.map! { |card| Card.new(card[0], card[1]) }.shuffle!
    new_deck.shuffle!.shuffle!
  end
end

class Card
  attr_accessor :suit, :face, :value

  def initialize(suit, face)
    @face = face
    @suit = suit
    @value = insert_value
  end

  def insert_value
    if (1..10).cover?(@face.to_i)
      @face.to_i
    elsif @face == "Ace"
      11
    else
      10
    end
  end
end

module Hand
  WINNING_TOTAL = 21
  DEALER_MAX = 17

  def hit(card)
    hand << card
  end

  def busted?
    total > WINNING_TOTAL
  end

  def got_21?
    total == WINNING_TOTAL
  end

  def total
    if sum > WINNING_TOTAL
      hand.each do |card|
        card.value = 1 if card.face == 'Ace'
        break if sum <= WINNING_TOTAL
      end
    end
    sum
  end

  def show_hand(full_or_partial = :full)
    display_hand_heading
    if full_or_partial == :full
      show_all_cards
    else
      show_first_card
    end
  end

  private

  def sum
    hand.map(&:value).reduce(:+)
  end

  def display_hand_heading
    puts "#{name}'s hand:"
    "#{name}'s hand:".size.times { print "=" }
    puts
  end

  def show_all_cards
    puts format_cards_for_display
    puts
    puts "#{name}'s total is: #{total}"
    puts
    puts
  end

  def format_cards_for_display
    hand.map do |card|
      "#{card.face} of #{card.suit}"
    end
  end

  def show_first_card
    puts format_first_card
    puts
    puts "#{name}'s total is: #{hand[0].value}"
    puts
    puts
  end

  def format_first_card
    "#{hand[0].face} of #{hand[0].suit}"
  end
end

class Contestant
  include Hand

  attr_accessor :name, :hand, :games_won

  def initialize
    @name = obtain_name
    @hand = []
    @games_won = 0
  end
end

class Player < Contestant
  def obtain_name
    name = nil
    loop do
      puts
      puts "Please enter your name:"
      name = gets.chomp
      break if valid_name?(name)
      puts "Sorry, that is not a valid name! Please try again."
    end
    name
  end

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

  private

  def valid_name?(name)
    !!(name =~ /^[A-Z][a-zA-Z]*(-[A-Z][a-zA-Z]*)?$/)
  end
end

class Dealer < Contestant
  def obtain_name
    %w(Twiki Hal WallE T-1000 CP30).sample
  end

  def stay?
    total >= DEALER_MAX && total <= WINNING_TOTAL
  end
end

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
    puts "Games won by #{dealer.name}: #{dealer.games_won}"
    puts "Games tied so far: #{@number_of_tied_games}"
    puts
  end

  def display_player_hand
    display_game_heading
    display_game_numbers_info
    player.show_hand
  end

  def display_both_hands(full_or_partial)
    display_player_hand
    dealer.show_hand(full_or_partial)
  end

  def display_goodbye_message
    puts
    puts "Thanks for playing 'Twenty-One'! Goodbye."
  end
end

class TwentyOne
  include Display

  attr_accessor :deck, :player, :dealer

  def initialize
    display_welcome_message
    @player = Player.new
    @dealer = Dealer.new
    @number_of_games = 0
    @number_of_tied_games = 0
    prepare_for_new_game
  end

  def start
    loop do
      display_game_heading
      display_game_numbers_info
      deal_initial_cards
      display_both_hands(:partial)
      player_turn
      dealer_turn
      determine_result
      break unless play_again?
      prepare_for_new_game
    end
    display_goodbye_message
  end

  private

  def prepare_for_new_game
    @winner = nil
    @deck = Deck.new
    player.hand = []
    dealer.hand = []
  end

  def player_turn
    loop do
      break if player.got_21? || player.busted? || player.stay?
      player.hit(deck.deal_card)
      display_both_hands(:partial)
    end
  end

  def dealer_turn
    loop do
      break if dealer.busted? || dealer.got_21? || dealer.total > player.total \
                              || dealer.stay?
      dealer.hit(deck.deal_card)
    end
  end

  def update_number_of_games_won(winner = nil)
    if winner == :player
      player.games_won += 1
    elsif winner == :dealer
      dealer.games_won += 1
    else
      @number_of_tied_games += 1
    end
  end

  def display_result(message, winner = nil)
    message = "#{player.name.upcase}, " + message if winner == :player
    puts message
  end

  def update_and_display(winner, full_or_partial, message)
    update_number_of_games_won(winner)
    display_both_hands(full_or_partial)
    display_result(message, winner)
    true
  end

  def results_part_1
    dealer_name = dealer.name.upcase
    if player.got_21?
      message = "YOU GOT 21, YOU ARE THE WINNER!"
      return update_and_display(:player, :partial, message)
    elsif player.busted?
      message = "YOU WENT BUST, #{dealer_name} WINS!"
      return update_and_display(:dealer, :partial, message)
    elsif dealer.busted?
      message = "#{dealer_name} WENT BUST, YOU WIN!"
      return update_and_display(:player, :full, message)
    elsif dealer.got_21?
      message = "#{dealer_name} GOT 21, AND WINS!"
      return update_and_display(:dealer, :full, message)
    end
    false
  end

  def results_part_2
    player_total = player.total
    dealer_total = dealer.total
    if player_total > dealer_total
      message = "YOU WIN!"
      return update_and_display(:player, :full, message)
    elsif dealer_total > player_total
      message = "#{dealer.name.upcase} WINS!"
      return update_and_display(:dealer, :full, message)
    elsif dealer_total == player_total
      message = "IT'S A TIE!"
      return update_and_display(:nil, :full, message)
    end
    false
  end

  def determine_result
    increment_number_of_games
    results_part_1 || results_part_2
  end

  def increment_number_of_games
    @number_of_games += 1
  end

  def deal_initial_cards
    2.times do
      player.hit(deck.deal_card)
      dealer.hit(deck.deal_card)
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
end

game = TwentyOne.new
game.start
