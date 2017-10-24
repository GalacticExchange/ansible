module Provision
  class Cluster

    PROVISION_REPO = File.absolute_path(File.join(File.dirname(__FILE__), '../../../provision'))

    def self.create(cluster_id, s_cluster_data, env={})
      script_path = File.join(PROVISION_REPO, 'cluster_create.rb')
      res = system("gex_env=main cluster_id=#{cluster_id} cluster_data=#{s_cluster_data} ruby #{script_path}")

      event = res ? 'cluster_provision_created' : 'cluster_provision_create_error'

      p event
    end

  end
end

# Provision::Cluster.create(123, '{}')