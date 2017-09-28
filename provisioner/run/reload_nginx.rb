require_relative '../lib/init'
require_relative '../lib/init/sidekiq'
require_relative '../lib/init/gush'


Provision::Webproxy.reload_nginx_async