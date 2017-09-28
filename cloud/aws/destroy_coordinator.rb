require_relative 'lib/aws'

AWS::Coordinator.new do
  cluster_id '100'
  action :destroy
end
