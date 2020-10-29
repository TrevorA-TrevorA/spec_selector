module Instructions
  def full_instructions(list)
    @all_passing ? bold("ALL EXAMPLES PASSED\n") : filter_pass_instructions
    select_instructions(list)
    back_instructions unless list == @active_map[:top_level]
    q_to_exit 
  end

  def back_instructions
    @output.puts "Press [backspace] to return to parent group list"
    @output.puts "Press [escape] to return to top-level group list"
  end

  def q_to_exit
    @output.puts "Press Q to exit"
  end

  def view_other_examples(status)
    verb = (status == :passed ? "passing" : status.to_s)
    @output.puts "Press ↑ or ↓ to view other #{verb} examples"
  end

  def filter_pass_instructions  
    verb = @exclude_passing ? "include" : "exclude"
    @output.puts "Press F to #{verb} passing examples"
  end

  def select_instructions(list)
    top_fail_text unless @failed.empty?
    @output.puts "Press ↑ or ↓ to navigate list" if list.count > 1
    @output.puts "Press [enter] to select"
  end

  def top_fail_text
    @output.puts "Press T to view top failed example"
  end

  def example_summary_instructions
    top_fail_text unless @failed.empty? || @selected == @failed.first
    back_instructions
    q_to_exit
    empty_line
  end
end