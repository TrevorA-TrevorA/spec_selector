module SpecSelectorUtil
   module State
    def rerun
      prepare_rerun
      pid, working_dir = [Process.pid, Dir.pwd]
      descriptions, marker = appended_arguments
      rerun = current_path + '/scripts/rerun.sh'
      Signal.trap('TERM') { clear_frame; exit }
      system("#{rerun} #{pid} #{working_dir} #{$0} #{@rerun_arguments} #{descriptions} #{marker}")
    end

    def filter_include(item = @selected)
      @filter_mode = :location if one_liner?(item)
      item.metadata[:include] = true
      @inclusion_filter << item
    end

    def prepare_rerun
      persist_filter
      reset_arguments
      prepare_location_arguments if @filter_mode == :location
      delete_filter_data if @inclusion_filter.empty?
    end

    def rerun_display
      close_alt_buffer if @instructions
      clear_frame
      italicize('running examples...')
    end

    def appended_arguments
      if @filter_mode == :description
        return [prepare_description_arguments, @filtered_descriptions.count]
      else
        [nil, 0]
      end
    end

    def persist_filter
      persist_descriptions
      persist_locations if @filter_mode == :location
    end

    def run_only_fails
      return if @failed.empty?
      
      @inclusion_filter = []
      
      @failed.each do |example|
        @filter_mode = :location if one_liner?(example)
        example.metadata[:include] = true
        @inclusion_filter << example
      end

      rerun
    end

    def rerun_all
      return if @last_run_descriptions.empty?

      @inclusion_filter = []
      rerun
    end

    def filter_remove
      @inclusion_filter -= [@selected]
      @selected.metadata[:include] = nil
    end

    def persist_descriptions
      @filtered_descriptions = @inclusion_filter.map do |item|
        item.metadata[:full_description]
      end
      
      filter = @filtered_descriptions.to_json
      File.write("#{current_path}/inclusion_filter/descriptions.json", filter)
    end

    def delete_filter_data
      descriptions = "#{current_path}/inclusion_filter/descriptions.json"
      locations = "#{current_path}/inclusion_filter/locations.json"
      File.delete(descriptions) if File.exist?(descriptions)
      File.delete(locations) if File.exist?(locations)
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
      old_descriptions = @last_run_descriptions.map { |d| "-e #{d}" }
      @rerun_arguments = ARGV.join(" ")
      old_descriptions.each { |d| @rerun_arguments.slice!(d) }
    end

    def persist_locations
      @filtered_locations = @inclusion_filter.map { |item| item.location }
      locations = @filtered_locations.to_json
      File.write("#{current_path}/inclusion_filter/locations.json", locations)
    end

    def prepare_location_arguments
      @rerun_arguments += " #{@filtered_locations.join(" ")}"
    end

    def prepare_description_arguments
      return if @inclusion_filter.empty?

      included = @filtered_descriptions
      contains_singles = included.select { |desc| desc.include?("'") }
      included -= contains_singles

      return contains_singles.to_s if included.empty?
        
      included = "#{included}".gsub("\"", "'")
      return included if contains_singles.empty?
      
      contains_singles.map! do |desc|
        desc.insert(0, "\"")
        desc.insert(-1, "\"")
      end
        
      included[-1] = ", #{contains_singles.join(", ")}]"
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
      @inclusion_filter = []
      filter_include(@failed.first)
      rerun
    end

    def check_inclusion_status(item)
      if @last_run_descriptions.include?(item.metadata[:full_description])
        @inclusion_filter << item
        item.metadata[:include] = true
      end
    end
  end
end