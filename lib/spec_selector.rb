# frozen_string_literal: true
require 'rspec/core'
require 'io/console'
require 'byebug'
require 'json'
require_relative 'spec_selector/terminal'
require_relative 'spec_selector/UI'
require_relative 'spec_selector/format'
require_relative 'spec_selector/data_presentation'
require_relative 'spec_selector/helpers'
require_relative 'spec_selector/data_map'
require_relative 'spec_selector/initialize'
require_relative 'spec_selector/instructions'
require_relative 'spec_selector/state'

# The SpecSelector instance receives example execution data from the reporter
# and arranges it into a formatted, traversable map.
class SpecSelector
  include SpecSelectorUtil::UI
  include SpecSelectorUtil::Terminal
  include SpecSelectorUtil::Format
  include SpecSelectorUtil::DataPresentation
  include SpecSelectorUtil::Helpers
  include SpecSelectorUtil::DataMap
  include SpecSelectorUtil::Initialize
  include SpecSelectorUtil::Instructions
  include SpecSelectorUtil::State

  RSpec::Core::Formatters.register self,
                                   :message,
                                   :example_group_started,
                                   :example_passed,
                                   :example_pending,
                                   :example_failed,
                                   :dump_summary

  def initialize(output)
    @output = output
    hide_cursor
    initialize_all
  end

  def message(notification)
    @messages << notification.message
  end

  def example_group_started(notification)
    group = notification.group
    map_group(group)
    @groups[group.metadata[:block]] = group
    check_inclusion_status(group)
  end

  def example_passed(notification)
    clear_frame
    @passed << notification.example
    map_example(notification.example)
    check_inclusion_status(notification.example)
    @pass_count += 1
    status_count
  end

  def example_pending(notification)
    clear_frame
    @pending_summaries[notification.example] = notification
    @pending << notification.example
    map_example(notification.example)
    check_inclusion_status(notification.example)
    @pending_count += 1
    status_count
  end

  def example_failed(notification)
    clear_frame
    @failure_summaries[notification.example] = notification
    @failed << notification.example
    map_example(notification.example)
    check_inclusion_status(notification.example)
    @fail_count += 1
    status_count
  end

  def dump_summary(notification)
    @outside_errors_count = notification.errors_outside_of_examples_count
    errors_before_formatter_initialization
    print_errors(notification) if @outside_errors_count.positive?
    messages_only if @map.empty?
    examples_summary(notification)
  end
end
