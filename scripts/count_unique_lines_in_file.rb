filename = ARGV[0]

file = File.open(filename, "r")
found_lines = []
file.each do |line|
  found_lines << line.chomp unless found_lines.include? line.chomp
end 
file.close
puts "Number of unique lines: #{found_lines.count}"