#!/usr/bin/env ruby

require 'net/http'

require_relative 'gex_aws'
require_relative 'clean/node_cleaner'
require_relative 'tests/main_env'
require_relative 'gex_api'

class Node < GexAWS

  include CleanHelper
  include MainEnv

  SWAP_SIZE = 4096
  # @fog -> basic fog object
  # @instance_ami_id -> clusterGX instance ami id
  # @node_data -> array of hashes

  attr_reader :hadoop_type, :node_data, :file_suffix

  def initialize (params = {})
    super

    @node_data = {}
    @node_data[:gex_node_uid] = params.fetch(:gex_node_uid)
    @node_data[:node_agent_token] = params.fetch(:node_agent_token)
    @node_data[:node_name] = params.fetch(:node_name)
    @hadoop_type = params.fetch(:hadoop_type)
    @instance_type = params.fetch(:instance_type, 't2.medium')
    @volume_size = params.fetch(:volume_size, '100')

    gex_env = @config.cluster_data.fetch(:env)
    gex_env = 'main' if gex_env == 'aws'

    @file_suffix = "#{gex_env}_node_ami_#{@hadoop_type}_id.txt"
    @instance_ami_id = get_ami_id

  end


  def start_new
    super
    add_tag('Name', "#{Helper::NODE_BASE_NAME}#{@config.cluster_data.fetch(:cluster_name)}-#{@node_data[:node_name]}")
    add_tag('ENV', "#{@config.cluster_data.fetch(:env)}")
    add_tag('cluster_id', "#{@config.cluster_data.fetch(:cluster_id)}")

    @node_data[:aws_instance_id] = @instance.id
    @node_data[:private_ip] = @instance.private_ip_address

    add_swap

    #TODO prod hard fx
    #@instance.ssh(%Q(sudo bash -c "echo '*       soft    nproc     500000' >> /etc/security/limits.conf"))
    #@instance.ssh(%Q(sudo bash -c "echo '*       hard    nproc     500000' >> /etc/security/limits.conf"))

    provision_ssh_data
    save_instance_id
    update_deb
  end


  def update_gex(env)
    env = env.to_sym
    #ssh(%Q(sudo bash -c 'echo "deb https://dl.bintray.com/#{Helper::GEXD_DEB.fetch(env)[:repo]}/deb $(lsb_release -c -s) main" | sudo tee -a /etc/apt/sources.list'))

    i = 0
    begin
      ssh(%Q(sudo apt-get update))
      ssh(%Q(sudo apt-get install --force-yes -y #{Helper::GEXD_DEB[env][:package]} ))
    rescue
      raise('gexd max tries exceeded') if i > 20

      puts 'Could not install gexd, retying'
      ssh(%Q(sudo apt-get -f install |true))
      #ssh(%Q(sudo dpkg --remove --force-remove-reinstreq --dry-run #{Helper::GEXD_DEB[env][:package]} |true))
      ssh(%Q(sudo dpkg --remove --force-remove-reinstreq #{Helper::GEXD_DEB[env][:package]} |true))
      fix_dpkg
      sleep 45
      i = i + 1
      retry
    end

    #TODO refactor or delete this...
    #hot_fix
  end

  def save_node_data

    File.open(@config.nodes_json_file_path, "r+") do |file|
      file.flock(File::LOCK_EX)

      all_nodes = JSON.parse(file.read, symbolize_names: true)
      file.rewind
      all_nodes.push(@node_data)
      file.write(JSON.pretty_generate(all_nodes))
      file.flush
      file.truncate(file.pos)
    end

    #all_nodes = @config.get_nodes_data
    #all_nodes.push(@node_data)
    #File.write(@config.nodes_json_file_path,JSON.pretty_generate(all_nodes))

  end

  def provision_ssh_data
    ssh('sudo mkdir -p /etc/node/nodeinfo')

    provision_pem

    ssh("sudo bash -c 'echo #{@config.cluster_data.fetch(:coordinator_private_ip)} > /etc/node/nodeinfo/COORDINATOR_IP'")
  end

  def provision_pem
    scp(@config.key_path, '/home/vagrant/')
    ssh("sudo mv /home/vagrant/#{@config.cluster_data.fetch(:key_name)}.pem /etc/node/nodeinfo/#{Helper::KEY_NAME}.pem")
  end

  def save_instance_id
    ssh(%Q(sudo bash -c 'echo #{@instance.id} > /etc/node/nodeinfo/aws_instance_id'))
  end

  #def fix_routes(container_name)
  #  @instance.ssh(%Q(sudo ip route del $(docker exec #{container_name} ip addr  |grep "global ethwe" | awk -F'[/\t\n ]' '{print $6}')))
  #  @instance.ssh(%Q(docker exec #{container_name} ip route replace 51.1.0.1 via #{Helper::VPN_WEAVE_IP}))
  #end

  def self.instantiate(cluster_id, gex_node_uid)
    conf = Helper::Config.new(:cluster_id => cluster_id)
    node_data = conf.get_nodes_data.detect {|elem| elem[:gex_node_uid] == gex_node_uid}

    node_data = {} if node_data.nil?
    #aws_id = conf.get_nodes_data.detect { |elem| elem[:gex_node_uid] == gex_node_uid }.fetch(:aws_instance_id, '')
    aws_id = node_data.fetch(:aws_instance_id, '')

    return nil if aws_id.empty?

    CleanHelper.safe_execute {
      node = Node.new(
          hadoop_type: '',
          cluster_id: cluster_id,
          instance_type: '',
          gex_node_uid: gex_node_uid,
          node_agent_token: node_data.fetch(:node_agent_token),
          node_name: ''
      )
      node.connect_to_instance(aws_id)
      return node
    }
    return nil

  end

  def update_deb
    ssh('cd /home/vagrant/gexstarter/updater && sudo rake update_deb')
  end

  def setup_gex

    setup_config_properties

    check_for_gexd(Helper::GEXD_PORT)

    command = %Q(ruby /home/vagrant/gexstarter/aws_scripts/setup_gexclient.rb #{Helper::GEXD_PORT} #{@node_data[:gex_node_uid]} #{@node_data[:node_agent_token]})

    ssh(command)
  end

  def install_client
    #fix_dpkg
    #added_packages_tmp

    #env = @config.cluster_data.fetch(:env)

    #forward_main_env if env == 'main'

    #update_gex(env)

    setup_gex

  end

  def stop
    super
    #GexApi.node_notify(
    #    'node_stopped',
    #    @node_data.fetch(:gex_node_uid),
    #    @node_data.fetch(:node_agent_token),
    #    @config.cluster_data.fetch(:env)
    #)
  end

  def terminate
    super
    #GexApi.node_notify(
    #    'node_uninstalled',
    #    @node_data.fetch(:gex_node_uid),
    #    @node_data.fetch(:node_agent_token),
    #    @config.cluster_data.fetch(:env)
    #)
  end

  def fix_dpkg
    ssh('sudo pkill apt |true')
    ssh('sudo rm /var/lib/dpkg/lock |true')
    ssh('sudo dpkg --configure -a |true')
  end

  # todo1
  def added_packages_tmp
    ssh('sudo gem install slack-notifier')
  end

  def add_swap
    ssh("sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=#{SWAP_SIZE}")
    ssh('sudo /sbin/mkswap /var/swap.1')
    ssh('sudo chmod 600 /var/swap.1')
    ssh('sudo /sbin/swapon /var/swap.1')
    ssh(%Q(sudo bash -c "echo '/var/swap.1 swap swap defaults 0 0' >> /etc/fstab"))
  end


  def setup_config_properties
    if @config.cluster_data.fetch(:env) == 'aws'

      conf_props_path = '/mount/ansibledata/config.properties'

      raise "Cannot find #{conf_props_path} !!!" unless File.exist?(conf_props_path)

      conf_props = File.read(conf_props_path)

      ssh(%Q(sudo bash -c 'echo "#{conf_props}" > /etc/gex/config.properties'))
      ssh(%Q(sudo supervisorctl restart gexd))

    end
  end

end

