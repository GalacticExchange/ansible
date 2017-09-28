require_relative '../lib/consul_utils'

namespace :provision do

  desc 'restart container'
  task :container_restart do
    cluster_id = ENV.fetch('_cluster_id')
    container_id = ENV.fetch('_container_id')



  end

  desc 'start container'
  task :container_start do
    cluster_id = ENV.fetch('_cluster_id')
    container_id = ENV.fetch('_container_id')



  end

  desc 'stop container'
  task :container_stop do
    cluster_id = ENV.fetch('_cluster_id')
    container_id = ENV.fetch('_container_id')



  end

end


