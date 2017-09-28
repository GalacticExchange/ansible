require_relative '../lib/pre_config'
require_relative '../lib/cluster_coordinator'
require_relative '../lib/node'

CLUSTER_ID = '112'
INSTANCE_TYPE = 't2.medium'
GEX_NODE_UID = '222'
GEX_NODE_AGENT_TOKEN = '333'
VOLUME_SIZE = '100'
GEX_ENV = 'main'
HADOOP_TYPE = 'cdh'

ZOOKEEPER_HOST = '51.0.1.8'
ZOOKEEPER_PORT = '60112' #60000 + CLUSTER_ID


def setup_dirs
  #puts 'fuu'
  CleanHelper.safe_execute { FileUtils.rm_rf("/mount/ansibledata/#{CLUSTER_ID}/credentials") }
  CleanHelper.safe_execute { FileUtils.mkdir_p("/mount/ansibledata/#{CLUSTER_ID}/credentials") }
end

def reset_zookeeper
  #Assumig zookeeper service is running
  zk = Zookeeper.new("#{ZOOKEEPER_HOST}:#{ZOOKEEPER_PORT}")
  zk.delete(Helper::NODES_JSON_FILE)
  zk.create(Helper::NODES_JSON_FILE)
  zk.set(path: Helper::NODES_JSON_FILE, data: '[]')
end


RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation
end
