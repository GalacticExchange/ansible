#!/usr/bin/env ruby
# noinspection RubyResolve
require_relative "proxy_utils"

safe_exec do

  cluster_id = ENV.fetch('_cluster_id')
  app_id = ENV.fetch('_app_id')

  parse_and_init('proxy', cluster_id)
  parse_and_init_app(app_id)

  app_name = get_value('_app_name')

  get_value('_ssh_services').each {|ssh_service|
    node_data = consul_get_node_data(ssh_service.fetch('node_id'))
    node_id = node_data.fetch('id')

    remove_services_by_wildcard("proxy_#{cluster_id}_#{node_id}_#{app_name}_*")
  }


end
