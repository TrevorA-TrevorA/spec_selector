RSpec.shared_context 'shared' do
  let(:spec_selector) { SpecSelector.new(StringIO.new) }
  let(:output) { spec_selector.ivar(:@output).string }
  let(:fail_result) { build(:execution_result, status: :failed) }
  let(:pending_result) { build(:execution_result, status: :pending) }
  let(:failed_example) { build(:example, execution_result: fail_result, metadata: { description: 'failed_example' }) }
  let(:pending_example) { build(:example, execution_result: pending_result, metadata: { description: 'pending_example' }) }
  let(:passing_example) { build(:example, metadata: { description: 'passing_example' }, description: "passing_example") }
  let(:pass_group) { build(:example_group, examples: [build(:example), build(:example)], metadata: { description: "pass_group" }) }
  let(:fail_group) { build(:example_group, examples: [failed_example, failed_example]) }
  let(:pending_group) { build(:example_group, examples: [pending_example, pending_example], metadata: { description: 'pending_group' }) }
  let(:mixed_result_group) { build(:example_group, examples: [passing_example, failed_example, pending_example]) }
  let(:fail_subgroup) do
    build(
      :example_group,
      metadata: {
        parent_example_group: {}
      },
      examples: [failed_example, failed_example]
    )
  end

  let(:pending_subgroup) do
    build(
      :example_group,
      metadata: {
        parent_example_group: {}
      },
      examples: [pending_example, pending_example]
    )
  end

  let(:fail_parent_group) { build(:example_group, examples: [], metadata: { description: 'fail_parent_group' }) }
  let(:pending_parent_group) { build(:example_group, examples: [], metadata: { description: 'pending_parent_group' }) }
  let(:pass_subgroup) do
    build(
      :example_group,
      metadata: { parent_example_group: pass_parent_group.metadata, description: 'pass_subgroup' },
      examples: [passing_example, passing_example]
    )
  end

  let(:pass_parent_group) { build(:example_group, examples: [], metadata: { description: 'pass_parent_group' }) }
  let(:mixed_list) { [pass_group, fail_group] }
  let(:mixed_map) do
    {
      :top_level => [pass_group, fail_group],
      pass_group.metadata[:block] => pass_group.examples,
      fail_group.metadata[:block] => fail_group.examples,
    }
  end

  let(:pending_map) do
    {
      :top_level => [pending_group],
      pending_group.metadata[:block] => pending_group.examples,
    }
  end

  let(:deep_map) do
    {
      :top_level => [pending_parent_group, pass_parent_group, fail_parent_group],
      pending_parent_group.metadata[:block] => [pending_subgroup],
      pass_parent_group.metadata[:block] => [pass_subgroup],
      fail_parent_group.metadata[:block] => [fail_subgroup],
      pending_subgroup.metadata[:block] => pending_subgroup.examples,
      pass_subgroup.metadata[:block] => pass_subgroup.examples,
      fail_subgroup.metadata[:block] => fail_subgroup.examples,
    }
  end

  let(:all_passing_map) do
    {
      top_level: [pass_group, pass_group],
      pass_group.metadata[:block] => pass_group.examples,
      pass_group.metadata[:block] => pass_group.examples
    }
  end

  def allow_methods(*methods)
    methods.each do |method|
      allow(spec_selector).to receive(method)
    end
  end

  def ivars_set(ivar_hash)
    ivar_hash.each do |ivar, value|
      spec_selector.ivar_set(ivar, value)
    end
  end

  def ivar_set(sym, value)
    spec_selector.ivar_set(sym, value)
  end

  def ivar(sym)
    spec_selector.ivar(sym)
  end

  def more_data?(readable)
    IO.select([readable], nil, nil, 0.000001)
  end

  def summary_settings(example)
    case example
    when failed_example
      notification_type = :failed_example_notification
      summary_list = :@failure_summaries
      ivar = :@failed
    when pending_example
      notification_type = :skipped_example_notification
      summary_list = :@pending_summaries
      ivar = :@pending
    end

    ivars_set(:@selected => example, ivar => [example])
    notification = build(notification_type, example: example)
    spec_selector.ivar(summary_list)[example] = notification
  end

  def expect_full_instructions_to_be_displayed
    expect(output).to include('Press I to hide instructions')
    expect(output).to include('Press F to exclude passing examples')
    expect(output).to include('Press ↑ or ↓ to navigate list')
    expect(output).to include('Press [enter] to select')
    expect(output).to include('Press Q to exit')
  end

  def expect_full_instructions_to_be_hidden
    expect(output).to include('Press I to view instructions')
    expect(output).not_to include('Press I to hide instructions')
    expect(output).not_to include('Press F to exclude passing examples')
    expect(output).not_to include('Press ↑ or ↓ to navigate list')
    expect(output).not_to include('Press [enter] to select')
    expect(output).not_to include('Press Q to exit')
  end
end
