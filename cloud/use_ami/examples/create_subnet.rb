require 'fog/aws'


fog = Fog::Compute.new(
    :provider => 'AWS',
    :region=>'us-west-2',
    :aws_access_key_id => 'PH_GEX_KEY_ID',
    :aws_secret_access_key => 'PH_GEX_ACESS_KEY'
)

gex_subnet = fog.create_subnet('vpc-8ec9e1ea','24.0.0.0/16')

gex_subnet_id = gex_subnet.body['subnet']['subnetId']

fog.modify_subnet_attribute(gex_subnet_id,{'MapPublicIpOnLaunch' => true}) #YOHOOO