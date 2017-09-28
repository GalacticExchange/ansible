require_relative 'lib/cluster_coordinator'

cluster_id = ENV.fetch('_cluster_id')

action = ENV.fetch('_action') #start/stop

coordinator = ClusterCoordinator.instantiate(cluster_id)

coordinator.change_instance_state(action)