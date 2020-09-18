require 'rspec/core'
require 'rspec/core/formatters/console_codes'
require 'io/console'
require 'byebug'

class SpecSelector 
  include RSpec::Core::Formatters::ConsoleCodes

  RSpec::Core::Formatters.register self, :message, :example_group_started, 
                                                   :example_passed, 
                                                   :example_pending, 
                                                   :example_failed,
                                                   :dump_summary

  def initialize(output)
    open_buffer
    hide_cursor
    @output = output
    @groups = {}
    @map = {}
    @failed = []
    @passed = []
    @pending = []
    @failure_summaries = {}
    @pending_summaries = {}
    @pass_count = 0
    @fail_count = 0
    @pending_count = 0
    @selected = nil
    @summary_notification = nil
    @summary = []
    @exclude_passing = false
    @active_map = @map
    @all_passing = false
    @selector_index = 0
    @messages = []
  end

  def message(notification)
    @messages << notification.message
  end

  def example_group_started(notification)
    group = notification.group
    map(group)
    @groups[group.metadata] = group
  end

  def example_passed(notification)
    clear_frame
    @passed << notification.example
    @pass_count += 1
    status_count
  end

  def example_pending(notification)
    clear_frame
    @pending_summaries[notification.example] = notification
    @pending << notification.example
    @pending_count += 1
    status_count
  end

  def example_failed(notification)
    clear_frame
    @failure_summaries[notification.example] = notification
    @failed << notification.example
    @fail_count += 1
    status_count
  end

  def dump_summary(notification)
    print_messages unless @messages.empty?
    external_err_count = notification.errors_outside_of_examples_count
    errors_summary(notification) if external_err_count > 0
    examples_summary(notification) unless @map.empty? 
  end

  private

  def print_messages
    @messages.each { |message| italicize message}
    empty_line
    stand_alone_exit
  end

  def errors_summary(notification)
    errors = notification.errors_outside_of_examples_count
    italicize "Finished in #{notification.duration} seconds"
    italicize "Files loaded in #{notification.load_time}"
    empty_line
    italicize "#{errors} errors occurred outside of examples"
    italicize "Examples were not successfully executed"
    stand_alone_exit
  end

  def examples_summary(notification)
    clear_frame
    @summary_notification = notification
    status_summary(notification)
    test_data_summary
    all_passing?
    display_list(@map[:top_level])
    selector(@map[:top_level])
  end

  def all_passing?
    if (@pending_count + @fail_count == 0) && @pass_count > 0
      @all_passing = true
    end
  end

  def stand_alone_exit
    q_to_exit
    reading_input = true
    while reading_input
      input = $stdin.getch
      quit if input.match?(/q/i)
    end
  end

  def display_list(list)
    full_instructions(list)
    empty_line
    list.each { |item| format_list_item(item) }
  end

  def all_passed?(examples)
    examples.all? { |example| example.execution_result.status == :passed }
  end

  def any_failed?(examples)
    examples.any? { |example| example.execution_result.status == :failed }
  end

  def any_pending?(examples)
    examples.any? { |example| example.execution_result.status == :pending }
  end

  def color(text, symbol)
    @output.puts wrap(text, symbol)
  end

  def parent_description(data)
    return "" if !data[:parent_example_group]

    parent_data = data[:parent_example_group]
    parent_description(parent_data) + parent_data[:description] + ": "
  end

  def pass_count
    color("PASS: #{@pass_count}", :green)
  end

  def pending_count
    color("PENDING: #{@pending_count}", :yellow)
  end

  def fail_count
    color("FAIL: #{@fail_count}", :red)
  end

  def status_count
    pass_count
    pending_count if @pending_count > 0
    fail_count
    empty_line
  end

  def status_summary(notification)
    @summary << "Total Examples: #{notification.example_count}"
    @summary << "Finished in #{notification.duration} seconds"
    @summary << "Files loaded in #{notification.load_time} seconds"
  end

  def print_summary
    @summary.each { |sum| italicize(sum) }
    empty_line
  end

  def italicize(string)
    @output.puts "\e[3m" + string + "\e[0m"
  end

  def bold(string)
    @output.puts "\e[1m" + string + "\e[0m"
  end

  def map(group)
    map_group(group)
    map_examples(group) unless group.examples.empty?
  end

  def top_level(group)
    @map[:top_level] ||= []
    @map[:top_level] << group
  end

  def fetch_examples(item)
    return [item] if example?(item)
    examples = item.examples

    return examples if @map[item.metadata] == examples

    @map[item.metadata].each do |d| 
      examples += d.examples unless example?(d)
    end
    
    examples
  end

  def highlight(text)
    @output.puts "\e[1m\e[7m" + text + "\e[27m\e[22m"
  end

  def selector(list)
    clear_frame
    list ||= @active_map[:top_level]
    @selected ||= list.first
    test_data_summary
    display_list(list) 
    read_input(list)
  end

  def display_example
    clear_frame
    test_data_summary
    status = @selected.execution_result.status
    result_list, data = example_list(status)
    view_other_examples(status) if result_list.count > 1
    
    top_fail_text unless @failed.empty? || @selected == @failed.first
    back_instructions
    q_to_exit
    empty_line
    
    
    format_example(status, result_list, data)
    example_options(result_list)
  end

  def lineage(data)
    parent = parent_data(data)

    return data[:description] unless parent
    lineage(parent) + " -> " + data[:description]
  end

  def parent_data(data)
    return data[:example_group] if data.keys.include?(:example_group)
    return data[:parent_example_group] if data.keys.include?(:parent_example_group)
    nil
  end

  def exclude_passing!
    list = @map.reject { |k,v| v.all?{ |g| all_passed?(fetch_examples(g))}}
    list.transform_values! { |v| v.reject{ |g| all_passed?(fetch_examples(g))}}
    @active_map = list
    @exclude_passing = true
  end

  def include_passing!
    @active_map = @map
    @exclude_passing = false
  end

  def back_instructions
    @output.puts "Press [backspace] to return to parent group list"
    @output.puts "Press [escape] to return to top-level group list"
  end

  def full_instructions(list)
    @all_passing ? bold("ALL EXAMPLES PASSED\n") : filter_pass_instructions
    select_instructions(list)
    back_instructions unless list == @active_map[:top_level]
    q_to_exit 
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

  def q_to_exit
    @output.puts "Press Q to exit"
  end

  def empty_line
    @output.puts "\n"
  end

  def view_other_examples(status)
    verb = (status == :passed ? "passing" : status.to_s)
    @output.puts "Press ↑ or ↓ to view other #{verb} examples"
  end

  def format_example(status, result_list, data)
    index = result_list.index(@selected)
    enumeration = index + 1
    col = $stdout.winsize[1]
    
    if status == :failed || status == :pending
      data = data.fully_formatted(enumeration).split("\n")
      data[0] = ""
      data.insert(1,"-"*col)
      data.insert(3,"-"*col)
      @output.puts data
    else
      @output.puts "-"*col
      @output.puts "#{enumeration}) " + @selected.description
      @output.puts "-"*col
      color("PASSED", :green)
    end
  end

  def example_list(status)
    case status
    when :failed
      result_list = @failed
      data = @failure_summaries[@selected]
    when :pending
      result_list = @pending
      data = @pending_summaries[@selected]
    when :passed
      result_list = @passed
    end
    [result_list, data]
  end

  def example_options(result_list)
    index = result_list.index(@selected)
    ex_group = @active_map[@selected.example_group.metadata]

    input = user_input

    case input
    when /t/i
      @failed.empty? ? display_example : top_fail
    when "\x7F"
      selector(ex_group)
    when /q/i
      quit
    when "\e"
      @selected = nil
      selector(@active_map[:top_level])
    when "\e[A"
      index -= 1
      @selected = result_list[index]
      display_example
    when "\e[B" 
      index = (index + 1) % result_list.length
      @selected = result_list[index]
      display_example
    else
      display_example
    end
  end

  def user_input
    input = $stdin.getch

    if input == "\e"
      input << $stdin.read_nonblock(2) rescue input
    end

    input
  end

  def read_input(list)
    @selector_index = list.index(@selected) || 0
    reading_input = true

    while reading_input
      input = user_input

      case input
      when /f/i 
        passing_filter
      when /t/i
        next if @failed.empty?
        top_fail
      when /q/i
        quit
      when "\e[A"
        up(list)
      when "\e[B"
        down(list)
      when "\x7F"
        next if list == @active_map[:top_level]
        back
      when "\e"
        @selected = nil
        selector(@active_map[:top_level])
      when "\r"
        select_item
      end
    end
  end

  def format_list_item(item)
    description = lineage(item.metadata)
    data = example?(item) ? [item] : fetch_examples(item)

    if @selected == item
      highlight(description)
    else
      color(description, :green) if all_passed?(data)
      color(description, :yellow) if any_pending?(data)
      color(description, :red) if any_failed?(data)
    end
      
  end

  def example?(item)
    item.is_a?(RSpec::Core::Example)
  end

  def status(example)
    example.execution_result.status
  end

  def map_examples(group)
    @map[group.metadata] ||= []
    @map[group.metadata] += group.examples
  end

  def map_group(group)
    if !group.metadata[:parent_example_group]
      top_level(group)
    else
      parent = group.metadata[:parent_example_group]
      @map[parent] ||= []
      @map[parent] << group
    end
  end

  def passing_filter
    unless @all_passing
      @exclude_passing ? include_passing! : exclude_passing!
      new_list = @active_map[parent_data(@selected.metadata)] 
      new_list ||= @active_map[:top_level]
      @selected = nil
      selector(new_list)
    end
  end

  def quit
    clear_frame
    close_buffer
    reveal_cursor
    exit
  end

  def back
    data = parent_data(@selected.metadata)
    parent_key = parent_data(data) || :top_level
    parent_list = @active_map[parent_key]
    @selected = @groups[data]
    selector(parent_list)
  end

  def test_data_summary
    status_count
    print_summary
  end

  def up(list)
    @selector_index -= 1 unless @selector_index == 0
    @selected = list[@selector_index]
    clear_frame
    test_data_summary
    display_list(list)
  end

  def down(list)
    @selector_index += 1 unless @selector_index == list.length - 1
    @selected = list[@selector_index]
    clear_frame
    test_data_summary
    display_list(list)
  end

  def select_item
    display_example if example?(@selected)
    list = @active_map[@selected.metadata]
    @selected = nil
    selector(list)
  end

  def top_fail
    return if @failed.empty?
    @selected = @failed.first
    display_example
  end

  def top_fail_text
    @output.puts "Press T to view top failed example"
  end

  def clear_frame
    system("printf '\e[H'")
    system("printf '\e[0J'")
  end

  def open_buffer
    system("tput smcup")
  end

  def close_buffer
    system("tput rmcup")
  end

  def hide_cursor
    system("printf '\e[?25l'")
  end
  
  def reveal_cursor
    system("printf '\e[?25h'")
  end
end
