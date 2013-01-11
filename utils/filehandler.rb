class FileHandler
  attr_reader :filename, :type

  def initialize(filename, type)
    @types = [:insertion, :query]
    @handlers = {:insertion => :create_insertion, :query => :create_query}
    @filename = filename
    @type = type
    @rows_handled = 1
  end

  def open
    @file = File.open(filename, "r")
  end

  def finished?
    @file.eof
  end

  def handle_row
    line = @file.readline
    @rows_handled += 1
    self.send(@handlers[@type], line)
  end

  def handle_all
    lines = @file.readlines
    elements = lines.collect do |line|
      self.send(@handlers[@type], line)
    end
    return elements
  end

  def close
    puts "#{@rows_handled}"
    @file.close
  end 

  private
  # Files in CSV format, so splitting done by ',' character
  def create_insertion(line)
    split_line = line.split(",")
    x = split_line.first.to_i
    y = split_line[1].to_i # Can't use method last because of possible zone as third entry
    Point.new(x, y)
  end

  def create_query(line)
    split_line = line.split(",")
    x = split_line.first.to_i
    y = split_line[1].to_i
    width = split_line[2].to_i
    height = split_line[3].to_i
    BoundingBox.new(Point.new(x, y), width, height)
  end
end