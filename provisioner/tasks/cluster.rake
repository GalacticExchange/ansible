require_relative '../lib/consul_utils'
require_relative '../lib/data_converter'

require_relative '../../templates/cluster/common/gexcloud_utils'

namespace :provision do

  SERVERS = [:master, :proxy, :webproxy, :provisioner]

  def run_reload_nginx
    system('cd /mount/ansible/provisioner && bundle exec ruby run/reload_nginx.rb')
    GEX_LOGGER.debug('nginx reloaded')
  end

  desc 'create cluster'
  task :create_cluster do
    cluster_id = ENV.fetch('_cluster_id')
    cluster_data = DataConverter.convert_cluster_data(ENV.fetch('_cluster_data'), ENV.fetch('_gex_env'))

    GEX_LOGGER.set_cluster_id(cluster_id)
    on roles(:openvpn) do
      execute("_cluster_id=#{cluster_id} ruby /mount/ansible/templates/cluster/openvpn/create_consul.rb")
    end
    GEX_LOGGER.debug('Consul created')


    ConsulUtils.update_cluster_data(cluster_id, cluster_data)

    on roles(:provisioner) do
      execute ("_cluster_id=#{cluster_id} ruby /mount/ansible/templates/cluster/provisioner/create_cluster_first.rb")
    end
    GEX_LOGGER.debug('create_cluster_first passed')

    on roles(:openvpn) do
      execute(%Q(_cluster_id=#{cluster_id} ruby /mount/ansible/templates/cluster/openvpn/create_cluster.rb))
    end
    GEX_LOGGER.debug('openvpn passed')


    SERVERS.each {|srv|
      on roles(srv) do
        execute ("_cluster_id=#{cluster_id} ruby /mount/ansible/templates/cluster/#{srv.to_s}/create_cluster.rb")
      end
      GEX_LOGGER.debug("#{srv} configured")

    }

    run_reload_nginx
  end

  #desc 'create consul'
  #task :create_consul do

  #  on roles(:openvpn) do
  #    execute(%Q(_cluster_data='#{ENV.fetch('_cluster_data')}' ruby /mount/ansible/templates/cluster/openvpn/create_consul.rb))
  #  end

  #end

  desc 'remove_cluster'
  task :remove_cluster do
    cluster_id = ENV.fetch('_cluster_id')
    cluster_type = ENV.fetch('_cluster_type')

    #ConsulUtils.connect(cluster_id)
    #cluster_data = JSON.parse(ConsulUtils.get_cluster_data)

    [:master, :proxy, :webproxy, :openvpn].each do |srv|
      on roles(srv) do
        #execute("source /etc/profile.d/rvm.sh && _cluster_id=#{cluster_id} ruby /mount/ansible/templates/cluster/#{srv.to_s}/remove_cluster.rb")
        execute("_cluster_id=#{cluster_id} ruby /mount/ansible/templates/cluster/#{srv.to_s}/remove_cluster.rb")
      end
    end

    on roles(:provisioner) do
      #execute("source /etc/profile.d/rvm.sh && _cluster_id=#{cluster_id} _cluster_type=#{cluster_type} ruby /mount/ansible/templates/cluster/provisioner/remove_cluster.rb")
      execute("_cluster_id=#{cluster_id} _cluster_type=#{cluster_type} ruby /mount/ansible/templates/cluster/provisioner/remove_cluster.rb")
    end

  end


  desc 'change master state'
  task :change_master_container_state do
    cluster_id = ENV.fetch('_cluster_id')
    action = ENV.fetch('_action')
    app_name = ENV.fetch('_app_name')

    on roles(:master) do
      execute("sudo service #{app_name}-master-#{cluster_id} #{action}")
    end

  end


  desc 'test task'
  task :test_task do

    on roles(:openvpn) do
      execute("echo #{Time.now} > /tmp/test_cap_task")
    end

  end

  desc 'test task'
  task :test_task_fail do

    on roles(:openvpn) do
      execute('fail')
    end

  end


  desc 'remove cluster all'
  task :remove_cluster_all do

    cluster_id = ENV.fetch('_cluster_id')
    #node_ids = JSON.parse(ENV.fetch('_node_ids'))
    #app_ids = JSON.parse(ENV.fetch('_app_ids'))

    require 'parallel'

    basic_cmd = 'source /etc/profile.d/rvm.sh; cd /mount/ansible/provisioner'
    gex_env = fetch(:gex_env)

    #TODO fetch node_ids and cluster_ids from consul keys
    ConsulUtils.connect(cluster_id)

    cluster_type = ConsulUtils.get_cluster_data.fetch('_cluster_type')

    nodes_ids = divide_arr(ConsulUtils.get_nodes_ids, 5)
    apps_ids = divide_arr(ConsulUtils.get_apps_ids, 5)
    p nodes_ids
    p apps_ids

    #exit 0
    apps_ids.each {|group|
      Parallel.each(group) {|id|
        puts "Removing app: #{id}"
        cmd = "#{basic_cmd} && _gex_env=#{gex_env} _cluster_id=#{cluster_id} _app_id=#{id} bundle exec cap main provision:remove_app"
        system(cmd)
        puts "Finished removing app: #{id}"
      }
    }

    nodes_ids.each {|group|
      Parallel.each(group) {|id|
        puts "Removing node: #{id}"
        cmd = "#{basic_cmd} && _gex_env=#{gex_env} _cluster_id=#{cluster_id} _node_id=#{id} bundle exec cap main provision:remove_node"
        system(cmd)
        puts "Finished removing node: #{id}"
      }
    }


    puts 'Removing cluster core'
    cmd = "#{basic_cmd} && _gex_env=#{gex_env} _cluster_id=#{cluster_id} _cluster_type=#{cluster_type} bundle exec cap main provision:remove_cluster"
    system(cmd)
    puts 'Finished removing cluster core'

  end


  def divide_arr(arr, mod)
    split_arr = [[]]

    j = 0

    arr.each_with_index {|e, index|

      if index % mod == 0 && index != 0
        j = j +1
        split_arr[j] = []
      end

      split_arr[j].push(e)
    }

    split_arr

  end

end
