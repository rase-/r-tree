require_relative "boundingbox.rb"
require_relative "node.rb"

Point = Struct.new(:x, :y)

class RTree
  attr_reader :root, :max_elements, :min_elements

  def initialize(bounding_box, max=50, min=2)
    @root = Node.new(bounding_box)
    @max_elements = max
    @min_elements = min
  end

  def insert(point)
    node = Node.new(BoundingBox.new(point, 0, 0))
    node.add_point point
    leaf = choose_leaf(@root, point)
    leaf.children << node
    node.parent = leaf
    if leaf.children.count > @max_elements
      left, right = split_node(leaf)
      adjust_tree(left, right)
    else
      adjust_tree(left, nil)
    end
  end

  # Deletion done for a given area
  def delete(bounding_box)
    # TODO
  end

  # Query targets a specified area
  def search(bounding_box)
    points_covered(@root, bounding_box, [])
  end

  private
  def choose_leaf(node, point)
    return node if node.leaf?
    child_with_min_enlargement = node.children[0]
    min_enlargement = enlargement_needed(child_with_min_enlargement, point)
    node.children.each do |child|
      enlargement_needed = enlargement_needed(child, point)
      if enlargement_needed < min_enlargement
        min_enlargement = enlargement_needed
        child_with_min_enlargement = child
      end
    end
    return choose_leaf(child_with_min_enlargement, point)
  end

  def enlargement_needed(node, point)
    return 0 if node.bounding_box.covers? point
    bbox = node.bounding_box
    width_increase = [bbox.point.x - point.x, point.x - (bbox.point.x + bbox.width)].min
    height_increase = [bbox.point.y - point.y, point.y - (bbox.point.y + bbox.height)].min
    area = bbox.width * bbox.height
    increased_area = (bbox.width + width_increase) * (bbox.height + height_increase)
    increased_area - area
  end

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

  def adjust_tree(left, right)
    if left == @root # could change to if left.parent.nil?
      finish_adjusting(left, right)
      return
    end

    minimize_bounding_box(left)
    unless right.nil?
      minimize_bounding_box(right)
      if left.parent.children.count > @max_elements
        new_left, new_right = split_node(left.parent)
        adjust_tree(new_left, new_right)
      end

      adjust_tree(left.parent, nil) unless left.parent.nil?
    end
  end

  def finish_adjusting(left, right)
    unless right.nil?
      # don't really know what to do here
      @root = Node.new(BoundingBox.new(Point.new(0,0), 9999999, 9999999))
      @root.children << left
      @root.children << right
      left.parent = @root
      right.parent = @root
    end
    minimize_bounding_box(@root)

  end

  def minimize_bounding_box(node)
    # TODO
  end

  # linear split
  def split_node(node)
    
  end

  def distribute_points_to_children(points, node)
    points.each do |point|
      child = node.child_covering point
      child.points << point
    end
  end
end