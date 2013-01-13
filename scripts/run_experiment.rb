require_relative "../model/quadtree.rb"
require_relative "../model/rtree.rb"
require_relative "../model/point.rb"
require_relative "../services/analyzer.rb"

spaces = { 
  wildcard: BoundingBox.new(Point.new(0, 0), 99999999999, 9999999999),
  real: BoundingBox.new(Point.new(246960, 2712194), 68865, 73104),
  generated: BoundingBox.new(Point.new(0,0), 100000, 100000)
}

tree_parameters = {
  q_max_elem: 50,
  q_max_depth: nil,
  r_max: 50,
  r_min: 15
}

# Initialize  
datafilename = ARGV[0]
queryfilename = ARGV[1]
space_selected = ARGV[2].to_sym
# Parse additional options to either trees parameters
# Arguments provided with -- switch, which is dropped
options = ARGV.drop 3 # All but first three arguments
(0..(options.count - 1)).step(2) do |i|
  tree_parameters[options[i][2..-1].to_sym] = options[i+1].to_i
end

# The code to decide space and initialize trees
space = spaces[space_selected]
quadtree = QuadTree.new space, tree_parameters[:q_max_elem], tree_parameters[:q_max_depth]
rtree = RTree.new space, tree_parameters[:r_max], tree_parameters[:r_min]

# The code to initialize analyzer with appropriate data
quadtree_analyzer = Analyzer.new quadtree, datafilename, queryfilename
rtree_analyzer = Analyzer.new rtree, datafilename, queryfilename

# Analyze QuadTree
#puts quadtree_analyzer.run_and_analyze_insertions
puts quadtree_analyzer.bulk_insert_and_analyze
puts quadtree_analyzer.run_and_analyze_queries

# Analyze R-tree
#puts rtree_analyzer.run_and_analyze_insertions
puts rtree_analyzer.bulk_insert_and_analyze
puts rtree_analyzer.run_and_analyze_queries