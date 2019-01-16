class Account < Validators::Account
  include Storage
  attr_accessor :cards
  attr_reader :age, :login, :name, :password

  CARD_TYPES = { usual: 'usual', capitalist: 'capitalist', virtual: 'virtual' }.freeze
  CARD_LENGTH = 16

  def create(account)
    validate(account)
    return unless valid?

    @age = account.age
    @login = account.login
    @name = account.name
    @password = account.password
    @cards = []
    array_accounts << self
    save_change
  end

  def load(login, password)
    array_accounts.detect { |account| login == account.login } unless chek_account(login, password)
  end

  def destroy
    array_accounts.delete(self)
    save_change
  end

  def save_change
    storing(@@accounts)
  end

  def save_card(type)
    cards << create_card(type)
    save_change
  end

  def destroy_card(answer)
    cards.delete_at(answer&.to_i.to_i - 1)
    save_change
  end

  private

  def create_card(type)
    case type
    when CARD_TYPES[:usual] then CreditCards::Usual.new
    when CARD_TYPES[:capitalist] then CreditCards::Capitalist.new
    when CARD_TYPES[:virtual] then CreditCards::Virtual.new
    end
  end

  def chek_account(login, password)
    array_accounts.select { |account| account.login == login && account.password == password }.empty?
  end

  def array_accounts
    @@accounts ||= accounts
  end
end
