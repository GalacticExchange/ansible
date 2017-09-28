#!/usr/bin/env ruby
require_relative 'local_utils'

safe_exec do


  cluster_id = ENV.fetch('_cluster_id')
  GEX_LOGGER.set_cluster_id(cluster_id).info_start

  parse_and_init('provisioner', cluster_id)




  if get_value('_cluster_type').to_s == "aws"

    GEX_LOGGER.debug('Entered aws block')

    texec "mkdir -p /mount/ansibledata/#{cluster_id}/credentials"
    texec "chmod 755  -R /mount/ansibledata/#{cluster_id}"


    ENV['_cluster_id'] = cluster_id
    ENV['_cluster_uid']= get_value('_cluster_uid')
    ENV['_aws_access_key_id'] = get_value('_aws_access_key_id')
    ENV['_aws_secret_key'] = get_value('_aws_secret_key')
    ENV['_aws_region'] = get_value('_aws_region')
    ENV['_gex_env'] = get_value('_gex_env')
    ENV['_cluster_name'] = get_value('_cluster_name')



    keys = ['_cluster_id', '_cluster_uid', '_aws_access_key_id', '_aws_secret_key', '_aws_region', '_gex_env', '_cluster_name']
    params = keys.map {|k| [k, get_value(k)]}.to_h

    s_params = params.map {|k, v| "#{k}=#{v}"}.join(' ')

    texec("sshpass -p PH_GEX_PASSWD1 ssh root@51.0.0.55  #{s_params} ruby /mount/ansible/cloud/use_ami/run_basic_configure.rb")
    GEX_LOGGER.debug('AWS core configured')

    texec("sshpass -p PH_GEX_PASSWD1 ssh root@51.0.0.55  #{s_params} ruby /mount/ansible/cloud/use_ami/run_coordinator.rb")
    GEX_LOGGER.debug('AWS coordinator configured')

    #require_relative '../../../cloud/use_ami/run_basic_configure'
    #require_relative '../../../cloud/use_ami/run_coordinator'


  end

  GEX_LOGGER.info_finish
end
