class QueryGenerator
  def initialize(space)
    @space = space
  end

  def generate_queries(n)
    queries = []
    (1..n).each do |i|
      queries << generate_query
    end
    queries
  end

  private
  def generate_query
    # Randomize starting point from space
    x = @space.point.x + Random.rand(0..@space.width)
    y = @space.point.y + Random.rand(0..@space.height)
    point = Point.new(x, y)

    # Only take into account remaining space in randomizing width and height
    width = Random.rand(0..(@space.x + @space.width - point.x))
    height = Random.rand(0..(@space.y + @space.height - point.y))
    BoundingBox.new(Point.new(x, y), width, height).to_s
  end
end