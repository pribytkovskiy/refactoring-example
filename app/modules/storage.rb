module Storage
  FILE_PATH = './db/accounts.yml'.freeze

  def accounts
    File.exist?(FILE_PATH) ? YAML.load_file(FILE_PATH) : []
  end

  def storing(new_accounts)
    File.open(FILE_PATH, 'w') { |f| f.write new_accounts.to_yaml }
  end
end
