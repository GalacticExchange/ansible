#!/usr/bin/env ruby

require_relative 'webproxy_utils'


safe_exec {

  cluster_id = ENV.fetch('_cluster_id')
  node_id = ENV.fetch('_node_id')

  GEX_LOGGER.set_cluster_id(cluster_id).set_node_id(node_id)
  GEX_LOGGER.info_start


  parse_and_init('openvpn', cluster_id)
  parse_and_init_node(node_id)

  node_number = _a('_node_number')

  #app_name = "hue"
  #service_name = "webui"

  unless $vars['_hadoop_app_id']
    GEX_LOGGER.info_finish
    exit 0
  end

  if _a('_node_type', false) == 'aws'

    GEX_LOGGER.debug('Entered aws block')

    consul_connect(get_value('_cluster_id'))
    hue_tun_ip = consul_get_container_ip(get_value('_node_name'), 'hue')
    hadoop_tun_ip = consul_get_container_ip(get_value('_node_name'), 'hadoop')

    #web_services = []
    web_services = get_value('_web_services').map do |web_service|
      {
          'service_ip' => web_service['app_name'] == 'hue' ? hue_tun_ip : hadoop_tun_ip,
          'source_port' => web_service.fetch('source_port'),
          'dest_port' => web_service.fetch('dest_port'),
          'app_name' => web_service.fetch('app_name'),
          'service_name' => 'webui'
      }
    end

    WebProxyUtils.setup_webproxy_services(web_services, cluster_id, node_number)
    GEX_LOGGER.debug('Configured webproxy services')

  end

  WebProxyUtils.reload_nginx #TODO

  GEX_LOGGER.info_finish


}


