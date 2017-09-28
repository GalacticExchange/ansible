#!/usr/bin/env ruby
require_relative "local_utils"

safe_exec do

  cluster_id = ENV.fetch('_cluster_id')

  # init dir structure
  bd = cluster_data_dir(cluster_id)
  remove_and_create_dir(bd)

  FileUtils.mkdir_p(
      %W(#{bd}/nodes #{bd}/credentials #{bd}/vpn #{bd}/vars)
  )

end

