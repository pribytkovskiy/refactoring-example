class MoneyHelpers < ConsoleHelpers
  def withdraw_money
    puts I18n.t(:choose_withdrawing)
    puts I18n.t(:no_active_cards) and return unless @current_account.cards.any?

    withdraw_money_amount_money(choose_card)
  end

  def withdraw_money_amount_money(answer) # rubocop:disable  Metrics/AbcSize
    current_card = @current_account.cards[answer&.to_i.to_i - 1]
    puts I18n.t(:amount_money)
    input_money = gets.chomp
    return withdraw_money_left_money(input_money, current_card) if input_money&.to_i.to_i.positive?

    puts I18n.t(:correct_amount)
  end

  def withdraw_money_left_money(input_money, current_card) # rubocop:disable  Metrics/AbcSize
    money_left = current_card.balance - input_money&.to_i - current_card.withdraw_tax(input_money&.to_i)
    puts I18n.t(:enough_money) and return if money_left <= 0

    current_card.balance = money_left
    @current_account.save_change
    puts "Money #{input_money&.to_i}$ withdrawed from #{current_card.number}."
    puts "Money left: #{current_card.balance}$. Tax: #{current_card.withdraw_tax(input_money&.to_i)}$"
  end

  def put_money
    puts I18n.t(:choose_card)
    puts I18n.t(:no_active_cards) and return unless @current_account.cards.any?

    put_money_amount_money(choose_card)
  end

  def put_money_amount_money(answer) # rubocop:disable  Metrics/AbcSize
    current_card = @current_account.cards[answer&.to_i.to_i - 1]
    puts I18n.t(:amount_money_card)
    amount_money = gets.chomp
    return put_money_left_money(amount_money, current_card) if amount_money&.to_i.to_i.positive?

    puts I18n.t(:correct_amount_money)
  end

  def put_money_left_money(amount_money, current_card) # rubocop:disable  Metrics/AbcSize
    puts I18n.t(:tax_higher) and return if current_card.put_tax(amount_money&.to_i) >= amount_money&.to_i

    current_card.balance = current_card.balance + amount_money&.to_i - current_card.put_tax(amount_money&.to_i)
    @current_account.save_change
    puts "Money #{amount_money&.to_i}$ was put on #{current_card.number}."
    puts "Balance: #{current_card.balance}$. Tax: #{current_card.put_tax(amount_money&.to_i)}$"
  end

  def send_money
    puts I18n.t(:choose_card_sending)
    puts I18n.t(:no_active_cards) and return unless @current_account.cards.any?

    check_input_recipient_card(choose_card)
  end

  def check_input_recipient_card(answer)
    sender_card = @current_account.cards[answer&.to_i.to_i - 1]
    puts I18n.t(:recipient_card)
    enter_recipient_card = gets.chomp
    puts I18n.t(:correct_number_card) and return if enter_recipient_card.length != Account::CARD_LENGTH

    input_recipient_card(enter_recipient_card, sender_card)
  end

  def input_recipient_card(enter_recipient_card, sender_card)
    loop do
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
      return send_money_transfer(amount_money, sender_card, recipient_card) if amount_money&.to_i.to_i.positive?

      puts I18n.t(:wrong_number)
    end
  end

  def send_money_transfer(amount_money, sender_card, recipient_card)
    sender_balance = sender_card.balance - amount_money&.to_i - sender_card.sender_tax(amount_money&.to_i)
    recipient_balance = recipient_card.balance + amount_money&.to_i - recipient_card.put_tax(amount_money&.to_i)
    if sender_balance.negative?
      puts I18n.t(:enough_money)
    elsif recipient_card.put_tax(amount_money&.to_i) >= amount_money&.to_i
      puts I18n.t(:enough_money_sender_card)
    else
      transfer_puts(sender_balance, recipient_balance, amount_money, sender_card, recipient_card)
    end
    return # rubocop:disable Style/RedundantReturn
  end

  def transfer_puts(sender_balance, recipient_balance, amount_money, sender_card, recipient_card)
    sender_card.balance = sender_balance
    @current_account.save_change
    recipient_card.balance = recipient_balance
    @current_account.save_change_recipient_card(recipient_card)
    puts "Money #{amount_money&.to_i}$ was put on #{sender_card.number}."
    puts "Balance: #{sender_balance}$. Tax: #{sender_card.sender_tax(amount_money&.to_i)}$\n"
    puts "Money #{amount_money&.to_i}$ was send on #{recipient_card.number}."
    puts "Balance: #{recipient_balance}$. Tax: #{recipient_card.put_tax(amount_money&.to_i)}$\n"
  end

  def check_card_ordinal_number(answer)
    answer&.to_i.to_i <= @current_account.cards.length && answer&.to_i.to_i.positive?
  end
end
