require_relative 'lib/init'
require_relative 'lib/init/sidekiq'
require_relative 'lib/init/gush'

#logger = Logger.new(File.join('log', 'gush.log'))
#logger.level = Logger::DEBUG


# sidekiq options
log_file = File.join('log', 'sidekiq-provision-gush.log')
pid_file = File.join("tmp/pids/", 'sidekiq-provision-gush.pid')
stop_timeout = 1800

Gush.configure do |c|
 # -e #{Config.gex_env}
 c.sidekiq_options = " -t #{stop_timeout} -L #{log_file} -P #{pid_file} "

end
