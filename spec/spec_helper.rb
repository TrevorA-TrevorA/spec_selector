# frozen_string_literal: true

require 'spec_selector'
require 'factory_bot'
require 'stringio'

RCN = RSpec::Core::Notifications
EXAMPLE_STUBS = { description: 'description',
                  execution_result: 'result',
                  full_description: 'full_description' }.freeze

alias ivar instance_variable_get

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end
