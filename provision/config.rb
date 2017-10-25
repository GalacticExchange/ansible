require 'chef'
require 'chef/application/solo'
require 'json'

class Chef::Application::Solo
  def set_json_attr(attr_hash)
    @chef_client_json = attr_hash
  end
end

Chef::Config[:color] = true
Chef::Config[:solo_legacy_mode] = true
Chef::Config[:cookbook_path] = [File.join(File.absolute_path(File.dirname(__FILE__)), 'cookbooks')]
Chef::Config[:environment_path] = File.join(File.absolute_path(File.dirname(__FILE__)), 'environments')
Chef::Config[:environment] = ENV.fetch('gex_env')
