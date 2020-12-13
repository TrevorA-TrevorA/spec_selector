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
      if File.exist?("#{current_path}/inclusion_filter/locations.json")
        locations = File.open("#{current_path}/inclusion_filter/locations.json")
        @last_run_locations = JSON.load(locations)
        @filter_mode = :location
      else
        @last_run_locations = []
      end
    end

    def get_descriptions
      if File.exist?("#{current_path}/inclusion_filter/descriptions.json")
        included = File.open("#{current_path}/inclusion_filter/descriptions.json")
        @last_run_descriptions = JSON.load(included)
      else
        @last_run_descriptions = []
      end
    end

    def initialize_all
      @messages = []
      init_example_store
      init_summaries
      init_counters
      init_pass_inclusion
      init_map
      init_selector
      @inclusion_filter = []
      @instructions = false
      @filter_mode = :description
      get_descriptions
      get_locations
    end
  end
end
