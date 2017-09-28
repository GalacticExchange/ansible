#!/usr/bin/env ruby

require_relative "master_utils"

safe_exec do

  cluster_id = ENV.fetch('_cluster_id')
  GEX_LOGGER.set_cluster_id(cluster_id).info_start

  parse_and_init('master', cluster_id)

  FRAMEWORKS.each do |f|
    GEX_LOGGER.before_line_debug("f = #{f}")
    add_var "_#{f}_ipv4", get_framework_master_ip(cluster_id, f)
  end

  FRAMEWORKS.each do |f|
    GEX_LOGGER.before_line_debug("f = #{f}")
    gex_cloud_create_and_configure_master_container f, cluster_id
  end

  GEX_LOGGER.info_finish

end






