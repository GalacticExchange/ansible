require_relative 'lib/init'
require_relative 'lib/init/sidekiq'


cluster_id=99
node_id=1107
cluster_type = 'onprem'
action = 'restart'

#ProvisionChangeAwsNodeStateWorker.perform(cluster_id, node_id, action)
#ProvisionChangeAwsNodeStateWorker.perform_async(cluster_id, node_id, action)
ClusterRemoveWorker.perform_async(cluster_id, cluster_type)
