module Display
  def clear
    system('clear') || system('cls')
  end

  def display_welcome_message
    clear
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye."
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  # The definition of the display method like below also works!
  # def display_board(clear_screen: true)
  #   clear if clear_screen
  #   puts ...

  def display_board
    puts "You're an #{human.marker}. Computer is an #{computer.marker}"
    puts ""
    board.draw
  end
end
