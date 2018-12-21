class Account
  
  def create
    @card = []
    new_accounts = accounts << self
    @current_account = self
    File.open(FILE_PATH, 'w') { |f| f.write new_accounts.to_yaml } #Storing
    main_menu
  end
end