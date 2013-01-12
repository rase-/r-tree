module BoundingBoxSearchable
  def search(bounding_box)
    points_covered(@root, bounding_box, [])
  end

  alias_method :rect_search, :search

  private
  def points_covered(node, bounding_box, points)
    if node.leaf?
      node.points.each do |point|
        points << point if bounding_box.covers? point
      end
    end

    node.children.each do |child|
      points_covered(child, bounding_box, points) if child.bounding_box.intersects?(bounding_box)
    end
    points
  end
end