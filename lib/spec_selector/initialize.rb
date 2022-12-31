# frozen_string_literal: true

module SpecSelectorUtil
  # The Initialize module contains methods that initialize specific sets of
  # instance variables for the SpecSelector instance.
  module Initialize
    STREAMS = %w[stderr stdout].freeze

    STREAMS.each do |stream|
      define_method("init_#{stream}_log") do
        log = Tempfile.new(["#{stream}_log", '.txt'])
        log.write("#{stream.upcase} LOG #{Time.now}:\n\n")
        log
      end
    end

    def init_example_store
      @failed = []
      @passed = []
      @pending = []
    end

    def init_summaries
      @failure_summaries = {}
      @pending_summaries = {}
    end

    def init_counters
      @pass_count = 0
      @fail_count = 0
      @pending_count = 0
    end

    def init_pass_inclusion
      @exclude_passing = false
    end

    def init_map
      @groups = {}
      @map = {}
      @active_map = @map
      @list = nil
    end

    def init_selector
      @selected = nil
      @selector_index = 0
    end

    def locations
      if File.exist?(@locations_file)
        stored_locations = File.open(@locations_file)
        @last_run_locations = JSON.parse(stored_locations.read)
        @filter_mode = :location
      else
        @last_run_locations = []
      end
    end

    def descriptions
      if File.exist?(@descriptions_file)
        included = File.open(@descriptions_file)
        @last_run_descriptions = JSON.parse(included.read)
      else
        @last_run_descriptions = []
      end
    end

    def init_filter
      inclusion_filter_path = "#{current_path}/inclusion_filter"
      Dir.mkdir(inclusion_filter_path) unless Dir.exist?(inclusion_filter_path)
      @descriptions_file = "#{current_path}/inclusion_filter/descriptions.json"
      @locations_file = "#{current_path}/inclusion_filter/locations.json"
      @inclusion_filter = []
      @filter_mode = :description
      descriptions
      locations
    end

    def stderr_log
      @stderr_log ||= init_stderr_log
    end

    def stdout_log
      @stdout_log ||= init_stdout_log
    end

    def initialize_all
      @messages = []
      @notices = []
      init_example_store
      init_summaries
      init_counters
      init_pass_inclusion
      init_map
      init_selector
      init_filter
      @instructions = false
    end
  end
end
