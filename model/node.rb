class Node
  attr_accessor :parent
  attr_reader :children, :bounding_box, :points

  def initialize(bounding_box)
    @bounding_box = bounding_box
    @parent = nil
    @children = []
    @points = []
  end

  def leaf?
    @children.empty?
  end

  def child_covering(point)
    @children.each do |child|
      return child if child.bounding_box.covers? point
    end
    false
  end

  def add_point(point)
    @points << point
  end

  def clear
    @points = []
    @children = []
  end

  def ==(node)
    @bounding_box == node.bounding_box
  end
end

