require_relative "../../model/rtree.rb"

describe RTree do
  let(:bounding_box) { BoundingBox.new(Point.new(0,0), 100, 100) }
  subject { RTree.new(bounding_box) }

  
end