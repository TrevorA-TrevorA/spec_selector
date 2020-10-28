module Terminal
  def clear_frame
    system("printf '\e[H'")
    system("printf '\e[3J'")
    system("printf '\e[0J'")
  end

  def hide_cursor
    system("printf '\e[?25l'")
  end
  
  def reveal_cursor
    system("printf '\e[?25h'")
  end
end