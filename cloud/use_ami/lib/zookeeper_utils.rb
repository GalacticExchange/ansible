require 'zookeeper'

module ZookeeperUtils

  ZOOKEEPER_HOST = '51.0.1.8'

  def create_zk_connection
    @zk = Zookeeper.new("#{ZOOKEEPER_HOST}:#{get_zk_port}")
  end

  def get_zk_port
    "#{60000 + @config.cluster_data[:cluster_id].to_i}"
  end
end