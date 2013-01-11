require_relative "../model/quadtree.rb"
require_relative "../model/rtree.rb"
require_relative "../model/point.rb"
require_relative "../services/analyzer.rb"

# Initialize  
datafilename = ARGV[0]
queryfilename = ARGV[1]

# The code to decide space and initialize trees
# space of real converted data: 246960 2712194 68865 73104
space = BoundingBox.new(Point.new(0, 0), 99999999999, 9999999999) # wild card
#space = BoundingBox.new(Point.new(246960, 2712194), 68865, 73104)
#space = BoundingBox.new(Point.new(0,0), 100000, 100000) # the space of generated data, need to devise one for the real spatial data
quadtree = QuadTree.new(space, 50, 10)
rtree = RTree.new(space)

# The code to initialize analyzer with appropriate data, maybe change data files to be sent as parameters
quadtree_analyzer = Analyzer.new quadtree, datafilename, queryfilename
rtree_analyzer = Analyzer.new rtree, datafilename, queryfilename

# Analyze QuadTree
#puts quadtree_analyzer.run_and_analyze_insertions
quadtree_analyzer.bulk_insert_and_analyze
puts quadtree_analyzer.run_and_analyze_queries

# Analyze R-tree
#puts rtree_analyzer.run_and_analyze_insertions
rtree_analyzer.bulk_insert_and_analyze
puts rtree_analyzer.run_and_analyze_queries