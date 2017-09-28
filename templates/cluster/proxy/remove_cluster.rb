#!/usr/bin/env ruby

require_relative "proxy_utils"

safe_exec do

  cluster_id = ENV.fetch('_cluster_id')
  #parse_and_init('proxy', cluster_id)

  remove_services_by_wildcard "proxy_#{cluster_id}_*"

end
