require_relative 'spec_helper'


require_relative 'pre_config_spec'

describe ClusterCoordinator do
  before :all do

    Fog.mock!
    #Fog::Mock.delay = 0

    @coord = ClusterCoordinator.new(
        cluster_id: CLUSTER_ID
    )
  end

  describe '#initialize' do
    it 'has instance ami id' do
      expect(@coord.instance_ami_id).to start_with('ami-')
    end
  end

  describe '#check_coordinator_existence' do
    it 'returns None' do
      expect(@coord.check_coordinator_existence).to eq('None')
    end
  end

  describe '#start_new' do
    it 'has proper instance type' do
      @coord.start_new
      expect(@coord.instance_type).to eq('t2.micro')
    end

    #it 'has elastic ip' do
    #  public_ip = @coord.fog.describe_addresses.body['addressesSet'].first['publicIp']
    #  expect(public_ip).to eq(@coord.config.cluster_data[:coordinator_public_ip])
    #
    #  expect(@coord.config.cluster_data[:coordinator_public_ip]).to eq(@coord.instance.public_ip_address)
    #end

    it 'has public ip' do
      expect(@coord.config.cluster_data[:coordinator_public_ip]).not_to be(nil)
    end

    it 'has instance-user vagrant' do
      expect(@coord.instance.username).to eq('vagrant')
    end

  end

  describe '#launch_weave' do
    it 'executes ssh commands and launches weave' do
      @coord.launch_weave
      #arr = @coord.instance.ssh('')
      #arr.pop
      #p arr
    end
  end

  describe '#save_cluster_data' do
    it 'writes coordinator data in cluster data file' do
      @coord.save_cluster_data

      data = JSON.parse(File.read(@coord.config.cluster_json_file_path), symbolize_names: true)
      expect(data).to eq(@coord.config.cluster_data)
    end
  end

  describe '#instantiate' do

    it 'creates coordinator object' do
      @coord = ClusterCoordinator.instantiate(CLUSTER_ID)
      expect(@coord).not_to eq(nil)
    end

    it 'has instance id' do
      expect(@coord.instance.id).to start_with('i-')
    end

  end

  describe 'change states' do
    it 'starts normally' do
      @coord.change_instance_state('start')
      expect(@coord.get_state).to eq('running')
    end

    it 'stops normally' do
      @coord.change_instance_state('stop')
      expect(@coord.get_state).to eq('stopped')
    end

    it 'raises exception on reboot' do
      expect { @coord.change_instance_state('reboot') }.to raise_error('Cannot reboot: Wrong initial state')
    end

    it 'starts and reboots normally' do
      @coord.change_instance_state('start')
      @coord.change_instance_state('reboot')
      expect(@coord.get_state).to eq('running')
    end

  end


end

