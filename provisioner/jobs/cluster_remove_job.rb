class ClusterRemoveJob < Gush::Job
  def work
    Provision::ProvisionCluster.remove_cluster(params[:cluster_id], params[:env])
  end
end
