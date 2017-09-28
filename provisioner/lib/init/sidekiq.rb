require 'sidekiq'
require 'sidekiq-unique-jobs'



###
Sidekiq.configure_server do |config|
  config.redis = {
      url: "redis://#{Config.redis_host}:6379/0",
      namespace: "#{Config.sidekiq_redis_prefix}",
  }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{Config.redis_host}:6379/0",
                   namespace: "#{Config.sidekiq_redis_prefix}" }
end


Dir["workers/*.rb"].each do |f|
  require_relative "../../#{f}"
end


