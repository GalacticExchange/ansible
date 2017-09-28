h = Config.redis_host
$redis = Redis.new(:host => Config.redis_host, :port => 6379)
