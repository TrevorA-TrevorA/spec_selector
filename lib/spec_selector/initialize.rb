# frozen_string_literal: true

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
    @all_passing = false
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

  def initialize_all
    @messages = []
    hide_cursor
    init_example_store
    init_summaries
    init_counters
    init_pass_inclusion
    init_map
    init_selector
    @instructions = false
  end
end
