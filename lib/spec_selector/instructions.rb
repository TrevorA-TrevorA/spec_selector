# frozen_string_literal: true

module SpecSelectorUtil
  # The Instructions module contains methods used to render the
  # appropriate user instructions.
  module Instructions
    def basic_instructions
      i_for_instructions
      up_down_select_instructions
      q_to_exit
    end

    def all_passed_message
      bold("ALL EXAMPLES PASSED\n")
    end

    def empty_filter_notice
      notice = '**********FILTER EMPTY**********'
      row = term_width / 2 - notice.length / 2
      position_cursor(1, row)
      @output.puts notice
      reset_cursor

      nil
    end

    def display_filter_mode
      return if @inclusion_filter.empty?

      notice = "FILTER MODE: #{@filter_mode.to_s.upcase}"
      col = term_width / 2 - notice.length / 2
      position_cursor(1, col)
      italicize notice
      reset_cursor
    end

    def back_instructions
      back_inst = 'Press [backspace] to view to parent group list'
      escape_inst = 'Press [escape] to view to top-level group list'

      [back_inst, escape_inst].each do |inst|
        if @instructions
          bold(inst)
          empty_line
        else
          @output.puts inst
        end
      end
    end

    def q_to_exit
      @output.puts 'Press Q to exit'
    end

    def view_other_examples(status)
      verb = (status == :passed ? 'passing' : status.to_s)
      @output.puts "Press ↑ or ↓ to view other #{verb} examples"
    end

    def filter_pass_instructions
      verb = @exclude_passing ? 'show' : 'hide'
      bold "Press P to #{verb} passing examples in current set"
    end

    def i_for_instructions
      @output.puts 'Press I to view full instructions'
    end

    def up_down_select_instructions
      up_down_inst = 'Press ↑ or ↓ to navigate list'
      select_inst = 'press [enter] to select'
      instructions_text = [select_inst]
      instructions_text.unshift(up_down_inst) if @list.count > 1

      instructions_text.each do |inst|
        if @instructions
          bold(inst)
          empty_line
        else
          @output.puts inst
        end
      end
    end

    def view_instructions_page
      @instructions = true
      open_alt_buffer

      unless @failed.empty? || @selected == @failed.first
        top_fail_text
        empty_line
      end

      unless all_passing? || none_passing?
        filter_pass_instructions
        empty_line
      end

      up_down_select_instructions
      back_instructions unless top_level?
      bold('Press R to rerun examples with filter selection')
      empty_line
      bold('Press F to rerun only failed examples')
      empty_line
      bold('Press T to rerun only the top failed example')
      empty_line
      bold('Press M to include or remove selected item from run filter')
      empty_line

      if @inclusion_filter.size.positive?
        bold('Press C to clear filter')
        empty_line
        bold('Press A to clear filter and rerun all examples')
        empty_line
      end

      bold('Press E to view stderr log')
      empty_line
      bold('Press O to view stdout log')
      empty_line
      bold('Press I to exit instructions')
      empty_line
      bold('Press Q to quit')
      bind_input
    end

    def toggle_instructions
      unless @instructions
        view_instructions_page
        return
      end

      exit_instruction_page_only
    end

    def top_fail_text
      text = 'Press [spacebar] to view top failed example'
      @instructions ? bold(text) : @output.puts(text)
    end

    def exit_instruction_page
      return unless @instructions

      @instructions = false
      close_alt_buffer
    end

    def example_summary_instructions
      i_for_instructions
      @output.puts 'Press M to remove from filter' if @selected.metadata[:include]
      @output.puts 'Press C to clear filter' unless @inclusion_filter.empty?
      top_fail_text unless @failed.empty? || @selected == @failed.first
      back_instructions
      q_to_exit
      empty_line
    end
  end
end
