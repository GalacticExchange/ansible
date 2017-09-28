require_relative 'lib/init'
require_relative 'lib/init/sidekiq'
require_relative 'lib/init/gush'


logger = Logger.new(File.join('log', 'workflow.log'))
logger.level = Logger::DEBUG

###
cluster_id = 999
node_ids = [1370, 1371]

# gush
flow = ClusterDeleteAllWorkflow.create(cluster_id, node_ids)

#flow.save # saves workflow and its jobs to Redis
flow.start!

puts "OK"
exit 0

