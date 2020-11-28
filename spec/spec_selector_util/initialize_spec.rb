# frozen_string_literal: true

describe SpecSelectorUtil::Initialize do
  # the subject calls #initialze_all during initialization, which calls
  # all of the other methods in this block.
  subject(:spec_selector) { SpecSelector.new(StringIO.new) }

  describe '#init_example_store' do
    it 'initializes @failed to an empty array' do
      expect(spec_selector.ivar(:@failed)).to eq([])
    end

    it 'initializes @passed to an empty array' do
      expect(spec_selector.ivar(:@passed)).to eq([])
    end

    it 'initializes @pending to an empty array' do
      expect(spec_selector.ivar(:@pending)).to eq([])
    end
  end

  describe '#init_summaries' do
    it 'initializes @failure_summaries to an empty hash' do
      expect(spec_selector.ivar(:@failure_summaries)).to eq({})
    end

    it 'initializes @pending_summaries to an empty hash' do
      expect(spec_selector.ivar(:@pending_summaries)).to eq({})
    end
  end

  describe '#init_counters' do
    it 'initializes @pass_count to zero' do
      expect(spec_selector.ivar(:@pass_count)).to eq(0)
    end

    it 'initializes @fail_count to zero' do
      expect(spec_selector.ivar(:@fail_count)).to eq(0)
    end

    it 'initializes @pending_count to zero' do
      expect(spec_selector.ivar(:@pending_count)).to eq(0)
    end
  end

  describe '#init_pass_inclusion' do
    it 'initializes @exclude_passing to false' do
      expect(spec_selector.ivar(:@exclude_passing)).to eq(false)
    end
  end

  describe '#init_map' do
    let(:map) { spec_selector.ivar(:@map) }

    it 'initializes @groups to an empty hash' do
      expect(spec_selector.ivar(:@groups)).to eq({})
    end

    it 'initializes @map to an empty hash' do
      expect(map).to eq({})
    end

    it 'initializes @active_map to @map' do
      expect(spec_selector.ivar(:@active_map)).to eq(map)
    end

    it 'initializes @list to nil' do
      expect(spec_selector.ivar(:@list)).to be_nil
    end
  end

  describe '#init_selector' do
    it 'initializes @selected to nil' do
      expect(spec_selector.ivar(:@selected)).to be_nil
    end

    it 'initialzes @selector_index to zero' do
      expect(spec_selector.ivar(:@selector_index)).to eq(0)
    end
  end

  # #initialize_all calls the above methods and initializes the
  # instance variables tested below.
  describe '#initialize_all' do
    it 'initializes @messages to an empty array' do
      expect(spec_selector.ivar(:@messages)).to eq([])
    end

    it 'initializes @instructions to false' do
      expect(spec_selector.ivar(:@instructions)).to eq(false)
    end
  end
end
