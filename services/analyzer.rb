require_relative "../utils/filehandler.rb"
require_relative "../utils/logger.rb"

class Analyzer
  attr_reader :tree

  def initialize(tree, datafilename, queryfilename)
    @tree = tree
    @datafilename = datafilename
    @queryfilename = queryfilename
    @logger = Logger.new("./log.txt")
  end

  def run_insertions
    file_handler = FileHandler.new(@datafilename, :insertion)
    file_handler.open
    until file_handler.finished?
      element = file_handler.handle_row
      @tree.insert element
    end
    file_handler.close
  end

  def run_and_analyze_insertions
    runtime = take_time do
      run_insertions
    end
    stats_message = "Insertion took #{runtime} ms for #{@tree.class}"
    @logger.log(stats_message)
    stats_message
  end

  def run_and_analyze_queries
    runtime = take_time do
      file_handler = FileHandler.new(@queryfilename, :query)
      file_handler.open
      runtime = until file_handler.finished? do
        @tree.search file_handler.handle_row
      end
      file_handler.close
    end
    stats_message = "Queries run in #{runtime} ms for #{@tree.class}"
    @logger.log(stats_message)
    stats_message
  end

  private
  def take_time
    start_time = Time.now
    yield
    end_time = Time.now
    end_time - start_time
  end
end