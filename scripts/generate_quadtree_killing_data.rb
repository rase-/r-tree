#!/usr/bin/env ruby
x = 0
y = 0
width = 100000
height = 100000
outputfilename = ARGV[0]
number_of_examples = ARGV[1].to_i

file = File.new(outputfilename, "w")
(1..number_of_examples).each do |i|
  # format is x,y
  file.write("#{x + Random.rand(99000..width)},#{y + Random.rand(99000..height)}\n")
end
file.close