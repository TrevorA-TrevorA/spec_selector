module SpecSelectorUtil
   module State
    def rerun
      close_alt_buffer if @instructions
      clear_frame
      persist_inclusion_filter
      italicize('running examples...')
      working_dir = Dir.pwd
      pid = Process.pid
      args = reset_arguments
      included = prepare_description_arguments
      marker = @filtered_item_descriptions.count
      rerun = File.dirname(__FILE__) + '/scripts/rerun.sh'
      Signal.trap('TERM') { clear_frame; exit }
      system("#{rerun} #{pid} #{working_dir} #{$0} #{args} #{included} #{marker}")
    end

    def filter_include(example = @selected)
      return if one_liner?(example)
      
      example.metadata[:include] = true
      @inclusion_filter << example
    end

    def run_only_fails
      return if @failed.empty?
      
      @inclusion_filter = []
      
      @failed.each do |example|
        next if one_liner?(example)
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

    def persist_inclusion_filter
      @filtered_item_descriptions = @inclusion_filter.map do |item|
        item.metadata[:full_description]
      end
      
      filter = @filtered_item_descriptions.to_json
      path = File.dirname(__FILE__)
      File.write("#{path}/inclusion_filter/inclusion.json", filter)
    end

    def delete_filter_data
      path = File.dirname(__FILE__)
      filter_file = "#{path}/inclusion_filter/inclusion.json"
      File.delete(filter_file) if File.exist?(filter_file)
    end

    def reset_arguments
      old_descriptions = @last_run_filtered_descriptions.map { |d| "-e #{d}" }
      args = ARGV.join(" ")
      old_descriptions.each { |d| args.slice!(d) }
      args
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