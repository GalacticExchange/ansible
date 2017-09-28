#require_relative '../lib/node'
#require_relative 'spec_helper'
require "ipaddress"
require_relative 'cluster_coordinator_spec'

describe Node do

  before :all do

    #Fog.mock!

    @node = Node.new(
        hadoop_type: 'cdh',
        cluster_id: CLUSTER_ID,
        instance_type: INSTANCE_TYPE,
        gex_node_uid: GEX_NODE_UID,
        node_name: 'node_name',
        node_agent_token: GEX_NODE_AGENT_TOKEN,
        volume_size: VOLUME_SIZE
    )
  end

  describe '#initialize' do
    #TODO has 2x amis main/prod
    it 'has proper file suffix' do
      expect(@node.file_suffix).to eq("#{GEX_ENV}_node_ami_#{HADOOP_TYPE}_id.txt")
    end

    it 'has ami id' do
      expect(@node.instance_ami_id).to start_with('ami-')
    end
  end

  describe '#start_new' do
    it 'has proper instance type' do
      @node.start_new
      expect(@node.instance_type).to eq(INSTANCE_TYPE)
    end

    it 'has aws instance id' do
      expect(@node.node_data[:aws_instance_id]).to start_with('i-')
    end

    it 'has valid ip' do
      expect(IPAddress.valid?(@node.node_data[:private_ip])).to be(true)
    end

    it 'has valid ebs' do
      instance = @node.fog.describe_instances('instance-id' => @node.instance.id).body['reservationSet'][0]['instancesSet'][0]
      volume_id = instance['blockDeviceMapping'][0]['volumeId']
      volume = @node.fog.describe_volumes('volume-id' => volume_id).body['volumeSet'][0]
      expect(volume['size']).to eq(VOLUME_SIZE)
    end

  end

  describe '#launch_weave_node' do
    it 'runs normally' do
      @node.launch_weave_node
    end
  end

  describe '#install_client' do
    it 'runs normally' do
      @node.install_client
    end
  end

  describe '#save_node_data' do
    it 'saves node data' do
      @node.save_node_data
      node_data = JSON.parse(File.read(@node.config.nodes_json_file_path), symbolize_names: true)
      expect(@node.node_data).to eq(node_data[0])
    end
  end

  describe '#instantiate' do
    it 'creates node object' do
      @node = Node.instantiate(CLUSTER_ID, GEX_NODE_UID)
      expect(@node).not_to eq(nil)
    end

    it 'has instance id' do
      expect(@node.instance.id).to start_with('i-')
    end
  end

  describe 'change states' do
    it 'starts normally' do
      @node.change_instance_state('start')
      expect(@node.get_state).to eq('running')
    end

    it 'stops normally' do
      @node.change_instance_state('stop')
      expect(@node.get_state).to eq('stopped')
    end

    it 'raises exception on reboot' do
      expect { @node.change_instance_state('reboot') }.to raise_error('Cannot reboot: Wrong initial state')
    end

    it 'starts and reboots normally' do
      @node.change_instance_state('start')
      @node.change_instance_state('reboot')
      expect(@node.get_state).to eq('running')
    end

  end

end