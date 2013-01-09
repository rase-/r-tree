require_relative "../../model/rtree.rb"

describe RTree do
  let(:bounding_box) { BoundingBox.new(Point.new(0,0), 100, 100) }
  subject { RTree.new(bounding_box) }

  it "should insert first entry to root" do
    expect { subject.insert(Point.new(1, 1)) }.to change { subject.root.points.count }.by(1)
  end

  it "should insert max_elements first inserts to root" do
    expect { (1..subject.max_elements).each { |i| subject.insert(Point.new(i, i)) } }.to change { subject.root.points.count }.by(subject.max_elements)
  end

  context "after inserting one more than max elements to tree" do
    before { (1..(1 + subject.max_elements)).each { |i| subject.insert(Point.new(i, i)) } }

    its(:root) { should have(2).children }
  end
end