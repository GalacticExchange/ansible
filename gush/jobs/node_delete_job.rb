class NodeDeleteJob < Gush::Job
  def work
    Provision::Node.delete(params[:cluster_id], params[:node_id])
  end
end
