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
  # Files in CSV format, so splitting done by ',' character
  def create_insertion(line)
    split = line.split(",")
    x = split.first.to_i
    y = split.last.to_i
    Point.new(x, y)
  end

  def create_query(line)
    split = line.split(",")
    x = split.first.to_i
    y = split[1].to_i
    width = split[2].to_i
    height = split[3].to_i
    BoundingBox.new(Point.new(x, y), width, height)
  end
end