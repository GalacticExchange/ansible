class ClusterCreateWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :provision, :retry => false

  def perform(cluster_id, s_cluster_data, env={})

    Provision::ProvisionCluster.create_cluster(cluster_id, s_cluster_data, env)

    true

  end
end
