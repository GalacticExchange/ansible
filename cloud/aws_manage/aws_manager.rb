require 'fog'
require_relative '../../cloud/use_ami/lib/clean/clean_helper'
class AwsManager

  include CleanHelper

  DEFAULT_REGION = 'us-west-2'
  DEFAULT_VPC = 'vpc-5dd7be38'

  AWS_KEYS = {key_id: 'PH_GEX_AWS_KEY', key_secret: 'PH_GEX_AWS_ID'}

  #IMPORTANT: all regions except default!!!
  # noinspection RubyLiteralArrayInspection
  AWS_REGIONS = [
      'us-east-1',
      'us-east-2',
      'us-west-1',
      'ap-northeast-2',
      'ap-southeast-1',
      'ap-southeast-2',
      'ap-northeast-1',
      'eu-central-1',
      'eu-west-1',
      'eu-west-2',
      'ca-central-1',
      'ap-south-1',
      'sa-east-1'
  ]

  def initialize
    @prime_fog = get_fog(DEFAULT_REGION)
  end


  def get_fog(region)
    Fog::Compute.new(
        :provider => 'AWS',
        :region => region,
        :aws_access_key_id => AWS_KEYS[:key_id],
        :aws_secret_access_key => AWS_KEYS[:key_secret]
    )
  end

  def stop_outsize_instances
    stop_instances(@prime_fog, get_non_default_instances(@prime_fog))

    AWS_REGIONS.each { |region|
      fog = get_fog(region)
      stop_instances(fog, get_non_default_instances(fog))
    }

  end

  def stop_instances(fog, instances)

    unless instances.class == Array
      instances = [instances]
    end
    safe_execute { fog.stop_instances(instances) }

  end


  def get_non_default_instances(fog)
    resp = fog.describe_vpcs.body['vpcSet']

    return [] if resp.length < 2

    vpc_arr = resp.select { |vpc| !vpc['isDefault'] }.map { |vpc| vpc['vpcId'] }

    instances = fog.describe_instances('vpc-id' => vpc_arr).body

    instances['reservationSet'].map { |instance| instance['instancesSet'][0]['instanceId'] }.compact
  end

end