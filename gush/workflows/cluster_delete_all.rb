class ClusterDeleteAll < Gush::Workflow

  def configure(cluster_id, node_ids)

    job_ids_remove_node = []
    node_ids.each do |node_id|
      job_ids_remove_node << (run NodeRemoveJob, params: {cluster_id: cluster_id, node_id: node_id})
    end

    run ClusterRemoveJob, after: job_ids_remove_node, params: {cluster_id: cluster_id}

    #run Normalize,
    #after: [PersistJob1, PersistJob2],
    #before: Index

    #run Index
    #run ClusterRemoveJob, params: {cluster_id: cluster_id}
  end
end
