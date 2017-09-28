require 'gush'

puts "init gush"

# options
redis_prefix = Config.sidekiq_redis_prefix
sidekiq_queue = ENV['queue'] || 'provisiongush'
concurrency = ENV['concurrency'] || 1

#
Gush.configure do |c|
  c.environment = Config.gex_env
  c.redis_url = "redis://#{Config.redis_host}:6379"
  #c.namespace = redis_prefix
  c.redis_prefix = redis_prefix
  c.sidekiq_queue = sidekiq_queue

  c.concurrency = concurrency

end

=begin
Sidekiq.configure_server do |config|
  #config.redis = { url: "redis://#{Config.redis_host}:6379/0", namespace: "#{sidekiq_namespace}", queue: sidekiq_queue }
  config.redis = { url: "redis://#{Config.redis_host}:6379/0",
                   namespace: redis_prefix,
                   queue: sidekiq_queue }
end

Sidekiq.configure_client do |config|
  #config.redis = { url: "redis://#{Config.redis_host}:6379/0", namespace: "#{sidekiq_namespace}", queue: sidekiq_queue }
  config.redis = { url: "redis://#{Config.redis_host}:6379/0",
                   namespace: redis_prefix,
                   queue: sidekiq_queue }
end
=end
#puts "c=#{Gush.configuration.inspect}"

Gush.reconfigure_sidekiq


# gush

Dir['jobs/*.rb'].each do |f|
  require_relative "../../#{f}"
end
Dir['workflows/*.rb'].each do |f|
  require_relative "../../#{f}"
end
