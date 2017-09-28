require 'fog/aws'


fog = Fog::Compute.new(
    :provider => 'AWS',
    :region=>'us-west-2',
    :aws_access_key_id => 'PH_GEX_AWS_KEY',
    :aws_secret_access_key => 'PH_GEX_AWS_ID'
)

gex_vpc = fog.create_vpc('24.0.0.0/16')

puts gex_vpc.body['vpcSet'][0]['vpcId']

#TODO get route table id