require 'fog/aws'
require 'json'
require 'net/ssh'

require_relative 'helper'
require_relative 'aws_utils'

class GexAWS
  include AwsUtils

  # @fog -> basic fog object
  # @instance_ami_id -> clusterGX coordinator/container ami id
  # @instance
  # @config
  attr_reader :fog, :instance, :instance_ami_id, :config, :instance_type


  def initialize (params = {})

    @volume_size = nil

    @config = Helper::Config.new(params)

    @fog = Fog::Compute.new(
        :provider => 'AWS',
        :region => @config.cluster_data.fetch(:region),
        :aws_access_key_id => @config.cluster_data.fetch(:aws_access_key_id),
        :aws_secret_access_key => @config.cluster_data.fetch(:aws_secret_access_key)
    )
  end


  def start_new
    # @instance_ami_id will be defined in subclasses

    if @instance_type.to_s == ''
      @instance_type ='t2.micro'
    end
#        'Ebs.VolumeSize'


    instance_params = {
        'InstanceType' => @instance_type,
        'SecurityGroupId' => @config.cluster_data.fetch(:security_group_id),
        'KeyName' => @config.cluster_data.fetch(:key_name),
        'SubnetId' => @config.cluster_data.fetch(:subnet_id)
    }

    unless @volume_size.nil?
      instance_params['BlockDeviceMapping'] = ['Ebs.VolumeSize' => @volume_size, 'DeviceName' => '/dev/sda1']
    end

    response = @fog.run_instances(
        @instance_ami_id,
        1,
        1,
        instance_params
    )

#Possible delay
    sleep(2)

    instance_id = response.body['instancesSet'].first['instanceId']

    @instance = @fog.servers.get(instance_id)
    @instance.private_key_path = @config.key_path
    @instance.wait_for {print '.'; ready?}

    @fog.create_tags(@instance.id, 'cluster_uid' => @config.cluster_data.fetch(:cluster_uid))

    check_for
    configure_vagrant
  end

  def check_for
    @instance.username = 'ubuntu' #default aws user
    puts "key path: #{@config.key_path}"
    print 'waiting for instance to be totally ready'

    i = 0
    begin
      @instance.ssh(%Q(echo hello world!))
    rescue Net::SSH::ConnectionTimeout, Errno::ECONNREFUSED, Timeout::Error, Net::SSH::Disconnect => e #TODO
      i = i + 1
      raise('Retries amount exceeded maximum') if i > Helper::MAX_RETRIES_AMOUNT
      puts "Exception handled: #{e.message}"
      print('.')
      sleep(10)
      retry
    end
    puts 'READY!'

  end

  def docker_check
    return if Fog.mock?

    result = @instance.ssh(%Q(sudo systemctl is-active docker))
    return true if result[0].status == 0

    retries = 10
    interval_seconds = 30
    n_try = 0

    while n_try != retries

      @instance.ssh(%Q(sudo service docker start))

      result = @instance.ssh(%Q(sudo systemctl is-active docker))
      break if result[0].status == 0

      n_try = n_try + 1

      sleep interval_seconds
    end

    raise 'Cannot wait for docker service to start' if n_try == retries

    true
  end

  def launch_weave
    puts 'launching weave'
    @instance.ssh(%Q(sudo weave launch --ipalloc-range #{Helper::CIDR_WEAVE}))
    @instance.ssh(%Q(sudo weave expose))
  end

  def launch_weave_node
    docker_check

    @instance.ssh(%Q(sudo weave launch #{@config.cluster_data.fetch(:coordinator_private_ip)} --ipalloc-range #{Helper::CIDR_WEAVE}))
    @instance.ssh(%Q(eval $(weave env)))

    @instance.ssh(%Q(sudo weave stop-proxy))
    @instance.ssh(%Q(sudo sudo weave launch-proxy --no-rewrite-hosts))
  end

  def connect_to_instance(instance_aws_id)
    if @instance != nil
      raise Exception.new('This object already has a connection to instance')
    end
    @instance = @fog.servers.get(instance_aws_id)
    @instance.private_key_path = @config.key_path
    @instance.username = 'vagrant'
  end

  def configure_vagrant
    @instance.private_key_path = @config.key_path
    @instance.username = 'ubuntu'

    @instance.ssh(%Q(sudo cp -R /home/ubuntu/.ssh /home/vagrant/))

    @instance.ssh(%Q(sudo chmod 700 /home/vagrant/.ssh ))
    @instance.ssh(%Q(sudo chmod 600 /home/vagrant/.ssh/authorized_key ))
    @instance.ssh(%Q(sudo chown -R vagrant /home/vagrant/.ssh/ ))

    @instance.username = 'vagrant'
  end

  def save_cluster_data
    File.write(@config.cluster_json_file_path, JSON.pretty_generate(@config.cluster_data))
  end

  def update_aws_credentials(aws_key_id, aws_key_secret)
    @config.cluster_data[:aws_access_key_id] = aws_key_id
    @config.cluster_data[:aws_secret_access_key] = aws_key_secret
    save_cluster_data
  end

  def ssh(cmd)
    result = @instance.ssh(cmd)
    return if Fog.mock?

    if result[0].status != 0
      raise("SSH command failed: #{cmd}, stdout: #{result[0].stdout}, stderr: #{result[0].stderr}")
    end
    result
  end

  def scp(source, dest)
    @instance.scp_upload(source, dest, :recursive => true)
  end

  def add_tag(key, val)
    @fog.create_tags(@instance.id, key => val)
  end

  def terminate
    @fog.terminate_instances(@instance.id)
    puts "terminating instance #{@instance.id}"
    wait_for_state('terminated', @instance.id)
  end

  #def get_state
  #  resp = @fog.describe_instances('instance-id' => @instance.id)
  #  resp.body['reservationSet'][0]['instancesSet'][0]['instanceState']['name']
  #end

  def get_ami_id
    url = "https://gex-ami-ids.s3-us-west-1.amazonaws.com/#{@config.cluster_data.fetch(:region)}_#{@file_suffix}"
    Net::HTTP.get(URI(url)).strip
  end

  def stop
    @fog.stop_instances([@instance.id])
    wait_for_state('stopped', @instance.id)
  end

  def start
    return if get_state(@instance.id) == 'running'

    @fog.start_instances([@instance.id])
    wait_for_state('running', @instance.id)
  end

  def reboot
    raise 'Cannot reboot: Wrong initial state' if get_state(@instance.id) != 'running'
    @fog.reboot_instances([@instance.id])
    #wait_for_state('running')
  end

  def change_instance_state(action)
    send(action)
  end

  #def wait_for_state(state)
  #  count = 0
  #  while get_state != state
  #    count = count + 1
  #    sleep(15)
  #    raise ('Cannot change state') if count > Helper::MAX_RETRIES_AMOUNT
  #  end
  #end

  private :check_for

end