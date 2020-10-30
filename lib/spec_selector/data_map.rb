# frozen_string_literal: true

module DataMap
  def map(group)
    map_group(group)
    map_examples(group) unless group.examples.empty?
  end

  def top_level(group)
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
      top_level(group)
    else
      parent = group.metadata[:parent_example_group]
      @map[parent] ||= []
      @map[parent] << group
    end
  end

  def map_examples(group)
    @map[group.metadata] ||= []
    @map[group.metadata] += group.examples
  end
end
