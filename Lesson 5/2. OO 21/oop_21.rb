# frozen_string_literal: false
class Deck
  CARD_SUITS = %w(Hearts Diamonds Spades Clubs).freeze
  CARD_FACES = %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace).freeze

  def initialize
    @deck = new_shuffled_deck
  end

  def deal_card
    @deck.pop
  end

  # private

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
    if (2..10).cover?(face.to_i)
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

  def show_hand(full = true)
    display_hand_heading
    full ? show_all_cards : show_first_card
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

  def stay
    @stay = true
  end

  def stayed?
    @stay
  end

  def turn_over?
    busted? || stayed?
  end
end

class Player < Contestant
  def obtain_name
    name = nil
    loop do
      puts
      puts "Please enter your name:"
      print "=> "
      name = gets.chomp
      break if valid_name?(name)
      puts "That is not a valid name! Please try again."
    end
    name
  end

  def obtain_input
    reply = nil

    loop do
      puts "(H)it or (S)tay?"
      print "=> "
      reply = gets.chomp.downcase
      break if %w(hit h stay s).include?(reply)
      puts "That is not a valid choice! Please try again."
    end

    stay if reply == 's' || reply == 'stay'
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

  def obtain_input
    stay if total >= DEALER_MAX
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

  def show_whole_card?
    player.turn_over?
  end

  def display_table
    display_game_heading_and_stats
    player.show_hand
    dealer.show_hand(show_whole_card?)
  end

  def display_result(message)
    display_table
    puts message
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
    @number_of_games_played = 0
    @number_of_tied_games = 0
    prepare_for_new_game
  end

  def start
    loop do
      deal_initial_cards
      display_table

      contestant_turn(player)
      contestant_turn(dealer) if !player.busted?

      result = determine_result
      update_game_stats(result)

      message = determine_result_message(result)
      display_result(message)

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

  def contestant_turn(contestant)
    loop do
      contestant.obtain_input
      if contestant.stayed?
        display_table
        break
      else
        contestant.hit(deck.deal_card)
        display_table
      end

      break if contestant.busted?
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

  def determine_result_message(result)
    dealer_name = dealer.name.upcase
    player_name = player.name.upcase
    case result
    when :player_busted
      "#{dealer_name} WINS! #{player_name} WENT BUST."
    when :dealer_busted
      "#{player_name} WINS! #{dealer_name} WENT BUST."
    when :player_win
      "#{player_name} WINS!"
    when :dealer_win
      "#{dealer_name} WINS!"
    when :tie
      "IT'S A TIE!"
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
      print "=> "
      answer = gets.chomp.downcase
      break if %w(yes y no n).include?(answer)
      puts "That is not a valid answer! Please try again."
    end

    answer == 'y' || answer == 'yes'
  end
end

game = TwentyOne.new
game.start
