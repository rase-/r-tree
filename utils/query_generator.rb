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
    # Randomize boundingbox width from remaining space
    # Randomize boundingbox height from remaining space
  end
end