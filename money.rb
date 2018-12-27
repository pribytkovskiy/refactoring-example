class Money
  def withdraw_money
    
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
end
