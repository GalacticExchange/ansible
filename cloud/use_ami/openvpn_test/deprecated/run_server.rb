#!/usr/bin/env ruby
require_relative 'openvpn_instance'

open_vpn_server = OpenVpnServer.new(:cluster_id => 112)
open_vpn_server.start_new
open_vpn_server.run_openvpn_server