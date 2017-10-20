module DockerCookbook
  class DockerExec < DockerBase
    resource_name :docker_exec

    property :host, [String, nil], default: lazy {default_host}
    property :command, Array
    property :container, String
    property :timeout, Numeric, default: 60
    property :container_obj, Docker::Container, desired_state: false

    property :ignore_failure, [TrueClass, FalseClass], default: false

    alias cmd command

    action :run do
      converge_by "executing #{new_resource.command} on #{new_resource.container}" do
        with_retries {new_resource.container_obj Docker::Container.get(new_resource.container, {}, connection)}
        res = new_resource.container_obj.exec(new_resource.command, wait: new_resource.timeout)
        unless new_resource.ignore_failure
          if res[2] != 0
            raise Chef::Exceptions::Exec, res[0]
          end
        end
      end
    end
  end
end
