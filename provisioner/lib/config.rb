module Config

  @@app_env = nil
  @@gex_config = nil


  def self.app_env
    return @@app_env unless @@app_env.nil?

    #
    @@app_env = ENV.fetch('_gex_env', 'main')


    @@app_env
  end


  def self.load_config
    @@gex_config = {}
    @@srv_hosts = {}

    require 'yaml'

    f = File.join(File.dirname(__FILE__), "../config/gex/#{app_env}.yml")
    h =YAML.load_file(f)

    #puts "h: #{h}"
    #@@gex_config = h.inject({}){|memo,(k,v)| memo[k.to_s] = v; memo}
    @@gex_config = h


  end

  def self.gex_config
    return @@gex_config unless @@gex_config.nil?

    load_config

    @@gex_config
  end


  def self.server_config(server_name)
    srv_config = gex_config["server_#{server_name}"]
  end

  def self.server_docker_host(server_name)
    srv_config = server_config(server_name)

    "#{srv_config['docker_engine']}"
  end

  ###

  def self.method_missing(method_sym, *arguments, &block)
    gex_config[method_sym.to_s] || gex_config[method_sym]
  end

  def self.srv_host(name)
    gex_config

    return @@srv_hosts[name] if @@srv_hosts[name]

    srv_cfg = gex_config["server_#{name}"]
    @@srv_hosts[name] = SSHKit::Host.new({hostname: srv_cfg['server_host'], user: srv_cfg['server_user'], password: srv_cfg['server_pwd']})

    @@srv_hosts[name]
  end


  def self.srv_hosts
    @@srv_hosts
  end

end
