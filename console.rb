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
  COMMANDS = { create: 'create', load: 'load' }.freeze
  FILE_PATH = 'accounts.yml'

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
    main_menu
  end

  def load
    loop do
      return create_the_first_account unless @account.accounts.any?
      puts I18n.t(:enter_login)
      login = gets.chomp
      puts I18n.t(:enter_password)
      password = gets.chomp
      if @account.load(login, password)
        @current_account = @account.load(login, password)
        break 
      else
        puts I18n.t(:no_account)
        next
      end
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
      when CreditCard::CARD_TYPES[:usual] then return save_card(type)
      when CreditCard::CARD_TYPES[:capitalist] then return save_card(type)
      when CreditCard::CARD_TYPES[:virtual] then return save_card(type)
      else
        puts I18n.t(:wrong_card)
      end
    end
  end

  def save_card(type)
    @current_account.cards << CreditCard.new.create_card(type)
    @current_account.save_change
  end

  def destroy_card
    loop do
      if @current_account.cards.any?
        puts I18n.t(:want_to_delete)
        print_cards
        answer = gets.chomp # one method
        break if answer == 'exit' 
        return confirmation_delete_card(answer) if answer&.to_i <= @current_account.cards.length && answer&.to_i > 0
        puts I18n.t(:wrong_number) unless answer&.to_i <= @current_account.cards.length && answer&.to_i > 0
      else
        return puts I18n.t(:no_active_cards)
      end
    end
  end

  def withdraw_money
    puts I18n.t(:choose_withdrawing)

    if @current_account.cards.any?
      print_cards
      loop do
        answer = gets.chomp # one method
        break if answer == 'exit'
        #return confirmation_delete_card(answer) if answer&.to_i <= @current_account.cards.length && answer&.to_i > 0
        puts I18n.t(:wrong_number) unless answer&.to_i <= @current_account.cards.length && answer&.to_i > 0
        current_card = @current_account.cards[answer&.to_i - 1]

        loop do
          puts I18n.t(:amount_money)
          input_money = gets.chomp
          if input_money&.to_i > 0
            money_left = current_card.balance - input_money&.to_i - current_card.withdraw_tax(input_money&.to_i)
            if money_left > 0
              @current_account.cards[answer&.to_i - 1].balance = money_left

              @current_account.save_change

              puts "Money #{input_money&.to_i} withdrawed from #{current_card.number}$."
              puts "Money left: #{current_card.balance}$. Tax: #{current_card.withdraw_tax(input_money&.to_i)}$"
              return
            else
              puts I18n.t(:enough_money)
              return
            end
          else
            puts I18n.t(:correct_amount)
            return
          end
        end
      end
    else
      puts I18n.t(:no_active_cards)
    end
  end

  def print_cards
    @current_account.cards.each_with_index { |c, i| puts "- #{c.number}, #{c.class.name}, press #{i + 1}" }
    puts I18n.t(:press_exit)
  end

  def confirmation_delete_card(answer)
    puts "Are you sure you want to delete #{@current_account.cards[answer&.to_i - 1].number}?[y/n]"
    if gets.chomp == 'y'
      @current_account.cards.delete_at(answer&.to_i - 1)
      @current_account.save_change
    end
  end

  def show_cards
    if @current_account.cards.any?
      @current_account.cards.map { |card| puts "- #{card.number}, #{card.class.name}" }
    else
      puts I18n.t(:no_active_cards)
    end
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
