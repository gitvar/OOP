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
  end
end

class Card
  attr_reader :suit, :face

  def initialize(suit, face)
    @suit = suit
    @face = face
  end

  def value
    if (1..10).cover?(face.to_i)
      face.to_i
    elsif face == "Ace"
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

  def total
    sum = hand.map(&:value).reduce(:+)

    if sum > WINNING_TOTAL
      hand.each do |card|
        sum -= 10 if card.face == "Ace"
        break if sum <= WINNING_TOTAL
      end
    end
    sum
  end

  def show_hand(show_partial = false)
    display_hand_heading
    show_partial ? show_first_card : show_all_cards
    puts "#{name} chose to stay." if stayed?
    puts
  end

  private

  def display_hand_heading
    puts "#{name}'s hand:"
    "#{name}'s hand:".size.times { print "=" }
    puts
  end

  def show_all_cards
    puts format_all_cards_for_display
    puts
    puts "#{name}'s total is: #{total}"
  end

  def format_all_cards_for_display
    hand.map { |card| "#{card.face} of #{card.suit}" }
  end

  def show_first_card
    puts format_first_card
    puts
    puts "#{name}'s total is: #{hand.first.value}"
    puts
  end

  def format_first_card
    "#{hand.first.face} of #{hand.first.suit}"
  end
end

class Contestant
  include Hand

  attr_accessor :name, :hand, :games_won

  def initialize
    @name = obtain_name
    @games_won = 0
    setup_new_game
  end

  def setup_new_game
    @hand = []
    @stay = false
  end

  def stayed?
    @stay
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

  def stays?
    answer = nil
    loop do
      puts "(H)it or (S)tay?"
      answer = gets.chomp.downcase
      break if %w(h s).include?(answer)
      puts "Sorry, that is not a valid choice! Please try again."
    end
    @stay = answer == 's' ? true : false
  end

  private

  def valid_name?(name)
    !!(name =~ /^[a-zA-Z]*(-[A-Z][a-zA-Z]*)*( [a-zA-Z]*)*$/)
  end
end

class Dealer < Contestant
  def obtain_name
    %w(Twiki Hal WallE The\ Terminator CP30).sample
  end

  def stays?
    @stay = total >= DEALER_MAX ? true : false
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

  def display_game_stats
    puts
    puts "Games played so far: #{@number_of_games_played}"
    puts "Games won by #{player.name}: #{player.games_won}"
    puts "Games won by #{dealer.name}: #{dealer.games_won}"
    puts "Games tied so far: #{@number_of_tied_games}"
    puts
  end

  def display_game_heading_and_stats
    display_game_heading
    display_game_stats
  end

  def display_table
    display_game_heading_and_stats
    player.show_hand
    partial = true
    partial = false if !player.busted? && player.stayed?
    dealer.show_hand(partial)
  end

  def display_busted(busted_result)
    winning_name = dealer.name.upcase
    loosing_name = player.name.upcase

    if busted_result == :dealer_busted
      winning_name = loosing_name
      loosing_name = dealer.name.upcase
    end
    puts "#{loosing_name} WENT BUST! #{winning_name} WINS!"
  end

  def display_winner(winning_result)
    winning_name = dealer.name.upcase
    winning_name = player.name.upcase if winning_result == :player_win

    puts "#{winning_name} WINS!"
  end

  def display_tie
    puts "IT'S A TIE!"
  end

  def display_results(result)
    display_table

    if result == :player_busted || result == :dealer_busted
      display_busted(result)
    elsif result == :player_win || result == :dealer_win
      display_winner(result)
    elsif result == :tie
      display_tie
    end
  end

  def display_goodbye_message
    puts
    puts "Thanks for playing 'Twenty-One'! Goodbye."
  end
end

class TwentyOne
  require 'pry'
  include Display

  attr_accessor :deck, :player, :dealer

  def initialize
    display_welcome_message
    @player = Player.new
    @dealer = Dealer.new
    @number_of_games_played = 0
    @number_of_tied_games = 0
    prepare_for_new_game
  end

  def start
    loop do
      display_game_heading_and_stats
      deal_initial_cards
      display_table

      player_turn
      dealer_turn if !player.busted?

      result = determine_result
      update_game_stats(result)
      display_results(result)

      break unless play_again?
      prepare_for_new_game
    end
    display_goodbye_message
  end

  private

  def prepare_for_new_game
    @deck = Deck.new
    player.setup_new_game
    dealer.setup_new_game
  end

  def player_turn
    loop do
      if player.busted? || player.stays?
        return
      else
        player.hit(deck.deal_card)
        display_table
      end
    end
  end

  def dealer_turn
    loop do
      if dealer.busted? || dealer.stays?
        display_table
        return
      else
        dealer.hit(deck.deal_card)
        display_table
      end
    end
  end

  def determine_result
    if player.busted?
      :player_busted
    elsif dealer.busted?
      :dealer_busted
    elsif player.total > dealer.total
      :player_win
    elsif dealer.total > player.total
      :dealer_win
    else
      :tie
    end
  end

  def update_number_of_games_won_or_tied(result)
    if result == :player_win || result == :dealer_busted
      player.games_won += 1
    elsif result == :dealer_win || result == :player_busted
      dealer.games_won += 1
    elsif result == :tie
      @number_of_tied_games += 1
    end
  end

  def increment_number_of_games_played
    @number_of_games_played += 1
  end

  def update_game_stats(result)
    increment_number_of_games_played
    update_number_of_games_won_or_tied(result)
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
