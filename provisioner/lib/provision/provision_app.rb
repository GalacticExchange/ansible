module Provision

  class ProvisionApp


    def self.run_remove_app(server_name, cluster_id, app_id)
      GEX_LOGGER.debug("Started configuration: #{server_name}")
      srv = Config.srv_host(server_name)
      ConsulUtils.lock_exec(cluster_id, server_name) {
        SSHKit::Coordinator.new(srv).each in: :sequence do
          execute("_cluster_id=#{cluster_id} _app_id=#{app_id} ruby /mount/ansible/templates/cluster/#{server_name}/remove_app.rb")
        end
      }
      GEX_LOGGER.debug("Finished configuration: #{server_name}")
    end


    def self.remove_app(cluster_id, app_id)
      GEX_LOGGER.set_cluster_id(cluster_id).set_app_id(app_id)
      GEX_LOGGER.info_start

      res = GexHelpers.run_task do

        ConsulUtils.connect(cluster_id)
        app_data = ConsulUtils.get_app_data(app_id)

        [:proxy, :webproxy, :openvpn].each do |srv|

          run_remove_app(srv, cluster_id, app_id)

        end

      end


      # notify
      event = res ? 'app_provision_removed' : 'app_provision_remove_error'
      Provision::Notification.notify_api_sidekiq(event, {app_id: app_id})

      # if res
      #   Provision::Notification.notify_app(app_id, 'app_provision_removed')
      # else
      #   Provision::Notification.notify_app(app_id, 'app_provision_remove_error')
      # end


    end


  end


end