require 'diplomat'
require 'net/ssh'
require_relative 'consul_utils'

module ContainerUtils
  extend self

  include ConsulUtils


  def change_container_state(cluster_id, node_name, container_name, action)
    if node_name.empty?
      change_master_state(cluster_id, container_name, action)
    else
      change_node_state(cluster_id, node_name, container_name, action)
    end
  end

  def change_master_state(cluster_id, container_name, action)
    cmd = "sudo service #{container_name}-master-#{cluster_id} #{action}"
    exec_ssh(Config.server_master['host'], 'gex', 'PH_GEX_PASSWD1', cmd)
  end

  def change_node_state(cluster_id, node_name, container_name, action)
    node_ip = get_node_ip(cluster_id, node_name)
    cmd = "sudo service #{container_name} #{action}"
    node_ssh_cmd(node_ip, cmd)
  end

  def exec_ssh(host, user, pwd, cmd)
    #Net::SSH.start(host, user, :password => pwd) { |ssh|
    #  ssh.open_channel { |chan|
    #    chan.exec(cmd)
    #    chan.on_request('exit-status') { |ch, data|
    #      exit_code = data.read_long
    #      raise "Process exited with non-zero exit code: #{exit_code}" if exit_code != 0
    #    }
    #  }
    #}
    exit_code = system("sshpass -p #{pwd} ssh #{user}@#{host} #{cmd}")
    raise "Process exited with non-zero exit code: #{exit_code}" unless exit_code
  end

  def get_node_ip(cluster_id, node_name)
    ConsulUtils.connect(cluster_id)
    ConsulUtils.consul_get("/nodes/#{node_name}/primary_ip")
  end

  def node_ssh_cmd(ip, cmd)
    exec_ssh(ip, 'vagrant', 'vagrant', cmd)
  end

end
