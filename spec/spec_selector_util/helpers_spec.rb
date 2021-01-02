# frozen_string_literal: true

describe 'SpecSelectorUtil::Helpers' do
  include_context 'shared'

  describe '#all_passing?' do
    context 'when all examples have passed' do
      before { ivars_set({:@pass_count => 10, :@fail_count => 0, :@pending_count => 0}) }
      
      it 'returns true' do
        expect(spec_selector.all_passing?).to be true
      end
    end

    context 'when not all examples have passed' do
      before { ivars_set({:@pass_count => 5, :@fail_count => 5, :@pending_count => 5}) }
      
      it 'returns false' do
        expect(spec_selector.all_passing?).to be false
      end
    end
  end

  describe '#none_passing?' do
    context 'when no examples have passed' do
      before { ivars_set({:@pass_count => 0, :@fail_count => 5, :@pending_count => 5}) }

      it 'returns true' do
        expect(spec_selector.none_passing?).to be true
      end
    end

    context 'when at least one example has passed' do
      before { ivars_set({:@pass_count => 1, :@fail_count => 4, :@pending_count => 5}) }

      it 'returns false' do
        expect(spec_selector.none_passing?).to be false
      end
    end
  end

  describe '#all_passed?' do
    context 'when every example in argument array has passed' do
      let(:examples) { pass_group.examples }

      it 'returns true' do
        expect(spec_selector.all_passed?(examples)).to be true
      end
    end

    context 'when at least one example in argument array did not pass' do
      let(:examples) { mixed_result_group.examples }
      
      it 'returns false' do
        expect(spec_selector.all_passed?(examples)).to be false
      end
    end
  end

  describe '#any_failed?' do
    context 'when at least one example in argument array has failed' do
      let(:examples) { fail_group.examples }

      it 'returns true' do
        expect(spec_selector.any_failed?(examples)).to be true
      end
    end

    context 'when no examples in argument array have failed' do
      let(:examples) { pass_group.examples }

      it 'returns false' do
        expect(spec_selector.any_failed?(examples)).to be false
      end
    end
  end

  describe '#any_pending?' do
    context 'when at least one example has pending status' do
      let(:examples) { mixed_result_group.examples }

      it 'returns true' do
        expect(spec_selector.any_pending?(examples)).to be true
      end
    end

    context 'when no examples have pending status' do
      let(:examples) { fail_group.examples }

      it 'returns false' do
        expect(spec_selector.any_pending?(examples)).to be false
      end
    end
  end

  describe '#example?' do
    context 'when argument is an instance of RSpec::Core::Example' do
      let(:example) { build(:example) }
      
      it 'returns true' do
        expect(spec_selector.example?(example)).to be true
      end
    end

    context 'when argument is not an instance of RSpec::Core::Example' do
      let(:non_example) { build(:example_group) }
      
      it 'returns false' do
        expect(spec_selector.example?(non_example)).to be false
      end
    end
  end

  describe '#status' do
    it 'returns the execution result status of example' do
      expect(spec_selector.status(passing_example)).to eq(:passed)
    end
  end

  describe '#description_mode?' do
    context 'when @filter_mode is set to :description' do
      before { spec_selector.ivar_set(:@filter_mode, :description) }
      
      it 'returns true' do
        expect(spec_selector.description_mode?).to be true
      end
    end

    context 'when @filter_mode is not set to :description' do
      before { spec_selector.ivar_set(:@filter_mode, :location) }
      it 'returns false' do
        expect(spec_selector.description_mode?).to be false
      end
    end
  end

  describe '#location_mode?' do
    context 'when @filter_mode is set to :location' do
      before { spec_selector.ivar_set(:@filter_mode, :location) }

      it 'returns true' do
        expect(spec_selector.location_mode?).to be true
      end
    end

    context 'when @filter_mode is not set to :location' do
      before { spec_selector.ivar_set(:@filter_mode, :description) }

      it 'returns false' do
        expect(spec_selector.location_mode?).to be false
      end
    end
  end

  describe '#empty_line' do
    it 'prints an newline character' do
      spec_selector.empty_line
      expect(output).to eq("\n")
    end
  end

  describe '#top_level?' do
    context 'when current list is a top-level list' do
      before { ivars_set(:@active_map => mixed_map, :@list => mixed_map[:top_level]) }
      it 'returns true' do
        expect(spec_selector.top_level?).to be true
      end
    end

    context 'when current list is not a top-level list' do
      before { ivars_set(:@active_map => mixed_map, :@list => mixed_map[fail_group.metadata[:block]]) }
      
      it 'returns false' do
        expect(spec_selector.top_level?).to be false
      end
    end
  end

  describe '#filter_view?' do
    context 'when current list is inclusion filter' do
      before { ivars_set(:@inclusion_filter => fail_group.examples, :@list => fail_group.examples )}
      
      it 'returns true' do
        expect(spec_selector.filter_view?).to be true
      end
    end

    context 'when current list is not inclusion filter' do
      before { ivars_set(:@inclusion_filter => fail_group.examples, :@list => pass_group.examples )}

      it 'returns false' do
        expect(spec_selector.filter_view?).to be false
      end
    end
  end

  describe '#current_path' do
    it 'returns the absolute path to directory that contains the current file' do
      expect(spec_selector.current_path).to match(/spec_selector\/lib\/spec_selector$/)
    end
  end

  describe '#one_liner?' do
    context 'when the argument is an example written in descriptionless (one-liner) syntax' do
      let(:example) { build(:example, metadata: { description_args: [] }) }
      
      it 'returns true' do
        expect(spec_selector.one_liner?(example)).to be true
      end
    end

    context 'when the argument is a described example' do
      let(:example) { build(:example, metadata: { description_args: ['is a described example'] }) } 

      it 'returns false' do
        expect(spec_selector.one_liner?(example)).to be false
      end
    end
  end
end