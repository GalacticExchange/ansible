require_relative '../../../../templates/cluster/openvpn/openvpn_utils'

def setup_zookeeper
  $vars['server_name'] = 'openvpn'

  create_processor.process_local_template_tree "cluster"


  enable_and_start_service "zookeeper-112"
end