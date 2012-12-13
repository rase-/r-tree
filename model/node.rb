class Node
  attr_reader :children, :rectangle
  # should change these values
  @@max_load = 10
  @@min_load = 2

  def initialize()
    @children = []
    # There should be a bounding box for leaf nodes, several for inner nodes
    @rectangle = nil
  end

  def leaf?
    @children.empty?
  end

  def full?
    @children.length > @@max_load
  end

  def install(record)

  end

  def overlap(record)

  end

  def enlargement_need(record)

  end
end
