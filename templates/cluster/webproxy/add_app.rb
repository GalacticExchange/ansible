#!/usr/bin/env ruby

require_relative 'webproxy_utils'


safe_exec do

  cluster_id = ENV.fetch('_cluster_id')
  app_id = ENV.fetch('_app_id')

  parse_and_init('proxy', cluster_id)
  parse_and_init_app(app_id)

  app_name = get_value('_app_name')

  get_value('_web_services').each {|web_service|
    node_data = consul_get_node_data(web_service.fetch('node_id'))

    return if node_data.fetch('node_type') != 'aws'

    node_number = node_data.fetch('node_number')
    node_name = node_data.fetch('name')

    service_ip = consul_get_container_ip(node_name, app_name)

    source_port = web_service.fetch('source_port')
    dest_port = web_service.fetch('dest_port')
    service_name = web_service.fetch('service_name')

    WebProxyUtils.setup_webproxy_service(cluster_id, node_number, service_ip, source_port, dest_port, app_name, service_name)
  }
  WebProxyUtils.reload_nginx #TODO



end


