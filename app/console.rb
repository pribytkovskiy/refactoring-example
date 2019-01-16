class Console < MoneyHelpers
  include Storage
  attr_reader :age, :login, :name, :password, :current_card

  COMMANDS_MENU = {
    show_cards: 'SC', create_card: 'CC', destroy_card: 'DC',
    put_money: 'PM', withdraw_money: 'WM', send_money: 'SM',
    destroy_account: 'DA', exit: 'exit'
  }.freeze
  COMMANDS = { create: 'create', load: 'load', exit: 'exit', yes: 'y' }.freeze

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
      case gets.chomp
      when COMMANDS_MENU[:show_cards] then show_cards
      when COMMANDS_MENU[:create_card] then create_card
      when COMMANDS_MENU[:destroy_card] then destroy_card
      when COMMANDS_MENU[:put_money] then put_money
      when COMMANDS_MENU[:withdraw_money] then withdraw_money
      when COMMANDS_MENU[:send_money] then send_money
      when COMMANDS_MENU[:destroy_account] then return destroy_account
      when COMMANDS_MENU[:exit] then return exit
      else
        puts I18n.t(:wrong_command)
      end
    end
  end

  def create_card
    loop do
      puts CREATE_CARD_PHRASES
      type = gets.chomp
      case type
      when CreditCards::CARD_TYPES[:usual] then return @current_account.save_card(type)
      when CreditCards::CARD_TYPES[:capitalist] then return @current_account.save_card(type)
      when CreditCards::CARD_TYPES[:virtual] then return @current_account.save_card(type)
      else
        puts I18n.t(:wrong_card)
      end
    end
  end

  def destroy_card
    return puts I18n.t(:no_active_cards) unless @current_account.cards.any?

    input_destroy_card
  end
end
