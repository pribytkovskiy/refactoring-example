class Console
  attr_reader :age, :login, :name, :password

  HELLO_MESSAGE = <<~HELLO_MESSAGE.freeze
    Hello, we are RubyG bank!
    - If you want to create account - press `create`
    - If you want to load account - press `load`
    - If you want to exit - press `exit`
  HELLO_MESSAGE

  CREATE_CARD_PHRASES = <<~CREATE_CARD_PHRASES.freeze
    You could create one of 3 card types
    - Usual card. 2% tax on card INCOME. 20$ tax on SENDING money from this card. 5% tax on WITHDRAWING money. For creation this card - press `usual`
    - Capitalist card. 10$ tax on card INCOME. 10% tax on SENDING money from this card. 4$ tax on WITHDRAWING money. For creation this card - press `capitalist`
    - Virtual card. 1$ tax on card INCOME. 1$ tax on SENDING money from this card. 12% tax on WITHDRAWING money. For creation this card - press `virtual`
    - For exit - press `exit`
  CREATE_CARD_PHRASES

  TEXT_MENU = <<~TEXT_MENU.freeze
      If you want to:
      - show all cards - press SC
      - create card - press CC
      - destroy card - press DC
      - put money on card - press PM
      - withdraw money on card - press WM
      - send money to another card  - press SM
      - destroy account - press `DA`
      - exit from account - press `exit`
  TEXT_MENU

  COMMANDS_MENU = { show_cards: 'SC', create_card: 'CC', destroy_card: 'DC', 
                    put_money: 'PM', withdraw_money: 'WM', send_money: 'SM', 
                    destroy_account: 'DA', exit: 'exit' }
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
      @current_account = @account.create(self)
      break if @account.valid?
      @account.puts_errors
    end
    load
  end

  def load
    loop do
      return create_the_first_account unless @account.accounts.any?
      puts I18n.t(:enter_login)
      login = gets.chomp
      puts I18n.t(:enter_password)
      password = gets.chomp
      break (@current_account = @account.load(login, password)) if @account.load(login, password)
      puts I18n.t(:no_account) unless @account.load(login, password)
    end
    main_menu
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
      when COMMANDS_MENU[:exit]
        exit 
        break
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
      when CreditCard::CARD_TYPES[:usual] then return @current_account.save_card(type)
      when CreditCard::CARD_TYPES[:capitalist] then return @current_account.save_card(type)
      when CreditCard::CARD_TYPES[:virtual] then return @current_account.save_card(type)
      else
        puts I18n.t(:wrong_card)
      end
    end
  end

  def destroy_card
    loop do
      if @current_account.cards.any?
        puts I18n.t(:want_to_delete)
        print_cards
        answer = gets.chomp
        break if answer == COMMANDS[:exit] 
        return confirmation_delete_card(answer) if check_card_ordinal_number(answer)
        puts I18n.t(:wrong_number) unless check_card_ordinal_number(answer)
      else
        return puts I18n.t(:no_active_cards)
      end
    end
  end

  def confirmation_delete_card(answer)
    puts "Are you sure you want to delete #{@current_account.cards[answer&.to_i - 1].number}?[y/n]"
    if gets.chomp == COMMANDS[:yes]
      @current_account.destroy_card(answer)
    end
  end

  def withdraw_money
    puts I18n.t(:choose_withdrawing)
    loop do
      puts I18n.t(:no_active_cards) unless @current_account.cards.any?
      break unless @current_account.cards.any?
      withdraw_money_amount_money(choose_card)
    end
  end

  def choose_card
    print_cards
    loop do
      answer = gets.chomp
      break if answer == COMMANDS[:exit]
      return answer if check_card_ordinal_number(answer)
      puts I18n.t(:wrong_number) unless check_card_ordinal_number(answer)
    end
  end

  def withdraw_money_amount_money(answer)
    current_card = @current_account.cards[answer&.to_i - 1]
    puts I18n.t(:amount_money)
    input_money = gets.chomp
    withdraw_money_left_money(input_money, current_card) if input_money&.to_i > 0
    puts I18n.t(:correct_amount) unless input_money&.to_i > 0
  end

  def withdraw_money_left_money(input_money, current_card)
    money_left = current_card.balance - input_money&.to_i - current_card.withdraw_tax(input_money&.to_i)
    loop do
      break puts I18n.t(:enough_money) if money_left <= 0
      current_card.balance = money_left
      @current_account.save_change
      puts "Money #{input_money&.to_i}$ withdrawed from #{current_card.number}."
      puts "Money left: #{current_card.balance}$. Tax: #{current_card.withdraw_tax(input_money&.to_i)}$"
      return
    end
  end

  def put_money
    puts I18n.t(:choose_card)
    loop do
      puts I18n.t(:no_active_cards) unless @current_account.cards.any?
      break unless @current_account.cards.any?
      put_money_amount_money(choose_card)
    end
  end

  def put_money_amount_money(answer)
    current_card = @current_account.cards[answer&.to_i - 1]
    puts I18n.t(:amount_money_card)
    amount_money = gets.chomp
    put_money_left_money(amount_money, current_card) if amount_money&.to_i > 0
    puts I18n.t(:correct_amount_money) unless amount_money&.to_i > 0
  end

  def put_money_left_money(amount_money, current_card)
    loop do
      break puts I18n.t(:tax_higher) if current_card.put_tax(amount_money&.to_i) >= amount_money&.to_i
      current_card.balance = current_card.balance + amount_money&.to_i - current_card.put_tax(amount_money&.to_i)
      @current_account.save_change
      puts "Money #{amount_money&.to_i}$ was put on #{current_card.number}."
      puts "Balance: #{current_card.balance}$. Tax: #{current_card.put_tax(amount_money&.to_i)}$"
      return
    end
  end

  def send_money
    puts I18n.t(:choose_card_sending)
    loop do
      puts I18n.t(:no_active_cards) unless @current_account.cards.any?
      break unless @current_account.cards.any?
      recipient_card(choose_card)
    end
  end

  def recipient_card(answer)
    sender_card = @current_account.cards[answer&.to_i - 1]
    puts I18n.t(:recipient_card)
    enter_recipient_card = gets.chomp
    loop do
      puts I18n.t(:correct_number_card) if enter_recipient_card.length != Account::CARD_LENGTH
      break if enter_recipient_card.length != Account::CARD_LENGTH
      all_cards = @current_account.accounts.map(&:cards).flatten
      recipient_cards = all_cards.select { |card| card.number == enter_recipient_card }
      return send_check_plus(sender_card, recipient_cards.first) if recipient_cards.any?
      puts "There is no card with number #{enter_recipient_card}\n" unless recipient_cards.any?
    end
  end

  def send_check_plus(sender_card, recipient_card)
    loop do
      puts I18n.t(:amount_money)
      amount_money = gets.chomp
      return send_money_transfer(amount_money, sender_card, recipient_card) if amount_money&.to_i > 0
      puts I18n.t(:wrong_number) unless amount_money&.to_i > 0   
    end
  end

  def send_money_transfer(amount_money, sender_card, recipient_card)
    sender_balance = sender_card.balance - amount_money&.to_i - sender_card.sender_tax(amount_money&.to_i)
    recipient_balance = recipient_card.balance + amount_money&.to_i - recipient_card.put_tax(amount_money&.to_i)
    case
    when sender_balance < 0 then puts I18n.t(:enough_money)
    when recipient_card.put_tax(amount_money&.to_i) >= amount_money&.to_i then puts I18n.t(:enough_money_sender_card)
    else
      sender_card.balance = sender_balance
      @current_account.save_change
      recipient_card.balance = recipient_balance
      @current_account.save_change_recipient_card(recipient_card)
      puts "Money #{amount_money&.to_i}$ was put on #{sender_card.number}."
      puts "Balance: #{sender_balance}$. Tax: #{sender_card.sender_tax(amount_money&.to_i)}$\n"
      puts "Money #{amount_money&.to_i}$ was send on #{recipient_card.number}."
      puts "Balance: #{recipient_balance}$. Tax: #{recipient_card.put_tax(amount_money&.to_i)}$\n"
      return
    end
    return
  end

  def check_card_ordinal_number(answer)
    answer&.to_i <= @current_account.cards.length && answer&.to_i > 0
  end

  def print_cards
    @current_account.cards.each_with_index { |c, i| puts "- #{c.number}, #{c.class.name}, press #{i + 1}" }
    puts I18n.t(:press_exit)
  end

  def show_cards
    @current_account.cards.map { |card| puts "- #{card.number}, #{card.class.name}" } if @current_account.cards.any?
    puts I18n.t(:no_active_cards) unless @current_account.cards.any?
  end

  def destroy_account
    puts I18n.t(:destroy_account)
    @current_account.destroy if gets.chomp == 'y'
  end

  def create_the_first_account
    puts I18n.t(:no_active_accounts)
    gets.chomp == 'y' ? create : console
  end

  def name_input
    puts I18n.t(:enter_name)
    @name = gets.chomp
  end

  def login_input
    puts I18n.t(:enter_login)
    @login = gets.chomp
  end

  def password_input
    puts I18n.t(:enter_password)
    @password = gets.chomp
  end

  def age_input
    puts I18n.t(:enter_age)
    @age = gets.chomp.to_i
  end
end
