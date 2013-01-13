# Default values for both trees
ruby run_experiment.rb ../data/converted_data.csv ../data/real_1000_queries.csv real
ruby run_experiment.rb ../data/converted_data.csv ../data/real_10000_queries.csv real
ruby run_experiment.rb ../data/converted_data.csv ../data/real_100000_queries.csv real

# R-tree max to 25
# Quadtree max to 25
ruby run_experiment.rb ../data/converted_data.csv ../data/real_1000_queries.csv real --q_max_elem 25 --r_max 25
ruby run_experiment.rb ../data/converted_data.csv ../data/real_10000_queries.csv real --q_max_elem 25 --r_max 25
ruby run_experiment.rb ../data/converted_data.csv ../data/real_100000_queries.csv real --q_max_elem 25 --r_max 25

# R-tree max to 75
# Quadtree max to 75
ruby run_experiment.rb ../data/converted_data.csv ../data/real_1000_queries.csv real --q_max_elem 75 --r_max 75
ruby run_experiment.rb ../data/converted_data.csv ../data/real_10000_queries.csv real --q_max_elem 75 --r_max 75
ruby run_experiment.rb ../data/converted_data.csv ../data/real_100000_queries.csv real --q_max_elem 75 --r_max 75

# R-tree min to 20
# Quadtree max depth to 100
ruby run_experiment.rb ../data/converted_data.csv ../data/real_1000_queries.csv real --r_min 20 --q_max_depth 100
ruby run_experiment.rb ../data/converted_data.csv ../data/real_10000_queries.csv real --r_min 20 --q_max_depth 100
ruby run_experiment.rb ../data/converted_data.csv ../data/real_100000_queries.csv real --r_min 20 --q_max_depth 100

# R-tree min to 25
# Quadtree max depth to 50
ruby run_experiment.rb ../data/converted_data.csv ../data/real_1000_queries.csv real --r_min 25 --q_max_depth 50
ruby run_experiment.rb ../data/converted_data.csv ../data/real_10000_queries.csv real --r_min 25 --q_max_depth 50
ruby run_experiment.rb ../data/converted_data.csv ../data/real_100000_queries.csv real --r_min 25 --q_max_depth 50