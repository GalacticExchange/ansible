class NodeRemoveJob < Gush::Job
  def work
    #%x(touch /projects/ansible/provisioner/tmp/remove_node.txt)
    Provision::ProvisionNode.remove_node(params[:cluster_id], params[:node_id], )
  end
end
