#!/usr/bin/env ruby
x = 0
y = 0
width = 100000
height = 100000

file = File.new(ARGV[0], "w")
(1..ARGV[1].to_i).each do |i|
  # format is x,y
  file.write("#{x + Random.rand(0..width)},#{y + Random.rand(0..height)}\n")
end
file.close