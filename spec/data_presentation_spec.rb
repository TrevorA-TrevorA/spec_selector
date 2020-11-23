# frozen_string_literal: true

describe Selector::DataPresentation do
  include_context 'shared objects'

  let(:spec_selector) { SpecSelector.new(StringIO.new) }
  let(:output) { spec_selector.ivar(:@output).string }
  let(:notification) { instance_double('SummaryNotification') }

  before do
    allow(spec_selector).to receive(:exit_only)
  end

  describe '#test_data_summary' do
    before do
      allow(spec_selector).to receive(:status_count)
      allow(spec_selector).to receive(:print_summary)
      spec_selector.test_data_summary
    end

    it 'calls #status_count' do
      expect(spec_selector).to have_received(:status_count)
    end

    it 'calls #print_summary' do
      expect(spec_selector).to have_received(:print_summary)
    end
  end

  describe '#print_messages' do
    before do
      spec_selector.ivar(:@messages) << 'example message one'
      spec_selector.ivar(:@messages) << 'example message two'
      allow(notification).to receive(:errors_outside_of_examples_count) { 0 }
    end

    it 'prints each message' do
      spec_selector.print_messages(notification)
      expect(output).to match(/example message one/)
      expect(output).to match(/example message two/)
    end

    context 'when errors outside examples have occurred' do
      it 'passes the summary notification to #errors_summary' do
        allow(notification).to receive(:errors_outside_of_examples_count) { 1 }
        allow(spec_selector).to receive(:errors_summary).with(notification)
        spec_selector.print_messages(notification)
        expect(spec_selector).to have_received(:errors_summary).with(notification)
      end
    end

    context 'when no errors outside examples have occurred' do
      it 'calls #exit_only' do
        spec_selector.print_messages(notification)
        expect(spec_selector).to have_received(:exit_only)
      end
    end
  end

  describe '#examples_summary' do
    before do
      allow(spec_selector).to receive(:status_summary).with(notification)
      allow(spec_selector).to receive(:selector)
      spec_selector.ivar(:@map)[:top_level] = :top_level
      spec_selector.examples_summary(notification)
    end

    it 'assigns the summary notification to an instance variable' do
      summary_notification = spec_selector.ivar(:@summary_notification)
      expect(summary_notification).to eq(notification)
    end
    
    it 'passes the notification object to #status_summary' do
      expect(spec_selector).to have_received(:status_summary).with(notification)
    end

    it 'sets the value of @list to @map[:top_level]' do
      expect(spec_selector.ivar(:@list)).to eq(:top_level)
    end

    it 'calls #selector' do
      expect(spec_selector).to have_received(:selector)
    end
  end

  describe '#errors_summary' do
    it 'prints text indicating number of errors outside examples' do
      allow(notification).to receive(:errors_outside_of_examples_count) { 3 }
      allow(notification).to receive(:duration)
      allow(notification).to receive(:load_time)
      spec_selector.errors_summary(notification)
      expect(output).to match(/3 errors occurred outside of examples/)
    end
  end

  describe '#status_count' do
    it 'calls #pass_count' do
      spec_selector.instance_variable_set(:@pass_count, 5)
      spec_selector.status_count
      expect(output).to match(/PASS: 5/)
    end
    
    it 'calls #fail_count' do
      spec_selector.instance_variable_set(:@fail_count, 3)
      spec_selector.status_count
      expect(output).to match(/FAIL: 3/)
    end

    context 'when there are pending examples' do
      it 'calls #pending_count' do
        spec_selector.instance_variable_set(:@pending_count, 2)
        spec_selector.status_count
        expect(output).to match(/PENDING: 2/)
      end
    end

    context 'when there no pending examples' do
      it 'does not call #pending_count' do
        expect(output).not_to match(/PENDING:/)
      end
    end
  end

  describe '#print_summary' do
    before do
      allow(notification).to receive(:example_count) { 30 }
      allow(notification).to receive(:duration) { 1.5 }
      allow(notification).to receive(:load_time) { 2.3 }
      spec_selector.status_summary(notification)
      spec_selector.print_summary
    end
    
    it 'prints total examples' do
      expect(output).to match(/Total Examples: 30/)
    end

    it 'prints total time for examples to run' do
      expect(output).to match(/Finished in 1.5 seconds/)
    end

    it 'prints total time for files to load' do
      expect(output).to match(/Files loaded in 2.3 seconds/)
    end
  end

  describe '#exclude_passing!' do
    before do
      spec_selector.instance_variable_set(:@map, mixed_result_map)
      spec_selector.exclude_passing!
    end

    it 'sets @active_map to map that excludes all-passing example groups' do
      expect(spec_selector.ivar(:@active_map)[:top_level]).not_to include(pass_group)
      expect(spec_selector.ivar(:@active_map)[:top_level]).to include(fail_group)
    end

    it 'sets @exclude_passing to true' do
      expect(spec_selector.ivar(:@exclude_passing)).to be true
    end
  end

  describe '#include_passing!' do
    before do
      spec_selector.instance_variable_set(:@map, mixed_result_map)
      spec_selector.exclude_passing!
    end

    it 'sets @active_map to @map' do
      expect(spec_selector.ivar(:@active)).not_to eq(spec_selector.ivar(:@map))
      spec_selector.include_passing!
      expect(spec_selector.ivar(:@active_map)).to eq(spec_selector.ivar(:@map))
    end
    
    it 'sets @exclude_passing to false' do
      expect(spec_selector.ivar(:@exclude_passing)).to be true
      spec_selector.include_passing!
      expect(spec_selector.ivar(:@exclude_passing)).to be false
    end
  end

  describe '#passing_filter' do
    before do
      allow(spec_selector).to receive(:display_list)
      allow(spec_selector).to receive(:navigate)
      spec_selector.instance_variable_set(:@map, mixed_result_map)
      spec_selector.instance_variable_set(:@list, mixed_list)
      spec_selector.instance_variable_set(:@selected, pass_group)
    end

    context 'when displayed list includes all-passing example groups' do
      it 'removes all-passing example groups from displayed list' do
        spec_selector.passing_filter
        expect(spec_selector.ivar(:@list)).not_to include(pass_group)
      end
    end
    
    context 'when all-passing example groups are already excluded' do
      it 'reverses the exclusion of all-passing example groups' do
        spec_selector.passing_filter
        expect(spec_selector.ivar(:@list)).not_to include(pass_group)
        spec_selector.passing_filter
        expect(spec_selector.ivar(:@list)).to include(pass_group)
      end
    end
  end

  describe '#status_summary' do
    let(:notification) { build(:summary_notification) }
    let(:summary) { spec_selector.ivar(:@summary) }

    before { spec_selector.status_summary(notification) }

    it 'stores message indicating example total in @summary' do
      expect(summary).to include(/Total Examples: 25/)
    end

    it 'stores message indicating total time to run examples in @summary' do
      expect(summary).to include(/Finished in 1.5 seconds/)
    end

    it 'stores message indicating total time to load files in @summary' do
      expect(summary).to include(/Files loaded in 0.5 seconds/)
    end
  end

  describe '#display_list' do
    before { allow(spec_selector).to receive(:test_data_summary) }

    context 'when all examples have passed' do
      it 'displays message indicating that all examples have passed' do
        spec_selector.instance_variable_set(:@map, all_passing_map)
        spec_selector.instance_variable_set(:@list, [pass_group, pass_group])
        allow(spec_selector).to receive(:all_passing?).and_return(true)
        spec_selector.display_list
        expect(output).to match(/ALL EXAMPLES PASSED/)
      end
    end

    context 'when not all examples have passed' do
      it 'does not display message indicating that all examples have passed' do
        spec_selector.instance_variable_set(:@map, mixed_result_map)
        spec_selector.instance_variable_set(:@list, mixed_list)
        allow(spec_selector).to receive(:all_passing?).and_return(false)
        spec_selector.display_list
        expect(output).not_to match(/ALL EXAMPLES PASSED/)
      end
    end

    context 'when user has pressed I to view instructions' do
      it 'displays full instructions' do
        spec_selector.instance_variable_set(:@map, mixed_result_map)
        spec_selector.instance_variable_set(:@list, mixed_list)
        spec_selector.instance_variable_set(:@instructions, true)
        spec_selector.display_list
        expect(output).to match(/[Press I to hide instructions]/)
        expect(output).to match(/[Press F to exclude passing examples]/)
        expect(output).to match(/[Press T to view top failed example]/)
        expect(output).to match(/[Press ↑ or ↓ to navigate list]/)
        expect(output).to match(/[Press [enter] to select]/)
        expect(output).to match(/[Press Q to exit]/)
      end
    end

    context 'when user has not pressed I to view full instructions' do
      it 'displays instruction to press I to view instructions' do
        spec_selector.instance_variable_set(:@map, mixed_result_map)
        spec_selector.instance_variable_set(:@list, mixed_list)
        spec_selector.display_list
        expect(output).to match(/Press I to view instructions/)
      end
    end

    it 'displays list of example groups or examples in current level' do
      spec_selector.instance_variable_set(:@map, mixed_result_map)
      spec_selector.instance_variable_set(:@list, mixed_list)
      spec_selector.display_list
      expect(output).to match(/[passing example group]/)
      expect(output).to match(/[non-passing example group]/)
    end
  end

  describe '#display_example' do
    context 'when example is failing or pending' do
      it 'displays example summary' do
        allow(spec_selector).to receive(:test_data_summary)
        allow(spec_selector).to receive(:navigate)
        example = pending_example
        spec_selector.instance_variable_set(:@selected, example)
        spec_selector.instance_variable_set(:@pending, [example])
        notification = build(:skipped_example_notification, example: example )
        spec_selector.ivar(:@pending_summaries)[example] = notification
        spec_selector.display_example
        expect(output).to match(/[pending example]/)
        example = failed_example
        spec_selector.instance_variable_set(:@selected, example)
        spec_selector.instance_variable_set(:@failed, [example])
        notification = build(:failed_example_notification, example: example)
        spec_selector.ivar(:@failure_summaries)[example] = notification
        spec_selector.display_example
        expect(output).to match(/[failed example]/)
      end
    end

    context 'when example is passing' do
      it 'displays text indicating the example passed' do
        allow(spec_selector).to receive(:test_data_summary)
        allow(spec_selector).to receive(:navigate)
        spec_selector.instance_variable_set(:@selected, passing_example)
        spec_selector.instance_variable_set(:@passed, [passing_example])
        spec_selector.display_example
        expect(output).to match(/[PASSED]/)
      end
    end
  end

  describe '#example_list' do
    it 'returns example list corresponding to execution result status' do
      expect(spec_selector.example_list(:passed)).to include(@passed)
    end

    context 'when example failed' do
      it 'returns failure summary of selected example' do
        example = failed_example
        spec_selector.instance_variable_set(:@selected, example)
        spec_selector.instance_variable_set(:@failed, [example])
        notification = build(:failed_example_notification, example: example)
        spec_selector.ivar(:@failure_summaries)[example] = notification
        expect(spec_selector.example_list(:failed)).to include(notification)
      end
    end

    context 'when example is pending' do
      it 'returns pending summary of selected example' do
        example = pending_example
        spec_selector.instance_variable_set(:@selected, example)
        spec_selector.instance_variable_set(:@pending, [example])
        notification = build(:skipped_example_notification, example: example )
        spec_selector.ivar(:@pending_summaries)[example] = notification
        expect(spec_selector.example_list(:pending)).to include(notification)
      end
    end
  end

  describe '#toggle_instructions' do
    context 'when full instructions are not currently displayed' do
      it 'displays full instructions' do
        allow(spec_selector).to receive(:test_data_summary)
        allow(spec_selector).to receive(:navigate)
        spec_selector.instance_variable_set(:@map, mixed_result_map)
        spec_selector.instance_variable_set(:@list, mixed_list)
        spec_selector.instance_variable_set(:@instuctions, false)
        spec_selector.toggle_instructions
        expect(output).to include('Press I to hide instructions')
        expect(output).to include('Press F to exclude passing examples')
        expect(output).to include('Press ↑ or ↓ to navigate list')
        expect(output).to include('Press [enter] to select')
        expect(output).to include('Press Q to exit')
      end
    end

    context 'when full instructions are currently displayed' do
      it 'conceals full instructions' do
        allow(spec_selector).to receive(:test_data_summary)
        allow(spec_selector).to receive(:navigate)
        spec_selector.instance_variable_set(:@map, mixed_result_map)
        spec_selector.instance_variable_set(:@list, mixed_list)
        spec_selector.instance_variable_set(:@instructions, true)
        spec_selector.toggle_instructions
        expect(output).to include('Press I to view instructions')
        expect(output).not_to include('Press I to hide instructions')
        expect(output).not_to include('Press F to exclude passing examples')
        expect(output).not_to include('Press T to view top failed example')
        expect(output).not_to include('Press ↑ or ↓ to navigate list')
        expect(output).not_to include('Press [enter] to select')
        expect(output).not_to include('Press Q to exit')
      end
    end
  end
end
