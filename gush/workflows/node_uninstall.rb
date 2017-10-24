class NodeUninstall < Gush::Workflow

  def configure(cluster_id, node_id)

    run  NodeRemoveJob, params: {cluster_id: cluster_id, node_id: node_id}

    #run Normalize,
    #after: [PersistJob1, PersistJob2],
    #before: Index

    #run Index
    #run ClusterRemoveJob, params: {cluster_id: cluster_id}
  end
end
