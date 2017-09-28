require_relative 'lib/cluster_coordinator'
require_relative 'lib/node'

Fog.mock! unless ENV.fetch('_test', nil).nil?


cluster_id = ENV.fetch('_cluster_id')
action = ENV.fetch('_action')

coordinator = ClusterCoordinator.instantiate(cluster_id)
coordinator.change_instance_state(action)

gex_node_ids = coordinator.config.get_nodes_data.map { |elem| elem[:gex_node_uid] }

nodes = []

gex_node_ids.each { |gex_id|
  puts gex_id
  node = Node.instantiate(cluster_id, gex_id)
  nodes.push(node)
}

nodes.compact!

nodes_threads = []

nodes.each { |node|
  nodes_threads.push(
      Thread.new {
        node.change_instance_state(action)
      }
  )
}

nodes_threads.each { |thr| thr.join }

