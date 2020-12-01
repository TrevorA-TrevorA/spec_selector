# frozen_string_literal: true

module SpecSelectorUtil
  # The DataMap module contains methods used to build a hash map of nested
  # lists, which can be rendered in their traversable form through the
  # DataPresentation methods.
  module DataMap
    def top_level_push(group)
      @map[:top_level] ||= []
      @map[:top_level] << group
      @map[group.metadata[:block]] ||= []
    end

    def parent_data(data)
      keys = data.keys
      return data[:example_group] if keys.include?(:example_group)
      return data[:parent_example_group] if keys.include?(:parent_example_group)

      nil
    end

    def map_group(group)
      if !group.metadata[:parent_example_group]
        top_level_push(group)
      else
        parent = group.metadata[:parent_example_group][:block]
        @map[parent] ||= []
        @map[parent] << group
        @map[group.metadata[:block]] ||= []
      end
    end

    def map_example(example)
      group = example.example_group
      @map[group.metadata[:block]] << example
    end
  end
end
