class Node
  attr_accessor :parent, :depth
  attr_reader :children, :bounding_box, :points

  def initialize(bounding_box, parent=nil, depth=nil)
    @bounding_box = bounding_box
    @parent = parent
    @children = []
    @points = []
    # Only used by quadtree
    @depth = depth
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

  def clear(which=nil)
    @points = [] if which.nil? or which == :points
    @children = [] if which.nil? or which == :children
  end

  def ==(node)
    @bounding_box == node.bounding_box and @points == node.points and @children == node.children
  end

  def root?
    self.parent.nil?
  end
end

