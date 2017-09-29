
module MainEnv

  DEFAULT_KEY_ID = 'PH_GEX_KEY_ID'
  DEFAULT_KEY_SECRET = 'PH_GEX_ACESS_KEY'


  def forward_main_env
    #vpn_instance = get_vpn_instance
    #restart_vpn_weave(vpn_instance)
    #connect_vpn_weave
    #expose_vpn_weave(vpn_instance)
    configure_routes_and_hosts
  end

  def connect_vpn_weave
    ssh("weave connect #{Helper::VPN_AWS_IP}")
  end

  def get_vpn_instance
    fog  = Fog::Compute.new(
        :provider => 'AWS',
        :region => 'us-west-2',
        :aws_access_key_id => DEFAULT_KEY_ID,
        :aws_secret_access_key => DEFAULT_KEY_SECRET
    )
    instance = fog.servers.get(Helper::VPN_AWS_ID)
    instance.private_key_path = File.join(File.dirname(__FILE__),'GEXExp.pem')
    instance.username = 'ubuntu'
    instance
  end

  def restart_vpn_weave(vpn_instance)
    vpn_instance.ssh('weave reset')
    vpn_instance.ssh('weave stop')
    vpn_instance.ssh("weave launch --ipalloc-range #{Helper::CIDR_WEAVE}")
  end

  def expose_vpn_weave(vpn_instance)
    vpn_instance.ssh("weave expose #{Helper::VPN_WEAVE_IP}/16")
  end

  def configure_routes_and_hosts
    ssh('sudo cp /home/vagrant/gexstarter/aws_scripts/vpn_client_main/* /etc/openvpn/')
    ssh('sudo cp /home/vagrant/gexstarter/aws_scripts/routes_main.service /etc/systemd/system/')
    ssh('sudo systemctl enable routes_main.service && sudo service routes_main start |true')
    ssh(%Q(sudo /home/vagrant/gexstarter/hosts_local/hosts.sh))
  end

  def hot_fix
    ssh(%Q(sudo sed -i '/api.gex/c\\10.1.0.12 api.gex' /etc/hosts))
    ssh(%Q(sudo sed -i '/apiUrl = api.gex/c\\apiUrl = api.gex:3000' /etc/gex/config.properties))
    ssh(%Q(sudo supervisorctl restart gexd))
    ssh(%Q(sudo ip route replace 10.1.0.0/16 via #{Helper::VPN_WEAVE_IP}))
  end

  def check_for_gexd(port)
    cmd = "curl http://localhost:#{port}/itsalive"
    retries = 0
    begin
      ssh(cmd)
    rescue Exception => e
      #puts "Exception handled: #{e.message}"
      retries = retries + 1
      if retries > 10
        raise 'GEXD check_for retries amount exceeded'
      end
      sleep(5)
      retry
    end
  end


end