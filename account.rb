class Account
  attr_reader :age, :login, :name, :password
  FILE_PATH = './accounts.yml'

  def initialize(console)
    @age = console.age
    @card = []
    @login = console.login
    @name = console.name
    @password = console.password
  end 

  def save
    new_accounts = accounts << self
    File.open(FILE_PATH, 'w') { |f| f.write new_accounts.to_yaml } #Storing
  end

  private

  def accounts
    File.exists?(FILE_PATH) ? YAML.load_file(FILE_PATH) : []
  end
end