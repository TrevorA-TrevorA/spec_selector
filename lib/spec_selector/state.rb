module SpecSelectorUtil
   module State
    def rerun
      close_alt_buffer if @instructions
      clear_frame
      persist_description_filter
      persist_location_arguments if @filter_mode == :location
      italicize('running examples...')
      working_dir = Dir.pwd
      pid = Process.pid
      args = reset_arguments
      args = args + " #{prepare_location_arguments}" if @filter_mode == :location
      delete_filter_data if @inclusion_filter.empty?
      included = @filter_mode == :description ? prepare_description_arguments : nil
      marker = @filter_mode == :description ? @filtered_item_descriptions.count : 0
      rerun = current_path + '/scripts/rerun.sh'
      Signal.trap('TERM') { clear_frame; exit }
      system("#{rerun} #{pid} #{working_dir} #{$0} #{args} #{included} #{marker}")
    end

    def filter_include(item = @selected)
      @filter_mode = :location if one_liner?(item)
      item.metadata[:include] = true
      @inclusion_filter << item
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
      return if @last_run_filtered_descriptions.empty?

      @inclusion_filter = []
      rerun
    end

    def filter_remove
      @inclusion_filter -= [@selected]
      @removed << @selected
      @selected.metadata[:include] = nil
    end

    def persist_description_filter
      @filtered_item_descriptions = @inclusion_filter.map do |item|
        item.metadata[:full_description]
      end
      
      filter = @filtered_item_descriptions.to_json
      File.write("#{current_path}/inclusion_filter/descriptions.json", filter)
    end

    def delete_filter_data
      descriptions = "#{current_path}/inclusion_filter/descriptions.json"
      locations = "#{current_path}/inclusion_filter/locations.json"
      File.delete(descriptions) if File.exist?(descriptions)
      File.delete(locations) if File.exist?(locations)
    end

    def reset_arguments
      args = remove_old_descriptions
      remove_old_locations(args)
    end

    def remove_old_locations(args)
      locations_file = "#{current_path}/inclusion_filter/locations.json"
      return unless File.exist?(locations_file)

      old_location_data = File.open(locations_file)
      old_locations = JSON.load(old_location_data)
      old_locations.each { |loc| args.slice!(loc) }
      args
    end

    def remove_old_descriptions
      old_descriptions = @last_run_filtered_descriptions.map { |d| "-e #{d}" }
      args = ARGV.join(" ")
      old_descriptions.each { |d| args.slice!(d) }
      args
    end

    def persist_location_arguments
      @filtered_locations = @inclusion_filter.map { |item| item.location }
      locations = @filtered_locations.to_json
      File.write("#{current_path}/inclusion_filter/locations.json", locations)
    end

    def prepare_location_arguments
      @filtered_locations.join(" ")
    end

    def prepare_description_arguments
      return if @inclusion_filter.empty?

      included = @filtered_item_descriptions
      contains_singles = nil

      included.each do |desc|
        if desc.include?("'")
          desc.insert(0, "\"")
          desc.insert(-1, "\"")
          contains_singles = desc
        end
      end

      included -= [contains_singles]

      if included.empty?
        return contains_singles
      elsif !contains_singles
        return "#{included}".gsub("\"", "'")
      else
        included = "#{included}".gsub("\"", "'")
        included[-1] = ", #{contains_singles}]"
        return included
      end
    end

    def clear_filter
      return if @inclusion_filter.empty?

      @inclusion_filter.each { |item| item.metadata[:include] = nil }
      @removed = @inclusion_filter
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
      if @last_run_filtered_descriptions.include?(item.metadata[:full_description])
        @inclusion_filter << item
        item.metadata[:include] = true
      end
    end
  end
end