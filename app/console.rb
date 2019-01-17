class Console < MoneyHelpers
  include Storage
  attr_reader :age, :login, :name, :password, :current_card

  COMMANDS_MENU = {
    show_cards: 'SC', create_card: 'CC', destroy_card: 'DC',
    put_money: 'PM', withdraw_money: 'WM', send_money: 'SM',
    destroy_account: 'DA', exit: 'exit'
  }.freeze
  COMMANDS = { create: 'create', load: 'load', exit: 'exit', yes: 'y' }.freeze
  MENU = {
    COMMANDS_MENU[:show_cards] => ->(instance) { instance.show_cards },
    COMMANDS_MENU[:create_card] => ->(instance) { instance.create_card },
    COMMANDS_MENU[:destroy_card] => ->(instance) { instance.destroy_card },
    COMMANDS_MENU[:put_money] => ->(instance) { instance.put_money },
    COMMANDS_MENU[:withdraw_money] => ->(instance) { instance.withdraw_money },
    COMMANDS_MENU[:send_money] => ->(instance) { instance.send_money },
    COMMANDS_MENU[:destroy_account] => ->(instance) { return instance.destroy_account },
    COMMANDS_MENU[:exit] => ->(_instance) { return exit }

  }.freeze

  def initialize
    @account = Account.new
  end

  def console
    puts HELLO_MESSAGE
    case gets.chomp
    when COMMANDS[:create] then create
    when COMMANDS[:load] then load
    else
      exit
    end
  end

  def create_card
    loop do
      puts CREATE_CARD_PHRASES
      input_as_key = gets.chomp.to_sym
      if CreditCard::CARD.key?(input_as_key)
        return @current_account.save_card(input_as_key)
      end

      puts I18n.t(:wrong_card)
    end
  end

  def destroy_card
    return puts I18n.t(:no_active_cards) unless @current_account.cards.any?

    input_destroy_card
  end

  private

  def create
    loop do
      name_input
      age_input
      login_input
      password_input
      @account.create(self)
      break if @account.valid?

      @account.puts_errors
    end
    @current_account = @account.load(login, password)
    main_menu
  end

  def load
    return create_the_first_account unless accounts.any?

    input_login_pasword
    main_menu
  end

  def input_login_pasword
    loop do
      puts I18n.t(:enter_login)
      login = gets.chomp
      puts I18n.t(:enter_password)
      password = gets.chomp
      break (@current_account = @account.load(login, password)) if @account.load(login, password)

      puts I18n.t(:no_account)
    end
  end

  def main_menu
    loop do
      puts "\nWelcome, #{@current_account.name}"
      puts TEXT_MENU
      begin
        MENU.fetch(gets.chomp).call(self)
      rescue KeyError => e
        puts I18n.t(:wrong_command)
      end
    end
  end
end
