#!/usr/bin/env ruby

require_relative 'local_utils'

safe_exec do

  cluster_id = ENV.fetch('_cluster_id')
  #parse_and_init('provisioner', cluster_id)

  if ENV.fetch('_cluster_type').to_s == 'aws'
    #require_relative '/mount/ansible/cloud/use_ami/destroy_aws_cluster.rb'
    require_relative '../../../cloud/use_ami/destroy_aws_cluster'
  end

  FileUtils.rm_rf cluster_data_dir(cluster_id)

end
