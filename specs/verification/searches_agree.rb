require_relative "../../model/rtree.rb"
require_relative "../../model/quadtree.rb"
require_relative "../../model/point.rb"
require_relative "../../services/analyzer.rb"

generated_data_filename = "data/10000_generated_examples.csv"
real_data_filename = "data/converted_data.csv"

describe "Search" do

  context "for generated data" do
    let(:rtree) { RTree.new(BoundingBox.new(Point.new(0,0), 100000, 100000)) }
    let(:quadtree) { QuadTree.new(BoundingBox.new(Point.new(0,0), 100000, 100000)) }
    before do
      quadtree_analyzer = Analyzer.new quadtree, generated_data_filename, ""
      rtree_analyzer = Analyzer.new rtree, generated_data_filename, ""
      quadtree_analyzer.run_insertions
      rtree_analyzer.run_insertions
    end

    it "should give same amount of results with quadtree and rtree for box: 0 0 1000 1000" do
      search_box = BoundingBox.new(Point.new(0,0), 50000, 50000)
      quadtree_results = quadtree.search search_box
      rtree_results = rtree.search search_box
      puts "RESULTS: #{quadtree_results.count}" # start debug
      puts "RESULTS: #{rtree_results.count}"
      not_included = []
      quadtree_results.each do |point|
        not_included << point unless rtree_results.include? point
      end
      puts "NOT INCLUDED: " + not_included.count.to_s
      puts not_included.inspect
      puts "UNIQUE IN RTREE_RESULTS: #{rtree_results.uniq.count}"
      puts "UNIQUE IN QUADTREE_RESULTS: #{quadtree_results.uniq.count}" # end debug
      quadtree_results.count.should == rtree_results.count
    end

    it "should give same amount of results with quadtree and rtree for box: 100 100 100 100" do
      search_box = BoundingBox.new(Point.new(50000,50000), 100000, 100000)
      quadtree_results = quadtree.search search_box
      rtree_results = rtree.search search_box
      quadtree_results.count.should == rtree_results.count
    end
  end
  
  context "for real data" do
    let(:rtree) { RTree.new(BoundingBox.new(Point.new(0,0), 99999999999, 99999999999)) }
    let(:quadtree) { QuadTree.new(BoundingBox.new(Point.new(0,0), 99999999999, 99999999999)) }
    before do
      quadtree_analyzer = Analyzer.new quadtree, real_data_filename, ""
      rtree_analyzer = Analyzer.new rtree, real_data_filename, ""
      quadtree_analyzer.run_insertions
      rtree_analyzer.run_insertions
    end

    it "should give same amount of results with quadtree and rtree for box: 0 0 1000 1000" do
      search_box = BoundingBox.new(Point.new(280000,2700000), 30000, 300000)
      quadtree_results = quadtree.search search_box
      rtree_results = rtree.search search_box
      puts "RESULTS: #{quadtree_results.count}" # start debug
      puts "RESULTS: #{rtree_results.count}"
      not_included = []
      quadtree_results.each do |point|
        not_included << point unless rtree_results.include? point
      end
      puts "NOT INCLUDED: " + not_included.count.to_s
      puts not_included.inspect
      puts "UNIQUE IN RTREE_RESULTS: #{rtree_results.uniq.count}"
      puts "UNIQUE IN QUADTREE_RESULTS: #{quadtree_results.uniq.count}" # end debug
      quadtree_results.count.should == rtree_results.count
    end
  end
end