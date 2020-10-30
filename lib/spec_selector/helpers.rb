# frozen_string_literal: true

module Helpers
  def all_passing?
    if (@pending_count + @fail_count == 0) && @pass_count.positiive?
      @all_passing = true
    end
  end

  def all_passed?(examples)
    examples.all? { |example| example.execution_result.status == :passed }
  end

  def any_failed?(examples)
    examples.any? { |example| example.execution_result.status == :failed }
  end

  def any_pending?(examples)
    examples.any? { |example| example.execution_result.status == :pending }
  end

  def example?(item)
    item.is_a?(RSpec::Core::Example)
  end

  def status(example)
    example.execution_result.status
  end

  def empty_line
    @output.puts "\n"
  end
end
