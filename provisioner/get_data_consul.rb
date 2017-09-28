require_relative 'lib/consul_utils'

cluster_id = ENV.fetch('_cluster_id')

node_id = ENV.fetch('_node_id', '')

app_id = ENV.fetch('_app_id', '')

ConsulUtils.connect(cluster_id)

if node_id.empty?
  puts ConsulUtils.get_cluster_data
elsif app_id.empty?
  puts ConsulUtils.get_node_data(node_id)
else
  puts ConsulUtils.get_app_data(node_id, app_id)
end
