#!/usr/bin/env ruby
require_relative 'lib/cluster_coordinator'

cluster_coord = ClusterCoordinator.new(
    cluster_id: ENV.fetch('_cluster_id')
)

if cluster_coord.check_coordinator_existence != 'None'
  exit 0
end


begin
  cluster_coord.start_new
  cluster_coord.launch_weave
rescue Exception => e
  cluster_coord.terminate
  cluster_coord.release_static_ip
  raise "Cannot create coordinator: #{e} class: #{e.class} backtrace: #{e.backtrace.inspect}"
end

cluster_coord.save_cluster_data


