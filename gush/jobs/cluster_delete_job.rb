class ClusterDeleteJob < Gush::Job
  def work
    Provision::Cluster.delete(params[:cluster_id])
  end
end
