class NodeCreateJob < Gush::Job
  def work
    Provision::Node.create(params[:cluster_id], params[:node_data])
  end
end
