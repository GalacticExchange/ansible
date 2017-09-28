require_relative '../lib/init'
require_relative '../lib/init/sidekiq'
require_relative '../lib/init/gush'

cluster_id = ENV.fetch('_cluster_id')
node_ids = JSON.parse(ENV.fetch('_node_ids'))

# gush
flow = ClusterDeleteAllWorkflow.create(cluster_id, node_ids)
flow.start!

puts 'OK'
exit 0