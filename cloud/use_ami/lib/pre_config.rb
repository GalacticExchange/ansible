require 'fog/aws'
require 'aws-sdk'

require_relative 'helper'
require_relative 'zookeeper_utils'
require_relative 'clean/pre_config_cleaner'

class PreConfig

  attr_reader :fog

  attr_accessor :config

  include Cleaner
  include ZookeeperUtils

  def initialize (params = {})

    @config = Helper::Config.new(params)

    @fog = Fog::Compute.new(
        :provider => 'AWS',
        :region => params.fetch(:region, 'us-west-2'),
        :aws_access_key_id => params.fetch(:aws_access_key_id),
        :aws_secret_access_key => params.fetch(:aws_secret_access_key)
    )
    @config.cluster_data[:env] = params.fetch(:env)

    @config.cluster_data[:aws_access_key_id] = params.fetch(:aws_access_key_id)
    @config.cluster_data[:aws_secret_access_key] = params.fetch(:aws_secret_access_key)
    @config.cluster_data[:cluster_id] = params.fetch(:cluster_id)
    @config.cluster_data[:cluster_uid] = params.fetch(:cluster_uid)
    @config.cluster_data[:region] = params.fetch(:region, 'us-west-2')
    @config.cluster_data[:cluster_name] = params.fetch(:cluster_name)

    @config.cluster_data[:aws_counter] = get_aws_counter
    @config.cluster_data[:cidr] = get_gex_cidr(@config.cluster_data[:aws_counter])

    setup_default_network_params
  end


  def create_key_pair
    key = @fog.create_key_pair(get_key_name)

    pem_file = File.new(get_key_path, 'w')
    pem_file.puts(key.body['keyMaterial'])

    File.chmod(0400, get_key_path)
  end

  def create_vpc
    #TODO if gex_vpc exists -> use its id.
    gex_vpc = @fog.create_vpc(@config.cluster_data[:cidr])
    gex_vpc_id = gex_vpc.body['vpcSet'][0]['vpcId']

    @fog.create_tags(gex_vpc_id, 'cluster_uid' => @config.cluster_data[:cluster_uid])
    @fog.create_tags(gex_vpc_id, 'Name' => "gex-#{@config.cluster_data[:cluster_uid]}")

    @config.cluster_data[:vpc_id] = gex_vpc_id
  end

  def create_subnet
    #TODO if gex_subnet exists in gex_vpc -> use its id.
    gex_vpc_id = @config.cluster_data.fetch(:vpc_id)
    gex_subnet = @fog.create_subnet(gex_vpc_id, @config.cluster_data[:cidr])

    gex_subnet_id = gex_subnet.body['subnet']['subnetId']

    @config.cluster_data[:subnet_id] = gex_subnet_id

    @fog.modify_subnet_attribute(gex_subnet_id, {'MapPublicIpOnLaunch' => true})
    #TODO check status?
  end

  def create_security_group
    #TODO if gex_sg exists -> use its id

    gex_security_group = @fog.create_security_group('ClusterGX', 'ClusterGX VPC security group', @config.cluster_data.fetch(:vpc_id))
    @config.cluster_data[:security_group_id] = gex_security_group.body['groupId']

    #All ICMP
    @fog.authorize_security_group_ingress({
                                              'GroupId' => @config.cluster_data[:security_group_id],
                                              'CidrIp' => '0.0.0.0/0',
                                              'FromPort' => -1,
                                              'IpProtocol' => 'icmp',
                                              'ToPort' => -1
                                          })
    #SSH
    @fog.authorize_security_group_ingress({
                                              'GroupId' => @config.cluster_data[:security_group_id],
                                              'CidrIp' => '0.0.0.0/0',
                                              'FromPort' => 22,
                                              'IpProtocol' => 'tcp',
                                              'ToPort' => 22
                                          })

    #All traffic (needed by weave)
    @fog.authorize_security_group_ingress({
                                              'GroupId' => @config.cluster_data[:security_group_id],
                                              'CidrIp' => '0.0.0.0/0',
                                              'FromPort' => 0,
                                              'IpProtocol' => '-1',
                                              'ToPort' => 65535
                                          })
  end

  def setup_gateway

    #Creating gateway
    gex_gateway = @fog.create_internet_gateway
    @config.cluster_data[:gateway_id] = gex_gateway.body['internetGatewaySet'][0]['internetGatewayId']

    #Attaching gateway to vpc
    @fog.attach_internet_gateway(@config.cluster_data.fetch(:gateway_id), @config.cluster_data.fetch(:vpc_id))

    #Getting gex vpc routing table id
    @config.cluster_data[:route_table_id] = @fog.describe_route_tables({'vpc-id' => @config.cluster_data.fetch(:vpc_id)}).body['routeTableSet'][0]['routeTableId']

    #Creating route with our gateway
    @fog.create_route(@config.cluster_data.fetch(:route_table_id), '0.0.0.0/0', @config.cluster_data.fetch(:gateway_id))

  end

  def save_cluster_data
    File.write(@config.cluster_json_file_path, JSON.pretty_generate(@config.cluster_data))
  end

  def check_existence
    File.file?(@config.cluster_json_file_path)
  end

  def create_peering_connection
    safe_execute {
      #noinspection RubyArgCount
      aws_sdk_client = Aws::EC2::Client.new(
          access_key_id: @config.cluster_data[:aws_access_key_id],
          secret_access_key: @config.cluster_data[:aws_secret_access_key],
          region: @config.cluster_data[:region]
      )

      resp = aws_sdk_client.create_vpc_peering_connection(
          {
              dry_run: false,
              vpc_id: @config.cluster_data.fetch(:vpc_id),
              peer_vpc_id: @config.cluster_data[:default_vpc_id]
          }
      )

      aws_sdk_client.accept_vpc_peering_connection(
          {
              dry_run: false,
              vpc_peering_connection_id: resp.vpc_peering_connection.vpc_peering_connection_id
          }
      )
      @config.cluster_data[:vpc_peering_connection_id] = resp.vpc_peering_connection.vpc_peering_connection_id
    }
  end

  def get_default_vpc_id
    vpc_arr = @fog.describe_vpcs.body['vpcSet']

    return 'none' if vpc_arr.empty? || vpc_arr[0]['isDefault'].nil?

    vpc_id = 'none'

    safe_execute {
      vpc_id = vpc_arr.select { |vpc| vpc['isDefault'] }.first['vpcId']
    }

    vpc_id

  end

  def create_nodes_file
    File.write(@config.nodes_json_file_path, '[]')
  end


  def create_peering_routes
    safe_execute {
      @fog.create_route(
          @config.cluster_data.fetch(:route_table_id),
          @config.cluster_data.fetch(:default_cidr),
          @config.cluster_data.fetch(:vpc_peering_connection_id)
      )
      @fog.create_route(
          @config.cluster_data.fetch(:default_rtb),
          @config.cluster_data.fetch(:cidr),
          @config.cluster_data.fetch(:vpc_peering_connection_id)
      )
    }
  end

  def setup_default_network_params
    default_vpc = get_default_vpc_id

    if default_vpc == 'none'
      @config.cluster_data[:default_rtb] = 'none'
      @config.cluster_data[:default_cidr] = 'none'
      return
    end

    @config.cluster_data[:default_vpc_id] = default_vpc
    resp = @fog.describe_route_tables('vpc-id' => @config.cluster_data[:default_vpc_id])
    @config.cluster_data[:default_rtb] = resp.body['routeTableSet'][0]['associationSet'][0]['routeTableId']
    @config.cluster_data[:default_cidr] = resp.body['routeTableSet'][0]['routeSet'][0]['destinationCidrBlock']
  end

  def get_gex_cidr(aws_counter)
    offset = aws_counter.to_i + 176
    "10.#{offset}.0.0/16"
  end

  def get_key_name
    @config.cluster_data[:key_name] = "#{Helper::KEY_NAME}#{@config.cluster_data.fetch(:aws_counter)}"
  end

  #TODO refactor this shit
  def get_key_path
    @config.key_path = File.join(@config.credentials_path, "#{get_key_name}.pem")
  end

  def get_aws_counter
    resp = @fog.describe_key_pairs.body['keySet']
    key_names = resp.map { |elem| elem['keyName'] if elem['keyName'].include?('ClusterGX') }.compact

    if key_names.empty?
      return 1
    end

    counts = key_names.map { |key_name| key_name.delete('ClusterGX_key').to_i }

    counts.max + 1
  end


  def self.instantiate(cluster_id)
    conf = Helper::Config.new(:cluster_id => cluster_id)
    pre_conf = PreConfig.new(
        aws_access_key_id: conf.cluster_data[:aws_access_key_id],
        aws_secret_access_key: conf.cluster_data[:aws_secret_access_key],
        cluster_id: conf.cluster_data[:cluster_id],
        cluster_uid: conf.cluster_data[:cluster_uid],
        region: conf.cluster_data[:region],
        cluster_name: conf.cluster_data[:cluster_name],
        env: conf.cluster_data[:env]
    )

    pre_conf.config = conf
    pre_conf
  end

  #TODO
  def gex_vpc_exists?
    @fog.describe_vpcs

  end

end