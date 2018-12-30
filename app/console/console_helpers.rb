module ConsoleHelpers
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

  def input_destroy_card
    loop do
      puts I18n.t(:want_to_delete)
      print_cards
      answer = gets.chomp
      break if answer == Console::COMMANDS[:exit]

      return confirmation_delete_card(answer) if check_card_ordinal_number(answer)

      puts I18n.t(:wrong_number) unless check_card_ordinal_number(answer)
    end
  end

  def confirmation_delete_card(answer)
    puts "Are you sure you want to delete #{@current_account.cards[answer&.to_i.to_i - 1].number}?[y/n]"
    return if gets.chomp != Console::COMMANDS[:yes]

    @current_account.destroy_card(answer)
  end

  def choose_card
    print_cards
    loop do
      answer = gets.chomp
      break if answer == Console::COMMANDS[:exit]

      return answer if check_card_ordinal_number(answer)

      puts I18n.t(:wrong_number) unless check_card_ordinal_number(answer)
    end
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
