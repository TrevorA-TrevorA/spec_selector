# frozen_string_literal: true

describe SpecSelectorUtil::UI do
  include_context 'shared'

  let(:spec_selector) { SpecSelector.new(StringIO.new) }
  let(:output) { spec_selector.ivar(:@output).string }

  describe '#exit_only', break_loop: true do
    before { allow(spec_selector).to receive(:quit) }

    it 'prints instructions to quit' do
      spec_selector.exit_only
      expect(output).to match(/Press Q to quit/)
    end

    context 'when user enters "q"' do
      before { $stdin = StringIO.new('q') }

      it 'calls #quit' do
        spec_selector.exit_only
        expect(spec_selector).to have_received(:quit)
      end
    end

    context 'when user does not enter "q"' do
      it 'does not call #quit' do
        spec_selector.exit_only
        expect(spec_selector).not_to have_received(:quit)
      end
    end
  end

  describe '#selector' do
    before do
      spec_selector.ivar_set(:@active_map, mixed_map)
      allow_methods(:display_list, :navigate)
      spec_selector.selector
    end

    it 'sets default value of @list to @active_map[:top_level]' do
      expect(spec_selector.ivar(:@list)).to eq(mixed_map[:top_level])
    end

    it 'sets default value of @selected to @list.first' do
      expect(ivar(:@selected)).to eq(ivar(:@list).first)
    end

    it 'calls #display_list' do
      expect(spec_selector).to have_received(:display_list)
    end

    it 'calls #navigate' do
      expect(spec_selector).to have_received(:navigate)
    end
  end

  describe '#navigate', break_loop: true do
    context 'when @selected is included in @list' do
      it 'sets @selector_index to index position of @selected in @list' do
        ivars_set(:@selected => fail_group, :@list => mixed_map[:top_level])
        spec_selector.navigate
        expect(ivar(:@selector_index)).to eq(1)
      end
    end

    context 'when @selected is not included in @list' do
      it 'sets @selected to zero' do
        ivars_set(:@selected => failed_example, :@list => mixed_map[:top_level])
        spec_selector.navigate
        expect(ivar(:selector_index)).to eq(0)
      end
    end

    it 'calls #bind_input continuously' do
      allow_methods(:bind_input)
      spec_selector.navigate
      expect(spec_selector).to have_received(:bind_input).at_least(:twice)
    end
  end

  describe '#bind_input' do
    it 'captures user input' do
      binding = nil
      trace = TracePoint.new(:call) { |t| binding = t.binding }
      trace.enable(target: spec_selector.method(:bind_input))
      allow_methods(:tree_nav_keys)
      allow(spec_selector).to receive(:user_input).and_return("\r")
      spec_selector.bind_input
      expect(binding.eval('input')).to be("\r")
    end

    context 'when DIRECTION_KEYS includes input string' do
      it 'passes input string to #direction_keys' do
        allow(spec_selector).to receive(:user_input).and_return("\e[A")
        allow(spec_selector).to receive(:direction_keys)
        spec_selector.bind_input
        expect(spec_selector).to have_received(:direction_keys).with("\e[A")
      end
    end

    context 'when TREE_NAVIGATION_KEYS includes input string' do
      it 'passes input string to #tree_nav_keys' do
        allow(spec_selector).to receive(:user_input).and_return("\x7F")
        allow(spec_selector).to receive(:tree_nav_keys)
        spec_selector.bind_input
        expect(spec_selector).to have_received(:tree_nav_keys).with("\x7F")
      end
    end

    context 'when input string matches pattern in OPTION_KEYS' do
      it 'passes input string to #option_keys' do
        allow(spec_selector).to receive(:user_input).and_return('q')
        allow(spec_selector).to receive(:option_keys)
        spec_selector.bind_input
        expect(spec_selector).to have_received(:option_keys).with('q')
      end
    end
  end

  describe '#quit' do
    before do
      allow_methods(:clear_frame, :reveal_cursor, :exit)
      spec_selector.quit
    end

    it 'calls #clear_frame' do
      expect(spec_selector).to have_received(:clear_frame)
    end

    it 'calls #reveal_cursor' do
      expect(spec_selector).to have_received(:reveal_cursor)
    end

    it 'exits program' do
      expect(spec_selector).to have_received(:exit)
    end
  end

  describe '#top_level_list' do
    before do
      ivars_set(:@active_map => mixed_map, :@list => [passing_example])
      ivars_set(:@selected => passing_example, :@example_display => true)
      allow_methods(:selector)
      spec_selector.top_level_list
    end

    it 'sets @example_display to false' do
      expect(ivar(:@example_display)).to be false
    end

    it 'sets @selected to nil' do
      expect(ivar(:@selected)).to be_nil
    end

    it 'sets @list to @active_map[:top_level]' do
      expect(ivar(:@list)).to eq(mixed_map[:top_level])
    end

    it 'calls #selector' do
      expect(spec_selector).to have_received(:selector)
    end
  end

  describe '#select_item' do
    context 'when @example_display is true' do
      it 'returns immediately' do
        spec_selector.ivar_set(:@example_display, true)
        allow(spec_selector).to receive(:example?)
        spec_selector.select_item
        expect(spec_selector).not_to have_received(:example?)
      end
    end

    context 'when @example_display is false' do
      it 'does not return immediately' do
        ivars_set(:@selected => fail_group, :@example_display => false)
        allow_methods(:selector, :example?)
        spec_selector.select_item
        expect(spec_selector).to have_received(:example?)
      end
    end

    context 'when @selected is an example' do
      it 'calls #display_example' do
        ivars_set(:@selected => failed_example, :@list => [failed_example])
        allow_methods(:display_example, :selector)
        spec_selector.select_item
        expect(spec_selector).to have_received(:display_example)
      end
    end

    context 'when @selected is not an example' do
      before do
        ivars_set(:@active_map => mixed_map, :@selected => pass_group)
        allow_methods(:selector)
        spec_selector.select_item
      end

      it 'sets @list subgroups and/or examples that belong to @selected' do
        expect(ivar(:@list)).to eq(pass_group.examples)
      end

      it 'sets @selected to nil' do
        expect(ivar(:@selected)).to be_nil
      end

      it 'calls #selector' do
        expect(spec_selector).to have_received(:selector)
      end
    end
  end

  describe '#top_fail' do
    before { allow(spec_selector).to receive(:display_example) }

    context 'when there are no failed examples' do
      it 'returns immediately' do
        spec_selector.top_fail
        expect(spec_selector).not_to have_received(:display_example)
      end
    end

    context 'when there are failed examples' do
      before do
        spec_selector.ivar_set(:@failed, fail_group.examples)
        spec_selector.top_fail
      end

      it 'sets @selected to the top failed example' do
        expect(ivar(:@selected)).to eq(ivar(:@failed).first)
      end

      it 'calls #display_example' do
        expect(spec_selector).to have_received(:display_example)
      end
    end
  end

  describe '#back' do
    before { allow_methods(:parent_list, :selector) }

    context 'when top level list is currently displayed' do
      it 'returns immediately' do
        spec_selector.back
        expect(spec_selector).not_to have_received(:parent_list)
        expect(spec_selector).not_to have_received(:selector)
      end
    end

    context 'when top level list is not currently displayed' do
      before do
        spec_selector.ivar_set(:@list, mixed_map[fail_group.metadata[:block]])
        spec_selector.back
      end

      it 'calls #parent_list' do
        expect(spec_selector).to have_received(:parent_list)
      end

      it 'calls #selector' do
        expect(spec_selector).to have_received(:selector)
      end
    end
  end

  describe '#parent_list' do
    context 'when @example_display is true' do
      before do
        attrs = {
          :@active_map => mixed_map,
          :@selected => fail_group.examples.first,
          :@example_display => true
        }
        ivars_set(attrs)
        allow(ivar(:@selected)).to receive(:example_group) { fail_group }
        spec_selector.parent_list
      end

      it 'sets @example_display to false' do
        expect(ivar(:@example_display)).to be false
      end

      it 'sets @list to example group that includes @selected' do
        expect(ivar(:@list)).to eq(fail_group.examples)
      end
    end

    context 'when @example_display is already false' do
      before do
        ivars_set(:@selected => fail_subgroup, :@active_map => deep_map)
        ivars_set(:@groups => {
                    fail_parent_group.metadata[:block] => fail_parent_group
                  })
        spec_selector.parent_list
      end

      it 'sets @list to group that includes parent group' do
        expect(ivar(:@list)).to eq(deep_map[:top_level])
      end

      it 'sets @selected to parent group' do
        expect(ivar(:@selected)).to eq(fail_parent_group)
      end
    end
  end

  describe '#direction_keys' do
    let(:list) do
      [fail_group, pass_group, fail_group, fail_group, fail_group]
    end

    before do
      ivars_set(:@list => list, :@selector_index => 2)
      allow_methods(:display_list, :display_example)
    end

    context 'when input string is "\e[A"' do
      it 'decrements @selector_index' do
        spec_selector.direction_keys("\e[A")
        expect(ivar(:@selector_index)).to eq(1)
      end
    end

    context 'when input string is not "\e[A"' do
      # the only possible value of input string in this case is "\e[B"
      it 'increments @selector_index' do
        spec_selector.direction_keys("\e[B")
        expect(ivar(:@selector_index)).to eq(3)
      end
    end

    it 'sets @selected to @list element at @selector_index' do
      spec_selector.direction_keys("\e[A")
      expect(ivar(:@selected)).to eq(pass_group)
    end

    context 'when @example_display is true' do
      it 'calls #display_example' do
        ivar_set(:@example_display, true)
        spec_selector.direction_keys("\e[A")
        expect(spec_selector).to have_received(:display_example)
      end
    end

    context 'when @example_display is false' do
      it 'calls #display_list' do
        ivar_set(:@example_display, false)
        spec_selector.direction_keys("\e[A")
        expect(spec_selector).to have_received(:display_list)
      end
    end
  end

  describe '#tree_nav_keys' do
    before do
      allow_methods(:select_item, :back, :top_level_list)
    end

    context 'when input string is "\r"' do
      it 'calls #select_item' do
        spec_selector.tree_nav_keys("\r")
        expect(spec_selector).to have_received(:select_item)
      end
    end

    context 'when input string is "\x7F"' do
      it 'calls #back' do
        spec_selector.tree_nav_keys("\x7F")
        expect(spec_selector).to have_received(:back)
      end
    end

    context 'when input string is "\e"' do
      it 'calls #top_level_list' do
        spec_selector.tree_nav_keys("\e")
        expect(spec_selector).to have_received(:top_level_list)
      end
    end
  end

  describe '#option_keys' do
    before do
      allow_methods(:top_fail, :passing_filter, :quit)
    end

    context 'when input string matches /t/i' do
      it 'calls #top_fail' do
        spec_selector.option_keys('t')
        expect(spec_selector).to have_received(:top_fail)
      end
    end

    context 'when input string matches /p/i' do
      it 'calls #passing_filter' do
        spec_selector.option_keys('p')
        expect(spec_selector).to have_received(:passing_filter)
      end
    end

    context 'when input string matches /q/i' do
      it 'calls #quit' do
        spec_selector.option_keys('q')
        expect(spec_selector).to have_received(:quit)
      end
    end

    context 'when input string matches /i/i' do
      it 'calls #view_instructions_page' do
        allow(spec_selector).to receive(:view_instructions_page)
        spec_selector.option_keys('i')
        expect(spec_selector).to have_received(:view_instructions_page)
      end
    end
  end

  describe '#user_input' do
    it 'initially captures one byte of keyboard input' do
      binding = nil
      trace = TracePoint.new(:call) { |t| binding = t.binding }
      trace.enable(target: spec_selector.method(:user_input))
      allow($stdin).to receive(:getch).and_return("\x7F")
      spec_selector.user_input
      expect(binding.eval('input')).to eq("\x7F")
    end

    context 'when there is no further readable data in buffer' do
      before do
        stdin, user = IO.pipe
        user.print "\e"
        allow($stdin).to receive(:getch).and_return(stdin.getc)
        allow(IO).to receive(:select).and_return(more_data?(stdin))
      end

      it 'returns input string' do
        expect(spec_selector.user_input).to eq("\e")
      end
    end

    context 'when input buffer still contains readable data' do
      # user is assumed to have pressed a directional key
      before do
        stdin, user = IO.pipe
        user.print "\e[A"
        allow($stdin).to receive(:getch).and_return(stdin.getc)
        allow(IO).to receive(:select).and_return(more_data?(stdin))
        last_two_bytes = stdin.read_nonblock(2)
        allow($stdin).to receive(:read_nonblock).with(2).and_return(last_two_bytes)
      end

      it 'appends the next two bytes to the input string' do
        expect(spec_selector.user_input).to eq("\e[A")
      end
    end
  end
end
