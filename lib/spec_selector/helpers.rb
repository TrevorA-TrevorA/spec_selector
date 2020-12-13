# frozen_string_literal: true

module SpecSelectorUtil
  # The Helpers module contains helper methods shared across multiple
  # concerns.
  module Helpers
    def all_passing?
      (@pending_count + @fail_count).zero? && @pass_count.positive?
    end

    def none_passing?
      (@pending_count + @fail_count).positive? && @pass_count.zero?
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

    def filter_view?
      @list == @inclusion_filter
    end

    def current_path
      File.dirname(__FILE__)
    end

    def one_liner?(example)
      example.metadata[:description_args].empty?
    end
  end
end
