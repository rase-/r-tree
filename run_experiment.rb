require_relative "model/quadtree.rb"
require_relative "services/analyzer.rb"

# Initialize  
datafilename = ARGV[0]
queryfilename = ARGV[1]

# The code to decide space and initialize trees
space = BoundingBox.new(Point.new(0,0),1,1) # replace this with actual space
quadtree = QuadTree.new(space)
rtree = RTree.new(space)

# The code to initialize analyzer with appropriate data, maybe change data files to be sent as parameters
quadtree_analyzer = Analyzer.new quadtree, datafilename, queryfilename
rtree_analyzer = Analyzer.new rtree, datafilename, queryfilename

# Analyze QuadTree
puts quadtree_analyzer.run_and_analyze_insertions
puts quadtree_analyzer.run_and_analyze_queries

# Analyze R-tree
puts rtree_analyzer.run_and_analyze_insertions
puts rtree_analyzer.run_and_analyze_queries

