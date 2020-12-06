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

    def get_descriptions
      path = File.dirname(__FILE__)

      if File.exist?("#{path}/inclusion_filter/inclusion.json")
        included = File.open("#{path}/inclusion_filter/inclusion.json")
        @last_run_filtered_descriptions = JSON.load(included)
      else
        @last_run_filtered_descriptions = []
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
      get_descriptions
      @inclusion_filter = []
      @instructions = false
      @removed = []
    end
  end
end
