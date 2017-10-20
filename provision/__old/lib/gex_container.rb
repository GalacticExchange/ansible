require 'docker'
require 'erb'


class GexContainer

  attr_reader :container

  def initialize(host, container_name, port=2375)
    @conn = Docker::Connection.new("tcp://#{host}:#{port}", {})
    @container = Docker::Container.get(container_name, {}, @conn)
  end


  # TODO container may not have bash
  def exec(cmd)
    puts cmd
    @container.exec(['bash', '-c', cmd])
  end

  def template(source, destination, vars)
    res = ERB.new(File.read(source)).result(binding)
    @container.store_file(destination, res)
  end

  def update_supervisor
    exec 'supervisorctl reread'
    exec 'supervisorctl update'
  end

end

p GexContainer.new('51.1.0.51','gexcore-openvpn').exec('fail')