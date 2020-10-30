# frozen_string_literal: true

module DataPresentation
  def test_data_summary
    status_count
    print_summary
  end

  def print_messages
    @messages.each { |message| italicize message }
    empty_line
    stand_alone_exit
  end

  def examples_summary(notification)
    clear_frame
    @summary_notification = notification
    status_summary(notification)
    test_data_summary
    all_passing?
    display_list(@map[:top_level])
    selector(@map[:top_level])
  end

  def errors_summary(notification)
    errors = notification.errors_outside_of_examples_count
    italicize "Finished in #{notification.duration} seconds"
    italicize "Files loaded in #{notification.load_time}"
    empty_line
    italicize "#{errors} errors occurred outside of examples"
    italicize 'Examples were not successfully executed'
    stand_alone_exit
  end

  def status_count
    pass_count
    pending_count if @pending_count.positive?
    fail_count
    empty_line
  end

  def print_summary
    @summary.each { |sum| italicize(sum) }
    empty_line
  end

  def exclude_passing!
    list = @map.reject { |_, v| v.all? { |g| all_passed?(fetch_examples(g)) } }
    list.transform_values! { |v| v.reject { |g| all_passed?(fetch_examples(g)) } }
    @active_map = list
    @exclude_passing = true
  end

  def include_passing!
    @active_map = @map
    @exclude_passing = false
  end

  def passing_filter
    return if @all_passing

    @exclude_passing ? include_passing! : exclude_passing!
    new_list = @active_map[parent_data(@selected.metadata)]
    new_list ||= @active_map[:top_level]
    @selected = nil
    selector(new_list)
  end

  def status_summary(notification)
    @summary = []
    @summary << "Total Examples: #{notification.example_count}"
    @summary << "Finished in #{notification.duration} seconds"
    @summary << "Files loaded in #{notification.load_time} seconds"
  end

  def display_list(list)
    clear_frame
    test_data_summary
    full_instructions(list)
    empty_line
    list.each { |item| format_list_item(item) }
  end

  def display_example
    clear_frame
    test_data_summary
    status = @selected.execution_result.status
    result_list, data = example_list(status)
    example_summary_instructions
    view_other_examples(status) if result_list.count > 1
    format_example(status, result_list, data)
    navigate_summaries(result_list)
  end

  def example_list(status)
    result_list = @failed if status == :failed
    result_list = @pending if status == :pending
    result_list = @passed if status == :passed

    data = @failure_summaries[@selected] if status == :failed
    data = @pending_summaries[@selected] if status == :pending

    [result_list, data]
  end
end
