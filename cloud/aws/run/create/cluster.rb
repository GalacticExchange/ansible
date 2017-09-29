require_relative '../../lib/aws'

AWS::VPC.new do
  env 'main'
  cluster_id '100'
  cluster_uid 'test_uid'
  cluster_name 'zzz'
  aws_key_id 'PH_GEX_KEY_ID'
  aws_key_secret 'PH_GEX_ACESS_KEY'
  aws_counter '4'
  region 'ap-southeast-1'
  action :create
end


AWS::Coordinator.new do
  cluster_id '100'
  instance_type 't2.micro'
  ami_id 'ami-b3124ed3'
  volume_size '100'
  user_token 'test_user_token'
  tags(
      Name: 'test_coord',
      cluster_id: '99'
  )

  action :create
end
