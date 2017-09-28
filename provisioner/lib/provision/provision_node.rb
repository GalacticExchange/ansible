module Provision
  class ProvisionNode

    def self.run_create_node(server_name, cluster_id, node_id)
      require_relative '../../../templates/cluster/provisioner/local_utils'

      ##
      GEX_LOGGER.debug("Started configuration: #{server_name}")
      srv = Config.srv_host(server_name)

      ConsulUtils.lock_exec(cluster_id, server_name) {
        SSHKit::Coordinator.new(srv).each in: :sequence do
          execute ("_node_id='#{node_id}' _cluster_id=#{cluster_id} ruby /mount/ansible/templates/cluster/#{server_name}/create_node.rb")
        end
      }
      GEX_LOGGER.debug("Finished configuration: #{server_name}")
    end


    def self.run_create_node_parallel(server_names, cluster_id, node_id)
      srvs = server_names.map {|server_name| Config.srv_host(server_name)}

      SHKit::Coordinator.new(srvs).each in: :parallel do |srv|
        server_name = Config.srv_hosts.key(srv)
        GEX_LOGGER.debug("Parallel starting configuration: #{server_name}")

        ConsulUtils.lock_exec(cluster_id, server_name) {
          execute("_node_id=#{node_id} _cluster_id=#{cluster_id} ruby /mount/ansible/templates/cluster/#{server_name}/create_node.rb")
        }

        GEX_LOGGER.debug("Parallel finished configuration: #{server_name}")
      end


    end

    def self.run_create_node_first(server_name, cluster_id, node_id)
      GEX_LOGGER.debug("Started configuration: #{server_name}")
      srv = Config.srv_host(server_name)

      SSHKit::Coordinator.new(srv).each in: :sequence do
        execute ("_node_id='#{node_id}' _cluster_id=#{cluster_id} ruby /mount/ansible/templates/cluster/#{server_name}/create_node_first.rb")
      end
      GEX_LOGGER.debug("Finished configuration: #{server_name}")
    end


    def self.run_remove_node(server_name, cluster_id, node_id, node_number = 'empty')
      GEX_LOGGER.debug("Started configuration: #{server_name}")
      srv = Config.srv_host(server_name)
      ConsulUtils.lock_exec(cluster_id, server_name) {
        SSHKit::Coordinator.new(srv).each in: :sequence do
          execute("_cluster_id=#{cluster_id} _node_id=#{node_id} _node_number=#{node_number} ruby /mount/ansible/templates/cluster/#{server_name}/remove_node.rb")
        end
      }
      GEX_LOGGER.debug("Finished configuration: #{server_name}")
    end

    def self.run_remove_aws_node(cluster_id, node_uid)
      GEX_LOGGER.debug('Removing aws instance..')
      ENV['_cluster_id'] = cluster_id.to_s
      ENV['_node_uid'] = node_uid.to_s

      system ("_cluster_id=#{cluster_id} _node_uid=#{node_uid} ruby #{File.join(File.dirname(__FILE__), '../../../cloud/use_ami/destroy_aws_node.rb')}")
    end


    def self.start_disabled_containers(host, pswd, cluster_id)

      FRAMEWORKS.each do |f|
        texec("sshpass -p #{pswd} ssh root@#{host} rm -f /etc/systemd/system/#{f}-master-#{cluster_id}.disabled")
        texec("sshpass -p #{pswd} ssh root@#{host} systemctl start #{f}-master-#{cluster_id}")
      end

    end


    def self.create_node(cluster_id, node_id, node_data = nil)

      GEX_LOGGER.set_cluster_id(cluster_id).set_node_id(node_id)
      GEX_LOGGER.info_start

      res = GexHelpers.run_task do
        ConsulUtils.connect(cluster_id)
        GEX_LOGGER.debug('Connected to consul')

        if node_data
          ConsulUtils.update_node_data(cluster_id, node_id, node_data)
          GEX_LOGGER.debug('Updated node_data')
        end

        SSHKit::Coordinator.new(Config.srv_host('master')).each in: :sequence do |host|
          start_disabled_containers(host.hostname, host.password, cluster_id)
        end

        if ENV['_cluster_data']
          ConsulUtils.update_cluster_data(cluster_id, ENV['_cluster_data'])
          GEX_LOGGER.debug('Updated cluster_data')
        end

        GEX_LOGGER.before_line_debug
        run_create_node('openvpn', cluster_id, node_id)

        GEX_LOGGER.before_line_debug
        run_create_node_first('provisioner', cluster_id, node_id)

        GEX_LOGGER.before_line_debug
        run_create_node('provisioner', cluster_id, node_id)

        run_create_node_parallel(['master', 'proxy', 'webproxy'], cluster_id, node_id)

        Provision::Webproxy.reload_nginx_async

      end


      # notify
      event = res ? 'node_provision_created' : 'node_provision_create_error'
      Provision::Notification.notify_api_sidekiq(event, {node_id: node_id})

      # if res
      #   Provision::Notification.notify_node(node_id, 'node_provision_created')
      # else
      #   Provision::Notification.notify_node(node_id, 'node_provision_create_error')
      # end

      GEX_LOGGER.info_finish

    end


    def self.remove_node(cluster_id, node_id, env={})
      GEX_LOGGER.set_cluster_id(cluster_id).set_node_id(node_id)
      GEX_LOGGER.info_start

      res = GexHelpers.run_task do
        puts "#{Time.now} node removing... #{node_id}"

        ConsulUtils.connect(cluster_id)
        node_data = ConsulUtils.get_node_data(node_id)
        cluster_data = ConsulUtils.get_cluster_data

        puts "NODE_TYPE: #{node_data['_node_type']}"
        if node_data['_node_type'] == 'aws'
          puts 'Entered AWS block'
          GEX_LOGGER.debug('Entered AWS block')
          run_remove_aws_node(cluster_id, node_data.fetch('_node_uid'))
          puts 'Exiting AWS block'
        end

        ['master', 'proxy', 'webproxy', 'openvpn', 'provisioner'].each {|server_name|
          run_remove_node(server_name, cluster_id, node_id, node_data.fetch('_node_number'))
        }

        puts "#{Time.now} node removed. #{node_id}"

        Provision::Webproxy.reload_nginx_async

      end

      # notify
      event = res ? 'node_provision_uninstalled' : 'node_provision_uninstall_error'
      Provision::Notification.notify_api_sidekiq(event, {node_id: node_id})

      # if res
      #   Provision::Notification.notify_node(node_id, 'node_provision_uninstalled')
      # else
      #   Provision::Notification.notify_node(node_id, 'node_provision_uninstall_error')
      # end

      GEX_LOGGER.info_finish

      res
    end

    def self.change_aws_node_state(cluster_id, node_id, action)
      # init data
      ConsulUtils.connect(cluster_id)

      node_data = ConsulUtils.get_node_data(node_id)

      # work
      require_relative '../../../cloud/use_ami/lib/node'

      action = 'reboot' if action == 'restart'

      puts "do action with node: #{action}, data: #{node_data}"
      #node = Node.instantiate(cluster_id, node_data['uid'])
      #node.change_instance_state(action)

      res = true

      # notify
      event = res ? 'node_aws_state_changed' : 'node_aws_state_change_error'
      Provision::Notification.notify_api_sidekiq(event, {node_id: node_id})

      # if res
      #   Provision::Notification.notify_node(node_id, 'node_aws_state_changed')
      # else
      #   Provision::Notification.notify_node(node_id, 'node_aws_state_change_error')
      # end

      return res
    end


  end
end
