require_relative "boundingbox.rb"
require_relative "rtree_node.rb"
require_relative "boundingbox_searchable.rb"

NodePair = Struct.new(:first, :second)

# In the r-tree each leaf represents only one data point
class RTree
  include BoundingBoxSearchable
  attr_reader :root, :max_elements, :min_elements

  def initialize(bounding_box, max=50, min=15)
    @root = RTreeNode.new(bounding_box)
    @max_elements = max
    @min_elements = min # should be at most max_elements/2
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

  private
  def choose_leaf(node, point)
    return node if node.leaf?
    child_with_min_enlargement = node.children.min_by { |child| child.enlargement_needed(point) }
    return choose_leaf(child_with_min_enlargement, point)
  end

  def adjust_tree(left, right)
    if left.root?
      finish_adjusting(left, right)
      return
    end

    left.minimize_bounding_box
    unless right.nil?
      right.minimize_bounding_box unless right.root? # we don't want to minimize root's bounding box
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
      @root = RTreeNode.new(@space.deepcopy)
      @root.children << left
      @root.children << right
      left.parent = @root
      right.parent = @root
    end
    # I guess minimization of root isn't needed with fixed space since it isn't increased either, so deleted it from here
  end

  def minimize_bounding_boxes(*nodes)
    nodes.each { |node| node.minimize_bounding_box }
  end

  def split_node(node)
    mode = node.leaf? ? :leaf : :inner
    unassigned = (mode == :leaf) ? node.points : node.children
    first_group, second_group = create_two_new_nodes_from node

    initialize_nodes_with_first_seeds(unassigned, first_group, second_group, mode)
    minimize_bounding_boxes(first_group, second_group)
    assign_rest(unassigned, first_group, second_group, mode)
  end

  def assign_rest(unassigned, first_group, second_group, mode)
    until unassigned.empty?
      if unfinished_node = splitting_terminable?(first_group, second_group, unassigned)
        bulk_add_to unfinished_node, first_group, second_group, unassigned, mode
        minimize_bounding_boxes(first_group, second_group)
        return first_group, second_group
      end

      chosen = select_new_seed_and_its_parent_and_append(unassigned, first_group, second_group, mode)
      chosen.minimize_bounding_box
    end
    return first_group, second_group
  end

  def create_two_new_nodes_from(node)
    first_group = node
    second_group = RTreeNode.new(node.bounding_box.deepcopy)
    second_group.parent = node.parent
    second_group.parent.children << second_group unless second_group.root?
    first_group.clear # references node
    return first_group, second_group
  end

  def initialize_nodes_with_first_seeds(unassigned, first_group, second_group, mode)
    one_seed, other_seed = (mode == :leaf) ? pick_seeds_from_points(unassigned) : pick_seeds_from_nodes(unassigned)
    first_group.points << one_seed if mode == :leaf
    second_group.points << other_seed if mode == :leaf
    first_group.children << one_seed if mode == :inner
    second_group.children << other_seed if mode == :inner
  end

  def select_new_seed_and_its_parent_and_append(unassigned, first_group, second_group, mode)
    next_pick = (mode == :leaf) ? pick_next_point(unassigned, first_group, second_group) : pick_next_child(unassigned, first_group, second_group)
    chosen = choose_by_primary_criteria(first_group, second_group, next_pick)
    chosen.points << next_pick if mode == :leaf
    chosen.children << next_pick if mode == :inner
    return chosen
  end

  def bulk_add_to(unfinished_node, first_group, second_group, unassigned, mode)
    unassigned.each do |element|
      first_group.points << element if unfinished_node == :first and mode == :leaf
      second_group.points << element if unfinished_node == :second and mode == :leaf
      first_group.children << element if unfinished_node == :first and mode == :inner
      second_group.children << element if unfinished_node == :second and mode == :inner
    end
  end

  def splitting_terminable?(first_group, second_group, unassigned)
    if first_group.children.count >= @min_elements and second_group.children.count + unassigned.count == @min_elements
      :second
    elsif second_group.children.count >= @min_elements and first_group.children.count + unassigned.count == @min_elements
      :first
    else
      false
    end
  end

  # maybe refactor with some matcher DSL
  def choose_by_primary_criteria(first_node, second_node, next_pick)
    if next_pick.is_a? Node
      enlargement_of_first = first_node.enlargement_needed_to_consume_bounding_box(next_pick.bounding_box, @space)
      enlargement_of_second = second_node.enlargement_needed_to_consume_bounding_box(next_pick.bounding_box, @space)
    else
      enlargement_of_first = first_node.enlargement_needed(next_pick)
      enlargement_of_second = second_node.enlargement_needed(next_pick)
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
    node_pairs = []
    0.upto nodes.count - 1 do |i|
      (i + 1).upto nodes.count - 1 do |j| # Don't want to pair with itself
        node_pairs << NodePair.new(nodes[i], nodes[j])
      end
    end
    node_pairs
  end

  def pick_seeds_from_points(points)
    nodes = points.collect do |point|
      RTreeNode.new(BoundingBox.new(point, 0, 0))
    end
    first, second = pick_seeds_from_nodes(nodes)
    points.delete_at points.index(first.bounding_box.point)
    points.delete_at points.index(second.bounding_box.point)
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
    bounding_node = RTreeNode.new(@space.deepcopy)
    bounding_node.children << RTreeNode.new(first_box)
    bounding_node.children << RTreeNode.new(second_box)
    bounding_node.minimize_bounding_box
    bounding_node.bounding_box 
  end

  # quadratic split pick next
  def pick_next_child(nodes, first_group, second_group)
    chosen = nodes.max_by do |node|
      (first_group.enlargement_needed_to_consume_bounding_box(node.bounding_box, @space) - second_group.enlargement_needed_to_consume_bounding_box(node.bounding_box, @space)).abs
    end
    nodes.delete chosen
    return chosen
  end

  def pick_next_point(points, first_group, second_group)
    chosen = points.max_by do |point|
      (first_group.enlargement_needed(point) - second_group.enlargement_needed(point)).abs
    end
    points.delete_at points.index(chosen)
    return chosen
  end
end