#!/usr/bin/env ruby

require_relative 'openvpn_utils'

safe_exec do

  cluster_id = ENV.fetch('_cluster_id')
  GEX_LOGGER.set_cluster_id(cluster_id).info_start

  parse_and_init('openvpn', cluster_id)

  consul_connect(cluster_id)
  GEX_LOGGER.debug('connected to consul')

  GEX_LOGGER.debug('before consul init cluster')
  consul_init_cluster(cluster_id, get_vars.fetch('_cluster_name'))
  #consul_set_cluster_data(cluster_data)

  FRAMEWORKS.each do |f|
    GEX_LOGGER.debug("before add to container hosts: #{f}")
    add_to_container_hosts get_framework_master_ip(cluster_id, f),
                 "#{f}-master-#{cluster_id}.gex #{f}-master-#{cluster_id}"
  end

  GEX_LOGGER.info_finish
end