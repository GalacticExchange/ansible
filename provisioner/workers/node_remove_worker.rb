class NodeRemoveWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :provision, :retry => false

  def perform(cluster_id, node_id, env={})
    # set env
    #Gexcore::BaseService.set_env env

    #
    Provision::ProvisionNode.remove_node(cluster_id, node_id, env)


    return true
  end
end
