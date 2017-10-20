require 'chef/provider/template_finder'
require 'chef/provider/file'

require 'erb'

module DockerCookbook
  class DockerTemplate < DockerBase
    resource_name :docker_template

    property :destination, String, name_property: true
    property :host, [String, nil], default: lazy {default_host}
    property :cookbook, [String, nil], default: lazy {cookbook_name}
    property :source, String
    property :container, String
    property :timeout, Numeric, default: 60

    property :container_obj, Docker::Container, desired_state: false


    action :run do
      converge_by 'processing template...' do
        with_retries {new_resource.container_obj Docker::Container.get(new_resource.container, {}, connection)}
        process_template(get_template_path, new_resource.destination)
      end
    end


    def template_exist?(template_path)
      ::File.exist?(template_path)
    end

    def get_template_path
      ::File.join(Chef::Config[:cookbook_path], cookbook, 'templates', source)
    end

    def process_template(source, destination)
      #Chef::Log.warn(node)
      processed_data = ERB.new(::File.read(source)).result(binding)
      container_obj.store_file(destination, processed_data)
    end

  end
end
