require_relative "node.rb"

class RTreeNode < Node
  def enlargement_needed(point)
    return 0 if self.bounding_box.covers? point
    bbox = self.bounding_box
    # Choice depends on the orientation between the box and the point for both dimensions
    # The other is always at most 0, so max can be used
    width_increase = [(bbox.point.x - point.x), (point.x - (bbox.point.x + bbox.width))].max
    height_increase = [(bbox.point.y - point.y), (point.y - (bbox.point.y + bbox.height))].max
    increased_area = (bbox.width + width_increase) * (bbox.height + height_increase)
    increased_area - bbox.area
  end

  # Replace with a more efficient algorithm relying on arithmetic operations only?
  def enlargement_needed_to_consume_bounding_box(bounding_box, space)
    # width_increase = (node.bounding_box.point.x - bounding_box.point.x + bounding_box.width).abs
    # height_increase = (node.bounding_box.point.y - bounding_box.point.y + bounding_box.height).abs
    # width_increase + height_increase
    bounding_node = RTreeNode.new(space.deepcopy)
    bounding_node.children << RTreeNode.new(@bounding_box)
    bounding_node.children << RTreeNode.new(bounding_box)
    bounding_node.minimize_bounding_box
    bounding_node.bounding_box.area - self.bounding_box.area
  end

  def minimize_bounding_box
    min_point = Point.new(Float::INFINITY, Float::INFINITY)
    max_point = Point.new(-Float::INFINITY, -Float::INFINITY)
    if self.leaf?
      min_point, max_point = find_points_defining_minimum_bounding_box_of_leaf(min_point, max_point)
    else
      min_point, max_point = find_points_defining_minimum_bounding_box_of_inner_node(min_point, max_point)
    end

    @bounding_box.point = min_point
    @bounding_box.width = max_point.x - min_point.x
    @bounding_box.height = max_point.y - min_point.y
  end

  private
    def find_points_defining_minimum_bounding_box_of_leaf(min_point, max_point)
    @points.each do |point|
      min_point.x = point.x if point.x < min_point.x
      min_point.y = point.y if point.y < min_point.y
      max_point.x = point.x if point.x > max_point.x
      max_point.y = point.y if point.y > max_point.y
    end

    return min_point, max_point
  end

  def find_points_defining_minimum_bounding_box_of_inner_node(min_point, max_point)
    @children.each do |child|
      child.parent = self # Making sure a child know's its parent
      bbox = child.bounding_box
      min_point.x = bbox.point.x if bbox.point.x < min_point.x
      min_point.y = bbox.point.y if bbox.point.y < min_point.y
      max_point.x = bbox.point.x + bbox.width if bbox.point.x + bbox.width > max_point.x
      max_point.y = bbox.point.y + bbox.height if bbox.point.y + bbox.height > max_point.y
    end

    return min_point, max_point
  end
end