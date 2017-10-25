class ClusterCreateWorkflow < Gush::Workflow

  def configure(cluster_id, cluster_data)
    run ClusterCreateJob, params: {cluster_id: cluster_id, cluster_data: cluster_data}
  end

end
