require 'gush'
require 'yaml'

base_dir = File.dirname(__FILE__)
Dir[File.join(base_dir, 'lib/*.rb'), File.join(base_dir, 'lib/provision/*.rb')].each do |file|
  require_relative file
end

# options
redis_prefix = Config.sidekiq_redis_prefix
sidekiq_queue = ENV['queue'] || 'provisiongush'
concurrency = ENV['concurrency'] || 1

Gush.configure do |c|
  c.environment = Config.gex_env
  c.redis_url = "redis://#{Config.redis_host}:6379"
  c.redis_prefix = redis_prefix
  c.sidekiq_queue = sidekiq_queue
  c.concurrency = concurrency
end

Gush.reconfigure_sidekiq


Dir[File.join(base_dir, 'jobs/*.rb'), File.join(base_dir, 'workflows/*.rb')].each do |file|
  require_relative file
end


Sidekiq.configure_client do |config|
  config.redis = {url: "redis://#{Config.redis_host}:6379/0",
                  namespace: "#{Config.sidekiq_redis_prefix}"}
end
