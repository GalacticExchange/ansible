class NodeRemoveAllWorkflow < Gush::Workflow

  def configure(node_id)
    raise 'not used'

    run NodeRemoveJob, after: child_job_ids, params: {node_id: node_id}

  end
end
