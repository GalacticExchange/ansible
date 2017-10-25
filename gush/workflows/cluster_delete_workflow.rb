class ClusterDeleteWorkflow < Gush::Workflow

  def configure(cluster_id, cluster_data)
    run ClusterDeleteJob, params: {cluster_id: cluster_id}
  end
end
