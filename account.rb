class Account < Validators::Account
  attr_reader :age, :login, :name, :password
  FILE_PATH = './accounts.yml'

  def create(account)
    validate(account)
    if valid?
      @age = account.age
      @card = []
      @login = account.login
      @name = account.name
      @password = account.password
      save
    end
  end

  def load(login, password)
    if accounts.map { |a| { login: a.login, password: a.password } }.include?({ login: login, password: password })
      accounts.select { |a| login == a.login }.first
    end
  end

  def destroy(current_account)
    new_accounts = []
    accounts.each { |ac| new_accounts.push(ac) unless ac.login == current_account.login }
    storing(new_accounts)
  end

  private

  def save
    new_accounts = accounts << self
    storing(new_accounts)
  end

  def storing(new_accounts)
    File.open(FILE_PATH, 'w') { |f| f.write new_accounts.to_yaml }
  end

  def accounts
    File.exists?(FILE_PATH) ? YAML.load_file(FILE_PATH) : []
  end
end
