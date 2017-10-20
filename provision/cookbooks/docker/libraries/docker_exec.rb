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
      converge_by "executing #{command} on #{container}" do
        with_retries {container_obj Docker::Container.get(container, {}, connection)}
        res = container_obj.exec(command, wait: timeout)
        unless ignore_failure
          if res[2] != 0
            raise Chef::Exceptions::Exec, res[0]
          end
        end
      end
    end
  end
end
