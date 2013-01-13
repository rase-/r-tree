# Default values for both trees
ruby run_experiment.rb ../data/100000_generated_examples.csv ../data/1000_queries_for_generated_data.csv generated
ruby run_experiment.rb ../data/100000_generated_examples.csv ../data/10000_queries_for_generated_data.csv generated
ruby run_experiment.rb ../data/100000_generated_examples.csv ../data/100000_queries_for_generated_data.csv generated

# R-tree max to 25
# Quadtree max to 25
ruby run_experiment.rb ../data/100000_generated_examples.csv ../data/1000_queries_for_generated_data.csv generated --q_max_elem 25 --r_max 25
ruby run_experiment.rb ../data/100000_generated_examples.csv ../data/10000_queries_for_generated_data.csv generated --q_max_elem 25 --r_max 25
ruby run_experiment.rb ../data/100000_generated_examples.csv ../data/100000_queries_for_generated_data.csv generated --q_max_elem 25 --r_max 25

# R-tree max to 75
# Quadtree max to 75
ruby run_experiment.rb ../data/100000_generated_examples.csv ../data/1000_queries_for_generated_data.csv generated --q_max_elem 75 --r_max 75
ruby run_experiment.rb ../data/100000_generated_examples.csv ../data/10000_queries_for_generated_data.csv generated --q_max_elem 75 --r_max 75
ruby run_experiment.rb ../data/100000_generated_examples.csv ../data/10000_queries_for_generated_data.csv generated --q_max_elem 75 --r_max 75

# R-tree min to 20
# Quadtree max depth to 100
ruby run_experiment.rb ../data/100000_generated_examples.csv ../data/1000_queries_for_generated_data.csv generated --r_min 20 --q_max_depth 100
ruby run_experiment.rb ../data/100000_generated_examples.csv ../data/10000_queries_for_generated_data.csv generated --r_min 20 --q_max_depth 100
ruby run_experiment.rb ../data/100000_generated_examples.csv ../data/100000_queries_for_generated_data.csv generated --r_min 20 --q_max_depth 100

# R-tree min to 25
# Quadtree max depth to 50
ruby run_experiment.rb ../data/100000_generated_examples.csv ../data/1000_queries_for_generated_data.csv generated --r_min 25 --q_max_depth 50
ruby run_experiment.rb ../data/100000_generated_examples.csv ../data/10000_queries_for_generated_data.csv generated --r_min 25 --q_max_depth 50
ruby run_experiment.rb ../data/100000_generated_examples.csv ../data/100000_queries_for_generated_data.csv generated --r_min 25 --q_max_depth 50