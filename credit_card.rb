class CreditCard
  
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
end
