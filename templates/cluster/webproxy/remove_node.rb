#!/usr/bin/env ruby
require_relative 'webproxy_utils'


safe_exec do

  cluster_id = ENV.fetch('_cluster_id')
  node_id = ENV.fetch('_node_id')

  parse_and_init('webproxy', cluster_id)
  parse_and_init_node(node_id)

  node_number = get_value('_node_number')

  remove_files_by_wildcard("/opt/openresty/nginx/sites-available/#{cluster_id}_#{node_number}*", $container)
  remove_files_by_wildcard("/opt/openresty/nginx/sites-enabled/#{cluster_id}_#{node_number}*", $container)

  #reload_nginx

end
