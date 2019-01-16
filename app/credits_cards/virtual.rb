module CreditCards
  class Virtual < Base
    attr_accessor :balance

    PERCENT_WITHDRAW_TAX = 88
    PERCENT_PUT_TAX = 0
    PERCENT_SENDER_TAX = 0
    FIXED_PUT_TAX = 1
    FIXED_SENDER_TAX = 1

    def initialize
      @balance = 150.0
      @number = generate_card_number
    end
  end
end
