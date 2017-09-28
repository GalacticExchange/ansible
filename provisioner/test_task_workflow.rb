require_relative 'lib/init'
require_relative 'lib/init/sidekiq'
require_relative 'lib/init/gush'


logger = Logger.new(File.join('log', 'workflow.log'))
logger.level = Logger::DEBUG

# debug
# remove old gush
=begin
$redis = Redis.new(:host => '51.0.0.12', :port => 6379)

keys = $redis.keys("gush.*")
puts "#{keys}"
keys.each do |key|
  $redis.del key
end
exit 1
=end



###
cluster_id = 520
node_ids = [1124, 1110]

# gush

flow = ClusterDeleteAllWorkflow.create(cluster_id, node_ids)

#flow.save # saves workflow and its jobs to Redis
flow.start!


puts "OK"
exit 0


# superworkflow
=begin

#Sidekiq::Superworker::Logging.logger = logger



Superworker.define(:ClusterDeleteAll, :cluster_id, :node_ids) do
  #sidekiq_options :queue => :provision, :retry => false

  #batch node_ids: :node_id do
  #  NodeRemoveWorker :cluster_id, node_id
  #end

  node_ids.each do |node_id|
    NodeRemoveWorker :cluster_id, node_id
  end

  ClusterRemoveWorker :cluster_id
end

res = ClusterDeleteAll.perform_async(cluster_id, node_ids)
puts "res=#{res}"
=end
