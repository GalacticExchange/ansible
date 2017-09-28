namespace :test do
namespace :provision do

  desc 'ruby'
  task :ruby do  |task_name|
    gex_env=fetch(:gex_env)
    gex_config = fetch(:gex_config)

    dir_scripts = gex_config[:dir_scripts]

    cluster_id = ENV['cluster_id']
    cluster_data = ENV['cluster_data']

    script = "#{dir_scripts}templates/cluster/openvpn/create_consul.rb"

    on roles(:master) do
      execute "which rvm"
      execute "which ruby"
      execute "ruby -v"
    end


  end

  desc 'init consul for new cluster'
  task :create_cluster_consul do  |task_name|
    gex_env=fetch(:gex_env)
    gex_config = fetch(:gex_config)

    dir_scripts = gex_config[:dir_scripts]

    cluster_id = ENV['cluster_id']
    cluster_data = ENV['cluster_data']

    script = "#{dir_scripts}templates/cluster/openvpn/create_consul.rb"

    on roles(:openvpn) do
      cmd = %Q(_cluster_id=#{cluster_id} _cluster_data='#{cluster_data}' ruby #{script})
      puts "cmd=#{cmd}"
      #exit
      #execute cmd
    end


  end


  #ansible-playbook -i /mount/ansible/prodinventory /mount/ansible/create_node.yml
  # -e '{"_gex_env":"prod","_cluster_id":55,"_cluster_uid":"1706817937835948","_cluster_name":"monoceros","_node_uid":"1706801773185477","_node_id":94,"_node_number":20,"_node_type":"aws","_host_type":"dedicated","_hadoop_type":"cdh","_hadoop_master_ipv4":"51.77.0.55","_node_name":"clean-canopus","_node_port":1118,"_node_ip6_address":null,"_interface":"","_is_wifi":false,"_proxy_ip":null,"_static_ips":false,"_gateway_ip":null,"_network_mask":null,"_container_ips":{"hadoop":null,"hue":null},"_port_ssh":5953,"_port_hue":5955,"_port_kibana":5956,"_port_elastic":5957}'

  desc 'create node'
  task :create_node do  |task_name|
    gex_env=fetch(:gex_env)
    gex_config = fetch(:gex_config)
    dir_clusters_data = gex_config[:dir_clusters_data]
    dir_scripts = gex_config[:dir_scripts]
    cluster_config_path = "#{dir_clusters_data}#{cluster_id}/webproxy_master.json"

    int_handler = {

    }

    on roles(:provisioner) do
      cmd = %Q(ansible-playbook -i /mount/ansible/inventory /mount/ansible/create_node.yml
   -e '{"_gex_env":"main","_cluster_id":99,"_cluster_uid":"1706817937835948","_cluster_name":"monoceros",
"_node_uid":"1706801773185477","_node_id":94,"_node_number":20,"_node_type":"aws","_host_type":"dedicated","_hadoop_type":"cdh","_hadoop_master_ipv4":"51.77.0.55","_node_name":"clean-canopus","_node_port":1118,"_node_ip6_address":null,"_interface":"","_is_wifi":false,"_proxy_ip":null,"_static_ips":false,"_gateway_ip":null,"_network_mask":null,"_container_ips":{"hadoop":null,"hue":null},"_port_ssh":5953,"_port_hue":5955,"_port_kibana":5956,"_port_elastic":5957}'
)
      execute cmd
    end


  end


  desc 'create node'
  task :create_node1 do  |task_name|
    gex_env=fetch(:gex_env)
    gex_config = fetch(:gex_config)
    dir_clusters_data = gex_config[:dir_clusters_data]
    dir_scripts = gex_config[:dir_scripts]

    cluster_id = 146

    nodes = []

    number =1

    p= %Q({"_gex_env":"main","_cluster_id":146,"_cluster_uid":"1706982553937619","_cluster_name":"proud-octans","_node_uid":"1706929652508004","_node_id":181,"_node_number":1,"_node_type":"aws","_host_type":"dedicated","_hadoop_type":"cdh","_hadoop_master_ipv4":"51.77.0.146","_node_name":"massive-gienah","_node_port":1205,"_node_ip6_address":null,"_interface":"","_is_wifi":false,"_proxy_ip":null,"_static_ips":false,"_gateway_ip":null,"_network_mask":null,"_container_ips":{"hadoop":null,"hue":null},"_port_ssh":6878,"_port_hue":6880,"_port_kibana":6881,"_port_elastic":6882})


    on roles(:provisioner) do
      cmd = %Q(cd #{dir_clusters_data}#{cluster_id}/nodes && chattr -i #{number} | true && rm -rf #{number} | true )
      execute cmd
    end



    on roles(:provisioner) do
      cmd = %Q(ansible-playbook -i /mount/ansible/inventory /mount/ansible/debug_create_node.yml  -e '#{p}')
      execute cmd
    end


  end

  desc 'create node'
  task :create_node2 do  |task_name|
    gex_env=fetch(:gex_env)
    gex_config = fetch(:gex_config)
    dir_clusters_data = gex_config[:dir_clusters_data]
    dir_scripts = gex_config[:dir_scripts]


    cluster_id = 146

    nodes = []

    number = 2
    p= %Q({"_gex_env":"main","_cluster_id":146,"_cluster_uid":"1706982553937619","_cluster_name":"proud-octans","_node_uid":"1706932282944620","_node_id":182,"_node_number":2,"_node_type":"aws","_host_type":"dedicated","_hadoop_type":"cdh","_hadoop_master_ipv4":"51.77.0.146","_node_name":"miniature-acrab","_node_port":1206,"_node_ip6_address":null,"_interface":"","_is_wifi":false,"_proxy_ip":null,"_static_ips":false,"_gateway_ip":null,"_network_mask":null,"_container_ips":{"hadoop":null,"hue":null},"_port_ssh":6883,"_port_hue":6885,"_port_kibana":6886,"_port_elastic":6887})



    on roles(:provisioner) do
      cmd = %Q(cd #{dir_clusters_data}#{cluster_id}/nodes && chattr -i #{number} | true && rm -rf #{number} | true )
      execute cmd
    end




    on roles(:provisioner) do
      cmd = %Q(ansible-playbook -i /mount/ansible/inventory /mount/ansible/debug_create_node.yml  -e '#{p}')
      execute cmd
    end


  end


  desc 'create node'
  task :create_nodes_parallel do  |task_name|
    gex_env=fetch(:gex_env)
    gex_config = fetch(:gex_config)
    dir_clusters_data = gex_config[:dir_clusters_data]
    dir_scripts = gex_config[:dir_scripts]
    #cluster_config_path = "#{dir_clusters_data}#{cluster_id}/webproxy_master.json"

    cluster_id = 146

    nodes = []

    nodes << {
        number: 1,
        p: %Q({"_gex_env":"main","_cluster_id":146,"_cluster_uid":"1706982553937619","_cluster_name":"proud-octans","_node_uid":"1706929652508004","_node_id":181,"_node_number":1,"_node_type":"aws","_host_type":"dedicated","_hadoop_type":"cdh","_hadoop_master_ipv4":"51.77.0.146","_node_name":"massive-gienah","_node_port":1205,"_node_ip6_address":null,"_interface":"","_is_wifi":false,"_proxy_ip":null,"_static_ips":false,"_gateway_ip":null,"_network_mask":null,"_container_ips":{"hadoop":null,"hue":null},"_port_ssh":6878,"_port_hue":6880,"_port_kibana":6881,"_port_elastic":6882})
    }

    nodes << {
        number: 2,
        p: %Q({"_gex_env":"main","_cluster_id":146,"_cluster_uid":"1706982553937619","_cluster_name":"proud-octans","_node_uid":"1706932282944620","_node_id":182,"_node_number":2,"_node_type":"aws","_host_type":"dedicated","_hadoop_type":"cdh","_hadoop_master_ipv4":"51.77.0.146","_node_name":"miniature-acrab","_node_port":1206,"_node_ip6_address":null,"_interface":"","_is_wifi":false,"_proxy_ip":null,"_static_ips":false,"_gateway_ip":null,"_network_mask":null,"_container_ips":{"hadoop":null,"hue":null},"_port_ssh":6883,"_port_hue":6885,"_port_kibana":6886,"_port_elastic":6887})
    }




    ### prepare
      on roles(:provisioner) do
        nodes.each do |node|
          cmd = %Q(cd #{dir_clusters_data}#{cluster_id}/nodes && chattr -i #{node[:number]} && rm -rf #{node[:number]} )
          (execute cmd) rescue nil
        end

      end


    puts "********** go ansible"

    #
    require 'parallel'

    Parallel.each(nodes) do |node|
    #nodes.each do |node|
      on roles(:provisioner) do

        cmd = %Q(ansible-playbook -i /mount/ansible/inventory /mount/ansible/debug_create_node.yml -e '#{node[:p]}')
        execute cmd
      end
    end


  end


end
end
