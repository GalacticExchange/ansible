#
# _gex_env=main _cluster_id=465 _node_id=940  ruby test_create_node.rb

#
require_relative 'lib/init'
require_relative 'lib/provision_node'

# input
node_id = 940

# work
ProvisionNode.create_node
