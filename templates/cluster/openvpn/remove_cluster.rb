#!/usr/bin/env ruby
# noinspection RubyResolve
#require "chef"
require_relative 'openvpn_utils'

safe_exec do

  cluster_id = ENV.fetch('_cluster_id')
  #parse_and_init('openvpn', cluster_id)
  #use_container('openvpn')

  remove_tunnels_by_wildcard "#{cluster_id}_*", $container

  remove_dnsmasq_entries_by_wildcard /^.*#{cluster_id}\.gex.*$/

  begin
    consul_remove_cluster(cluster_id)
  rescue
    puts 'COULD NOT REMOVE CONSUL!'
  end

  init_vars
  add_var('_server_name', 'openvpn')
  get_processor.remove_template_tree(template_dir("cluster"))

  system("service consul-#{cluster_id} stop")

end

