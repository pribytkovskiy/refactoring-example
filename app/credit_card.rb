class CreditCard
  CARD = {
    usual: {
      balance: 50.0, percent_withdraw_tax: 5, percent_put_tax: 20,
      percent_sender_tax: 0, fixed_put_tax: 0, fixed_sender_tax: 20
    },
    virtual: {
      balance: 150.0, percent_withdraw_tax: 88, percent_put_tax: 0,
      percent_sender_tax: 0, fixed_put_tax: 1, fixed_sender_tax: 1
    },
    capitalist: {
      balance: 100.00, percent_withdraw_tax: 4, percent_put_tax: 0,
      percent_sender_tax: 10, fixed_put_tax: 10, fixed_sender_tax: 0
    }
  }.freeze

  attr_accessor :balance
  attr_reader :type, :number

  def initialize(type)
    @type = type
    @balance = CARD[type][:balance]
    @number = generate_card_number
  end

  def withdraw_tax(amount = 0)
    amount * CARD[type][:percent_withdraw_tax] / 100.0
  end

  def put_tax(amount = 0)
    amount * CARD[type][:percent_put_tax] / 100.0 + CARD[type][:fixed_put_tax]
  end

  def sender_tax(amount = 0)
    amount * CARD[type][:percent_sender_tax] / 100.0 + CARD[type][:fixed_sender_tax]
  end

  private

  def generate_card_number
    Array.new(16) { rand(10) }.join
  end
end
