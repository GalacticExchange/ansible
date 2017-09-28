require_relative "../vagrant/base/ruby/deploy.rb"

$inited = true
$config = nil


def cluster (command)
  puts command
end

def config(config)

  if config == nil
    raise "Nil config"
  end
  $config = config
  puts "Config = #{config}"
end


begin
  puts "Loading Clusterfile ... "
  Kernel::load "Clusterfile"
  puts "Loaded Clusterfile\n"
  if $config == nil
    raise "Nil config"
  end
rescue LoadError
  $initinited = false
end


def get_config
  unless $inited
    puts "Uninitialized. Call rake init first."
    exit (-1)
  end
  if $config.nil?
    raise "Nil config"
  end
  return $config
end


def ansible(cmd)
  inventory = "inventory"
  if get_config != "main"
    inventory = "#{get_config}#{inventory}"
  end
  sh "ansible-playbook -v  -i ./#{inventory} " + cmd
end

def cap(cmd)
  sh "cd /mount/ansible/provisioner && #{cmd}"
end

desc "Create test cluster"
task :test_cluster, [:type] => [:clean_test_containers] do |task, args|
  args.with_defaults(type: "cdh")


  ansible "create_cluster.yml -e '_gex_env=prod _hadoop_type=#{args[:type]} _cluster_type=onprem _cluster_id=99 _cluster_id_hex=16 _cluster_name=cancer   _port_ssh=5001 _port_hue=57000 " + \
  "_port_spark_history=2173 _port_spark_master_webui=1739 _port_hadoop_resource_manager=57001 _port_hdfs=57002 _port_hdfs_namenode_webui=57003'"

  ansible "create_node.yml -e '_gex_env=prod _hadoop_type=#{args[:type]} _host_type=virtualbox _interface=" " _cluster_id=99 _cluster_id_hex=16 _cluster_name=cancer  _hadoop_master_ipv4=51.77.0.99 _node_uid=12345678 _cluster_uid=0987654321 _node_number=1 _node_ip6_address=FDE9:E9:E9:3:1:5:0:0/64 _node_port=5251  _node_name=sirius2 _openvpn_ip6_address=FD9E:9E:9E:0:0:1:8:0/64'"

  ssh_exec "kladko@10.1.0.14", "PH_GEX_PASSWD1", "mkdir -p /tmp/vagrant; rm -rf /tmp/vagrant/Vagrantfile"

  #scp("kladko@10.1.0.14", "PH_GEX_PASSWD1", "/mount/ansibledata/99/nodes/1/node/Vagrantfile", "/tmp/vagrant")


  ansible "add_app.yml -e ''_gex_env=prod _hadoop_type=#{args[:type]} _interface=" " _cluster_id=99 _cluster_id_hex=16 _cluster_name=cancer  _hadoop_master_ipv4=51.77.0.99 _node_uid=12345678 _cluster_uid=0987654321 _node_number=1 _node_ip6_address=FDE9:E9:E9:3:1:5:0:0/64 _node_port=5251  _node_name=sirius2 _app_name=rocana _source_port=1015 _dest_port=1016 _openvpn_ip6_address=FD9E:9E:9E:0:0:1:8:0/64'"

  #sh "ping -c 1 -W 10 51.77.0.99"
  #sh "ping -c 1 -W 10 51.78.0.99"

end

desc 'create test cluster cap'
task :test_cluster_cap => [:clean_test_containers_cap] do
  cluster_data = %Q({ "id": 99, "id_hex": "63", "name": "australe", "cluster_type": "onprem", "uid": "1711797893019526", "hadoop_type": "cdh", "port_elastic": 10191, "port_hadoop_resource_manager": 57001, "port_hdfs": 57002, "port_hdfs_namenode_webui": 57003, "port_hue": 57000, "port_spark_history": 56005, "port_spark_master_webui": 56004, "port_ssh": 5001 })
  cluster_id = 99
  gex_env = 'main'

  #cap("_cluster_data='#{cluster_data}' cap main provision:create_consul")
  cap("_cluster_id=#{cluster_id} _cluster_data='#{cluster_data}' _gex_env=#{gex_env} cap main provision:create_cluster")
end

desc 'create test node cap'
task :test_node_cap do
  node_data = %Q({ "cluster_id": 99, "uid": "12345678", "id": 11, "node_number": 1, "node_type": "onprem", "host_type": "virtualbox", "hadoop_type": "cdh", "name": "halk", "node_port": 5251, "node_ip6_address": null, "interface": "", "is_wifi": false, "proxy_ip": null, "static_ips": false, "gateway_ip": null, "network_mask": null, "container_ips": { "hadoop": null, "hue": null } })
  cap("_node_data='#{node_data}' cap main provision:create_node")
end


desc 'create test node cap parallel'
task :test_node_cap_parallel do
  node_data1 = %Q({ "cluster_id": 99, "uid": "12345678", "id": 11, "node_number": 1, "node_type": "onprem", "host_type": "virtualbox", "hadoop_type": "cdh", "name": "halk", "node_port": 5251, "node_ip6_address": null, "interface": "", "is_wifi": false, "proxy_ip": null, "static_ips": false, "gateway_ip": null, "network_mask": null, "container_ips": { "hadoop": null, "hue": null } })
  node_data2 = %Q({ "cluster_id": 99, "uid": "12345679", "id": 12, "node_number": 2, "node_type": "onprem", "host_type": "virtualbox", "hadoop_type": "cdh", "name": "halk2", "node_port": 5252, "node_ip6_address": null, "interface": "", "is_wifi": false, "proxy_ip": null, "static_ips": false, "gateway_ip": null, "network_mask": null, "container_ips": { "hadoop": null, "hue": null } })

  tr1 = Thread.new {
    cap("_node_data='#{node_data1}' cap main provision:create_node")
  }

  tr2 = Thread.new {
    cap("_node_data='#{node_data2}' cap main provision:create_node")
  }

  tr1.join
  tr2.join

end

desc 'add test app cap'
task :test_app_cap do
  app_data = %Q({"_cluster_id": 99, "_app_name": "datameer", "_app_id":123, "_node_id":11, "_ssh_port":5050 })
  cap("_app_data='#{app_data}' cap main provision:add_app")
end

desc 'test remove cluster cap'
task :test_remove_cluster_cap do
  cluster_id = 99
  cap("_cluster_id=#{cluster_id} cap main provision:remove_cluster")
end

desc 'test remove node cap'
task :test_remove_node_cap do
  cluster_id = 99
  node_id = 11

  cap("_cluster_id=#{cluster_id} _node_id=#{node_id} cap main provision:remove_node")
end


task :update_test_vagrant do |task, args|
  ssh_exec "kladko@10.1.0.14", "PH_GEX_PASSWD1", "mkdir -p /tmp/vagrant; rm -f /tmp/vagrant/Vagrantfile"
  scp("kladko@10.1.0.14", "PH_GEX_PASSWD1", "/mount/ansibledata/99/nodes/1/node/Vagrantfile", "/tmp/vagrant")
end

desc "Remove test custer"
task :remove_test_cluster, [:type] do |task, args|
  args.with_defaults(type: "cdh")

  ansible "remove_app.yml -e '_hadoop_type=#{args[:type]} _interface=" " _cluster_id=99 _cluster_id_hex=16 _cluster_name=cancer  _hadoop_master_ipv4=51.77.0.99 _node_uid=12345678 _cluster_uid=0987654321 _node_number=1 _node_ip6_address=FDE9:E9:E9:3:1:5:0:0/64 _node_port=5251  _node_name=sirius2 _app_name=rocana _source_port=1015 _dest_port=1016 _openvpn_ip6_address=FD9E:9E:9E:0:0:1:8:0/64'"

  ansible "remove_node.yml -e '_hadoop_type=#{args[:type]} _interface=" " _cluster_id=99 _cluster_id_hex=16 _cluster_name=cancer  _hadoop_master_ipv4=51.77.0.99 _node_uid=12345678 _cluster_uid=0987654321 _node_number=1 _node_ip6_address=FDE9:E9:E9:3:1:5:0:0/64 _node_port=5251 _host_type=virtualbox _node_name=sirius2 _openvpn_ip6_address=FD9E:9E:9E:0:0:1:8:0/64'"

  ansible "remove_cluster.yml -e '_hadoop_type=#{args[:type]} _cluster_id=99 _cluster_id_hex=16 _cluster_name=cancer   _port_ssh=5001 _port_hue=57000 _port_hadoop_resource_manager=57001 _port_hdfs=57002 _port_hdfs_namenode_webui=57003'"

end


#desc "Create test aws node"
#task :test_aws_cluster, [:type] => [:clean_test_containers] do |task, args|
#  args.with_defaults(type: "cdh")
#
#
#  ansible "create_cluster.yml -e '_hadoop_type=#{args[:type]} _cluster_id=98 _cluster_id_hex=16 _cluster_name=cancer2   _port_ssh=5001 _port_hue=57000 _port_hadoop_resource_manager=57011 _port_hdfs=57002 _port_hdfs_namenode_webui=57012'"
#
#  ansible "create_node.yml -e '_hadoop_type=#{args[:type]} _interface=" " _cluster_id=98 _cluster_id_hex=16 _cluster_name=cancer  _hadoop_master_ipv4=51.77.0.99 _node_uid=123456788 _cluster_uid=987654321 _node_number=1 _node_ip6_address=FDE9:E9:E9:3:1:5:0:0/64 _node_port=5251  _node_name=sirius2 _openvpn_ip6_address=FD9E:9E:9E:0:0:1:8:0/64'"
#
#
#  sh "ping -c 1 -W 10 51.77.0.98"
#  sh "ping -c 1 -W 10 51.78.0.98"
#
#end


desc "Remove test node"
task :remove_test_node, [:type] do |task, args|
  args.with_defaults(type: "cdh")
  ansible "remove_node.yml -e '_hadoop_type=#{args[:type]} _interface=" " _cluster_id=99 _cluster_id_hex=16 _cluster_name=cancer  _hadoop_master_ipv4=51.77.0.99 _node_uid=12345678 _cluster_uid=0987654321 _node_number=1 _node_ip6_address=FDE9:E9:E9:3:1:5:0:0/64 _node_port=5251  _node_name=sirius1 _openvpn_ip6_address=FD9E:9E:9E:0:0:1:8:0/64'"
end


desc "Create test node cdh"
task :test_node_cdh, :node_number do |task, args|

  ansible "create_node.yml -e '_hadoop_type=cdh  _host_type=virtualbox _interface=" " _cluster_id=99 _cluster_id_hex=16 _cluster_name=cancer  _hadoop_master_ipv4=51.77.0.99 _node_uid=12345678 _cluster_uid=0987654321 _node_number=#{args[:node_number]} _node_ip6_address=FDE9:E9:E9:3:1:5:0:0/64  _node_port=525#{args[:node_number]} _node_name=sirius _openvpn_ip6_address=FD9E:9E:9E:0:0:1:8:0/64'"

  ssh_exec "kladko@10.1.0.14", "PH_GEX_PASSWD1", "mkdir -p /tmp/vagrant"

  scp("kladko@10.1.0.14", "PH_GEX_PASSWD1",
      "/mount/ansibledata/99/nodes/#{args[:node_number]}/node/Vagrantfile", "/tmp/vagrant/")

end
desc 'Clean test containers cap'
task :clean_test_containers_cap do
  cap 'cap main provision:clean_test_containers'
end

desc "Clean test containers"
task :clean_test_containers do
  ansible "clean_test_containers.yml"
end

desc "Init main or prod "
task :init, :config do |task, args|
  File.open("Clusterfile", "w+") do |file|
    file.write "node config \"#{args[:config]}\""
  end
  puts "Inited Clusterfile"
end


desc "Deploy test node on cloud"
task :deploy_test_node_cloud, [:node_uid, :gex_token, :debug] do |task, args|
  ansible "create_node.yml -e '_hadoop_type=cdh  _host_type=dedicated _interface=" "  _port_hue=5431 _cluster_id=112  _cluster_name=cancer3  _hadoop_master_ipv4=51.77.0.112 _node_uid=#{args[:node_uid]} _cluster_uid=0987654321 _node_number=1 _node_type=aws _node_ip6_address=FDE9:E9:E9:3:1:5:0:0/64  _node_port=525#{args[:node_number]} _node_name=sirius _port_ssh=3456 _openvpn_ip6_address=FD9E:9E:9E:0:0:1:8:0/64'"
  ansible("create_node_aws_instance.yml -e ' _cluster_id=112 _instance_type=t2.medium _hadoop_type=cdh  _gex_env=main _node_agent_token=#{args[:gex_token]} _node_uid=#{args[:node_uid]} _debug=#{args[:debug]}'")
end

desc "Deploy second node on cloud"
task :deploy_second_node_cloud, [:node_uid, :gex_token, :debug] do |task, args|
  ansible("create_aws_cluster.yml -e '_cluster_id=113 _cluster_uid=113333 _gex_env=test _aws_region=us-west-2 _aws_access_key_id=PH_GEX_AWS_KEY _aws_secret_key=PH_GEX_AWS_ID'")
  ansible("create_node_aws_instance.yml -e '_cluster_id=113 _instance_type=t2.medium _hadoop_type=cdh _gex_env=main _node_agent_token=#{args[:gex_token]} _node_uid=#{args[:node_uid]} _debug=#{args[:debug]}'")
end

desc 'Destroy aws cluster'
task :destroy_aws_cluster, [:cluster_id] do |task, args|
  ansible("remove_cluster.yml -e '_cluster_id=#{args[:cluster_id]} _cluster_type=aws'")
end

desc 'Create test aws cluster'
task :test_aws_cluster do
  ansible(%Q(create_cluster.yml -e '{"_port_ssh":5002,"_port_hadoop_resource_manager":56001,"_port_hdfs":56002,"_port_hdfs_namenode_webui":56003,"_port_hue":56000,"_port_spark_master_webui":56004,"_port_spark_history":56005,"_gex_env":"main","_cluster_id":112,"_cluster_uid":"1234567890","_cluster_type":"aws","_cluster_name":"scary_indus","_cluster_id_hex":"70","_hadoop_type":"cdh","_aws_region":"us-east-1","_aws_access_key_id":"PH_GEX_AWS_KEY","_aws_secret_key":"PH_GEX_AWS_ID"}'))
end

desc 'Git pull'
task :pull do |task, args|
  ssh_cmd "vagrant@51.0.1.50", "PH_GEX_PASSWD1", "cd /var/www/ansible; git pull origin master"
  ssh_cmd "vagrant@51.0.1.50", "PH_GEX_PASSWD1", "cd /var/www/vagrant; git pull origin master"
end
