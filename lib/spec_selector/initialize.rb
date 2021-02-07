# frozen_string_literal: true

module SpecSelectorUtil
  # The Initialize module contains methods that initialize specific sets of
  # instance variables for the SpecSelector instance.
  module Initialize
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

    def get_locations
      if File.exist?(@locations_file)
        locations = File.open(@locations_file)
        @last_run_locations = JSON.load(locations)
        @filter_mode = :location
      else
        @last_run_locations = []
      end
    end

    def get_descriptions
      if File.exist?(@descriptions_file)
        included = File.open(@descriptions_file)
        @last_run_descriptions = JSON.load(included)
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
      get_descriptions
      get_locations
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
