class FileHandler
  attr_reader :filename, :type

  def initialize(filename, type)
    @types = [:insertion, :query]
    @handlers = [:create_insertion, :create_query]
    @filename = filename
    @type = type
    @file = nil
  end

  def open
    @file = File.open(filename, "r")
  end

  def finished?
    not @file.any?
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
    x = line.split.first.to_i
    y = line.split.last.to_i
    Point.new(x, y)
  end

  def create_query(line)
    x = line.split.first.to_i
    y = line.split[1].to_i
    width = line.split[2].to_i
    height = line.split[3].to_i
    BoundingBox.new(Point.new(x, y), width, height)
  end
end