require 'fog/aws'


fog = Fog::Compute.new(
    :provider => 'AWS',
    :region=>'us-west-2',
    :aws_access_key_id => 'PH_GEX_AWS_KEY',
    :aws_secret_access_key => 'PH_GEX_AWS_ID'
)

gex_gateway = fog.create_internet_gateway

gex_gateway_id = gex_gateway.body['internetGatewaySet'][0]['internetGatewayId']

fog.attach_internet_gateway(gex_gateway_id,'vpc-4895be2c')

#TODO get routing table id
route_table_id = fog.describe_route_tables({'vpc-id'=>'vpc-4895be2c'}).body['routeTableSet'][0]['routeTableId']


fog.create_route(route_table_id,'0.0.0.0/0',gex_gateway_id)


