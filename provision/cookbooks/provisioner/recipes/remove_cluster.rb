docker_exec 'remove cluster directory' do
  host "tcp://#{node.env_default['openvpn']}:2375"
  container 'gexcore-openvpn'
  command ['bash', '-c', "rm -rf /data/clusters/#{node['attributes'].fetch('cluster_id')}"]
end