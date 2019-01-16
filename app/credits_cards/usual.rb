module CreditCards
  class Usual < Base
    attr_accessor :balance

    PERCENT_WITHDRAW_TAX = 5
    PERCENT_PUT_TAX = 20
    PERCENT_SENDER_TAX = 0
    FIXED_PUT_TAX = 0
    FIXED_SENDER_TAX = 20

    def initialize
      @balance = 50.0
      @number = generate_card_number
    end
  end
end
