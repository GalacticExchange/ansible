#!/usr/bin/env ruby
require_relative "local_utils"

safe_exec do

  cluster_id = ENV.fetch('_cluster_id')
  node_id = ENV.fetch('_node_id')

  GEX_LOGGER.set_cluster_id(cluster_id).set_node_id(node_id)
  GEX_LOGGER.info_start

  parse_and_init('provisioner', cluster_id)
  parse_and_init_node(node_id)

  node_number = _a('_node_number')

  node_name = _a('_node_name')


  add_vars ({
      '_tunnel_client_ip' => consul_get_node_ip(node_name),
      '_tunnel_server_ip' => consul_get_node_tunnel_ip(node_name),
      '_tunnel_port' => consul_get_node_vpn_port(node_name)
  })

  GEX_LOGGER.debug("Configured $vars: #{$vars}")


  ndd = node_data_dir(cluster_id, node_number)


  processor = get_processor

  if _a('_host_type') == 'virtualbox'
    GEX_LOGGER.debug('Entered virtualbox block')


    FileUtils.rm_rf "#{ndd}/node/Vagrantfile"

    processor.process_template_file "#{BASE_DIR_VAGRANT}/Vagrantfile.erb", BASE_DIR_VAGRANT,
                                    destination: "#{ndd}/node/Vagrantfile"

    texecs("cat #{BASE_DIR_VAGRANT}/Vagrantfile.rb >> #{ndd}/node/Vagrantfile",
           "cp #{BASE_DIR_VAGRANT}/common/* #{ndd}/node")

    GEX_LOGGER.debug('Processed  Vagrantfile')

  elsif _a('_host_type') == 'dedicated'
    GEX_LOGGER.debug('Entered dedicated block')

    processor.process_template_file "#{BASE_DIR_DEDICATED}/provision.rb.erb", BASE_DIR_DEDICATED,
                                    destination: "#{ndd}/node/provision.rb"

    GEX_LOGGER.debug('Processed  provision.rb')
  end


  GEX_LOGGER.info_finish
end
