def cpu_count
  return Java::Java.lang.Runtime.getRuntime.availableProcessors if defined? Java::Java
  return File.read('/proc/cpuinfo').scan(/^processor\s*:/).size if File.exist? '/proc/cpuinfo'
  require 'win32ole'

  result = WIN32OLE.connect("winmgmts://").ExecQuery("select NumberOfLogicalProcessors from Win32_Processor")
  result.to_enum.collect(&:NumberOfLogicalProcessors).reduce(:+)


rescue LoadError
  Integer `sysctl -n hw.ncpu 2>/dev/null` rescue 1
end


require 'getoptlong'


opts = GetoptLong.new(
    ['--image-file', GetoptLong::OPTIONAL_ARGUMENT],
    ['--app-name', GetoptLong::OPTIONAL_ARGUMENT],
    ['--json-file', GetoptLong::OPTIONAL_ARGUMENT],
    ['--container-name', GetoptLong::OPTIONAL_ARGUMENT],
    ['--action', GetoptLong::OPTIONAL_ARGUMENT],
)

image_file = ''
app_name = ''
app_config_json_file = ''
action = ''
container_name = ''

puts p

class Myexecutor

  def vboxmanage_path
    @vboxmanage_path
  end

  def initialize


    if Vagrant::Util::Platform.windows? || Vagrant::Util::Platform.cygwin?
      @vboxmanage_path = Vagrant::Util::Which.which("VBoxManage")

      # On Windows, we use the VBOX_INSTALL_PATH environmental
      # variable to find VBoxManage.
      if !@vboxmanage_path && (ENV.key?("VBOX_INSTALL_PATH") ||
          ENV.key?("VBOX_MSI_INSTALL_PATH"))

        # Get the path.
        path = ENV["VBOX_INSTALL_PATH"] || ENV["VBOX_MSI_INSTALL_PATH"]

        # There can actually be multiple paths in here, so we need to
        # split by the separator ";" and see which is a good one.
        path.split(";").each do |single|
          # Make sure it ends with a \
          single += "\\" unless single.end_with?("\\")

          # If the executable exists, then set it as the main path
          # and break out
          vboxmanage = "#{single}VBoxManage.exe"
          if File.file?(vboxmanage)
            @vboxmanage_path = Vagrant::Util::Platform.cygwin_windows_path(vboxmanage)
            break
          end
        end
      end

      # If we still don't have one, try to find it using common locations
      drive = ENV["SYSTEMDRIVE"] || "C:"
      [
          "#{drive}/Program Files/Oracle/VirtualBox",
          "#{drive}/Program Files (x86)/Oracle/VirtualBox",
          "#{ENV["PROGRAMFILES"]}/Oracle/VirtualBox"
      ].each do |maybe|
        path = File.join(maybe, "VBoxManage.exe")
        if File.file?(path)
          @vboxmanage_path = path
          break
        end
      end
    end

    # Fall back to hoping for the PATH to work out
    @vboxmanage_path ||= "VBoxManage"
  end


  def execute(*command, &block)
    # Get the options hash if it exists
    # noinspection RubyUnusedLocalVariable
    opts = {}
    # noinspection RubyUnusedLocalVariable
    opts = command.pop if command.last.is_a?(Hash)


    #retryable(on: Vagrant::Errors::VBoxManageError, tries: tries, sleep: 1) do

    # If there is an error with VBoxManage, this gets set to true
    errored = false

    # Execute the command
    r = raw(*command, &block)

    # If the command was a failure, then raise an exception that is
    # nicely handled by Vagrant.
    if r.exit_code != 0
      if @interrupted
        #@logger.info("Exit code != 0, but interrupted. Ignoring.")
      elsif r.exit_code == 126
        # This exit code happens if VBoxManage is on the PATH,
        # but another executable it tries to execute is missing.
        # This is usually indicative of a corrupted VirtualBox install.
        raise Vagrant::Errors::VBoxManageNotFoundError
      else
        errored = true
      end
    else
      # Sometimes, VBoxManage fails but doesn't actual return a non-zero
      # exit code. For this we inspect the output and determine if an error
      # occurred.

      if r.stderr =~ /failed to open \/dev\/vboxnetctl/i
        # This catches an error message that only shows when kernel
        # drivers aren't properly installed.
        #@logger.error("Error message about unable to open vboxnetctl")
        raise Vagrant::Errors::VirtualBoxKernelModuleNotLoaded
      end

      if r.stderr =~ /VBoxManage([.a-z]+?): error:/
        # This catches the generic VBoxManage error case.
        #@logger.info("VBoxManage error text found, assuming error.")
        errored = true
      end
    end

    # If there was an error running VBoxManage, show the error and the
    # output.
    if errored
      raise Vagrant::Errors::VBoxManageError,
            command: command.inspect,
            stderr: r.stderr,
            stdout: r.stdout
    end
    #end

    # Return the output, making sure to replace any Windows-style
    # newlines with Unix-style.
    r.stdout.gsub("\r\n", "\n")
  end


  # Executes a command and returns the raw result object.
  def raw(*command, &block)
    int_callback = lambda do
      @interrupted = true

      # We have to execute this in a thread due to trap contexts
      # and locks.
      Thread.new {@logger.info("Interrupted.")}.join
    end

    # Append in the options for subprocess
    command << {notify: [:stdout, :stderr]}

    Vagrant::Util::Busy.busy(int_callback) do
      Vagrant::Util::Subprocess.execute(@vboxmanage_path, *command, &block)
    end
  rescue Vagrant::Util::Subprocess::LaunchError => e
    raise Vagrant::Errors::VBoxManageLaunchError,
          message: e.to_s
  end

  def get_memory
    result = execute("list", "hostinfo")
    return /Memory size: (\d+)/.match(result)[1].to_i - 3000
  end

  def read_bridged_interfaces
    execute("list", "bridgedifs").split("\n\n").collect do |block|
      info = {}

      block.split("\n").each do |line|
        if (name = line[/^Name:\s+(.+?)$/, 1])
          info[:name] = name
        elsif (ip = line[/^IPAddress:\s+(.+?)$/, 1])
          info[:ip] = ip
        elsif (netmask = line[/^NetworkMask:\s+(.+?)$/, 1])
          info[:netmask] = netmask
        elsif (status = line[/^Status:\s+(.+?)$/, 1])
          info[:status] = status
        end
      end

      # Return the info to build up the results
      info
    end
  end


  def our_interface
    list = read_bridged_interfaces

    puts list.inspect


    if Vagrant::Util::Platform.windows? || Vagrant::Util::Platform.cygwin?
      list.delete_if {|interface| interface[:status] == "Down" || interface[:status] == "Unknown" || interface[:name]=~ /(vnic\d*|vmnet.*|p2p.*)/}
    else
      list.delete_if {|interface| interface.empty? || interface[:status] == "Down" || interface[:status] == "Unknown" || interface[:name][0] != "e" || interface[:name].include?("Wi")|| interface[:name].include?("wi")}
    end

    puts list.inspect

    if list.empty?
      puts("#ERROR: No active wired cards found. You need to connect your machine to a wired network.")
    end

    return list[0]
  end
end


Vagrant.configure(2) do |config|
  config.vm.box = "gex/client"
  #config.vm.hostname = "{{_node_name}}"
  config.vm.provision :shell, inline: "hostnamectl set-hostname #{p[:NODE_NAME]}"


  #begin
  #  config.vbguest.auto_update = false
  # do NOT download the iso file from a webserver
  #  config.vbguest.no_remote = true
  #rescue => e
  #end

  #config.ssh.password="vagrant"
  config.ssh.insert_key=false
  config.vm.box_check_update = false

  myexecutor = Myexecutor.new

  if p[:INTERFACE] && p[:INTERFACE] != "" && Vagrant::Util::Platform.windows?
    iface = p[:INTERFACE]
  elsif p[:IS_WIFI] == "true"
    iface = p[:INTERFACE]
  else
    iface = myexecutor.our_interface[:name]
  end

  if p[:IS_WIFI] == "true"
    config.vm.network "private_network", type: "dhcp"
  elsif iface == "unknown"
    config.vm.network "public_network"
  else
    config.vm.network "public_network", :bridge => iface
  end

  # config.vm.provision "shell",
  #  run: "always", inline: "ifconfig eth1 add " + p[:IP6_ADDRESS] + " up"

  config.vm.provision "shell", run: "always", inline: "ifconfig enp0s8 promisc"
  config.vm.provider "virtualbox" do |vb|
    vb.name = "gex_" + p[:CLUSTER_NAME] + "_" + p[:NODE_NAME]
    vb.memory = "6048"
    vb.cpus = cpu_count
    vb.customize ["modifyvm", :id, "--nicpromisc1", "allow-all"]
    vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
    vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
    vb.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
    #   vb.gui = true
  end

  if "#{p[:OPENVPN_IP]}".start_with?('46.172.71')
    system_type = ':main'
  else
    system_type = ':prod'
  end

  config.vm.provision "update_node", type: "shell" do |s2|
    s2.inline = "/usr/bin/timeout 5m ruby -r /home/vagrant/ruby_scripts/update_gexnode.rb -e \"update_deb(#{system_type},'gexnode-version.txt')\""
  end


  CMD = "/usr/bin/timeout 20m /home/vagrant/ruby_scripts/playbook.rb #{p[:NODE_NAME]} #{p[:NODE_NAME]} #{p[:SENSU_NODE_ID]} #{p[:SENSU_RMQUSER]} " \
       "#{p[:SENSU_RMQPWD]} #{p[:SENSU_RMQHOST]} #{p[:NAME_SERVER]} #{p[:SENSU_NAME]}"
  puts CMD

  config.vm.provision "configure", type: "shell" do |s|
    s.inline = CMD
  end

  SLAVE_CMD = "/usr/bin/timeout 20m /home/vagrant/ruby_scripts/slaveplaybook.rb  #{p[:HADOOP_MASTER_IP]} #{p[:API_IP]} #{p[:NAME_SERVER]}  #{p[:CLUSTER_ID]} #{p[:NODE_ID]} #{p[:NODE_UID]} #{p[:CLUSTER_UID]} " +
      "#{p[:OPENVPN_IP]} #{p[:OPENVPN_PORT]} #{p[:TUNNEL_CLIENT_IP]}  #{p[:TUNNEL_SERVER_IP]} #{p[:TUNNEL_PORT]} #{p[:SOCKS_PROXY_IP]} #{p[:STATIC_IPS]} '#{p[:CONTAINER_IPS]}' " +
      "#{p[:NETWORK_MASK]} #{p[:GATEWAY_IP]}  "

  puts SLAVE_CMD


  config.vm.provision "configureslave", type: "shell" do |s2|
    s2.inline = SLAVE_CMD
  end

  if ARGV.include? 'install_container'

    opts.each do |opt, arg|
      case opt
        when '--image-file'
          image_file=arg
        when '--app-name'
          app_name=arg
        when '--json-file'
          app_config_json_file=arg
        else

      end
    end


    config.vm.provision "install_container", type: "shell" do |s2|
      puts "Install container args #{image_file} #{app_name}"
      if image_file == '' || app_name == ''
        puts "Empty argument"
        exit 1
      end
      cmd2 = "/usr/bin/timeout 20m /home/vagrant/ruby_scripts/install_container.rb /vagrant/#{image_file} #{app_name}"
      puts cmd2
      s2.inline = cmd2
    end
  end

  if ARGV.include? 'run_container'

    opts.each do |opt, arg|
      case opt
        when '--image-file'
          image_file=arg
        when '--app-name'
          app_name=arg
        when '--json-file'
          app_config_json_file=arg
        else

      end
    end

    config.vm.provision "run_container", type: "shell" do |s2|
      puts "Run container args #{app_name} #{app_config_json_file}"
      if app_config_json_file == '' || app_name == ''
        puts "Empty arguments"
        exit 1
      end
      cmd2 = "/usr/bin/timeout 30m /home/vagrant/ruby_scripts/run_container.rb #{app_name} #{app_config_json_file} "
      puts cmd2
      s2.inline = cmd2
    end
  end

  if ARGV.include? 'remove_container'

    opts.each do |opt, arg|
      case opt
        when '--app-name'
          app_name=arg
        else
      end
    end

    config.vm.provision "remove_container", type: "shell" do |s2|
      puts "Remove container args #{app_name}"
      if app_name == ''
        puts "Empty arguments"
        exit 1
      end
      s2.inline ="/usr/bin/timeout 10m /home/vagrant/ruby_scripts/remove_container.rb #{app_name} "
    end
  end

  if ARGV.include? 'change_container_state'

    opts.each do |opt, arg|
      case opt
        when '--action'
          action=arg
        when '--container-name'
          container_name=arg
        else

      end
    end

    config.vm.provision "change_container_state", type: "shell" do |s2|
      puts "Change container state args #{container_name} #{action}"
      if container_name == '' || action == ''
        puts "Empty arguments"
        exit 1
      end
      cmd2 = "container_name=#{container_name} action=#{action} /usr/bin/timeout 5m ruby /home/vagrant/ruby_scripts/change_container_state.rb"
      puts cmd2
      s2.inline = cmd2
    end
  end

end
