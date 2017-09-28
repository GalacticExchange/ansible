require_relative 'lib/container_utils'

#initial _cluster_id
#initial _container_name
#initial _node_name
#initial _cmd

#fetch node tunnel ip

cluster_id = ENV.fetch('_cluster_id')
node_name = ENV.fetch('_node_name', '')
container_name = ENV.fetch('_container_name').gsub("-#{node_name}",'')
action = ENV.fetch('_cmd')

ContainerUtils.change_container_state(cluster_id, node_name, container_name, action)




