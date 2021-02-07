# frozen_string_literal: true

module SpecSelectorUtil
  # The Terminal module contains methods concerned with terminal display
  # function.
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

    def term_height
      $stdout.winsize[0]
    end

    def open_alt_buffer
      system('tput smcup')
    end

    def close_alt_buffer
      system('tput rmcup')
    end

    def reset_cursor
      system("printf '\e[H'")
    end

    def term_width
      $stdout.winsize[1]
    end

    def position_cursor(row, col)
      system("printf '\e[#{row};#{col}H'")
    end
  end
end
