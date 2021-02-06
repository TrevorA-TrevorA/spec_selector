# frozen_string_literal: true

module TestObjects
  RSN = RSpec::Core::Notifications

  class Example < RSpec::Core::Example
    attr_accessor :metadata, :execution_result, :description, :example_group

    def initialize
    end
  end

  class ExecutionResult < RSpec::Core::Example::ExecutionResult
    attr_accessor :status
  end

  class ExampleGroup < RSpec::Core::ExampleGroup
    attr_accessor :examples, :metadata, :description
  end

  class SummaryNotification < RSN::SummaryNotification
    attr_accessor :example_count,
                  :duration,
                  :load_time,
                  :errors_outside_of_example_count
    :examples
  end

  class SkippedExampleNotification < RSN::SkippedExampleNotification
    attr_accessor :example

    def fully_formatted(_n)
      "\npending example"
    end
  end

  class FailedExampleNotification < RSN::FailedExampleNotification
    attr_accessor :example

    def initialize
    end

    def fully_formatted(_n)
      "\nfailed example"
    end
  end
end

FactoryBot.define do
  factory :execution_result, class: 'TestObjects::ExecutionResult' do
    status { :passed }
  end

  factory :example, class: 'TestObjects::Example' do
    execution_result { build(:execution_result) }
    description { 'passed' }
    metadata { {} }
  end

  factory :example_group, class: 'TestObjects::ExampleGroup' do
    examples { [build(:example)] }
    metadata { { block: self } }
    description do
      if self.examples.all? { |ex| ex.execution_result.status == :passed }
        'passing example group'
      else
        'non-passing example group'
      end
    end
  end

  factory :summary_notification, class: 'TestObjects::SummaryNotification' do
    example_count { 25 }
    duration { 1.5 }
    load_time { 0.5 }
    errors_outside_of_examples_count { 0 }
  end

  factory :skipped_example_notification,
    class: 'TestObjects::SkippedExampleNotification' do
    example
  end

  factory :failed_example_notification,
    class: 'TestObjects::FailedExampleNotification' do
      example
    end
end
