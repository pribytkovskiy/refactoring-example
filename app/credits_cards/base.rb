module CreditCards
  CARD_TYPES = { usual: 'usual', virtual: 'virtual', capitalist: 'capitalist' }.freeze

  class Base
    attr_reader :number

    def withdraw_tax(amount = 0)
      amount * percent_withdraw_tax / 100.0
    end

    def put_tax(amount = 0)
      amount * percent_put_tax / 100.0 + fixed_put_tax
    end

    def sender_tax(amount = 0)
      amount * percent_sender_tax / 100.0 + fixed_sender_tax
    end

    def percent_withdraw_tax
      raise NotImplementedError
    end

    def percent_put_tax
      raise NotImplementedError
    end

    def percent_sender_tax
      raise NotImplementedError
    end

    def fixed_put_tax
      raise NotImplementedError
    end

    def fixed_sender_tax
      raise NotImplementedError
    end

    private

    def generate_card_number
      Array.new(16) { rand(10) }.join
    end
  end
end
