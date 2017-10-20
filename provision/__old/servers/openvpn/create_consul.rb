cluster_id = ENV.fetch('cluster_id')
openvpn = GexContainer.new('51.1.0.51', 'gexcore-openvpn')
GEX_LOGGER.set_cluster_id(cluster_id).info_start

openvpn.exec('mkdir -p /data/consul_logs')

begin
  GEX_LOGGER.debug('Trying to remove consul service..')
  openvpn.exec("supervicortctl stop consul_#{cluster_id}")
  openvpn.exec("rm -f /etc/supervisor/conf.d/consul_#{cluster_id}.conf")
rescue
  GEX_LOGGER.debug("No such consul service: consul_#{cluster_id}")
  puts 'No such consul service'
end

GEX_LOGGER.debug('before template processing')
openvpn.template(
    'templates/consul.conf.erb',
    "/etc/supervisor/conf.d/consul_#{cluster_id}.conf",
    {cluster_id: cluster_id}
)


consul_vars = {
    cluster_id: cluster_id,
    consul_ports: ConsulUtils.consul_ports(cluster_id)
}

openvpn.template(
    'templates/consul.json.erb',
    "/etc/consul/consul_#{cluster_id}.json",
    consul_vars
)

openvpn.update_supervisor

GexUtils.is_port_open?('51.0.1.8', ConsulUtils.consul_ports(cluster_id)[:http])

ConsulUtils.wait_for_consul(cluster_id)

GEX_LOGGER.info_finish

