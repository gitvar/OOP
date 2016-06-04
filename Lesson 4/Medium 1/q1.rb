class BankAccount
  attr_reader :balance

  def initialize(starting_balance)
    @balance = starting_balance
  end

  # def balance # overwrite the attr_reader method. # test for Q1, Hard 1
  #   puts "inside the balance method"
  #   @balance
  # end

  def positive_balance?
    balance >= 0
  end
end

my_account = BankAccount.new(1229.34)
puts my_account.balance
puts my_account.positive_balance?
