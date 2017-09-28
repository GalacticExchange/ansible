#!/usr/bin/env ruby
require 'fog/aws'

KEY_NAME = 'ClusterGX_key'

fog = Fog::Compute.new(
  :provider => 'AWS',
  :region=>'us-west-2',
  :aws_access_key_id => 'PH_GEX_AWS_KEY',
  :aws_secret_access_key => 'PH_GEX_AWS_ID'
)

key = fog.create_key_pair(KEY_NAME)


pem_file = File.new("credentials/#{KEY_NAME}.pem",'w')
pem_file.puts(key.body['keyMaterial'])

File.chmod(0400,"credentials/#{KEY_NAME}.pem")
