#!/usr/bin/env ruby
require_relative 'local_utils'

safe_exec do

  cluster_id = ENV.fetch('_cluster_id')
  node_id = ENV.fetch('_node_id')

  parse_and_init('provisioner', cluster_id)
  parse_and_init_node(node_id)


  keys = ['_cluster_id', '_gex_env', '_hadoop_type', '_node_agent_token', '_instance_type', '_node_uid', '_volume_size', '_node_name']

  params = keys.map {|k| [k, get_value(k)]}.to_h
  s_params = params.map {|k, v| "#{k}=#{v}"}.join(' ')

  texec("sshpass -p PH_GEX_PASSWD1 ssh root@51.0.0.55  #{s_params} ruby /mount/ansible/cloud/use_ami/run_node.rb")

end