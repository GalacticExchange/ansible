#!/usr/bin/env ruby

require_relative "proxy_utils"


safe_exec {

  cluster_id = ENV.fetch('_cluster_id')
  node_id = ENV.fetch('_node_id')

  GEX_LOGGER.set_cluster_id(cluster_id).set_node_id(node_id)
  GEX_LOGGER.info_start


  parse_and_init('proxy', cluster_id)
  parse_and_init_node(node_id)

  #unless get_value('_hadoop_app_id')
  unless $vars['_hadoop_app_id']
    GEX_LOGGER.info_finish
    exit 0
  end

  if get_value('_node_type') == 'aws'
    GEX_LOGGER.debug('Entered aws block')

    source_port = get_value('_port_ssh')

    node_number = get_value('_node_number')

    service_name = "#{cluster_id}_#{node_number}_#{source_port}"

    destination_host = consul_get_container_ip(get_value('_node_name'), 'hadoop')

    create_proxy(service_name, source_port, destination_host)
    GEX_LOGGER.debug('Created proxy service')

    if get_value('_components').include?('neo4j')
      GEX_LOGGER.debug('Entered neo4j BOLT block')

      bolt_service_name = "#{cluster_id}_#{node_number}_neo4j_bolt"
      bolt_proxy_port = get_value('_port_neo4j_bolt')
      create_proxy(bolt_service_name, bolt_proxy_port, destination_host,'7687')

      GEX_LOGGER.debug('Created neo4j bolt proxy service')
    end

  end

  GEX_LOGGER.info_finish

}



