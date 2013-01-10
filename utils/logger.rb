class Logger
  attr_reader :filename

  def initialize(filename)
    @filename = filename
    @file = File.open(filename, "a")
  end

  def log(message)
    @file.write(timestamp + " " + message + "\n")
  end

  private
  def timestamp
    "[" + Time.now.to_s + "]"
  end
end