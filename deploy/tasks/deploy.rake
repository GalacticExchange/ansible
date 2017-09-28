namespace :deploy do

  desc 'deploy'
  task :deploy do
    gex_config = fetch(:gex_config)
    gex_env = fetch(:gex_env)
    dir_data = gex_config[:dir_data]

    dir_data = '/mount/'

    u = fetch(:host_user) || 'gex'
    u = 'gex'

    git_tag = fetch(:git_tag) || 'origin/master'

    on roles(:mainhost) do
    #on roles(:provisioner) do
      #as user: u do
        execute 'whoami'

        execute "docker exec gex-provisioner bash -c 'cd #{dir_data}ansible && git fetch && git reset --hard #{git_tag}' "
        execute "docker exec gex-provisioner bash -c 'cd #{dir_data}vagrant && git fetch && git reset --hard #{git_tag}' "
        #execute "cd #{dir_data}ansible/provisioner && bundle i"
        execute "docker exec gex-provisioner bash -c 'cd #{dir_data}ansible/provisioner && bundle i' "
       # execute "cd #{dir_data}ansible && git fetch && git pull -s recursive -X theirs origin master"
       # execute "cd #{dir_data}vagrant && git fetch && git pull -s recursive -X theirs origin master"


        # data_bags
        #execute "cd #{dir_data}scripts && rm -rf data_bags && mv data_bags_#{gex_env} data_bags"


        # fix permissions
        #execute "cd #{dir_data}scripts && chown #{u}:#{u} -R .git"

      #end
    end
  end

end
