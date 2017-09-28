module AWS
  module Core


    class Base

      include Mixin::Params
      include Mixin::Constants
      include Mixin::Helper
      include Mixin::Log

      def initialize(&block)
        @user_data = BASIC_USER_DATA
        @init_params = {}
        instance_eval &block
      end

      def init_config
        @config_data = ConfigData.new(@init_params.fetch('cluster_id'))
      end

      def init_fog
        @fog = Fog::Compute.new(
            provider: 'AWS',
            region: get_config('region'),
            aws_access_key_id: get_config('aws_key_id'),
            aws_secret_access_key: get_config('aws_key_secret')
        )
      end

      def get_config(key)
        val = @config_data.cluster_data.fetch(key, nil) || @init_params.fetch(key)
        #p val
        #val
      end

      def set_config(key, val)
        @config_data.cluster_data[key] = val
      end

      def action(name)
        init_config
        init_fog

        send name
      end

      def get_state(instance_id)
        resp = @fog.describe_instances('instance-id' => instance_id)
        resp.body['reservationSet'][0]['instancesSet'][0]['instanceState']['name']
      end

      def wait_for_state(state, instance_id)
        count = 0
        while get_state(instance_id) != state
          count = count + 1
          sleep(15)
          raise ('Cannot change state') if count > AWS::Core::Mixin::Constants::MAX_RETRIES_AMOUNT
        end

      end

      def key_path
        "/mount/ansibledata/#{get_config('cluster_id')}/credentials/ClusterGX_key_#{get_config('cluster_id')}.pem"
      end

    end


  end
end


