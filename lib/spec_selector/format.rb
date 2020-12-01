# frozen_string_literal: true

module SpecSelectorUtil
  # The Format module contains methods used for simple text formatting, as well
  # as methods that determine how specific list items will be formatted.
  module Format
    ESCAPE_CODES = {
      green: 32,
      red: 31,
      yellow: 33,
      italicize: 3,
      bold: 1
    }.freeze

    ESCAPE_CODES.each do |sym, num|
      define_method(sym) do |text|
        @output.puts "\e[#{num}m#{text}\e[0m"
      end
    end

    def fetch_examples(item)
      return [item] if example?(item)

      examples = item.examples
      return examples if @map[item.metadata[:block]] == examples

      examples.reject! { |ex| ex.execution_result.status.nil? }

      @map[item.metadata[:block]].each do |d|
        examples += fetch_examples(d)
      end

      examples
    end

    def format_list_item(item)
      description = lineage(item.metadata)
      data = example?(item) ? [item] : fetch_examples(item)

      if @selected == item
        highlight(description)
      else
        green(description) if all_passed?(data)
        yellow(description) if any_pending?(data) && !any_failed?(data)
        red(description) if any_failed?(data)
      end
    end

    def pass_count
      green("PASS: #{@pass_count}")
    end

    def pending_count
      yellow("PENDING: #{@pending_count}")
    end

    def fail_count
      red("FAIL: #{@fail_count}")
    end

    def highlight(text)
      @output.puts "\e[1m\e[7m#{text}\e[27m\e[22m"
    end

    def lineage(data)
      parent = parent_data(data)
      return data[:description] unless parent

      lineage(parent) + ' -> ' + data[:description]
    end

    def format_example(status, data)
      if %i[failed pending].include?(status)
        print_nonpassing_example(data)
      else
        print_passing_example
      end
    end

    def print_nonpassing_example(data)
      data = data.fully_formatted(@selector_index + 1).split("\n")
      data[0] = ''
      data.insert(1, '-' * term_width)
      data.insert(3, '-' * term_width)
      @output.puts data
    end

    def print_passing_example
      @output.puts '-' * term_width
      @output.puts "#{@selector_index + 1}) " + @selected.description
      @output.puts '-' * term_width
      green('PASSED')
    end

    def parent_description(data)
      return '' unless data[:parent_example_group]

      parent_data = data[:parent_example_group]
      parent_description(parent_data) + parent_data[:description] + ': '
    end
  end
end
