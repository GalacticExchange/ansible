require_relative 'lib/init'
require_relative 'lib/init/sidekiq'


cluster_id=99
node_id=1107

NodeRemoveWorker.perform_async(cluster_id,node_id)