require_relative "../../model/point.rb"
require_relative "../../model/boundingbox.rb"

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
  it "should cover point (66133,59375) with box: 65625 56250 3125 3125" do
    BoundingBox.new(Point.new(65625, 56250), 3125, 3125).covers?(Point.new(66133, 59375)).should be_true
  end
end