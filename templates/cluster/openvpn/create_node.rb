#!/usr/bin/env ruby

require_relative "openvpn_utils"

safe_exec do

  cluster_id = ENV.fetch('_cluster_id')
  node_id = ENV.fetch('_node_id')
  GEX_LOGGER.set_cluster_id(cluster_id).set_node_id(node_id).info_start

  parse_and_init('openvpn', cluster_id)
  parse_and_init_node(node_id)

  node_number = get_value('_node_number').to_s
  node_name = get_value('_node_name')
  openvpn_ip_address = get_value('_openvpn_ip_address')

  GEX_LOGGER.debug('before create_tunnel')
  create_tunnel cluster_id, node_number, node_name, 'node', openvpn_ip_address

  unless $vars['_hadoop_app_id']
    GEX_LOGGER.info_finish
    exit 0
  end

  FRAMEWORKS.each do |f|
    GEX_LOGGER.debug("before create_tunnel #{f}")
    create_tunnel cluster_id, node_number, node_name, f, openvpn_ip_address
  end

  GEX_LOGGER.info_finish
end


