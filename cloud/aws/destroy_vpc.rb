require_relative 'lib/aws'

AWS::VPC.new do
  cluster_id '100'
  action :destroy
end