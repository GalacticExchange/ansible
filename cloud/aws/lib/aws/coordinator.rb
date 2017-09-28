module AWS

  class Coordinator < Core::Base

    include Actions::Instance

    def create
      debug('Creating coordinator')
      ami_pattern = '*coordinator*'
      set_config('ami_id', get_ami_id(ami_pattern))
      coordinator_user_data = ERB.new(File.read(File.join(USER_DATA_DIR, 'coordinator.erb'))).result(binding)
      append_user_data(coordinator_user_data)

      super

      set_config('coordinator_aws_id', @instance.id)
      set_config('coordinator_private_ip', @instance.private_ip_address)
      @config_data.save_cluster_data
      debug('Finished creating coordinator')
    end

    def destroy
      debug('DESTROYING COORDINATOR')
      set_config('instance_id', @config_data.coordinator_aws_id)
      super
      debug('FINISHED DESTROYING COORDINATOR')
    end

  end

end