# frozen_string_literal: true

module UI
  DIRECTION_KEYS = ["\e[A", "\e[B"].freeze
  TREE_NAVIGATION_KEYS = ["\r", "\x7F", "\e"].freeze
  OPTION_KEYS = [/t/i, /f/i, /q/i, /i/i].freeze

  def exit_only
    q_to_exit
    loop { quit if user_input.match?(/q/i) }
  end

  def selector
    clear_frame
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
    clear_frame
    reveal_cursor
    exit
  end

  def back_to_top_level
    @selected = nil
    @list = @active_map[:top_level]
    selector
  end

  def select_item
    return if summary_list?

    display_example if example?(@selected)
    @list = @active_map[@selected.metadata]
    @selected = nil
    selector
  end

  def top_fail
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
    if summary_list?
      @list = @active_map[@selected.example_group.metadata]
    else
      data = parent_data(@selected.metadata)
      parent_key = parent_data(data) || :top_level
      @list = @active_map[parent_key]
      @selected = @groups[data]
    end
  end

  def direction_keys(input)
    case input
    when "\e[A"
      dir = -1 # up
    when "\e[B"
      dir = 1 # down
    end

    @selector_index = (@selector_index + dir) % @list.length
    @selected = @list[@selector_index]
    summary_list? ? display_example : display_list
  end

  def tree_nav_keys(input)
    case input
    when "\r"
      select_item
    when "\x7F"
      back
    when "\e"
      back_to_top_level
    end
  end

  def option_keys(input)
    case input
    when /t/i
      top_fail
    when /f/i
      passing_filter
    when /q/i
      quit
    when /i/i
      toggle_instructions
    end
  end

  def user_input
    input = $stdin.getch
    return input unless input == "\e"

    begin
      input << $stdin.read_nonblock(2)
    rescue IO::EAGAINWaitReadable
      nil
    end

    input
  end
end
