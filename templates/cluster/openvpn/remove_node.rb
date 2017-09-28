require_relative 'openvpn_utils'


safe_exec do

  cluster_id = ENV.fetch('_cluster_id')
  node_id = ENV.fetch('_node_id')

  parse_and_init('openvpn', cluster_id)
  parse_and_init_node(node_id)

  node_number = get_value('_node_number')
  node_name = get_value('_node_name')

  remove_tunnels_by_wildcard "#{cluster_id}_#{node_number}_*", $container
  remove_dnsmasq_entries_by_wildcard /^.*#{node_name}.*$/

end

