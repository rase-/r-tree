require_relative "../../model/quadtree.rb"
require_relative "../../model/point.rb"

describe QuadTree do
  let(:space) { BoundingBox.new(Point.new(0, 0), 100, 100) }
  let(:tree) { QuadTree.new(space) }
  subject { tree }

  it "should accept a point in its root when adding first point" do
    expect { subject.insert(Point.new(1, 1)) }.to change { subject.root.points.count }.by(1)  
  end

  it "should accept points in its root when adding max elements number of points" do
    expect do 
      (1..(subject.max_elements)).each { |i| subject.insert(Point.new(i,i)) }
    end.to change { subject.root.points.count }.by(subject.max_elements)
  end

  context "after split" do
    before { (1..subject.max_elements + 1).each { |i| subject.insert(Point.new(i + 3, i + 2)) } }

    it "should delegate all points to its chilren" do
      subject.root.points.should be_empty
    end

    it "should have a root with exactly four children" do
      subject.root.should have(4).children
    end

    it "should have altogether max_elements + 1 number of points in its 4 children" do
      subject.root.children.inject(0) { |points, child| points + child.points.count }.should == subject.max_elements + 1
    end

    it "should return points (4,3) and (5,4) when searched on a rectangle stretching from (0,0) 5 units to both axis" do
      box = BoundingBox.new(Point.new(0,0), 5, 5)
      points = subject.search(box)
      puts points.inspect
      points.count.should == 2 # right amount
      points.include?(Point.new(4, 3)).should be_true
      points.include?(Point.new(5, 4)).should be_true
    end
  end

  context "in its root" do
    subject { tree.root }

    its(:children) { should be_empty }
    its(:bounding_box) { should == space }
  end
end