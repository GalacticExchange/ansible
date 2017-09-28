require 'fog/aws'


fog = Fog::Compute.new(
    :provider => 'AWS',
    :region => 'us-west-2',
    :aws_access_key_id => 'PH_GEX_AWS_KEY',
    :aws_secret_access_key => 'PH_GEX_AWS_ID'
)

gex_security_group = fog.create_security_group('ClusterGX', 'ClusterGX VPC security group', 'vpc-b9b79fdd')
gex_security_group_id = gex_security_group.body['groupId']

puts gex_security_group_id


fog.authorize_security_group_ingress({'GroupId' => gex_security_group_id, 'CidrIp' => '0.0.0.0/0', 'FromPort' => -1, 'IpProtocol' => 'icmp', 'ToPort' => -1}) #All icmp
fog.authorize_security_group_ingress({'GroupId' => gex_security_group_id, 'CidrIp' => '0.0.0.0/0', 'FromPort' => 22, 'IpProtocol' => 'tcp', 'ToPort' => 22}) #SSH