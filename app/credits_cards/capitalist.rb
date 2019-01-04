module CreditCards
  class Capitalist < Base
    attr_accessor :balance

    def initialize
      @balance = 50.0
      @number = generate_card_number
    end

    def percent_withdraw_tax
      4
    end

    def percent_put_tax
      0
    end

    def percent_sender_tax
      10
    end

    def fixed_put_tax
      10
    end

    def fixed_sender_tax
      0
    end
  end
end
