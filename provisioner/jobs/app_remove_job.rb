class AppRemoveJob < Gush::Job
  def work
    #%x(touch /projects/ansible/provisioner/tmp/remove_node.txt)
    Provision::ProvisionApp.remove_app(params[:cluster_id], params[:app_id] )
  end
end