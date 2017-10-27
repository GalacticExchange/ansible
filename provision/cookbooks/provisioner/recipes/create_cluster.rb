docker_exec 'create cluster and nodes directory' do
  host "tcp://#{node.env_default['provisioner']}:2375"
  container 'gexcore-provisioner'
  command ['mkdir', '-p', "/data/clusters/#{node['attributes'].fetch('cluster_id')}/nodes"]
end


