require_relative "../utils/filehandler.rb"
require_relative "../utils/logger.rb"

class Analyzer
  attr_reader :tree

  def initialize(tree)
    @tree = tree
    @logger = Logger.new("./log.txt")
  end

  def run_insertions
    file_handler = FileHandler.new("", :insertion)
    file_handler.open
    until file_handler.finished? do
      @tree.insert file_handler.handle_row
    end
    file_handler.close
  end

  def run_and_analyze_insertions
    runtime = time do
      run_insertions
    end
    message = "Insertion took #{runtime} ms for #{@tree.class}"
    @logger.log(message)
    message
  end

  def analyze_queries
    runtime = time do
      file_handler = FileHandler.new("", :query)
      file_handler.open
      runtime = until file_handler.finished? do
        @tree.search file_handler.handle_row
      end
      file_handler.close
    end
    message = "Queries run in #{runtime} ms for #{@tree.class}"
    @logger.log(message)
    message
  end

  private
  def time
    start_time = Time.now
    yield
    end_time = Time.now
    end_time - start_time
  end
end