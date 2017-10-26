module Provision
  class Node

    PROVISION_REPO = File.absolute_path(File.join(File.dirname(__FILE__), '../../../provision'))

    def self.create(cluster_id, s_node_data, env={})
      script_path = File.join(PROVISION_REPO, 'run/node/create.rb')
      res = system("gex_env=main cluster_id=#{cluster_id} node_data=#{s_node_data} ruby #{script_path}")

      event = res ? 'node_provision_created' : 'node_provision_create_error'

      Provision::Notification.notify_api_sidekiq(event, {cluster_id: cluster_id})

    end


    def self.delete(cluster_id, node_id)
      script_path = File.join(PROVISION_REPO, 'run/node/delete.rb')
      res = system("gex_env=main cluster_id=#{cluster_id} node_id=#{node_id} ruby #{script_path}")

      event = res ? 'cluster_provision_deleted' : 'cluster_provision_delete_error'

      Provision::Notification.notify_api_sidekiq(event, {cluster_id: cluster_id})
    end

  end
end
