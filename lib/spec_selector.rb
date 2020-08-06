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
                                                   :dump_failures,
                                                   :dump_pending, 
                                                   :dump_summary

  def initialize(output)
    @output = output
    @groups = []
    @failed = []
    @passed = []
    @pending = []
    @failure_summaries = []
    @pending_summaries = []
    @pass_count = 0
    @fail_count = 0
    @pending_count = 0
  end

  def message(notification)
    @output.puts notification.message
  end

  def example_group_started(notification)
    @groups << notification.group
  end

  def example_passed(notification)
    system("clear")
    @passed << notification.example.description
    @pass_count += 1
    status_count
  end

  def example_pending(notification)
    system("clear")
    @pending << notification.example.description
    @pending_count += 1
    status_count
  end

  def example_failed(notification)
    system("clear")
    @failed << notification.example.description
    @fail_count += 1
    status_count
  end

  def dump_failures(notification)
    return if notification.failed_examples.empty?
    @failure_summaries << notification.fully_formatted_failed_examples
  end

  def dump_pending(notification)
    return if notification.pending_examples.empty?
    @pending_summaries << notification.fully_formatted_pending_examples
  end

  def dump_summary(notification)
    status_summary(notification) 
    display_groups 
  end

  private

  def display_groups
    @groups.each do |group|
      next if group.examples.empty?
      parent_desc = parent_description(group.metadata)
      desc = group.description
      full_desc = parent_desc + desc
      examples = group.examples

      color(full_desc, :green) if all_passed?(examples)
      color(full_desc, :yellow) if any_pending?(examples)
      color(full_desc, :red) if any_failed?(examples)
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
    italicize("Total Examples: #{notification.example_count}")
    italicize("Finished in #{notification.duration} seconds")
    italicize("Files loaded in #{notification.load_time} seconds")
    @output.puts "\n"
  end

  def italicize(string)
    @output.puts "\e[3m" + string + "\e[0m"
  end
end
