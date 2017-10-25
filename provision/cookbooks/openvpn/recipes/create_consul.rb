# docker_exec 'create consul logs directory' do
#   host "tcp://#{node.env_default['openvpn']}:2375"
#   container 'gexcore-openvpn'
#   command ['mkdir', '-p', '/data/consul_logs']
# end

docker_exec 'remove supervisor service if exists' do
  host "tcp://#{node.env_default['openvpn']}:2375"
  container 'gexcore-openvpn'
  ignore_failure true
  command ['bash', '-c', "rm /etc/supervisor/conf.d/consul_#{node['attributes'].fetch('cluster_id')}.conf"]
end

docker_exec 'supervisor reread' do
  host "tcp://#{node.env_default['openvpn']}:2375"
  container 'gexcore-openvpn'
  command ['bash', '-c', 'supervisorctl reread && supervisorctl update']
end

docker_template "/etc/supervisor/conf.d/consul_#{node['attributes'].fetch('cluster_id')}.conf" do
  host "tcp://#{node.env_default['openvpn']}:2375"
  source 'consul.conf.erb'
  container 'gexcore-openvpn'
end

docker_template "/etc/consul/consul_#{node['attributes'].fetch('cluster_id')}.json" do
  host "tcp://#{node.env_default['openvpn']}:2375"
  source 'consul.json.erb'
  container 'gexcore-openvpn'
end


docker_exec 'supervisor reread' do
  host "tcp://#{node.env_default['openvpn']}:2375"
  container 'gexcore-openvpn'
  command ['bash', '-c', 'supervisorctl reread && supervisorctl update']
end
