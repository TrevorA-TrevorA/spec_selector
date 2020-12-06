# frozen_string_literal: true

module SpecSelectorUtil
  # The Instructions module contains methods used to render the
  # appropriate user instructions.
  module Instructions
    def full_instructions
      i_for_instructions
      filter_pass_instructions unless all_passing? || none_passing?
      select_instructions
      back_instructions unless top_level?
      q_to_exit
    end

    def all_passed_message
      bold("ALL EXAMPLES PASSED\n")
    end

    def back_instructions
      @output.puts 'Press [backspace] to return to parent group list'
      @output.puts 'Press [escape] to return to top-level group list'
    end

    def q_to_exit
      @output.puts 'Press Q to exit'
    end

    def view_other_examples(status)
      verb = (status == :passed ? 'passing' : status.to_s)
      @output.puts "Press ↑ or ↓ to view other #{verb} examples"
    end

    def filter_pass_instructions
      verb = @exclude_passing ? 'include' : 'exclude'
      @output.puts "Press P to #{verb} passing examples"
    end

    def i_for_instructions
      verb = @instructions ? 'hide' : 'view'
      @output.puts "Press I to #{verb} instructions"
    end

    def select_instructions
      top_fail_text unless @failed.empty?
      @output.puts 'Press ↑ or ↓ to navigate list' if @list.count > 1
      @output.puts 'Press [enter] to select'
      @output.puts 'Press R to rerun examples'
      @output.puts 'Press F to rerun only failed results'
      @output.puts 'Press M to include or remove item from run filter'

      if @inclusion_filter.size.positive?
        @output.puts 'Press C to clear filter' 
        @output.puts 'Press A to clear filter and rerun all examples'
      end
    end

    def top_fail_text
      @output.puts 'Press T to view top failed example'
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
