require 'gush'
require 'yaml'
require_relative 'config'

Config.load_conf(ENV.fetch('gex_env'))

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