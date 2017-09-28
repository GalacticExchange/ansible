require_relative 'lib/init'
require_relative 'lib/init/sidekiq'

redis_namespace = "#{Config.redis_prefix}:gush"

Gush.configure do |c|
  #c.environment = gex_env
  c.redis_url = "redis://#{Config.redis_host}:6379"
  c.namespace = redis_namespace

end

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{Config.redis_host}:6379/0", namespace: "#{redis_namespace}", queue: Gush.configuration.namespace }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{Config.redis_host}:6379/0", namespace: "#{redis_namespace}", queue: Gush.configuration.namespace }
end


job_id = '111'
