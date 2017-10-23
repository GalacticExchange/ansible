require 'chef'
require 'chef/application/solo'


class Chef::Application::Solo
  def set_json_attr(attr_hash)
    @chef_client_json = attr_hash
  end
end

Chef::Config[:color] = true
Chef::Config[:solo_legacy_mode] = true
Chef::Config[:cookbook_path] = [File.join(File.absolute_path(File.dirname(__FILE__)), 'cookbooks')]
Chef::Config[:environment_path] = File.join(File.absolute_path(File.dirname(__FILE__)), 'environments')
Chef::Config[:environment] = 'main' #TODO

Chef::Config[:lockfile] = "/tmp/#{Random.rand(5)}" #TODO

chef_client = Chef::Application::Solo.new

chef_client.config[:override_runlist] = ['recipe[openvpn::create_consul]']


chef_client.set_json_attr(
    {
        zzz: '555'
    }
)
chef_client.run