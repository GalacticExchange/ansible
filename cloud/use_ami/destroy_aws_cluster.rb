#!/usr/bin/env ruby
require_relative 'lib/cluster_coordinator'
require_relative 'lib/pre_config'
require_relative 'lib/node'


cluster_id = ENV.fetch('_cluster_id')

config = Helper::Config.new(:cluster_id => cluster_id)

nodes_destroy = Proc.new { |config|
  gex_node_ids = config.get_nodes_data.map { |elem| elem[:gex_node_uid] }

  nodes = []

  gex_node_ids.each { |gex_id|
    puts gex_id
    node = Node.instantiate(config.cluster_data.fetch(:cluster_id), gex_id)
    nodes.push(node)
  }

  nodes.compact!

  nodes_threads = []

  nodes.each { |node|
    nodes_threads.push(
        Thread.new {
          node.terminate
        }
    )
  }

  nodes_threads.each { |thr| thr.join }

}

coordinator_destroy = Proc.new{ |config|
  coordinator = ClusterCoordinator.instantiate(config.cluster_data.fetch(:cluster_id))
  coordinator.terminate
  coordinator.release_static_ip
}

network_destroy = Proc.new { |config|
  networking = PreConfig.instantiate(config.cluster_data.fetch(:cluster_id))
  networking.clean_all
}


CleanHelper.safe_execute{
  nodes_destroy.call(config)
}

CleanHelper.safe_execute{
  coordinator_destroy.call(config)
}

CleanHelper.safe_execute{
  network_destroy.call(config)
}