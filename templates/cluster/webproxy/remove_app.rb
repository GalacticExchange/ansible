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
    node_number = node_data.fetch('node_number')

    remove_files_by_wildcard "/opt/openresty/nginx/sites-available/#{cluster_id}_#{node_number}_#{app_name}*"
    remove_files_by_wildcard "/opt/openresty/nginx/sites-enabled/#{cluster_id}_#{node_number}_#{app_name}*"
  }

  #WebProxyUtils.reload_nginx TODO

end

