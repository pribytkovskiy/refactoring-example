module CreditCards
  class Usual < Base
    attr_accessor :balance

    def initialize
      @balance = 50.0
      @number = generate_card_number
    end

    def percent_withdraw_tax
      5
    end

    def percent_put_tax
      20
    end

    def percent_sender_tax
      0
    end

    def fixed_put_tax
      0
    end

    def fixed_sender_tax
      20
    end
  end
end
