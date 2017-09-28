#!/usr/bin/env ruby

require_relative "local_utils"

safe_exec do

  cluster_id = ENV.fetch('_cluster_id')
  node_id = ENV.fetch('_node_id')

  node_number = ENV.fetch('_node_number')

  ndd = node_data_dir(cluster_id, node_number)

  begin
    FileUtils.rm_r ndd
  rescue
    puts "Could not remove node data directory: #{ndd}"
  end

end

