class ClusterCreateJob < Gush::Job
  def work
    Provision::ProvisionCluster.create_cluster(params[:cluster_id], params[:cluster_data])
  end
end
