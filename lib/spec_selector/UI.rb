# frozen_string_literal: true

module UI
  UP = "\e[A"
  DOWN = "\e[B"
  DIRECTIONS = [UP, DOWN].freeze

  def stand_alone_exit
    q_to_exit
    reading_input = true

    while reading_input
      input = $stdin.getch
      quit if input.match?(/q/i)
    end
  end

  def selector
    clear_frame
    @list ||= @active_map[:top_level]
    @selected ||= @list.first
    test_data_summary
    display_list
    navigate
  end

  def navigate
    @selector_index = @list.index(@selected) || 0
    reading_input = true

    while reading_input
      input = user_input
      directions(input) if DIRECTIONS.include?(input)

      case input
      when /f/i
        passing_filter
      when /t/i
        top_fail
      when /q/i
        quit
      when "\x7F"
        back
      when "\e"
        back_to_top_level
      when "\r"
        select_item
      end
    end
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

  def up
    @selector_index = (@selector_index - 1) % @list.length
    @selected = @list[@selector_index]
    summary_list? ? display_example : display_list
  end

  def down
    @selector_index = (@selector_index + 1) % @list.length
    @selected = @list[@selector_index]
    summary_list? ? display_example : display_list
  end

  def select_item
    return if summary_list?

    display_example if example?(@selected)
    @list = @active_map[@selected.metadata]
    @selected = nil
    selector
  end

  def top_fail
    if @failed.empty?
      summary_list? ? display_example : return
    end

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

  def directions(input)
    up if input == UP
    down if input == DOWN
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
