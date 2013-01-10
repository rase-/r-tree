class Logger
  attr_reader :filename

  def initialize(filename)
    @filename = filename
    @file = File.open(filename, "a")
  end

  def log(message)
    @file.write message + "\n"
  end
end