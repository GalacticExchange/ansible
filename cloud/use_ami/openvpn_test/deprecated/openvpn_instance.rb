#!/usr/bin/env ruby
require 'net/http'
require 'erb'
require_relative '../lib/gex_aws'
#require File.join(Dir.pwd, '/gex_aws')
=begin
class OpenVpnServer < GexAWS
  # @fog -> basic fog object
  # @instance_ami_id -> clusterGX instance ami id

  def initialize (params ={} )
    @instance_ami_id = Net::HTTP.get(URI('https://gex-ami-ids.s3-us-west-1.amazonaws.com/coordinator_ami_id.txt')).strip
    @range = '24.0.0.0'
    @mask = '255.255.0.0'
    super
  end

  def start_new
    super
    @fog.tags.create(:resource_id => @instance.identity, :key => 'Name', :value => 'OpenVPN')
  end


  def setup_openvpn_server
    #Modifying source destination check
    puts 'source dest check disable'
    @fog.modify_instance_attribute(@instance.id,{'SourceDestCheck.Value' => false})

    puts 'installing openvpn'
    @instance.ssh(%Q(sudo apt-get install -y openvpn))


    setup_openvpn_server_conf

    puts 'scp upload server conf'
    @instance.scp_upload('/work/ansible/cloud/use_ami/openvpn_test/openvpn/server.conf', '/home/vagrant/', :recursive => true)

    puts 'saving openvpn ip'
    @cluster_data[:open_vpn_server_ip] = @instance.private_ip_address
    save_cluster_data

  end
  #File.new('/work/ansible/cloud/use_ami/openvpn_test/OPENVPN_SERVER_IP', 'w').puts(@instance.private_ip_address)


  def setup_openvpn_client
    template = File.read('/work/ansible/cloud/use_ami/openvpn_test/openvpn/client.conf.erb') #TODO
    client_conf = File.new('/work/ansible/cloud/use_ami/openvpn_test/client.conf', 'w') #TODO
    client_conf.puts(ERB.new(template).result(binding))
  end

  def setup_openvpn_server_conf
    template = File.read('/work/ansible/cloud/use_ami/openvpn_test/openvpn/server.conf.erb') #TODO
    server_conf = File.new('/work/ansible/cloud/use_ami/openvpn_test/openvpn/server.conf', 'w') #TODO
    server_conf.puts(ERB.new(template).result(binding))
  end

  def run_openvpn_server
    setup_openvpn_server
    @instance.ssh(%Q(sudo openvpn --daemon --config /home/vagrant/server.conf))
    setup_openvpn_client
  end



  def run_openvpn_client
    `openvpn --daemon --config /work/ansible/cloud/use_ami/openvpn_test/client.conf`
  end


  private :setup_openvpn_server, :setup_openvpn_client

end

=begin
open_vpn_server = OpenVpnServer.new('PH_GEX_AWS_KEY','PH_GEX_AWS_ID')
open_vpn_server.start_new
open_vpn_server.run_openvpn_server

sleep(5)
open_vpn_server.run_openvpn_client

=end