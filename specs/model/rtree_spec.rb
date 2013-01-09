require_relative "../../model/rtree.rb"

describe RTree do
  let(:bounding_box) { BoundingBox.new(Point.new(0,0), 100, 100) }
  subject { RTree.new(bounding_box) }

  it "should insert first entry to root" do
    expect {subject.insert(Point.new(1, 1))}.to change {subject.root.children.count}.by(1)
  end

  it "should insert first max_elements entries to root" do
    expect do
      (1..subject.max_elements).each {|i| subject.insert(Point.new(i,i))}
    end.to change {subject.root.children.count}.by(1)
  end

  it "should split root when inserting one more than max_elements entries to tree" do
    (1..(subject.max_elements + 1)).each {|i| subject.insert(Point.new(i,i))}
    subject.root.children.should_not == subject.max_elements + 1
  end
end