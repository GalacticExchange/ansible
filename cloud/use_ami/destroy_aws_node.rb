#!/usr/bin/env ruby

require_relative 'lib/node'

#Delete aws container by its clusterID and nodeUID

cluster_id = ENV.fetch('_cluster_id')
node_id = ENV.fetch('_node_uid')

puts "INSIDE destroy_aws_node"
puts cluster_id
puts node_id

if ENV['test']
  puts "!!!TEST!!!"
  exit 0
end

node = Node.instantiate(cluster_id,node_id)

if node.nil?
  puts "Couldn't connect to aws instance"
  exit 0
end


node.terminate

puts "EXITING destroy_aws_node"