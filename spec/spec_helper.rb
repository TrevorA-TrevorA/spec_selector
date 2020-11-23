# frozen_string_literal: true

require 'spec_selector.rb'
require 'factory_bot'
require 'stringio'

RCN = RSpec::Core::Notifications
EXAMPLE_STUBS = { description: 'description',
                  execution_result: 'result',
                  full_description: 'full_description' }.freeze

alias ivar instance_variable_get

RSpec.shared_context 'shared objects' do
  let(:fail_result) { build(:execution_result, status: :failed) }
  let(:pending_result) { build(:execution_result, status: :pending) }
  let(:failed_example) { build(:example, execution_result: fail_result) }
  let(:pending_example) { build(:example, execution_result: pending_result) }
  let(:passing_example) { build(:example) }
  let(:pass_group) { build(:example_group) }
  let(:fail_group) { build(:example_group, examples: [failed_example]) }
  let(:mixed_list) { [pass_group, fail_group] }

  let(:mixed_result_map) do
    {
      top_level: [pass_group, fail_group],
      pass_group.metadata[:block] => pass_group.examples,
      fail_group.metadata[:block] => fail_group.examples
    }
  end

  let(:all_passing_map) do
    {
      top_level: [pass_group, pass_group],
      pass_group.metadata[:block] => pass_group.examples,
      pass_group.metadata[:block] => pass_group.examples
    }
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include_context 'shared objects', include_shared: true

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end
