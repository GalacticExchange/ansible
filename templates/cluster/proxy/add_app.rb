#!/usr/bin/env ruby

require_relative 'proxy_utils'


safe_exec {

  cluster_id = ENV.fetch('_cluster_id')
  app_id = ENV.fetch('_app_id')

  parse_and_init('proxy', cluster_id)
  parse_and_init_app(app_id)

  app_name = get_value('_app_name')

  get_value('_ssh_services').each {|ssh_service|
    node_data = consul_get_node_data(ssh_service.fetch('node_id'))
    source_port = ssh_service.fetch('ssh_port')

    node_id = node_data.fetch('id')
    node_name =node_data.fetch('name')

    destination_host = consul_get_container_ip(node_name, app_name)

    service_name = "#{cluster_id}_#{node_id}_#{app_name}_#{source_port}"

    create_proxy(service_name, source_port, destination_host)
  }

  get_value('_proxy_services').each {|proxy_service|
    node_data = consul_get_node_data(proxy_service.fetch('node_id'))

    source_port = proxy_service.fetch('source_port')
    dest_port = proxy_service.fetch('dest_port')

    node_id = node_data.fetch('id')
    node_name =node_data.fetch('name')

    destination_host = consul_get_container_ip(node_name, app_name)

    service_name = "#{cluster_id}_#{node_id}_#{app_name}_#{source_port}"

    create_proxy(service_name, source_port, destination_host, dest_port)
  }

}



