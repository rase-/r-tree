require_relative "../model/boundingbox.rb"
require_relative "../utils/query_generator.rb"
Point = Struct.new(:x, :y)

outputfile = ARGV[0]
number_of_queries = ARGV[1].to_i
space_x = ARGV[2].to_i
space_y = ARGV[3].to_i
space_width = ARGV[4].to_i
space_height = ARGV[5].to_i
space = BoundingBox.new(Point.new(space_x, space_y), space_width, space_height)

query_generator = QueryGenerator.new space
queries = query_generator.generate_queries(number_of_queries)

file = File.new(outputfile, "w")
queries.each do |query|
  file.write query + "\n"
end
file.close