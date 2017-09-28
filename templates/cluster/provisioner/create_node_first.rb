#!/usr/bin/env ruby
require_relative "local_utils"

safe_exec do

  cluster_id = ENV.fetch('_cluster_id')
  node_id = ENV.fetch('_node_id')

  parse_and_init('openvpn', cluster_id)
  parse_and_init_node(node_id)

  node_number = _a('_node_number')

  ndd = node_data_dir(cluster_id, node_number)

  remove_and_create_dir("#{ndd}")

  texec "mkdir #{ndd}/node"
  texec "mkdir #{ndd}/vpn"

  #TODO
  #texec "chattr +i #{ndd}"


end
