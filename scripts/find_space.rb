datafilename = ARGV[0]
file = File.open(datafilename, "r")

positive_infinity = 1.0/0.0
negative_infinity = -1.0/0.0

max_x = negative_infinity
max_y = negative_infinity
min_x = positive_infinity
min_y = positive_infinity

file.each do |line|
  split = line.split(",")
  x = split[0].to_i
  y = split[1].to_i
  # Zone ignored
  max_x = x if x > max_x
  max_y = y if y > max_y
  min_x = x if x < min_x
  min_y = y if y < min_y
end
file.close

puts "#{min_x} #{min_y} #{max_x - min_x} #{max_y - min_y}"
