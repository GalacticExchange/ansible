require_relative '../spec_helper'

cluster_data ={cluster_id: 99}
s_cluster_data = JSON.generate(cluster_data)

puts s_cluster_data

flow = ClusterCreateWorkflow.create(99, "'#{s_cluster_data}'")
flow.start!


puts 'OK'