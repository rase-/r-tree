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

  private
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
    unless node.leaf? do
      node = node.children.min do |a,b|
        order = a.enlargement_need(record) <=> b.enlargement_need(record)
        a.rectangle.area <=> b.rectangle.area if order == 0
      end
      end
    end
  end

  def adjust_tree(leaf, lleaf)
    node = lleaf.nil? ? leaf : lleaf
    unless node.root?
      # tightly enclose all rectangles of node in its parent
      # ... there's still more, TODO the rest of the method
    end
  end
end
