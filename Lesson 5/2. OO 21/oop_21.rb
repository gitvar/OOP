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

  def to_s
    deck.each { |card| print "#{card[0]} of #{card[1]}, " }
  end
end

class Hand
  require 'pry'
  attr_accessor :card, :cards, :name

  def initialize(deck, name)
    @cards = []
    @name = name
    @deck = deck
  end

  def card=(new_card)
    @cards << new_card
  end

  def hit
    puts "#{@name} chose to receive a new card!"
    self.card = @deck.deal_card
  end

  def stay
    puts "#{@name} chose to stay."
  end

  def busted?
  end

  def total
  end

  def valid?(answer)
    !!(answer =~ /^[hs]?$/)
  end
end

class Human < Hand
  def turn_input
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

  def turn
    turn_input == 's' ? stay : hit
  end
end

class Dealer < Hand
  def turn
    puts
    puts "Dealer turn!"
  end
end

module Display

  def format_for_display(arr)
    array = arr.dup
    array[-1] = "and #{array.last}" if array.size > 1
    array.size == 2 ? array.join(' ') : array.join(', ')
  end

  def show_initial_cards
    puts
    print "#{player.name}'s cards: "
    puts format_for_display(player.cards)
    # player.cards.each { |card| print "#{card[0]} of #{card[1]}, " }
    puts
    print "#{dealer.name}'s cards: "
    puts format_for_display(dealer.cards)
    # dealer.cards.each { |card| print "#{card[0]} of #{card[1]}, " }
  end

  def show_result
  end
end

class TwentyOne
  include Display

  attr_accessor :deck, :player, :dealer

  def initialize
    @human_name = human_player_name
    @deck = Deck.new
    @player = Human.new(@deck, @human_name)
    @dealer = Dealer.new(@deck, "Dealer")
  end

  def deal_cards
    (1..2).each do
      player.card = deck.deal_card
      dealer.card = deck.deal_card
    end
  end

  def start
    deal_cards
    show_initial_cards
    player.turn
    dealer.turn
    show_initial_cards
    # show_result
  end

  def valid_name?(name) # Hyphenated names are also valid: "Jean-Claude".
    !!(name =~ /^[A-Z][a-zA-Z]*(-[A-Z][a-zA-Z]*)?$/)
  end

  def human_player_name
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
