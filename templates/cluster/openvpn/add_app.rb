#!/usr/bin/env ruby


require_relative 'openvpn_utils'

safe_exec do

  cluster_id = ENV.fetch('_cluster_id')
  app_id = ENV.fetch('_app_id')

  parse_and_init('openvpn', cluster_id)
  parse_and_init_app(app_id)

  app_name = get_value('_app_name')
  openvpn_ip_address = get_value('_openvpn_ip_address')

  get_value('_containers').each {|container|
    node_data = consul_get_node_data(container.fetch('node_id'))
    node_number = node_data.fetch('node_number')
    node_name = node_data.fetch('name')
    #TODO init_node in $vars for processor?
    create_tunnel(cluster_id, node_number, node_name, app_name, openvpn_ip_address)
  }

end


