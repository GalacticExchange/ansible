require_relative '../../lib/aws'

AWS::Node.new do
  cluster_id '100'
  node_uid '231123'
  action :destroy
end
