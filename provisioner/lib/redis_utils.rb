class RedisUtils
  def self.get(key, v_def=nil)
    redis_key = build_key(key)
    v = $redis.get(redis_key)

    if v.nil?
      v = v_def
    end

    v
  end

  def self.set(k, v, ttl=24*60*60)
    key = build_key(k)
    $redis.set key, v
    $redis.expire key, ttl
  end

  def self.build_key(k)
    "#{Config.redis_prefix}:#{k}"
  end

end
