class NodeDeleteWorkflow < Gush::Workflow

  def configure(cluster_id, node_id)
    run NodeDeleteJob, params: {cluster_id: cluster_id, node_id: node_id}
  end

end
