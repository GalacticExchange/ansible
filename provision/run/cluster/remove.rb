require_relative '../../config'

cluster_data = JSON.parse(ENV.fetch('cluster_data'))

Chef::Config[:lockfile] = "/tmp/cluster_#{cluster_data.fetch('cluster_id')}"

chef_client = Chef::Application::Solo.new
chef_client.config[:override_runlist] = ['recipe[openvpn::remove_consul]']

chef_client.set_json_attr(
    attributes: {
        cluster_id: ENV.fetch('cluster_id'),
        cluster_data: cluster_data
    }
)

chef_client.run