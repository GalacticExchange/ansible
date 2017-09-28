require_relative 'lib/init'
require_relative 'lib/init/sidekiq'


cluster_id=99
node_id=1107
cluster_type = 'onprem'
action = 'restart'


#
Provision::Webproxy.restart_nginx_async

sleep 5
Provision::Webproxy.restart_nginx_async

sleep 3
Provision::Webproxy.restart_nginx_async

sleep 3
Provision::Webproxy.restart_nginx_async

sleep 3
Provision::Webproxy.restart_nginx_async


###
exit 0

sleep 10
Provision::Webproxy.restart_nginx_async

sleep 8
Provision::Webproxy.restart_nginx_async

sleep 8
Provision::Webproxy.restart_nginx_async
