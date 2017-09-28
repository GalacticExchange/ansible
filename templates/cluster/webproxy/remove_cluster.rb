#!/usr/bin/env ruby

require_relative "webproxy_utils"

safe_exec {

  cluster_id = ENV.fetch('_cluster_id')
  #parse_and_init('webproxy', cluster_id)

  texec "docker exec -t gex-webproxy bash -c 'rm -f /opt/openresty/nginx/sites-available/#{cluster_id}*'"
  texec "docker exec -t gex-webproxy bash -c 'rm -f /opt/openresty/nginx/sites-enabled/#{cluster_id}*'"

  #remove_files_by_wildcard "/opt/openresty/nginx/sites-available/#{cluster_id}*", $container
  #remove_files_by_wildcard "/opt/openresty/nginx/sites-enabled/#{cluster_id}*", $container

  #WebProxyUtils.reload_nginx TODO

}