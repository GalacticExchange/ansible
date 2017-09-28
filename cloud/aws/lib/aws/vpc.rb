module AWS

  class VPC < Core::Base


    def create
      begin

        debug('Creating VPC')
        create_vpc
        debug('Creating Subnet')
        create_subnet
        debug('Creating Security group')
        create_security_group
        debug('Creating Gateway')
        create_gateway
        debug('Creating Key pair')
        create_key_pair
        #wtf.wtf # TODO
        debug('Saving cluster data')
        save_cluster_data
        debug('Initiating node data')
        init_node_data

      rescue StandardError => e
        warn "EXCEPTION CAUGHT:#{e.class}, destroying infrastructure..."
        destroy
        raise e
      end

      #@config_data.save_cluster_data
    end

    def destroy
      destroy_remaining_instances

      debug('DESTROYING VPC')
      delete_key_pair

      destroy_subnet
      destroy_security_group
      destroy_gateway

      destroy_vpc

      debug('FINISHED DESTROYING VPC')
    end

    def create_vpc
      gex_vpc = @fog.create_vpc(CIDR_VPC)
      gex_vpc_id = gex_vpc.body['vpcSet'][0]['vpcId']

      @fog.create_tags(gex_vpc_id, 'cluster_uid' => get_config('cluster_uid'))
      @fog.create_tags(gex_vpc_id, 'Name' => "gex-#{get_config('cluster_uid')}")

      set_config('vpc_id', gex_vpc_id)

    end

    def create_subnet
      gex_vpc_id = get_config('vpc_id')
      gex_subnet = @fog.create_subnet(gex_vpc_id, CIDR_VPC)

      gex_subnet_id = gex_subnet.body['subnet']['subnetId']

      set_config('subnet_id', gex_subnet_id)


      @fog.modify_subnet_attribute(gex_subnet_id, {'MapPublicIpOnLaunch' => true})
    end

    def create_security_group
      gex_security_group = @fog.create_security_group('ClusterGX', 'ClusterGX VPC security group', get_config('vpc_id'))
      set_config('security_group_id', gex_security_group.body['groupId'])


      #All ICMP
      @fog.authorize_security_group_ingress({
                                                'GroupId' => get_config('security_group_id'),
                                                'CidrIp' => '0.0.0.0/0',
                                                'FromPort' => -1,
                                                'IpProtocol' => 'icmp',
                                                'ToPort' => -1
                                            })
      #SSH
      @fog.authorize_security_group_ingress({
                                                'GroupId' => get_config('security_group_id'),
                                                'CidrIp' => '0.0.0.0/0',
                                                'FromPort' => 22,
                                                'IpProtocol' => 'tcp',
                                                'ToPort' => 22
                                            })

      #All traffic (needed by weave)
      @fog.authorize_security_group_ingress({
                                                'GroupId' => get_config('security_group_id'),
                                                'CidrIp' => '0.0.0.0/0',
                                                'FromPort' => 0,
                                                'IpProtocol' => '-1',
                                                'ToPort' => 65535
                                            })
    end

    def create_gateway
      gex_gateway = @fog.create_internet_gateway
      gex_gateway_id = gex_gateway.body['internetGatewaySet'][0]['internetGatewayId']
      set_config('gateway_id', gex_gateway_id)

      @fog.attach_internet_gateway(gex_gateway_id, get_config('vpc_id'))

      route_table_id = @fog.describe_route_tables({'vpc-id' => get_config('vpc_id')}).body['routeTableSet'][0]['routeTableId']
      set_config('route_table_id', route_table_id)
      @fog.create_route(route_table_id, '0.0.0.0/0', gex_gateway_id)
    end

    def create_key_pair
      key_name = "ClusterGX_key_#{get_config('cluster_id')}"
      set_config('key_name', key_name)

      key = @fog.create_key_pair(key_name)

      pem_file = File.new(key_path, 'w')
      pem_file.puts(key.body['keyMaterial'])

      File.chmod(0400, key_path)
    end

    def save_cluster_data
      [:env, :aws_key_id, :aws_key_secret, :cluster_id, :cluster_uid,
       :region, :cluster_name, :aws_counter, :key_name, :vpc_id,
       :subnet_id, :security_group_id, :gateway_id, :route_table_id].each do |key|
        key = key.to_s

        @config_data.cluster_data[key] ||= @init_params.fetch(key)

      end


      @config_data.save_cluster_data

    end


    def destroy_vpc
      safe_execute(Fog::Compute::AWS::NotFound) {@fog.delete_vpc(get_config('vpc_id'))}
    end

    def destroy_subnet
      safe_execute(Fog::Compute::AWS::NotFound) {@fog.delete_subnet(get_config('subnet_id'))}
    end

    def destroy_security_group
      safe_execute(Fog::Compute::AWS::NotFound) {@fog.delete_security_group(nil, get_config('security_group_id'))}
    end

    def destroy_gateway
      safe_execute(Fog::Compute::AWS::NotFound) {
        @fog.detach_internet_gateway(get_config('gateway_id'), get_config('vpc_id'))
        @fog.delete_internet_gateway(get_config('gateway_id'))
      }
    end

    def delete_key_pair
      safe_execute(Fog::Compute::AWS::NotFound) {@fog.delete_key_pair(get_config('key_name'))}
      safe_execute(Errno::ENOENT) {FileUtils.remove(key_path)}
    end

    def destroy_remaining_instances
      safe_execute {
        resp = @fog.describe_instances('vpc-id' => get_config('vpc_id')).body
        instances_ids = resp['reservationSet'].map {|e| e['instancesSet'][0]['instanceId']}
        @fog.terminate_instances(instances_ids)

        instances_ids.each {|id|
          wait_for_state('terminated', id)
        }
      }
    end

    def init_node_data
      File.write(@config_data.nodes_data_path, '{}')
    end

  end


end