# frozen_string_literal: true

module SpecSelectorUtil
  # The UI module contains methods used to bind and process user input.
  module UI
    DIRECTION_KEYS = ["\e[A", "\e[B"].freeze
    TREE_NAVIGATION_KEYS = ["\r", "\x7F", "\e"].freeze
    OPTION_KEYS = [
      /t/i, /f/i, /p/i, /q/i, /i/i, /r/i, /m/i, /c/i, /a/i, /v/i
    ].freeze

    def exit_only
      q_to_exit
      loop { quit if user_input.match?(/q/i) }
    end

    def selector
      @list ||= @active_map[:top_level]
      @selected ||= @list.first
      display_list
      navigate
    end

    def navigate
      @selector_index = @list.index(@selected) || 0
      loop { bind_input }
    end

    def bind_input
      input = user_input
      direction_keys(input) if DIRECTION_KEYS.include?(input)
      tree_nav_keys(input) if TREE_NAVIGATION_KEYS.include?(input)
      option_keys(input) if OPTION_KEYS.any? { |key| input.match?(key) }
    end

    def quit
      close_alt_buffer if @instructions
      clear_frame
      delete_filter_data
      reveal_cursor
      exit
    end

    def top_level_list
      exit_instruction_page if @instructions
      @example_display = false
      @selected = nil
      @list = @active_map[:top_level]
      selector
    end

    def select_item
      return if @example_display

      display_example if example?(@selected)
      @list = @active_map[@selected.metadata[:block]]
      @selected = nil
      selector
    end

    def exit_instruction_page_only
      exit_instruction_page
      refresh_display
    end

    def top_fail
      exit_instruction_page if @instructions
      return if @failed.empty?

      @selected = @failed.first
      display_example
    end

    def back
      return if top_level?

      parent_list
      selector
    end

    def parent_list
      if @example_display
        @example_display = false
        @list = @active_map[@selected.example_group.metadata[:block]]
      else
        data = parent_data(@selected.metadata)
        p_data = parent_data(data)
        parent_key = p_data ? p_data[:block] : :top_level
        @list = @active_map[parent_key]
        @selected = @groups[data[:block]]
      end
    end

    def direction_keys(input)
      exit_instruction_page if @instructions
      dir = input == "\e[A" ? -1 : 1
      @selector_index = (@selector_index + dir) % @list.length
      @selected = @list[@selector_index]
      @example_display ? display_example : display_list
    end

    def tree_nav_keys(input)
      exit_instruction_page_only if @instructions && input != "\e"
      
      case input
      when "\r"
        select_item
      when "\x7F"
        back
      when "\e"
        top_level_list
      end
    end

    def option_keys(input)

      case input
      when /t/i
        top_fail
      when /p/i
        toggle_passing
      when /f/i
        run_only_fails
      when /q/i
        quit
      when /i/i
        exit_instruction_page_only if @instructions
        view_instructions_page
      when /r/i
        rerun
      when /^a$/i
        rerun_all
      when /m/i
        return if @instructions
        @selected.metadata[:include] ? filter_remove : filter_include
      when /^c$/i
        clear_filter
      when /v/i
        view_inclusion_filter
      end
    end

    def user_input
      input = $stdin.getch
      return input unless IO.select([$stdin], nil, nil, 0.000001)
      input << $stdin.read_nonblock(2)
      input
    end
  end
end
