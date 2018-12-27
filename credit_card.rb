class CreditCard

  CARD_TYPES = { usual: 'usual', capitalist: 'capitalist', virtual: 'virtual' }.freeze

  def create_card(type)
    case type
    when CARD_TYPES[:usual] then CreditCards::Usual.new
    when CARD_TYPES[:capitalist] then CreditCards::Capitalist.new
    when CARD_TYPES[:virtual] then CreditCards::Virtual.new
    end
  end
end
