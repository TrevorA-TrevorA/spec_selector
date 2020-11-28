describe SpecSelectorUtil::DataMap do
  subject(:spec_selector) { SpecSelector.new(StringIO.new) }

  let(:example_group) do
    instance_double('ExampleGroup', examples: [], metadata: {
      block: :example_group_block
    })
  end

  let(:map) { spec_selector.ivar(:@map) }

  # #map takes an example group as an argument
  describe '#map' do
    it 'passes the example group to #map_group' do
      allow(spec_selector).to receive(:map_group).with(example_group)
      .and_call_original
      spec_selector.map(example_group)
      expect(spec_selector).to have_received(:map_group).with(example_group)
    end

    context 'when the example group contains examples' do
      it 'passes the example group to #map_examples' do
        allow(example_group).to receive(:examples) { [instance_double('Example')] }
        allow(spec_selector).to receive(:map_examples).with(example_group)
        allow(spec_selector).to receive(:map_group).with(example_group)
        spec_selector.map(example_group)
        expect(spec_selector).to have_received(:map_examples).with(example_group)
      end
    end

    context 'when the example group does not contain examples' do
      it 'does not pass the example group to #map_examples' do
        allow(spec_selector).to receive(:map_group)
        allow(spec_selector).to receive(:map_examples)
        spec_selector.map(example_group)
        expect(spec_selector).not_to have_received(:map_examples)
      end
    end
  end

  describe '#top_level_push' do
    before { spec_selector.top_level_push(example_group) }

    it 'lazy-initializes @map[:top_level] to an array' do
      expect(map[:top_level]).to be_an(Array)
    end

    it 'stores example group in @map[:top_level]' do
      expect(map[:top_level]).to include(example_group)
    end
  end

  # takes takes the metadata hash from an example group or from an
  # example as its argument
  describe '#parent_data' do
    context 'when metadata hash is from an example' do
      let(:example_metadata) { { example_group: example_group.metadata } }
      let(:example) { instance_double('Example', metadata: example_metadata) }

      it 'returns metadata of the example group to which the example belongs' do
        expect(spec_selector.parent_data(example_metadata))
        .to eq(example_group.metadata)
      end
    end

    context 'when metadata hash is from an example group' do
      context 'when the example group has a parent group' do
        let(:example_group) do
          instance_double('ExampleGroup',  metadata: {
            parent_example_group: { block: :parent_example_block }
          })
        end

        it 'returns the parent group metadata' do
          expect(spec_selector.parent_data(example_group.metadata))
          .to eq(example_group.metadata[:parent_example_group])
        end
      end

      context 'when the example group does not have a parent group' do
        it 'returns nil' do
          expect(spec_selector.parent_data(example_group.metadata)).to be_nil
        end
      end
    end
  end

  describe '#map_group' do
    let(:map) { spec_selector.ivar(:@map) }
    before { spec_selector.map_group(example_group) }

    context 'when example group has parent group' do
      let(:example_group) do
        instance_double('ExampleGroup', metadata: {
          parent_example_group: { block: :parent_block }
         })
      end



      it 'stores the parent block as a key in @map initialized to an array' do
        expect(map[:parent_block]).to be_an(Array)
      end

      it 'stores the example group in the parent block array' do
        expect(map[:parent_block]).to include(example_group)
      end
    end

    context 'when example group does not have parent group' do
      it 'passes the example group to #top_level_push' do
        expect(map[:top_level]).to include(example_group)
      end
    end
  end

  describe '#map_examples' do
    let(:example) { instance_double('Example') }

    before do
      example_group.examples << example
      spec_selector.map_examples(example_group)
    end

    it 'stores an example block as a key in @map with an array as its value' do
      expect(map[:example_group_block]).to be_an(Array)
    end

    it 'appends the examples to the array' do
      expect(map[:example_group_block]).to include(example)
    end
  end
end
