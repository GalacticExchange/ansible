class SshRunner
  ### ssh
  def self.run(ssh_options, cmd, _interaction_handler=nil)
    require 'sshkit'

    output = ""
    res = 0

    begin

      if cmd.is_a? Array
        a_cmd = cmd
      else
        a_cmd = [cmd]
      end

      # fix rvm
      #a_cmd.unshift('source /etc/profile.d/rvm.sh')

      #
      cmd = a_cmd.join '; '

      # debug
      #cmd = %Q(source /etc/profile.d/rvm.sh; cd /mount/ansible/provisioner && bundle exec cap main provision:test_task)


      #
      output = ''
      pwd = ssh_options.delete(:pwd)

      host = SSHKit::Host.new(ssh_options)
      host.password = pwd

      #
      ih = _interaction_handler
      #ih ||= interaction_handler_pwd(ssh_options[:user], pwd)

      SSHKit::Coordinator.new(host).each in: :sequence do
        #output = capture cmd
        a_cmd.each do |q|
          output << capture(q)
          #execute(q, interaction_handler: SSHKit::MappingInteractionHandler.new({}, :info))
          #execute(q, interaction_handler: ih)
        end
      end

      #Gexcore::GexLogger.info('debug_provision_script', "provision script 0 ok ", {})

      #
      return {res: 1, output: output}

    rescue => e
      #Gexcore::GexLogger.debug('debug_provision', "provision - exception", {e: e})

      return {
          res: 0,
          output: "error: "+e.message,
      }
    end
  end


  def self.ssh_exec!(ssh, command)
    stdout_data = ""
    stderr_data = ""
    exit_code = nil
    exit_signal = nil
    ssh.open_channel do |channel|
      channel.exec(command) do |ch, success|
        unless success
          abort "FAILED: couldn't execute command (ssh.channel.exec)"
        end
        channel.on_data do |ch,data|
          stdout_data+=data
        end

        channel.on_extended_data do |ch,type,data|
          stderr_data+=data
        end

        channel.on_request("exit-status") do |ch,data|
          exit_code = data.read_long
        end

        channel.on_request("exit-signal") do |ch, data|
          exit_signal = data.read_long
        end
      end
    end
    ssh.loop
    [stdout_data, stderr_data, exit_code, exit_signal]
  end



  def self.interaction_handler_pwd(user, pwd, host='')
    {
        "#{user}@#{host}'s password:" => "#{pwd}\n",
        /#{user}@#{host}'s password: */ => "#{pwd}\n",
        "password: " => "#{pwd}\n",
        "password:" => "#{pwd}\n",
        "Password: " => "#{pwd}\n",
    }
  end



  def self.sshkit_run_locally(&block)
    require 'sshkit'
    require 'sshkit/dsl'

    SSHKit::Backend::Local.new(&block).run
  end

  def self.sshkit_on(hosts, options={}, &block)
    require 'sshkit'
    require 'sshkit/dsl'

    SSHKit::Coordinator.new(hosts).each(options, &block)
  end

end
