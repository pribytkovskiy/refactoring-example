class Console
  attr_accessor :login, :name, :card, :password, :file_path

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
  CARDS_TYPE = { usual: 'usual', capitalist: 'capitalist', virtual: 'virtual' }.freeze
  FILE_PATH = 'accounts.yml'

  START_LENGTH_AGE = 23
  FINISH_LENGTH_AGE = 90

  def initialize
    @errors = []
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

  def create
    loop do
      name_input
      age_input
      login_input
      password_input
      break if @errors.length == 0
      @errors.map { |e| puts e }
      @errors = []
    end

    @current_account = Account.new(self)

    main_menu
  end

  def load
    loop do
      return create_the_first_account unless accounts.any?

      puts I18n.t(:enter_login)
      login = gets.chomp
      puts I18n.t(:enter_password)
      password = gets.chomp

      if accounts.map { |a| { login: a.login, password: a.password } }.include?({ login: login, password: password })
        a = accounts.select { |a| login == a.login }.first
        @current_account = a
        break
      else
        puts I18n.t(:no_account)
        next
      end
    end
    main_menu
  end

  def create_the_first_account
    puts I18n.t(:no_active_accounts)
    gets.chomp == 'y' ? create : console
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
      when COMMANDS_MENU[:destroy_account] then destroy_account
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

      case gets.chomp
      when CARDS_TYPE[:usual] then card = { type: 'usual', number: random_number, balance: 50.00 }
      when CARDS_TYPE[:capitalist] then card = { type: 'capitalist', number: random_number, balance: 100.00 }
      when CARDS_TYPE[:virtual] then card = { type: 'virtual', number: random_number, balance: 150.00 }
      else
        puts I18n.t(:wrong_card)
      end

      cards = @current_account.card << card
      @current_account.card = cards #important!!!

      new_accounts = [] # one medhod
      accounts.each { |ac| ac.login == @current_account.login ? new_accounts.push(@current_account) : new_accounts.push(ac) }  # one medhod
      File.open(FILE_PATH, 'w') { |f| f.write new_accounts.to_yaml } #Storing
      break
    end
  end

  def destroy_card
    loop do
      if @current_account.card.any?
        puts I18n.t(:want_to_delete)

        @current_account.card.each_with_index { |c, i| puts "- #{c[:number]}, #{c[:type]}, press #{i + 1}" }

        puts I18n.t(:press_exit)
        answer = gets.chomp
        break if answer == 'exit'

        if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i > 0
          puts "Are you sure you want to delete #{@current_account.card[answer&.to_i.to_i - 1][:number]}?[y/n]"

          a2 = gets.chomp
          if a2 == 'y'
            @current_account.card.delete_at(answer&.to_i.to_i - 1)

            new_accounts = [] # one medhod
            accounts.each { |ac| ac.login == @current_account.login ? new_accounts.push(@current_account) : new_accounts.push(ac) }
            File.open(FILE_PATH, 'w') { |f| f.write new_accounts.to_yaml } #Storing
            break
          else
            return
          end
        else
          puts I18n.t(:wrong_number)
        end
      else
        puts I18n.t(:no_active_cards)
        break
      end
    end
  end

  def show_cards
    if @current_account.card.any?
      @current_account.card.each { |c| puts "- #{c[:number]}, #{c[:type]}" }
    else
      puts I18n.t(:no_active_cards)
    end
  end

  def withdraw_money
    puts I18n.t(:choose_withdrawing)

    if @current_account.card.any?
      @current_account.card.each_with_index do |c, i|
        puts "- #{c[:number]}, #{c[:type]}, press #{i + 1}"
      end
      puts "press `exit` to exit\n"
      loop do
        answer = gets.chomp
        break if answer == 'exit'
        if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i > 0
          current_card = @current_account.card[answer&.to_i.to_i - 1]

          loop do
            puts I18n.t(:amount_money)
            a2 = gets.chomp
            if a2&.to_i.to_i > 0
              money_left = current_card[:balance] - a2&.to_i.to_i - withdraw_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)
              if money_left > 0
                current_card[:balance] = money_left
                @current_account.card[answer&.to_i.to_i - 1] = current_card

                new_accounts = [] # one medhod
                accounts.each { |ac| ac.login == @current_account.login ? new_accounts.push(@current_account) : new_accounts.push(ac) }
                
                File.open(FILE_PATH, 'w') { |f| f.write new_accounts.to_yaml } #Storing
                puts "Money #{a2&.to_i.to_i} withdrawed from #{current_card[:number]}$. Money left: #{current_card[:balance]}$. Tax: #{withdraw_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)}$"
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
        else
          puts I18n.t(:wrong_number)
          return
        end
      end
    else
      puts I18n.t(:no_active_cards)
    end
  end

  def put_money
    puts I18n.t(:choose_card)

    if @current_account.card.any?
      @current_account.card.each_with_index { |c, i| puts "- #{c[:number]}, #{c[:type]}, press #{i + 1}" }
      puts I18n.t(:press_exit)
      loop do
        answer = gets.chomp
        break if answer == COMMANDS[:exit]
        if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i > 0
          current_card = @current_account.card[answer&.to_i.to_i - 1]
          loop do
            puts I18n.t(:amount_money_card)
            amount_money = gets.chomp
            if amount_money&.to_i.to_i > 0
              if put_tax(current_card[:type], current_card[:balance], current_card[:number], amount_money&.to_i.to_i) >= amount_money&.to_i.to_i
                puts I18n.t(:tax_higher)
                return
              else
                new_money_amount = current_card[:balance] + amount_money&.to_i.to_i - put_tax(current_card[:type], current_card[:balance], current_card[:number], amount_money&.to_i.to_i)
                current_card[:balance] = new_money_amount
                @current_account.card[answer&.to_i.to_i - 1] = current_card

                new_accounts = [] # one medhod
                accounts.each { |ac| ac.login == @current_account.login ? new_accounts.push(@current_account) : new_accounts.push(ac) }

                File.open(FILE_PATH, 'w') { |f| f.write new_accounts.to_yaml } #Storing
                puts "Money #{amount_money&.to_i.to_i} was put on #{current_card[:number]}. Balance: #{current_card[:balance]}. Tax: #{put_tax(current_card[:type], current_card[:balance], current_card[:number], amount_money&.to_i.to_i)}"
                return
              end
            else
              puts I18n.t(:correct_amount_money)
              return
            end
          end
        else
          puts I18n.t(:wrong_number)
          return
        end
      end
    else
      puts I18n.t(:no_active_cards)
    end
  end

  def send_money
    puts I18n.t(:choose_card_sending)

    if @current_account.card.any?
      @current_account.card.each_with_index { |c, i| puts "- #{c[:number]}, #{c[:type]}, press #{i + 1}" }
      puts I18n.t(:exit)
      answer = gets.chomp
      exit if answer == COMMANDS[:exit]
      if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i > 0
        sender_card = @current_account.card[answer&.to_i.to_i - 1]
      else
        puts I18n.t(:choose_correct_card)
        return
      end
    else
      puts I18n.t(:no_active_cards)
      return
    end

    puts I18n.t(:recipient_card)
    enter_recipient_card = gets.chomp
    if enter_recipient_card.length > 15 && enter_recipient_card.length < 17
      all_cards = accounts.map(&:card).flatten
      if all_cards.select { |card| card[:number] == enter_recipient_card }.any?
        recipient_card = all_cards.select { |card| card[:number] == enter_recipient_card }.first
      else
        puts "There is no card with number #{enter_recipient_card}\n"
        return
      end
    else
      puts I18n.t(:correct_number_card)
      return
    end

    loop do
      puts I18n.t(:amount_money)
      amount_money = gets.chomp
      if amount_money&.to_i.to_i > 0
        sender_balance = sender_card[:balance] - amount_money&.to_i.to_i - sender_tax(sender_card[:type], sender_card[:balance], sender_card[:number], amount_money&.to_i.to_i)
        recipient_balance = recipient_card[:balance] + amount_money&.to_i.to_i - put_tax(recipient_card[:type], recipient_card[:balance], recipient_card[:number], amount_money&.to_i.to_i)

        if sender_balance < 0
          puts I18n.t(:enough_money)
        elsif put_tax(recipient_card[:type], recipient_card[:balance], recipient_card[:number], amount_money&.to_i.to_i) >= amount_money&.to_i.to_i
          puts I18n.t(:enough_money_sender_card)
        else
          sender_card[:balance] = sender_balance
          @current_account.card[answer&.to_i.to_i - 1] = sender_card
          new_accounts = []
          accounts.each do |ac|
            if ac.login == @current_account.login
              new_accounts.push(@current_account)
            elsif ac.card.map { |card| card[:number] }.include? enter_recipient_card
              recipient = ac
              new_recipient_cards = []
              recipient.card.each do |card|
                card[:balance] = recipient_balance if card[:number] == enter_recipient_card
                new_recipient_cards.push(card)
              end
              recipient.card = new_recipient_cards
              new_accounts.push(recipient)
            end
          end
          File.open(FILE_PATH, 'w') { |f| f.write new_accounts.to_yaml } #Storing
          puts "Money #{amount_money&.to_i.to_i}$ was put on #{sender_card[:number]}. Balance: #{recipient_balance}. Tax: #{put_tax(sender_card[:type], sender_card[:balance], sender_card[:number], a3&.to_i.to_i)}$\n"
          puts "Money #{amount_money&.to_i.to_i}$ was put on #{enter_recipient_card}. Balance: #{sender_balance}. Tax: #{sender_tax(sender_card[:type], sender_card[:balance], sender_card[:number], a3&.to_i.to_i)}$\n"
          break
        end
      else
        puts I18n.t(:wrong_number)
      end
    end
  end

  def destroy_account
    puts I18n.t(:destroy_account)
    a = gets.chomp
    if a == 'y'
      new_accounts = []
      accounts.each { |ac| new_accounts.push(ac) unless ac.login == @current_account.login }
      File.open(FILE_PATH, 'w') { |f| f.write new_accounts.to_yaml } #Storing
    end
  end

  private

  def random_number
    16.times.map{rand(10)}.join
  end

  def name_input
    puts I18n.t(:enter_name)
    @name = gets.chomp
    @errors.push('Your name must not be empty and starts with first upcase letter') if (@name == '' || @name[0].upcase != @name[0])
  end

  def login_input
    puts I18n.t(:enter_login)
    @login = gets.chomp
    case
    when @login == '' then @errors.push('Login must present')
    when @login.length < 4 then @errors.push('Login must be longer then 4 symbols')
    when @login.length > 20 then @errors.push('Login must be shorter then 20 symbols')
    end

    @errors.push('Such account is already exists') if (accounts.map { |a| a.login }.include? @login)
  end

  def password_input
    puts I18n.t(:enter_password)
    @password = gets.chomp
    case
    when @password == '' then @errors.push('Password must present')
    when @password.length < 6 then @errors.push('Password must be longer then 6 symbols')
    when @password.length > 30 then @errors.push('Password must be shorter then 30 symbols')
    end
  end

  def age_input
    puts I18n.t(:enter_age)
    @age = gets.chomp.to_i
    return @age if @age.between?(START_LENGTH_AGE, FINISH_LENGTH_AGE)
    @errors.push('Your Age must be greeter then 23 and lower then 90')
  end

  def accounts
    File.exists?(FILE_PATH) ? YAML.load_file(FILE_PATH) : []
  end

  def withdraw_tax(type, balance, number, amount)
    case type
    when CARDS_TYPE[:usual] then amount * 0.05
    when CARDS_TYPE[:capitalist] then amount * 0.04
    when CARDS_TYPE[:virtual] then amount * 0.88
    else
      0
    end
  end

  def put_tax(type, balance, number, amount)
    case type
    when CARDS_TYPE[:usual] then amount * 0.02
    when CARDS_TYPE[:capitalist] then 10
    when CARDS_TYPE[:virtual] then 1
    else
      0
    end
  end

  def sender_tax(type, balance, number, amount)
    case type
    when CARDS_TYPE[:usual] then 20
    when CARDS_TYPE[:capitalist] then amount * 0.1
    when CARDS_TYPE[:virtual] then 1
    else
      0
    end
  end
end
