class Account < Validators::Account
  attr_accessor :cards
  attr_reader :age, :login, :name, :password

  FILE_PATH = './accounts.yml'

  def create(account)
    validate(account)
    if valid?
      @age = account.age
      @login = account.login
      @name = account.name
      @password = account.password
      @cards = []
      new_accounts = accounts << self
      storing(new_accounts)
    end
  end

  def load(login, password)
    if accounts.map { |a| { login: a.login, password: a.password } }.include?({ login: login, password: password })
      accounts.select { |a| login == a.login }.first
    end
  end

  def destroy
    new_accounts = []
    accounts.each { |ac| new_accounts.push(ac) unless ac.login == self.login }
    storing(new_accounts)
  end

  def accounts
    File.exists?(FILE_PATH) ? YAML.load_file(FILE_PATH) : []
  end

  def save_change()
    new_accounts = []
    accounts.each { |ac| ac.login == self.login ? new_accounts.push(self) : new_accounts.push(ac) }
    storing(new_accounts)
  end

  def save_change_recipient_card(recipient_card)
    new_accounts = []
    accounts.each do |ac|
      new_accounts.push(ac) unless ac.cards.map { |card| card.number }.include? recipient_card.number
      if ac.cards.map { |card| card.number }.include? recipient_card.number
        recipient = ac
        new_recipient_cards = []
        recipient.cards.each do |card|
          card.balance = recipient_card.balance if card.number == recipient_card.number
          new_recipient_cards.push(card)
        end
        recipient.cards = new_recipient_cards
        new_accounts.push(recipient)
      end
    end
    storing(new_accounts)
  end

  private

  def storing(new_accounts)
    File.open(FILE_PATH, 'w') { |f| f.write new_accounts.to_yaml }
  end
end
