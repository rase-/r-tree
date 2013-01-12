require_relative "boundingbox.rb"
require_relative "node.rb"
require_relative "boundingbox_searchable.rb"

class QuadTree
  include BoundingBoxSearchable
  attr_reader :root, :max_elements

  def initialize(bounding_box, max_elements=50, max_depth=nil)
    @root = Node.new(bounding_box)
    @root.depth = 0
    @max_elements = max_elements
    @max_depth = max_depth
  end

  def insert(point)
    node = @root
    until node.leaf?
      node = node.child_covering point
    end
    node.add_point point
    split_node(node) if node.points.length > @max_elements
  end

private
  # needs refactoring
  def split_node(node)
    return if (not @max_depth.nil?) and node.depth >= @max_depth
    create_new_children_for node
    distribute_points_to_children node.points, node
    node.clear(:points)
  end

  def create_new_children_for(node)
    child_width, child_height = find_dimensions_for_new_children_of node
    p = node.bounding_box.point
    node.children << Node.new(BoundingBox.new(Point.new(p.x, p.y), child_width, child_height), node, node.depth + 1)
    node.children << Node.new(BoundingBox.new(Point.new(p.x + child_width, p.y), child_width, child_height), node, node.depth + 1)
    node.children << Node.new(BoundingBox.new(Point.new(p.x, p.y + child_height), child_width, child_height), node, node.depth + 1)
    node.children << Node.new(BoundingBox.new(Point.new(p.x + child_width, p.y + child_height), child_width, child_height), node, node.depth + 1)
  end

  def find_dimensions_for_new_children_of(node)
    child_width = (node.bounding_box.width / 2.0).ceil
    child_height = (node.bounding_box.height / 2.0).ceil
    return child_width, child_height
  end

  def distribute_points_to_children(points, node)
    points.each do |point|
      child = node.child_covering point
      child.points << point
    end
  end
end