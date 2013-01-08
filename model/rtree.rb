require_relative "boundingbox.rb"
require_relative "node.rb"

Point = Struct.new(:x, :y)

# In the r-tree each leaf represents only one data point
class RTree
  attr_reader :root, :max_elements, :min_elements

  def initialize(bounding_box, max=50, min=2)
    @root = Node.new(bounding_box)
    @max_elements = max
    @min_elements = min # should be <= max_elements/2
    @space = bounding_box # if we need to make new root nodes at some point we should know the space we're dealing with
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
    # TODO if need
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

  def enlargement_needed_to_consume_bounding_box(node, bounding_box)
    # TODO
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
    if left.root?
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
      # don't really know what to do here, i.e., should I redo root? how?
      #@root = Node.new(BoundingBox.new(Point.new(0,0), 9999999, 9999999))
      @root.children << left
      @root.children << right
      left.parent = @root
      right.parent = @root
    end
    minimize_bounding_box(@root)

  end

  def minimize_bounding_boxes(*nodes)
    nodes.each { |node| minimize_bounding_box(node) }
  end

  def minimize_bounding_box(node)
    positive_infinity = 1.0/0
    negative_infinity = -1.0/0
    min_point = Point.new(negative_infinity, negative_infinity)
    max_point = Point.new(positive_infinity, positive_infinity)

    node.children.each do |child|
      # will i break child to parent relationship somewhere? this would be a good place to fix that
      bbox = child.bounding_box
      min_point.x = bbox.point.x if bbox.point.x < min_point.x
      min_point.y = bbox.point.y if bbox.point.y < min_point.y
      max_point.x = bbox.point.x + bbox.width if bbox.point.x + bbox.width > max_point.x
      max_point.y = bbox.point.y + bbox.height if bbox.point.y + bbox.height > max_point.y
    end

    node.bounding_box.point = min_point
    node.bounding_box.width = max_point.x - min_point.x
    node.bounding_box.height = max_point.y - min_point.y
  end

  # quadratic split
  def split_node(node)
    unassigned = node.children
    first_group = node
    second_group = Node.new(node.bounding_box)
    second_group.parent = node.parent
    second_group.parent.children << second_grop unless second_group.root?
    first_group.clear # references node


    one_seed, other_seed = pick_seeds(unassigned)
    first_group.children << one_seed
    second_group.children << other_seed
    minimize_bounding_boxes(first_group, second_group)
    until entry_group.empty?
      # additional escape here if one group has so few entries that all the rest must be added to it

      next_pick = pick_next(unassigned)
      enlargement_of_first = enlargement_needed_to_consume_bounding_box(first_group, next_pick.bounding_box)
      enlargement_of_second = enlargement_needed_to_consume_bounding_box(second_group, next_pick.bounding_box)
      if  enlargement_of_first < enlargement_of_second
        chosen = first_group
      elsif enlargement_of_first > enlargement_of_second
        chosen = first_group
      else
        chosen = choose_by_secondary_criteria(first_group, second_group)
      end
      chosen.children << next_pick
      minimize_bounding_box(chosen)
    end

    return first_group, second_group
  end

  def choose_by_secondary_criteria(first_node, second_node)
    first_area = first_node.bounding_box.width * first_node.bounding_box.height
    second_area = second_node.bounding_box.width * second_node.bounding_box.height
    if first_area < second_area
      first_node
    elsif second_area < first_area
      second_ndoe
    else
      if first_node.children.count < second_node.children.count
        first_node
      elsif second_node.children.count < first_node.children.count
        second_node
      else
        Random.rand > 0.5 ? first_node : second_node # Choose by random
      end
    end
  end

  # quadratic split seedpicker
  def pick_seeds(nodes)
    # TODO
  end

  def distribute_points_to_children(points, node)
    points.each do |point|
      child = node.child_covering point
      child.points << point
    end
  end
end