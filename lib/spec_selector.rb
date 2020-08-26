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
    @output = output
    @groups = []
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
  end

  def message(notification)
    @output.puts notification.message
  end

  def example_group_started(notification)
    group = notification.group
    map(group)
    @groups << group
  end

  def example_passed(notification)
    system("clear")
    @passed << notification.example
    @pass_count += 1
    status_count
  end

  def example_pending(notification)
    system("clear")
    @pending_summaries[notification.example] = notification
    @pending << notification.example
    @pending_count += 1
    status_count
  end

  def example_failed(notification)
    system("clear")
    @failure_summaries[notification.example] = notification
    @failed << notification.example
    @fail_count += 1
    status_count
  end

  def dump_summary(notification)
    system("clear")
    @summary_notification = notification
    status_count
    status_summary(notification)
    print_summary
    display_list(@map[:top_level])
    sleep(1) 
    selector(@map[:top_level])
  end

  private

  def display_list(list)
      list.each do |item|
        description = lineage(item.metadata)
           
        if item.is_a?(RSpec::Core::Example)
          status = item.execution_result.status
          
          if @selected == item
            highlight(description)
          else
            color(description, :green) if status == :passed
            color(description, :yellow) if status == :pending
            color(description, :red) if status == :failed
          end
        else   
          examples = fetch_examples(item)

          if @selected == item
            highlight(description)
          else
            color(description, :green) if all_passed?(examples)
            color(description, :yellow) if any_pending?(examples)
            color(description, :red) if any_failed?(examples)
          end
        end
    end
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
    @output.puts "\n"
  end

  def status_summary(notification)
    @summary << "Total Examples: #{notification.example_count}"
    @summary << "Finished in #{notification.duration} seconds"
    @summary << "Files loaded in #{notification.load_time} seconds"
  end

  def print_summary
    @summary.each { |sum| italicize(sum) }
    @output.puts "\n"
  end

  def italicize(string)
    @output.puts "\e[3m" + string + "\e[0m"
  end

  def map(group)
    if !group.metadata[:parent_example_group]
      top_level(group)
    else
      parent_description = group.metadata[:parent_example_group][:description]
      @map[parent_description] ||= []
      @map[parent_description] << group
    end
  end

  def top_level(group)
    @map[:top_level] ||= []
    @map[:top_level] << group
  end

  def fetch_examples(group)
    examples = group.examples
    if @map[group.description]
      @map[group.description].each { |g| examples += g.examples }
    end
    examples
  end

  def highlight(text)
    @output.puts "\e[1m\e[7m" + text + "\e[27m\e[22m"
  end

  def selector(list)
    system("clear")
    list ||= @selected.examples
    index = 0
    @selected = list[index]
    status_count
    print_summary
    display_list(list)

    run_selector = true

    until run_selector == false
      input = $stdin.getch

      if input == "\e"
        input << $stdin.read_nonblock(2) rescue input
      end
      
      case input
      when /t/i
        @selected = @failed.first
        display_example
      when /q/i
        system("clear")
        exit
      when "\e[A"
        index -= 1 unless index == 0
        @selected = list[index]
        system("clear")
        status_count
        print_summary
        display_list(list)
      when "\e[B"
        index += 1 unless index == list.length - 1
        @selected = list[index]
        system("clear")
        status_count
        print_summary
        display_list(list)
      when "\x7F"
        next if list == @map[:top_level]

        if @selected.class == RSpec::Core::Example
          group = @selected.example_group.metadata[:parent_example_group]
          parent_key = group ? group[:description] : :top_level
          parent_list = @map[parent_key] if parent_key
        else
          group = @selected.metadata[:parent_example_group][:parent_example_group]
          parent_key = group ? group[:description] : :top_level
          parent_list = @map[parent_key]
        end

        selector(parent_list) if parent_list
      when "\e"
        selector(@map[:top_level])
      when "\r"
        run_selector = false

        if @selected.is_a?(RSpec::Core::Example)
          display_example
          return
        end

        list = @map[@selected.description]
        selector(list)
      end
    end
  end

  def display_example
    system("clear")
    status_count
    print_summary
    status = @selected.execution_result.status

    puts "Press BACKSPACE to return to list"
    puts "Press Q to quit"
    puts "Press ESC to return to top-level group list"
    puts "Press UP or DOWN to view other #{status} examples"
    puts "\n"

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
    
    ex_group = @selected.example_group.examples

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

    input = $stdin.getch

    if input == "\e"
      input << $stdin.read_nonblock(2) rescue input
    end

    case input
    when "\x7F"
      selector(ex_group)
    when /q/i
      system("clear")
      exit
    when "\e"
      selector(@map[:top_level])
    when "\e[A"
      index -= 1
      @selected = result_list[index]
      display_example
    when "\e[B" 
      index = (index + 1) % result_list.length
      @selected = result_list[index]
      display_example
    end
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
end
