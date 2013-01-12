require_relative "../model/quadtree.rb"
require_relative "../model/rtree.rb"
require_relative "../model/point.rb"
require_relative "../services/analyzer.rb"

spaces = { 
  wildcard: BoundingBox.new(Point.new(0, 0), 99999999999, 9999999999),
  real: BoundingBox.new(Point.new(246960, 2712194), 68865, 73104),
  generated: BoundingBox.new(Point.new(0,0), 100000, 100000)
}

# Initialize  
datafilename = ARGV[0]
queryfilename = ARGV[1]
space_selected = ARGV[2].to_sym

# The code to decide space and initialize trees
space = spaces[space_selected]
quadtree = QuadTree.new space
rtree = RTree.new space

# The code to initialize analyzer with appropriate data, maybe change data files to be sent as parameters
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