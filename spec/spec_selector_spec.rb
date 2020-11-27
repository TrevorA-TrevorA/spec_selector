# frozen_string_literal: true

describe SpecSelector do
  include_context 'shared objects'

  let(:spec_selector) { described_class.new(StringIO.new) }

  let(:output) { spec_selector.ivar(:@output).string }
  let(:pass_result) { build(:execution_result) }
  let(:pending_result) { build(:execution_result, status: :pending) }

  let(:fail_result) do
    build(:execution_result, status: :failed, exception: 'error')
  end

  describe '#message' do
    let(:notification) { RCN::MessageNotification.new('message') }

    it 'stores the message string in the @messages array' do
      messages = spec_selector.ivar(:@messages)
      spec_selector.message(notification)
      expect(messages).to include('message')
    end
  end

  describe '#example_group_started' do
    let(:group) do
      instance_double('ExampleGroup', metadata: { block: 'key' }, examples: [])
    end

    let(:notification) { RCN::GroupNotification.new(group) }

    it 'passes the example group to SpecSelector#map' do
      expect(spec_selector).to receive(:map).with(group)
      spec_selector.example_group_started(notification)
    end

    it 'stores example group in the @groups hash' do
      spec_selector.example_group_started(notification)
      groups = spec_selector.ivar(:@groups)
      expect(groups.values).to include(group)
    end

  end

  describe '#example_passed' do
    let(:example) { instance_double('Example', execution_result: pass_result) }
    let(:notification) { RCN::ExampleNotification.send(:new, example) }

    before do
      spec_selector.example_passed(notification)
    end

    it 'stores example in @passed array' do
      passed = spec_selector.ivar(:@passed)
      expect(passed).to include(example)
    end

    it 'increments @pass_count' do
      pass_count = spec_selector.ivar(:@pass_count)
      expect(pass_count).to eq(1)
    end

    it 'updates passing example status display' do
      expect(output).to match(/PASS: \d+/)
    end
  end

  describe '#example_pending' do
    let(:example) { instance_double('Example', execution_result: pending_result) }
    let(:notification) { RCN::ExampleNotification.send(:new, example) }

    before do
      spec_selector.example_pending(notification)
    end

    it 'stores example in @pending array' do
      pending = spec_selector.ivar(:@pending)
      expect(pending).to include(notification.example)
    end

    it 'increments @pending_count' do
      pending_count = spec_selector.ivar(:@pending_count)
      expect(pending_count).to eq(1)
    end

    it 'updates pending status display' do
      expect(output).to match(/PENDING: \d+/)
    end
  end

  describe '#example_failed' do
    let(:example) do
      instance_double('Example',
                      full_description: 'full description',
                      execution_result: fail_result)
    end

    let(:notification) { RCN::FailedExampleNotification.send(:new, example) }

    before do
      spec_selector.example_failed(notification)
    end

    it 'stores example in @failed array' do
      failed = spec_selector.ivar(:@failed)
      expect(failed).to include(notification.example)
    end

    it 'increments @fail_count' do
      fail_count = spec_selector.ivar(:@fail_count)
      expect(fail_count).to eq(1)
    end

    it 'calls #status_count' do
      expect(output).to match(/FAIL: \d+/)
    end
  end

  describe '#dump_summary', break_loop: true do
    let(:notification) { build(:summary_notification) }

    context 'when errors outside of examples have occurred' do
      let(:notification) do
         build(:summary_notification, errors_outside_of_examples_count: 2)
      end

      it 'passes notification to #print_errors' do
        allow(spec_selector).to receive(:print_errors).and_call_original
        spec_selector.dump_summary(notification)
        expect(spec_selector).to have_received(:print_errors).with(notification)
      end
    end

    context 'when errors outside of examples have not occured' do
      it 'does not call #print_errors' do
        allow(spec_selector).to receive(:print_errors).and_call_original
        spec_selector.dump_summary(notification)
        expect(spec_selector).not_to have_received(:print_errors)
      end
    end

    context 'when non-error messages are present with no examples' do
      it 'calls #messages only' do
        spec_selector.ivar(:@messages) << 'some message'
        spec_selector.dump_summary(notification)
      end
    end

    context 'when examples successfully executed' do
      it 'passes notification to #examples_summary' do
        ivar_set(:@map, mixed_map)
        allow(spec_selector).to receive(:examples_summary).and_call_original
        spec_selector.dump_summary(notification)
        expect(spec_selector).to have_received(:examples_summary)
        .with(notification)
      end
    end
  end
end
