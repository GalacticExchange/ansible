require_relative '../lib/consul_utils'

cluster_id = ARGV[0]
#cluster_id = 422
#cluster_id = 419
#cluster_id = 424

ConsulUtils.connect(cluster_id)
sessionid = Diplomat::Session.create({:Node => "consul-#{cluster_id}", :Name => 'my-lock'})

['openvpn','provisioner_first', 'provisioner', 'master', 'proxy','webproxy'].each {|srv|
  lock_acquired = Diplomat::Lock.acquire("/lock/#{srv}", sessionid, '1')
  puts "#{srv}: #{lock_acquired}"
  #break if srv == 'master'
  Diplomat::Lock.release("/lock/#{srv}", sessionid )

}



=begin
ConsulUtils.connect(409)
sessionid = Diplomat::Session.create({:Node => 'consul409', :Name => 'my-lock'})

['master','openvpn', 'proxy', 'webproxy', 'provisioner'].each {|srv|
  lock_acquired = Diplomat::Lock.acquire("/lock/#{srv}", sessionid)
  puts "#{srv}: #{lock_acquired}"
  Diplomat::Lock.release("/lock/#{srv}", sessionid )

}
=end