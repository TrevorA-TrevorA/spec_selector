RSpec.shared_context 'shared' do
  let(:fail_result) { build(:execution_result, status: :failed) }
  let(:pending_result) { build(:execution_result, status: :pending) }
  let(:failed_example) { build(:example, execution_result: fail_result) }
  let(:pending_example) { build(:example, execution_result: pending_result) }
  let(:passing_example) { build(:example) }
  let(:pass_group) { build(:example_group) }
  let(:fail_group) { build(:example_group, examples: [failed_example, failed_example]) }
  let(:fail_subgroup) do
    build(
      :example_group,
      metadata: {
        parent_example_group: {}
      },
      examples: [failed_example, failed_example]
    )
  end

  let(:fail_parent_group) { build(:example_group, examples: [], metadata: {}) }
  let(:pass_subgroup) do
    build(
      :example_group,
      metadata: { parent_example_group: pass_parent_group },
      examples: [passing_example, passing_example]
    )
  end

  let(:pass_parent_group) { build(:example_group, examples: [], metadata: {}) }
  let(:mixed_list) { [pass_group, fail_group] }
  let(:mixed_map) do
    {
      top_level: [pass_group, fail_group],
      pass_group.metadata[:block] => pass_group.examples,
      fail_group.metadata[:block] => fail_group.examples
    }
  end

  let(:deep_map) do
    {
      top_level: [pass_parent_group, fail_parent_group],
      pass_parent_group.metadata[:block] => [pass_subgroup],
      fail_parent_group.metadata[:block] => [fail_subgroup],
      pass_subgroup.metadata[:block] => pass_subgroup.examples,
      fail_subgroup.metadata[:block] => fail_subgroup.examples
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