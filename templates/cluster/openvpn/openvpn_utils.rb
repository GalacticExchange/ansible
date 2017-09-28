require "json"
require "fileutils"
require_relative "../common/gexcloud_utils"


SYSTEMD_DIR = "/etc/systemd/system/"
OPENVPN_DIR = "/etc/openvpn/config"


def get_tunnel_ip(index, is_client)
  if is_client
    offset = 1
  else
    offset = 0
  end
  "51.128." + ((2 * index + offset)/256).to_s + "." + ((2 * index + offset) % 256).to_s
end

def get_port(index)
  (1024 + index).to_s
end


def remove_tunnels_by_pattern(clusterid, nodeid = nil, appid = nil)

  if nodeid == nil
    pattern = clusterid + "_*"
  elsif apid == nil
    pattern = clusterid + "_" + nodeid + "_*"
  else
    pattern = clusterid + "_" + nodeid + "_" + appid + ".*"
  end

  puts "Removing tunnels " + pattern

  Dir.glob("#{SYSTEMD_DIR}/openvpn_#{pattern}").each do |file_name|
    `systemctl disable --now #{file_name}| true`
    File.delete "#{file_name}"
  end

  remove_files_by_pattern OPENVPN_DIR, pattern
  remove_files_by_pattern OPENVPN_DIR, pattern

end


INDEX_FILE_NAME = "/etc/openvpn/config/index"

def create_file(file, contents)
  puts "Writing #{file}"
  IO.write file, contents
end


#def zookeper_port(cluster_id)
#  "#{60000 + cluster_id.to_i}"
#end

def create_tunnel(cluster_id, node_number, node_name, app_name, openvpn_ip_address)

  assert_node_container node_name, app_name
  assert_node_number node_number
  assert_ip openvpn_ip_address

  remove_files_by_wildcard "/etc/openvpn/config/#{cluster_id}_#{node_number}_#{app_name}*", $container
  remove_files_by_wildcard "/etc/systemd/system/openvpn_#{cluster_id}_#{node_number}_#{app_name}*", $container


  index = 1

  index_file = container_file(INDEX_FILE_NAME)

  unless File.exist? index_file
    xexec "bash -c 'echo 1 > #{INDEX_FILE_NAME}'", $container
  end


  client_ip = nil

  File.open(index_file, "r+") do |file|

    file.flock(File::LOCK_EX)
    index = file.readline.strip.to_i

    vpn_port = get_port index
    client_ip = get_tunnel_ip index, true
    server_ip = get_tunnel_ip index, false

    file_prefix = "/mount/ansibledata/#{cluster_id}_#{node_number}_#{app_name}_"


    create_file file_prefix + "port", vpn_port.to_s
    create_file file_prefix + "client_ip", client_ip.to_s
    create_file file_prefix + "server_ip", server_ip.to_s


    index = index + 1
    file.rewind
    file.write(index)
    file.flush
    file.truncate(file.pos)

    add_vars ({"_server_ip" => server_ip,
               "_client_ip" => client_ip,
               "_vpn_port" => vpn_port,
               "_node_number" => node_number,
               "_openvpn_ip_address" => openvpn_ip_address,
               "_app_name" => app_name})


    processor = get_processor

    processor.process_template_tree template_dir("tunnel/container"), $container
    processor.process_template_tree template_dir("tunnel/host")


    if app_name == "node"

      add_to_container_hosts(client_ip, "#{node_name}.gex #{node_number}-#{cluster_id}.gex #{node_name} ")

      consul_create_node(node_name)
      consul_set_node_ip(node_name, client_ip)
      consul_set_node_tunnel_ip(node_name, server_ip)
      consul_set_node_vpn_port(node_name, vpn_port)

    else
      add_to_container_hosts(client_ip,
                             "#{app_name}-#{node_name}.gex #{app_name}-#{node_name} #{app_name}-#{node_number}-#{cluster_id}.gex")

      consul_create_container_dir(node_name, app_name)
      consul_set_container_ip(node_name, app_name, client_ip)
      consul_set_container_tunnel_ip(node_name, app_name, server_ip)
      consul_set_container_vpn_port(node_name, app_name, vpn_port)

    end


    dexec 'service dnsmasq restart | true'

  end

  dcp "/mount/ansible/templates/cluster/openvpn/secret.key",
      "/etc/openvpn/config/#{cluster_id}_#{node_number}_#{app_name}.key"

  enable_and_start_service "openvpn_#{cluster_id}_#{node_number}_#{app_name}"

  client_ip
end


def remove_tunnel(cluster_id, node_name, node_number, app_name, container)


  remove_tunnels_by_wildcard "#{cluster_id}_#{node_number}_#{app_name}*", container

  if app_name == "node"
    wildcard = /^.*#{node_name}.*$/
  else
    wildcard = /^.*#{app_name}-#{node_name}.*$/
  end

  remove_dnsmasq_entries_by_wildcard wildcard

end

def wait_for_consul(cluster_id)

  60.times do |t|
    #result = `curl 51.0.1.8:#{consul_ports(cluster_id)[:http]}`
    #result = system("curl 51.0.1.8:#{consul_ports(cluster_id)[:http]}")

    result = `curl 51.0.1.8:#{consul_ports(cluster_id)[:http]}/v1/status/leader`
    if result.gsub('"','') == "51.0.1.8:#{consul_ports(cluster_id)[:server]}"
      break
    end
    raise 'Cannot wait for consul started' if t == 59
    sleep 10
  end

end

use_container 'openvpn'

