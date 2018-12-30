class Account < Validators::Account
  attr_accessor :cards
  attr_reader :age, :login, :name, :password

  CARD_TYPES = { usual: 'usual', capitalist: 'capitalist', virtual: 'virtual' }.freeze
  CARD_LENGTH = 16
  FILE_PATH = './db/accounts.yml'.freeze

  def create(account)
    validate(account)
    return unless valid?

    @age = account.age
    @login = account.login
    @name = account.name
    @password = account.password
    @cards = []
    new_accounts = accounts << self
    storing(new_accounts)
  end

  # rubocop:disable Style/GuardClause, Style/BracesAroundHashParameters

  def load(login, password)
    if accounts.map { |a| { login: a.login, password: a.password } }.include?({ login: login, password: password })
      accounts.select { |a| login == a.login }.first
    end
  end

  # rubocop:enable Style/GuardClause, Style/BracesAroundHashParameters

  def destroy
    new_accounts = []
    accounts.each { |ac| new_accounts.push(ac) unless ac.login == login }
    storing(new_accounts)
  end

  def accounts
    File.exist?(FILE_PATH) ? YAML.load_file(FILE_PATH) : []
  end

  def save_change
    new_accounts = []
    accounts.each { |ac| ac.login == login ? new_accounts.push(self) : new_accounts.push(ac) }
    storing(new_accounts)
  end

  def save_change_recipient_card(recipient_card)
    new_accounts = []
    accounts.each do |ac|
      new_accounts.push(ac) unless ac.cards.map(&:number).include? recipient_card.number
      next unless ac.cards.map(&:number).include? recipient_card.number

      new_accounts.push(recipienr_cadr(recipient_card, ac))
    end
    storing(new_accounts)
  end

  def save_card(type)
    cards << CreditCard.new.create_card(type)
    save_change
  end

  def destroy_card(answer)
    cards.delete_at(answer&.to_i.to_i - 1)
    save_change
  end

  private

  def storing(new_accounts)
    File.open(FILE_PATH, 'w') { |f| f.write new_accounts.to_yaml }
  end

  def create_card(type)
    case type
    when CARD_TYPES[:usual] then CreditCards::Usual.new
    when CARD_TYPES[:capitalist] then CreditCards::Capitalist.new
    when CARD_TYPES[:virtual] then CreditCards::Virtual.new
    end
  end

  def recipienr_cadr(recipient_card, account)
    recipient = account
    new_recipient_cards = []
    recipient.cards.each do |card|
      card.balance = recipient_card.balance if card.number == recipient_card.number
      new_recipient_cards.push(card)
    end
    recipient.cards = new_recipient_cards
    recipient
  end
end
