outputfile = ARGV[0]
number_of_queries = ARVG[1].to_i

query_generator = QueryGenerator.new
queries = query_generator.generate_queries(number_of_queries)

file = File.new(outputfile, "w")
queries.each do |query|
  file.write query + "\n"
end
file.close