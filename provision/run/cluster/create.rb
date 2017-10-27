require_relative '../../config'

cluster_data = JSON.parse(ENV.fetch('cluster_data'))

#TODO
cluster_data['consul_ports'] = {
    dns: 10000,
    http: 10001,
    serf_lan: 10002,
    serf_wan: 10003,
    server: 10004
}

Chef::Config[:environment] = ENV.fetch('gex_env')
Chef::Config[:lockfile] = "/tmp/cluster_#{cluster_data.fetch('cluster_id')}"

chef_client = Chef::Application::Solo.new
chef_client.config[:override_runlist] = ['recipe[openvpn::create_consul]', 'recipe[provisioner::create_cluster]']

chef_client.set_json_attr(
    attributes: {
        cluster_id: ENV.fetch('cluster_id'),
        cluster_data: cluster_data
    }

)

chef_client.run