namespace :provision do

  desc 'change cluster state'
  task :change_cluster_state do
    cluster_id = ENV.fetch('_cluster_id')
    action=ENV.fetch('_action') #start/stop

    on roles(:provisioner) do
      execute ("_cluster_id=#{cluster_id} _action=#{action} ruby /mount/ansible/cloud/use_ami/change_cluster_state.rb")
    end

  end

end