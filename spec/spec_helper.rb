# frozen_string_literal: true

require 'spec_selector'
require 'factory_bot'
require 'stringio'
require 'timeout'
require 'shared_context'

RCN = RSpec::Core::Notifications
EXAMPLE_STUBS = { description: 'description',
                  execution_result: 'result',
                  full_description: 'full_description' }.freeze

alias ivar instance_variable_get
alias ivar_set instance_variable_set

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.filter_run_when_matching :focus

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include_context 'shared', include_shared: true

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.around(:example, break_loop: true) do |example|
    begin
      Timeout.timeout(0.001) do
        example.run
      end
    rescue Timeout::Error
      nil
    end
  end
end
