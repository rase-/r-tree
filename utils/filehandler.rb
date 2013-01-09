class FileHandler
  attr_reader :filename, :type

  def initialize(filename, type)
    @types = [:insertion, :query]
    @handlers = [:create_insertion, :create_query]
    @filename = filename
    @type = type
    @file = nil
  end

  def begin
    @file = File.open(filename, "r")
  end

  def finished?
    @file.any?
  end

  def handle_row
    line = @file.readline
    send(handlers[@type], line)
  end

  def close
    @file.close
  end 

  private
  def create_insertion(line)
    # TODO, returns one single point to be inserted
  end

  def create_query(line)
    # TODO, returns one single rectangle to be 
  end
end