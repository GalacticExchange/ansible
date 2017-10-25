module Provision
  class Cluster

    PROVISION_REPO = File.absolute_path(File.join(File.dirname(__FILE__), '../../../provision'))

    def self.create(cluster_id, s_cluster_data, env={})
      script_path = File.join(PROVISION_REPO, 'run/cluster/create.rb')
      res = system("gex_env=main cluster_id=#{cluster_id} cluster_data=#{s_cluster_data} ruby #{script_path}")

      event = res ? 'cluster_provision_created' : 'cluster_provision_create_error'

      Provision::Notification.notify_api_sidekiq(event, {cluster_id: cluster_id})

    end


    def self.delete(cluster_id)
      script_path = File.join(PROVISION_REPO, 'run/cluster/delete.rb')
      res = system("gex_env=main cluster_id=#{cluster_id} ruby #{script_path}")

      event = res ? 'cluster_provision_deleted' : 'cluster_provision_delete_error'

      Provision::Notification.notify_api_sidekiq(event, {cluster_id: cluster_id})
    end

  end
end
