require_relative 'lib/aws'

AWS::VPC.new do
  env 'main'
  cluster_id '100'
  cluster_uid 'test_uid'
  cluster_name 'zzz'
  aws_key_id 'PH_GEX_KEY_ID'
  aws_key_secret 'PH_GEX_ACESS_KEY'
  aws_counter '4'
  region 'us-west-1'
  action :create
end
