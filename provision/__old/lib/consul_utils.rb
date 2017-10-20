class ConsulUtils

  def self.consul_ports(cluster_id)
    max = cluster_id.to_i * 5
    arr = (max).downto(max-4).to_a
    {
        dns: 40000 + arr[0],
        http: 40000 + arr[1],
        serf_lan: 40000 + arr[2],
        serf_wan: 40000 + arr[3],
        server: 40000 + arr[4]
    }
  end

  def self.wait_for_consul(cluster_id)

    60.times do |t|
      result = `curl 51.0.1.8:#{consul_ports(cluster_id)[:http]}/v1/status/leader`
      if result.gsub('"', '') == "51.0.1.8:#{consul_ports(cluster_id)[:server]}"
        break
      end
      raise 'Cannot wait for consul started' if t == 59
      sleep 10
    end

  end

end