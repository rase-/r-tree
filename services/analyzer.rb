class Analyzer
  attr_reader :tree

  def initialize(tree)
    @tree = tree
  end

  def run_insertions
    # TODO
  end

  def run_and_analyze_insertions
    # TODO
  end

  def analyze_queries
    # TODO
  end

  private
  def time
    start_time = Time.now
    yield
    end_time = Time.now
    end_time - start_time
  end
end