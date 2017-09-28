namespace :provision_ansible do

  desc 'create cluster'
  task :create_cluster, :p_ansible do  |task_name, p|
    ansible_params = p[:p_ansible]

    gex_env=fetch(:gex_env)
    gex_config = fetch(:gex_config)
    dir_clusters_data = gex_config[:dir_clusters_data]
    #dir_scripts = gex_config[:dir_scripts]
    dir_scripts = '/data/scripts'

    run_locally do
      #
      # ansible-playbook -i /var/www/ansible/inventory /var/www/ansible/create_cluster.yml -e ' _port_ssh=9967 _port_hadoop_resource_manager=9968 _port_hdfs=9969 _port_hdfs_namenode_webui=9970 _port_hue=9971 _port_spark_master_webui=9972 _port_spark_history=9973 _gex_env=main _cluster_id=403 _cluster_uid=1703515886910317 _cluster_type=onprem _cluster_name=jolly-lynx _cluster_id_hex=193 _hadoop_type=cdh _hadoop_type=cdh'
      execute %Q(ansible-playbook -i #{dir_scripts}inventory #{dir_scripts}create_cluster.yml #{ansible_params} )


    end
  end


end
