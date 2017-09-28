require_relative '../lib/consul_utils'

namespace :provision do


  def run_reload_nginx
    system('cd /mount/ansible/provisioner && bundle exec ruby run/reload_nginx.rb')
  end

  desc 'add application'
  task :add_app do
    #app_data = DataConverter.convert_app_data(ENV.fetch('_app_data'))
    #app_data = JSON.parse(ENV.fetch('_app_data',''))

    s_app_data = ENV.fetch('_app_data', '')
    cluster_id = ENV.fetch('_cluster_id')
    app_id = ENV.fetch('_app_id')

    unless s_app_data.empty?
      app_data = JSON.parse(s_app_data)
      ConsulUtils.update_app_data(cluster_id, app_data)
    end

    #TODO lock?
    [:openvpn, :proxy, :webproxy].each do |srv|
      on roles(srv) do
        execute("_cluster_id=#{cluster_id} _app_id=#{app_id} ruby /mount/ansible/templates/cluster/#{srv.to_s}/add_app.rb")
      end
    end

    run_reload_nginx

  end


  desc 'remove app'
  task :remove_app do

    app_id = ENV.fetch('_app_id')
    cluster_id = ENV.fetch('_cluster_id')

    ConsulUtils.connect(cluster_id)
    app_data = ConsulUtils.get_app_data(app_id)

    [:proxy, :webproxy, :openvpn].each do |srv|

      on roles(srv) do
        execute("_cluster_id=#{cluster_id} _app_id=#{app_id} ruby /mount/ansible/templates/cluster/#{srv.to_s}/remove_app.rb")
      end

    end

  end

  desc 'master install app'
  task :app_install_master do
    gex_env = ENV.fetch('_gex_env')
    app_id = ENV.fetch('_app_id')
    cluster_id = ENV.fetch('_cluster_id')

    # app data
    ConsulUtils.connect(cluster_id)
    app_data = ConsulUtils.get_app_data(app_id)
    app_config = ConsulUtils.get_app_data_config(app_id)
    cluster_data = ConsulUtils.get_cluster_data

    # first node
    node_id = app_data['containers'][0]['node_id']
    node_data = ConsulUtils.get_node_data node_id

    #puts "data: #{app_data}"
    #puts "cluster data: #{cluster_data}"
    #puts "node data: #{node_data}"


    app_basename = app_data['name']

    # recipe for master
    recipe_exist = true
    chef_dir = '/mount/chef-repo/'
    recipe_name = "#{app_basename}::master"
    filename_recipe = File.join(chef_dir, "cookbooks-apps/#{app_basename}/recipes", "master.rb")

    if !File.exist?(filename_recipe)
      recipe_exist = false
    end

    if !recipe_exist
      puts "recipe #{filename_recipe} not exist"

      # res - ok
      exit(0)
    end

    # app config
    file_config = "/mount/ansibledata/#{cluster_id}/applications/#{app_id}/config.json"
    File.write(file_config, JSON.pretty_generate(app_config))


    # chef
    chef_node_name = "master-#{cluster_id}"
    hadoop_master_ipv4 = node_data['_hadoop_master_ipv4'] || node_data['hadoop_master_ipv4']



    ssh_user = 'root'
    ssh_pwd = 'vagrant'

=begin
    source /etc/profile.d/rvm.sh
rvm list
ruby -v
which ruby

=end

    cmd = %Q(
    cd /mount/chef-repo/config-knife/master_node
    chef exec knife zero bootstrap #{hadoop_master_ipv4} --node-name #{chef_node_name} --overwrite --ssh-user #{ssh_user} --ssh-password #{ssh_pwd}
    chef exec knife zero converge "name:#{chef_node_name}" --json-attributes #{file_config}  --ssh-user #{ssh_user} --ssh-password #{ssh_pwd}  --override-runlist #{recipe_name} --ssh-user #{ssh_user} --ssh-password #{ssh_pwd}

    )

    puts "cmd=#{cmd}"

    Bundler.with_clean_env do
      sh "#{cmd}"
    end

    #run_locally do
    #  with rails_env: gex_env.to_sym do
    #    execute "#{cmd}"
    #  end
    #end
    #res = `#{cmd}`
    #puts "output: #{res}"
  end

  desc 'master uninstall app'
  task :app_uninstall_master do
    raise 'not used'

  end

end
