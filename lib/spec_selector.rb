require 'rspec/core'
require 'rspec/core/formatters/console_codes'
require 'io/console'
require 'byebug'
require_relative 'spec_selector/terminal'
require_relative 'spec_selector/UI'
require_relative 'spec_selector/format'
require_relative 'spec_selector/data_presentation'
require_relative 'spec_selector/helpers'
require_relative 'spec_selector/data_map'
require_relative 'spec_selector/initialize'
require_relative 'spec_selector/instructions'

class SpecSelector
  include RSpec::Core::Formatters::ConsoleCodes
  include UI
  include Terminal
  include Format
  include DataPresentation
  include Helpers
  include DataMap
  include Initialize
  include Instructions

  RSpec::Core::Formatters.register self, :message, :example_group_started,
                                                   :example_passed,
                                                   :example_pending,
                                                   :example_failed,
                                                   :dump_summary

  def initialize(output)
    @output = output
    initialize_all
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
    clear_frame
    print_messages unless @messages.empty?
    external_err_count = notification.errors_outside_of_examples_count
    errors_summary(notification) if external_err_count > 0
    examples_summary(notification) unless @map.empty? 
  end
end