class NodeCreateWorkflow < Gush::Workflow

  def configure(cluster_id, cluster_data)
    run NodeCreateJob, params: {cluster_id: cluster_id, node_data: cluster_data}
  end

end
