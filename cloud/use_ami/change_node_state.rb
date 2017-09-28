require_relative 'lib/node'

cluster_id = ENV.fetch('_cluster_id')
node_uid = ENV.fetch('_node_uid')
action = ENV.fetch('_action') #start/stop

action = 'reboot' if action == 'restart'

node = Node.instantiate(cluster_id, node_uid)
node.change_instance_state(action)



