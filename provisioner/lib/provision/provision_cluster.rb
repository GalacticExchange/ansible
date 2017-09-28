module Provision
  class ProvisionCluster


    def self.run_create_cluster(server_name, cluster_id)
      #_gex_env=#{Config.gexcloud_env}
      GexHelpers.run_remote_cmd(server_name, "_cluster_id=#{cluster_id} ruby /mount/ansible/templates/cluster/#{server_name}/create_cluster.rb")
    end


    def self.remove_cluster(cluster_id, env={})
      require_relative '../../../templates/cluster/provisioner/local_utils'

      puts "#{Time.now}. removing cluster ... #{cluster_id}"

      res = GexHelpers.run_task do

        ConsulUtils.connect(cluster_id)
        cluster_type = ConsulUtils.get_cluster_data['_cluster_type']

        puts "!!!!!!!!!!!!! CLUSTER_TYPE: #{cluster_type}"

        if cluster_type.to_s == 'aws'
          ENV['_cluster_id'] = "#{cluster_id}"
          #require_relative '../../../cloud/use_ami/destroy_aws_cluster'
          system("_cluster_id=#{cluster_id} ruby #{File.join(File.dirname(__FILE__), '../../../cloud/use_ami/destroy_aws_cluster.rb')}")
        end


        ['master', 'proxy', 'webproxy', 'openvpn'].each do |server_name|

          srv = Config.srv_host(server_name)

          SSHKit::Coordinator.new(srv).each in: :sequence do
            execute("_cluster_id=#{cluster_id} ruby /mount/ansible/templates/cluster/#{server_name}/remove_cluster.rb")
          end
        end

        FileUtils.rm_rf cluster_data_dir(cluster_id)

      end

      # notify
      event = res ? 'cluster_provision_uninstalled' : 'cluster_provision_uninstall_error'
      Provision::Notification.notify_api_sidekiq(event, {cluster_id: cluster_id})

      # if res
      #   Provision::Notification.notify_cluster(cluster_id, 'cluster_provision_uninstalled')
      # else
      #   Provision::Notification.notify_cluster(cluster_id, 'cluster_provision_uninstall_error')
      # end


      puts "#{Time.now}. cluster REMOVED. #{cluster_id}"
    end


    def self.create_cluster(cluster_id, s_cluster_data, env={})
      res = GexHelpers.run_task do
        GEX_LOGGER.debug_msg("creating cluster. #{cluster_id}")

        ### consul
        cluster_data = DataConverter.convert_cluster_data(s_cluster_data, Config.gex_env)

        GexHelpers.run_remote_cmd('openvpn', "_cluster_id=#{cluster_id} ruby /mount/ansible/templates/cluster/openvpn/create_consul.rb")

        ConsulUtils.update_cluster_data(cluster_id, cluster_data)

        ###
        GexHelpers.run_remote_cmd('provisioner', "_cluster_id=#{cluster_id} ruby /mount/ansible/templates/cluster/provisioner/create_cluster_first.rb")

        run_create_cluster('openvpn', cluster_id)

        #this can be executed in parallel
        ['master', 'proxy', 'webproxy', 'provisioner'].each {|srv|
          run_create_cluster(srv, cluster_id)
        }

        Provision::Webproxy.reload_nginx_async

        GEX_LOGGER.debug_msg("create cluster - FINISHED. #{cluster_id}")
      end

      # notify
      event = res ? 'cluster_provision_created' : 'cluster_provision_create_error'
      Provision::Notification.notify_api_sidekiq(event, {cluster_id: cluster_id})

      # if res
      #   Provision::Notification.notify_cluster(cluster_id, 'cluster_provision_created')
      # else
      #   Provision::Notification.notify_cluster(cluster_id, 'cluster_provision_create_error')
      # end

    end


  end
end
