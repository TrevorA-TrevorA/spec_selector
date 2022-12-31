# frozen_string_literal: true

module SpecSelectorUtil
  # The State module contains methods that facilitate example rerun and filtering
  module State
    def rerun
      prepare_rerun
      descriptions, marker = appended_arguments
      rerun_script = "#{current_path}/scripts/rerun.sh"
      prepended = [rerun_script, Process.pid, Dir.pwd].join(' ')

      Signal.trap('TERM') do
        clear_frame
        exit
      end

      system("#{prepended} #{$PROGRAM_NAME} #{@rerun_arguments} #{descriptions} #{marker}")
    end

    def filter_include(item = @selected)
      @filter_mode = :location if one_liner?(item)
      item.metadata[:include] = true
      @inclusion_filter << item
    end

    def prepare_rerun
      display_rerun
      persist_filter
      reset_arguments
      prepare_location_arguments if location_mode?
      delete_filter_data if @inclusion_filter.empty?
    end

    def display_rerun
      close_alt_buffer if @instructions
      clear_frame
      italicize('running examples...')
    end

    def appended_arguments
      return [nil, 0] if location_mode?

      [prepare_description_arguments, @filtered_descriptions.count]
    end

    def persist_filter
      persist_descriptions
      persist_locations if location_mode?
    end

    def run_only_fails
      return if @failed.empty?

      @inclusion_filter = []
      @failed.each { |example| filter_include(example) }
      rerun
    end

    def rerun_all
      @inclusion_filter = []
      rerun
    end

    def filter_remove
      @inclusion_filter -= [@selected]
      @selected.metadata[:include] = nil
      @filter_mode = :descripton unless @inclusion_filter.any? { |item| one_liner?(item) }
    end

    def add_or_remove_from_filter
      return if @instructions

      @selected.metadata[:include] ? filter_remove : filter_include
      refresh_display
    end

    def persist_descriptions
      @filtered_descriptions = @inclusion_filter.map do |item|
        item.metadata[:full_description]
      end

      filter = @filtered_descriptions.to_json
      File.write(@descriptions_file, filter)
    end

    def delete_filter_data
      [@descriptions_file, @locations_file].each do |file|
        File.delete(file) if File.exist?(file)
      end
    end

    def reset_arguments
      remove_old_descriptions
      remove_old_locations
    end

    def remove_old_locations
      return if @last_run_locations.empty?

      @last_run_locations.each { |loc| @rerun_arguments.slice!(loc) }
    end

    def remove_old_descriptions
      old_descriptions = @last_run_descriptions.map { |desc| "-e #{desc}" }
      @rerun_arguments = ARGV.join(' ')
      old_descriptions.each { |desc| @rerun_arguments.slice!(desc) }
    end

    def persist_locations
      @filtered_locations = @inclusion_filter.map(&:location)
      locations = @filtered_locations.to_json
      File.write(@locations_file, locations)
    end

    def prepare_location_arguments
      @rerun_arguments += " #{@filtered_locations.join(' ')}"
    end

    def prepare_description_arguments
      return if @inclusion_filter.empty?

      contains_singles = @filtered_descriptions.select { |desc| desc.include?("'") }
      included = @filtered_descriptions - contains_singles
      return contains_singles.to_s if included.empty?

      included = included.to_s.gsub('"', "'")
      return included if contains_singles.empty?

      contains_singles.map!(&:dump)
      included[-1] = ", #{contains_singles.join(', ')}]"
      included
    end

    def clear_filter
      return if @inclusion_filter.empty?

      @inclusion_filter.each { |item| item.metadata[:include] = nil }
      @inclusion_filter = []
      return if @instructions

      @example_display ? display_example : top_level_list
    end

    def top_fail!
      return if @failed.empty?

      @inclusion_filter = []
      filter_include(@failed.first)
      rerun
    end

    def check_inclusion_status(item)
      return unless @last_run_descriptions.include?(item.metadata[:full_description])

      @inclusion_filter << item
      item.metadata[:include] = true
    end
  end
end
