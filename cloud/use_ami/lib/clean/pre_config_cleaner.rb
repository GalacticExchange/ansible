require_relative 'clean_helper'
require_relative '../aws_utils'


module Cleaner
  include CleanHelper
  include AwsUtils


  def delete_key_pair
    safe_execute {@fog.delete_key_pair(@config.cluster_data.fetch(:key_name))}
  end

  def delete_peering_route
    safe_execute {@fog.delete_route(@config.cluster_data.fetch(:default_rtb), @config.cluster_data.fetch(:cidr))}
  end

  def delete_peering_connection

    #noinspection RubyArgCount
    client = Aws::EC2::Client.new(
        access_key_id: @config.cluster_data[:aws_access_key_id],
        secret_access_key: @config.cluster_data[:aws_secret_access_key],
        region: @config.cluster_data[:region]
    )

    safe_execute {
      client.delete_vpc_peering_connection(
          {
              dry_run: false,
              vpc_peering_connection_id: @config.cluster_data.fetch(:vpc_peering_connection_id)
          }
      )
    }
  end


  def delete_vpc
    safe_execute {@fog.delete_vpc(@config.cluster_data.fetch(:vpc_id))}
  end

  def delete_subnet
    safe_execute {@fog.delete_subnet(@config.cluster_data.fetch(:subnet_id))}
  end

  def delete_security_group
    safe_execute {@fog.delete_security_group(nil, @config.cluster_data.fetch(:security_group_id))}
  end

  def delete_gateway
    safe_execute {
      @fog.detach_internet_gateway(@config.cluster_data.fetch(:gateway_id), @config.cluster_data.fetch(:vpc_id))
      @fog.delete_internet_gateway(@config.cluster_data.fetch(:gateway_id))
    }
  end

  def delete_remaining_instances
    safe_execute {
      resp = @fog.describe_instances('vpc-id' => @config.cluster_data.fetch(:vpc_id)).body
      instances_ids = resp['reservationSet'].map {|e| e['instancesSet'][0]['instanceId']}
      @fog.terminate_instances(instances_ids)

      instances_ids.each {|id|
        wait_for_state('terminated', id)
      }
    }
  end

  def remove_cluster_data
    safe_execute {FileUtils.rm_rf(@config.credentials_path)}
  end

  def clean_all
    delete_remaining_instances

    delete_key_pair
    delete_peering_route
    delete_peering_connection

    delete_subnet
    delete_security_group
    delete_gateway

    delete_vpc
    remove_cluster_data
  end

end