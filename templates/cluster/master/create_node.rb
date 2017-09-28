#!/usr/bin/env ruby

require_relative 'master_utils'


def start_disabled_containers(cluster_id)
  FRAMEWORKS.each do |f|

    FileUtils.rm_f "/etc/systemd/system/#{f}-master-#{cluster_id}.disabled"
    #start_service "#{f}-master-#{cluster_id}"
    #texec("bash -c 'systemctl daemon-reload'")
    #texec("bash -c 'systemctl start #{f}-master-#{cluster_id}'")

    #texec("sshpass -p PH_GEX_PASSWD2 ssh root@51.1.0.50 bash -c 'systemctl start #{f}-master-#{cluster_id}'")
    texec("bash -c 'source /root/.bashrc; systemctl start #{f}-master-#{cluster_id}'")

  end
end

def update_framework_master_hosts(cluster_id, f, vars, slave_ip)
  node_name = vars["_node_name"]
  assert_nnil node_name
  FRAMEWORKS.each do |ff|
    dexec "bash -c 'echo #{slave_ip} #{f}-#{node_name}.gex #{f}-#{node_name}  >> /etc/hosts'",
          "#{ff}-master-#{cluster_id}"
  end
end

safe_exec do

  cluster_id = ENV.fetch('_cluster_id')
  node_id = ENV.fetch('_node_id')
  #GexLogger.trace_position_create_node('master_started', cluster_id, node_id)
  GEX_LOGGER.set_cluster_id(cluster_id).set_node_id(node_id)
  GEX_LOGGER.info_start


  parse_and_init('master', cluster_id)
  parse_and_init_node(node_id)


  init_master_vars(cluster_id)

  unless $vars['_hadoop_app_id']
    GEX_LOGGER.info_finish
    exit 0
  end

  #start_disabled_containers(cluster_id)

  FRAMEWORKS.each do |f|

    slave_ip = consul_get_container_ip(_a("_node_name"), f)

    use_container "#{f}-master-#{cluster_id}"

    GEX_LOGGER.before_line_debug("f = #{f}")
    update_framework_master_with_slave f, $vars, slave_ip

    GEX_LOGGER.before_line_debug("f = #{f}")
    update_framework_master_hosts(cluster_id, f, $vars, slave_ip)

  end


  GEX_LOGGER.info_finish

end
