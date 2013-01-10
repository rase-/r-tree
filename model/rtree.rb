require_relative "boundingbox.rb"
require_relative "node.rb"

NodePair = Struct.new(:first, :second)

# In the r-tree each leaf represents only one data point
class RTree
  attr_reader :root, :max_elements, :min_elements

  def initialize(bounding_box, max=50, min=2)
    @root = Node.new(bounding_box)
    @max_elements = max
    @min_elements = min # should be <= max_elements/2
    @space = bounding_box.deepcopy
  end

  def insert(point)
    leaf = choose_leaf(@root, point)
    leaf.points << point
    if leaf.points.count > @max_elements
      left, right = split_node(leaf)
      adjust_tree(left, right)
    else
      adjust_tree(leaf, nil)
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
    width_increase = [(bbox.point.x - point.x), (point.x - (bbox.point.x + bbox.width))].min
    height_increase = [(bbox.point.y - point.y), (point.y - (bbox.point.y + bbox.height))].min
    increased_area = (bbox.width + width_increase) * (bbox.height + height_increase)
    increased_area - bbox.area
  end

  # Is this sufficient?
  def enlargement_needed_to_consume_bounding_box(node, bounding_box)
    width_increase = (node.bounding_box.point.x - bounding_box.point.x + bounding_box.width).abs
    height_increase = (node.bounding_box.point.y - bounding_box.point.y + bounding_box.height).abs
    width_increase + height_increase
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
      minimize_bounding_box(right) unless right.root? # we don't want to minimize root's bounding box
      if left.parent.children.count > @max_elements
        new_left, new_right = split_node(left.parent)
        adjust_tree(new_left, new_right)
      end

      adjust_tree(left.parent, nil) unless left.parent.nil?
    end
  end

  def finish_adjusting(left, right)
    unless right.nil?
      # don't really know what to do here, i.e., should I redo root? how? probably not any different than this if I keep space fixed
      @root = Node.new(@space.deepcopy)
      @root.children << left
      @root.children << right
      left.parent = @root
      right.parent = @root
    end
    # I guess minimization of root isn't needed with fixed space since it isn't increased either, so deleted it from here
  end

  def minimize_bounding_boxes(*nodes)
    nodes.each { |node| minimize_bounding_box(node) }
  end

  def minimize_bounding_box(node)
    if node.leaf?
      minimize_bounding_box_of_leaf(node)
    else
      minimize_bounding_box_of_inner_node(node)
    end
  end

  def minimize_bounding_box_of_leaf(node)
    positive_infinity = 1.0/0
    negative_infinity = -1.0/0
    min_point = Point.new(positive_infinity, positive_infinity)
    max_point = Point.new(negative_infinity, negative_infinity)

    node.points.each do |point|
      min_point.x = point.x if point.x < min_point.x
      min_point.y = point.y if point.y < min_point.y
      max_point.x = point.x if point.x > max_point.x
      max_point.y = point.y if point.y > max_point.y
    end

    node.bounding_box.point = min_point
    node.bounding_box.width = max_point.x - min_point.x
    node.bounding_box.height = max_point.y - min_point.y
  end

  def minimize_bounding_box_of_inner_node(node)
    positive_infinity = 1.0/0
    negative_infinity = -1.0/0
    min_point = Point.new(positive_infinity, positive_infinity)
    max_point = Point.new(negative_infinity, negative_infinity)
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

  def split_node(node)
    if node.leaf?
      split_leaf(node)
    else
      split_inner_node(node)
    end
  end

  def split_leaf(node)
    unassigned = node.points
    first_group = node
    second_group = Node.new(node.bounding_box)
    second_group.parent = node.parent
    second_group.parent.children << second_group unless second_group.root?
    first_group.clear # references node


    one_seed, other_seed = pick_seeds_from_points(unassigned)
    first_group.points << one_seed
    second_group.points << other_seed
    minimize_bounding_boxes(first_group, second_group)
    until unassigned.empty?
      if unfinished_node = splitting_terminable?(first_group, second_group, unassigned)
        unassigned.each do |point|
          first_group.points << point if unfinished_node == :first
          second_group.points << point if unfinished_node == :second
        end
        minimize_bounding_boxes(first_group, second_group)
        return first_group, second_group
      end

      next_pick = pick_next_point(unassigned, first_group, second_group)
      chosen = choose_by_primary_criteria(first_group, second_group, next_pick)
      chosen.points << next_pick
      minimize_bounding_box(chosen)
    end

    return first_group, second_group
  end

  # quadratic split
  # maybe refactor with some matcher DSL
  def split_inner_node(node)
    puts node.inspect
    unassigned = node.children 
    first_group = node
    second_group = Node.new(node.bounding_box)
    second_group.parent = node.parent
    second_group.parent.children << second_grop unless second_group.root?
    first_group.clear # references node


    one_seed, other_seed = pick_seeds_from_nodes(unassigned)
    first_group.children << one_seed
    second_group.children << other_seed
    minimize_bounding_boxes(first_group, second_group)
    until unassigned.empty?
      if unfinished_node = splitting_terminable?(first_group, second_group, unassigned)
        unassigned.each do |node|
          first_group.children << node if unfinished_node == :first
          second_group.children << node if unfinished_node == :second
        end
        minimize_bounding_boxes(first_group, second_group)
        return first_group, second_group
      end

      next_pick = pick_next_child(unassigned, first_group, second_group)
      chosen = choose_by_primary_criteria(first_group, second_group, next_pick)
      chosen.children << next_pick
      minimize_bounding_box(chosen)
    end

    return first_group, second_group
  end

  def splitting_terminable?(first_group, second_group, unassigned)
    if first_group.children.count >= @max_elements and second_group.children.count + unassigned.count == @min_elements
      :first
    elsif second_group.children.count >= @max_elements and first_group.children.count + unassigned.count == @min_elements
      :second
    else
      false
    end
  end

  # maybe refactor with some matcher DSL
  def choose_by_primary_criteria(first_node, second_node, next_pick)
    if next_pick.is_a? Node
      enlargement_of_first = enlargement_needed_to_consume_bounding_box(first_node, next_pick.bounding_box)
      enlargement_of_second = enlargement_needed_to_consume_bounding_box(second_node, next_pick.bounding_box)
    else
      enlargement_of_first = enlargement_needed(first_node, next_pick)
      enlargement_of_second = enlargement_needed(second_node, next_pick)
    end

    if  enlargement_of_first < enlargement_of_second
      first_node
    elsif enlargement_of_first > enlargement_of_second
      second_node
    else
      choose_by_secondary_criteria(first_node, second_node)
    end
  end

  # maybe refactor with some matcher DSL
  def choose_by_secondary_criteria(first_node, second_node)
    first_area = first_node.bounding_box.area
    second_area = second_node.bounding_box.area
    if first_area < second_area
      first_node
    elsif second_area < first_area
      second_node
    else
      choose_by_ternary_criteria(first_node, second_node)
    end
  end

  def choose_by_ternary_criteria(first_node, second_node)
    if first_node.children.count < second_node.children.count or first_node.points.count < second_node.points.count
        first_node
      elsif second_node.children.count < first_node.children.count or second_node.points.count < first_node.points.count
        second_node
      else
        Random.rand > 0.5 ? first_node : second_node # Choose by random
      end
  end

  def create_node_pairs(nodes)
    nodes.collect do |first|
      nodes.collect do |second|
        NodePair.new(first, second) unless first == second
      end
    end.flatten.compact
  end

  def pick_seeds_from_points(points)
    nodes = points.collect do |point|
      Node.new(BoundingBox.new(point, 0, 0))
    end
    first, second = pick_seeds_from_nodes(nodes)
    points.delete first.bounding_box.point
    points.delete second.bounding_box.point
    return first.bounding_box.point, second.bounding_box.point
  end

  # quadratic split seedpicker
  def pick_seeds_from_nodes(nodes)
    node_pairs = create_node_pairs(nodes)
    # Select the pair that has the most unused area
    most_wasteful_pair = node_pairs.max_by do |pair|
      create_superbox(pair.first.bounding_box, pair.second.bounding_box).area - pair.first.bounding_box.area - pair.second.bounding_box.area
    end
    # Delete the nodes from the unassigned list
    nodes.delete most_wasteful_pair.first
    nodes.delete most_wasteful_pair.second
    return most_wasteful_pair.first, most_wasteful_pair.second
  end

  # maybe replace this with area of combined box, no need to actually combine boxes
  # Creates a box that covers the given two boxes as tightly as possible
  def create_superbox(first_box, second_box)
    bounding_node = Node.new(@space.deepcopy)
    bounding_node.children << Node.new(first_box)
    bounding_node.children << Node.new(second_box)
    minimize_bounding_box(bounding_node)
    bounding_node.bounding_box 
  end

  # quadratic split pick next
  def pick_next_child(nodes, first_group, second_group)
    chosen = nodes.max_by do |node|
      (enlargement_needed_to_consume_bounding_box(first_group, node) - enlargement_needed_to_consume_bounding_box(second_group, node)).abs
    end
    nodes.delete chosen
    return chosen
  end

  def pick_next_point(points, first_group, second_group)
    chosen = points.max_by do |point|
      (enlargement_needed(first_group, point) - enlargement_needed(second_group, point)).abs
    end
    points.delete chosen
    return chosen
  end
end