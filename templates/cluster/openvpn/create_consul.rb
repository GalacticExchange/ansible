require 'json'

####
require_relative 'openvpn_utils'

safe_exec do


  cluster_id = ENV.fetch('_cluster_id')
  GEX_LOGGER.set_cluster_id(cluster_id).info_start


  init_vars

  add_var('_cluster_id', cluster_id)
  add_var('_server_name', 'openvpn')
  add_var('_consul_ports', consul_ports(cluster_id))

  dexec('mkdir -p /data/consul_logs')

  begin
    GEX_LOGGER.debug('Trying to remove consul service..')
    consul_remove_cluster(cluster_id)
  rescue
    GEX_LOGGER.debug("No such consul service: consul-#{cluster_id}")
    puts 'No such consul service'
  end

  GEX_LOGGER.debug('before template processing')
  gexcloud_process_template_trees 'cluster'

  enable_and_start_service("consul-#{cluster_id}")
  is_port_open?('51.0.1.8', consul_ports(cluster_id)[:http])
  wait_for_consul(cluster_id)

  GEX_LOGGER.info_finish

end
