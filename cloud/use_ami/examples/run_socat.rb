#!/usr/bin/env ruby
require_relative 'lib/cluster_coordinator'

#ARGV[0] -> cluster_id
#ARGV[1] -> destination host (container's ip)
#ARGV[2] -> source port

cluster_coord = ClusterCoordinator.new(:cluster_id => ARGV[0])
ip = ARGV[1]
port = ARGV[2]

cluster_coord.connect_to_instance(cluster_coord.cluster_data[:coordinator_id])

#parsing last octet
#octets = ip.split('.')
#port = (octets[2].to_i)*256 + (octets[3].to_i+1)
#port = 2000 + port


#_source_port = 2000 + n
#_destination_host = container weave ip
#_proxy_private_ip = weave expose ip
#_proxy_public_ip = private aws eth0 ip
cluster_coord.run_socat(ip, port)
