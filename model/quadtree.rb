require_relative "boundingbox.rb"
require_relative "node.rb"

Point = Struct.new(:x, :y)

class Node
  attr_reader :children, :bounding_box, :points

  def initialize(bounding_box)
    @bounding_box = bounding_box
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
end

class QuadTree
  attr_reader :root, :max_elements

  def initialize(bounding_box, max=5)
    @root = Node.new(bounding_box)
    @max_elements = max
  end

  def insert(point)
    node = @root
    until node.leaf?
      node = node.child_covering point
    end
    node.add_point point
    split_node(node) if node.points.length > @max_elements
  end

  # Query targets a specified area
  def search(bounding_box)
    points_covered(@root, bounding_box, [])
  end

  private
  def points_covered(node, bounding_box, points)
    if node.leaf?
      node.points.each do |point|
        points << point if bounding_box.covers? point
      end
    end

    node.children.each do |child|
      points_covered(child, bounding_box, points) if child.bounding_box.intersects?(bounding_box)
    end
    points
  end

  # needs refactoring
  def split_node(node)
    points = node.points
    child_width = node.bounding_box.width / 2
    child_height = node.bounding_box.height / 2
    p = node.bounding_box.point
    node.clear
    node.children << Node.new(BoundingBox.new(node.bounding_box.point, child_width, child_height))
    node.children << Node.new(BoundingBox.new(Point.new(p.x + child_width, p.y), child_width, child_height))
    node.children << Node.new(BoundingBox.new(Point.new(p.x, p.y + child_height), child_width, child_height))
    node.children << Node.new(BoundingBox.new(Point.new(p.x + child_width, p.y + child_height), child_width, child_height))

    distribute_points_to_children points, node
  end

  def distribute_points_to_children(points, node)
    points.each do |point|
      child = node.child_covering point
      child.points << point
    end
  end
end