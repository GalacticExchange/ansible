#!/usr/bin/env ruby

require_relative 'lib/pre_config'

pre_config = PreConfig.new(
    aws_access_key_id: ENV.fetch('_aws_access_key_id'),
    aws_secret_access_key: ENV.fetch('_aws_secret_key'),
    cluster_id: ENV.fetch('_cluster_id'),
    cluster_uid: ENV.fetch('_cluster_uid'),
    region: ENV.fetch('_aws_region'),
    env: ENV.fetch('_gex_env', 'prod'),
    cluster_name: ENV.fetch('_cluster_name')
)

if pre_config.check_existence
  exit 0
end

begin
  pre_config.create_key_pair
  pre_config.create_vpc
  pre_config.create_peering_connection
  pre_config.create_subnet
  pre_config.create_security_group
  pre_config.setup_gateway
  pre_config.create_peering_routes
  pre_config.save_cluster_data
  pre_config.create_nodes_file
rescue Exception => e
  pre_config.clean_all
  raise "Failed to make basic configuration: #{e}"
end
