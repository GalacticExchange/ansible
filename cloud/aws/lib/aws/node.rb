module AWS

  class Node < Core::Base

    include Actions::Instance


    def create
      ami_pattern = "*#{get_config('env')}_node*"
      set_config('ami_id', get_ami_id(ami_pattern))
      node_user_data = ERB.new(File.read(File.join(USER_DATA_DIR, 'node.erb')) ).result(binding)
      append_user_data(node_user_data)
      super
      node_data = format_node_data
      @config_data.save_node_data(node_data)
    end


    def destroy
      set_config('instance_id', @config_data.nodes_data[get_config('node_uid')].fetch('aws_instance_id') )
      super
    end


    def format_node_data
      {
          "#{get_config('node_uid')}" => {
              'node_agent_token' => get_config('node_agent_token'),
              'node_name' => get_config('node_name'),
              'aws_instance_id' => @instance.id,
              'private_ip' => @instance.private_ip_address

          }
      }
    end

  end

end