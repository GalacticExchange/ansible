class ClusterRemoveWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :provision, :retry => false

  def perform(cluster_id, cluster_type, env={})
    #require_relative '../lib/provision/provision_cluster'

    # set env
    #Gexcore::BaseService.set_env env

    #
    Provision::ProvisionCluster.remove_cluster(cluster_id, cluster_type, env)


    true
  end
end
