# frozen_string_literal: true

FactoryBot.define do
  factory :execution_result, class: 'RSpec::Core::Example::ExecutionResult' do
    status { :passed }
  end
end
