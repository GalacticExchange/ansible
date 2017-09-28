#!/usr/bin/env ruby
require 'net/http'
require_relative 'gex_aws'
require_relative '../openvpn_test/openvpn'
require_relative 'clean/coordinator_cleaner'

class ClusterCoordinator < GexAWS
  # @fog -> basic fog object
  # @instance_ami_id -> clusterGX coordinator ami id

  include OpenVPN

  include Cleaner

  def initialize (params = {})
    super
    @file_suffix = 'coordinator_ami_id.txt'
    @instance_ami_id = get_ami_id
  end

  def start_new
    super
    add_tag('Name', "gex-coordinator-#{@config.cluster_data.fetch(:cluster_name)}")
    add_tag('ENV', "#{@config.cluster_data.fetch(:env)}")
    add_tag('cluster_id', "#{@config.cluster_data.fetch(:cluster_id)}")
    #allocate_address

    @config.cluster_data[:coordinator_aws_id] = @instance.id
    @config.cluster_data[:coordinator_private_ip] = @instance.private_ip_address
    @config.cluster_data[:coordinator_public_ip] = @instance.public_ip_address

    add_tag('cluster_uid', @config.cluster_data[:cluster_uid])
  end

  def self.instantiate(cluster_id)
    conf = Helper::Config.new(:cluster_id => cluster_id)
    coord = nil
    CleanHelper.safe_execute {
      coord = ClusterCoordinator.new(:cluster_id => cluster_id)
      coord.connect_to_instance(conf.cluster_data[:coordinator_aws_id])
      return coord
    }
    coord
  end

  def check_coordinator_existence
    @config.cluster_data.fetch(:coordinator_aws_id, 'None')
  end

  def allocate_address
    resp = @fog.allocate_address.body

    @fog.associate_address(@instance.id, resp['publicIp'])
    @instance = @fog.servers.get(@instance.id) #FIX after address allocating
    @instance.private_key_path = @config.key_path #FIX after address allocating
    @config.cluster_data[:coordinator_public_ip] = resp['publicIp']
    @config.cluster_data[:eip_allocation_id] = resp['allocationId']

    check_for
    @instance.username = 'vagrant'
  end

  def terminate
    safe_execute { super }
  end

end

