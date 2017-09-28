#!/usr/bin/env ruby

require_relative 'master_utils'

safe_exec do

  cluster_id = ENV.fetch('_cluster_id')
  node_id = ENV.fetch('_node_id')

  parse_and_init('openvpn', cluster_id)
  parse_and_init_node(node_id)

  use_container("hadoop-master-#{cluster_id}")

  remove_slave_from_master(get_value('_node_name'), "/etc/hadoop/conf", "/usr/bin")


end

