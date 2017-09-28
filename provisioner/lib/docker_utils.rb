#module Provision
  class DockerUtils

    def self.dexec(server_name, cmd)
      conn = Docker::Connection.new(Config.server_docker_host(server_name), {})
      container_name = Config.server_config(server_name)['container_name']

      container = Docker::Container.get(container_name, {}, conn)

      # [msgs.stdout_messages, msgs.stderr_messages, self.json['ExitCode']]
      if cmd.is_a? String
        #a_cmd = ["bash -c #{cmd}"]
        #a_cmd = [cmd]
        a_cmd = [ "bash", "-c", cmd ]
      else
        a_cmd=cmd
      end
      res_cmd = container.exec(a_cmd)

      res_cmd
    end



    ### helpers

  end
#end
