#!/usr/bin/env ruby

require_relative 'lib/node'

node = Node.new(
    hadoop_type: ENV.fetch('_hadoop_type'),
    cluster_id: ENV.fetch('_cluster_id'),
    instance_type: ENV.fetch('_instance_type'),
    gex_node_uid: ENV.fetch('_node_uid'),
    node_agent_token: ENV.fetch('_node_agent_token'),
    volume_size: ENV.fetch('_volume_size'),
    node_name: ENV.fetch('_node_name')
)
begin
  node.start_new
  node.launch_weave_node
  node.install_client
rescue Exception => e
  node.terminate if ENV.fetch('_debug','').empty?

  puts "Cannot create node: #{e} class: #{e.class} backtrace: #{e.backtrace.inspect}"

  raise "Cannot create node: #{e} class: #{e.class} backtrace: #{e.backtrace.inspect}"
end

node.save_node_data
