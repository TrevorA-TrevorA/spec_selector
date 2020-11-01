# frozen_string_literal: true

module Helpers
  def all_passing?
    return unless (@pending_count + @fail_count).zero? && @pass_count.positive?

    @all_passing = true
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

  def top_level?
    @list == @active_map[:top_level]
  end
end
