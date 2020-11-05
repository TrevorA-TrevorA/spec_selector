# frozen_string_literal: true

module Selector
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

    def term_width
      $stdout.winsize[1]
    end
  end
end
