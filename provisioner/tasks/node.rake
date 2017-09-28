#require_relative '../lib/init'
require_relative '../lib/consul_utils'
require_relative '../../templates/cluster/common/gexcloud_utils'

namespace :provision do

  def run_create_node(role, cluster_id, node_id)
    on roles(role.to_sym) do
      execute ("_node_id='#{node_id}' _cluster_id=#{cluster_id} ruby /mount/ansible/templates/cluster/#{role}/create_node.rb")
    end
  end

  def run_create_node_first(role, cluster_id, node_id)
    on roles(role.to_sym) do
      execute ("_node_id='#{node_id}' _cluster_id=#{cluster_id} ruby /mount/ansible/templates/cluster/#{role}/create_node_first.rb")
    end
  end


  def start_disabled_containers(host, pswd, cluster_id)

    FRAMEWORKS.each do |f|
      texec("sshpass -p #{pswd} ssh root@#{host} rm -f /etc/systemd/system/#{f}-master-#{cluster_id}.disabled")
      texec("sshpass -p #{pswd} ssh root@#{host} systemctl start #{f}-master-#{cluster_id}")
    end

  end

  def run_reload_nginx
    system('cd /mount/ansible/provisioner && bundle exec ruby run/reload_nginx.rb')
  end

  desc 'create node'
  task :create_node do

    cluster_id = ENV.fetch('_cluster_id')
    node_id = ENV.fetch('_node_id')
    node_data = ENV.fetch('_node_data', nil)

    GEX_LOGGER.set_cluster_id(cluster_id).set_node_id(node_id)
    GEX_LOGGER.info_start

    ConsulUtils.connect(cluster_id)
    GEX_LOGGER.debug('Connected to consul')

    if node_data
      ConsulUtils.update_node_data(cluster_id, node_id, node_data)
      GEX_LOGGER.debug('Updated node_data')
    end

    roles(:master).each do |host|
      start_disabled_containers(host.hostname, host.password, cluster_id)
    end

    cluster_data = ENV.fetch('_cluster_data', '')
    unless cluster_data.empty?
      ConsulUtils.update_cluster_data(cluster_id, cluster_data)
      GEX_LOGGER.debug('Updated cluster_data')
    end


    GEX_LOGGER.before_line_debug
    ConsulUtils.lock_exec(cluster_id, 'openvpn') {
      run_create_node(:openvpn, cluster_id, node_id)
    }


    GEX_LOGGER.before_line_debug
    ConsulUtils.lock_exec(cluster_id, 'provisioner_first') {
      run_create_node_first(:provisioner, cluster_id, node_id)
    }

    GEX_LOGGER.before_line_debug
    ConsulUtils.lock_exec(cluster_id, 'provisioner') {
      run_create_node(:provisioner, cluster_id, node_id)
    }

    on [:master, :proxy, :webproxy], in: :parallel do |host|
      srv = host.to_s.to_sym

      GEX_LOGGER.debug("Parallel starting configuration: #{srv}")

      if srv == :webproxy
        run_create_node(srv, cluster_id, node_id)
      else
        ConsulUtils.lock_exec(cluster_id, srv.to_s) {
          run_create_node(srv, cluster_id, node_id)
        }

      end

      GEX_LOGGER.debug("Parallel finished configuration: #{srv}")
    end
    run_reload_nginx

    GEX_LOGGER.info_finish
  end


  desc 'remove_node'
  task :remove_node do
    cluster_id = ENV.fetch('_cluster_id')
    node_id = ENV.fetch('_node_id')

    GEX_LOGGER.set_cluster_id(cluster_id).set_node_id(node_id)
    GEX_LOGGER.info_start

    ConsulUtils.connect(cluster_id)
    node_data = ConsulUtils.get_node_data(node_id)
    cluster_data = ConsulUtils.get_cluster_data

    if node_data['_node_type'] == 'aws'
      GEX_LOGGER.debug('Entered AWS block')
      on roles(:provisioner) do
        execute("_cluster_id=#{cluster_id} _node_uid=#{node_data.fetch('_node_uid')} ruby /mount/ansible/cloud/use_ami/destroy_aws_node.rb")
      end
    end

    [:master, :proxy, :webproxy, :openvpn].each {|srv|
      GEX_LOGGER.debug("Started configuration: #{srv}")
      ConsulUtils.lock_exec(cluster_id, srv.to_s) {
        on roles(srv.to_sym) do
          execute("_cluster_id=#{cluster_id} _node_id=#{node_id} ruby /mount/ansible/templates/cluster/#{srv}/remove_node.rb")
        end
      }
      GEX_LOGGER.debug("Finished configuration: #{srv}")
    }

    on roles(:provisioner) do
      GEX_LOGGER.debug('Executing provisioner role')
      execute("_cluster_id=#{cluster_id} _node_id=#{node_id} _node_number=#{node_data.fetch('_node_number')} ruby /mount/ansible/templates/cluster/provisioner/remove_node.rb")
    end
    GEX_LOGGER.info_finish
  end


  desc 'create node aws instance'
  task :create_node_aws_instance do

    cluster_id = ENV.fetch('_cluster_id')
    node_id = ENV.fetch('_node_id')

    ConsulUtils.connect(cluster_id)

    node_data = ENV.fetch('_node_data', nil)
    if node_data
      ConsulUtils.update_node_data(cluster_id, node_id, node_data)
      GEX_LOGGER.debug('Updated node_data')
    end

    on roles(:provisioner) do
      execute("_cluster_id=#{cluster_id} _node_id=#{node_id} ruby /mount/ansible/templates/cluster/provisioner/create_node_aws_instance.rb")
    end

  end

  desc 'change aws node state'
  task :change_aws_node_state do
    cluster_id = ENV.fetch('_cluster_id')
    node_id = ENV.fetch('_node_id')
    #node_uid = ENV.fetch('_node_uid')
    #action = ENV.fetch('_action')

    ConsulUtils.connect(cluster_id)

    node_data = ConsulUtils.get_node_data(node_id)
    ENV['_node_uid'] = node_data.fetch('_node_uid')

    require_relative '../../cloud/use_ami/change_node_state'

  end


  desc 'test kafka log'
  task :kafka_test do
    GEX_LOGGER.debug('Ztest')
  end


  desc 'test start master'
  task :start_master_test do
    cluster_id = 415

    roles(:master).each do |host|
      puts host.inspect

      start_disabled_containers(host.hostname, host.password, cluster_id)
    end
  end

end
