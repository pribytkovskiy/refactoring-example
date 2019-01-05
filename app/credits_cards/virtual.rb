module CreditCards
  class Virtual < Base
    attr_accessor :balance

    def initialize
      @balance = 150.0
      @number = generate_card_number
    end

    def percent_withdraw_tax
      88
    end

    def percent_put_tax
      0
    end

    def percent_sender_tax
      0
    end

    def fixed_put_tax
      1
    end

    def fixed_sender_tax
      1
    end
  end
end
