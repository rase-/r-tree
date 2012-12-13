class RTree
  attr_accessor :root

  def initialize()
    @root = nil
  end

  def search(rectangle)
    find_overlapping_records(node, rectangle, [])
  end

  def insert(record)
    # Find positon for new record
    leaf = choose_leaf(record)
    leaf.install(record)
    # Split if necessary
    if leaf.full?
      leaf, lleaf = split_node(leaf)
    end
    # Propagate changes upwards
    adjust_tree(leaf, lleaf)
    # We create a new root and place leaf and lleaf as children if root was split
  end

  def delete(record)
    leaf = find_leaf(record)
    return nil if leaf.nil?
    leaf.remove(record)
    condense_tree(leaf)
    self.root = leaf if self.root.children.one?
  end

  private
  def find_leaf(node, record)
    if node.leaf?
      return node if node.records.include? record
      return nil
    end

    node.children.each do |child|
      # we recursively search each overlapping child node
      find_leaf(child, record)
    end
  end

  def condense_tree(leaf)
    node = leaf
    eliminated_nodes = []
    until node.root?
      # TODO
    end
  end

  def find_all_overlapping_records(node, rectangle, all)
    if node.leaf?
      overlapping = find_overlapping_records(node.children, rectangle)
      all.concat overlapping
    else
      overlapping = find_overlapping_records(node.children, rectangle)
      overlapping.each do |child|
        all.concat overlapping
        find_all_overlapping_records(child, rectangle, all)
      end
    end
  end

  def find_overlapping_records(children, rectangle)
    overlapping = []
    node.children.each do |child|
      overlapping << child if child.overlap? rectangle
    end
  end

  def choose_leaf(record)
    node = self.root
    until node.leaf? do
      node = node.children.min do |a,b|
        order = a.enlargement_need(record) <=> b.enlargement_need(record)
        a.rectangle.area <=> b.rectangle.area if order == 0
      end
    end
  end

  def adjust_tree(leaf, lleaf)
    node = lleaf.nil? ? leaf : lleaf
    unless node.root?
      # tightly enclose all rectangles of node in its parent
      node.parent.enclose(node)
      # here we should do the weird splitting check
      # here we should reselect node
    end
  end
end
