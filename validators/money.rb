module Validators
  class Money
    attr_reader :errors

    def initialize
      @errors = []
    end

    def validate(account)
      validate_name(account.name)
      validate_age(account.age)
      validate_login(account.login)
      validate_password(account.password)
    end

    def valid?
      @errors.size.zero?
    end

    def puts_errors
      @errors.each { |error| puts error }
      @errors = []
    end

    private

    def validate_name(name)
      @errors.push(I18n.t(:error_name)) if (name == '' || name[0].upcase != name[0])
    end

    def validate_login(login)
      @errors.push(I18n.t(:error_login_present)) if login.empty?
      @errors.push(I18n.t(:error_login_longer)) if login.length < START_LENGTH_NAME
      @errors.push(I18n.t(:error_login_shorter)) if login.length > END_LENGTH_NAME
      @errors.push(I18n.t(:error_login_exists)) if accounts.map(&:login).include?(login)
    end

    def validate_password(password)
      @errors.push(I18n.t(:error_password_present)) if password.empty?
      @errors.push(I18n.t(:error_password_longer)) if password.length < START_LENGTH_PASSWORD
      @errors.push(I18n.t(:error_password_shorter)) if password.length > START_LENGTH_PASSWORD
    end

    def validate_age(age)
      @errors.push(I18n.t(:error_name)) unless age.between?(START_LENGTH_AGE, END_LENGTH_AGE)
    end

    def accounts
      File.exists?(FILE_PATH) ? YAML.load_file(FILE_PATH) : []
    end
  end
end
