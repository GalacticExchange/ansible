docker_exec 'remove supervisor service' do
  host "tcp://#{node.env_default['openvpn']}:2375"
  container 'gexcore-openvpn'
  command ['bash', '-c', "rm /etc/supervisor/conf.d/consul_#{node['attributes'].fetch('cluster_id')}.conf"]
end

docker_exec 'supervisor reread and update' do
  host "tcp://#{node.env_default['openvpn']}:2375"
  container 'gexcore-openvpn'
  command ['bash', '-c', 'supervisorctl reread && supervisorctl update']
end