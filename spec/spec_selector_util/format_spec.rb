# frozen_string_literal: true

describe 'SpecSelectorUtil::Format' do
  include_context 'shared'

  describe '#fetch_examples' do
    context 'when argument is an example' do
      let(:example) { build(:example) }

      it 'returns an array containing only the argument' do
        expect(spec_selector.fetch_examples(example)).to eq([example])
      end
    end

    context 'when argument is an example group with no subgroups' do
      before { ivar_set(:@map, mixed_map) }

      it 'returns an array of the examples that belong to the example group' do
        expect(spec_selector.fetch_examples(pass_group)).to eq(pass_group.examples)
      end
    end

    context 'when argument is an example group with subgroups' do
      before { ivar_set(:@map, deep_map) }

      it 'returns an array of all descendent examples of the example group' do
        expect(spec_selector.fetch_examples(fail_parent_group)).to eq(fail_subgroup.examples)
      end
    end
  end


  describe '#format_list_item' do
    context 'when argument is a currently selected list item' do
      before { ivars_set(:@list => deep_map[:top_level], :@selected => pass_parent_group, :@map => deep_map) }
      it 'prints the argument description in highlighted text' do
        spec_selector.format_list_item(pass_parent_group)
        expect(output).to eq("\e[1;7mpass_parent_group\e[0m\n")
      end
    end

    context 'when argument is non-selected passing example' do
      before { ivar_set(:@map, deep_map) }
      it 'prints the argument description in green text' do
        spec_selector.format_list_item(passing_example)
        expect(output).to eq("\e[1;32mpassing_example\e[0m\n")
      end
    end

    context 'when argument is non-selected example group whose descendent examples all pass' do
      before { ivar_set(:@map, mixed_map) }
      it 'prints the argument description in green text' do
        spec_selector.format_list_item(pass_group)
        expect(output).to eq("\e[1;32mpass_group\e[0m\n")
      end
    end

    context 'when argument is non-selected failed example' do
      it 'prints the argument description in red text' do
        spec_selector.format_list_item(failed_example)
        expect(output).to eq("\e[1;31mfailed_example\e[0m\n")
      end
    end

    context 'when argument is non-selected example group with at least one failed descendent example' do
      before { ivar_set(:@map, deep_map) }
      
      it 'prints the argument description in red text' do
        spec_selector.format_list_item(fail_parent_group)
        expect(output).to eq("\e[1;31mfail_parent_group\e[0m\n")
      end
    end

    context 'when argument is a pending example' do
      it 'prints the argument description in yellow text' do
        spec_selector.format_list_item(pending_example)
        expect(output).to eq("\e[1;33mpending_example\e[0m\n")
      end
    end

    context 'when argument is non-selected example group with at least one pending and no failed descendent examples' do
      before { ivar_set(:@map, pending_map) }
      
      it 'prints the argument description in yellow text' do
        spec_selector.format_list_item(pending_group)
        expect(output).to eq("\e[1;33mpending_group\e[0m\n")
      end
    end

    context 'when argument is included in filter' do
      let(:example) { build(:example, metadata: { include: true, description: 'the example' }) }

      it 'prints the argument description with a check mark' do
        spec_selector.format_list_item(example)
        expect(output).to eq("\e[1;32mthe example\e[0m √\n")
      end
    end
  end

  describe '#pass_count' do
    before { ivar_set(:@pass_count, 30) }

    it 'prints the current number of passing examples in green text' do
      spec_selector.pass_count
      expect(output).to eq("\e[1;32mPASS: 30\e[0m\n")
    end
  end

  describe '#pending_count' do
    before { ivar_set(:@pending_count, 10) }
  
    it 'prints the current number of pending examples' do
      spec_selector.pending_count
      expect(output).to eq("\e[1;33mPENDING: 10\e[0m\n")
    end
  end

  describe '#fail_count' do
    before { ivar_set(:@fail_count, 20) }
  
    it 'prints the current number of failed examples' do
      spec_selector.fail_count
      expect(output).to eq("\e[1;31mFAIL: 20\e[0m\n")
    end
  end

  describe '#highlight' do
    before { ivar_set(:@selected, passing_example)}
  
    it 'prints the argument in highlighted text' do
      spec_selector.highlight(passing_example.description)
      expect(output).to eq("\e[1;7mpassing_example\e[0m\n")
    end

    context 'when argument is included in filter' do
      
      it 'prints the argument with a check mark' do
        spec_selector.highlight(passing_example.description, true)
        expect(output).to eq("\e[1;7mpassing_example √\e[0m\n")
      end
    end
  end

  describe '#lineage' do
    it 'recursively prepends descriptions of ancestor example groups to description of argument' do
      expect(spec_selector.lineage(pass_subgroup.metadata)).to eq('pass_parent_group -> pass_subgroup')
    end
  end


  describe '#format_example' do
    it 'prints description of selected example' do
      ivar_set(:@selected, passing_example)
      spec_selector.format_example(:passed, nil)
      expect(output).to match(/passing_example/)
    end

    context 'when selected example is passing' do
      it 'prints "PASSED" in green text' do
        ivar_set(:@selected, passing_example)
        spec_selector.format_example(:passed, nil)
        expect(output).to include("\e[1;32mPASSED\e[0m")
      end
    end

    context 'when selected example is pending or failed' do
      let(:notification) { build(:failed_example_notification) }

      it 'prints example result summary' do
        ivar_set(:@selector_index, 0)
        spec_selector.format_example(:failed, notification)
        expect(output).to include("failed example")
      end
    end
  end


  describe '#print_nonpassing_example' do
    context 'when selected example is failed' do
      let(:notification) { build(:failed_example_notification) }

      it 'prints failure summary of selected example' do
        ivar_set(:@selector_index, 0)
        spec_selector.print_nonpassing_example(notification)
        expect(output).to include("failed example")
      end
    end

    context 'when selected example is pending' do
      let(:notification) { build(:skipped_example_notification) }

      it 'prints pending summary of selected example' do
        ivar_set(:@selector_index, 0)
        spec_selector.print_nonpassing_example(notification)
        expect(output).to include("pending example")
      end
    end
  end

  describe '#print_passing_example' do
    before do
      ivar_set(:@selected, passing_example)
      spec_selector.print_passing_example
    end

    it 'prints description of selected example' do
      expect(output).to include('passing_example')
    end

    it 'prints "PASSED"' do
      expect(output).to include('PASSED')
    end
  end
end