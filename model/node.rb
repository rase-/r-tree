class Node
  # should change these values
  @@max_load = 10
  @@min_load = 2

  def initialize()
    @children = []
    # There should be a bounding box for leaf nodes, several for inner nodes
    @bounding_box = nil
  end

  def leaf?
    @children.empty?
  end

  def room?
    @children.length < @@max_load
  end

  def install(record)

  end
end
