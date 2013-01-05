require_relative "../../model/quadtree.rb"

describe BoundingBox do
  subject { BoundingBox.new(Point.new(0, 0), 10, 10) }
  let(:point_in) { Point.new(1, 1) }
  let(:point_out) { Point.new(11, 10) }
  let(:intersecting_box) { BoundingBox.new(Point.new(0, 0), 5, 5) }
  let(:unintersecting_box) { BoundingBox.new(Point.new(12, 12), 2, 2) }

  it { should be_covers point_in }
  it { should_not be_covers point_out }
  it { should be_intersects intersecting_box }
  it { should_not be_intersects unintersecting_box }
end