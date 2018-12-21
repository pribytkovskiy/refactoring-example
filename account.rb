class Account
  FILE_PATH = 'accounts.yml'

  def initialize(console)
    @age = console.age
    @card = console.card ||= []
    @login = console.login
    @name = console.name
    @password = console.password
  end 

  def create(account)
    new_accounts = accounts << account
    @current_account = account
    File.open(FILE_PATH, 'w') { |f| f.write new_accounts.to_yaml } #Storing
  end

  private

  def accounts
    File.exists?(FILE_PATH) ? YAML.load_file(FILE_PATH) : []
  end
end