module AWS
  module Actions

    module Instance


      def create
        create_instance
      end

      def destroy
        safe_execute(Fog::Compute::AWS::NotFound) {
          destroy_instance(get_config('instance_id'))
        }
      end

      def create_instance

        instance_params = {
            'InstanceType' => get_config('instance_type'),
            'SecurityGroupId' => get_config('security_group_id'),
            'KeyName' => get_config('key_name'),
            'SubnetId' => get_config('subnet_id'),
            'UserData' => @user_data.squeeze(' ').strip
        }

        if get_config('volume_size')
          instance_params['BlockDeviceMapping'] = ['Ebs.VolumeSize' => get_config('volume_size'), 'DeviceName' => '/dev/sda1']
        end

        response = @fog.run_instances(
            get_config('ami_id'),
            1,
            1,
            instance_params
        )

        sleep(2)

        instance_id = response.body['instancesSet'].first['instanceId']

        @instance = @fog.servers.get(instance_id)

        @fog.create_tags(@instance.id, @init_params['tags']) if @init_params['tags']

        @instance.private_key_path = key_path
        debug("Waiting for instance '#{@instance.id}' to come up")
        @instance.wait_for {print '.'; ready?}
        puts 'Done!'
      end

      def destroy_instance(instance_id)
        debug("Terminating instance: #{instance_id}")
        @fog.terminate_instances(instance_id)
        wait_for_state('terminated', instance_id)
        debug("Terminated instance #{instance_id}")
      end

      def get_ami_id(pattern)
        resp = @fog.describe_images('Owner' => AWS::Core::Mixin::Constants::GEX_AWS_ID, 'name' => pattern)
        resp.body['imagesSet'].first['imageId']
      end

      def private_key
        File.read(key_path)
      end

    end

  end
end