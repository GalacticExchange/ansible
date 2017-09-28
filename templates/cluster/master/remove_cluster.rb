#!/usr/bin/env ruby

require_relative "master_utils"

safe_exec do

  cluster_id = ENV.fetch('_cluster_id')
  #parse_and_init('master', cluster_id)

  remove_master_container "hadoop", cluster_id
  remove_master_container "hue", cluster_id

end

