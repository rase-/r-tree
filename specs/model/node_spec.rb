require_relative "../../model/quadtree.rb"

describe Node do 
  let(:point) { Point.new(0, 0) }
  let(:bounding_box) { BoundingBox.new(point, 10, 10) }
  subject { Node.new(bounding_box) }

  it { should be_leaf }
  its(:points) { should be_empty }
end