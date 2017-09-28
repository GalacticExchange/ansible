class ProvisionChangeAwsNodeStateWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'provision', retry: 5


  def perform(cluster_id, node_id, action)
    Provision::ProvisionNode.change_aws_node_state(cluster_id, node_id, action)
  end

end

