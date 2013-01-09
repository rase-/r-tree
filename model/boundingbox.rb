class BoundingBox
  attr_accessor :point, :width, :height

  def initialize(point, width, height)
    @point = point
    @width = width
    @height = height
  end

  def area
    @width * @height
  end

  def covers?(point)
    (@point.x <= point.x && point.x <= @point.x + @width) && (@point.y <= point.y && point.y <= @point.y + @height)
  end

  def intersects?(bounding_box)
    return false if @point.x + @width < bounding_box.point.x # self is left of given box
    return false if bounding_box.point.x + bounding_box.width < @point.x # self is right of given box
    return false if @point.y + @height < bounding_box.point.y # self is above the given box
    return false if bounding_box.point.y + bounding_box.height < @point.y # self is below the given box
    true
  end

  def ==(box)
    @point == box.point && @width == box.width && @height == box.height
  end

  def deepcopy
    copy = self.clone
    copy.point = Point.new(self.point.x, self.point.y)
    return copy
  end
end