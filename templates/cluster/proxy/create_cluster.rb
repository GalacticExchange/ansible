#!/usr/bin/env ruby

require_relative "proxy_utils"


safe_exec do

  cluster_id = ENV.fetch('_cluster_id')
  GEX_LOGGER.set_cluster_id(cluster_id).info_start

  parse_and_init('proxy', cluster_id)

  source_port = _a('_port_ssh')

  service_name = "#{cluster_id}_master_#{source_port}"

  destination_host = get_framework_master_ip(cluster_id, "hadoop")

  create_proxy(service_name, source_port, destination_host)
  GEX_LOGGER.debug('proxy service created')

  GEX_LOGGER.info_finish
end








