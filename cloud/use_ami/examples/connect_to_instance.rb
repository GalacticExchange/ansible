#!/usr/bin/env ruby
require 'fog/aws'
#require 'net/http'


fog = Fog::Compute.new(
  :provider => 'AWS',
  :region=>'us-west-2',
  :aws_access_key_id => 'PH_GEX_AWS_KEY',
  :aws_secret_access_key => 'PH_GEX_AWS_ID'
)


gex_instance = fog.servers.get('i-e629f049')

gex_instance.username = 'vagrant'
gex_instance.private_key_path = '../GEXExp.pem'

puts gex_instance.ssh(%Q(touch ztez))