namespace :test do
namespace :provision do


  desc 'TEST create cluster'
  task :create_cluster do  |task_name|
    #ansible_params = p[:p_ansible]

    gex_env=fetch(:gex_env)
    gex_config = fetch(:gex_config)
    dir_clusters_data = gex_config[:dir_clusters_data]
    #dir_scripts = gex_config[:dir_scripts]
    dir_scripts = '/mount/ansible'

    #on roles(:provisioner) do
    on roles(:mainhost) do
      within dir_scripts do
        #execute %Q(cd #{dir_scripts} && sh create_test_cluster.sh)
        #execute :rake, 'create_test_cluster[cdh]'
        execute %Q(docker exec gex-provisioner bash -c 'cd /mount/ansible && rake test_cluster[cdh]')
      end
    end
  end


end
end
