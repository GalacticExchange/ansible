require 'diplomat'
require 'timeout'
require 'json'

require_relative 'config'
require_relative 'data_converter'
require_relative 'gex_logger'


module ConsulUtils
  extend self

  #include Config

  def connect(cluster_id)
    port = consul_ports(cluster_id)[:http]

    puts "Connecting to Consul (#{Config.server_openvpn['host']}:#{port})"

    Diplomat.configure do |config|
      config.url = "http://#{Config.server_openvpn['host']}:#{port}"
    end
    puts 'Done'
  end

  def consul_ports(cluster_id)
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

  def consul_get(key)
    Diplomat::Kv.get(key)
  end

  def delete(key)
    GEX_LOGGER.debug("delete : #{key}")
    Diplomat::Kv.delete(key)
  end

  def get_cluster_data(cluster_id = nil)
    connect(cluster_id) if cluster_id

    JSON.parse(consul_get('/info/cluster_data.json'))
  end

  def get_node_data(node_id)
    #JSON.parse(consul_get("/nodes/id/#{node_id}/node_data.json"))
    DataConverter.convert_node_data(consul_get("/nodes/id/#{node_id}/node_data.json"))
  end

  def get_node_data_raw(node_id)
    JSON.parse(consul_get("/nodes/id/#{node_id}/node_data.json"))
  end

  def get_app_data(app_id)
    JSON.parse(consul_get("/apps/id/#{app_id}/app_data.json"))
  end

  def get_app_data_config(app_id)
    JSON.parse(consul_get("/apps/id/#{app_id}/app_settings.json"))
  end

  def set_cluster_data(cluster_data)
    cluster_data.merge!(cluster_data) {|k, v| v.to_s}
    data = cluster_data.to_json
    Diplomat::Kv.put('/info/cluster_data.json', data)
  end

  def set_node_data(node_data, node_id)
    node_data.merge!(node_data) {|k, v| v.to_s}
    #node_id = node_data.fetch('_node_id')
    data = node_data.to_json
    Diplomat::Kv.put("/nodes/id/#{node_id}/node_data.json", data)
  end

  def update_cluster_data(cluster_id, cluster_data)
    connect(cluster_id)
    set_cluster_data(cluster_data)
  end

  def update_node_data(cluster_id, node_id, node_data)
    connect(cluster_id)

    consul_node_data = get_node_data_raw(node_id)
    consul_node_data.merge!(node_data)

    set_node_data(consul_node_data, node_id)
  end

  def set_app_data(app_data)
    #app_data.merge!(app_data) {|k, v| v.to_s}
    app_id = app_data.fetch('id')
    data = app_data.to_json
    Diplomat::Kv.put("/apps/id/#{app_id}/app_data.json", data)
  end

  def update_app_data(cluster_id, app_data)
    connect(cluster_id)
    app_data = get_app_data(app_data.fetch('id')).deep_merge(app_data)
    set_app_data(app_data)
  end

  def lock_exec(cluster_id, lock_name)


    #force_unlock = Proc.new {
    #  puts "deleting key: /lock/#{lock_name}"
    #  Diplomat::Kv.delete("/lock/#{lock_name}")
    #}


    #wait_for_block("wait for lock: #{lock_name}, cluster_id: #{cluster_id}", force_unlock) {
    #  Diplomat::Lock.wait_to_acquire("/lock/#{lock_name}", sessionid, '1')
    #}

    acquired, sessionid = wait_acquire_lock(cluster_id, lock_name, 600, true)
    GEX_LOGGER.set_cluster_id(cluster_id).debug("lock acquire: #{acquired}")

    if acquired

      begin
        yield
      rescue => e
        force_unlock(lock_name)
        GEX_LOGGER.fatal("Yield exception: #{e.backtrace}")
        raise "#{e.backtrace}"
      end

      Diplomat::Lock.release("/lock/#{lock_name}", sessionid)

    else

      GEX_LOGGER.fatal("Cannot acquire lock: #{lock_name}")

      force_unlock(lock_name)

      raise "Cannot acquire lock: #{lock_name}"
    end

=begin
    begin
      yield
    rescue => e
      force_unlock.call
      raise "#{e.backtrace}"
    end
=end


  end

  def force_unlock(lock_name)
    GEX_LOGGER.fatal("force unlock : #{lock_name}")
    delete(lock_key(lock_name))
    GEX_LOGGER.fatal("force unlock key : #{lock_key(lock_name)}")
  end

  #def release_lock(lock_name)
  #Diplomat::Lock.release("#{lock_name}", sessionid)
  #end

  #def wait_for_block(msg, proc = nil)
  #  begin
  #    Timeout::timeout(600) {yield}
  #  rescue Timeout::Error
  #    proc.call if proc != nil
  #    raise "Timeout error: #{msg}"
  #  end
  #end

  def lock_key(lock_name)
    "/lock/#{lock_name}"
  end

  def wait_acquire_lock(cluster_id, lock_name, t=600, del=true)
    lock_acquired = false

    sessionid = Diplomat::Session.create({:Node => "consul-#{cluster_id}", :Name => "#{lock_name}-lock"})
    puts sessionid
    begin
      Timeout::timeout(t) do
        lock_acquired = Diplomat::Lock.wait_to_acquire(lock_key(lock_name), sessionid, '1')
      end
    rescue Timeout::Error => e
      puts "acquire inside Timeout error:# #{e.backtrace}"
      if del
        #delete lock
        force_unlock(lock_name)
      end

      return false
    end


    return lock_acquired, sessionid
  end


  def get_container_data

  end

  def set_container_data(container_data)
    container_data.merge!(container_data) {|k, v| v.to_s}
    container_id = container_data.fetch('id')
    data = container_data.to_json
    Diplomat::Kv.put("/nodes/id/#{container_id}/node_data.json", data)
  end

  def get_keys(prefix)
    Diplomat::Kv.get(prefix, :keys => true)
  end

  def get_nodes_ids
    begin
      return get_keys('/nodes/id').map{|e| e.gsub(/nodes\/id|node_data.json|\//,'') }
    rescue => e
      puts "Exception caught: #{e.backtrace}"
      []
    end
  end


  def get_apps_ids
    begin
      get_keys('/apps/id').map{|e| e.gsub(/nodes\/id|node_data.json|\//,'') }
    rescue => e
      puts "Exception caught: #{e.backtrace}"
      []
    end
  end

  #def update_data
  #  unless ENV.fetch('_cluster_data','').empty
  #    cluster_data = DataConverter.convert_cluster_data(ENV.fetch('_cluster_data'),'')
  #    update_cluster_data(cluster_data.fetch(''))
  #  end
  #end

end
