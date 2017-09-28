require_relative '../../lib/aws'


AWS::Node.new do
  cluster_id '100'
  node_uid '331124'
  instance_type 't2.medium'
  node_agent_token 'test_agent_token'
  volume_size '100'
  node_name 'test_node_name'
  tags(
      Name: 'test_node',
      cluster_id: '99'
  )
  action :create
end
