# frozen_string_literal: true

module UI
  def stand_alone_exit
    q_to_exit
    reading_input = true

    while reading_input
      input = $stdin.getch
      quit if input.match?(/q/i)
    end
  end

  def selector(list)
    clear_frame
    list ||= @active_map[:top_level]
    @selected ||= list.first
    test_data_summary
    display_list(list)
    navigate_list(list)
  end

  def navigate_list(list)
    @selector_index = list.index(@selected) || 0
    reading_input = true

    while reading_input
      input = user_input

      case input
      when /f/i
        passing_filter
      when /t/i
        next if @failed.empty?
        top_fail
      when /q/i
        quit
      when "\e[A"
        up(list)
        display_list(list)
      when "\e[B"
        down(list)
        display_list(list)
      when "\x7F"
        next if list == @active_map[:top_level]
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
    selector(@active_map[:top_level])
  end

  def up(list)
    @selector_index = (@selector_index - 1) % list.length
    @selected = list[@selector_index]
  end

  def down(list)
    @selector_index = (@selector_index + 1) % list.length
    @selected = list[@selector_index]
  end

  def select_item
    display_example if example?(@selected)
    list = @active_map[@selected.metadata]
    @selected = nil
    selector(list)
  end

  def top_fail
    return if @failed.empty?

    @selected = @failed.first
    display_example
  end

  def back
    data = parent_data(@selected.metadata)
    parent_key = parent_data(data) || :top_level
    parent_list = @active_map[parent_key]
    @selected = @groups[data]
    selector(parent_list)
  end

  def navigate_summaries(result_list)
    @selector_index = result_list.index(@selected)
    ex_group = @active_map[@selected.example_group.metadata]

    input = user_input

    case input
    when /t/i
      @failed.empty? ? display_example : top_fail
    when "\x7F"
      selector(ex_group)
    when /q/i
      quit
    when "\e"
      back_to_top_level
    when "\e[A"
      up(result_list)
      display_example
    when "\e[B"
      down(result_list)
      display_example
    else
      display_example
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
