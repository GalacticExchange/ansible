require 'httparty'

require_relative 'consul_utils'

module ConsulSpecUtils
  extend ConsulUtils


  def self.consul_get(key)
    http_party_get(key)
  end

  def self.http_party_get(key)
    resp = HTTParty.get("#{Diplomat.configuration.url}/v1/kv/#{key}?raw")
    raise "Consul response fail code: #{resp.code}; key: #{key}" if resp.code != 200
    resp.body
  end


end