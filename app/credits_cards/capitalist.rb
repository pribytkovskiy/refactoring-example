module CreditCards
  class Capitalist < Base
    attr_accessor :balance

    PERCENT_WITHDRAW_TAX = 4
    PERCENT_PUT_TAX = 0
    PERCENT_SENDER_TAX = 10
    FIXED_PUT_TAX = 10
    FIXED_SENDER_TAX = 0

    def initialize
      @balance = 100.0
      @number = generate_card_number
    end
  end
end
