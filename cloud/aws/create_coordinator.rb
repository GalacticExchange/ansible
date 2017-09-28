require_relative 'lib/aws'

AWS::Coordinator.new do
  cluster_id '100'
  instance_type 't2.micro'
  volume_size '100'
  user_token 'test_user_token'
  tags(
      Name: 'test_coord',
      cluster_id: '99'
  )

  action :create
end
