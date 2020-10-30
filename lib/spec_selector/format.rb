# frozen_string_literal: true

module Format
  def fetch_examples(item)
    return [item] if example?(item)

    examples = item.examples

    return examples if @map[item.metadata] == examples

    @map[item.metadata].each do |d|
      examples += d.examples unless example?(d)
    end

    examples
  end

  def format_list_item(item)
    description = lineage(item.metadata)
    data = example?(item) ? [item] : fetch_examples(item)

    if @selected == item
      highlight(description)
    else
      color(description, :green) if all_passed?(data)
      color(description, :yellow) if any_pending?(data)
      color(description, :red) if any_failed?(data)
    end
  end

  def color(text, symbol)
    @output.puts wrap(text, symbol)
  end

  def pass_count
    color("PASS: #{@pass_count}", :green)
  end

  def pending_count
    color("PENDING: #{@pending_count}", :yellow)
  end

  def fail_count
    color("FAIL: #{@fail_count}", :red)
  end

  def italicize(string)
    @output.puts "\e[3m" + string + "\e[0m"
  end

  def bold(string)
    @output.puts "\e[1m" + string + "\e[0m"
  end

  def highlight(text)
    @output.puts "\e[1m\e[7m" + text + "\e[27m\e[22m"
  end

  def lineage(data)
    parent = parent_data(data)

    return data[:description] unless parent

    lineage(parent) + ' -> ' + data[:description]
  end

  def format_example(status, result_list, data)
    index = result_list.index(@selected)
    enumeration = index + 1
    col = $stdout.winsize[1]

    if [:failed, :pending].include?(status)
      data = data.fully_formatted(enumeration).split("\n")
      data[0] = ''
      data.insert(1, '-'*col)
      data.insert(3, '-'*col)
      @output.puts data
    else
      @output.puts '-'*col
      @output.puts "#{enumeration}) " + @selected.description
      @output.puts '-'*col
      color('PASSED', :green)
    end
  end

  def parent_description(data)
    return "" if !data[:parent_example_group]

    parent_data = data[:parent_example_group]
    parent_description(parent_data) + parent_data[:description] + ': '
  end
end
