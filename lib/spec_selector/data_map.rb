# frozen_string_literal: true

module SpecSelectorUtil
  # The DataMap module contains methods used to build a hash map of nested
  # lists, which can be rendered in their traversable form through the
  # DataPresentation methods.
  module DataMap
    def map(group)
      map_group(group)
      map_examples(group) unless group.examples.empty?
    end

    def top_level_push(group)
      @map[:top_level] ||= []
      @map[:top_level] << group
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
      end
    end

    def map_examples(group)
      @map[group.metadata[:block]] ||= []
      @map[group.metadata[:block]] += group.examples
    end
  end
end
