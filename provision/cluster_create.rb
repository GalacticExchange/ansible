require_relative 'config'


Chef::Config[:environment] = ENV.fetch('gex_env')
Chef::Config[:lockfile] = "/tmp/#{Random.rand(5)}" #TODO

chef_client = Chef::Application::Solo.new
chef_client.config[:override_runlist] = ['recipe[openvpn::create_consul]']

chef_client.set_json_attr(
    {
        cluster_id: ENV.fetch('cluster_id'),
        cluster_data: JSON.parse(ENV.fetch('cluster_data'))
    }
)

chef_client.run