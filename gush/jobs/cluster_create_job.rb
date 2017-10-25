class ClusterCreateJob < Gush::Job
  def work
    Provision::Cluster.create(params[:cluster_id], params[:cluster_data])
  end
end
