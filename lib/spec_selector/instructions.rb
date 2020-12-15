# frozen_string_literal: true

module SpecSelectorUtil
  # The Instructions module contains methods used to render the
  # appropriate user instructions.
  module Instructions
    def basic_instructions
      i_for_instructions
      up_down_select_instructions
      q_to_exit if @notices.empty?
    end

    def all_passed_message
      bold("ALL EXAMPLES PASSED\n")
    end

    def empty_filter_notice
      @notices << '**********FILTER EMPTY**********'
      refresh_display
      @notices.pop
    end

    def back_instructions
      back_inst = 'Press [back] to view to parent group list'
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
      @output.puts "Press I to view full instructions"
    end

    def up_down_select_instructions
      up_down_inst = 'Press ↑ or ↓ to navigate list' if @list.count > 1
      select_inst = 'press [enter] to select'

      [up_down_inst, select_inst].each do |inst|
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
      bold('Press SHIFT + T to rerun only the top failed example')
      empty_line
      bold('Press M to include or remove selected item from run filter')
      empty_line

      if @inclusion_filter.size.positive?
        bold('Press C to clear filter')
        empty_line
        bold('Press A to clear filter and rerun all examples')
        empty_line
      end

      bold('Press I to exit instructions')
      empty_line
      bold('Press Q to quit')
      bind_input
    end

    def top_fail_text
      bold 'Press T to view top failed example'
    end

    def exit_instruction_page
      @instructions = false
      close_alt_buffer
    end

    def print_notices
      return if @notices.empty?
      @notices.each { |notice| @output.puts notice }
    end

    def example_summary_instructions
      i_for_instructions
      @output.puts 'Press M to remove from filter' if @selected.metadata[:include]
      @output.puts 'Press C to clear filter' unless @inclusion_filter.empty?
      top_fail_text unless @failed.empty? || @selected == @failed.first
      back_instructions
      q_to_exit
      print_notices || empty_line
    end
  end
end
