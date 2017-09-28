#!/usr/bin/env ruby
require_relative 'proxy_utils'

safe_exec do


  cluster_id = ENV.fetch('_cluster_id')
  node_id = ENV.fetch('_node_id')

  parse_and_init('proxy', cluster_id)
  parse_and_init_node(node_id)

  node_number = get_value('_node_number')

  remove_services_by_wildcard "proxy_#{cluster_id}_#{node_number}_*"

end





