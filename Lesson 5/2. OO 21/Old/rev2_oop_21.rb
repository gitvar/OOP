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

  def show_hand(full_or_partial_hand = :full)
    display_hand_heading
    if full_or_partial_hand == :full
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
    puts @stay_message
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
    puts "#{name}'s total is: #{hand.first.value}"
    puts
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
    @hand = []
    @games_won = 0
    @stay_message = ""
  end

  def new_game
    @hand = []
    @stay_message = ''
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
      puts
      puts "(H)it or (S)tay?"
      answer = gets.chomp.downcase
      break if %w(h s).include?(answer)
      puts "Sorry, that is not a valid choice! Please try again."
    end
    @stay_message = "#{name} stays" if answer == "s"
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

  def stays?
    @stay_message = "#{name} stays" if total >= DEALER_MAX
    total >= DEALER_MAX
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

  def display_player_hand
    display_game_heading
    display_game_stats
    player.show_hand
  end

  def display_contestant_hands(full_or_partial_hand = :partial)
    display_player_hand
    dealer.show_hand(full_or_partial_hand)
  end

  def display_result(message, winner = nil)
    message = "#{player.name.upcase}, " + message if winner == :player
    puts message
  end

  def update_and_display(winner, full_or_partial_hand, message)
    update_number_of_games_won(winner)
    display_contestant_hands(full_or_partial_hand)
    display_result(message, winner)
    true
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
      display_game_heading
      display_game_stats
      deal_initial_cards
      display_contestant_hands

      if player_turn == :stay
        increment_number_of_games_played
        compare_contestant_scores if dealer_turn == :stay
      end

      break unless play_again?
      prepare_for_new_game
    end
    display_goodbye_message
  end

  private

  def prepare_for_new_game
    @winner = nil
    @deck = Deck.new
    player.new_game
    dealer.new_game
  end

  def player_turn
    loop do
      if player.got_21?
        return player_did_get_21
      elsif player.busted?
        return player_did_go_bust
      elsif player.stays?
        return player_did_stay
      else
        player.hit(deck.deal_card)
        display_contestant_hands
      end
    end
  end

  def dealer_turn
    loop do
      if dealer.got_21?
        return dealer_did_get_21
      elsif dealer.busted?
        return dealer_did_go_bust
      elsif dealer.stays?
        return :stay
      else
        dealer.hit(deck.deal_card)
        display_contestant_hands(:full)
      end
    end
  end

  def player_did_get_21
    increment_number_of_games_played
    message = "YOU GOT 21, YOU ARE THE WINNER!"
    update_and_display(:player, :partial, message)
    :got_21
  end

  def player_did_go_bust
    increment_number_of_games_played
    message = "YOU WENT BUST, #{dealer.name.upcase} WINS!"
    update_and_display(:dealer, :partial, message)
    :went_bust
  end

  def player_did_stay
    message = "#{player.name.upcase} STAYS!"
    update_and_display(nil, :full, message)
    :stay
  end

  def dealer_did_get_21
    message = "#{dealer.name.upcase} GOT 21, AND WINS!"
    update_and_display(:dealer, :full, message)
    :got_21
  end

  def dealer_did_go_bust
    message = "#{dealer.name.upcase} WENT BUST, YOU WIN!"
    update_and_display(:player, :full, message)
    :went_bust
  end

  def compare_contestant_scores
    player_total = player.total
    dealer_total = dealer.total
    if player_total > dealer_total
      player_did_win_on_points
    elsif dealer_total > player_total
      dealer_did_win_on_points
    elsif dealer_total == player_total
      game_is_a_tie
    end
  end

  def player_did_win_on_points
    message = "YOU WIN!"
    update_and_display(:player, :full, message)
  end

  def dealer_did_win_on_points
    message = "#{dealer.name.upcase} WINS!"
    update_and_display(:dealer, :full, message)
  end

  def game_is_a_tie
    message = "IT'S A TIE!"
    update_and_display(:tied, :full, message)
  end

  def update_number_of_games_won(winner = nil)
    if winner == :player
      player.games_won += 1
    elsif winner == :dealer
      dealer.games_won += 1
    elsif winner == :tied
      @number_of_tied_games += 1
    end
  end

  def increment_number_of_games_played
    @number_of_games_played += 1
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
