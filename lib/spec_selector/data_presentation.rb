# frozen_string_literal: true

module SpecSelectorUtil
  # The DataPresentation module contains methods used to render mapped data.
  module DataPresentation
    def test_data_summary
      status_count
      print_summary
    end

    # If an exception is raised before an instance of SpecSelector is
    # initialized (for instance, a TypeError raised due to a configuration
    # problem), the MessageNotification will be sent to the registered
    # default formatter instead and will not be accessable to SpecSelector.
    # In such a case, the formatted error information is printed immediately
    # in the manner determined by the default formatter. This method simply
    # checks for a condition caused by that situation and leaves the error
    # information displayed until the user exits.
    def errors_before_formatter_initialization
      return unless @outside_errors_count.positive? && @messages == ['No examples found.']

      empty_line
      exit_only
    end

    def print_errors(notification)
      clear_frame
      print_messages
      errors_summary(notification)
    end

    def print_messages
      printed = 0
      @messages.each do |message|
        next if message.include?('Run options: include {:full_description=>')
        next if message.include?('Run options: include {:locations=>')

        italicize(message)
        printed += 1
      end
      empty_line if printed.positive?
    end

    def examples_summary(notification)
      @summary_notification = notification
      status_summary(notification)

      @list = if @inclusion_filter.empty? || @inclusion_filter.count > 10
                @map[:top_level]
              else
                @inclusion_filter
              end

      selector
    end

    def errors_summary(notification)
      err_count = notification.errors_outside_of_examples_count
      word_form = err_count > 1 ? 'errors' : 'error'
      italicize "Finished in #{notification.duration} seconds"
      italicize "Files loaded in #{notification.load_time}"
      empty_line
      italicize "#{err_count} #{word_form} occurred outside of examples"
      italicize 'Examples were not successfully executed'
      exit_only
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
      alt_map = @map.reject { |_, v| v.all? { |g| all_passed?(fetch_examples(g)) } }
      alt_map.transform_values! { |v| v.reject { |g| all_passed?(fetch_examples(g)) } }
      @active_map = alt_map
      @exclude_passing = true
    end

    def include_passing!
      @active_map = @map
      @exclude_passing = false
    end

    def toggle_passing
      return if all_passing?

      @exclude_passing ? include_passing! : exclude_passing!
      return if @example_display && @list != @passed && !@instructions

      exit_instruction_page
      p_data = parent_data(@selected.metadata)
      key = p_data ? p_data[:block] : :top_level
      new_list = @active_map[key]
      @list = new_list
      @selected = nil
      @example_display = false
      set_selected
      display_list
    end

    def status_summary(notification)
      @summary = []
      @summary << "Total Examples: #{@example_count}"
      @summary << "Finished in #{notification.duration} seconds"
      @summary << "Files loaded in #{notification.load_time} seconds"
    end

    def display_list
      clear_frame
      display_filter_mode
      test_data_summary
      print_messages unless @messages.empty?
      all_passed_message if all_passing?
      basic_instructions
      empty_line

      @list.each { |item| format_list_item(item) }
    end

    def view_inclusion_filter
      if @inclusion_filter.empty?
        empty_filter_notice
        return
      end

      @example_display = false
      exit_instruction_page if @instructions
      @list = @inclusion_filter
      @selected = @list.first unless @selected.metadata[:include]
      set_selected
      display_list
    end

    def display_stderr_log
      system("less #{stderr_log.path}")
    end

    def display_stdout_log
      system("less #{stdout_log.path}")
    end

    def refresh_display
      set_selected
      @example_display ? display_example : display_list
    end

    def display_example
      @example_display = true
      clear_frame
      display_filter_mode
      test_data_summary
      status = @selected.execution_result.status
      @list, data = example_list
      example_summary_instructions
      @output.puts 'Added to filter √' if @selected.metadata[:include]
      @selector_index = @list.index(@selected)
      view_other_examples(status) if @list.count > 1 && @instructions
      format_example(status, data)
    end

    def example_list
      status = @selected.execution_result.status
      result_list = @failed if status == :failed
      result_list = @pending if status == :pending
      result_list = @passed if status == :passed

      data = @failure_summaries[@selected] if status == :failed
      data = @pending_summaries[@selected] if status == :pending

      [result_list, data]
    end

    def messages_only
      clear_frame
      print_messages
      exit_only
    end
  end
end
