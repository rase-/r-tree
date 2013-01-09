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

    its(:root) {should_not be_leaf}

    its(:root) { should have(2).children }

    its(:root) { should have(0).points }

    it "should return (1,1), (2,2) and (3,3) when searching with box: point: (1,1), width: 2, height: 2" do
      points = subject.search(BoundingBox.new(Point.new(1,1), 2, 2))
      points.count.should == 3
      points.include?(Point.new(1,1)).should be_true
      points.include?(Point.new(2,2)).should be_true
      points.include?(Point.new(3,3)).should be_true
    end

    it "should return point (50,50) when searching only for that point" do
      points = subject.search(BoundingBox.new(Point.new(50, 50), 0, 0))
      points.count.should == 1
      points.first.should == Point.new(50,50)
    end

    it "should not return any points when searching with box: point: (4,5), width: 0, height: 0" do
      points = subject.search(BoundingBox.new(Point.new(4,5), 0, 0))
      points.should be_empty
    end

    it "should not return any points when searching with box: point: (60, 60), width: 10, height: 10" do
      points = subject.search(BoundingBox.new(Point.new(60, 60), 10, 10))
      points.should be_empty
    end
  end
end