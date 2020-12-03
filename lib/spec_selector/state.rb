module SpecSelectorUtil
   module State
    def rerun
      clear_frame
      persist_inclusion_filter
      italicize('running examples...')
      working_dir = Dir.pwd
      process_id = Process.pid
      args = ARGV - @filtered_descriptions - ['-E'] - @removed
      args = args.join(" ")
      included = prepare_description_arguments
      rerun = File.dirname(__FILE__) + '/scripts/rerun.sh'
      Signal.trap('TERM') { clear_frame; exit }
      system("#{rerun} #{process_id} #{working_dir} #{$0} #{args} #{included}")
    end

    def filter_include
      @selected.metadata[:include] = true
      @inclusion_filter << @selected
      @example_display ? display_example : selector
    end

    def filter_remove
      @inclusion_filter -= [@selected]
      @removed << @selected
      @selected.metadata[:include] = nil
      @example_display ? display_example : selector
    end

    def persist_inclusion_filter
      @inclusion_filter.uniq!
      filter = @inclusion_filter.map(&:description).to_json
      path = File.dirname(__FILE__)
      File.write("#{path}/inclusion_filter/inclusion.json", filter)
    end

    def delete_filter_data
      path = File.dirname(__FILE__)
      filter_file = "#{path}/inclusion_filter/inclusion.json"
      File.delete(filter_file) if File.exist?(filter_file)
    end

    def prepare_description_arguments
      return if @inclusion_filter.empty?

      filter = @inclusion_filter.map(&:description)
      filter.each do |d|
        d.insert(0,"'")
        d.insert(-1,"'")
        d.gsub!('[', '\[')
        d.gsub!(']', '\]')
      end

      filter = '-E ' + filter.join(' -E ')
      filter
    end

    def clear_filter
      return if @inclusion_filter.empty?

      @inclusion_filter.each { |item| item.metadata[:include] = nil }
      @removed = @inclusion_filter
      @inclusion_filter = []
      @example_display ? display_example : top_level_list
    end

    def check_inclusion_status(item)
      if @filtered_descriptions.include?(item.description)
        @inclusion_filter << item
        item.metadata[:include] = true
      end
    end
  end
end