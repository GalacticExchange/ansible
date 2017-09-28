#!/usr/bin/env ruby

require 'erb'

module OpenVPN

  OPENVPN_CONF = File.join(File.dirname(__FILE__),'conf')

  def setup_openvpn_server
    @range = '10.176.0.0'
    @mask = '255.255.0.0' #16

    puts 'source dest check disable'
    @fog.modify_instance_attribute(@instance.id,{'SourceDestCheck.Value' => false})

    puts 'installing openvpn'
    @instance.ssh(%Q(sudo apt-get install -y openvpn))

    puts 'scp upload server conf'
    @instance.scp_upload(File.join(OPENVPN_CONF,'server.conf'), '/home/vagrant/', :recursive => true)

  end

  def setup_client_conf
    template = File.read("#{File.join(OPENVPN_CONF,'client.conf.erb')}")
    client_conf = File.new("#{File.join(OPENVPN_CONF,'client.conf')}", 'w')
    client_conf.puts(ERB.new(template).result(binding))
  end

  def run_openvpn_server
    setup_openvpn_server
    @instance.ssh(%Q(sudo openvpn --daemon --config /home/vagrant/server.conf))
    setup_client_conf
  end

  def run_openvpn_client
    `sudo openvpn --daemon --config #{File.join(OPENVPN_CONF,'client.conf')}`
  end
end