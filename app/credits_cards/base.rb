module CreditCards
  CARD_TYPES = { usual: 'usual', virtual: 'virtual', capitalist: 'capitalist' }.freeze

  class Base
    attr_reader :number

    PERCENT_WITHDRAW_TAX = 0
    PERCENT_PUT_TAX = 0
    PERCENT_SENDER_TAX = 0
    FIXED_PUT_TAX = 0
    FIXED_SENDER_TAX = 0

    def withdraw_tax(amount = 0)
      amount * PERCENT_WITHDRAW_TAX / 100.0
    end

    def put_tax(amount = 0)
      amount * PERCENT_PUT_TAX / 100.0 + FIXED_PUT_TAX
    end

    def sender_tax(amount = 0)
      amount * PERCENT_SENDER_TAX / 100.0 + FIXED_SENDER_TAX
    end

    private

    def generate_card_number
      Array.new(16) { rand(10) }.join
    end
  end
end
